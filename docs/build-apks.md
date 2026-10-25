# Como gerar os APKs

Abra **Actions → Android clients CI → Run workflow → main → Run workflow**.

O workflow executa duas tarefas independentes:
- `Passenger Flutter debug`: gera `passenger-debug-apk`
- `Driver Kotlin debug`: gera `driver-debug-apk`

Depois de uma execução bem-sucedida, abra o workflow run e baixe os arquivos na seção **Artifacts**. O arquivo de cada artefato é um ZIP contendo um APK debug.

Se o build falhar, abra o job com erro e consulte a primeira falha relevante do log. Não considerar APK gerado antes de verificar que o job concluiu com sucesso e publicou o artefato.

Esses APKs são protótipos com dados locais simulados, não aplicativos operacionais de transporte. A compilação do motorista usa Kotlin/Jetpack Compose, e a do passageiro usa Flutter.
