BeforeAll { 
    Import-Module -Name Selenium 

    #Definimos en variable de entorno la ruta dónde está descargado el ChromeDriver
    $env:ChromeWebDriver = 'c:\ChromeDriver\'


    $HtmlFilePath = "$PSScriptRoot\Home.html"


    $Global:Driver = Start-SeChrome -StartURL ([system.uri](Get-Item $HtmlFilePath).FullName).AbsoluteUri 
   
    function Set-Valores
    {
        [CmdletBinding()]
        param (
                               
            $Campos
        )

        foreach ($Campo in $Campos.GetEnumerator())
        {
            Write-Host "$($Campo.Key) - $($Campo.Value)"

            if ($Global:Driver.FindElementById($Campo.Key).TagName -eq "select")
            {
                $CampoHtml = $Global:Driver.FindElementById($Campo.Key)
                $CampoHtmlSelect = [OpenQA.Selenium.Support.UI.SelectElement]$CampoHtml
                $CampoHtmlSelect.SelectByText($Campo.Value)
                    
            }
            else
            {
                $Global:Driver.FindElementById($Campo.Key).clear()
                $Global:Driver.FindElementById($Campo.Key).SendKeys($Campo.Value)
            }

                
        }

    }


    function Test-Resultados
    {

        [CmdletBinding()]
        param (
                               
            $Resultados

        )

           

            

        foreach ($Resultado in $Resultados.GetEnumerator())
        {
   
            $Global:Driver.FindElementById($Resultado.Key).text | Should -Be $Resultado.Value
    
        }
    }
    
}

