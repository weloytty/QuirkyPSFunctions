Import-Module Quirky -Force


Describe "Unit Testing Quirky MSMQ:" {
    InModuleScope Quirky {
        Context "Get-QueueDepthExists" {
            $returnValue = (Get-Command Get-QueueDepth).Source
            It "Should know about Get-QueueDepth" {
                $returnValue | Should Be "Quirky.MSMQ"
            }
        }
        Context "Clear-QueueExists" {
            $returnValue = (Get-Command Clear-RemoteQueue).Source
            It "Should know about Clear-Queue" {
                $returnValue | Should Be "Quirky.MSMQ"
            }
        }

        
    } #InModuleScope Quirky{
} #Describe "Unit Testing Quirky MSMQ:" {