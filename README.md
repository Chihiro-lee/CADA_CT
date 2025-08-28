# CADA_CT
### 
We highly recommend reading the scientific article before diving into this report!

Following, there is a list of instructions and broad guidelines on how to compile, run and test CADA_CT. Depending on the board used for this evaluation, on the programming environment and the tools used, the behaviour of this implementation might change. 

**Disclaimer**: *The following is a working proof of concept. There might be bugs and inconsistencies which were not addressed. Furthermore, the code might damage your MCU board, erasing its memory or degrading its hardware. Use it at your own risk, we do not assume any responsibility for the use of this code, or for the damage it can cause.*

## Folders Description
- `UpdateApplication/`: this folder contains all of the required files for compiling a single application for CADA_CT. Specifically, it should be populated with the source files of the application.
    - `Makefile`: makefile for compiling the application to be deployed. The result is a file `deployable.out` which is ready for deployment.
    - `src/`: this folder should contain all of the source files of the user application to be compiled (both '.c' and '.s' files). 
- `TCM/`: this folder contains the source code of CADA_CT TCM. Morevoer, it contains the source files of a user application (untrusted) that can be deployed alongside it without going over remote update.
    - `Makefile`: makefile for compiling both the untrusted application and the core of TCM. The result is the file `deployable.out` which is ready to be deployed on the MCU.
    - `app/`: folder containing all of the files required for the compilation of the untrusted application
        - `src/`: folder containing all of the source files, both '.c' and '.s' of the untrusted application
        - `Makefile.include`: makefile to be included, containing some directives for the compilation of the application by the main Makefile
    - `core/`: folder containing all of the files required for the CADA_CT compilation.
        - `src/`: folder containing all of the source files, both '.c' and '.s' of CADA_CT.
            - `core.c|.h`: file containing the source code for the main CADA_CT functions. It is usually used in Measurement stage.
            - `core_withoutMeasurement.c|.h`: version without Measurement.
            - `virt_fun.s`: assembly file containing the definitions of the various virtual functions. It is usually used in Measurement stage.
            - `virt_fun_withoutMeasurement.s`: version without Measurement.
            - `protected_isr.s`: assembly file containing the protected Interrupt Service Routines for the secure interrupt management.
            - `secureContextSwitch.c|.h`: source files for the secure context switch operations which allow the backup and restoration of the RAM, or any other hook operation during a safe context switch.
            - `RAhook.h`: header file needed by the application (needs to be included in the source files with the '#include' directive) in order to call API of CADA_CT and to setup for receiving challenges. This file get automatically copied to the `app/src/` directory of the application.
        - `ext_modules/`: folder containing the source files of the various extensions. These files are copied in the `core/src/` folder by the makefile if specified.
            - `secureUpdate.c|.h`: source file for the secure update over serial communication. It is usually used in Measurement stage.
            - `secureUpdate_withoutMeasurement.c|.h`: version without Measurement.
            - `secureSend.c|.h`: source files for the secure count sending over serial communication.
            - `XorCompute.c|.h`: source files for the Xor computation to collect control flow evidence.
            
        - `Makefile.include`: makefile to be included, containing some directives for the compilation of the TCM by the main Makefile
