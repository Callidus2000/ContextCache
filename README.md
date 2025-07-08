<!--
*** Thanks for checking out the Best-README-Template. If you have a suggestion
*** that would make this better, please fork the repo and create a pull request
*** or simply open an issue with the tag "enhancement".
*** Thanks again! Now go create something AMAZING! :D
***
-->

<!-- PROJECT SHIELDS -->
<!--
*** I'm using markdown "reference style" links for readability.
*** Reference links are enclosed in brackets [ ] instead of parentheses ( ).
*** See the bottom of this document for the declaration of the reference variables
*** for contributors-url, forks-url, etc. This is an optional, concise syntax you may use.
*** https://www.markdownguide.org/basic-syntax/#reference-style-links
-->
[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![GPLv3 License][license-shield]][license-url]


<br />
<p align="center">
<!-- PROJECT LOGO
  <a href="https://github.com/Callidus2000/ContextCache">
    <img src="images/logo.png" alt="Logo" width="80" height="80">
  </a>
-->

  <h3 align="center">Powershell Context Cache Module</h3>

  <p align="center">
    This Powershell Module is a helper module for debugging your Code.
    <br />
    <a href="https://github.com/Callidus2000/ContextCache"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://github.com/Callidus2000/ContextCache/issues">Report Bug</a>
    ·
    <a href="https://github.com/Callidus2000/ContextCache/issues">Request Feature</a>
  </p>
</p>



<!-- TABLE OF CONTENTS -->
<details open="open">
  <summary><h2 style="display: inline-block">Table of Contents</h2></summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#use-cases-or-why-was-the-module-developed">Use-Cases - Why was this module created?</a></li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgements">Acknowledgements</a></li>
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
## About The Project

## PowerShell Module for Context Cache

This PowerShell module is designed to save current variables into the Cache of PSFramework. My normal workflow for debugging code is to code in VSC and to test in a seperate PWSH terminal. Sometimes I'd like to get the internal/local variable state to perform adhoc tests with this data. This module helps to get the state of the local variable scope, either by restoring it into a hashtable or to directly initialize the variables in the current (local) scope.

<!-- USAGE EXAMPLES -->
## Usage Examples

Here is an example of how to use the module and the resulting output:

### Example Code

```powershell
# Import the module and define a demo function
Import-Module ContextCache
function foo {
    param (
        [Parameter(Mandatory, Position=0)]
        $A,
        [Parameter(Mandatory, Position=1)]
        $B
    )
    Save-ContextCache -Name "JustTheParams" -CurrentVariables (Get-Variable -Scope Local) -FunctionName "foo"
    $C = $A + $B
    Save-ContextCache -Name "AllLocalVariables" -CurrentVariables (Get-Variable -Scope Local)
    Save-ContextCache -Name "JustTheResult" -CurrentVariables (Get-Variable -Scope Local) -Include "C"
    Save-ContextCache -Name "EveryThingButB" -CurrentVariables (Get-Variable -Scope Local) -Exclude "B"
    # No return value
}

# Call the function
foo 1 2

#Retrieve the different caches and store it for demo purposes
$cacheContent=@{}
"AllLocalVariables","JustTheParams", "JustTheResult", "EveryThingButB" | ForEach-Object {
    $cacheContent.$_ = Get-ContextCache -Name $_
}
$cacheContent | ConvertTo-Json -depth 1
```

This is the content of $cacheContent (limited to the first level):

```json
{
  "EveryThingButB": {
    "PSBoundParameters": "System.Management.Automation.PSBoundParametersDictionary",
    "PSCmdlet": "System.Management.Automation.PSScriptCmdlet",
    "PSCommandPath": "",
    "null": null,
    "C": 3,
    "PSScriptRoot": "",
    "A": 1,
    "input": "",
    "MyInvocation": "System.Management.Automation.InvocationInfo"
  },
  "JustTheResult": {
    "C": 3
  },
  "JustTheParams": {
    "A": 1,
    "B": 2
  },
  "AllLocalVariables": {
    "PSBoundParameters": "System.Management.Automation.PSBoundParametersDictionary",
    "A": 1,
    "PSCommandPath": "",
    "C": 3,
    "null": null,
    "PSCmdlet": "System.Management.Automation.PSScriptCmdlet",
    "PSScriptRoot": "",
    "B": 2,
    "input": "",
    "MyInvocation": "System.Management.Automation.InvocationInfo"
  }
}
```

Another usage would be 

```powershell
Restore-ContextCache -Name JustTheParams
Write-Host $B
```

which initializes the variables $A and $B in the current context. From there on you can manually steptrace through your functions code.

---



### Built With

* [psframework](https://github.com/PowershellFrameworkCollective/psframework)


<!-- ROADMAP -->
## Roadmap
New features will be added if any of my scripts need it ;-)

I cannot guarantee that no breaking change will occur as the development follows my internal DevOps need completely. 
This should not be a problem as the module is designed for adhoc debugging needs and not for permanent use in code.
See [Changelog](SMAX\changelog.md) for information regarding breaking changes.

See the [open issues](https://github.com/Callidus2000/ContextCache/issues) for a list of proposed features (and known issues).

If you need a special function feel free to contribute to the project.

<!-- CONTRIBUTING -->
## Contributing

Contributions are what make the open source community such an amazing place to be learn, inspire, and create. Any contributions you make are **greatly appreciated**. For more details please take a look at the [CONTRIBUTE](docs/CONTRIBUTING.md#Contributing-to-this-repository) document

Short stop:

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request


## Limitations
* The module works on the tenant level as this is the only permission set I've been granted
* Maybe there are some inconsistencies in the docs, which may result in a mere copy/paste marathon from my other projects

<!-- LICENSE -->
## License

Distributed under the GNU GENERAL PUBLIC LICENSE version 3. See `LICENSE.md` for more information.



<!-- CONTACT -->
## Contact


Project Link: [https://github.com/Callidus2000/ContextCache](https://github.com/Callidus2000/ContextCache)



<!-- ACKNOWLEDGEMENTS -->
## Acknowledgements

* [Friedrich Weinmann](https://github.com/FriedrichWeinmann) for his marvelous [PSModuleDevelopment](https://github.com/PowershellFrameworkCollective/PSModuleDevelopment) and [psframework](https://github.com/PowershellFrameworkCollective/psframework)





<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/Callidus2000/ContextCache.svg?style=for-the-badge
[contributors-url]: https://github.com/Callidus2000/ContextCache/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/Callidus2000/ContextCache.svg?style=for-the-badge
[forks-url]: https://github.com/Callidus2000/ContextCache/network/members
[stars-shield]: https://img.shields.io/github/stars/Callidus2000/ContextCache.svg?style=for-the-badge
[stars-url]: https://github.com/Callidus2000/ContextCache/stargazers
[issues-shield]: https://img.shields.io/github/issues/Callidus2000/ContextCache.svg?style=for-the-badge
[issues-url]: https://github.com/Callidus2000/ContextCache/issues
[license-shield]: https://img.shields.io/github/license/Callidus2000/ContextCache.svg?style=for-the-badge
[license-url]: https://github.com/Callidus2000/ContextCache/blob/master/LICENSE

