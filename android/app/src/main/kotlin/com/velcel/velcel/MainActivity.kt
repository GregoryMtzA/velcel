package com.velcel.velcel

import android.content.ContentValues
import android.Manifest
import android.app.DownloadManager
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import android.bluetooth.BluetoothAdapter
import android.content.pm.PackageManager
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import androidx.core.content.ContextCompat
import java.io.File

class MainActivity : FlutterActivity() {
    private val fileStorageChannel = "com.velcel.velcel/file_storage"
    private val bluetoothChannel = "com.velcel.velcel/bluetooth"
    private val downloadNotificationChannel = "downloads"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            fileStorageChannel,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "saveToPublicDownloads" -> {
                    val fileName = call.argument<String>("fileName")
                    val bytes = call.argument<ByteArray>("bytes")
                    val mimeType = call.argument<String>("mimeType")

                    if (fileName == null || bytes == null || mimeType == null) {
                        result.error(
                            "INVALID_ARGUMENTS",
                            "Faltan datos para guardar el archivo.",
                            null,
                        )
                        return@setMethodCallHandler
                    }

                    try {
                        result.success(saveToPublicDownloads(fileName, bytes, mimeType).toString())
                    } catch (error: Exception) {
                        result.error(
                            "SAVE_FAILED",
                            error.message ?: "No se pudo guardar el archivo.",
                            null,
                        )
                    }
                }

                "showDownloadNotification" -> {
                    val fileName = call.argument<String>("fileName")
                    if (fileName == null) {
                        result.error("INVALID_ARGUMENTS", "Falta el nombre del archivo.", null)
                        return@setMethodCallHandler
                    }

                    try {
                        showDownloadNotification(fileName)
                        result.success(null)
                    } catch (error: Exception) {
                        result.error(
                            "NOTIFICATION_FAILED",
                            error.message ?: "No se pudo mostrar la notificación.",
                            null,
                        )
                    }
                }

                else -> result.notImplemented()
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            bluetoothChannel,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getBondedDevices" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S &&
                        ContextCompat.checkSelfPermission(
                            this,
                            Manifest.permission.BLUETOOTH_CONNECT,
                        ) != PackageManager.PERMISSION_GRANTED
                    ) {
                        result.error(
                            "BLUETOOTH_CONNECT_DENIED",
                            "Se requiere permiso para consultar dispositivos Bluetooth vinculados.",
                            null,
                        )
                        return@setMethodCallHandler
                    }

                    val adapter = BluetoothAdapter.getDefaultAdapter()
                    val devices = adapter?.bondedDevices?.map { device ->
                        "${device.name ?: "Dispositivo Bluetooth"}#${device.address}"
                    } ?: emptyList()
                    result.success(devices)
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun showDownloadNotification(fileName: String) {
        val notificationManager = getSystemService(NotificationManager::class.java)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            notificationManager.createNotificationChannel(
                NotificationChannel(
                    downloadNotificationChannel,
                    "Descargas",
                    NotificationManager.IMPORTANCE_DEFAULT,
                ).apply {
                    description = "Notificaciones de archivos descargados"
                },
            )
        }

        val downloadsIntent = Intent(DownloadManager.ACTION_VIEW_DOWNLOADS).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        val pendingIntentFlags = PendingIntent.FLAG_UPDATE_CURRENT or
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                PendingIntent.FLAG_IMMUTABLE
            } else {
                0
            }
        val pendingIntent = PendingIntent.getActivity(
            this,
            fileName.hashCode(),
            downloadsIntent,
            pendingIntentFlags,
        )

        val notificationBuilder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, downloadNotificationChannel)
        } else {
            Notification.Builder(this)
        }

        notificationManager.notify(
            fileName.hashCode(),
            notificationBuilder
                .setSmallIcon(android.R.drawable.stat_sys_download_done)
                .setContentTitle("Inventario descargado")
                .setContentText(fileName)
                .setContentIntent(pendingIntent)
                .setAutoCancel(true)
                .build(),
        )
    }

    private fun saveToPublicDownloads(
        fileName: String,
        bytes: ByteArray,
        mimeType: String,
    ): Uri {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
            val downloadsDirectory = Environment.getExternalStoragePublicDirectory(
                Environment.DIRECTORY_DOWNLOADS,
            )
            if (!downloadsDirectory.exists() && !downloadsDirectory.mkdirs()) {
                throw IllegalStateException("No se pudo crear la carpeta Descargas.")
            }

            val file = File(downloadsDirectory, fileName)
            file.writeBytes(bytes)
            return Uri.fromFile(file)
        }

        val resolver = contentResolver
        val values = ContentValues().apply {
            put(MediaStore.Downloads.DISPLAY_NAME, fileName)
            put(MediaStore.Downloads.MIME_TYPE, mimeType)
            put(MediaStore.Downloads.RELATIVE_PATH, Environment.DIRECTORY_DOWNLOADS)
            put(MediaStore.Downloads.IS_PENDING, 1)
        }
        val uri = resolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, values)
            ?: throw IllegalStateException("No se pudo crear el archivo en Descargas.")

        return try {
            resolver.openOutputStream(uri)?.use { output ->
                output.write(bytes)
            } ?: throw IllegalStateException("No se pudo escribir el archivo.")

            val publishedValues = ContentValues().apply {
                put(MediaStore.Downloads.IS_PENDING, 0)
            }
            resolver.update(uri, publishedValues, null, null)
            uri
        } catch (error: Exception) {
            resolver.delete(uri, null, null)
            throw error
        }
    }
}