- `toolchain/`: folder containing all of the scripts required by the makefile and the deployment process
    - `linkerScript.ld`: modified linker scripts containing the directives for the linker when compiling ONLY the application. Used exclusively by the Makefile.
    - `linkerScriptWithCore.ld`: modified linker scripts containing the directives for the linker when compiling both the application and the TCM. Used exclusively by the Makefile.
    - `linkerScriptWithCore_withMeasurement.ld`: version without Measurement.
    - `loadProgram.py`: python script used to load the program onto the MCU via UART interface (serial port), in compliance with the CADA_CT secure update protocol.
    - `metadata.py`: python script in charge of adding the required metadata to the output file. Used exclusively by the Makefile.
    - `modifier.py`: python script in charge of replacing unsafe instructions. Used exclusively by the Makefile.
    - `postprocessor.py`: python script in charge of rejecting the application in case of unsafe instructions (compile-time). Used exclusively by Makefile.
    - `ReceiveData.py`: python script in charge of receiving the measurement result from Prv. 
    - `Send.py`: python script in charge of sending challenge from Vrf to Prv.
    - `database_verify.py`: python script to verify the measurement result. Checking whether the result from Prv are matching with the Vrf local database.
    - `gccLibraries/`: contains all of the statically linked libraries used by GCC and adapted to our toolchain (insertion of NOP slides and reserved registers). The `*.small` files inside refer to libraries using ret and call instead of reta and calla.
        - `libcrt.a`: statically linked library of gcc, compiled from the gcc source folder with the instrumented file `newlib/libgloss/msp430/crt0.S|crt_bss.S` which generates the compiled file `msp430-elf/large/full-memory-range/libgloss/msp430/libcrt.a`. The new file must be placed in `compilerGCCRoot/msp430-elf/lib/large/full-memory-range`. **crt0_movedata** and **crt0_init_bss** have been instrumented (adding the NOP slides). Others, such as call_main and call_exit are not but we should not need them.
        - `libgcc.a`: statically linked library compiled with a modified makefile (to prevent use of reserved registers '*-ffixed-r4 -ffixed-r5 -ffixed-r6*') `sourceGCC/gcc/libgcc/Makefile.in` yielding the file `build/gcc/msp430-elf/large/full-memory-range/libgcc/libgcc.a` to be placed in `compilerGCCRoot/lib/gcc/msp430-elf/9.2.0/large/full-memory-range`
        - `libnosys.a` and `libsim.a`: statically compiled files obtained from the modified makefile (to prevent use of reserved registers '*-ffixed-r4 -ffixed-r5 -ffixed-r6*') `sourceGCC/newlib/libgloss/msp430/Makefile.ini` yielding the files `build/gcc/msp430-elf/large/full-range-memory/libgloss/msp430/libnosys.a|libsim.a`. To be placed in `compiler//msp430-elf/lib/large/full-memory-range`
        - `libc.a`: statically linked library compiled with a modified makefiles (to prevent use of reserved registers '*-ffixed-r4 -ffixed-r5 -ffixed-r6*') `sourceGCC/newlib/newlib/libc/string/Makefile.in`,`sourceGCC/newlib/newlib/libc/string/Makefile.in`,`sourceGCC/newlib/newlib/libc/string/Makefile.in`  yielding the file `build/gcc/msp430-elf/large/full-memopry-range/newlib/libc.a`. 
        The new file must be placed in `compiler/msp430-elf/lib/large/full-memory-range`
    - `helperScripts/`: contains all of the scripts that are helpful in the creation of a proper application image
        - `auxGccPaser.py`: python script that parses a portion of mspdump code and performs the following operations:
            - Format the files to assembly standard.
            - Locates the relevant functions and labels, renaming them so that they can be compiled.
            - Replaces all of the jumps offsets, branches arguments and calla destinations with the correct label so that they can be relocated.
        - `getSizeData.py`: compiles every single test application and retrieves the size info of the various files.
        - `objToHex.py`: python script that parses an object file - created by the `metadata.py` script with the 'debugFiles' set to true - and outputs its content byte by byte so that it can be used in an `injectData.c` source file.
        - `runTimeEvaluation.c`: small C file containing the code used for the runTime evaluation. 
        - `powerConsumption/`: contains all of the scripts for getting the battery consumption with its graphs.
            - `Battery.java`: simulates the battery consumption at various execution rates.
            - `getConsumptions.sh`: script to get all of the power measures via the java script.
            - `getGraph.py`: script to generate graphs for the power measures obtained with the above script.
        - `remote_attestation/verifier/verifier.py`: python script acting simulating a verifier for the Remote Attestation. This script computes the HMAC of a block of data.     
    - `compiler/`: contains the various compilers used by CADA_CT, with some compilation libraries and some backups.
        - `include_gcc/`: contains some of the includes files required by the compiler and provided by TI.
        - `msp430-gcc-9.2.0.50_linux_instrumented/`: contains the instrumented GCC compiler used by CADA_CT.
        - `msp430-gcc-9.2.0.50_linux64_original/`: contains the origin GCC compiler used by CADA_CT.
        
