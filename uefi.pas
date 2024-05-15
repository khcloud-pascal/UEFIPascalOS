unit uefi;

interface

{$POINTERMATH ON}
type efi_lba=qword;
     fat32_header=packed record
                  JumpOrder:array[1..3] of byte;
                  OemCode:array[1..8] of char;
                  BytesPerSector:word;
                  SectorPerCluster:byte;
                  ReservedSectorCount:word;
                  NumFATs:byte;
                  RootEntryCount:word;
                  TotalSector16:word;
                  Media:byte;
                  FATSectors16:word;
                  SectorPerTrack:word;
                  NumHeads:word;
                  HiddenSectors:dword;
                  TotalSectors32:dword;
                  FATSector32:dword;
                  ExtendedFlags:word;
                  FileSystemVersion:word;
                  RootCluster:dword;
                  FileSystemInfo:word;
                  BootSector:word;
                  Reserved:array[1..12] of byte;
                  DriverNumber:byte;
                  Reserved1:byte;
                  BootSignature:byte;
                  VolumeID:dword;
                  VolumeLabel:array[1..11] of char;
                  FileSystemType:array[1..8] of char;
                  Reserved2:array[1..420] of byte;
                  SignatureWord:word;
                  Reserved3:array[1..65023] of byte;
                  end;
     fat32_file_system_info=packed record
                            FSI_leadSig:dword;
                            FSI_Reserved1:array[1..480] of byte;
                            FSI_StrucSig:dword;
                            FSI_FreeCount:dword;
                            FSI_NextFree:dword;
                            FSI_Reserved2:array[1..12] of byte;
                            FSI_TrailSig:dword;
                            FSI_Reserved3:array[1..65023] of byte;
                            end;
     mbr_partition_record=packed record
                          BootIndicator:byte;
                          StartingCHS:array[1..3] of byte;
                          OSType:byte;
                          EndingCHS:array[1..3] of byte;
                          StartingLBA:dword;
                          SizeinLBA:dword;
                          end;
     master_boot_record=packed record
                        BootStrapCode:array[1..440] of byte;
                        UniqueMbrSignature:dword;
                        Unknown:word;
                        Partition:array[1..4] of mbr_partition_record;
                        Signature:word;
                        end;
     efi_guid=packed record
              data1:dword;
              data2:word;
              data3:word;
              data4:array[1..8] of byte;
              end; 
     efi_gpt_header=packed record
                    signature:qword;
                    Revision:dword;
                    HeaderSize:dword;
                    HeaderCRC32:dword;
                    Reserved1:dword;
                    MyLBA:qword;
                    AlternateLBA:qword;
                    FirstUsableLBA:qword;
                    LastUsableLBA:qword;
                    DiskGuid:efi_guid;
                    PartitionEntryLBA:qword;
                    NumberOfPartitionEntries:dword;
                    SizeOfPartitionEntry:dword;
                    PartitionEntryArrayCRC32:dword;
                    Reserved2:array[1..65444] of byte;
                    end;
     efi_partition_entry=packed record
                         PartitionTypeGUID:efi_guid;
                         UniquePartitionGUID:efi_guid;
                         StartingLBA:efi_lba;
                         EndingLBA:efi_lba;
                         Attributes:qword;
                         PartitionName:array[1..36] of WideChar;
                         end;
     Pefi_guid=^efi_guid;
     PPefi_guid=^Pefi_guid;
     PPPefi_guid=^PPefi_guid;
     efi_mac_address=array[1..32] of byte;
     efi_ipv4_address=array[1..4] of byte;
     efi_ipv6_address=array[1..16] of byte;
     efi_btt_info_block=record
                        sig:array[1..16] of char;
                        uuid:efi_guid;
                        Parentuuid:efi_guid;
                        Flags:longword;
                        Major,Minor:word;
                        ExternallbaSize,ExternalNlba:longword;
                        Internallbasize,InternalNlba:longword;
                        Nfree:longword;
                        InfoSize:longword;
                        NextOff,DataOff,MapOff,FlogOff,InfoOff:qword;
                        unused:array[1..3968] of char;
                        Checksum:qword;
                        end;
     efi_btt_map_entry=bitpacked record
                       PostMapLba:0..1073741823;
                       Error:0..1;
                       Zero:0..1;
                       end;
     efi_table_header=record
		      signature:qword;
		      revision:dword;
		      headersize:dword;
		      crc32:dword;
		      reserved:dword;
                      end;
     efi_tape_header=record
                     Signature:qword;
                     Revision:dword;
                     BootDescSize:dword;
                     BootDescCRC:dword;
                     TapeGUID:efi_guid;
                     TapeType:efi_guid;
                     TapeUnique:efi_guid;
                     OSVersion:array[1..40] of char;
                     AppVersion:array[1..40] of char;
                     CreationDate:array[1..10] of char;
                     CreationTime:array[1..10] of char;
                     SystemName:array[1..256] of char;
                     TapeTitle:array[1..120] of char;
                     Pad:array[1..468] of char;
                     end;
     efi_handle=pointer;
     Pefi_handle=^pointer;
     PPefi_handle=^Pefi_handle;
     efi_hii_handle=pointer;
     Pefi_hii_handle=^pointer;
     PPefi_hii_handle=^Pefi_hii_handle;
     efi_event=pointer;
     Pefi_event=^pointer;
     PPefi_event=^Pefi_event;
     efi_physical_address=qword;
     efi_virtual_address=qword;
     efi_status=Natuint;
     Pefi_status=^Natuint;
     efi_input_key=record
                   scancode:word;
                   UnicodeChar:WideChar;
                   end;
     Pefi_simple_text_input_protocol=^efi_simple_text_input_protocol;
     efi_input_reset=function (This:Pefi_simple_text_input_protocol;ExtendedVerification:boolean):EFI_STATUS;cdecl;
     efi_input_read_key=function (This:Pefi_simple_text_input_protocol;var key:efi_input_key):EFI_STATUS;cdecl;
     efi_simple_text_input_protocol=record
      				    Reset:efi_input_reset;
      				    ReadKeyStroke:efi_input_read_key;
      				    WaitForKey:efi_event;
                                    end;
     Pefi_simple_text_output_protocol=^efi_simple_text_output_protocol;
     simple_text_output_mode=record
                             MaxMode:integer;
                             SMode:integer;
                             SAttribute:integer;
                             CursorColumn:integer;
                             CursorRow:integer;
                             CursorVisible:boolean;
                             end;
     efi_text_reset=function (This:Pefi_simple_text_output_protocol;ExtendedVerification:boolean):efi_status;cdecl;
     efi_text_output_string=function (This:Pefi_simple_text_output_protocol;efistring:PWideChar):efi_status;cdecl;
     efi_text_test_string=function (This:Pefi_simple_text_output_protocol;efistring:PWideChar):efi_status;cdecl;
     efi_text_query_mode=function (This:Pefi_simple_text_output_protocol;Modenumber:NatUint;var Columns,Rows:Natuint):efi_status;cdecl;
     efi_text_set_mode=function (This:Pefi_simple_text_output_protocol;Modenumber:NatUint):efi_status;cdecl;
     efi_text_set_attribute=function (This:Pefi_simple_text_output_protocol;eattribute:NatUint):efi_status;cdecl;
     efi_text_clear_screen=function (This:Pefi_simple_text_output_protocol):efi_status;cdecl;
     efi_text_set_cursor_position=function (This:Pefi_simple_text_output_protocol;column,row:Natuint):efi_status;cdecl;
     efi_text_enable_cursor=function (This:Pefi_simple_text_output_protocol;visible:boolean):efi_status;cdecl;
     efi_simple_text_output_protocol=record
                                     Reset:efi_text_reset;
                                     Outputstring:efi_text_output_string;
                                     Teststring:efi_text_test_string;
                                     QueryMode:efi_text_query_mode;
                                     SetMode:efi_text_set_mode;
                                     SetAttribute:efi_text_set_attribute;
                                     clearscreen:efi_text_clear_screen;
                                     setcursorposition:efi_text_set_cursor_position;
                                     enablecursor:efi_text_enable_cursor;
                                     mode:^simple_text_output_mode;
                                     end;
     efi_time=record
     	      year:word;
     	      month:byte;
     	      day:byte;
     	      hour:byte;
     	      minute:byte;
     	      second:byte;
     	      pad1:byte;
     	      nanosecond:longword;
     	      timezone:smallint;
     	      daylight:byte;
     	      pad2:byte;
              end; 
     Pefi_time=^efi_time;
     efi_time_capabilities=record
                           resolution:dword;
                           accuracy:dword;
                           SetsToZero:boolean;
                           end;
     Pefi_time_capabilities=^efi_time_capabilities;
     efi_memory_descriptor=record
                           efitype:longword;
                           physicalstart:efi_physical_address;
                           virtualstart:efi_virtual_address;
                           NumberofPages:qword;
                           efiAttribute:qword;
                           end;
     Pefi_memory_descriptor=^efi_memory_descriptor;
     efi_get_time=function (var Time:efi_time;var Capabilities:efi_time_capabilities):efi_status;cdecl;
     efi_set_time=function (Time:Pefi_time):efi_status;cdecl;
     efi_get_wakeup_time=function (var Enabled,Pending:boolean;var Time:efi_time):efi_status;cdecl;
     efi_set_wakeup_time=function (enabled:boolean;Time:Pefi_time):efi_status;cdecl;
     efi_set_virtual_address_map=function (MemoryMapSize,DescriptorSize:NatUint;DescriptorVersion:dword;VirtualMap:Pefi_memory_descriptor):efi_status;cdecl;
     efi_convert_pointer=function (DebugPosition:NatUint;Address:PPointer):efi_status;cdecl;
     efi_get_variable=function (VariableName:PWideChar;VendorGuid:Pefi_guid;var attributes:dword;var datasize:NatUint;var data):efi_Status;cdecl;
     efi_get_next_variable_name=function (var VariableNameSize:PNatUint;var VariableName:PWidechar;var VendorGuid:Pefi_guid):efi_status;cdecl;
     efi_set_variable=function (VariableName:PWideChar;VendorGuid:Pefi_guid;Attributes:dword;DataSize:Natuint;Data:Pointer):efi_status;cdecl;
     efi_get_next_monotonic_count=function (var Highcount:dword):efi_Status;cdecl;
     efi_reset_type=(EfiResetCold,EfiResetWarm,EfiResetShutDown,EfiResetPlatformSpecific);
     Pefi_reset_type=^efi_reset_type;
     efi_reset_system=function (ResetType:efi_reset_type;ResetStatus:efi_status;DataSize:Natuint;ResetData:Pointer):efi_status;cdecl;
     efi_capsule_block_descriptor=record
                        	  efilength:qword;
                        	  case Boolean of 
                       		  True:(DataBlock:efi_physical_address);
                        	  False:(ContinuationPointer:efi_physical_address);
                      		  end;
     efi_capsule_header=record
                        CapsuleGuid:efi_guid;
                        headersize:dword;
                        flags:dword;
                        CapsuleImageSize:dword;
                        end;
     efi_capsule_table=record
                       CapsuleArrayNumber:dword;
                       CapsulePtr:array[1..1] of Pointer;
                       end;
     Pefi_capsule_header=^efi_capsule_header;
     PPefi_capsule_header=^Pefi_capsule_header;
     efi_update_capsule=function (CapsuleHeaderArray:PPefi_capsule_header;CapsuleCount:NatUint;ScatterGatherList:efi_physical_address):efi_status;cdecl;
     efi_query_capsule_capabilities=function (CapsuleHeaderArray:PPefi_capsule_header;CapsuleCount:NatUint;var MaximumCapsuleSize:qword;var ResetType:efi_reset_type):efi_status;cdecl;
     efi_query_variable_info=function (attributes:dword;MaximumVariableStorageSize,RemainingVariableStorageSize,MaximumVariableSize:Pqword):efi_status;cdecl;                 
     efi_runtime_services=record
                          hdr:efi_table_header;
                          Gettime:efi_get_time;
                          Settime:efi_set_time;
                          GetWakeupTime:efi_get_wakeup_time;
                          SetWakeupTime:efi_set_wakeup_time;
                          SetVirtualAddressMap:efi_set_virtual_address_map;
                          ConvertPointer:efi_convert_pointer;
                          getvariable:efi_get_variable;
                          getnextvariablename:efi_get_next_variable_name;
                          setvariable:efi_set_variable;
                          GetNextMonotonicCount:efi_get_next_monotonic_count;
                          ResetSystem:efi_reset_system;
                          UpdateCapsule:efi_update_capsule;
                          QueryCapsuleCapabilities:efi_query_capsule_capabilities;
                          QueryVariableInfo:efi_query_variable_info;
                          end;
     efi_tpl=NatUint;
     efi_raise_tpl=function (NewTpl:efi_tpl):efi_status;cdecl;
     efi_restore_tpl=function (OldTpl:efi_tpl):efi_status;cdecl;
     efi_allocate_type=(AllocateAnyPages,AllocateMaxAddress,AllocateAddress,MaxAllocateType);
       	efi_memory_type=(EfiReservedMemoryType,EfiLoaderCode,EfiLoaderData,EfiBootServicesCode,EfiBootServicesData,EfiRuntimeServicesCode,EfiRuntimeServicesData,EfiConventionalMemory,EfiUnusableMemory,EfiACPIReclaimMemory,EfiACPIMemoryNVS,EfiMemoryMappedIO,EfiMemoryMappedIOPortSpace,EfiPalCode,EfiPersistentMemory,EfiUnacceptedMemoryType,EfiMaxMemoryType);
     efi_allocate_pages=function (efitype:efi_allocate_type;MemoryType:efi_memory_type;Pages:NatUint;Memory:Pqword):efi_status;cdecl;
     efi_free_pages=function (Memory:qword;Pages:NatUint):efi_status;cdecl;
     efi_get_memory_map=function (var MemoryMapSize:Natuint;var Memory_map:efi_memory_descriptor;var MapKey,DescriptorSize:NatUint;var DescriptorVersion:dword):efi_status;cdecl;
     efi_allocate_pool=function (PoolType:efi_memory_type;Size:NatUint;var Buffer:Pointer):efi_status;cdecl;
     efi_free_pool=function (Buffer:Pointer):efi_status;cdecl;
     efi_event_notify=function (Event:efi_event;Context:Pointer):efi_status;cdecl;
     efi_create_event=function (efitype:dword;NotifyTpl:efi_tpl;NotifyFunction:efi_event_notify;NotifyContext:Pointer;var Event:efi_event):efi_status;cdecl;
     efi_create_event_ex=function (efitype:dword;NotifyTpl:efi_tpl;NotifyFunction:efi_event_notify;const NotifyContext:Pointer;const EventGroup:Pefi_guid;var Event:efi_event):efi_status;cdecl;
     efi_timer_delay=(TimerCancel,TimerPeriodic,TimerRelative);
     efi_set_timer=function (event:efi_event;efitype:efi_timer_delay;TriggerTime:qword):efi_status;cdecl;
     efi_wait_for_event=function (NumberOfEvents:NatUint;Event:efi_event;var Index:NatUint):efi_status;cdecl;
     efi_signal_event=function (event:efi_event):efi_status;cdecl;
     efi_close_event=function (event:efi_event):efi_status;cdecl;
     efi_check_event=function (event:efi_event):efi_status;cdecl;
     efi_interface_type=(efi_native_interface);
     efi_install_protocol_interface=function (var Handle:efi_handle;Protocol:Pefi_guid;InterfaceType:efi_interface_type;efiinterface:Pointer):efi_status;cdecl;
     efi_reinstall_protocol_interface=function (Handle:efi_handle;Protocol:Pefi_guid;Oldinterface,Newinterface:Pointer):efi_status;cdecl;
     efi_uninstall_protocol_interface=function (Handle:efi_handle;Protocol:Pefi_guid;efiinterface:Pointer):efi_status;cdecl;
     efi_handle_protocol=function (Handle:efi_handle;Protocol:Pefi_guid;var efiinterface:Pointer):efi_status;cdecl;
     efi_register_protocol_notify=function (Protocol:Pefi_guid;Event:efi_event;var Registration:Pointer):efi_status;cdecl;
     efi_locate_search_type=(AllHandles,ByRegisterNotify,ByProtocol);
     efi_locate_handle=function (SearchType:efi_locate_search_type;Protocol:Pefi_guid;SearchKey:Pointer;var BufferSize:Pointer;var Buffer:Pefi_handle):efi_status;cdecl;
     efi_device_path_protocol=record
                              efitype:byte;
                              subtype:byte;
                              efilength:array[1..2] of byte;
                              end;
     Pefi_device_path_protocol=^efi_device_path_protocol;
     PPefi_device_path_protocol=^Pefi_device_path_protocol;
     efi_device_path=efi_device_path_protocol;
     Pefi_device_path=^efi_device_path;
     efi_locate_device_path=function (Protocol:Pefi_guid;var DevicePath:Pefi_device_path_protocol;Device:Pefi_handle):efi_status;cdecl;
     efi_install_configuration_table=function (Guid:Pefi_guid;Table:Pointer):efi_status;cdecl;
     efi_image_load=function (BootPolicy:boolean;ParentImageHandle:efi_handle;DevicePath:Pefi_device_path_protocol;SourceBuffer:Pointer;SourceSize:NatUint;var ImageHandle:efi_handle):efi_status;cdecl;
     efi_image_start=function (ImageHandle:efi_handle;var ExitDataSize:NatUint;var ExitData:PWideChar):efi_status;cdecl;
     efi_exit=function (ImageHandle:efi_handle;ExitStatus:efi_status;ExitDataSize:NatUInt;ExitData:PWideChar):efi_status;cdecl;
     efi_image_unload=function (ImageHandle:efi_handle):efi_status;cdecl;
     efi_exit_boot_services=function (ImageHandle:efi_handle;MapKey:NatUint):efi_status;cdecl;
     efi_stall=function (Microseconds:NatUint):efi_status;cdecl;
     efi_set_watchdog_timer=function (Timeout:NatUint;Watchdogcode:qword;DataSize:NatUint;WatchDogData:PWideChar):efi_status;cdecl;
     efi_connect_controller=function (ControllerHandle:efi_handle;DriveImageHandle:Pefi_handle;RemainingDevicePath:Pefi_device_path_protocol;Recursive:boolean):efi_status;cdecl;
     efi_disconnect_controller=function (ControllerHandle,DriverImageHandle,ChildHandle:efi_handle):efi_status;cdecl;
     efi_open_protocol=function (Handle:efi_handle;Protocol:Pefi_guid;var efiinterface:Pointer;AgentHandle:efi_handle;ControllerHandle:efi_handle;Attributes:dword):efi_status;cdecl;
     efi_close_protocol=function (Handle:efi_handle;Protocol:Pefi_guid;AgentHandle:efi_handle;ControllerHandle:efi_handle):efi_status;cdecl;
     efi_open_protocol_information_entry=record
     					 AgentHandle,ControllerHandle:efi_handle;
     					 Attributes,OpenCount:dword;
                                         end;
     Pefi_open_protocol_information_entry=^efi_open_protocol_information_entry;
     PPefi_open_protocol_information_entry=^Pefi_open_protocol_information_entry;
     efi_open_protocol_information=function (Handle:efi_handle;Protocol:Pefi_guid;var EntryBuffer:PPefi_open_protocol_information_entry;EntryCount:PNatUint):efi_status;cdecl;
     efi_Protocols_Per_Handle=function (Handle:efi_handle;var ProtocolBuffer:PPefi_guid;var ProtocolBufferCount:NatUint):efi_status;cdecl;
     efi_locate_handle_buffer=function (searchtype:efi_locate_search_type;Protocol:Pefi_guid;SearchKey:Pointer;var noHandles:NatUint;var Buffer:Pefi_handle):efi_status;cdecl;
     efi_locate_protocol=function (Protocol:Pefi_guid;Registation:pointer;var efiinterface:Pointer):efi_status;cdecl;
     efi_install_multiple_protocol_interfaces=function (var Handle:efi_handle;argument:array of Pointer):efi_status;cdecl;
     efi_uninstall_multiple_protocol_interfaces=function (var Handle:efi_handle;argument:array of Pointer):efi_status;cdecl;
     efi_calculate_crc32=function (Data:Pointer;DataSize:NatUint;var Crc32:dword):efi_status;cdecl;
     efi_copy_mem=procedure (Destination,Source:Pointer;efilength:NatUint);cdecl;
     efi_set_mem=procedure (Buffer:Pointer;size:NatUint;efivalue:byte);cdecl;
     efi_boot_services=record
                       hdr:efi_table_header;
                       RaiseTPL:efi_raise_tpl;
                       RestoreTPL:efi_restore_tpl;
                       AllocatePages:efi_allocate_pages;
                       FreePages:efi_free_pages;
                       GetMemoryMap:efi_get_memory_map;
                       AllocatePool:efi_allocate_pool;
                       FreePool:efi_free_pool;
                       CreateEvent:efi_create_event;
                       SetTimer:efi_set_timer;
                       WaitForEvent:efi_wait_for_event;
                       SignalEvent:efi_signal_event;
                       CloseEvent:efi_close_event;
                       CheckEvent:efi_check_event;
                       InstallProtocolInterface:efi_install_protocol_interface;
                       ReinstallProtocolInterface:efi_reinstall_protocol_interface;
                       UninstallProtocolInterface:efi_uninstall_protocol_interface;
                       HandleProtocol:efi_handle_protocol;
                       Reserved:Pointer;
                       RegisterProtocolNotify:efi_register_protocol_notify;
                       locatehandle:efi_locate_handle;
                       locatedevicepath:efi_locate_device_path;
                       InstallConfigurationTable:efi_install_configuration_table;
                       loadimage:efi_image_load;
                       startimage:efi_image_start;
                       efiexit:efi_exit;
                       unloadimage:efi_image_unload;
                       exitbootservices:efi_exit_boot_services;
                       GetNextMonotonicCount:efi_get_next_monotonic_count;
                       stall:efi_stall;
                       SetWatchDogTimer:efi_set_watchdog_timer;
                       ConnectController:efi_connect_controller;
                       DisconnectController:efi_disconnect_controller;
                       OpenProtocol:efi_open_protocol;
                       CloseProtocol:efi_close_protocol;
                       OpenProtocolInformation:efi_open_protocol_information;
                       Protocolsperhandle:efi_protocols_per_handle;
                       LocateHandleBuffer:efi_locate_handle_buffer;
                       LocateProtocol:efi_locate_protocol;
                       InstallMultipleProtocolInterfaces:efi_install_multiple_protocol_interfaces;
                       UninstallMultipleProtocolInterfaces:efi_uninstall_multiple_protocol_interfaces;
                       CalculateCrc32:efi_calculate_crc32;
                       CopyMem:efi_copy_mem;
                       SetMem:efi_set_mem;
                       CreateEventEx:efi_create_event_ex;
                       end;
     efi_configuration_table=record
                             VendorGuid:efi_guid;
                             VendorTable:pointer;
                             end;
     efi_system_table=record
                      hdr:efi_table_header;
                      FirmWareVendor:^WideChar;
                      FirmWareRevision:dword;
                      ConsoleInHandle:efi_handle;
                      ConIn:^efi_simple_text_input_protocol;
                      ConsoleOutHandle:efi_handle;
                      ConOut:^efi_simple_text_output_protocol;
                      StandardErrorHandle:efi_handle;
                      StdErr:^efi_simple_text_output_protocol;
                      RuntimeServices:^efi_runtime_services;
                      bootservices:^efi_boot_services;
                      numberofTableEntries:NatUint;
                      configuration_table:^efi_configuration_table;
                      end;
     Pefi_system_table=^efi_system_table;
     efi_loaded_image_protocol=record
                               Revision:dword;
                               ParentHandle:efi_handle;
                               SystemTable:^efi_system_table;
                               DeviceHandle:efi_handle;
                               filepath:^efi_device_path_protocol;
                               reserved:Pointer;
                               LoadOptionSize:dword;
                               LoadOptions:Pointer;
                               ImageBase:Pointer;
                               ImageSize:qword;
                               ImageCodeType:efi_memory_type;
                               ImageDataType:efi_memory_type;
                               unload:efi_image_unload;
                               end;
     efi_device_path_utils_get_device_path_size=function (const DevicePath:efi_device_path_protocol):natuint;cdecl;
     efi_device_path_utils_dup_device_path=function (const DevicePath:efi_device_path_protocol):Pefi_device_path_protocol;cdecl;
     efi_device_path_utils_append_path=function (const src1,src2:Pefi_device_path_protocol):Pefi_device_path_protocol;cdecl;
     efi_device_path_utils_append_node=function (const DevicePath,DeviceNode:Pefi_device_path_protocol):Pefi_device_path_protocol;cdecl;
     efi_device_path_utils_append_instance=function (const DevicePath,DeviceInstance:Pefi_device_path_protocol):Pefi_device_path_protocol;cdecl;
     efi_device_path_utils_get_next_instance=function (var DevicePathInstance:PPefi_device_path_protocol;var DevicePathInstanceSize:Natuint):Pefi_device_path_protocol;cdecl;
     efi_device_path_utils_is_multi_instance=function (const DevicePath:Pefi_device_path_protocol):Pefi_device_path_protocol;cdecl;
     efi_device_path_utils_create_node=function (NodeType:byte;NodeSubType:byte;NodeLength:word):Pefi_device_path_protocol;cdecl;
     efi_device_path_utilities_protocol=record
     					GetDevicePathSize:efi_device_path_utils_get_device_path_size;
     					DuplicateDevicePath:efi_device_path_utils_dup_device_path;
     					AppendDevicePath:efi_device_path_utils_append_path;
     					AppendDeviceNode:efi_device_path_utils_append_node;
     					AppendDevicePathInstance:efi_device_path_utils_append_instance;
     					GetNextDevicePathInstance:efi_device_path_utils_get_next_instance;
     					IsDevicePathMultiinstance:efi_device_path_utils_is_multi_instance;
     					CreateDeviceNode:efi_device_path_utils_create_node;
                                        end;
     efi_device_path_to_text_node=function (const DeviceNode:Pefi_device_path_protocol;DisplayOnly:boolean;AllowShortCuts:boolean):PWideChar;cdecl;
     efi_device_path_to_text_path=function (const DevicePath:Pefi_device_path_protocol;DisplayOnly:boolean;AllowShortCuts:boolean):PWideChar;cdecl;
     efi_device_path_to_text_protocol=record
                                      ConvertDeviceNodeToText:efi_device_path_to_text_node;
                                      ConvertDevicePathToText:efi_device_path_to_text_path;
                                      end;
     efi_device_path_from_text_node=function (const TextDeviceNode:PWideChar):Pefi_device_path_protocol;cdecl;
     efi_device_path_from_text_path=function (const TextDevicePath:PWideChar):Pefi_device_path_protocol;cdecl;
     efi_device_path_from_text_protocol=record
     					ConvertTextToDeviceNode:efi_device_path_from_text_node;
     					ConvertTextToDevicePath:efi_device_path_from_text_path;
                                        end;
     Pefi_driver_binding_protocol=^efi_driver_binding_protocol;
     efi_driver_binding_protocol_supported=function (This:Pefi_driver_binding_protocol;ControllerHandle:efi_handle;RemainingDevicePath:Pefi_device_path_protocol):efi_status;cdecl;
     efi_driver_binding_protocol_start=function (This:Pefi_driver_binding_protocol;ControllerHandle:efi_handle;RemainingDevicePath:Pefi_device_path_protocol):efi_status;cdecl;
     efi_driver_binding_protocol_stop=function (This:Pefi_driver_binding_protocol;ControllerHandle:efi_handle;NumberOfChildren:natuint;ChildHandleBuffer:efi_handle):efi_status;cdecl;
     efi_driver_binding_protocol=record
                                 Supported:efi_driver_binding_protocol_supported;
                                 Start:efi_driver_binding_protocol_start;
                                 Stop:efi_driver_binding_protocol_stop;
                                 Version:dword;
                                 ImageHandle:efi_handle;
                                 DriverBindingHandle:efi_handle;
     				 end;
     Pefi_platform_driver_override_protocol=^efi_platform_driver_override_protocol;
     efi_platform_driver_override_get_driver=function (This:Pefi_platform_driver_override_protocol;ControllerHandle:efi_handle;var DriverImageHandle:efi_handle):efi_status;cdecl;
     efi_platform_driver_override_get_driver_path=function (This:Pefi_platform_driver_override_protocol;ControllerHandle:efi_handle;var DriverImagePath:Pointer):efi_status;cdecl;
     efi_platform_driver_override_driver_loaded=function (This:Pefi_platform_driver_override_protocol;ControllerHandle:efi_handle;DriverImagePath:Pefi_device_path_protocol;DriverImageHandle:efi_handle):efi_status;cdecl;
     efi_platform_driver_override_protocol=record
                                           GetDriver:efi_platform_driver_override_get_driver;
                                           GetDriverPath:efi_platform_driver_override_get_driver_path;
                                           DriverLoaded:efi_platform_driver_override_driver_loaded;
                                           end;
     Pefi_bus_specific_driver_override_protocol=^efi_bus_specific_driver_override_protocol;
     efi_bus_specific_driver_override_get_driver=function (This:Pefi_bus_specific_driver_override_protocol;var DriverImageHandle:efi_handle):efi_status;cdecl;
     efi_bus_specific_driver_override_protocol=record
                                               GetDriver:efi_bus_specific_driver_override_get_driver;
                                               end;
     efi_driver_diagnostic_type=(efidriverdiagnostictypestandard=0,efidriverdiagnostictypeextended=1,efidriverdiagnostictypemanufacturing=2,
efidriverdiagnostictypeCancel=3,efiDriverDiagnosticTypeMaximum);
     Pefi_driver_diagnostics_protocol=^efi_driver_diagnostics_protocol;
     efi_driver_diagnostics2_run_diagnostics=function (This:Pefi_driver_diagnostics_protocol;ControllerHandle:efi_handle;ChildHandle:efi_handle;DiagnosticsHandle:efi_driver_diagnostic_type;Language:PChar;var ErrorType:Pefi_guid;var BufferSize:NatUint;var Buffer:PWideChar):efi_status;cdecl;
     efi_driver_diagnostics_protocol=record
                                     RunDiagnostics:efi_driver_diagnostics2_run_diagnostics;
                                     SupportedLanguages:Pchar;
                                     end;
     Pefi_component_name2_protocol=^efi_component_name2_protocol;
     efi_component_name_get_driver_name=function (This:Pefi_component_name2_protocol;Language:Pchar;var DriverName:PWideChar):efi_status;cdecl;
     efi_component_name_get_controller_name=function (This:Pefi_component_name2_protocol;ControllerHandle,ChildHandle:efi_handle;Languages:PChar;var DriverName:PWideChar):efi_status;cdecl;
     efi_component_name2_protocol=record
				  GetDriverName:efi_component_name_get_driver_name;
				  GetControllerName:efi_component_name_get_controller_name;
				  SupportedLanguages:PChar;
                                  end;
     Pefi_service_binding_protocol=^efi_service_binding_protocol;
     efi_service_binding_create_child=function (This:Pefi_service_binding_protocol;var ChildHandle:efi_handle):efi_status;cdecl;
     efi_service_binding_destroy_child=function (This:Pefi_service_binding_protocol;ChildHandle:efi_handle):efi_status;cdecl;
     efi_service_binding_protocol=record
     			 	  CreateChild:efi_service_binding_create_child;
     			 	  DestroyChild:efi_service_binding_destroy_child;
                                  end;
     Pefi_platform_to_driver_configuration_protocol=^efi_platform_to_driver_configuration_protocol;
     efi_platform_to_driver_configuration_query=function (This:Pefi_platform_to_driver_configuration_protocol;ControllerHandle,ChildHandle:efi_handle;Instance:PNatuint;var ParameterTypeGuid:Pefi_guid;var ParameterBlock:Pointer;var ParameterBlockSize:Natuint):efi_status;cdecl;
     	efi_platform_configuration_action=(efiplatformconfigurationactionnone=0,efiplatformconfigurationactionstopcontroller=1,efiplatformconfigurationactionrestartcontroller=2,efiplatformconfigurationactionrestartplatform=3,efiplatformconfigurationactionnvramfailed=4,efiplatformconfigurationactionunsupportedguid=5,efiplatformconfigurationactionmaximum);
     efi_platform_to_driver_configuration_response=function (This:Pefi_platform_to_driver_configuration_protocol;ControllerHandle,ChildHandle:efi_handle;Instance:PNatUint;ParameterTypeGuid:Pefi_guid;ParameterBlock:Pointer;ParameterBlockSize:Natuint;ConfigurationAction:efi_platform_configuration_action):efi_status;cdecl;
     efi_platform_to_driver_configuration_protocol=record
     						   Query:efi_platform_to_driver_configuration_query;
     						   Response:efi_platform_to_driver_configuration_response;
     						   end;
     efi_driver_supported_efi_version_protocol=record
                                               efilength:dword;
                                               FirmWareVersion:dword;
                                               end;
     Pefi_driver_family_override_protocol=^efi_driver_family_override_protocol;
     efi_driver_family_override_get_version=function (This:Pefi_driver_family_override_protocol):dword;cdecl;
     efi_driver_family_override_protocol=record
                                         GetVersion:efi_driver_family_override_get_version;
                                         end;
     Pefi_driver_health_protocol=^efi_driver_health_protocol;
     efi_driver_health_status=(efidriverstatushealthy,efidriverstatusrepairrequired,efidriverstatusconfigurationrequired,efidriverstatusfailed,efidriverstatusreconnectrequired,efidriverstatusrebootrequired);
     efi_string_id=natuint;
     efi_driver_health_hii_message=record
     				   HiiHandle:efi_hii_handle;
     				   StringId:efi_string_id;
     				   MessageCode:qword;
                                   end;
     efi_driver_health_get_health_status=function (This:Pefi_driver_health_protocol;ControllerHandle,ChildHandle:efi_handle;var HealthStatus:efi_driver_health_status;var MessageList:efi_driver_health_hii_message;var FormHiiHandle:efi_hii_handle):efi_status;cdecl;
     efi_driver_health_repair_notify=function (efiValue:Natuint;Limit:Natuint):efi_status;cdecl;
     efi_driver_health_repair=function (This:Pefi_driver_health_protocol;ControllerHandle,ChildHandle:efi_handle;RepairNotify:efi_driver_health_repair_notify):efi_status;cdecl;
     efi_driver_health_protocol=record
                                GetHealthStatus:efi_driver_health_get_health_status;
                                Repair:efi_driver_health_repair;
                                end;
     Pefi_adapter_information_protocol=^efi_adapter_information_protocol;
     efi_adapter_info_get_info=function (This:Pefi_adapter_information_protocol;InformationType:Pefi_guid;var InformationBlock:Pointer;var InformationBlockSize:NatUint):efi_status;cdecl;
     efi_adapter_info_set_info=function (This:Pefi_adapter_information_protocol;InformationType:Pefi_guid;InformationBlock:Pointer;InformationBlockSize:Natuint):efi_status;cdecl;
     efi_adapter_info_get_supported_types=function (This:Pefi_adapter_information_protocol;var InfoTypesBuffer:Pefi_guid;var InfoTypesBufferCount:NatUint):efi_status;cdecl;
     efi_adapter_information_protocol=record
                                      GetInformation:efi_adapter_info_get_info;
                                      SetInformation:efi_adapter_info_set_info;
                                      GetSupportedTypes:efi_adapter_info_get_supported_types;
                                      end;
     efi_adapter_info_state=record
                            MediaState:efi_status;
                            end;
     efi_adapter_info_network=record
     			      iSsciIpv4BootCapability:boolean;
     			      iSsciIpv6BootCapability:boolean;
     			      FCoeBootCapability:boolean;
     			      OffloadCapability:boolean;
     			      iSsciMpioCapability:boolean;
     			      iSsciIpv4Boot:boolean;
     			      iSsciIpv6Boot:boolean;
     			      FCoeBoot:boolean;
                              end;
     efi_adapter_info_san_mac_address=record
     				      SanMacAddress:efi_mac_address;
                                      end;
     efi_adapter_info_undi_ipv6_support=record
                                        Ipv6Support:boolean;
                                        end;
     efi_adapter_info_media_type=record
                                 MediaType:byte;
                                 end;
     efi_adapter_info_cdat_type_type=record
                                     CdatSize:natuint;
                                     Cdat:array of byte;
                                     end;
     Pefi_simple_text_input_ex_protocol=^efi_simple_text_input_ex_protocol;
     efi_input_reset_ex=function (This:Pefi_simple_text_input_ex_protocol;ExtendedVerification:boolean):efi_status;cdecl;
     efi_key_state=record
                   keyshiftstate:dword;
                   keytogglestate:byte;
                   end;
     efi_key_data=record 
                  Key:efi_input_key;
                  KeyState:efi_key_state;
                  end; 
     Pefi_key_data=^efi_key_data;
     efi_key_toggle_state=byte;
     Pefi_key_toggle_state=^efi_key_toggle_state;
     efi_input_read_key_ex=function (This:Pefi_simple_text_input_ex_protocol;var KeyData:efi_key_data):efi_status;cdecl;
     efi_set_state=function (This:Pefi_simple_text_input_ex_protocol;KeyToggleState:Pefi_key_toggle_state):efi_status;cdecl;
     efi_key_notify_function=function (KeyData:Pefi_key_data):efi_status;cdecl;
     efi_register_keystroke_notify=function (This:Pefi_simple_text_input_ex_protocol;KeyData:Pefi_key_data;KeyNotificationFunction:efi_key_notify_function;var NotifyHandle:Pointer):efi_status;cdecl;
     efi_unregister_keystroke_notify=function (This:Pefi_simple_text_input_ex_protocol;NotificationHandle:Pointer):efi_status;cdecl;
     efi_simple_text_input_ex_protocol=record
                                       Reset:efi_input_reset_ex;
                                       ReadKeyStrokeEx:efi_input_read_key_ex;
                                       WaitForKeyEx:efi_event;
                                       SetState:efi_set_state;
                                       RegisterKeyNotify:efi_register_keystroke_notify;
                                       UnregisterKeyNotify:efi_unregister_keystroke_notify;
                                       end;
     efi_simple_pointer_mode=record 
                             ResolutionX,ResolutionY,ResolutionZ:qword;
                             leftbutton,rightbutton:boolean;
                             end;
     Pefi_simple_pointer_protocol=^efi_simple_pointer_protocol;
     efi_simple_pointer_reset=function (This:Pefi_simple_pointer_protocol;ExtendedVerification:boolean):efi_status;cdecl;
     efi_simple_pointer_state=record
                              RelativeMovementX,RelativeMovementY,RelativeMovementZ:integer;
                              LeftButton,RightButton:boolean;
                              end;
     efi_simple_pointer_get_state=function (This:Pefi_simple_pointer_protocol;var State:efi_simple_pointer_state):efi_status;cdecl;
     efi_simple_pointer_protocol=record
                                 Reset:efi_simple_pointer_reset;
                                 GetState:efi_simple_pointer_get_state;
                                 WaitForInput:efi_event;
                                 Mode:^efi_simple_pointer_mode;
                                 end;
     Pefi_absolute_pointer_protocol=^efi_absolute_pointer_protocol;
     efi_absolute_pointer_mode=record
                               AbsoluteMinX,AbsoluteMinY,AbsoluteMinZ,AbsoluteMaxX,AbsoluteMaxY,AbsoluteMaxZ:qword;
                               Attributes:dword;
                               end;
     efi_absolute_pointer_reset=function (This:Pefi_absolute_pointer_protocol;ExtendVerification:boolean):efi_status;cdecl;
     efi_absolute_pointer_state=record
                                CurrentX,CurrentY,CurrentZ:qword;
                                ActiveButtons:dword;
                                end;
     efi_absolute_pointer_get_state=function (This:Pefi_absolute_pointer_protocol;var state:efi_absolute_pointer_state):efi_status;cdecl;
     efi_absolute_pointer_protocol=record
                                   Reset:efi_absolute_pointer_reset;
                                   GetState:efi_absolute_pointer_get_state;
                                   WaitForInput:efi_event;
                                   Mode:^efi_absolute_pointer_mode;
                                   end;
     serial_io_mode=record
                    ControlMask:dword;
                    TimeOut:dword;
                    BaudRate:qword;
                    ReceiveFifoDepth:dword;
                    DataBits:dword;
                    Parity:dword;
                    StopBits:dword;
                    end;
     efi_parity_type=(DefaultParity=0,NoParity=1,EvenParity=2,OddParity=3,MarkParity=4,SpaceParity=5);
     efi_stop_bits_type=(DefaultStopBits=0,OneStopBit=1,OneFiveStopBits=2,TwoStopBits=3);
     Pefi_serial_io_protocol=^efi_serial_io_protocol;
     efi_serial_reset=function (This:Pefi_serial_io_protocol):efi_status;cdecl;
     efi_serial_set_attributes=function (This:Pefi_serial_io_protocol;BaudRate:qword;ReceiveFifoDepth:dword;Timeout:dword;Parity:efi_parity_type;DataBits:byte;StopBits:efi_stop_bits_type):efi_status;cdecl;
     efi_serial_set_control_bits=function (This:Pefi_serial_io_protocol;Control:dword):efi_status;cdecl;
     efi_serial_get_control_bits=function (This:Pefi_serial_io_protocol;var Control:dword):efi_status;cdecl;
     efi_serial_write=function (This:Pefi_serial_io_protocol;BufferSize:PNatuint;Buffer:Pointer):efi_status;cdecl;
     efi_serial_read=function (This:Pefi_serial_io_protocol;var BufferSize:Natuint;var Buffer):efi_status;cdecl;
     efi_serial_io_protocol=record
                            revision:longword;
                            Reset:efi_serial_reset;
                            SetAttributes:efi_serial_set_attributes;
                            SetControl:efi_serial_set_control_bits;
                            GetControl:efi_serial_get_control_bits;
                            efiWrite:efi_serial_write;
                            efiRead:efi_serial_read;
                            Mode:^Serial_IO_mode;
                            device_type_guid:^efi_guid;
                            end;
     Pefi_graphics_output_protocol=^efi_graphics_output_protocol;
     efi_pixel_mask=record
                    RedMask,GreenMask,BlueMask,ReservedMask:dword;
                    end;
     efi_graphics_pixel_format=(PixelRedGreenBlueReserved8BitPerColor,PixelBlueGreenRedReserved8BitPerColor,PixelBitMask,PixelBitOnly,PixelFormatMax);
     efi_graphics_output_mode_information=record
                                          Version:dword;
                                          HorizonalResolution:dword;
                                          VerticalResolution:dword;
                                          PixelFormat:efi_graphics_pixel_format;
                                          PixelInformation:efi_pixel_mask;
                                          PixelPerScanLine:dword;
                                          end;
     Pefi_graphics_output_mode_information=^efi_graphics_output_mode_information;
     efi_graphics_output_protocol_mode=efi_graphics_output_mode_information;
     efi_graphics_output_protocol_query_mode=function (This:Pefi_graphics_output_protocol;ModeNumber:dword;var SizeOfInfo:Natuint;var Info:Pefi_graphics_output_mode_information):efi_status;cdecl;
     efi_graphics_output_protocol_set_mode=function (This:Pefi_graphics_output_protocol;ModeNumber:dword):efi_status;cdecl;
     efi_graphics_output_blt_pixel=record
                                   Blue,Green,Red,Reserved:byte;
                                   end;
     efi_graphics_output_blt_operation=(efibltVideoFill,efibltVideoToBltBuffer,efibltBufferToVideo,efiBltVideoToVideo,efiGraphicsOutputBltOperationMax);
     efi_graphics_output_protocol_blt=function (This:Pefi_graphics_output_protocol;var BltBuffer:efi_graphics_output_blt_pixel;BltOperation:efi_graphics_output_blt_operation;SourceX,SourceY,DestinationX,DestinationY,Width,Height,Delta:Natuint):efi_status;cdecl;
     efi_graphics_output_protocol=record
                                  QueryMode:efi_graphics_output_protocol_query_mode;
                                  SetMode:efi_graphics_output_protocol_set_mode;
                                  Blt:efi_graphics_output_protocol_blt;
                                  Mode:^efi_graphics_output_protocol_mode;
                                  end;
     Pefi_load_file_protocol=^efi_load_file_protocol;
     efi_load_file=function (This:Pefi_load_file_protocol;FilePath:Pefi_device_path_protocol;BootPolicy:boolean;var BufferSize:Natuint;var Buffer):efi_status;cdecl;
     efi_load_file_protocol=record
                            LoadFile:efi_load_file;
                            end;
     efi_load_file2_protocol=efi_load_file_protocol;
     Pefi_simple_file_system_protocol=^efi_simple_file_system_protocol;
     Pefi_file_protocol=^efi_file_protocol;
     efi_simple_file_system_protocol_open_volume=function (This:Pefi_simple_file_system_protocol;var Root:Pefi_file_protocol):efi_status;cdecl;
     efi_simple_file_system_protocol=record
                                     Revision:qword;
                                     OpenVolume:efi_simple_file_system_protocol_open_volume;
                                     end;
     efi_file_open=function (This:Pefi_file_protocol;var NewHandle:Pefi_file_protocol;FileName:PWideChar;OpenMode,Attributes:qword):efi_status;cdecl;
     efi_file_close=function (This:Pefi_file_protocol):efi_status;cdecl;
     efi_file_delete=function (This:Pefi_file_protocol):efi_status;cdecl;
     efi_file_read=function (This:Pefi_file_protocol;var buffersize:qword;var Buffer):efi_status;cdecl;
     efi_file_write=function (This:Pefi_file_protocol;var buffersize:qword;Buffer:Pointer):efi_status;cdecl;
     efi_file_set_position=function (This:Pefi_file_protocol;Position:qword):efi_status;cdecl;
     efi_file_get_position=function (This:Pefi_file_protocol;var Position:qword):efi_status;cdecl;
     efi_file_set_info=function (This:Pefi_file_protocol;InformationType:Pefi_guid;BufferSize:Natuint;Buffer:Pointer):efi_status;cdecl;
     efi_file_get_info=function (This:Pefi_file_protocol;InformationType:Pefi_guid;var BufferSize:Natuint;var Buffer):efi_status;cdecl;
     efi_file_flush=function (This:Pefi_file_protocol):efi_status;cdecl;
     efi_file_io_token=record
                       Event:efi_event;
                       Status:efi_status;
                       BufferSize:qword;
                       Buffer:Pointer;
                       end;
     efi_file_open_ex=function (This:Pefi_file_protocol;var NewHandle:Pefi_file_protocol;FileName:PWideChar;OpenMode,Attributes:qword;var Token:efi_file_io_token):efi_status;cdecl;
     efi_file_read_ex=function (This:Pefi_file_protocol;var Token:efi_file_io_token):efi_status;cdecl;
     efi_file_write_ex=function (This:Pefi_file_protocol;var Token:efi_file_io_token):efi_status;cdecl;
     efi_file_flush_ex=function (This:Pefi_file_protocol;var Token:efi_file_io_token):efi_status;cdecl;
     efi_file_protocol=record
                       Revision:qword;
                       Open:efi_file_open;
                       Close:efi_file_close;
                       Delete:efi_file_delete;
                       efiRead:efi_file_read;
                       efiWrite:efi_file_write;
                       GetPosition:efi_file_get_position;
                       SetPosition:efi_file_set_position;
                       GetInfo:efi_file_get_info;
                       SetInfo:efi_file_set_info;
                       Flush:efi_file_flush;
                       OpenEx:efi_file_open_ex;
                       efiReadEx:efi_file_read_ex;
                       efiWriteEx:efi_file_write_ex;
                       FlushEx:efi_file_flush_ex;
                       end;
     efi_file_info=record
                   Size:qword;
                   FileSize:qword;
                   PhysicalSize:qword;
                   CreateTime:efi_time;
                   LastAccessTime:efi_time;
                   ModificationTime:efi_time;
                   Attributes:qword;
                   FileName:array[1..1024] of WideChar;
                   end;
     Pefi_file_info=^efi_file_info;
     efi_file_system_info=record
                          Size:qword;
                          ReadOnly:boolean;
                          VolumeSize:qword;
                          FreeSpace:qword;
                          BlockSize:dword;
                          VolumeLabel:array[1..1024] of WideChar;
                          end;
     Pefi_file_system_info=^efi_file_system_info;
     efi_file_system_volume_label=record
                                  VolumeLabel:array[1..1024] of WideChar;
                                  end;
     Pefi_tape_io_protocol=^efi_tape_io_protocol;
     efi_tape_read=function (This:Pefi_tape_io_protocol;var BufferSize:natuint;var Buffer):efi_status;cdecl;
     efi_tape_write=function (This:Pefi_tape_io_protocol;BufferSize:Pnatuint;Buffer:Pointer):efi_status;cdecl;
     efi_tape_rewind=function (This:Pefi_tape_io_protocol):efi_status;cdecl;
     efi_tape_space=function (This:Pefi_tape_io_protocol;Direction:Natint;efitype:Natuint):efi_status;cdecl;
     efi_tape_writeFM=function (This:Pefi_tape_io_protocol;Count:Natuint):efi_status;cdecl;
     efi_tape_reset=function (This:Pefi_tape_io_protocol;ExtendedVerification:boolean):efi_status;cdecl;
     efi_tape_io_protocol=record
                          TapeRead:efi_tape_read;
                          TapeWrite:efi_tape_write;
                          TapeRewind:efi_tape_rewind;
                          TapeSpace:efi_tape_space;
                          TapeWriteFM:efi_tape_writeFM;
                          TapeReset:efi_tape_reset;
                          end;
     Pefi_disk_io_protocol=^efi_disk_io_protocol;
     efi_disk_read=function (This:Pefi_disk_io_protocol;MediaId:dword;Offset:qword;BufferSize:natuint;var Buffer):efi_status;cdecl;
     efi_disk_write=function (This:Pefi_disk_io_protocol;MediaId:dword;Offset:qword;BufferSize:natuint;Buffer:Pointer):efi_status;cdecl;
     efi_disk_io_protocol=record
                          Revision:qword;
                          ReadDisk:efi_disk_read;
                          WriteDisk:efi_disk_write;
                          end;
     Pefi_disk_io2_protocol=^efi_disk_io2_protocol;
     efi_disk_cancel_ex=function (This:Pefi_disk_io2_protocol):efi_status;cdecl;
     efi_disk_io2_token=record
                        Event:efi_event;
                        TransactionStatus:efi_status;
                        end;
     efi_disk_read_ex=function (This:Pefi_disk_io2_protocol;MediaId:dword;Offset:qword;var Token:efi_disk_io2_token;BufferSize:Natuint;var Buffer):efi_status;cdecl;
     efi_disk_write_ex=function (This:Pefi_disk_io2_protocol;MediaId:dword;Offset:qword;var Token:efi_disk_io2_token;BufferSize:Natuint;Buffer:Pointer):efi_status;cdecl;
     efi_disk_flush_ex=function (This:Pefi_disk_io2_protocol;var Token:efi_disk_io2_token):efi_status;cdecl;
     efi_disk_io2_protocol=record
                           Revision:qword;
                           Cancel:efi_disk_cancel_ex;
                           ReadDiskEx:efi_disk_read_ex;
                           WriteDiskEx:efi_disk_write_ex;
                           FlushDiskEx:efi_disk_flush_ex;
                           end;  
     Pefi_block_io_protocol=^efi_block_io_protocol;
     efi_block_io_media=record
                        MediaId:dword;
                        RemovableMedia:boolean;
                        MediaPresent:boolean;
                        LogicalPartition:boolean;
                        ReadOnly:boolean;
                        WriteCaching:boolean;
                        BlockSize:dword;
                        IoAlign:dword;
                        LastBlock:efi_lba;
                        LowestAlignedLba:efi_lba;
                        LogicalBlocksPerPhysicalBlock:dword;
                        OptimalTransferLengthGranularity:dword;
                        end;
     efi_block_reset=function (This:Pefi_block_io_protocol;ExtendedVerification:boolean):efi_status;cdecl;
     efi_block_read=function (This:Pefi_block_io_protocol;MediaId:dword;lba:efi_lba;BufferSize:Natuint;var Buffer):efi_status;cdecl;
     efi_block_write=function (This:Pefi_block_io_protocol;MediaId:dword;lba:efi_lba;BufferSize:Natuint;Buffer:Pointer):efi_status;cdecl;
     efi_block_flush=function (This:Pefi_block_io_protocol):efi_status;cdecl;
     efi_block_io_protocol=record 
                           Revision:qword;
                           Media:^efi_block_io_media;
                           Reset:efi_block_reset;
                           ReadBlocks:efi_block_read;
                           WriteBlocks:efi_block_write;
                           FlushBlocks:efi_block_flush;
                           end;
     Pefi_block_io2_protocol=^efi_block_io2_protocol;
     efi_block_reset_ex=function (This:Pefi_block_io2_protocol;ExtendedVerification:boolean):efi_status;cdecl;
     efi_block_io2_token=record
                         Event:efi_event;
                         TransactionStatus:efi_status;
                         end;
     efi_block_read_ex=function (This:Pefi_block_io2_protocol;MediaId:dword;lba:efi_lba;var Token:efi_block_io2_token;BufferSize:Natuint;var Buffer):efi_status;cdecl;
     efi_block_write_ex=function (This:Pefi_block_io2_protocol;MediaId:dword;lba:efi_lba;var Token:efi_block_io2_token;BufferSize:Natuint;Buffer:Pointer):efi_status;cdecl;
     efi_block_flush_ex=function (This:Pefi_block_io2_protocol;var Token:efi_block_io2_token):efi_status;cdecl;
     efi_block_io2_protocol=record
                            Media:^efi_block_io_media;
                            Reset:efi_block_reset_ex;
                            ReadBlocksEX:efi_block_read_ex;
                            WriteBlocksEX:efi_block_write_ex;
                            FlushBlocksEx:efi_block_flush_ex;
                            end;
     Pefi_block_io_crypto_protocol=^efi_block_io_crypto_protocol;
     efi_block_io_crypto_capability=record
                                    Algorithm:efi_guid;
                                    KeySize:qword;
                                    CryptoBlockSizeBitMask:qword;
                                    end;
     efi_block_io_crypto_iv_input=record
                                  InputSize:qword;
                                  end;
     efi_block_io_crypto_iv_input_aes_xts=record
                                          Header:efi_block_io_crypto_iv_input;
                                          CryptoBlockNumber,CryptoBlockByteSize:qword;
                                          end;
     efi_block_io_crypto_iv_input_aes_cbc_microsoft_bitlocker=record
                                                              Header:efi_block_io_crypto_iv_input;
                                                              CryptoBlockNumber,CryptoBlockByteSize:qword;
                                                              end;
     efi_block_io_crypto_capabilities=record
                                      supported:boolean;
                                      KeyCount:qword;
                                      CapabilityCount:qword;
                                      Capabilities:array[1..1] of efi_block_io_crypto_capability;
                                      end;
     efi_block_io_crypto_configuration_table_entry=record
                                                   Index:qword;
                                                   KeyOwnerGuid:efi_guid;
                                                   Capability:efi_block_io_crypto_capability;
                                                   CryptoKey:Pointer;
                                                   end;
     efi_block_io_crypto_response_configuration_entry=record 
                                                      Index:qword;
                                                      KeyOwnerGuid:efi_guid;
                                                      Capability:efi_block_io_crypto_capability;
                                                      end;
     Pefi_block_io_crypto_configuration_table_entry=^efi_block_io_crypto_configuration_table_entry;
     efi_block_io_crypto_reset=function (This:Pefi_block_io_crypto_protocol;ExtendedVerification:boolean):efi_status;cdecl;
     efi_block_io_crypto_get_capabilities=function (This:Pefi_block_io_crypto_protocol;var Capabilities:efi_block_io_crypto_capabilities):efi_status;cdecl;
     efi_block_io_crypto_set_configuration=function (This:Pefi_block_io_crypto_protocol;ConfigurationCount:qword;ConfigurationTable:Pefi_block_io_crypto_configuration_table_entry;var ResultingTable:efi_block_io_crypto_response_configuration_entry):efi_status;cdecl;
     efi_block_io_crypto_get_configuration=function (This:Pefi_block_io_crypto_protocol;StartIndex:qword;ConfigurationCount:qword;KeyOwnerGuid:Pefi_guid;var ConfigurationTable:efi_block_io_crypto_response_configuration_entry):efi_status;cdecl;
     efi_block_io_crypto_token=record
                               event:efi_event;
                               TransactionStatus:efi_status;
                               end;
     efi_block_io_crypto_read_extended=function (This:Pefi_block_io_crypto_protocol;MediaId:dword;lba:efi_lba;var Token:efi_block_io_crypto_token;BufferSize:qword;var Buffer;Index:Pqword;CryptoIvInput:Pointer):efi_status;cdecl;
     efi_block_io_crypto_write_extended=function (This:Pefi_block_io_crypto_protocol;MediaId:dword;lba:efi_lba;var Token:efi_block_io_crypto_token;BufferSize:qword;Buffer:Pointer;Index:Pqword;CryptoIvInput:Pointer):efi_status;cdecl;
     efi_block_io_crypto_flush=function (This:Pefi_block_io_crypto_protocol;var Token:efi_block_io_crypto_token):efi_status;cdecl;
     efi_block_io_crypto_protocol=record 
                                  Media:^efi_block_io_media;
                                  Reset:efi_block_io_crypto_reset;
                                  GetCapabilities:efi_block_io_crypto_get_capabilities;
                                  SetConfiguration:efi_block_io_crypto_set_configuration;
                                  GetConfiguration:efi_block_io_crypto_get_configuration;
                                  ReadExtended:efi_block_io_crypto_read_extended;
                                  WriteExtended:efi_block_io_crypto_write_extended;
                                  FlushBlocks:efi_block_io_crypto_flush;
                                  end;
     Pefi_erase_block_protocol=^efi_erase_block_protocol;
     efi_erase_block_token=record
                           Event:efi_event;
                           TransactionStatus:efi_status;
                           end;
     efi_block_erase=function (This:Pefi_block_io_protocol;MediaId:dword;LBA:efi_lba;var Token:efi_erase_block_token;Size:Natuint):Pefi_status;cdecl;
     efi_erase_block_protocol=record
                              Revision:qword;
                              EraseLengthGranularity:dword;
                              EraseBlocks:efi_block_erase;
                              end;
     Pefi_ata_pass_thru_protocol=^efi_ata_pass_thru_protocol;
     efi_ata_pass_thru_mode=record
                            Attributes:dword;
                            IoAlign:dword;
                            end;
     efi_ata_status_block=record
                          Reserved1:array[1..2] of byte;
                          AtaStatus:byte;
                          AtaError:byte;
                          AtaSectorNumber:byte;
                          AtaCylinderLow:byte;
                          AtaCylinderHigh:byte;
                          AtaDeviceHead:byte;
                          AtaSectorNumberExp:byte;
                          AtaCylinderLowExp:byte;
                          AtaCylinderHighExp:byte;
                          Reserved2:byte;
                          AtaSectorCount:byte;
                          AtaSectorCountExp:byte;
                          Reserved3:array[1..6] of byte;
                          end;
     efi_ata_command_block=record
                          Reserved1:array[1..2] of byte;
                          Atacommand:byte;
                          AtaFeatures:byte;
                          AtaSectorNumber:byte;
                          AtaCylinderLow:byte;
                          AtaCylinderHigh:byte;
                          AtaDeviceHead:byte;
                          AtaSectorNumberExp:byte;
                          AtaCylinderLowExp:byte;
                          AtaCylinderHighExp:byte;
                          AtaFeaturesExp:byte;
                          AtaSectorCount:byte;
                          AtaSectorCountExp:byte;
                          Reserved2:array[1..6] of byte;
                          end;
     efi_ata_pass_thru_cmd_protocol=byte;
     efi_ata_pass_thru_length=byte;
     efi_ata_pass_thru_command_packet=record
                                      Asb:^efi_ata_status_block;
                                      Acb:^efi_ata_command_block;
                                      Timeout:qword;
                                      InDataBuffer:Pointer;
                                      OutDataBuffer:Pointer;
                                      InTransferLength:dword;
                                      OutTransferLength:dword;
                                      Protocol:efi_ata_pass_thru_cmd_protocol;
                                      Length:efi_ata_pass_thru_length;
                                      end;
     efi_ata_pass_thru_passthru=function (This:Pefi_ata_pass_thru_protocol;Port:word;PortMultiplierPort:word;var Packet:efi_ata_pass_thru_command_packet;Event:efi_event):efi_status;cdecl;
     efi_ata_pass_thru_get_next_port=function (This:Pefi_ata_pass_thru_protocol;var Port:word):efi_status;cdecl;
     efi_ata_pass_thru_get_next_device=function (This:Pefi_ata_pass_thru_protocol;Port:word;var PortMultiplierPort:word):efi_status;cdecl;
     efi_ata_pass_thru_build_device_path=function (This:Pefi_ata_pass_thru_protocol;Port,PortMultiplierPort:word;var DevicePath:Pefi_device_path_protocol):efi_status;cdecl;
     efi_ata_pass_thru_get_device=function (This:Pefi_ata_pass_thru_protocol;DevicePath:Pefi_device_path_protocol;var Port,PortMultiplierPort:word):efi_status;cdecl;
     efi_ata_pass_thru_reset_port=function (This:Pefi_ata_pass_thru_protocol;Port:Pword):efi_status;cdecl;
     efi_ata_pass_thru_reset_device=function (This:Pefi_ata_pass_thru_protocol;Port,PortMultiplierPort:word):efi_status;cdecl;
     efi_ata_pass_thru_protocol=record
                                Mode:^efi_ata_pass_thru_mode;
                                Passthru:efi_ata_pass_thru_passthru;
                                GetNextPort:efi_ata_pass_thru_get_next_port;
                                GetNextDevice:efi_ata_pass_thru_get_next_device;
                                BuildDevicePath:efi_ata_pass_thru_build_device_path;
                                GetDevice:efi_ata_pass_thru_get_device;
                                ResetPort:efi_ata_pass_thru_reset_port;
                                ResetDevice:efi_ata_pass_thru_reset_device;
                                end;
    Pefi_storage_security_command_protocol=^efi_storage_security_command_protocol;
    efi_storage_security_receive_data=function (This:Pefi_storage_security_command_protocol;MediaId:dword;Timeout:qword;SecurityProtocolId:byte;SecurityProtocolSpecificData:word;PayloadBufferSize:Natuint;var PayloadBuffer;var PayloadTransferSize:Natuint):efi_status;cdecl;
    efi_storage_security_send_data=function (This:Pefi_storage_security_command_protocol;MediaId:dword;Timeout:qword;SecurityProtocolId:byte;SecurityProtocolSpecificData:word;PayloadBufferSize:Natuint;PayloadBuffer:Pointer):efi_status;cdecl;
    efi_storage_security_command_protocol=record
                                          ReceiveData:efi_storage_security_receive_data;
                                          SendData:efi_storage_security_send_data;
                                          end;
    Pefi_nvm_express_pass_thru_protocol=^efi_nvm_express_pass_thru_protocol;
    efi_nvm_express_pass_thru_mode=record
                                   Attributes:dword;
                                   IoAlign:dword;
                                   NvmeVersion:dword;
                                   end;
    nvme_cdw0=bitpacked record
              Opcode:0..255;
              FusedOperation:0..3;
              Reserved:0..4194303;
              end;
    efi_nvm_express_command=record
    			    cdw0:nvme_cdw0;
    			    flags:byte;
    			    Nsid,Cdw2,Cdw3,Cdw10,Cdw11,Cdw12,Cdw13,Cdw14,Cdw15:dword;
                            end;
    efi_nvm_express_completion=record
                               DW0,DW1,DW2,DW3:dword;
                               end;
    efi_nvm_express_pass_thur_command_packet=record 
                                             CommandTimeout:qword;
                                             TransferBuffer:Pointer;
                                             TransferLength:dword;
                                             MetaDataBuffer:Pointer;
                                             MetaDataLength:dword;
                                             QueueType:byte;
                                             NvmeCmd:^efi_nvm_express_command;
                                             NvmeCompletion:^efi_nvm_express_completion;
                                             end;
    efi_nvm_express_pass_thru_passthru=function (This:Pefi_nvm_express_pass_thru_protocol;NameSpaceId:dword;var Packet:efi_nvm_express_pass_thur_command_packet;Event:efi_event):efi_status;cdecl;
    efi_nvm_express_pass_thru_get_next_namespace=function (This:Pefi_nvm_express_pass_thru_protocol;var namespaceid:dword):efi_status;cdecl;
    efi_nvm_express_pass_thru_build_device_path=function (This:Pefi_nvm_express_pass_thru_protocol;namespaceid:dword;var DevicePath:Pefi_device_path_protocol):efi_status;cdecl;
    efi_nvm_express_pass_thru_get_namespace=function (This:Pefi_nvm_express_pass_thru_protocol;DevicePath:Pefi_device_path_protocol;var Namespaceid:dword):efi_status;cdecl;
    efi_nvm_express_pass_thru_protocol=record
                                       Mode:^efi_nvm_express_pass_thru_mode;
                                       PassThru:efi_nvm_express_pass_thru_passthru;
                                       GetNextNamespace:efi_nvm_express_pass_thru_get_next_namespace;
                                       BuildDevicePath:efi_nvm_express_pass_thru_build_device_path;
                                       GetNamespace:efi_nvm_express_pass_thru_get_namespace;
                                       end;
    Pefi_sd_mmc_pass_thru_protocol=^efi_sd_mmc_pass_thru_protocol;
    efi_sd_mmc_command_block=record
                             CommandIndex:word;
                             CommandArgument:dword;
                             CommandType:dword;
                             ResponseType:dword; 
                             end;
    efi_sd_mmc_status_block=record
                            Resp0,Resp1,Resp2,Resp3:dword;
                            end;
    efi_sd_mmc_command_type=(SdMmcCommandTypeBc,SdMmcCommandTypeBcr,SdMmcCommandTypeAc,SdMmcCommandTypeAdtc);
    efi_sd_mmc_response_type=(SdMmcResponceTypeR1,SdMmcResponceTypeR1b,SdMmcResponceTypeR2,SdMmcResponceTypeR3,SdMmcResponceTypeR4,SdMmcResponceTypeR5,SdMmcResponceTypeR5b,SdMmcResponceTypeR6,SdMmcResponceTypeR7);
    efi_sd_mmc_pass_thru_command_packet=record
                                        SdMmcCmdBlk:^efi_sd_mmc_command_block;
                                        SdMmcStatusBlk:^efi_sd_mmc_status_block;
                                        Timeout:qword;
                                        InDataBuffer,OutDataBuffer:Pointer;
                                        InTransferLength,OutTransferLength:dword;
                                        TransactionStatus:efi_status;
                                        end;
    efi_sd_mmc_pass_thru_passthru=function (This:Pefi_sd_mmc_pass_thru_protocol;Slot:byte;var Packet:efi_sd_mmc_pass_thru_command_packet;Event:efi_event):efi_status;cdecl;
    efi_sd_mmc_pass_thru_get_next_slot=function (This:Pefi_sd_mmc_pass_thru_protocol;var Slot:byte):efi_status;cdecl;
    efi_sd_mmc_pass_thru_build_device_path=function (This:Pefi_sd_mmc_pass_thru_protocol;Slot:byte;var DevicePath:Pefi_device_path_protocol):efi_status;cdecl;
    efi_sd_mmc_pass_thru_get_slot_number=function (This:Pefi_sd_mmc_pass_thru_protocol;DevicePath:Pefi_device_path_protocol;var Slot:byte):efi_status;cdecl;
    efi_sd_mmc_pass_thru_reset_device=function (This:Pefi_sd_mmc_pass_thru_protocol;Slow:byte):efi_status;cdecl;
    efi_sd_mmc_pass_thru_protocol=record
                                  IoAlign:Natuint;
                                  PassThru:efi_sd_mmc_pass_thru_passthru;
                                  GetNextSlot:efi_sd_mmc_pass_thru_get_next_slot;
                                  BuildDevicePath:efi_sd_mmc_pass_thru_build_device_path;
                                  GetSlotNumber:efi_sd_mmc_pass_thru_get_slot_number;
                                  ResetDevice:efi_sd_mmc_pass_thru_reset_device;
                                  end;
    Pefi_ram_disk_protocol=^efi_ram_disk_protocol;
    efi_ram_disk_register_ramdisk=function (RamDiskBase:qword;RamDiskSize:qword;RamDiskType:Pefi_guid;ParentDevicePath:Pefi_device_path;var DevicePath:Pefi_device_path_protocol):efi_status;cdecl;
    efi_ram_disk_unregister_ramdisk=function (DevicePath:Pefi_device_path_protocol):efi_status;cdecl;
    efi_ram_disk_protocol=record
                          Register:efi_ram_disk_register_ramdisk;
                          Unregister:efi_ram_disk_unregister_ramdisk;
                          end;
    Pefi_partition_info_protocol=^efi_partition_info_protocol;
    efi_partition_info_protocol=packed record
                                Revision:dword;
                                efitype:dword;
                                System:byte;
                                Reserved:array[1..7] of byte;
                                case Boolean of 
                                True:(mbr:mbr_partition_record);
                                False:(gpt:efi_partition_entry);
                                end;
    Pefi_nvdimm_label_protocol=^efi_nvdimm_label_protocol;
    efi_nvdimm_label_storage_information=function (This:Pefi_nvdimm_label_protocol;var SizeOfLabelStorageArea:dword;var MaxTransferLength:dword):efi_status;cdecl;
    efi_nvdimm_label_storage_read=function (const This:Pefi_nvdimm_label_protocol;Offset:dword;TransferLength:dword;var LabelData:byte):efi_status;cdecl;
    efi_nvdimm_label_storage_write=function (const This:Pefi_nvdimm_label_protocol;Offset:dword;TransferLength:dword;LabelData:Pbyte):efi_status;cdecl;
    efi_nvdimm_label_protocol=record
                              LabelStorageInformation:efi_nvdimm_label_storage_information;
                              LabelStorageRead:efi_nvdimm_label_storage_read;
                              LabelStorageWrite:efi_nvdimm_label_storage_write;
                              end;
    Pefi_ufs_device_config_protocol=^efi_ufs_device_config_protocol;
    efi_ufs_device_config_rw_descriptor=function (This:Pefi_ufs_device_config_protocol;efiRead:boolean;DescId,Index,Selector:byte;var Descriptor:byte;var DecSize:dword):efi_status;cdecl;
    efi_ufs_device_rw_flag=function (This:Pefi_ufs_device_config_protocol;efiRead:boolean;FlagId:byte;var Flag:byte):efi_status;cdecl;
    efi_ufs_device_rw_attribute=function (This:Pefi_ufs_device_config_protocol;efiRead:boolean;AttrId,Index,Selector:byte;var efiattribute:byte;var AttrSize:dword):efi_status;cdecl;
    efi_ufs_device_config_protocol=record
                                   RwUfsDescriptor:efi_ufs_device_config_rw_descriptor;
                                   RwUfsFlag:efi_ufs_device_rw_flag;
                                   RwUfsAttribute:efi_ufs_device_rw_attribute;
                                   end;
{User Defined Types}
    efi_file_system_list=record
                         file_system_content:^Pefi_simple_file_system_protocol;
                         file_system_count:natuint;
                         end;
    efi_file_system_list_ext=record
                         fsrcontent:^Pefi_simple_file_system_protocol;
                         fsrcount:natuint;
                         fsrwcontent:^Pefi_simple_file_system_protocol;
                         fsrwcount:natuint;
                         end;
    efi_disk_list=record
                  disk_content:^Pefi_disk_io_protocol;
                  disk_block_content:^Pefi_block_io_protocol;
                  disk_count:natuint;
                  end;
    efi_partition_entry_list=record
                             epe_content:array[1..128] of efi_partition_entry;
                             epe_count:natuint;
                             end;
{User Defined End}
const unused_entry_guid:efi_guid=(data1:$00000000;data2:$0000;data3:$0000;data4:($00,$00,$00,$00,$00,$00,$00,$00));
      efi_system_partition_guid:efi_guid=(data1:$C12A7328;data2:$F81F;data3:$11D2;data4:($BA,$4B,$00,$A0,$C9,$3E,$C9,$3B));
      partition_containing_a_legacy_mbr_guid:efi_guid=(data1:$024DEE41;data2:$33E7;data3:$11D3;data4:($9D,$69,$00,$08,$C7,$81,$F3,$9F));
      system_restart_guid:efi_guid=(data1:$C14A7398;data2:$2819;data3:$4DF2;data4:($BA,$4F,$00,$A0,$C4,$3F,$C9,$4A));
      evt_timer:dword=$80000000;
      evt_runtime:dword=$40000000;
      evt_notify_wait:dword=$00000100;
      evt_notify_signal:dword=$00000200;
      evt_signal_exit_boot_services=$00000201;
      evt_signal_virtual_address_change=$60000202;
      tpl_application=4;
      tpl_callback=8;
      tpl_notify=16;
      tpl_high_level=31;
      efi_loaded_image_protocol_guid:efi_guid=(data1:$5B1B31A1;data2:$9562;data3:$11D2;data4:($8E,$3F,$00,$A0,$C9,$69,$72,$3B));
      efi_loaded_image_device_path_protocol_guid:efi_guid=(data1:$BC62157E;data2:$3E33;data3:$4FEC;data4:($99,$20,$2D,$3B,$36,$D7,$50,$DF));
      efi_device_path_protocol_guid:efi_guid=(data1:$09576E91;data2:$6D3F;data3:$11D2;data4:($8E,$39,$00,$A0,$C9,$69,$72,$3B));
      efi_device_path_utilities_protocol_guid:efi_guid=(data1:$0379BE4E;data2:$D706;data3:$437D;data4:($B0,$37,$ED,$B8,$2F,$B7,$72,$A4));
      efi_device_path_to_text_protocol_guid:efi_guid=(data1:$8B843E20;data2:$8132;data3:$4852;data4:($90,$CC,$55,$1A,$4E,$4A,$7F,$1C));
      efi_device_path_from_text_protocol_guid:efi_guid=(data1:$05C99A21;data2:$C70F;data3:$4AD2;data4:($8A,$5F,$35,$DF,$33,$43,$F5,$1E));
      efi_driver_binding_protocol_guid:efi_guid=(data1:$18A031AB;data2:$B443;data3:$4D1A;data4:($A5,$C0,$0C,$09,$26,$1E,$9F,$71));
      efi_platform_driver_override_protocol_guid:efi_guid=(data1:$6B30C738;data2:$A391;data3:$11D4;data4:($9A,$3B,$00,$90,$27,$3F,$C1,$4D));
      efi_bus_specific_driver_override_protocol_guid:efi_guid=(data1:$3BC1B285;data2:$8A15;data3:$4A82;data4:($AA,$BF,$4D,$7D,$13,$FB,$32,$65));
      efi_driver_diagnostics_protocol_guid:efi_guid=(data1:$4D330321;data2:$025F;data3:$4AAC;data4:($90,$D8,$5E,$D9,$00,$17,$3B,$63));
      efi_component_name2_protocol_guid:efi_guid=(data1:$6A7A5CFF;data2:$E8D9;data3:$4F70;data4:($BA,$DA,$75,$AB,$30,$25,$CE,$14));
      efi_platform_to_driver_configuration_protocol_guid:efi_guid=(data1:$642CD590;data2:$8059;data3:$4C0A;data4:($A9,$58,$C5,$EC,$07,$D2,$3C,$4B));
      efi_driver_supported_efi_version_protocol_guid:efi_guid=(data1:$5C198761;data2:$16A8;data3:$4E69;data4:($97,$2C,$89,$D6,$79,$54,$F8,$1D));
      efi_driver_family_override_protocol_guid:efi_guid=(data1:$B1EE129E;data2:$DA36;data3:$4181;data4:($91,$F8,$04,$A4,$92,$37,$66,$A7));
      efi_driver_health_protocol_guid:efi_guid=(data1:$2A534210;data2:$9280;data3:$41D8;data4:($AE,$79,$CA,$DA,$01,$A2,$B1,$27));
      efi_adapter_information_protocol_guid:efi_guid=(data1:$E5DD1403;data2:$D622;data3:$C24E;data4:($84,$88,$C7,$1B,$17,$F5,$E8,$02));
      efi_adapter_info_media_state_guid:efi_guid=(data1:$D7C74207;data2:$A831;data3:$4A26;data4:($B1,$F5,$D1,$93,$06,$5C,$E8,$B6));
      efi_adapter_info_network_boot_guid:efi_guid=(data1:$1FBD2690;data2:$4130;data3:$41E5;data4:($94,$AC,$D2,$CF,$03,$7F,$B3,$7C));
      efi_adapter_info_san_mac_address_guid:efi_guid=(data1:$114DA5EF;data2:$2CF1;data3:$4E12;data4:($9B,$BB,$C4,$70,$B5,$52,$05,$D9));
      efi_adapter_info_undi_ipv6_support_guid:efi_guid=(data1:$4BD56BE3;data2:$4975;data3:$4D8A;data4:($A0,$AD,$C4,$91,$20,$4B,$5D,$4D));
      efi_adapter_info_media_type_guid:efi_guid=(data1:$8484472F;data2:$71EC;data3:$411A;data4:($B3,$9C,$62,$CD,$94,$D9,$91,$6E));
      efi_adapter_info_cdat_type_guid:efi_guid=(data1:$77AF24D1;data2:$B6F0;data3:$42B9;data4:($83,$F5,$8F,$E6,$E8,$3E,$B6,$F0));
      efi_simple_text_input_ex_protocol_guid:efi_guid=(data1:$DD9E7534;data2:$7762;data3:$4698;data4:($8C,$14,$F5,$85,$17,$A6,$25,$AA));
      efi_simple_pointer_protocol_guid:efi_guid=(data1:$31878C87;data2:$0B75;data3:$11D5;data4:($9A,$4F,$00,$90,$27,$3F,$C1,$4D));
      efi_absolute_pointer_protocol_guid:efi_guid=(data1:$8D59D32B;data2:$C655;data3:$4AE9;data4:($9B,$15,$F2,$59,$04,$99,$2A,$43));
      efi_serial_to_protocol_guid:efi_guid=(data1:$BB25CF6F;data2:$F1D4;data3:$11D2;data4:($9A,$0C,$00,$90,$27,$3F,$C1,$FD));
      efi_serial_terminal_device_type_guid:efi_guid=(data1:$6AD9A60F;data2:$5815;data3:$4C7C;data4:($8A,$10,$50,$53,$D2,$BF,$7A,$1B));
      efi_graphics_output_protocol_guid:efi_guid=(data1:$9042A9DE;data2:$23DC;data3:$4A38;data4:($96,$FB,$7A,$DE,$D0,$80,$51,$6A));
      efi_load_file_protocol_guid:efi_guid=(data1:$56EC3091;data2:$954C;data3:$11D2;data4:($8E,$3F,$00,$A0,$C9,$69,$72,$3B));
      efi_load_file2_protocol_guid:efi_guid=(data1:$4006C0C1;data2:$FCB3;data3:$403E;data4:($99,$6D,$4A,$6C,$87,$24,$E0,$6D));
      efi_simple_file_system_protocol_guid:efi_guid=(data1:$964E5B22;data2:$6459;data3:$11D2;data4:($8E,$39,$00,$A0,$C9,$69,$72,$3B));
      efi_file_info_id:efi_guid=(data1:$09576E92;data2:$6D3F;data3:$11D2;data4:($8E,$39,$00,$A0,$C9,$69,$72,$3B));
      efi_file_system_info_id:efi_guid=(data1:$09576E93;data2:$6D3F;data3:$11D2;data4:($8E,$39,$00,$A0,$C9,$69,$72,$3B));
      efi_file_system_volume_label_id:efi_guid=(data1:$DB47D7D3;data2:$FE81;data3:$11D3;data4:($9A,$35,$0,$90,$27,$3F,$C1,$4D));
      efi_tape_to_protocol_guid:efi_guid=(data1:$1E93E633;data2:$D65A;data3:$459E;data4:($AB,$84,$93,$D9,$EC,$26,$6D,$18));
      efi_disk_io_protocol_guid:efi_guid=(data1:$CE345171;data2:$BA0B;data3:$11D2;data4:($8E,$4F,$00,$A0,$C9,$69,$72,$3B));
      efi_disk_io2_protocol_guid:efi_guid=(data1:$151C8EAE;data2:$7F2C;data3:$472C;data4:($9E,$54,$98,$28,$19,$4F,$6A,$88));
      efi_block_io_protocol_guid:efi_guid=(data1:$964E5B21;data2:$6459;data3:$11D2;data4:($8E,$39,$00,$A0,$C9,$69,$72,$3B));
      efi_block_io2_protocol_guid:efi_guid=(data1:$A77B2472;data2:$E282;data3:$4E9F;data4:($A2,$45,$C2,$C0,$E2,$7B,$BC,$C1));
      efi_block_io_crypto_protocol_guid:efi_guid=(data1:$A00490BA;data2:$3F1A;data3:$4B4C;data4:($AB,$90,$4F,$A9,$97,$26,$A1,$E8));
      efi_block_io_crypto_algo_guid_aes_xts:efi_guid=(data1:$2F87BA6A;data2:$5C04;data3:$4385;data4:($A7,$80,$F3,$BF,$78,$A9,$7B,$EC));
      efi_block_io_crypto_algo_guid_aes_cbc_microsoft_bitlocker:efi_guid=(data1:$689E4CB2;data2:$70BF;data3:$4CF3;data4:($88,$BB,$33,$B3,$18,$26,$86,$70));
      efi_erase_block_protocol_guid:efi_guid=(data1:$95A9A93E;data2:$A86E;data3:$4926;data4:($AA,$EF,$99,$18,$E7,$72,$D9,$87));
      efi_ata_pass_thru_protocol_guid:efi_guid=(data1:$1D3DE7F0;data2:$0807;data3:$424F;data4:($AA,$69,$11,$A5,$4E,$19,$A4,$6F));
      efi_storage_security_command_protocol_guid:efi_guid=(data1:$C88B0B6D;data2:$0DFC;data3:$49A7;data4:($9C,$B4,$49,$07,$4B,$4C,$3A,$78));
      efi_nvm_express_pass_thru_protocol_guid:efi_guid=(data1:$52C78312;data2:$8EDC;data3:$4233;data4:($98,$F2,$1A,$1A,$A5,$E3,$88,$A5));
      efi_sd_mmc_pass_thru_protocol_guid:efi_guid=(data1:$716EF0D9;data2:$FF83;data3:$4F69;data4:($81,$E9,$51,$8B,$D3,$9A,$8E,$70));
      efi_ram_disk_protocol_guid:efi_guid=(data1:$AB38A0BF;data2:$6873;data3:$44A9;data4:($87,$E6,$D4,$EB,$56,$14,$84,$49));
      efi_partition_info_protocol_guid:efi_guid=(data1:$8CF2F62C;data2:$BC9B;data3:$4821;data4:($80,$8D,$EC,$9E,$C4,$21,$A1,$A0));
      efi_nvdimm_label_protocol_guid:efi_guid=(data1:$D40B6B80;data2:$97D5;data3:$4282;data4:($BB,$1D,$22,$3A,$16,$91,$80,$58));
      efi_ufs_device_config_guid:efi_guid=(data1:$B81BFAB0;data2:$0EB3;data3:$4CF9;data4:($84,$65,$7F,$A9,$86,$36,$16,$64));
      efi_success:natuint=0;
      efi_load_error:natuint=1;
      efi_invaild_parameter:natuint=2;
      efi_unsupported:natuint=3;
      efi_bad_buffer_size:natuint=4;
      efi_buffer_too_small:natuint=5;
      efi_not_ready:natuint=6;
      efi_device_error:natuint=7;
      efi_write_protected:natuint=8;
      efi_out_of_resources:natuint=9;
      efi_volume_corrupted:natuint=10;
      efi_volume_full:natuint=11;
      efi_no_media:natuint=12;
      efi_media_changed:natuint=13;
      efi_not_found:natuint=14;
      efi_access_denied:natuint=15;
      efi_no_response:natuint=-16;
      efi_no_mapping:natuint=-17;
      efi_timeout:natuint=-18;
      efi_not_started:natuint=-19;
      efi_already_started:natuint=-20;
      efi_aborted:natuint=-21;
      efi_icmp_error:natuint=-22;
      efi_tftp_error:natuint=-23;
      efi_protocol_error:natuint=-24;
      efi_incompatible_version:natuint=-25;
      efi_security_violation:natuint=-26;
      efi_crc_error:natuint=27;
      efi_end_of_media:natuint=28;
      efi_end_of_file:natuint=31;
      efi_invaild_language:natuint=32;
      efi_compromised_data:natuint=33;
      efi_ip_address_conflict:natuint=34;
      efi_http_error:natuint=35;
      efi_warn_unknown_glyph:natuint=1;
      efi_warn_delete_failure:natuint=2;
      efi_warn_write_failure:natuint=3;
      efi_warn_buffer_too_small:natuint=4;
      efi_warn_stale_data:natuint=5;
      efi_warn_file_system:natuint=6;
      efi_warn_reset_required:natuint=7;
      efi_black=$0;
      efi_blue=$1;
      efi_green=$2;
      efi_cyan=$3;
      efi_red=$4;
      efi_magenta=$5;
      efi_brown=$6;
      efi_lightgrey=$7;
      efi_bright=$8;
      efi_darkgrey=$8;
      efi_lightblue=$9;
      efi_lightgreen=$A;
      efi_lightcyan=$B;
      efi_lightred=$C;
      efi_lightmagenta=$D;
      efi_yellow=$E;
      efi_white=$F;
      efi_bck_black=$0;
      efi_bck_blue=$1;
      efi_bck_green=$2;
      efi_bck_cyan=$3;
      efi_bck_red=$4;
      efi_bck_magenta=$5;
      efi_bck_brown=$6;
      efi_bck_lightgrey=$7;
      efi_shift_state_vaild=$80000000;
      efi_right_shift_pressed=$00000001;
      efi_left_shift_pressed=$00000002;
      efi_right_control_pressed=$00000004;
      efi_left_control_pressed=$00000008;
      efi_right_alt_pressed=$00000010;
      efi_left_alt_pressed=$00000020;
      efi_right_logo_pressed=$00000040;
      efi_left_logo_pressed=$00000080;
      efi_menu_key_pressed=$00000100;
      efi_sys_req_pressed=$00000200;
      efi_toggle_state_vaild=$80;
      efi_key_state_exposed=$40;
      efi_scroll_lock_active=$01;
      efi_num_lock_active=$02;
      efi_caps_lock_active=$04;
      efi_absp_supportsaltactive=$00000001;
      efi_absp_supportspressureasZ=$00000002;
      efi_serial_clear_to_send=$0010;
      efi_serial_data_set_ready=$0020;
      efi_serial_ring_indicate=$0040;
      efi_serial_carrier_detect=$0080;
      efi_serial_request_to_send=$0002;
      efi_serial_data_terminal_ready=$0001;
      efi_serial_input_buffer_empty=$0100;
      efi_serial_output_buffer_empty=$0200;
      efi_serial_hardware_loopback_enable=$1000;
      efi_serial_software_loopback_enable=$2000;
      efi_serial_hardware_flow_control_enable=$4000;
      efi_simple_file_system_protocol_revision=$00010000;
      efi_file_protocol_revision=$00010000;
      efi_file_protocol2_revision=$00020000;
      efi_file_protocol_latest_revision=efi_file_protocol2_revision;
      efi_file_mode_read=$0000000000000001;
      efi_file_mode_write=$0000000000000002;
      efi_file_mode_create=$8000000000000000;
      efi_file_read_only=$0000000000000001;
      efi_file_hidden=$0000000000000002;
      efi_file_system=$0000000000000004;
      efi_file_reserved=$0000000000000008;
      efi_file_directory=$0000000000000010;
      efi_file_archive=$0000000000000020;
      efi_file_valid_attr=$0000000000000037;
      efi_disk_io_protocol_revision=$00010000;
      efi_disk_io2_protocol_revision=$00020000;
      efi_block_io_protocol_revision2:dword=$00020001;
      efi_block_io_protocol_revision3:dword=(2 shl 16) or 31;
      efi_block_io_crypto_index_any:qword=$FFFFFFFFFFFFFF;
      efi_erase_block_protocol_revision:dword=(2 shl 16) or 60;
      efi_ata_pass_thru_attributes_physical:word=$0001;
      efi_ata_pass_thru_attributes_logical:word=$0002;
      efi_ata_pass_thru_attributes_nonblockio:word=$0004;
      efi_ata_pass_thru_protocol_ata_hardware_reset:byte=$00;
      efi_ata_pass_thru_protocol_ata_software_reset:byte=$01;
      efi_ata_pass_thru_protocol_ata_non_data:byte=$02;
      efi_ata_pass_thru_protocol_pio_data_in:byte=$04;
      efi_ata_pass_thru_protocol_pio_data_out:byte=$05;
      efi_ata_pass_thru_protocol_dma:byte=$06;
      efi_ata_pass_thru_protocol_dma_queued:byte=$07;
      efi_ata_pass_thru_protocol_device_diagnostic:byte=$08;
      efi_ata_pass_thru_protocol_device_reset:byte=$09;
      efi_ata_pass_thru_protocol_umda_data_in:byte=$0A;
      efi_ata_pass_thru_protocol_umda_data_out:byte=$0B;
      efi_ata_pass_thru_protocol_fpdma:byte=$0C;
      efi_ata_pass_thru_protocol_return_response:byte=$FF;
      efi_ata_pass_thru_length_bytes:byte=$80;
      efi_ata_pass_thru_length_mask:byte=$70;
      efi_ata_pass_thru_length_no_data_transfer:byte=$00;
      efi_ata_pass_thru_length_features:byte=$10;
      efi_ata_pass_thru_length_sector_count:byte=$20;
      efi_ata_pass_thru_length_tpsiu:byte=$30;
      efi_ata_pass_thru_length_count:byte=$0F;
      efi_partition_info_protocol_revision:dword=$00010000;
      partition_type_other:byte=$00;
      partition_type_mbr:byte=$01;
      partition_type_gpt:byte=$02;
      efi_nvm_express_pass_thru_attributes_physical:word=$0001;
      efi_nvm_express_pass_thru_attributes_logical:word=$0002;
      efi_nvm_express_pass_thru_attributes_nonblockio:word=$0004;
      efi_nvm_express_pass_thru_attributes_cmd_set_nvm:word=$0008;
      cdw2_vaild:byte=$01;
      cdw3_vaild:byte=$02;
      cdw10_vaild:byte=$04;
      cdw11_vaild:byte=$08;
      cdw12_vaild:byte=$10;
      cdw13_vaild:byte=$20;
      cdw14_vaild:byte=$40;
      cdw15_vaild:byte=$80;   
      fs_signature:qword=$5D47291AD7E3F2B1;
      capsule_flags_persist_across_reset:dword=$00010000;
      capsule_flags_populate_system_table:dword=$00020000;
      capsule_flags_initiate_reset:dword=$00030000;

