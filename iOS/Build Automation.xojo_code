#tag BuildAutomation
			Begin BuildStepList Linux
				Begin BuildProjectStep Build
				End
			End
			Begin BuildStepList Mac OS X
				Begin BuildProjectStep Build
				End
				Begin SignProjectStep Sign
				End
			End
			Begin BuildStepList Windows
				Begin BuildProjectStep Build
				End
			End
			Begin BuildStepList iOS
				Begin IDEScriptBuildStep Script1 , AppliesTo = 0, Architecture = 0, Target = 0
					PropertyValue("App.NonReleaseVersion") = str(val(PropertyValue("App.NonReleaseVersion")) + 1)
				End
				Begin BuildProjectStep Build
				End
				Begin SignProjectStep Sign
				End
			End
#tag EndBuildAutomation