Describe "Verificar Errores de entrada" {
    It "Importe < 0" {

        $Campos = @{
            "importe" = "-1"
            
        } 

        Set-Valores -Campos $Campos
        $Global:Driver.FindElementByXPath('//*[@id="calculadora"]/button').click() 
        $Global:Driver.SwitchTo().alert().text | Should -Be "'El importe' es obligatorio y debe ser un valor numérico superior a 0."
        $Global:Driver.SwitchTo().alert().accept()
    
    } 

    It "Valores negativos" {

        $Campos = [ordered]@{
            "importe"                = "-1"
            "tipoInteres"            = "-1"
            "porcentajeRetencion"    = "-1"
            "porcentajePenalizacion" = "-1"  
        }

       

        foreach ($Campo in $Campos.GetEnumerator())
        {
   
            $Global:Driver.FindElementById($Campo.Key).clear()
            $Global:Driver.FindElementById($Campo.Key).SendKeys($Campo.Value)

            $Global:Driver.FindElementByXPath('//*[@id="calculadora"]/button').click() 
            $Global:Driver.SwitchTo().alert().text | Should -BeLike "* es obligatorio y debe ser un valor numérico superior a 0."
            $Global:Driver.SwitchTo().alert().accept()
            $Global:Driver.FindElementById($Campo.Key).clear()
            $Global:Driver.FindElementById($Campo.Key).SendKeys("1")
    
        }


        
       
    
    } 

    It "Campos en blanco" {

        $Campos = [ordered]@{
            "importe"                = ""
            "tipoInteres"            = ""
            "porcentajeRetencion"    = ""
            "porcentajePenalizacion" = ""  
        }

       

        foreach ($Campo in $Campos.GetEnumerator())
        {
   
            $Global:Driver.FindElementById($Campo.Key).clear()
            
            $Global:Driver.FindElementByXPath('//*[@id="calculadora"]/button').click() 
            $Global:Driver.SwitchTo().alert().text | Should -BeLike "* es obligatorio y debe ser un valor numérico superior a 0."
            $Global:Driver.SwitchTo().alert().accept()
            $Global:Driver.FindElementById($Campo.Key).clear()
            $Global:Driver.FindElementById($Campo.Key).SendKeys("1")
    
        }


        
       
    
    } 

    It "Fechas independientes" {

        $CamposIniciales = [ordered]@{
            "tipoTarifa"             = "Ordinaria"
            "reintegro"              = "Total"
            "importe"                = "70000"
            "tipoInteres"            = "1"
            "porcentajeRetencion"    = "20"
            "porcentajePenalizacion" = "1"
            "fechaInicio"            = "15/03/2023"
            "fechaVencimiento"       = "15/03/2024"
            "fechaReintegro"         = "15/09/2023" 
        }

       
        Set-Valores -Campos $CamposIniciales


        $CamposVerificar = [ordered]@{
            "fechaInicio"      = "15/03/2023"
            "fechaVencimiento" = "15/03/2024"
            "fechaReintegro"   = "15/09/2023" 
        }

        foreach ($CampoVerificar in $CamposVerificar.GetEnumerator())
        {
            Set-Valores -Campos $CamposIniciales
            $Global:Driver.FindElementById($CampoVerificar.Key).clear()
            
            $Global:Driver.FindElementByXPath('//*[@id="calculadora"]/button').click() 
            $Global:Driver.SwitchTo().alert().text | Should -BeLike "* no es una fecha válida."
            $Global:Driver.SwitchTo().alert().accept()
            
        }


        
       
    
    } 

    It "Error: La 'fecha de vencimiento' debe ser posterior a la 'fecha de inicio'." {

        $CamposIniciales = [ordered]@{
            "tipoTarifa"             = "Ordinaria"
            "reintegro"              = "Total"
            "importe"                = "70000"
            "tipoInteres"            = "1"
            "porcentajeRetencion"    = "20"
            "porcentajePenalizacion" = "1"
            "fechaInicio"            = "15/03/2023"
            "fechaVencimiento"       = "1/03/2023"
            "fechaReintegro"         = "15/09/2023" 

        }

       
        Set-Valores -Campos $CamposIniciales


            
        $Global:Driver.FindElementByXPath('//*[@id="calculadora"]/button').click() 
        $Global:Driver.SwitchTo().alert().text | Should -Be "Error: La 'fecha de vencimiento' debe ser posterior a la 'fecha de inicio'."
        $Global:Driver.SwitchTo().alert().accept()
            
    } 

    It "Error: La 'fecha de reintegro' debe ser posterior a la 'fecha de inicio'." {

        $CamposIniciales = [ordered]@{
            "tipoTarifa"             = "Ordinaria"
            "reintegro"              = "Total"
            "importe"                = "70000"
            "tipoInteres"            = "1"
            "porcentajeRetencion"    = "20"
            "porcentajePenalizacion" = "1"
            "fechaInicio"            = "15/03/2023"
            "fechaVencimiento"       = "15/03/2024"
            "fechaReintegro"         = "1/03/2023" 

        }

       
        Set-Valores -Campos $CamposIniciales


            
        $Global:Driver.FindElementByXPath('//*[@id="calculadora"]/button').click() 
        $Global:Driver.SwitchTo().alert().text | Should -Be "Error: La 'fecha de reintegro' debe ser posterior a la 'fecha de inicio'."
        $Global:Driver.SwitchTo().alert().accept()
            
    } 

    It "Error: La 'fecha de reintegro' no es válida. Debe ser mayor a la 'fecha de inicio' y menor a la 'fecha de vencimiento'." {

        $CamposIniciales = [ordered]@{
            "tipoTarifa"             = "Ordinaria"
            "reintegro"              = "Total"
            "importe"                = "70000"
            "tipoInteres"            = "1"
            "porcentajeRetencion"    = "20"
            "porcentajePenalizacion" = "1"
            "fechaInicio"            = "15/03/2023"
            "fechaVencimiento"       = "15/03/2024"
            "fechaReintegro"         = "15/02/2023" 

        }

       
        Set-Valores -Campos $CamposIniciales


            
        $Global:Driver.FindElementByXPath('//*[@id="calculadora"]/button').click() 
        $Global:Driver.SwitchTo().alert().text | Should -Be "Error: La 'fecha de reintegro' debe ser posterior a la 'fecha de inicio'."
        $Global:Driver.SwitchTo().alert().accept()
            
    }

}
 