function efi_error(status:efi_status):boolean;cdecl;
procedure efi_console_clear_screen(SystemTable:Pefi_system_table);cdecl;
procedure efi_console_output_string(SystemTable:Pefi_system_table;outputstring:PWideChar);cdecl;
procedure efi_set_watchdog_timer_to_null(SystemTable:Pefi_system_table);cdecl;
procedure efi_console_read_string(SystemTable:Pefi_system_table;var ReadString:PWideChar);cdecl;
procedure efi_console_enable_mouse(SystemTable:Pefi_system_table);cdecl;
procedure efi_console_set_global_colour(SystemTable:Pefi_system_table;backgroundcolour:byte;textcolour:byte);cdecl;
procedure efi_console_set_cursor_position(SystemTable:Pefi_system_table;column,row:natuint);cdecl;
procedure efi_console_get_cursor_position(SystemTable:Pefi_system_table;var column,row:natuint);cdecl;
procedure efi_console_get_max_row_and_max_column(SystemTable:Pefi_system_table;debug:boolean);cdecl;
procedure efi_console_output_string_with_colour(SystemTable:Pefi_system_table;Outputstring:PWideChar;backgroundcolour:byte;textcolour:byte);cdecl;
procedure efi_console_read_string_with_colour(SystemTable:Pefi_system_table;var ReadString:PWideChar;backgroundcolour:byte;textcolour:byte);cdecl;
function efi_console_timer_mouse_blink(Event:efi_event;Context:Pointer):efi_status;cdecl;
procedure efi_console_enable_mouse_blink(SystemTable:Pefi_system_table;enableblink:boolean;blinkmilliseconds:qword);cdecl;
function efi_generate_guid(seed1,seed2:qword):efi_guid;cdecl;
function efi_generate_fat32_volumeid(seed1:dword):dword;cdecl;
function efi_list_all_file_system(SystemTable:Pefi_system_table;isreadonly:byte):efi_file_system_list;cdecl;
function efi_list_all_file_system_ext(SystemTable:Pefi_system_table):efi_file_system_list_ext;cdecl;
function efi_detect_disk_write_ability(SystemTable:Pefi_system_table):efi_disk_list;cdecl;
procedure efi_install_cdrom_to_hard_disk(systemtable:Pefi_system_table;filesystemlist:efi_file_system_list;disklist:efi_disk_list;cdromindex,harddiskindex:natuint);cdecl;
procedure efi_install_cdrom_to_hard_disk_stage2(systemtable:Pefi_system_table;efslext:efi_file_system_list_ext;inscd,insdisk:natuint;const efipart:boolean);cdecl;
procedure efi_system_restart_information_off(systemtable:Pefi_system_table;var mybool:boolean);cdecl;
function efi_disk_empty_list(systemTable:Pefi_system_table):efi_disk_list;cdecl;
function efi_disk_tydq_get_fs_list(systemTable:Pefi_system_table):efi_disk_list;cdecl;
procedure efi_disk_tydq_set_fs(systemTable:Pefi_system_table;disknumber:natuint);cdecl;

