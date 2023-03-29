Import-Module -Name Selenium 


#Definimos en variable de entorno la ruta dónde está descargado el ChromeDriver
$env:ChromeWebDriver = 'c:\ChromeDriver\'


$HtmlFilePath = "$PSScriptRoot\Home.html"


$Global:Driver = Start-SeChrome -StartURL ([system.uri](Get-Item $HtmlFilePath).FullName).AbsoluteUri 


$Campos = @{
    "importe"                = "70000"
    "tipoInteres"            = "1"
    "porcentajeRetencion"    = "20"
    "porcentajePenalizacion" = "1"
    "fechaInicio"            = "15/03/2023"
    "fechaVencimiento"       = "15/03/2024"
    "fechaReintegro"         = "15/09/2023"
}

foreach ($Campo in $Campos.GetEnumerator())
{

    $Global:Driver.FindElementById($Campo.Key).SendKeys($Campo.Value)

    Write-Host "$($Campo.Key) - $($Campo.Value)"
}


$Global:Driver.FindElementByXPath('//*[@id="calculadora"]/button').click()

$Resultados = @{
    "duracionMeses"            = "Duración (meses): 12.021"
    "diasTranscurridos"        = "Días transcurridos: 184"
    "interesesEuros"           = "Intereses (euros): 352.88"
    "interesesEurosReintegro"  = "Intereses (euros) Reintegro: 352.88"
    "interesesEurosDevengados" = "Intereses (euros) Devengados: 0.00"
    "retencionEuros"           = "Retención (euros): 70.58"
    "penalizacionEuros"        = "Penalización (euros): 349.04"
    "maximoInteresesBrutos"    = "Máximo intereses brutos: 352.88"
    "penalizacionAplicar"      = "Penalización a aplicar: 349.04"
    "capital"                  = "+Capital: 70000.00"
    "intereses"                = "+Intereses: 352.88"
    "retencion"                = "-Retención: -70.58"
    "penalizacion"             = "-Penalización: -349.04"
    "total"                    = "Total: 69933.26"

}

foreach ($Resultado in $Resultados.GetEnumerator())
{

    if ($Global:Driver.FindElementById($Resultado.Key).text -ne $($Resultado.Value))
    {
        Write-Warning "$($Global:Driver.FindElementById($Resultado.Key).text) error"
    }
    

    
}