Describe "Verificar cálculos" {

    BeforeAll {
    }

    BeforeEach {
    }

    It "Ordinaria-Total: REINTEGRO TOTAL - Penalización por días remanentes (Tarifas ordinarias):" {

        $Campos = @{
            "tipoTarifa"             = "Ordinaria"
            "reintegro"              = "Total"
            "importe"                = "70000"
            "tipoInteres"            = "1"
            "porcentajeRetencion"    = "20"
            "porcentajePenalizacion" = "1"
            "fechaInicio"            = "15/03/2023"
            "fechaVencimiento"       = "15/03/2024"
            "fechaReintegro"         = "14/08/2023"
        }
        $Resultados = @{
            "duracionMeses"            = "Duración (meses): 12,02"
            "diasTranscurridos"        = "Días transcurridos: 152"
            "diasRemanentes"           = "Días remanentes: 214"
            "interesesEuros"           = "Intereses: 291,51 euros"
            "interesesEurosReintegro"  = "Intereses Reintegro: 291,51 euros"
            "interesesEurosDevengados" = "Intereses Devengados: 291,51 euros"
            "retencionEuros"           = "Retención: 58,30 euros"
            "penalizacionEuros"        = "Penalización: 410,41 euros"
            "maximoInteresesBrutos"    = "Máximo intereses brutos: 291,51 euros"
            "penalizacionAplicar"      = "Penalización a aplicar: 291,51 euros"
            "capital"                  = "+Capital: 70.000,00 euros"
            "intereses"                = "+Intereses: 291,51 euros"
            "retencion"                = "-Retención: -58,30 euros"
            "penalizacion"             = "-Penalización: -291,51 euros"
            "total"                    = "Total: 69.941,70 euros"
        }

        Set-Valores -Campos $Campos
        $Global:Driver.FindElementByXPath('//*[@id="calculadora"]/button').click()
        Test-Resultados -Resultados $Resultados

    }

    It "Ordinaria-Parcial: REINTEGRO PARCIAL - Penalización por días remanentes (Tarifas ordinarias):" {

        $Campos = [ordered]@{
            "tipoTarifa"             = "Ordinaria"
            "reintegro"              = "Parcial"
            "importe"                = "70000"
            "fechaInicio"            = "15/03/2023"
            "fechaVencimiento"       = "15/03/2024"
            "fechaReintegro"         = "15/04/2023"
            "importeReintegro"       = "50000"
            "tipoInteres"            = "1"
            "porcentajeRetencion"    = "20"
            "porcentajePenalizacion" = "1"
        }

        $Resultados = @{
            "duracionMeses"            = "Duración (meses): 12,02"
            "diasTranscurridos"        = "Días transcurridos: 31"
            "diasRemanentes"           = "Días remanentes: 335"
            "interesesEuros"           = "Intereses: 42,47 euros"
            "interesesEurosReintegro"  = "Intereses Reintegro: 42,47 euros"
            "interesesEurosDevengados" = "Intereses Devengados: 59,45 euros"
            "retencionEuros"           = "Retención: 8,49 euros"
            "penalizacionEuros"        = "Penalización: 458,90 euros"
            "maximoInteresesBrutos"    = "Máximo intereses brutos: 59,45 euros"
            "penalizacionAplicar"      = "Penalización a aplicar: 59,45 euros"
            "capital"                  = "+Capital: 50.000,00 euros"
            "intereses"                = "+Intereses: 42,47 euros"
            "retencion"                = "-Retención: -8,49 euros"
            "penalizacion"             = "-Penalización: -59,45 euros"
            "total"                    = "Total: 49.974,52 euros"
        }

        Set-Valores -Campos $Campos

        $Global:Driver.FindElementByXPath('//*[@id="calculadora"]/button').click()

        Test-Resultados -Resultados $Resultados



    } 
    
    It "Coyuntural-Total: REINTEGRO TOTAL - Penalización por días transcurridos (Tarifas coyunturales):" {

        $Campos = [ordered]@{
            "tipoTarifa"             = "Coyuntural"
            "reintegro"              = "Total"
            "importe"                = "70000"
            "fechaInicio"            = "15/03/2023"
            "fechaVencimiento"       = "15/03/2024"
            "fechaReintegro"         = "15/09/2023"
            "tipoInteres"            = "1"
            "porcentajeRetencion"    = "20"
            "porcentajePenalizacion" = "1"
        }

        $Resultados = @{
            "duracionMeses"            = "Duración (meses): 12,02"
            "diasTranscurridos"        = "Días transcurridos: 184"
            "interesesEuros"           = "Intereses: 352,88 euros"
            "interesesEurosReintegro"  = "Intereses Reintegro: 352,88 euros"
            "interesesEurosDevengados" = "Intereses Devengados: 352,88 euros"
            "retencionEuros"           = "Retención: 70,58 euros"
            "penalizacionEuros"        = "Penalización: 352,88 euros"
            "maximoInteresesBrutos"    = "Máximo intereses brutos: 352,88 euros"
            "penalizacionAplicar"      = "Penalización a aplicar: 352,88 euros"
            "capital"                  = "+Capital: 70.000,00 euros"
            "intereses"                = "+Intereses: 352,88 euros"
            "retencion"                = "-Retención: -70,58 euros"
            "penalizacion"             = "-Penalización: -352,88 euros"
            "total"                    = "Total: 69.929,42 euros"
        }

        Set-Valores -Campos $Campos

        $Global:Driver.FindElementByXPath('//*[@id="calculadora"]/button').click()

        Test-Resultados -Resultados $Resultados
    }
    
    It "Coyuntural-Parcial: REINTEGRO PARCIAL - Penalización por días transcurridos (Tarifas coyunturales)" {

        $Campos = [ordered]@{
            "tipoTarifa"             = "Coyuntural"
            "reintegro"              = "Parcial"
            "importe"                = "70000"
            "fechaInicio"            = "15/03/2023"
            "fechaVencimiento"       = "15/03/2024"
            "fechaReintegro"         = "15/09/2023"
            "importeReintegro"       = "35000"
            "tipoInteres"            = "1"
            "porcentajeRetencion"    = "20"
            "porcentajePenalizacion" = "1"
        }

        $Resultados = @{
            "duracionMeses"            = "Duración (meses): 12,02"
            "diasTranscurridos"        = "Días transcurridos: 184"
            "interesesEuros"           = "Intereses: 176,44 euros"
            "interesesEurosDevengados" = "Intereses Devengados: 352,88 euros"
            "interesesEurosReintegro"  = "Intereses Reintegro: 176,44 euros"
            "retencionEuros"           = "Retención: 35,29 euros"
            "penalizacionEuros"        = "Penalización: 176,44 euros"
            "maximoInteresesBrutos"    = "Máximo intereses brutos: 352,88 euros"
            "penalizacionAplicar"      = "Penalización a aplicar: 176,44 euros"
            "capital"                  = "+Capital: 35.000,00 euros"
            "intereses"                = "+Intereses: 176,44 euros"
            "retencion"                = "-Retención: -35,29 euros"
            "penalizacion"             = "-Penalización: -176,44 euros"
            "total"                    = "Total: 34.964,71 euros"
        }

        Set-Valores -Campos $Campos

        $Global:Driver.FindElementByXPath('//*[@id="calculadora"]/button').click()

        Test-Resultados -Resultados $Resultados

    } 
}

AfterAll {
    $Global:Driver.Close()
}