
function(CreateInstallTarget TargetName InstallDestination)
	install(TARGETS TargetName DESTINATION InstallDestination)
endfunction(CreateInstallTarget)