- `App/`: folder containing all of the test applications used during the evaluation of the proposed CADA_CT implementation.
    - `ACFA_modified_app/`: instrumented and correctly working
    - `attack_app/`: instrumented and correctly working
    - `Bitcount/`: instrumented and correctly working
    - `CopyDMA/`: instrumented and correctly working. The Application copies the content of the flash into RAM with memcpy and with the DMA. In both cases, it checks whether the result is correct. The DMA triggers an interrupt when finished.
    - `DIALED_modified_app/`: instrumented and correctly working
    - `F5529-serial/`: instrumented and correctly working
    - `OAT_modified_app/`: instrumented and correctly working
    - `SerialMSP/`: instrumented and correctly working
    - `XorCypher/`: instrumented and correctly working
    - `Verify&Revive_modified/`: instrumented and correctly working
    - `TiBenchmark/`: folder containing all of the benchmark applications used by TI and during the evalution of the proposed CADA_CT implementation.
        - `matrixMultiplication/`: instrumented and correctly working.
        - `floatingPointMath/`: instrumented and correctly working.
        - `firFilter/`: instrumented and correctly working.
        - `8bitSwitchCase/`: instrumented and correctly working.
        - `16bitSwitchCase/`: instrumented and correctly working.
        - `8bitMath/`: instrumented and correctly working.
        - `16bitMath/`: instrumented and correctly working.
        - `32bitMath/`: instrumented and correctly working.
        - `8bit2dimMatrix/`: instrumented and correctly working.
        - `16bit2dimMatrix/`: instrumented and correctly working.
        - `DMA/`: instrumented and correctly working.
        