var maxcolumn:Natuint=80;
    maxrow:Natuint=25;
    currentcolumn:Natuint=0;
    currentrow:Natuint=0;
    consolebck:byte=efi_bck_black;
    consoletex:byte=efi_lightgrey;
    Cursorblinkevent:efi_event=nil;
    CursorblinkVisible:boolean=false;
    content:array[1..268435456] of byte;
    mbr,rmbr:master_boot_record;
    gpt,rgpt1,rgpt2:efi_gpt_header;
    epe:efi_partition_entry_list;
    fat32h:fat32_header;
    fat32fs:fat32_file_system_info;

implementation

function efi_error(status:efi_status):boolean;cdecl;[public,alias:'EFI_ERROR'];
begin
 if(natint(status)>=0) then efi_error:=false else if(natint(status)<0) then efi_error:=true;
end;
procedure efi_console_clear_screen(SystemTable:Pefi_system_table);cdecl;[public,alias:'EFI_CONSOLE_CLEAR_SCREEN'];
begin
 SystemTable^.ConOut^.ClearScreen(SystemTable^.ConOut);
 currentcolumn:=0; currentrow:=0;
end;
procedure efi_console_output_string(SystemTable:Pefi_system_table;outputstring:PWideChar);cdecl;[public,alias:'EFI_CONSOLE_OUTPUT_STRING'];
var mychar:array[1..2] of WideChar;
    i,len:Natuint;
