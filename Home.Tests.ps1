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
   
            Write-Host "$($Resultado.key) - $($Resultado.value)"
            $Global:Driver.FindElementById($Resultado.Key).text | Should -Be $Resultado.Value
    
        }
    }
    
}

Describe "Verificar Errores de entrada numericos" {


    BeforeEach {
        $CamposIniciales = @{

            "Importe"                = "15000"
            "FechaInicio"            = "05/07/2023"
            "PorcentajePenalizacion" = "3"
            "PorcentajeRetencion"    = "20"
    
            "TipoInteres1"           = "2"
            "TipoInteres2"           = "1,5"
            "TipoInteres3"           = "1"

            "ImporteReintegro1"      = "5000"
            "ImporteReintegro2"      = "5000"
            "ImporteReintegro3"      = "5000"
            "FechaReintegro1"        = "04/01/2024"
            "FechaReintegro2"        = "05/07/2024"
            "FechaReintegro3"        = "05/01/2025"

        }

        foreach ($CampoInicial in $CamposIniciales.GetEnumerator())
        {
            $Global:Driver.FindElementById($CampoInicial.Key).clear()
            $Global:Driver.FindElementById($CampoInicial.Key).SendKeys($CampoInicial.Value)
            
        }


    }

    It "Importe < 0" {

        $Campos = @{
            "Importe"                = "-1"
        
            "PorcentajePenalizacion" = "-1"
            "PorcentajeRetencion"    = "-20"

            "TipoInteres1"           = "-2"
            "TipoInteres2"           = "-1,5"
            "TipoInteres3"           = "-1"

            "ImporteReintegro1"      = "-5000"
            "ImporteReintegro2"      = "-5000"
            "ImporteReintegro3"      = "-5000"
        
        } 

        #    Set-Valores -Campos $Campos
        #   $Global:Driver.FindElementByXPath('//*[@id="calculadora"]/table/tbody/tr[27]/td/center/button').click()

        # Recorre los campos y verifica los mensajes de error
        foreach ($Campo in $Campos.GetEnumerator())
        {

            # Genera el identificador de la celda de error correspondiente
            $errorCellId = $Campo.Name + "Error"

            $Global:Driver.FindElementById($Campo.Name).clear()
            $Global:Driver.FindElementById($Campo.Name).SendKeys($Campo.Value)
            $Global:Driver.FindElementByXPath('//*[@id="calculadora"]/table/tbody/tr[27]/td/center/button').click()
            # Busca el elemento y verifica el mensaje de error
            $Global:Driver.FindElementById($errorCellId).text | Should -BeLike "* debe ser un valor numérico superior a 0."
            $Global:Driver.FindElementById($Campo.Name).clear()
            $Global:Driver.FindElementById($Campo.Name).SendKeys("1")
                
            
        }

    }

    It "Importe en blanco" {

        $Campos = @{
            "Importe"                = ""
        
            "PorcentajePenalizacion" = ""
            "PorcentajeRetencion"    = ""

            # "TipoInteres1"           = ""
            # "TipoInteres2"           = ""
            # "TipoInteres3"           = ""

            # "ImporteReintegro1"      = ""
            # "ImporteReintegro2"      = ""
            # "ImporteReintegro3"      = ""
        
        } 

        #    Set-Valores -Campos $Campos
        #   $Global:Driver.FindElementByXPath('//*[@id="calculadora"]/table/tbody/tr[27]/td/center/button').click()

        # Recorre los campos y verifica los mensajes de error
        foreach ($Campo in $Campos.GetEnumerator())
        {

            # Genera el identificador de la celda de error correspondiente
            $errorCellId = $Campo.Name + "Error"

            $Global:Driver.FindElementById($Campo.Name).clear()
            $Global:Driver.FindElementById($Campo.Name).SendKeys($Campo.Value)
            $Global:Driver.FindElementByXPath('//*[@id="calculadora"]/table/tbody/tr[27]/td/center/button').click()
            # Busca el elemento y verifica el mensaje de error
            $Global:Driver.FindElementById($errorCellId).text | Should -BeLike "* es obligatorio y debe ser un valor numérico superior a 0."
            $Global:Driver.FindElementById($Campo.Name).clear()
            $Global:Driver.FindElementById($Campo.Name).SendKeys("1")
                
            
        }

    }
} 

