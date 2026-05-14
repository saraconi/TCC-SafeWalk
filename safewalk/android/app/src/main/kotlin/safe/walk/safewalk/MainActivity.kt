package safe.walk.safewalk

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    companion object {
        const val CHANNEL          = "safewalk/emergency"
        const val PERMISSION_CODE  = 100
    }

    private val permissoesNecessarias = mutableListOf(
        Manifest.permission.RECORD_AUDIO,
        Manifest.permission.SEND_SMS,
    ).apply {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            add(Manifest.permission.POST_NOTIFICATIONS)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {

                    "iniciarServico" -> {
                        solicitarPermissoes()
                        val keyword   = call.argument<String>("keyword") ?: ""
                        val contatos  = call.argument<List<String>>("contatos") ?: emptyList()

                        val intent = Intent(this, EmergencyService::class.java).apply {
                            action = EmergencyService.ACTION_START
                            putExtra(EmergencyService.EXTRA_KEYWORD, keyword)
                            putStringArrayListExtra(EmergencyService.EXTRA_CONTACTS, ArrayList(contatos))
                        }

                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            startForegroundService(intent)
                        } else {
                            startService(intent)
                        }
                        result.success(true)
                    }

                    "pararServico" -> {
                        val intent = Intent(this, EmergencyService::class.java).apply {
                            action = EmergencyService.ACTION_STOP
                        }
                        startService(intent)
                        result.success(null)
                    }

                    "pararGravacao" -> {
                        val intent = Intent(this, EmergencyService::class.java).apply {
                            action = EmergencyService.ACTION_STOP_REC
                        }
                        startService(intent)
                        result.success(null)
                    }

                    "servicoAtivo" -> {
                        result.success(EmergencyService.isRunning)
                    }

                    "salvarEmail" -> {
                        val email = call.argument<String>("email") ?: ""
                        getSharedPreferences("safewalk_prefs", MODE_PRIVATE)
                            .edit().putString("usuario_email", email).apply()
                        result.success(null)
                    }

                    else -> result.notImplemented()
                }
            }
    }

    private fun solicitarPermissoes() {
        val faltando = permissoesNecessarias.filter {
            ContextCompat.checkSelfPermission(this, it) != PackageManager.PERMISSION_GRANTED
        }
        if (faltando.isNotEmpty()) {
            ActivityCompat.requestPermissions(this, faltando.toTypedArray(), PERMISSION_CODE)
        }
    }
}