## Pre requisites
- **linux**: build-essential python3 pip3
- **pip3**: pyserial [matplotlib] [pandas]
- MSP430F5529 board with USB cable (we use a MSP-EXP430F5529LP)
- Code Composer Studio with msp430 libraries [official link](https://www.ti.com/tool/CCSTUDIO)
- (optional) MSP430 debugger (e.g. MSP430F5529Launchpad version) [board link](https://www.ti.com/tool/MSP-EXP430F5529LP)
- (optional) IAR workbench msp430 Kickstart edition [official link](https://www.iar.com/products/architectures/iar-embedded-workbench-for-msp430/#containerblock_3096)
- (optional) Java for the execution of powerConsumption measurement scripts.


## Loading CADA_CT TCM (with the default untrusted application)
In order to secure the microcontroller, the TCM (i.e. the root of trust for our architecture) needs to be loaded before any other program. The folder `TCM/` contains all of the required files for the compilation of CADA_CT TCM. Although it is possible to also load an untrusted application right away, to be loaded with the TCM, currently the toolchain does not fully support it. The first initialisation should be perfomed with the default application. 
The following steps must be performed:
- (optional) Copy all of the required untrusted application's source files inside the `TCM/app/src/` folder. The default application only calls the *receiveUpdate()* function from the RAhooks to initiate a secure update. If such function is not required, or the secureupdate module is not loaded, it should be changed. If no application is loaded, the default one will be. This will initiate a secure update and thus wait for any deployable on the UART communication.
- (optional) Modify the `TCM/Makefile` file to update the binaries paths. By default the toolchain will use the self-contained compiler in this repository.
- Generate the secure deployable image of the TCM using the `make` command from inside the `TCM/` folder. This will generate a `deployable.out` binary (if curious, you can check it with *readelf* to see how it is structured).
- Load the `TCM/deployable.out` image on the device, e.g. using Code Composer Studio 'load' function. If everything was loaded correctly, you should see the following:
    1. The red LED blinks 10 times
    2. The red LED turns on for verification (a few seconds)
    3. The green LED turns on --> ready for incoming updates
- You can also reset the board to start the verification from the beginning.
If you see any other combination of LED check section "LED Signals" for debugging.


## Measurement
In order to get Vrf local database, The following steps must be performed:
- Change the version of `virt_fun.s` to Mearsurement version. In `TCM/core` folder, modify the correct version of each module to be loaded into the TCM in `Makefile.include` file.
- Generate the secure deployable image of the TCM using the `make` command from inside the `TCM/` folder. This will generate a `deployable.out` binary.
- Under `toolchain/` path, execute the `python3 ReceiveData.py` command. This comman will open serial port and wait for coming data from Prv.
- Load the `TCM/deployable.out` image on the device, e.g. using Code Composer Studio 'load' function. 
- After receiving data from Prv, the file `data.txt` wili be created in `toolchain/` folder, this file contains the measurement result of Prv.

## Runtime evidence collection
In order to get Prv runtime evidence, The following steps must be performed:
- Change the version of `virt_fun.s` to runtime version. In `TCM/core` folder, modify the correct version of each module to be loaded into the TCM in `Makefile.include` file.
- Generate the secure deployable image of the TCM using the `make` command from inside the `TCM/` folder. This will generate a `deployable.out` binary.
- Under `toolchain/` path, execute the `python3 Send.py` command. This command will open serial port and call API for sending evidence we want to Vrf(The default content of file will send Xor Compute Result to Vrf). We can change the content of `Send.py` to send readValue.
- Under `toolchain/` path, execute the `python3 ReceiveData.py` command. This command will open serial port and wait for coming data from Prv.
- Load the `TCM/deployable.out` image on the device, e.g. using Code Composer Studio 'load' function. 
- After receiving data from Prv, the file `data.txt` wili be created in `toolchain/` folder, this file contains the runtime evidence of Prv.

## Verify
In order to Verify Prv runtime evidence, The following steps must be performed:
- Under `toolchain/` path, execute the `python3 database_verify.py` command. This command will ask for two files to get start to verify. If you have finished **Measurement** and **Runtime evidence collection**, please give two files you got to this script and wait for matching result.
- If Prv's measurement result is not matched with runtime evidence, this script will send command to serial port to make the MCU reset.

## Applications updates / Remote deployments
### Compiling the update/application 
In order to securely deploy an application via CADA_CT, a properly crafted update must be compiled. To automate this process, CADA_CT offers the folder `UpdateApplication/` which contains the Makefile that must be used. Precisely, the following steps are required to compile the untrusted update:
- Copy all of the source files of the application ('*.c' and '*.s') to the `UpdateApplication/src/` folder. If the folder does not exist it should be created. These are the files that will be compiled.
- Execute the `make` command. This will generate the first executable `deployable.out`. 
- Execute the `make libraries` command to generate some helper files for the instrumentation of the standard library code (check section "Library instrumentation" for more details).
- Execute the `make clean && make` command to generate the final executable `deployable.out` containing the instrumented code for both the application and the standard libraries used by it. NB: this executable is not an ELF file because it contains extra metadata added for CADA_CT. To check the original ELF file you can inspect `appWithoutMetadata.out`.
- Proceed with the deployment



### Deploying untrusted update
An application update can only be performed if the MCU is in the receiving update state (see Section **LED signals**). In order to enter this state, the running program must call the `callReceiveUpdate()` function from the `RAhook.h` header file (as is the case when loading the TCM with the default application). When the MCU is ready to receive the update execute the `/toolchain/loadProgram.py` python script, passing as arguments the final application binary (e.g. `deployable.out`) and the serial port name (e.g. `/dev/ttyACM1` on Linux or `COM4` on Windows). NB: The serial port might change across executions or systems, please check the serial ports available on your system (especially those that become available as soon as the MCU board is plugged through the USB port).

If the serial port is correct, the script will start uploading the various chunks of the application, waiting for some acknowledgments. As soon as the upload is finished, the script will output a *File sent* to the terminal and the TCM will begin its deployment operations.
As soon as the TCM receives the image it will verify it. If the image is verified with success and the binary does not contain unsafe code (as should be the case if properly compiled using CADA_CT toolchain), then it should be lunched by the TCM. Otherwise, the TCM will restart the update process and wait for another valid image. 


Be aware that the code in this repository is compatible with the MSP430 family of microcontroller. However, the code, along with some of the toolchain components, needs to be updated to work with anything different than an MSP430f5529 MCU.


## LED signals
The following table shows the current CADA_CT' usage of the various LEDs.

| Green LED | Red LED | Description |
| --------- | ------- | ----------- |
|   ON      | OFF     | The TCM is waiting for an income update or The TCM gets control from APIs     |    
|   ON      | ON      | *reserved*       |
|   OFF     | OFF     | Application started       |
|   OFF     | ON      | Verification of code in progress       |
|   OFF     | blink*10      | MCU has been reset, starting secure boot       |




# Technical details
## Memory Map
|Address|Name|Description|
|------|-----|-----------|
|0x000-fff|MMIO|Registers for pheripherals|
|0x1000-17ff|BSL| BSL |
|0x1800-19ff|Information Memory|Hardware info used for calibration of the board|
|0x1c00-2aff|TCM Ram|Ram used by CADA_CT Trusted Applications|
|0x2c00-43ff|App RAM|Ram used by the untrusted application |
|0x4400-c3ff|App Code|Where the untrusted yet verified code of the application resides|
|0xc400-f7ff|TCM code|Code of the TCM|
|0xf800-fbff|TCM Secure ISRs|Trampoline for App ISRs. Each entry will load the right App ISR pointer|
|0xfc00-ff7f|TCM virtual functions|Functions invoked by the untrusted app in replacement of the original unsafe instructions|
|0xff80-ffff|TCM ISRs trampoline|Trampoline for TCM ISRs. Interrupts will trigger a lookup of this table, which will lead to the TCM Secure ISRs entries.|
|0x10000-101ff| TCM backup data|Where the PC and status register are saved during interrupts |
|0x10200-103ff| TAs backup data|Where the CPU context (i.e. the registers) are saved during interrupts of TAs|
|0x10400-105ff| App ISRs | Where the app stores the pointers to the ISRs. Each entry stores the address of the APP ISR|
|0x10600-143ff|TCM code|Code of the TCM|
|0x14400-1c3ff|App RoData| Read Only data for the application|
|0x1c400-243ff|Reserved|Used for incoming data|


## Library instrumentation
Applications using common libc functions, such as *memset*, *memcpy* and similar, need a few extra steps in order to correctly work. Since our untrusted toolchain (i.e. the prepocessor and modifier scripts) only works with source files, it cannot be used to instrument the statically linked binaries. Such binary code derives from statically linked libraries, e.g. the libc library, for instance whenever functions such as *malloc* are required. The binary code is therefore appended to the rest of the instrumented application binary whenever compiling with the GCC linker. The instrumentation of the binary code is automatically performed by our toolchain (althogh it might not be optimal).

In order to fully optimise the library code used by an application, the following steps should be performed, some of which are manual.
First, our modified linker script assigns the explicit application binary code (i.e. only the binary code derived from the files in `UpdateApplication/src/`, without the libc libraries) to the **.appText** code section. Code sections allow the code to be organised in the binary, allowing the linker to place them in the different parts of the memory. Although our custom .appText section is placed alongside the rest of the application code, which by default would be assigned to the **.text** section, this separation allows us to easily spot the statically linked code. More precisely, while **.appText** will contain our source code, **.text** and **.lower.text** will only contain the code of the libraries. We can therefore fetch it by extracting only the **.text** and the **.lower.text** sections from the assembly dump of the binary file. These sections will indeed only contain the code not derived from our source files, i.e. the statically linked binary code. 

To facilitate this process, we propose an auxiliary script **auxGccParser** that extracts the library code from the deployable and performs some optimisations. This will create the new file `UpdateApplication/src/helper.s` containing the **uninstrumented** code. 

On top of creating a new assembly file, the **auxGccParser** script will output to console some possible optimisations, e.g. "Possible optimisation with calla r7 found". These are dynamic calls found in the binary code that could be replaced with some static calls, thus improving the performance of the code. With the current toolchain, such optimisations are mere suggestions that require manual verification and inspection. Beware that  some of them could not be valid! To figure out which are indeed valid and apply them, a manual inspection is required. Specifically, the following steps should/could be performed. Examining the newly created file `UpdateApplication/src/helper.s`, for each optimisation mentioned by the output of the above script, do the following:
- Find the dynamic call in question, e.g. `calla r7`, by searching the file.
- Look for the instruction that assign a value to the concerning register (e.g. `mova	#_sbrk_r,	r7`, which loads the address of `_sbrk_r` into `r7`). **NB:** this instruction must be looked for among the assembly instructions **preceding** the dynamic call.
- Replace the dynamic call (e.g. `calla r7`) with a call to the label used in the definition (e.g. `calla #_sbrk_r`).
- Remove the assignation (e.g. `mova	#_sbrk_r,	r7`) since no longer needed.

Note that it might not be trivial deciding whether the optimisation is valid or not: some might seem valid but might instead break the application. As a rule of thumb, the optimisation is valid as long as there is no other register assignation (e.g. for `r7`) between the dynamic call and the spotted assignation. This means that the call will indeed be only to that static address (e.g. `_sbrk_r`). 
**NB**: be aware of the jumps that might make the analysis of the code non-linear.
