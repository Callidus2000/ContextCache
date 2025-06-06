@{
	# Script module or binary module file associated with this manifest
	RootModule = 'ContextCache.psm1'

	# Version number of this module.
	ModuleVersion = '1.1.1'

	# ID used to uniquely identify this module
	GUID = '2b9a57ec-4add-4477-8c28-64bb1c96b8ca'

	# Author of this module
	Author = 'Sascha Spiekermann'

	# Company or vendor of this module
	CompanyName = 'MyCompany'

	# Copyright statement for this module
	Copyright = 'Copyright (c) 2025 Sascha Spiekermann'

	# Description of the functionality provided by this module
	Description = 'Module for saving Context within the PSFramework Cache'

	# Minimum version of the Windows PowerShell engine required by this module
	PowerShellVersion = '5.0'

	# Modules that must be imported into the global environment prior to importing
	# this module
	RequiredModules = @(
		@{ ModuleName='PSFramework'; ModuleVersion='1.12.346' }
	)

	# Assemblies that must be loaded prior to importing this module
	# RequiredAssemblies = @('bin\ContextCache.dll')

	# Type files (.ps1xml) to be loaded when importing this module
	# TypesToProcess = @('xml\ContextCache.Types.ps1xml')

	# Format files (.ps1xml) to be loaded when importing this module
	# FormatsToProcess = @('xml\ContextCache.Format.ps1xml')

	# Functions to export from this module
	FunctionsToExport = @(
		'Get-ContextCache'
		'Restore-ContextCache'
		'Save-ContextCache'
	)

	# Cmdlets to export from this module
	CmdletsToExport = ''

	# Variables to export from this module
	VariablesToExport = ''

	# Aliases to export from this module
	AliasesToExport = ''

	# List of all modules packaged with this module
	ModuleList = @()

	# List of all files packaged with this module
	FileList = @()

	# Private data to pass to the module specified in ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
	PrivateData = @{

		#Support for PowerShellGet galleries.
		PSData = @{

			# Tags applied to this module. These help with module discovery in online galleries.
			# Tags = @()

			# A URL to the license for this module.
			LicenseUri = 'https://raw.githubusercontent.com/Callidus2000/ContextCache/refs/heads/master/LICENSE'

			# A URL to the main website for this project.
			ProjectUri = 'https://github.com/Callidus2000/ContextCache'

			# A URL to an icon representing this module.
			# IconUri = ''

			# ReleaseNotes of this module
			# ReleaseNotes = ''

		} # End of PSData hashtable

	} # End of PrivateData hashtable
}