Describe "Verificar Errores de entrada de Fechas" {


    BeforeEach {

        $CamposIniciales = @{

            "Importe"                = "15000"
            "FechaInicio"            = "05/07/2023"
            "PorcentajePenalizacion" = "3"
            "PorcentajeRetencion"    = "20"
    
            "TipoInteres1"           = "2"
            "TipoInteres2"           = "1,5"
            "TipoInteres3"           = "1"

            "ImporteReintegro1"      = "5000"
            "ImporteReintegro2"      = "5000"
            "ImporteReintegro3"      = "5000"
            "FechaReintegro1"        = "04/01/2024"
            "FechaReintegro2"        = "05/07/2024"
            "FechaReintegro3"        = "05/01/2025"

        }

        foreach ($CampoInicial in $CamposIniciales.GetEnumerator())
        {
            $Global:Driver.FindElementById($CampoInicial.Key).clear()
            $Global:Driver.FindElementById($CampoInicial.Key).SendKeys($CampoInicial.Value)
            
        }

    }
   
} 
Describe "Verificar cálculos" {

    BeforeAll {
    }

    BeforeEach {
    }

    It "Importe 10.000€" {

        $Campos = @{
            "Importe"                = "10000"
            "FechaInicio"            = "05/06/2023"
            "PorcentajePenalizacion" = "2"
            "PorcentajeRetencion"    = "19"
            
            "TipoInteres1"           = "1"
            "TipoInteres2"           = "1"
            "TipoInteres3"           = "1"

            "ImporteReintegro1"      = "1"
            "ImporteReintegro2"      = "1"
            "ImporteReintegro3"      = "9998"
            "FechaReintegro1"        = "04/12/2023"
            "FechaReintegro2"        = "05/06/2024"
            "FechaReintegro3"        = "05/12/2024"
            
            
        }
        $Resultados = @{
            "DiasTranscurridosDesdeAnteriorLiquidacionR1" = "182"
            "DiasTranscurridosDesdeAnteriorLiquidacionR2" = "183"
            "DiasTranscurridosDesdeAnteriorLiquidacionR3" = "183"
            "DiasTranscurridosL1"                         = "183"
            "DiasTranscurridosL2"                         = "183"
            "DiasTranscurridosL3"                         = "183"
            "DiasTranscurridosR1"                         = "182"
            "DiasTranscurridosR2"                         = "366"
            "DiasTranscurridosR3"                         = "549"
            
            "FechaLiquidacionL1"                          = "5/12/2023"
            "FechaLiquidacionL2"                          = "5/6/2024"
            "FechaLiquidacionL3"                          = "5/12/2024"
            "FechaReintegroR1"                            = "4/12/2023"
            "FechaReintegroR2"                            = "5/6/2024"
            "FechaReintegroR3"                            = "5/12/2024"
            
            "ImporteReintegroR1"                          = "1,00 €"
            "ImporteReintegroR2"                          = "1,00 €"
            "ImporteReintegroR3"                          = "9.998,00 €"
            "ImporteVivoL1"                               = "9.999,00 €"
            "ImporteVivoL2"                               = "9.998,00 €"
            "ImporteVivoL3"                               = "0,00 €"
            "InteresesEurosL1"                            = "50,13 €"
            "InteresesEurosL2"                            = "50,13 €"
            "InteresesEurosL3"                            = "0,00 €"
            "InteresesReintegroR1"                        = "0,00 €"
            "InteresesReintegroR2"                        = "0,01 €"
            "InteresesReintegroR3"                        = "50,13 €"
            "MasCapitalR1"                                = "1,00 €"
            "MasCapitalR2"                                = "1,00 €"
            "MasCapitalR3"                                = "9.998,00 €"
            "MasInteresesL1"                              = "50,13 €"
            "MasInteresesL2"                              = "50,13 €"
            "MasInteresesL3"                              = "0,00 €"
            "MasInteresesR1"                              = "0,00 €"
            "MasInteresesR2"                              = "0,01 €"
            "MasInteresesR3"                              = "50,13 €"
            "MaximoInteresesBrutosR1"                     = "49,86 €"
            "MaximoInteresesBrutosR2"                     = "100,27 €"
            "MaximoInteresesBrutosR3"                     = "150,40 €"
            "MenosPenalizacionR1"                         = "-0,01 €"
            "MenosPenalizacionR2"                         = "-0,02 €"
            "MenosPenalizacionR3"                         = "-150,40 €"
            "MenosRetencionL1"                            = "-9,53 €"
            "MenosRetencionL2"                            = "-9,52 €"
            "MenosRetencionL3"                            = "-0,00 €"
            "MenosRetencionR1"                            = "-0,00 €"
            "MenosRetencionR2"                            = "-0,00 €"
            "MenosRetencionR3"                            = "-9,52 €"
            "PenalizacionAplicarR1"                       = "0,01 €"
            "PenalizacionAplicarR2"                       = "0,02 €"
            "PenalizacionAplicarR3"                       = "150,40 €"
            "PenalizacionEurosR1"                         = "0,01 €"
            "PenalizacionEurosR2"                         = "0,02 €"
            "PenalizacionEurosR3"                         = "300,76 €"
            "PorcentajePenalizacionR1"                    = "2,00 %"
            "PorcentajePenalizacionR2"                    = "2,00 %"
            "PorcentajePenalizacionR3"                    = "2,00 %"
            "PorcentajeRetencionL1"                       = "19,00 %"
            "PorcentajeRetencionL2"                       = "19,00 %"
            "PorcentajeRetencionL3"                       = "19,00 %"
            "PorcentajeRetencionR1"                       = "19,00 %"
            "PorcentajeRetencionR2"                       = "19,00 %"
            "PorcentajeRetencionR3"                       = "19,00 %"
            "PorcentajeTipoInteresL1"                     = "1,00 %"
            "PorcentajeTipoInteresL2"                     = "1,00 %"
            "PorcentajeTipoInteresL3"                     = "1,00 %"
            "ResultadoL1"                                 = "40,61 €"
            "ResultadoL2"                                 = "40,60 €"
            "ResultadoL3"                                 = "0,00 €"
            "ResultadoR1"                                 = "0,99 €"
            "ResultadoR2"                                 = "0,98 €"
            "ResultadoR3"                                 = "9.888,21 €"
            "RetencionEurosL1"                            = "9,53 €"
            "RetencionEurosL2"                            = "9,52 €"
            "RetencionEurosL3"                            = "0,00 €"
            "RetencionEurosR1"                            = "0,00 €"
            "RetencionEurosR2"                            = "0,00 €"
            "RetencionEurosR3"                            = "9,52 €"
        }

        Set-Valores -Campos $Campos
        $Global:Driver.FindElementByXPath('//*[@id="calculadora"]/table/tbody/tr[27]/td/center/button').click()
        
        Test-Resultados -Resultados $Resultados

    }


    It "Importe 15.000€" {

        $Campos = @{

            "Importe"                = "15000"
            "FechaInicio"            = "05/07/2023"
            "PorcentajePenalizacion" = "3"
            "PorcentajeRetencion"    = "20"
    
            "TipoInteres1"           = "2"
            "TipoInteres2"           = "1,5"
            "TipoInteres3"           = "1"

            "ImporteReintegro1"      = "5000"
            "ImporteReintegro2"      = "5000"
            "ImporteReintegro3"      = "5000"
            "FechaReintegro1"        = "04/01/2024"
            "FechaReintegro2"        = "05/07/2024"
            "FechaReintegro3"        = "05/01/2025"

        }

        $Resultados = @{

            "DiasTranscurridosDesdeAnteriorLiquidacionR1" = "183"
            "DiasTranscurridosDesdeAnteriorLiquidacionR2" = "182"
            "DiasTranscurridosDesdeAnteriorLiquidacionR3" = "184"
            "DiasTranscurridosL1"                         = "184"
            "DiasTranscurridosL2"                         = "182"
            "DiasTranscurridosL3"                         = "184"
            "DiasTranscurridosR1"                         = "183"
            "DiasTranscurridosR2"                         = "366"
            "DiasTranscurridosR3"                         = "550"

            "FechaLiquidacionL1"                          = "5/1/2024"
            "FechaLiquidacionL2"                          = "5/7/2024"
            "FechaLiquidacionL3"                          = "5/1/2025"
            "FechaReintegroR1"                            = "4/1/2024"
            "FechaReintegroR2"                            = "5/7/2024"
            "FechaReintegroR3"                            = "5/1/2025"

            "ImporteReintegroR1"                          = "5.000,00 €"
            "ImporteReintegroR2"                          = "5.000,00 €"
            "ImporteReintegroR3"                          = "5.000,00 €"
            "ImporteVivoL1"                               = "10.000,00 €"
            "ImporteVivoL2"                               = "5.000,00 €"
            "ImporteVivoL3"                               = "0,00 €"
            "InteresesEurosL1"                            = "100,82 €"
            "InteresesEurosL2"                            = "37,40 €"
            "InteresesEurosL3"                            = "0,00 €"
            "InteresesReintegroR1"                        = "50,14 €"
            "InteresesReintegroR2"                        = "37,40 €"
            "InteresesReintegroR3"                        = "25,21 €"
            "MasCapitalR1"                                = "5.000,00 €"
            "MasCapitalR2"                                = "5.000,00 €"
            "MasCapitalR3"                                = "5.000,00 €"
            "MasInteresesL1"                              = "100,82 €"
            "MasInteresesL2"                              = "37,40 €"
            "MasInteresesL3"                              = "0,00 €"
            "MasInteresesR1"                              = "50,14 €"
            "MasInteresesR2"                              = "37,40 €"
            "MasInteresesR3"                              = "25,21 €"
            "MaximoInteresesBrutosR1"                     = "150,41 €"
            "MaximoInteresesBrutosR2"                     = "225,75 €"
            "MaximoInteresesBrutosR3"                     = "250,96 €"
            "MenosPenalizacionR1"                         = "-75,21 €"
            "MenosPenalizacionR2"                         = "-150,41 €"
            "MenosPenalizacionR3"                         = "-226,03 €"
            "MenosRetencionL1"                            = "-20,16 €"
            "MenosRetencionL2"                            = "-7,48 €"
            "MenosRetencionL3"                            = "-0,00 €"
            "MenosRetencionR1"                            = "-10,03 €"
            "MenosRetencionR2"                            = "-7,48 €"
            "MenosRetencionR3"                            = "-5,04 €"
            "PenalizacionAplicarR1"                       = "75,21 €"
            "PenalizacionAplicarR2"                       = "150,41 €"
            "PenalizacionAplicarR3"                       = "226,03 €"
            "PenalizacionEurosR1"                         = "75,21 €"
            "PenalizacionEurosR2"                         = "150,41 €"
            "PenalizacionEurosR3"                         = "226,03 €"
            "PorcentajePenalizacionR1"                    = "3,00 %"
            "PorcentajePenalizacionR2"                    = "3,00 %"
            "PorcentajePenalizacionR3"                    = "3,00 %"
            "PorcentajeRetencionL1"                       = "20,00 %"
            "PorcentajeRetencionL2"                       = "20,00 %"
            "PorcentajeRetencionL3"                       = "20,00 %"
            "PorcentajeRetencionR1"                       = "20,00 %"
            "PorcentajeRetencionR2"                       = "20,00 %"
            "PorcentajeRetencionR3"                       = "20,00 %"
            "PorcentajeTipoInteresL1"                     = "2,00 %"
            "PorcentajeTipoInteresL2"                     = "1,50 %"
            "PorcentajeTipoInteresL3"                     = "1,00 %"
            "ResultadoL1"                                 = "80,66 €"
            "ResultadoL2"                                 = "29,92 €"
            "ResultadoL3"                                 = "0,00 €"
            "ResultadoR1"                                 = "4.964,90 €"
            "ResultadoR2"                                 = "4.879,51 €"
            "ResultadoR3"                                 = "4.794,14 €"
            "RetencionEurosL1"                            = "20,16 €"
            "RetencionEurosL2"                            = "7,48 €"
            "RetencionEurosL3"                            = "0,00 €"
            "RetencionEurosR1"                            = "10,03 €"
            "RetencionEurosR2"                            = "7,48 €"
            "RetencionEurosR3"                            = "5,04 €"
        }

        Set-Valores -Campos $Campos
        $Global:Driver.FindElementByXPath('//*[@id="calculadora"]/table/tbody/tr[27]/td/center/button').click()
        
        Test-Resultados -Resultados $Resultados
    }
} 

AfterAll {
    #$Global:Driver.Close()
}