begin
 SystemTable^.ConOut^.SetAttribute(SystemTable^.ConOut,consolebck shl 4+consoletex);
 i:=1; len:=wstrlen(outputstring)-1;
 while(i<=len+1) do
  begin
   if(i<=len) then
    begin
     if((outputstring+i-1)^=#13) and ((outputstring+i)^=#10) then 
      begin
       mychar[1]:=(outputstring+i-1)^;
       mychar[2]:=#0;
       SystemTable^.ConOut^.OutputString(SystemTable^.ConOut,@mychar);
       mychar[1]:=(outputstring+i)^;
       mychar[2]:=#0;
       SystemTable^.ConOut^.OutputString(SystemTable^.ConOut,@mychar);
       inc(currentrow); currentcolumn:=0; inc(i,2);
      end
     else
      begin
       mychar[1]:=(outputstring+i-1)^;
       mychar[2]:=#0;
       SystemTable^.ConOut^.OutputString(SystemTable^.ConOut,@mychar);
       inc(currentcolumn); inc(i,1);
      end;
    end
   else
    begin
     mychar[1]:=(outputstring+i-1)^;
     mychar[2]:=#0;
     SystemTable^.ConOut^.OutputString(SystemTable^.ConOut,@mychar);
     inc(currentcolumn); inc(i,1);
    end;
   if(currentcolumn>=maxcolumn) then 
    begin
     currentcolumn:=0; inc(currentrow,1);
    end;
   if(currentrow>=maxrow) then 
    begin
     efi_console_clear_screen(SystemTable);
    end;
  end;
 efi_console_set_cursor_position(SystemTable,currentcolumn,currentrow);
end;
procedure efi_console_output_string_with_colour(SystemTable:Pefi_system_table;Outputstring:PWideChar;backgroundcolour:byte;textcolour:byte);cdecl;[public,alias:'EFI_CONSOLE_OUTPUT_STRING_WITH_COLOUR'];
var mychar:array[1..2] of WideChar;
    i,len:Natuint;
begin
 SystemTable^.ConOut^.SetAttribute(SystemTable^.ConOut,backgroundcolour shl 4+textcolour);
 i:=1; len:=wstrlen(outputstring)-1;
 while(i<=len+1) do
  begin
   if(i<=len) then
    begin
     if((outputstring+i-1)^=#13) and ((outputstring+i)^=#10) then 
      begin
       mychar[1]:=(outputstring+i-1)^;
       mychar[2]:=#0;
       SystemTable^.ConOut^.OutputString(SystemTable^.ConOut,@mychar);
       mychar[1]:=(outputstring+i)^;
       mychar[2]:=#0;
       SystemTable^.ConOut^.OutputString(SystemTable^.ConOut,@mychar);
       inc(currentrow); currentcolumn:=0; inc(i,2);
      end
     else
      begin
       mychar[1]:=(outputstring+i-1)^;
       mychar[2]:=#0;
       SystemTable^.ConOut^.OutputString(SystemTable^.ConOut,@mychar);
       inc(currentcolumn); inc(i,1);
      end;
    end
   else
    begin
     mychar[1]:=(outputstring+i-1)^;
     mychar[2]:=#0;
     SystemTable^.ConOut^.OutputString(SystemTable^.ConOut,@mychar);
     inc(currentcolumn); inc(i,1);
    end;
   if(currentcolumn>=maxcolumn) then 
    begin
     currentcolumn:=0; inc(currentrow,1);
    end;
   if(currentrow>=maxrow) then 
    begin
     efi_console_clear_screen(SystemTable);
    end;
  end;
 efi_console_set_cursor_position(SystemTable,currentcolumn,currentrow);
end;
procedure efi_set_watchdog_timer_to_null(SystemTable:Pefi_system_table);cdecl;[public,alias:'EFI_SET_WATCHDOG_TIMER_TO_NULL'];
begin
 SystemTable^.bootservices^.SetWatchDogTimer(0,0,0,nil);
end;
procedure efi_console_read_string(SystemTable:Pefi_system_table;var ReadString:PWideChar);cdecl;[public,alias:'EFI_CONSOLE_READ_STRING'];
var key:efi_input_key;
    waitidx,i,j:natuint;
begin
 SystemTable^.ConOut^.SetAttribute(SystemTable^.ConOut,consolebck shl 4+consoletex);
 Readstring:=getmem(sizeof(WideChar)*1025); i:=0;
 while (True) do
  begin
   inc(i);
   if(i>1024) then break;
   SystemTable^.BootServices^.WaitForEvent(1,@SystemTable^.ConIn^.WaitForKey,waitidx);
   SystemTable^.ConIn^.ReadKeyStroke(SystemTable^.ConIn,key);
   (ReadString+i-1)^:=key.UnicodeChar;
   if((ReadString+i-1)^=#10) or ((ReadString+i-1)^=#13) then
    begin
     (ReadString+i-1)^:=#0; 
     SystemTable^.ConOut^.OutputString(SystemTable^.ConOut,#13#10);
     currentcolumn:=0; inc(currentrow);
     if(currentrow>=maxrow) then efi_console_clear_screen(SystemTable);
     break;
    end
   else if((ReadString+i-1)^=#8) then
    begin
     if(i>0) then
      begin 
       (ReadString+i-1)^:=#0; dec(i);  
       if(i>0) then
        begin
         (ReadString+i-1)^:=#0; dec(i);
         SystemTable^.ConOut^.OutputString(SystemTable^.ConOut,#8);
         if(currentcolumn>0) then dec(currentcolumn) 
          else
           begin
           if(currentrow>0) then dec(currentrow);
           currentcolumn:=maxcolumn-1;
          end;
        end;
      end;
    end
   else
    begin
     inc(currentcolumn);
     if(currentcolumn>=maxcolumn) then
      begin
       currentcolumn:=0; inc(currentrow);
      end;
     if(currentrow>=maxrow) then efi_console_clear_screen(SystemTable);
     SystemTable^.ConOut^.OutputString(SystemTable^.ConOut,@(ReadString+i-1)^);
    end;
  end;
end;
procedure efi_console_read_string_with_colour(SystemTable:Pefi_system_table;var ReadString:PWideChar;backgroundcolour:byte;textcolour:byte);cdecl;[public,alias:'EFI_CONSOLE_READ_STRING_WITH_COLOUR'];
var key:efi_input_key;
    waitidx,i,j:natuint;
begin
 SystemTable^.ConOut^.SetAttribute(SystemTable^.ConOut,backgroundcolour shl 4+textcolour);
 Readstring:=getmem(sizeof(WideChar)*1025); i:=0;
 while (True) do
  begin
   inc(i);
   if(i>1024) then break;
   SystemTable^.BootServices^.WaitForEvent(1,@SystemTable^.ConIn^.WaitForKey,waitidx);
   SystemTable^.ConIn^.ReadKeyStroke(SystemTable^.ConIn,key);
   (ReadString+i-1)^:=key.UnicodeChar;
   if((ReadString+i-1)^=#10) or ((ReadString+i-1)^=#13) then
    begin
     (ReadString+i-1)^:=#0; 
     SystemTable^.ConOut^.OutputString(SystemTable^.ConOut,#13#10);
     currentcolumn:=0; inc(currentrow);
     if(currentrow>=maxrow) then efi_console_clear_screen(SystemTable);
     break;
    end
   else if((ReadString+i-1)^=#8) then
    begin
     if(i>0) then
      begin 
       (ReadString+i-1)^:=#0; dec(i);  
       if(i>0) then
        begin
         (ReadString+i-1)^:=#0; dec(i);
         SystemTable^.ConOut^.OutputString(SystemTable^.ConOut,#8);
         if(currentcolumn>0) then dec(currentcolumn) 
          else
           begin
           if(currentrow>0) then dec(currentrow);
           currentcolumn:=maxcolumn-1;
          end;
        end;
      end;
    end
   else
    begin
     inc(currentcolumn);
     if(currentcolumn>=maxcolumn) then
      begin
       currentcolumn:=0; inc(currentrow);
      end;
     if(currentrow>=maxrow) then efi_console_clear_screen(SystemTable);
     SystemTable^.ConOut^.OutputString(SystemTable^.ConOut,@(ReadString+i-1)^);
    end;
  end;
end;
procedure efi_console_enable_mouse(SystemTable:Pefi_system_table);cdecl;[public,alias:'EFI_CONSOLE_ENABLE_MOUSE'];
begin
 SystemTable^.ConOut^.EnableCursor(SystemTable^.ConOut,true);
end;
procedure efi_console_set_global_colour(SystemTable:Pefi_system_table;backgroundcolour:byte;textcolour:byte);cdecl;[public,alias:'EFI_CONSOLE_SET_GLOAL_COLOUR'];
begin
 consolebck:=backgroundcolour; consoletex:=textcolour;
end;
procedure efi_console_set_cursor_position(SystemTable:Pefi_system_table;column,row:natuint);cdecl;[public,alias:'EFI_CONSOLE_SET_CURSOR_POSITION'];
begin
 SystemTable^.ConOut^.SetCursorPosition(SystemTable^.ConOut,column,row);
end;
procedure efi_console_get_cursor_position(SystemTable:Pefi_system_table;var column,row:natuint);cdecl;[public,alias:'EFI_CONSOLE_GET_CURSOR_POSITION'];
begin
 column:=SystemTable^.ConOut^.Mode^.Cursorcolumn;
 row:=SystemTable^.ConOut^.Mode^.CursorRow;
end;
procedure efi_console_get_max_row_and_max_column(SystemTable:Pefi_system_table;debug:boolean);cdecl;[public,alias:'EFI_CONSOLE_GET_MAX_ROW_AND_MAX_COLUMN'];
var maxc,maxr:Natuint;
    status:natint;
    i:byte;
begin
 i:=0; status:=efi_success;
 SystemTable^.ConOut^.SetMode(SystemTable^.ConOut,0);
 while(True) do
  begin
   inc(i);
   status:=SystemTable^.ConOut^.QueryMode(SystemTable^.ConOut,i-1,maxc,maxr);
   if(debug=true) then
    begin
     SystemTable^.ConOut^.OutputString(SystemTable^.ConOut,'Mode ');
     SystemTable^.ConOut^.OutputString(SystemTable^.ConOut,UIntToPWchar(i-1));
     SystemTable^.ConOut^.OutputString(SystemTable^.ConOut,' ');
     if(status=efi_success) then
      begin
       SystemTable^.ConOut^.OutputString(SystemTable^.ConOut,UIntToPWchar(maxc));
       SystemTable^.ConOut^.OutputString(SystemTable^.ConOut,'-');
       SystemTable^.ConOut^.OutputString(SystemTable^.ConOut,UIntToPWchar(maxr));
       SystemTable^.ConOut^.OutputString(SystemTable^.ConOut,#13#10);
      end
     else if(status<>efi_success) then
      begin
       SystemTable^.ConOut^.OutputString(SystemTable^.ConOut,'Unsupported'+#13#10);
      end;
    end;
   if(i>=SystemTable^.ConOut^.Mode^.MaxMode) then 
    begin
     SystemTable^.ConOut^.SetMode(SystemTable^.ConOut,i-1);
     maxcolumn:=maxc; maxrow:=maxr; 
     break;
    end;
  end;
end;
function efi_console_timer_mouse_blink(Event:efi_event;Context:Pointer):efi_status;cdecl;[public,alias:'EFI_CONSOLE_TIMER_MOUSE_BLINK'];
begin
 if(CursorBlinkVisible=true) then 
  begin 
   Pefi_system_table(Context)^.ConOut^.EnableCursor(Pefi_system_table(Context)^.ConOut,false);
   CursorBlinkVisible:=false;
  end
 else if(CursorBlinkVisible=false) then 
  begin
   Pefi_system_table(Context)^.ConOut^.EnableCursor(Pefi_system_table(Context)^.ConOut,true);
   CursorBlinkVisible:=true;
  end;
end;
procedure efi_console_enable_mouse_blink(SystemTable:Pefi_system_table;enableblink:boolean;blinkmilliseconds:qword);cdecl;[public,alias:'EFI_CONSOLE_ENABLE_MOUSE_BLINK'];
begin
 if(enableblink=true) and (Cursorblinkevent=nil) then
  begin
   SystemTable^.BootServices^.CreateEvent(evt_notify_signal or evt_timer,tpl_callback,@efi_console_timer_mouse_blink,SystemTable,Cursorblinkevent);
   SystemTable^.BootServices^.SetTimer(Cursorblinkevent,TimerPeriodic,blinkmilliseconds*10000);
  end
 else if(enableblink=false) and (Cursorblinkevent<>nil) then
  begin
   SystemTable^.BootServices^.CloseEvent(CursorBlinkEvent);
   Cursorblinkevent:=nil;
  end;
end;
function efi_generate_guid(seed1:qword;seed2:qword):efi_guid;cdecl;[public,alias:'EFI_GENERATE_GUID'];
var resguid:efi_guid;
    i:byte;
    mseed1:dword;
    mseed2,mseed3:word;
    mseed4:array[1..8] of byte;
begin
 mseed1:=seed1 div 4294967296;
 mseed2:=seed1 mod 4294967296 div 65536;
 mseed3:=seed1 mod 4294967296 mod 65536;
 for i:=1 to 8 do mseed4[i]:=seed2 div UintPower(2,(8-i)*8) mod UintPower(2,(i-1)*8);
 resguid.data1:=mseed1 div 13*5+12;
 resguid.data2:=mseed2 div 7*3+17;
 resguid.data3:=mseed3 div 3*2+21;
 for i:=1 to 8 do resguid.data4[i]:=mseed4[i] div 11*8+18;
 efi_generate_guid:=resguid;
end;
function efi_generate_fat32_volumeid(seed1:dword):dword;cdecl;[public,alias:'EFI_GENERATE_FAT32_VOLUMEID'];
var res:dword;
begin
 res:=(seed1+seed1 div 17*9+seed1 div 127*110) div 3;
 efi_generate_fat32_volumeid:=res;
end;
function efi_list_all_file_system(SystemTable:Pefi_system_table;isreadonly:byte):efi_file_system_list;cdecl;[public,alias:'EFI_LIST_ALL_FILE_SYSTEM'];
var totalnum,i:natuint;
    totalbuf:Pefi_handle;
    sfspp:Pointer;
    fsinfo:efi_file_system_info;
    fp:Pefi_file_protocol;
    data:efi_file_system_list;
    realsize:natuint;
begin
 SystemTable^.BootServices^.LocateHandleBuffer(ByProtocol,@efi_simple_file_system_protocol_guid,nil,totalnum,totalbuf);
 data.file_system_content:=allocmem(sizeof(Pointer)*1024); data.file_system_count:=0;
 for i:=1 to totalnum do
  begin
   SystemTable^.BootServices^.HandleProtocol((totalbuf+i-1)^,@efi_simple_file_system_protocol_guid,sfspp);
   Pefi_simple_file_system_protocol(sfspp)^.OpenVolume(Pefi_simple_file_system_protocol(sfspp),fp);
   realsize:=sizeof(efi_file_system_info);
   fp^.GetInfo(fp,@efi_file_system_info_id,realsize,fsinfo);
   if(isreadonly=1) and (fsinfo.ReadOnly=true) then
    begin
     inc(data.file_system_count);
     (data.file_system_content+data.file_system_count-1)^:=Pefi_simple_file_system_protocol(sfspp);
    end
   else if(isreadonly=0) and (fsinfo.ReadOnly=false) then
    begin
     inc(data.file_system_count);
     (data.file_system_content+data.file_system_count-1)^:=Pefi_simple_file_system_protocol(sfspp);
    end
   else if(isreadonly=2) then
    begin
     inc(data.file_system_count);
     (data.file_system_content+data.file_system_count-1)^:=Pefi_simple_file_system_protocol(sfspp);
    end;
  end;
 efi_list_all_file_system:=data;
end;
function efi_list_all_file_system_ext(SystemTable:Pefi_system_table):efi_file_system_list_ext;cdecl;[public,alias:'EFI_LIST_ALL_FILE_SYSTEM_EXT'];
var totalnum,i,j:natuint;
    status:efi_status;
    totalbuf:Pefi_handle;
    sfspp:Pointer;
    fp:Pefi_file_protocol;
    data:efi_file_system_list_ext;
    fsinfo:efi_file_system_info;
    realsize:natuint;
begin
 SystemTable^.BootServices^.LocateHandleBuffer(ByProtocol,@efi_simple_file_system_protocol_guid,nil,totalnum,totalbuf);
 data.fsrcontent:=allocmem(sizeof(Pointer)*1024); data.fsrcount:=0;
 data.fsrwcontent:=allocmem(sizeof(Pointer)*1024); data.fsrwcount:=0;
 for i:=1 to totalnum do
  begin
   SystemTable^.BootServices^.HandleProtocol((totalbuf+i-1)^,@efi_simple_file_system_protocol_guid,sfspp);
   Pefi_simple_file_system_protocol(sfspp)^.OpenVolume(Pefi_simple_file_system_protocol(sfspp),fp);
   realsize:=sizeof(efi_file_system_info);
   fp^.GetInfo(fp,@efi_file_system_info_id,realsize,fsinfo);
   if(fsinfo.ReadOnly) then
    begin
     inc(data.fsrcount);
     (data.fsrcontent+data.fsrcount-1)^:=Pefi_simple_file_system_protocol(sfspp);
     fp^.Close(fp);
    end
   else
    begin
     for j:=1 to 4 do
      begin
       status:=fp^.Open(fp,fp,'\',efi_file_mode_create or efi_file_mode_write or efi_file_mode_read,efi_file_directory);
       if(status=efi_success) then break;
      end;
     if (j<=4) then
      begin
       inc(data.fsrwcount);
       (data.fsrwcontent+data.fsrwcount-1)^:=Pefi_simple_file_system_protocol(sfspp);
       fp^.Delete(fp);
      end
     else fp^.Close(fp);
    end;
  end;
 efi_list_all_file_system_ext:=data;
end;
function efi_detect_disk_write_ability(SystemTable:Pefi_system_table):efi_disk_list;cdecl;[public,alias:'EFI_DETECT_DISK_WRITE_ABILITY'];
var tnum1,tnum2,i:natuint;
    tbuf1,tbuf2:Pefi_handle;
    p1,p2:Pointer;
    mydata1:PNatuint;
    mydata2:natuint;
    reslist:efi_disk_list;
    status:efi_status;
begin
 SystemTable^.BootServices^.LocateHandleBuffer(ByProtocol,@efi_disk_io_protocol_guid,nil,tnum1,tbuf1);
 SystemTable^.BootServices^.LocateHandleBuffer(ByProtocol,@efi_block_io_protocol_guid,nil,tnum2,tbuf2);
 reslist.disk_content:=allocmem(1024*sizeof(Pointer)); 
 reslist.disk_block_content:=allocmem(1024*sizeof(Pointer)); 
 reslist.disk_count:=0;
 for i:=1 to tnum1 do
  begin
   SystemTable^.BootServices^.HandleProtocol((tbuf1+i-1)^,@efi_disk_io_protocol_guid,p1);
   SystemTable^.BootServices^.HandleProtocol((tbuf2+i-1)^,@efi_block_io_protocol_guid,p2);
   mydata1:=allocmem(8);
   mydata1^:=1012;
   Pefi_disk_io_protocol(p1)^.ReadDisk(Pefi_disk_io_protocol(p1),Pefi_block_io_protocol(p2)^.Media^.MediaId,0,8,mydata2);
   status:=Pefi_disk_io_protocol(p1)^.WriteDisk(Pefi_disk_io_protocol(p1),Pefi_block_io_protocol(p2)^.Media^.MediaId,0,8,mydata1);
   if(status=efi_success) then
    begin
     Pefi_disk_io_protocol(p1)^.WriteDisk(Pefi_disk_io_protocol(p1),Pefi_block_io_protocol(p2)^.Media^.MediaId,0,8,@mydata2);
     Pefi_disk_io_protocol(p1)^.ReadDisk(Pefi_disk_io_protocol(p1),Pefi_block_io_protocol(p2)^.Media^.MediaId,0,sizeof(master_boot_record),rmbr);
     Pefi_disk_io_protocol(p1)^.ReadDisk(Pefi_disk_io_protocol(p1),Pefi_block_io_protocol(p2)^.Media^.MediaId,
     Pefi_block_io_protocol(p2)^.Media^.BlockSize,Pefi_block_io_protocol(p2)^.Media^.BlockSize,rgpt1);
     Pefi_disk_io_protocol(p1)^.ReadDisk(Pefi_disk_io_protocol(p1),Pefi_block_io_protocol(p2)^.Media^.MediaId,
     Pefi_block_io_protocol(p2)^.Media^.BlockSize*Pefi_block_io_protocol(p2)^.Media^.LastBlock,
     Pefi_block_io_protocol(p2)^.Media^.BlockSize,rgpt2);
     if(rmbr.Partition[1].OStype=$EE) and ((rgpt1.signature=$5452415020494645) or (rgpt2.signature=$5452415020494645)) then continue;
     inc(reslist.disk_count);
     (reslist.disk_content+reslist.disk_count-1)^:=Pefi_disk_io_protocol(p1);
     (reslist.disk_block_content+reslist.disk_count-1)^:=Pefi_block_io_protocol(p2);
    end;
   freemem(mydata1);
  end;
 efi_detect_disk_write_ability:=reslist;
end;
procedure efi_install_cdrom_to_hard_disk(systemtable:Pefi_system_table;filesystemlist:efi_file_system_list;disklist:efi_disk_list;cdromindex,harddiskindex:natuint);cdecl;[public,alias:'EFI_INSTALL_CDROM_TO_HARD_DISK'];
var i,j,lastblock,blocksize,mediaid,diskwritepos,FirstDataSector:natuint;
    tmpv1,tmpv2,tmpv3:natuint;
    zero:byte;
    sfsp:Pefi_simple_file_system_protocol;
    fp:Pefi_file_protocol;
    efsi:efi_file_system_info;
    readsize:natuint;
    diop:Pefi_disk_io_protocol;
    status:efi_status;
    fssignature:qword;
begin
 sfsp:=(filesystemlist.file_system_content+cdromindex-1)^; zero:=0;
 for i:=1 to disklist.disk_count do
  begin
   diop:=(disklist.disk_content+i-1)^;
   blocksize:=((disklist.disk_block_content+i-1)^)^.Media^.BlockSize;
   lastblock:=((disklist.disk_block_content+i-1)^)^.Media^.LastBlock;
   diskwritepos:=0;
   for j:=1 to 440 do mbr.BootStrapCode[j]:=0;
   mbr.UniqueMbrSignature:=0; mbr.Unknown:=0;
   for j:=1 to 4 do
    begin 
     if(j=1) then
      begin
       mbr.Partition[j].BootIndicator:=$05;
       mbr.Partition[j].StartingCHS[1]:=$00;
       mbr.Partition[j].StartingCHS[2]:=$02;
       mbr.Partition[j].StartingCHS[3]:=$00;
       mbr.Partition[j].OSType:=$EE;
       mbr.Partition[j].EndingCHS[1]:=$FF;
       mbr.Partition[j].EndingCHS[2]:=$FF;
       mbr.Partition[j].EndingCHS[3]:=$FF;
       mbr.Partition[j].StartingLBA:=$00000001;
       mbr.Partition[j].SizeInLBA:=LastBlock;
      end
     else if(j>1) then
      begin
       mbr.Partition[j].BootIndicator:=$00;
       mbr.Partition[j].StartingCHS[1]:=$00;
       mbr.Partition[j].StartingCHS[2]:=$00;
       mbr.Partition[j].StartingCHS[3]:=$00;
       mbr.Partition[j].OSType:=$00;
       mbr.Partition[j].EndingCHS[1]:=$00;
       mbr.Partition[j].EndingCHS[2]:=$00;
       mbr.Partition[j].EndingCHS[3]:=$00;
       mbr.Partition[j].StartingLBA:=$00000000;
       mbr.Partition[j].SizeInLBA:=$00000000;
      end;
    end;
   mbr.signature:=$AA55;
   gpt.signature:=$5452415020494645;
   gpt.revision:=$00010000;
   gpt.headersize:=92;
   gpt.headercrc32:=0;
   gpt.reserved1:=0;
   gpt.MyLBA:=1; 
   gpt.AlternateLBA:=lastblock;
   gpt.FirstUsableLBA:=2+128 div (blocksize div 128); 
   gpt.LastUsableLBA:=gpt.AlternateLBA-128 div (blocksize div 128)-1;
   gpt.DiskGuid:=efi_generate_guid($F1B2A2C3D7E3F967+32768*i,$C1F2E3D1F4C9E84F+8192*i);
   gpt.PartitionEntryLBA:=2;
   gpt.NumberOfPartitionEntries:=128;
   gpt.SizeOfPartitionEntry:=128;
   gpt.PartitionEntryArrayCRC32:=0;
   epe.epe_count:=128;
   if(blocksize>92) then for j:=1 to blocksize-92 do gpt.reserved2[j]:=0;
   if(i=harddiskindex) then
    begin
     for j:=1 to 128 do
      begin
       if(j=1) then
        begin
         epe.epe_content[j].PartitionTypeGUID:=efi_system_partition_guid;
         epe.epe_content[j].UniquePartitionGUID:=efi_generate_guid($F1B2A2C3D7E3F967+4096*i+j*21,$C1F2E3D1F4C9E84F+3072*i+j*17);
         epe.epe_content[j].StartingLBA:=gpt.FirstUsableLBA;
         epe.epe_content[j].EndingLBA:=gpt.FirstUsableLBA+256*1024 div (blocksize div 512)-1;
         epe.epe_content[j].Attributes:=0;
         epe.epe_content[j].PartitionName[1]:='E';
         epe.epe_content[j].PartitionName[2]:='F';
         epe.epe_content[j].PartitionName[3]:='I';
         epe.epe_content[j].PartitionName[4]:=#0;
        end
       else if(j=2) then
        begin
         epe.epe_content[j].PartitionTypeGUID:=efi_generate_guid($F1B2A2C3D7E3F967+4096*i+j*23,$C1F2E3D1F4C9E84F+4096*i+j*19);
         epe.epe_content[j].UniquePartitionGUID:=efi_generate_guid($F1B2A2C3D7E3F967+4096*i+j*21,$C1F2E3D1F4C9E84F+4096*i+j*17);
         epe.epe_content[j].StartingLBA:=gpt.FirstUsableLBA+256*1024 div (blocksize div 512);
         epe.epe_content[j].EndingLBA:=gpt.LastUsableLBA;
         epe.epe_content[j].Attributes:=0;
         epe.epe_content[j].PartitionName[1]:='T';
         epe.epe_content[j].PartitionName[2]:='Y';
         epe.epe_content[j].PartitionName[3]:='D';
         epe.epe_content[j].PartitionName[4]:='Q';
         epe.epe_content[j].PartitionName[5]:=#0;
        end
       else if(j>2) then
        begin
         epe.epe_content[j].PartitionTypeGUID:=unused_entry_guid;
         epe.epe_content[j].UniquePartitionGUID:=efi_generate_guid($F1B2A2C3D7E3F967+1636*i+j*21,$C1F2E3D1F4C9E84F+2560*i+j*17);
         epe.epe_content[j].StartingLBA:=0;
         epe.epe_content[j].EndingLBA:=0;
         epe.epe_content[j].Attributes:=0;
         epe.epe_content[j].PartitionName[1]:=#0;
        end;
      end;
    end
   else if(i<>harddiskindex) then
    begin
     for j:=1 to 128 do
      begin
       if(j=1) then
        begin
         epe.epe_content[j].PartitionTypeGUID:=efi_generate_guid($F1B2A2C3D7E3F967+4096*i+j*23,$C1F2E3D1F4C9E84F+4096*i+j*19);
         epe.epe_content[j].UniquePartitionGUID:=efi_generate_guid($F1B2A2C3D7E3F967+4096*i+j*21,$C1F2E3D1F4C9E84F+4096*i+j*17);
         epe.epe_content[j].StartingLBA:=gpt.FirstUsableLBA;
         epe.epe_content[j].EndingLBA:=gpt.LastUsableLBA;
         epe.epe_content[j].Attributes:=0;
         epe.epe_content[j].PartitionName[1]:='T';
         epe.epe_content[j].PartitionName[2]:='Y';
         epe.epe_content[j].PartitionName[3]:='D';
         epe.epe_content[j].PartitionName[4]:='Q';
         epe.epe_content[j].PartitionName[5]:=#0;
        end  
       else if(j>1) then
        begin
         epe.epe_content[j].PartitionTypeGUID:=unused_entry_guid;
         epe.epe_content[j].UniquePartitionGUID:=efi_generate_guid($F1B2A2C3D7E3F967+4096*i+j*21,$C1F2E3D1F4C9E84F+4096*i+j*17);
         epe.epe_content[j].StartingLBA:=0;
         epe.epe_content[j].EndingLBA:=0;
         epe.epe_content[j].Attributes:=0;
         epe.epe_content[j].PartitionName[1]:=#0;
        end;
      end;
    end;
   SystemTable^.BootServices^.CalculateCrc32(@epe.epe_content,sizeof(epe.epe_content),gpt.PartitionEntryArrayCRC32);
   SystemTable^.BootServices^.CalculateCrc32(@gpt,gpt.headersize,gpt.headercrc32);
   diop^.WriteDisk(diop,mediaid,0,sizeof(master_boot_record),@mbr);
   if(blocksize>512) then for j:=512 to blocksize-1 do diop^.WriteDisk(diop,mediaid,j,1,@zero);
   diskwritepos:=blocksize;
   diop^.WriteDisk(diop,mediaid,diskwritepos,blocksize,@gpt);
   diop^.WriteDisk(diop,mediaid,blocksize*lastblock,blocksize,@gpt);
   diskwritepos:=blocksize*2;
   diop^.WriteDisk(diop,mediaid,diskwritepos,sizeof(epe.epe_content),@epe.epe_content);
   diop^.WriteDisk(diop,mediaid,blocksize*lastblock-blocksize*(128 div (blocksize div 128)),sizeof(epe.epe_content),@epe.epe_content);
   if(i=harddiskindex) then
    begin
     fat32h.JumpOrder[1]:=$EB; fat32h.JumpOrder[2]:=$58; fat32h.JumpOrder[3]:=$90;
     fat32h.OemCode[1]:='T'; fat32h.OemCode[2]:='Y'; fat32h.OemCode[3]:='D'; fat32h.OemCode[4]:='Q';
     fat32h.OemCode[5]:='O'; fat32h.OemCode[6]:='S'; fat32h.OemCode[7]:=' '; fat32h.OemCode[8]:=' ';
     fat32h.BytesPerSector:=blocksize; 
     fat32h.SectorPerCluster:=1;
     fat32h.ReservedSectorCount:=8;
     fat32h.NumFATs:=2;
     fat32h.RootEntryCount:=0; 
     fat32h.TotalSector16:=0; 
     fat32h.Media:=$F8;
     fat32h.FATSectors16:=0; 
     fat32h.SectorPerTrack:=32; 
     fat32h.NumHeads:=8;
     fat32h.HiddenSectors:=0; 
     fat32h.TotalSectors32:=1024*256 div (blocksize div 512); 
     fat32h.FATSector32:=256 div (blocksize div 512);
     fat32h.ExtendedFlags:=0; 
     fat32h.filesystemVersion:=0; 
     fat32h.RootCluster:=fat32h.ReservedSectorCount+fat32h.FATSector32*2;
     fat32h.FileSystemInfo:=1; 
     fat32h.BootSector:=6; 
     for j:=1 to 12 do fat32h.Reserved[j]:=0; 
     fat32h.DriverNumber:=$80; 
     fat32h.Reserved1:=0;
     fat32h.BootSignature:=$29; 
     fat32h.VolumeID:=efi_generate_fat32_volumeid($1F3845D2);
     fat32h.VolumeLabel[1]:='E'; fat32h.VolumeLabel[2]:='F'; fat32h.VolumeLabel[3]:='I'; fat32h.VolumeLabel[4]:=' '; 
     fat32h.VolumeLabel[5]:='P'; fat32h.VolumeLabel[6]:='A'; fat32h.VolumeLabel[7]:='R'; fat32h.VolumeLabel[8]:='T'; 
     fat32h.VolumeLabel[9]:=' '; fat32h.VolumeLabel[10]:=' '; fat32h.VolumeLabel[11]:=' ';
     fat32h.FileSystemType[1]:='F'; fat32h.FileSystemType[2]:='A'; fat32h.FileSystemType[3]:='T';
     fat32h.FileSystemType[4]:='3'; fat32h.FileSystemType[5]:='2'; fat32h.FileSystemType[6]:=' ';
     fat32h.FileSystemType[7]:=' '; fat32h.FileSystemType[8]:=' ';
     for j:=1 to 420 do fat32h.Reserved2[j]:=0;
     fat32h.SignatureWord:=$AA55;
     if(BlockSize>512) then for j:=1 to BlockSize-512 do fat32h.Reserved3[j]:=0;
     fat32fs.FSI_leadsig:=$41615252; 
     for j:=1 to 480 do fat32fs.FSI_Reserved1[j]:=0;
     fat32fs.FSI_StrucSig:=$61417272;
     fat32fs.FSI_FreeCount:=1024*256 div (blocksize shr 9)-fat32h.ReservedSectorCount-fat32h.FATSector32*2; 
     fat32fs.FSI_NextFree:=fat32h.ReservedSectorCount+fat32h.FATSector32*2;
     for j:=1 to 12 do fat32fs.FSI_Reserved2[j]:=0;
     fat32fs.FSI_TrailSig:=$AA550000;
     if(BlockSize>512) then for j:=1 to BlockSize-512 do fat32fs.FSI_Reserved3[j]:=0;
     diop^.WriteDisk(diop,mediaid,gpt.FirstUsableLBA*blocksize,blocksize,@fat32h);
     diop^.WriteDisk(diop,mediaid,gpt.FirstUsableLBA*blocksize+blocksize,blocksize,@fat32fs);
     diop^.WriteDisk(diop,mediaid,gpt.FirstUsableLBA*blocksize+blocksize*6,blocksize,@fat32h);
     diop^.WriteDisk(diop,mediaid,gpt.FirstUsableLBA*blocksize+blocksize*7,blocksize,@fat32fs);
     diop^.WriteDisk(diop,mediaid,gpt.FirstUsableLBA*blocksize+1024*256*blocksize div (blocksize div 512),sizeof(efi_guid),@system_restart_guid);
    end;
  end;
end;
procedure efi_install_cdrom_to_hard_disk_stage2(systemtable:Pefi_system_table;efslext:efi_file_system_list_ext;inscd,insdisk:natuint;const efipart:boolean);cdecl;[public,alias:'EFI_INSTALL_CDROM_TO_HARD_DISK_STAGE2'];
var fsp1,fsp2:Pefi_simple_file_system_protocol;
    fp1,fp2,fp3:Pefi_file_protocol;
    fpinfo:efi_file_info;
    realsize,consize:natuint;
    status:efi_status;
begin
 fsp1:=(efslext.fsrcontent+inscd-1)^; fsp2:=(efslext.fsrwcontent+insdisk-1)^;
 fsp1^.OpenVolume(fsp1,fp1); fsp2^.OpenVolume(fsp2,fp2);
 status:=fp2^.Open(fp2,fp2,'\',efi_file_mode_create or efi_file_mode_write or efi_file_mode_read,efi_file_directory);
 if(status<>efi_success) then efi_console_output_string(systemtable,'ERROR1'#13#10) else fp2^.SetPosition(fp2,0);
 status:=fp2^.Open(fp2,fp2,'\EFI',efi_file_mode_create or efi_file_mode_write or efi_file_mode_read,efi_file_directory);
 while(status<>efi_success) do status:=fp2^.Open(fp2,fp2,'\EFI',efi_file_mode_create or efi_file_mode_write or efi_file_mode_read,efi_file_directory);
 if(efipart) then 
  begin
   status:=fp2^.Open(fp2,fp2,'\EFI\BOOT',efi_file_mode_create or efi_file_mode_write or efi_file_mode_read,efi_file_directory);
   while(status<>efi_success) do status:=fp2^.Open(fp2,fp2,'\EFI\BOOT',efi_file_mode_create or efi_file_mode_write or efi_file_mode_read,efi_file_directory);
   status:=fp2^.Open(fp2,fp2,'\EFI\BOOT\bootx64.efi',efi_file_mode_create or efi_file_mode_write or efi_file_mode_read,efi_file_system);
   while(status<>efi_success) do status:=fp2^.Open(fp2,fp2,'\EFI\BOOT\bootx64.efi',efi_file_mode_create or efi_file_mode_write or efi_file_mode_read,efi_file_directory);
   fp2^.SetPosition(fp2,0);
  end
 else 
  begin
   status:=fp2^.Open(fp2,fp2,'\EFI\TYDQOS',efi_file_mode_create or efi_file_mode_write or efi_file_mode_read,efi_file_directory);
   while(status<>efi_success) do status:=fp2^.Open(fp2,fp2,'\EFI\TYDQOS',efi_file_mode_create or efi_file_mode_write or efi_file_mode_read,efi_file_directory);
   status:=fp2^.Open(fp2,fp2,'\EFI\TYDQOS\bootx64.efi',efi_file_mode_create or efi_file_mode_write or efi_file_mode_read,efi_file_system);
   while(status<>efi_success) do status:=fp2^.Open(fp2,fp2,'\EFI\TYDQOS\bootx64.efi',efi_file_mode_create or efi_file_mode_write or efi_file_mode_read,efi_file_system);
   fp2^.SetPosition(fp2,0);
  end;
 fp1^.Open(fp1,fp1,'\EFI\SETUP\bootx64.efi',efi_file_mode_read,0);
 realsize:=sizeof(efi_file_info);
 fp1^.GetInfo(fp1,@efi_file_info_id,realsize,fpinfo);
 realsize:=fpinfo.FileSize;
 fp1^.efiRead(fp1,realsize,content);
 status:=fp2^.efiWrite(fp2,realsize,@content);
 if(status<>efi_success) then efi_console_output_string(systemtable,'ERROR4'#13#10);
 fp1^.Close(fp1); 
 fp2^.Close(fp2);
end;
procedure efi_system_restart_information_off(systemtable:Pefi_system_table;var mybool:boolean);cdecl;[public,alias:'EFI_SYSTEM_RESTART_INFORMATION_OFF'];
var edl:efi_disk_list;
    procdisk:Pefi_disk_io_protocol;
    procblock:Pefi_block_io_protocol;
    data:efi_guid;
    i:natuint;
begin
 edl:=efi_detect_disk_write_ability(systemtable); mybool:=false;
 for i:=1 to edl.disk_count do
  begin
   procdisk:=(edl.disk_content+i-1)^; procblock:=(edl.disk_block_content+i-1)^;
   Procdisk^.ReadDisk(procdisk,procblock^.Media^.MediaId,0,16,data);
   if(data.data1=system_restart_guid.data1) and  (data.data2=system_restart_guid.data2) and (data.data3=system_restart_guid.data3) 
   and (data.data4[1]=system_restart_guid.data4[1]) and (data.data4[2]=system_restart_guid.data4[2])
   and (data.data4[3]=system_restart_guid.data4[3]) and (data.data4[4]=system_restart_guid.data4[4])
   and (data.data4[5]=system_restart_guid.data4[5]) and (data.data4[6]=system_restart_guid.data4[6])
   and (data.data4[7]=system_restart_guid.data4[7]) and (data.data4[8]=system_restart_guid.data4[8]) then
    begin
     Procdisk^.WriteDisk(procdisk,procblock^.Media^.MediaId,0,16,@unused_entry_guid);
     mybool:=true; break;
    end;
  end;
end;
function efi_disk_empty_list(systemTable:Pefi_system_table):efi_disk_list;cdecl;[public,alias:'EFI_DISK_EMPTY_LIST'];
var edl,redl:efi_disk_list;
    procdisk:Pefi_disk_io_protocol;
    procblock:Pefi_block_io_protocol;
    data:qword;
    i:natuint;
begin
 edl:=efi_detect_disk_write_ability(systemtable); 
 redl.disk_count:=0;
 redl.disk_content:=allocmem(sizeof(Pointer)*1024); 
 redl.disk_block_content:=allocmem(sizeof(Pointer)*1024);
 for i:=1 to edl.disk_count do
  begin
   procdisk:=(edl.disk_content+i-1)^; procblock:=(edl.disk_block_content+i-1)^;
   procdisk^.ReadDisk(procdisk,procblock^.Media^.MediaId,0,8,data);
   if(data=0) then 
    begin
     inc(redl.disk_count);
     (redl.disk_content+redl.disk_count-1)^:=procdisk;
     (redl.disk_block_content+redl.disk_count-1)^:=procblock;
    end;
  end;
 efi_disk_empty_list:=redl;
end;
function efi_disk_tydq_get_fs_list(systemTable:Pefi_system_table):efi_disk_list;cdecl;[public,alias:'EFI_DISK_TYDQ_FS_LIST'];
var edl,redl:efi_disk_list;
    procdisk:Pefi_disk_io_protocol;
    procblock:Pefi_block_io_protocol;
    data:qword;
    i:natuint;
begin
 edl:=efi_detect_disk_write_ability(systemtable); 
 redl.disk_count:=0;
 redl.disk_content:=allocmem(sizeof(Pointer)*1024); 
 redl.disk_block_content:=allocmem(sizeof(Pointer)*1024);
 for i:=1 to edl.disk_count do
  begin
   procdisk:=(edl.disk_content+i-1)^; procblock:=(edl.disk_block_content+i-1)^;
   procdisk^.ReadDisk(procdisk,procblock^.Media^.MediaId,0,8,data);
   if(data=$5D47291AD7E3F2B1) then 
    begin
     inc(redl.disk_count);
     (redl.disk_content+redl.disk_count-1)^:=procdisk;
     (redl.disk_block_content+redl.disk_count-1)^:=procblock;
    end;
  end;
 efi_disk_tydq_get_fs_list:=redl;
end;
procedure efi_disk_tydq_set_fs(systemTable:Pefi_system_table;disknumber:natuint);cdecl;[public,alias:'EFI_DISK_TYDQ_SET_FS'];
var edl:efi_disk_list;
    pdisk:Pefi_disk_io_protocol;
    pblock:Pefi_block_io_protocol;
    wdata:qword;
begin
 edl:=efi_disk_empty_list(systemtable);
 pdisk:=(edl.disk_content+disknumber-1)^;
 pblock:=(edl.disk_block_content+disknumber-1)^;
 wdata:=$5D47291AD7E3F2B1;
 pdisk^.WriteDisk(pdisk,pblock^.Media^.MediaId,0,8,@wdata);
end;

end.
