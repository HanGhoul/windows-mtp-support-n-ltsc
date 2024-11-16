## Instructions for adding MTP feature to Windows N versions

Install MTP feature without any of the other bloat from Microsoft's Media Feature Pack.

> **Note**: While this method works with the Windows version mentioned below, you'll download an older version of the Media Feature Pack (version 1903) because it is the last one available as a standalone download, not installed from the Microsoft Store.

Last tested on **Windows 10 Pro N 22H2** (Build: 19045.5131).

### 1. **Download the Media Feature Pack**  
   - **Version**: 1903 (May 2019)  
   - **File**: `Windows_MediaFeaturePack_x64_1903_V1.msu`  
   - **Source**: [Microsoft's official website](https://www.microsoft.com/en-us/software-download/mediafeaturepack)  
   - **Alternative Check**:  
     - If downloading from another source, verify the file hash:  
       - **SHA256**: `65D76BB1BEDE083F017F3FDE9F225C42C0CF72BC79ADC804D210CDAF86BA6E93`

### 2. **Unpack the MSU File**  
   - Extract the contents of the `.msu` file.

### 3. **Locate and Unpack the CAB File**  
   - Find the file named `microsoft-windows-mediafeaturepack-oob-package~31bf3856ad364e35~amd64~~.cab` within the extracted contents.  
   - Extract the contents of the `.cab` file.
### 4. **Install files required for MTP**
```
cd "extracted cab folder path"
dism /online /add-package /packagepath:"Microsoft-Windows-Portable-Devices-multimedia-Package~31bf3856ad364e35~amd64~~10.0.18362.1.mum"
dism /online /add-package /packagepath:"Microsoft-Windows-Portable-Devices-multimedia-Package~31bf3856ad364e35~amd64~de-DE~10.0.18362.1.mum"
dism /online /add-package /packagepath:"Microsoft-Windows-Portable-Devices-Package~31bf3856ad364e35~amd64~~10.0.18362.1.mum"
```
### 5. **Reboot**

---

Or use the script and provide the -Patch parameter with the path to the MSU file:
```
.\Install-MTP.ps1 -Patch -MsuFile D:\Downloads\Windows_MediaFeaturePack_x64_1903_V1.msu
```

### Script output
```
MsuFile provided: "D:\Downloads\Windows_MediaFeaturePack_x64_1903_V1.msu"

Extracting MSU file "D:\Downloads\Windows_MediaFeaturePack_x64_1903_V1.msu"
  to "C:\Users\USER\AppData\Local\Temp\mtp-install"
Created directory: "C:\Users\USER\AppData\Local\Temp\mtp-install"
MSU extraction complete. Files are located at "C:\Users\USER\AppData\Local\Temp\mtp-install"

Extracting CAB file "C:\Users\USER\AppData\Local\Temp\mtp-install\microsoft-windows-mediafeaturepack-oob-package~31bf3856ad364e35~amd64~~.cab"
  to "C:\Users\USER\AppData\Local\Temp\mtp-install\cab-extracted"
Created directory: "C:\Users\USER\AppData\Local\Temp\mtp-install\cab-extracted"
CAB extraction complete. Files are located at "C:\Users\USER\AppData\Local\Temp\mtp-install\cab-extracted"

CabFolder provided: "C:\Users\USER\AppData\Local\Temp\mtp-install\cab-extracted"

Found required files, proceeding install:
- C:\Users\USER\AppData\Local\Temp\mtp-install\cab-extracted\Microsoft-Windows-Portable-Devices-multimedia-Package~31bf3856ad364e35~amd64~~10.0.18362.1.mum
- C:\Users\USER\AppData\Local\Temp\mtp-install\cab-extracted\Microsoft-Windows-Portable-Devices-multimedia-Package~31bf3856ad364e35~amd64~de-DE~10.0.18362.1.mum
- C:\Users\USER\AppData\Local\Temp\mtp-install\cab-extracted\Microsoft-Windows-Portable-Devices-Package~31bf3856ad364e35~amd64~~10.0.18362.1.mum

Running command: "dism /online /add-package /packagepath:"C:\Users\USER\AppData\Local\Temp\mtp-install\cab-extracted\Microsoft-Windows-Portable-Devices-multimedia-Package~31bf3856ad364e35~amd64~~10.0.18362.1.mum" /NoRestart"

Tool zur Imageverwaltung für die Bereitstellung
Version: 10.0.19041.3636

Abbildversion: 10.0.19045.5131

1 von 1 wird verarbeitet – Paket "Microsoft-Windows-Portable-Devices-multimedia-Package~31bf3856ad364e35~amd64~~10.0.18362.1" wird hinzugefügt
[==========================100.0%==========================]
Der Vorgang wurde erfolgreich beendet.

Running command: "dism /online /add-package /packagepath:"C:\Users\USER\AppData\Local\Temp\mtp-install\cab-extracted\Microsoft-Windows-Portable-Devices-multimedia-Package~31bf3856ad364e35~amd64~de-DE~10.0.18362.1.mum" /NoRestart"

Tool zur Imageverwaltung für die Bereitstellung
Version: 10.0.19041.3636

Abbildversion: 10.0.19045.5131

1 von 1 wird verarbeitet – Paket "Microsoft-Windows-Portable-Devices-multimedia-Package~31bf3856ad364e35~amd64~de-DE~10.0.18362.1" wird hinzugefügt
[==========================100.0%==========================]
Der Vorgang wurde erfolgreich beendet.

Running command: "dism /online /add-package /packagepath:"C:\Users\USER\AppData\Local\Temp\mtp-install\cab-extracted\Microsoft-Windows-Portable-Devices-Package~31bf3856ad364e35~amd64~~10.0.18362.1.mum" /NoRestart"

Tool zur Imageverwaltung für die Bereitstellung
Version: 10.0.19041.3636

Abbildversion: 10.0.19045.5131

1 von 1 wird verarbeitet – Paket "Microsoft-Windows-Portable-Devices-Package~31bf3856ad364e35~amd64~~10.0.18362.1" wird hinzugefügt
[==========================100.0%==========================]
Der Vorgang wurde erfolgreich beendet.

Patching completed.
Cleaning up extracted MSU & CAB folders: "C:\Users\USER\AppData\Local\Temp\mtp-install"
Do you want to reboot now? (y/n): n
Please reboot your system to apply the changes.
```
