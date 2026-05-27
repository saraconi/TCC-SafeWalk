package safe.walk.safewalk

import android.app.*
import android.content.Intent
import android.content.pm.PackageManager
import android.media.AudioFormat
import android.media.AudioRecord
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
        const val CHANNEL_ID      = "safewalk_emergency"
        const val NOTIFICATION_ID = 1
        const val ACTION_START    = "START"
        const val ACTION_STOP     = "STOP"
        const val ACTION_STOP_REC = "STOP_REC"
        const val ACTION_SIMULATE = "SIMULATE"
        const val EXTRA_KEYWORD   = "KEYWORD"
        const val EXTRA_CONTACTS  = "CONTACTS"
        var isRunning             = false
    }

    private var keyword: String             = ""
    private var contacts: ArrayList<String> = arrayListOf()

    // Vosk via reflexão
    private var voskModel: Any?      = null
    private var voskRecognizer: Any? = null
    private var audioRecord: AudioRecord? = null
    private var listenThread: Thread? = null
    private var isListening           = false

    // Gravação
    private var mediaRecorder: MediaRecorder? = null
    private var isRecording                   = false

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        isRunning = true
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_START -> {
                keyword  = intent.getStringExtra(EXTRA_KEYWORD) ?: ""
                contacts = intent.getStringArrayListExtra(EXTRA_CONTACTS) ?: arrayListOf()
                startForeground(NOTIFICATION_ID, buildNotification("Inicializando reconhecimento de voz..."))
                iniciarVosk()
            }
            ACTION_STOP     -> stopSelf()
            ACTION_STOP_REC -> stopRecording()
            ACTION_SIMULATE -> {
                stopListening()
                startForeground(NOTIFICATION_ID, buildNotification("Modo de teste ativo"))
                onKeywordDetected()
            }
        }
        return START_STICKY
    }

    override fun onDestroy() {
        isRunning = false
        stopListening()
        stopRecording()
        super.onDestroy()
    }

    // ── Vosk via Reflexão ─────────────────────────────────────

    private fun iniciarVosk() {
        Thread {
            try {
                android.util.Log.d("EmergencyService", "Carregando modelo Vosk via reflexão...")
                updateNotification("Carregando modelo de voz...")

                val modelDir = File(cacheDir, "vosk-model")
                if (!modelDir.exists()) {
                    copiarAssets("vosk-model", modelDir)
                }

                // Carrega Model via reflexão
                val modelClass = Class.forName("com.alphacephei.vosk.Model")
                voskModel = modelClass.getConstructor(String::class.java)
                    .newInstance(modelDir.absolutePath)

                // Carrega Recognizer via reflexão
                val recClass = Class.forName("com.alphacephei.vosk.Recognizer")
                voskRecognizer = recClass.getConstructor(modelClass, Float::class.java)
                    .newInstance(voskModel, 16000.0f)

                android.util.Log.d("EmergencyService", "Modelo Vosk carregado! Ouvindo por: $keyword")
                updateNotification("Ouvindo — diga \"$keyword\" para acionar")
                iniciarCaptura()

            } catch (e: Exception) {
                android.util.Log.e("EmergencyService", "Erro Vosk: ${e.message}", e)
                updateNotification("Erro ao carregar reconhecimento: ${e.message}")
                stopSelf()
            }
        }.start()
    }

    private fun iniciarCaptura() {
        if (ContextCompat.checkSelfPermission(this,
                android.Manifest.permission.RECORD_AUDIO) != PackageManager.PERMISSION_GRANTED) return

        val sampleRate = 16000
        val bufferSize = AudioRecord.getMinBufferSize(
            sampleRate, AudioFormat.CHANNEL_IN_MONO, AudioFormat.ENCODING_PCM_16BIT) * 4

        audioRecord = AudioRecord(
            MediaRecorder.AudioSource.MIC, sampleRate,
            AudioFormat.CHANNEL_IN_MONO, AudioFormat.ENCODING_PCM_16BIT, bufferSize)
        audioRecord?.startRecording()
        isListening = true

        val recClass         = Class.forName("com.alphacephei.vosk.Recognizer")
        val acceptMethod     = recClass.getMethod("acceptWaveForm", ByteArray::class.java, Int::class.java)
        val resultMethod     = recClass.getMethod("getResult")
        val partialMethod    = recClass.getMethod("getPartialResult")

        listenThread = Thread {
            val buffer = ShortArray(bufferSize / 2)
            android.util.Log.d("EmergencyService", "Captura iniciada")

            while (isListening) {
                val lidos = audioRecord?.read(buffer, 0, buffer.size) ?: 0
                if (lidos > 0) {
                    val bytes = ByteArray(lidos * 2)
                    for (i in 0 until lidos) {
                        bytes[i * 2]     = (buffer[i].toInt() and 0xFF).toByte()
                        bytes[i * 2 + 1] = (buffer[i].toInt() shr 8 and 0xFF).toByte()
                    }
                    val aceito = acceptMethod.invoke(voskRecognizer, bytes, bytes.size) as Boolean
                    if (aceito) {
                        val resultado = resultMethod.invoke(voskRecognizer) as? String ?: ""
                        android.util.Log.d("EmergencyService", "Reconhecido: $resultado")
                        verificarPalavraChave(resultado)
                    } else {
                        val parcial = partialMethod.invoke(voskRecognizer) as? String ?: ""
                        if (parcial.isNotEmpty() && parcial != "{\"partial\" : \"\"}") {
                            android.util.Log.d("EmergencyService", "Parcial: $parcial")
                            verificarPalavraChave(parcial)
                        }
                    }
                }
            }
        }
        listenThread?.start()
    }

    private fun verificarPalavraChave(texto: String) {
        if (texto.lowercase().contains(keyword.lowercase())) {
            android.util.Log.d("EmergencyService", "PALAVRA-CHAVE DETECTADA!")
            isListening = false
            onKeywordDetected()
        }
    }

    private fun stopListening() {
        isListening = false
        listenThread?.interrupt()
        listenThread = null
        audioRecord?.stop()
        audioRecord?.release()
        audioRecord = null
        try {
            voskRecognizer?.let {
                it.javaClass.getMethod("close").invoke(it)
            }
            voskModel?.let {
                it.javaClass.getMethod("close").invoke(it)
            }
        } catch (_: Exception) {}
        voskRecognizer = null
        voskModel = null
    }

    private fun onKeywordDetected() {
        updateNotification("⚠️ Palavra detectada! Gravando e acionando emergência...")
        sendSmsToContacts()
        startRecording()
        ligarParaPolicia()
    }

    // ── Gravação ──────────────────────────────────────────────

    private fun startRecording() {
        if (isRecording) return
        if (ContextCompat.checkSelfPermission(this,
                android.Manifest.permission.RECORD_AUDIO) != PackageManager.PERMISSION_GRANTED) return

        val timestamp = SimpleDateFormat("yyyyMMdd_HHmmss", Locale.getDefault()).format(Date())
        val file = File(getExternalFilesDir(null), "emergencia_$timestamp.m4a")

        mediaRecorder = (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S)
            MediaRecorder(this) else @Suppress("DEPRECATION") MediaRecorder()).apply {
            setAudioSource(MediaRecorder.AudioSource.MIC)
            setOutputFormat(MediaRecorder.OutputFormat.MPEG_4)
            setAudioEncoder(MediaRecorder.AudioEncoder.AAC)
            setOutputFile(file.absolutePath)
            prepare()
            start()
        }
        isRecording = true
    }

    private fun stopRecording() {
        if (!isRecording) return
        try { mediaRecorder?.stop() } catch (_: Exception) {}
        mediaRecorder?.release()
        mediaRecorder = null
        isRecording = false
        updateNotification("Gravação encerrada.")
    }

    // ── SMS ───────────────────────────────────────────────────

    private fun sendSmsToContacts() {
        if (ContextCompat.checkSelfPermission(this,
                android.Manifest.permission.SEND_SMS) != PackageManager.PERMISSION_GRANTED) return

        val nome = getSharedPreferences("safewalk_prefs", MODE_PRIVATE)
            .getString("usuario_email", "usuário") ?: "usuário"
        val message = "🚨 EMERGÊNCIA Safe Walk: $nome acionou o alarme de emergência."

        val smsManager = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S)
            applicationContext.getSystemService(SmsManager::class.java)
        else @Suppress("DEPRECATION") SmsManager.getDefault()

        contacts.forEach { numero ->
            try { smsManager?.sendTextMessage(numero, null, message, null, null) }
            catch (_: Exception) {}
        }
    }

    // ── Ligação ───────────────────────────────────────────────

    private fun ligarParaPolicia() {
        if (ContextCompat.checkSelfPermission(this,
                android.Manifest.permission.CALL_PHONE) != PackageManager.PERMISSION_GRANTED) return
        try {
            startActivity(android.content.Intent(android.content.Intent.ACTION_CALL).apply {
                data  = android.net.Uri.parse("tel:190")
                flags = android.content.Intent.FLAG_ACTIVITY_NEW_TASK
            })
        } catch (e: Exception) {
            android.util.Log.e("EmergencyService", "Erro ao ligar: ${e.message}")
        }
    }

    // ── Notificação ───────────────────────────────────────────

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(CHANNEL_ID, "Safe Walk Emergência",
                NotificationManager.IMPORTANCE_LOW).apply {
                description = "Reconhecimento de voz em segundo plano"
                setShowBadge(false)
            }
            getSystemService(NotificationManager::class.java).createNotificationChannel(channel)
        }
    }

    private fun buildNotification(text: String): Notification {
        val stopPi = PendingIntent.getService(this, 0,
            Intent(this, EmergencyService::class.java).apply { action = ACTION_STOP },
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
        val stopRecPi = PendingIntent.getService(this, 1,
            Intent(this, EmergencyService::class.java).apply { action = ACTION_STOP_REC },
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
        getSystemService(NotificationManager::class.java)
            .notify(NOTIFICATION_ID, buildNotification(text))
    }

    // ── Utilitário ────────────────────────────────────────────

    private fun copiarAssets(assetPath: String, destino: File) {
        destino.mkdirs()
        assets.list(assetPath)?.forEach { arquivo ->
            val subAsset = "$assetPath/$arquivo"
            val subDest  = File(destino, arquivo)
            try {
                assets.open(subAsset).use { input ->
                    subDest.outputStream().use { output -> input.copyTo(output) }
                }
            } catch (_: Exception) {
                copiarAssets(subAsset, subDest)
            }
        }
    }
}