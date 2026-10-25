package br.com.alceyatri.driver

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.background
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
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
import android.util.Base64

private val API_URL = BuildConfig.API_URL

private fun api(method: String, path: String, user: String, password: String, body: JSONObject? = null): JSONObject {
    val connection = (URL("$API_URL$path").openConnection() as HttpURLConnection)
    connection.requestMethod = method
    connection.connectTimeout = 5000
    connection.readTimeout = 8000
    connection.setRequestProperty("Content-Type", "application/json")
    val credentials = Base64.encodeToString("$user:$password".toByteArray(Charsets.UTF_8), Base64.NO_WRAP)
    connection.setRequestProperty("Authorization", "Basic $credentials")
    if (body != null) {
        connection.doOutput = true
        connection.outputStream.use { it.write(body.toString().toByteArray(Charsets.UTF_8)) }
    }
    return try {
        val code = connection.responseCode
        val stream = if (code < 400) connection.inputStream else connection.errorStream
        val raw = stream.bufferedReader().use { it.readText() }
        if (code == 401) error("Credenciais incorretas (401)")
        val result = JSONObject(raw)
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
    var connected by remember { mutableStateOf(false) }
    var username by remember { mutableStateOf("alce-teste") }
    var password by remember { mutableStateOf("") }
    val scope = rememberCoroutineScope()
    var ride by remember { mutableStateOf<JSONObject?>(null) }
    var message by remember { mutableStateOf<String?>(null) }
    var busy by remember { mutableStateOf(false) }
    var refreshKey by remember { mutableIntStateOf(0) }
    var consecutiveFailures by remember { mutableIntStateOf(0) }

    LaunchedEffect(online, refreshKey) {
        if (online) {
            while (true) {
                try {
                    val response = withContext(Dispatchers.IO) { api("GET", "/rides/current", username, password) }
                    ride = response.optJSONObject("ride")
                    consecutiveFailures = 0
                    message = null
                } catch (e: Exception) {
                    consecutiveFailures++
                    if (consecutiveFailures >= 2) message = "Conexão instável. Tentando reconectar automaticamente…"
                }
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
    val pink = Color(0xFFFF00BE)
    val statusLabel = when (status) {
        "requested" -> "Nova solicitação"
        "accepted" -> "A caminho do passageiro"
        "driver_arrived" -> "Aguardando embarque"
        "in_progress" -> "Viagem em andamento"
        "completed" -> "Viagem concluída"
        "cancelled" -> "Corrida cancelada"
        else -> "Nenhuma corrida no momento"
    }
    MaterialTheme(colorScheme = lightColorScheme(primary = Color(0xFF7954A7), secondary = pink)) {
        Surface(modifier = Modifier.fillMaxSize(), color = Color(0xFFF8F7FB)) {
            Column(modifier = Modifier.fillMaxSize().padding(20.dp), verticalArrangement = Arrangement.spacedBy(16.dp)) {
                Text("ALCE YATRI", style = MaterialTheme.typography.headlineMedium, fontWeight = FontWeight.ExtraBold)
                Text("Painel do motorista", style = MaterialTheme.typography.titleMedium, color = Color.Gray)
                Surface(color = if (online) Color(0xFFE7F7EF) else Color(0xFFECEAF2), shape = RoundedCornerShape(24.dp)) {
                    Column(modifier = Modifier.fillMaxWidth().padding(22.dp), verticalArrangement = Arrangement.spacedBy(10.dp)) {
                        Text(if (online) "● VOCÊ ESTÁ ONLINE" else "● VOCÊ ESTÁ OFFLINE", color = if (online) Color(0xFF16734B) else Color.DarkGray, fontWeight = FontWeight.Bold)
                        Text(if (online) "Pronto para receber solicitações" else "Fique disponível para começar", style = MaterialTheme.typography.titleLarge, fontWeight = FontWeight.Bold)
                        if (connected) Button(onClick = { online = !online; if (!online) ride = null }, modifier = Modifier.fillMaxWidth()) {
                            Text(if (online) "Ficar offline" else "Ficar disponível")
                        }
                    }
                }
                Surface(color = Color.White, shape = RoundedCornerShape(24.dp)) {
                    Column(modifier = Modifier.fillMaxWidth().padding(22.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
                        Text("CORRIDA ATUAL", color = Color.Gray, style = MaterialTheme.typography.labelMedium)
                        Text(statusLabel, style = MaterialTheme.typography.titleLarge, fontWeight = FontWeight.Bold)
                        if (ride != null) Text("ID: ${ride?.optString("id")}", style = MaterialTheme.typography.bodySmall)
                        if (online && connected) {
                            OutlinedButton(onClick = { refreshKey++ }, modifier = Modifier.fillMaxWidth()) { Text("Atualizar corrida") }
                            if (next != null) {
                                val id = ride?.optString("id") ?: ""
                                Button(enabled = !busy, modifier = Modifier.fillMaxWidth(), onClick = {
                                    busy = true
                                    scope.launch {
                                        try {
                                            val result = withContext(Dispatchers.IO) {
                                                api("POST", "/rides/$id/status", username, password, JSONObject().put("status", next))
                                            }
                                            ride = result.getJSONObject("ride")
                                            message = null
                                        } catch (e: Exception) {
                                            message = "Alteração não confirmada. Atualize antes de tentar novamente: ${e.message}"
                                        } finally { busy = false }
                                    }
                                }) { Text(label) }
                            }
                        }
                    }
                }
                if (!connected) Surface(color = Color.White, shape = RoundedCornerShape(24.dp)) {
                    Column(modifier = Modifier.fillMaxWidth().padding(20.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
                        Text("Acesso ao laboratório", style = MaterialTheme.typography.titleMedium, fontWeight = FontWeight.Bold)
                        OutlinedTextField(value = username, onValueChange = { username = it }, label = { Text("Usuário de testes") }, modifier = Modifier.fillMaxWidth())
                        OutlinedTextField(value = password, onValueChange = { password = it }, label = { Text("Senha de testes") }, visualTransformation = androidx.compose.ui.text.input.PasswordVisualTransformation(), modifier = Modifier.fillMaxWidth())
                        Button(enabled = !busy && username.isNotBlank() && password.isNotBlank(), modifier = Modifier.fillMaxWidth(), onClick = {
                            busy = true
                            scope.launch {
                                try {
                                    withContext(Dispatchers.IO) { api("GET", "/health", username, password) }
                                    connected = true
                                    message = null
                                } catch (e: Exception) { message = "Falha na conexão: ${e.message}" }
                                finally { busy = false }
                            }
                        }) { Text("Conectar à API") }
                    }
                }
                if (message != null) Text(message!!, color = MaterialTheme.colorScheme.error)
                Spacer(modifier = Modifier.weight(1f))
                Text("AMBIENTE DE TESTES • SEM CORRIDAS REAIS", modifier = Modifier.fillMaxWidth(), textAlign = TextAlign.Center, style = MaterialTheme.typography.labelSmall, color = Color.Gray)
            }
        }
    }
}
