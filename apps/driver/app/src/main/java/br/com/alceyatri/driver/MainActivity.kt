package br.com.alceyatri.driver

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp

private enum class RideState { OFFLINE, ONLINE, OFFERED, ACCEPTED, ARRIVED, IN_PROGRESS, COMPLETED }

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            var state by remember { mutableStateOf(RideState.OFFLINE) }
            MaterialTheme {
                Surface(modifier = Modifier.fillMaxSize()) {
                    Column(modifier = Modifier.padding(24.dp), verticalArrangement = Arrangement.spacedBy(16.dp)) {
                        Text("Alce Yatri • Motorista", style = MaterialTheme.typography.headlineMedium)
                        Text("Protótipo offline: nenhuma corrida real será solicitada.")
                        Text("Estado: ${state.name}")
                        when (state) {
                            RideState.OFFLINE -> Button(onClick = { state = RideState.ONLINE }) { Text("Ficar disponível") }
                            RideState.ONLINE -> {
                                Button(onClick = { state = RideState.OFFERED }) { Text("Simular oferta de corrida") }
                                OutlinedButton(onClick = { state = RideState.OFFLINE }) { Text("Ficar offline") }
                            }
                            RideState.OFFERED -> {
                                Button(onClick = { state = RideState.ACCEPTED }) { Text("Aceitar corrida") }
                                OutlinedButton(onClick = { state = RideState.ONLINE }) { Text("Recusar") }
                            }
                            RideState.ACCEPTED -> Button(onClick = { state = RideState.ARRIVED }) { Text("Cheguei ao embarque") }
                            RideState.ARRIVED -> Button(onClick = { state = RideState.IN_PROGRESS }) { Text("Iniciar viagem") }
                            RideState.IN_PROGRESS -> Button(onClick = { state = RideState.COMPLETED }) { Text("Finalizar viagem") }
                            RideState.COMPLETED -> Button(onClick = { state = RideState.ONLINE }) { Text("Próxima corrida") }
                        }
                    }
                }
            }
        }
    }
}
