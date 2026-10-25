package br.com.alceyatri.driver

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import org.json.JSONObject
import java.net.HttpURLConnection
import java.net.URL

private val API_URL = BuildConfig.API_URL

private fun api(method: String, path: String, body: JSONObject? = null): JSONObject {
    val connection = (URL("$API_URL$path").openConnection() as HttpURLConnection)
    connection.requestMethod = method
    connection.connectTimeout = 5000
    connection.readTimeout = 8000
    connection.setRequestProperty("Content-Type", "application/json")
    if (body != null) {
        connection.doOutput = true
        connection.outputStream.use { it.write(body.toString().toByteArray(Charsets.UTF_8)) }
    }
    return try {
        val code = connection.responseCode
        val stream = if (code < 400) connection.inputStream else connection.errorStream
        val result = JSONObject(stream.bufferedReader().use { it.readText() })
        if (code >= 400) error("HTTP $code: ${result.optString("error")}")
        result
    } finally { connection.disconnect() }
}

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent { DriverScreen() }
    }
}

@Composable
private fun DriverScreen() {
    var online by remember { mutableStateOf(false) }
    var ride by remember { mutableStateOf<JSONObject?>(null) }
    var message by remember { mutableStateOf<String?>(null) }
    var busy by remember { mutableStateOf(false) }
    var refreshKey by remember { mutableIntStateOf(0) }

    LaunchedEffect(online, refreshKey) {
        if (online) {
            while (true) {
                try {
                    val response = withContext(Dispatchers.IO) { api("GET", "/rides/current") }
                    ride = response.optJSONObject("ride")
                    message = null
                } catch (e: Exception) { message = "API indisponível: ${e.message}" }
                delay(3000)
            }
        }
    }

    val status = ride?.optString("status") ?: "nenhuma corrida"
    val next = when (status) {
        "requested" -> "accepted"
        "accepted" -> "driver_arrived"
        "driver_arrived" -> "in_progress"
        "in_progress" -> "completed"
        else -> null
    }
    val label = when (next) {
        "accepted" -> "Aceitar corrida"
        "driver_arrived" -> "Cheguei ao embarque"
        "in_progress" -> "Iniciar viagem"
        "completed" -> "Finalizar viagem"
        else -> ""
    }
    MaterialTheme {
        Surface(modifier = Modifier.fillMaxSize()) {
            Column(modifier = Modifier.padding(24.dp), verticalArrangement = Arrangement.spacedBy(16.dp)) {
                Text("Alce Yatri • Motorista", style = MaterialTheme.typography.headlineMedium)
                Text("Laboratório: sem corridas reais.")
                Text("Disponibilidade: ${if (online) "online" else "offline"}")
                Text("Corrida: $status")
                if (message != null) Text(message!!, color = MaterialTheme.colorScheme.error)
                Button(onClick = { online = !online; if (!online) ride = null }) {
                    Text(if (online) "Ficar offline" else "Ficar disponível")
                }
                if (online) {
                    OutlinedButton(onClick = { refreshKey++ }) { Text("Atualizar") }
                    if (next != null) {
                        val id = ride?.optString("id") ?: ""
                        val scope = rememberCoroutineScope()
                        Button(enabled = !busy, onClick = {
                            busy = true
                            scope.launch {
                                try {
                                    val result = withContext(Dispatchers.IO) {
                                        api("POST", "/rides/$id/status", JSONObject().put("status", next))
                                    }
                                    ride = result.getJSONObject("ride")
                                    message = null
                                } catch (e: Exception) { message = "Erro: ${e.message}" }
                                finally { busy = false }
                            }
                        }) { Text(label) }
                    }
                }
            }
        }
    }
}
