package safe.walk.safewalk

import ai.picovoice.porcupine.Porcupine
import ai.picovoice.porcupine.PorcupineManager
import ai.picovoice.porcupine.PorcupineManagerCallback
import ai.picovoice.porcupine.PorcupineException
import android.app.*
import android.content.Intent
import android.content.pm.PackageManager
import android.media.MediaRecorder
import android.os.*
import android.telephony.SmsManager
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat
import java.io.File
import java.text.SimpleDateFormat
import java.util.*

class EmergencyService : Service() {

    companion object {
        const val CHANNEL_ID       = "safewalk_emergency"
        const val NOTIFICATION_ID  = 1
        const val ACTION_START     = "START"
        const val ACTION_STOP      = "STOP"
        const val ACTION_STOP_REC  = "STOP_REC"
        const val EXTRA_KEYWORD    = "KEYWORD"
        const val EXTRA_CONTACTS   = "CONTACTS"
        const val ACCESS_KEY       = "8rxqU/GEgLxaYHfBeh/mp9JLA74oMZQ3wSOy1gUEzC6kw4MwrE94Bg=="
        var isRunning              = false
    }

    private var porcupineManager: PorcupineManager? = null
    private var mediaRecorder: MediaRecorder?        = null
    private var isRecording                          = false
    private var contacts: ArrayList<String>          = arrayListOf()
    private var currentAudioFile: String?            = null

    // ── Lifecycle ──────────────────────────────────────────────

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        isRunning = true
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_START -> {
                val keyword   = intent.getStringExtra(EXTRA_KEYWORD) ?: return START_NOT_STICKY
                contacts      = intent.getStringArrayListExtra(EXTRA_CONTACTS) ?: arrayListOf()

                startForeground(NOTIFICATION_ID, buildNotification("Aguardando palavra-chave..."))
                startPorcupine(ACCESS_KEY, keyword)
            }
            ACTION_STOP -> stopSelf()
            ACTION_STOP_REC -> stopRecording()
        }
        return START_STICKY
    }

    override fun onDestroy() {
        isRunning = false
        stopPorcupine()
        stopRecording()
        super.onDestroy()
    }

    // ── Porcupine ──────────────────────────────────────────────

    private fun startPorcupine(accessKey: String, keyword: String) {
        try {
            // Tenta usar keyword built-in; se não encontrar, usa arquivo .ppn em assets
            val builtIn = Porcupine.BuiltInKeyword.values().firstOrNull { kw ->
                kw.name.equals(keyword, ignoreCase = true)
            }

            val callback = PorcupineManagerCallback { _ ->
                onKeywordDetected()
            }

            porcupineManager = if (builtIn != null) {
                PorcupineManager.Builder()
                    .setAccessKey(accessKey)
                    .setKeyword(builtIn)
                    .build(applicationContext, callback)
            } else {
                // Procura arquivo .ppn em assets/keyword_files/
                val keywordPath = copyAssetToCache("keyword_files/$keyword.ppn")
                PorcupineManager.Builder()
                    .setAccessKey(accessKey)
                    .setKeywordPath(keywordPath)
                    .build(applicationContext, callback)
            }

            porcupineManager?.start()
            updateNotification("Ouvindo — diga a palavra-chave para acionar")
        } catch (e: Exception) {
            updateNotification("Erro ao iniciar detecção: ${e.message}")
            stopSelf()
        }
    }

    private fun stopPorcupine() {
        porcupineManager?.stop()
        porcupineManager?.delete()
        porcupineManager = null
    }

    private fun onKeywordDetected() {
        updateNotification("⚠️ Palavra detectada! Gravando...")
        sendSmsToContacts()
        startRecording()
    }

    // ── Gravação ───────────────────────────────────────────────

    private fun startRecording() {
        if (isRecording) return
        if (ContextCompat.checkSelfPermission(this,
                android.Manifest.permission.RECORD_AUDIO) != PackageManager.PERMISSION_GRANTED) return

        val timestamp = SimpleDateFormat("yyyyMMdd_HHmmss", Locale.getDefault()).format(Date())
        val fileName  = "emergencia_$timestamp.m4a"
        val file      = File(getExternalFilesDir(null), fileName)
        currentAudioFile = file.absolutePath

        mediaRecorder = (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S)
            MediaRecorder(this) else @Suppress("DEPRECATION") MediaRecorder()).apply {
            setAudioSource(MediaRecorder.AudioSource.MIC)
            setOutputFormat(MediaRecorder.OutputFormat.MPEG_4)
            setAudioEncoder(MediaRecorder.AudioEncoder.AAC)
            setOutputFile(currentAudioFile)
            prepare()
            start()
        }
        isRecording = true
    }

    private fun stopRecording() {
        if (!isRecording) return
        try {
            mediaRecorder?.stop()
        } catch (_: Exception) {}
        mediaRecorder?.release()
        mediaRecorder  = null
        isRecording    = false
        updateNotification("Gravação encerrada. Ouvindo novamente...")
    }

    // ── SMS ────────────────────────────────────────────────────

    private fun sendSmsToContacts() {
        if (ContextCompat.checkSelfPermission(this,
                android.Manifest.permission.SEND_SMS) != PackageManager.PERMISSION_GRANTED) return

        val message = "🚨 EMERGÊNCIA Safe Walk: ${getDeviceOwnerName()} acionou o alarme de emergência. Localização: não disponível no momento."

        val smsManager = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S)
            applicationContext.getSystemService(SmsManager::class.java)
        else @Suppress("DEPRECATION") SmsManager.getDefault()

        contacts.forEach { numero ->
            try {
                smsManager?.sendTextMessage(numero, null, message, null, null)
            } catch (_: Exception) {}
        }
    }

    private fun getDeviceOwnerName(): String {
        val prefs = getSharedPreferences("safewalk_prefs", MODE_PRIVATE)
        return prefs.getString("usuario_email", "usuário") ?: "usuário"
    }

    // ── Notificação ────────────────────────────────────────────

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Safe Walk Emergência",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Detecção de palavra-chave em segundo plano"
                setShowBadge(false)
            }
            getSystemService(NotificationManager::class.java)
                .createNotificationChannel(channel)
        }
    }

    private fun buildNotification(text: String): Notification {
        val stopIntent = Intent(this, EmergencyService::class.java).apply { action = ACTION_STOP }
        val stopPi    = PendingIntent.getService(this, 0, stopIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)

        val stopRecIntent = Intent(this, EmergencyService::class.java).apply { action = ACTION_STOP_REC }
        val stopRecPi     = PendingIntent.getService(this, 1, stopRecIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("🛡️ Safe Walk ativo")
            .setContentText(text)
            .setSmallIcon(android.R.drawable.ic_lock_silent_mode_off)
            .setOngoing(true)
            .addAction(android.R.drawable.ic_media_pause, "Parar gravação", stopRecPi)
            .addAction(android.R.drawable.ic_delete, "Desativar", stopPi)
            .build()
    }

    private fun updateNotification(text: String) {
        val nm = getSystemService(NotificationManager::class.java)
        nm.notify(NOTIFICATION_ID, buildNotification(text))
    }

    // ── Utilitário ─────────────────────────────────────────────

    private fun copyAssetToCache(assetPath: String): String {
        val outFile = File(cacheDir, File(assetPath).name)
        if (!outFile.exists()) {
            assets.open(assetPath).use { input ->
                outFile.outputStream().use { output -> input.copyTo(output) }
            }
        }
        return outFile.absolutePath
    }
}
