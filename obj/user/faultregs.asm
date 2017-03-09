
obj/user/faultregs.debug:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 66 05 00 00       	call   800597 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <check_regs>:
static struct regs before, during, after;

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 0c             	sub    $0xc,%esp
  80003c:	89 c6                	mov    %eax,%esi
  80003e:	89 cb                	mov    %ecx,%ebx
	int mismatch = 0;

	cprintf("%-6s %-8s %-8s\n", "", an, bn);
  800040:	ff 75 08             	pushl  0x8(%ebp)
  800043:	52                   	push   %edx
  800044:	68 31 24 80 00       	push   $0x802431
  800049:	68 00 24 80 00       	push   $0x802400
  80004e:	e8 7d 06 00 00       	call   8006d0 <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800053:	ff 33                	pushl  (%ebx)
  800055:	ff 36                	pushl  (%esi)
  800057:	68 10 24 80 00       	push   $0x802410
  80005c:	68 14 24 80 00       	push   $0x802414
  800061:	e8 6a 06 00 00       	call   8006d0 <cprintf>
  800066:	83 c4 20             	add    $0x20,%esp
  800069:	8b 03                	mov    (%ebx),%eax
  80006b:	39 06                	cmp    %eax,(%esi)
  80006d:	75 17                	jne    800086 <check_regs+0x53>
  80006f:	83 ec 0c             	sub    $0xc,%esp
  800072:	68 24 24 80 00       	push   $0x802424
  800077:	e8 54 06 00 00       	call   8006d0 <cprintf>
  80007c:	83 c4 10             	add    $0x10,%esp

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
	int mismatch = 0;
  80007f:	bf 00 00 00 00       	mov    $0x0,%edi
  800084:	eb 15                	jmp    80009b <check_regs+0x68>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800086:	83 ec 0c             	sub    $0xc,%esp
  800089:	68 28 24 80 00       	push   $0x802428
  80008e:	e8 3d 06 00 00       	call   8006d0 <cprintf>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  80009b:	ff 73 04             	pushl  0x4(%ebx)
  80009e:	ff 76 04             	pushl  0x4(%esi)
  8000a1:	68 32 24 80 00       	push   $0x802432
  8000a6:	68 14 24 80 00       	push   $0x802414
  8000ab:	e8 20 06 00 00       	call   8006d0 <cprintf>
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	8b 43 04             	mov    0x4(%ebx),%eax
  8000b6:	39 46 04             	cmp    %eax,0x4(%esi)
  8000b9:	75 12                	jne    8000cd <check_regs+0x9a>
  8000bb:	83 ec 0c             	sub    $0xc,%esp
  8000be:	68 24 24 80 00       	push   $0x802424
  8000c3:	e8 08 06 00 00       	call   8006d0 <cprintf>
  8000c8:	83 c4 10             	add    $0x10,%esp
  8000cb:	eb 15                	jmp    8000e2 <check_regs+0xaf>
  8000cd:	83 ec 0c             	sub    $0xc,%esp
  8000d0:	68 28 24 80 00       	push   $0x802428
  8000d5:	e8 f6 05 00 00       	call   8006d0 <cprintf>
  8000da:	83 c4 10             	add    $0x10,%esp
  8000dd:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000e2:	ff 73 08             	pushl  0x8(%ebx)
  8000e5:	ff 76 08             	pushl  0x8(%esi)
  8000e8:	68 36 24 80 00       	push   $0x802436
  8000ed:	68 14 24 80 00       	push   $0x802414
  8000f2:	e8 d9 05 00 00       	call   8006d0 <cprintf>
  8000f7:	83 c4 10             	add    $0x10,%esp
  8000fa:	8b 43 08             	mov    0x8(%ebx),%eax
  8000fd:	39 46 08             	cmp    %eax,0x8(%esi)
  800100:	75 12                	jne    800114 <check_regs+0xe1>
  800102:	83 ec 0c             	sub    $0xc,%esp
  800105:	68 24 24 80 00       	push   $0x802424
  80010a:	e8 c1 05 00 00       	call   8006d0 <cprintf>
  80010f:	83 c4 10             	add    $0x10,%esp
  800112:	eb 15                	jmp    800129 <check_regs+0xf6>
  800114:	83 ec 0c             	sub    $0xc,%esp
  800117:	68 28 24 80 00       	push   $0x802428
  80011c:	e8 af 05 00 00       	call   8006d0 <cprintf>
  800121:	83 c4 10             	add    $0x10,%esp
  800124:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  800129:	ff 73 10             	pushl  0x10(%ebx)
  80012c:	ff 76 10             	pushl  0x10(%esi)
  80012f:	68 3a 24 80 00       	push   $0x80243a
  800134:	68 14 24 80 00       	push   $0x802414
  800139:	e8 92 05 00 00       	call   8006d0 <cprintf>
  80013e:	83 c4 10             	add    $0x10,%esp
  800141:	8b 43 10             	mov    0x10(%ebx),%eax
  800144:	39 46 10             	cmp    %eax,0x10(%esi)
  800147:	75 12                	jne    80015b <check_regs+0x128>
  800149:	83 ec 0c             	sub    $0xc,%esp
  80014c:	68 24 24 80 00       	push   $0x802424
  800151:	e8 7a 05 00 00       	call   8006d0 <cprintf>
  800156:	83 c4 10             	add    $0x10,%esp
  800159:	eb 15                	jmp    800170 <check_regs+0x13d>
  80015b:	83 ec 0c             	sub    $0xc,%esp
  80015e:	68 28 24 80 00       	push   $0x802428
  800163:	e8 68 05 00 00       	call   8006d0 <cprintf>
  800168:	83 c4 10             	add    $0x10,%esp
  80016b:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800170:	ff 73 14             	pushl  0x14(%ebx)
  800173:	ff 76 14             	pushl  0x14(%esi)
  800176:	68 3e 24 80 00       	push   $0x80243e
  80017b:	68 14 24 80 00       	push   $0x802414
  800180:	e8 4b 05 00 00       	call   8006d0 <cprintf>
  800185:	83 c4 10             	add    $0x10,%esp
  800188:	8b 43 14             	mov    0x14(%ebx),%eax
  80018b:	39 46 14             	cmp    %eax,0x14(%esi)
  80018e:	75 12                	jne    8001a2 <check_regs+0x16f>
  800190:	83 ec 0c             	sub    $0xc,%esp
  800193:	68 24 24 80 00       	push   $0x802424
  800198:	e8 33 05 00 00       	call   8006d0 <cprintf>
  80019d:	83 c4 10             	add    $0x10,%esp
  8001a0:	eb 15                	jmp    8001b7 <check_regs+0x184>
  8001a2:	83 ec 0c             	sub    $0xc,%esp
  8001a5:	68 28 24 80 00       	push   $0x802428
  8001aa:	e8 21 05 00 00       	call   8006d0 <cprintf>
  8001af:	83 c4 10             	add    $0x10,%esp
  8001b2:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  8001b7:	ff 73 18             	pushl  0x18(%ebx)
  8001ba:	ff 76 18             	pushl  0x18(%esi)
  8001bd:	68 42 24 80 00       	push   $0x802442
  8001c2:	68 14 24 80 00       	push   $0x802414
  8001c7:	e8 04 05 00 00       	call   8006d0 <cprintf>
  8001cc:	83 c4 10             	add    $0x10,%esp
  8001cf:	8b 43 18             	mov    0x18(%ebx),%eax
  8001d2:	39 46 18             	cmp    %eax,0x18(%esi)
  8001d5:	75 12                	jne    8001e9 <check_regs+0x1b6>
  8001d7:	83 ec 0c             	sub    $0xc,%esp
  8001da:	68 24 24 80 00       	push   $0x802424
  8001df:	e8 ec 04 00 00       	call   8006d0 <cprintf>
  8001e4:	83 c4 10             	add    $0x10,%esp
  8001e7:	eb 15                	jmp    8001fe <check_regs+0x1cb>
  8001e9:	83 ec 0c             	sub    $0xc,%esp
  8001ec:	68 28 24 80 00       	push   $0x802428
  8001f1:	e8 da 04 00 00       	call   8006d0 <cprintf>
  8001f6:	83 c4 10             	add    $0x10,%esp
  8001f9:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  8001fe:	ff 73 1c             	pushl  0x1c(%ebx)
  800201:	ff 76 1c             	pushl  0x1c(%esi)
  800204:	68 46 24 80 00       	push   $0x802446
  800209:	68 14 24 80 00       	push   $0x802414
  80020e:	e8 bd 04 00 00       	call   8006d0 <cprintf>
  800213:	83 c4 10             	add    $0x10,%esp
  800216:	8b 43 1c             	mov    0x1c(%ebx),%eax
  800219:	39 46 1c             	cmp    %eax,0x1c(%esi)
  80021c:	75 12                	jne    800230 <check_regs+0x1fd>
  80021e:	83 ec 0c             	sub    $0xc,%esp
  800221:	68 24 24 80 00       	push   $0x802424
  800226:	e8 a5 04 00 00       	call   8006d0 <cprintf>
  80022b:	83 c4 10             	add    $0x10,%esp
  80022e:	eb 15                	jmp    800245 <check_regs+0x212>
  800230:	83 ec 0c             	sub    $0xc,%esp
  800233:	68 28 24 80 00       	push   $0x802428
  800238:	e8 93 04 00 00       	call   8006d0 <cprintf>
  80023d:	83 c4 10             	add    $0x10,%esp
  800240:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  800245:	ff 73 20             	pushl  0x20(%ebx)
  800248:	ff 76 20             	pushl  0x20(%esi)
  80024b:	68 4a 24 80 00       	push   $0x80244a
  800250:	68 14 24 80 00       	push   $0x802414
  800255:	e8 76 04 00 00       	call   8006d0 <cprintf>
  80025a:	83 c4 10             	add    $0x10,%esp
  80025d:	8b 43 20             	mov    0x20(%ebx),%eax
  800260:	39 46 20             	cmp    %eax,0x20(%esi)
  800263:	75 12                	jne    800277 <check_regs+0x244>
  800265:	83 ec 0c             	sub    $0xc,%esp
  800268:	68 24 24 80 00       	push   $0x802424
  80026d:	e8 5e 04 00 00       	call   8006d0 <cprintf>
  800272:	83 c4 10             	add    $0x10,%esp
  800275:	eb 15                	jmp    80028c <check_regs+0x259>
  800277:	83 ec 0c             	sub    $0xc,%esp
  80027a:	68 28 24 80 00       	push   $0x802428
  80027f:	e8 4c 04 00 00       	call   8006d0 <cprintf>
  800284:	83 c4 10             	add    $0x10,%esp
  800287:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  80028c:	ff 73 24             	pushl  0x24(%ebx)
  80028f:	ff 76 24             	pushl  0x24(%esi)
  800292:	68 4e 24 80 00       	push   $0x80244e
  800297:	68 14 24 80 00       	push   $0x802414
  80029c:	e8 2f 04 00 00       	call   8006d0 <cprintf>
  8002a1:	83 c4 10             	add    $0x10,%esp
  8002a4:	8b 43 24             	mov    0x24(%ebx),%eax
  8002a7:	39 46 24             	cmp    %eax,0x24(%esi)
  8002aa:	75 2f                	jne    8002db <check_regs+0x2a8>
  8002ac:	83 ec 0c             	sub    $0xc,%esp
  8002af:	68 24 24 80 00       	push   $0x802424
  8002b4:	e8 17 04 00 00       	call   8006d0 <cprintf>
	CHECK(esp, esp);
  8002b9:	ff 73 28             	pushl  0x28(%ebx)
  8002bc:	ff 76 28             	pushl  0x28(%esi)
  8002bf:	68 55 24 80 00       	push   $0x802455
  8002c4:	68 14 24 80 00       	push   $0x802414
  8002c9:	e8 02 04 00 00       	call   8006d0 <cprintf>
  8002ce:	83 c4 20             	add    $0x20,%esp
  8002d1:	8b 43 28             	mov    0x28(%ebx),%eax
  8002d4:	39 46 28             	cmp    %eax,0x28(%esi)
  8002d7:	74 31                	je     80030a <check_regs+0x2d7>
  8002d9:	eb 55                	jmp    800330 <check_regs+0x2fd>
	CHECK(ebx, regs.reg_ebx);
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
  8002db:	83 ec 0c             	sub    $0xc,%esp
  8002de:	68 28 24 80 00       	push   $0x802428
  8002e3:	e8 e8 03 00 00       	call   8006d0 <cprintf>
	CHECK(esp, esp);
  8002e8:	ff 73 28             	pushl  0x28(%ebx)
  8002eb:	ff 76 28             	pushl  0x28(%esi)
  8002ee:	68 55 24 80 00       	push   $0x802455
  8002f3:	68 14 24 80 00       	push   $0x802414
  8002f8:	e8 d3 03 00 00       	call   8006d0 <cprintf>
  8002fd:	83 c4 20             	add    $0x20,%esp
  800300:	8b 43 28             	mov    0x28(%ebx),%eax
  800303:	39 46 28             	cmp    %eax,0x28(%esi)
  800306:	75 28                	jne    800330 <check_regs+0x2fd>
  800308:	eb 6c                	jmp    800376 <check_regs+0x343>
  80030a:	83 ec 0c             	sub    $0xc,%esp
  80030d:	68 24 24 80 00       	push   $0x802424
  800312:	e8 b9 03 00 00       	call   8006d0 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800317:	83 c4 08             	add    $0x8,%esp
  80031a:	ff 75 0c             	pushl  0xc(%ebp)
  80031d:	68 59 24 80 00       	push   $0x802459
  800322:	e8 a9 03 00 00       	call   8006d0 <cprintf>
	if (!mismatch)
  800327:	83 c4 10             	add    $0x10,%esp
  80032a:	85 ff                	test   %edi,%edi
  80032c:	74 24                	je     800352 <check_regs+0x31f>
  80032e:	eb 34                	jmp    800364 <check_regs+0x331>
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
	CHECK(esp, esp);
  800330:	83 ec 0c             	sub    $0xc,%esp
  800333:	68 28 24 80 00       	push   $0x802428
  800338:	e8 93 03 00 00       	call   8006d0 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  80033d:	83 c4 08             	add    $0x8,%esp
  800340:	ff 75 0c             	pushl  0xc(%ebp)
  800343:	68 59 24 80 00       	push   $0x802459
  800348:	e8 83 03 00 00       	call   8006d0 <cprintf>
  80034d:	83 c4 10             	add    $0x10,%esp
  800350:	eb 12                	jmp    800364 <check_regs+0x331>
	if (!mismatch)
		cprintf("OK\n");
  800352:	83 ec 0c             	sub    $0xc,%esp
  800355:	68 24 24 80 00       	push   $0x802424
  80035a:	e8 71 03 00 00       	call   8006d0 <cprintf>
  80035f:	83 c4 10             	add    $0x10,%esp
  800362:	eb 34                	jmp    800398 <check_regs+0x365>
	else
		cprintf("MISMATCH\n");
  800364:	83 ec 0c             	sub    $0xc,%esp
  800367:	68 28 24 80 00       	push   $0x802428
  80036c:	e8 5f 03 00 00       	call   8006d0 <cprintf>
  800371:	83 c4 10             	add    $0x10,%esp
}
  800374:	eb 22                	jmp    800398 <check_regs+0x365>
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
	CHECK(esp, esp);
  800376:	83 ec 0c             	sub    $0xc,%esp
  800379:	68 24 24 80 00       	push   $0x802424
  80037e:	e8 4d 03 00 00       	call   8006d0 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800383:	83 c4 08             	add    $0x8,%esp
  800386:	ff 75 0c             	pushl  0xc(%ebp)
  800389:	68 59 24 80 00       	push   $0x802459
  80038e:	e8 3d 03 00 00       	call   8006d0 <cprintf>
  800393:	83 c4 10             	add    $0x10,%esp
  800396:	eb cc                	jmp    800364 <check_regs+0x331>
	if (!mismatch)
		cprintf("OK\n");
	else
		cprintf("MISMATCH\n");
}
  800398:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80039b:	5b                   	pop    %ebx
  80039c:	5e                   	pop    %esi
  80039d:	5f                   	pop    %edi
  80039e:	5d                   	pop    %ebp
  80039f:	c3                   	ret    

008003a0 <pgfault>:

static void
pgfault(struct UTrapframe *utf)
{
  8003a0:	55                   	push   %ebp
  8003a1:	89 e5                	mov    %esp,%ebp
  8003a3:	83 ec 08             	sub    $0x8,%esp
  8003a6:	8b 45 08             	mov    0x8(%ebp),%eax
	int r;

	if (utf->utf_fault_va != (uint32_t)UTEMP)
  8003a9:	8b 10                	mov    (%eax),%edx
  8003ab:	81 fa 00 00 40 00    	cmp    $0x400000,%edx
  8003b1:	74 18                	je     8003cb <pgfault+0x2b>
		panic("pgfault expected at UTEMP, got 0x%08x (eip %08x)",
  8003b3:	83 ec 0c             	sub    $0xc,%esp
  8003b6:	ff 70 28             	pushl  0x28(%eax)
  8003b9:	52                   	push   %edx
  8003ba:	68 c0 24 80 00       	push   $0x8024c0
  8003bf:	6a 51                	push   $0x51
  8003c1:	68 67 24 80 00       	push   $0x802467
  8003c6:	e8 2c 02 00 00       	call   8005f7 <_panic>
		      utf->utf_fault_va, utf->utf_eip);

	// Check registers in UTrapframe
	during.regs = utf->utf_regs;
  8003cb:	8b 50 08             	mov    0x8(%eax),%edx
  8003ce:	89 15 40 40 80 00    	mov    %edx,0x804040
  8003d4:	8b 50 0c             	mov    0xc(%eax),%edx
  8003d7:	89 15 44 40 80 00    	mov    %edx,0x804044
  8003dd:	8b 50 10             	mov    0x10(%eax),%edx
  8003e0:	89 15 48 40 80 00    	mov    %edx,0x804048
  8003e6:	8b 50 14             	mov    0x14(%eax),%edx
  8003e9:	89 15 4c 40 80 00    	mov    %edx,0x80404c
  8003ef:	8b 50 18             	mov    0x18(%eax),%edx
  8003f2:	89 15 50 40 80 00    	mov    %edx,0x804050
  8003f8:	8b 50 1c             	mov    0x1c(%eax),%edx
  8003fb:	89 15 54 40 80 00    	mov    %edx,0x804054
  800401:	8b 50 20             	mov    0x20(%eax),%edx
  800404:	89 15 58 40 80 00    	mov    %edx,0x804058
  80040a:	8b 50 24             	mov    0x24(%eax),%edx
  80040d:	89 15 5c 40 80 00    	mov    %edx,0x80405c
	during.eip = utf->utf_eip;
  800413:	8b 50 28             	mov    0x28(%eax),%edx
  800416:	89 15 60 40 80 00    	mov    %edx,0x804060
	during.eflags = utf->utf_eflags & ~FL_RF;
  80041c:	8b 50 2c             	mov    0x2c(%eax),%edx
  80041f:	81 e2 ff ff fe ff    	and    $0xfffeffff,%edx
  800425:	89 15 64 40 80 00    	mov    %edx,0x804064
	during.esp = utf->utf_esp;
  80042b:	8b 40 30             	mov    0x30(%eax),%eax
  80042e:	a3 68 40 80 00       	mov    %eax,0x804068
	check_regs(&before, "before", &during, "during", "in UTrapframe");
  800433:	83 ec 08             	sub    $0x8,%esp
  800436:	68 7f 24 80 00       	push   $0x80247f
  80043b:	68 8d 24 80 00       	push   $0x80248d
  800440:	b9 40 40 80 00       	mov    $0x804040,%ecx
  800445:	ba 78 24 80 00       	mov    $0x802478,%edx
  80044a:	b8 80 40 80 00       	mov    $0x804080,%eax
  80044f:	e8 df fb ff ff       	call   800033 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  800454:	83 c4 0c             	add    $0xc,%esp
  800457:	6a 07                	push   $0x7
  800459:	68 00 00 40 00       	push   $0x400000
  80045e:	6a 00                	push   $0x0
  800460:	e8 9a 0c 00 00       	call   8010ff <sys_page_alloc>
  800465:	83 c4 10             	add    $0x10,%esp
  800468:	85 c0                	test   %eax,%eax
  80046a:	79 12                	jns    80047e <pgfault+0xde>
		panic("sys_page_alloc: %e", r);
  80046c:	50                   	push   %eax
  80046d:	68 94 24 80 00       	push   $0x802494
  800472:	6a 5c                	push   $0x5c
  800474:	68 67 24 80 00       	push   $0x802467
  800479:	e8 79 01 00 00       	call   8005f7 <_panic>
}
  80047e:	c9                   	leave  
  80047f:	c3                   	ret    

00800480 <umain>:

void
umain(int argc, char **argv)
{
  800480:	55                   	push   %ebp
  800481:	89 e5                	mov    %esp,%ebp
  800483:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(pgfault);
  800486:	68 a0 03 80 00       	push   $0x8003a0
  80048b:	e8 60 0e 00 00       	call   8012f0 <set_pgfault_handler>

	asm volatile(
  800490:	50                   	push   %eax
  800491:	9c                   	pushf  
  800492:	58                   	pop    %eax
  800493:	0d d5 08 00 00       	or     $0x8d5,%eax
  800498:	50                   	push   %eax
  800499:	9d                   	popf   
  80049a:	a3 a4 40 80 00       	mov    %eax,0x8040a4
  80049f:	8d 05 da 04 80 00    	lea    0x8004da,%eax
  8004a5:	a3 a0 40 80 00       	mov    %eax,0x8040a0
  8004aa:	58                   	pop    %eax
  8004ab:	89 3d 80 40 80 00    	mov    %edi,0x804080
  8004b1:	89 35 84 40 80 00    	mov    %esi,0x804084
  8004b7:	89 2d 88 40 80 00    	mov    %ebp,0x804088
  8004bd:	89 1d 90 40 80 00    	mov    %ebx,0x804090
  8004c3:	89 15 94 40 80 00    	mov    %edx,0x804094
  8004c9:	89 0d 98 40 80 00    	mov    %ecx,0x804098
  8004cf:	a3 9c 40 80 00       	mov    %eax,0x80409c
  8004d4:	89 25 a8 40 80 00    	mov    %esp,0x8040a8
  8004da:	c7 05 00 00 40 00 2a 	movl   $0x2a,0x400000
  8004e1:	00 00 00 
  8004e4:	89 3d 00 40 80 00    	mov    %edi,0x804000
  8004ea:	89 35 04 40 80 00    	mov    %esi,0x804004
  8004f0:	89 2d 08 40 80 00    	mov    %ebp,0x804008
  8004f6:	89 1d 10 40 80 00    	mov    %ebx,0x804010
  8004fc:	89 15 14 40 80 00    	mov    %edx,0x804014
  800502:	89 0d 18 40 80 00    	mov    %ecx,0x804018
  800508:	a3 1c 40 80 00       	mov    %eax,0x80401c
  80050d:	89 25 28 40 80 00    	mov    %esp,0x804028
  800513:	8b 3d 80 40 80 00    	mov    0x804080,%edi
  800519:	8b 35 84 40 80 00    	mov    0x804084,%esi
  80051f:	8b 2d 88 40 80 00    	mov    0x804088,%ebp
  800525:	8b 1d 90 40 80 00    	mov    0x804090,%ebx
  80052b:	8b 15 94 40 80 00    	mov    0x804094,%edx
  800531:	8b 0d 98 40 80 00    	mov    0x804098,%ecx
  800537:	a1 9c 40 80 00       	mov    0x80409c,%eax
  80053c:	8b 25 a8 40 80 00    	mov    0x8040a8,%esp
  800542:	50                   	push   %eax
  800543:	9c                   	pushf  
  800544:	58                   	pop    %eax
  800545:	a3 24 40 80 00       	mov    %eax,0x804024
  80054a:	58                   	pop    %eax
		: : "m" (before), "m" (after) : "memory", "cc");

	// Check UTEMP to roughly determine that EIP was restored
	// correctly (of course, we probably wouldn't get this far if
	// it weren't)
	if (*(int*)UTEMP != 42)
  80054b:	83 c4 10             	add    $0x10,%esp
  80054e:	83 3d 00 00 40 00 2a 	cmpl   $0x2a,0x400000
  800555:	74 10                	je     800567 <umain+0xe7>
		cprintf("EIP after page-fault MISMATCH\n");
  800557:	83 ec 0c             	sub    $0xc,%esp
  80055a:	68 f4 24 80 00       	push   $0x8024f4
  80055f:	e8 6c 01 00 00       	call   8006d0 <cprintf>
  800564:	83 c4 10             	add    $0x10,%esp
	after.eip = before.eip;
  800567:	a1 a0 40 80 00       	mov    0x8040a0,%eax
  80056c:	a3 20 40 80 00       	mov    %eax,0x804020

	check_regs(&before, "before", &after, "after", "after page-fault");
  800571:	83 ec 08             	sub    $0x8,%esp
  800574:	68 a7 24 80 00       	push   $0x8024a7
  800579:	68 b8 24 80 00       	push   $0x8024b8
  80057e:	b9 00 40 80 00       	mov    $0x804000,%ecx
  800583:	ba 78 24 80 00       	mov    $0x802478,%edx
  800588:	b8 80 40 80 00       	mov    $0x804080,%eax
  80058d:	e8 a1 fa ff ff       	call   800033 <check_regs>
}
  800592:	83 c4 10             	add    $0x10,%esp
  800595:	c9                   	leave  
  800596:	c3                   	ret    

00800597 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800597:	55                   	push   %ebp
  800598:	89 e5                	mov    %esp,%ebp
  80059a:	56                   	push   %esi
  80059b:	53                   	push   %ebx
  80059c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80059f:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	envid_t envid = sys_getenvid();
  8005a2:	e8 1a 0b 00 00       	call   8010c1 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8005a7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8005ac:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8005af:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8005b4:	a3 b0 40 80 00       	mov    %eax,0x8040b0

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8005b9:	85 db                	test   %ebx,%ebx
  8005bb:	7e 07                	jle    8005c4 <libmain+0x2d>
		binaryname = argv[0];
  8005bd:	8b 06                	mov    (%esi),%eax
  8005bf:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8005c4:	83 ec 08             	sub    $0x8,%esp
  8005c7:	56                   	push   %esi
  8005c8:	53                   	push   %ebx
  8005c9:	e8 b2 fe ff ff       	call   800480 <umain>

	// exit gracefully
	exit();
  8005ce:	e8 0a 00 00 00       	call   8005dd <exit>
}
  8005d3:	83 c4 10             	add    $0x10,%esp
  8005d6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8005d9:	5b                   	pop    %ebx
  8005da:	5e                   	pop    %esi
  8005db:	5d                   	pop    %ebp
  8005dc:	c3                   	ret    

008005dd <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8005dd:	55                   	push   %ebp
  8005de:	89 e5                	mov    %esp,%ebp
  8005e0:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8005e3:	e8 43 0f 00 00       	call   80152b <close_all>
	sys_env_destroy(0);
  8005e8:	83 ec 0c             	sub    $0xc,%esp
  8005eb:	6a 00                	push   $0x0
  8005ed:	e8 8e 0a 00 00       	call   801080 <sys_env_destroy>
}
  8005f2:	83 c4 10             	add    $0x10,%esp
  8005f5:	c9                   	leave  
  8005f6:	c3                   	ret    

008005f7 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8005f7:	55                   	push   %ebp
  8005f8:	89 e5                	mov    %esp,%ebp
  8005fa:	56                   	push   %esi
  8005fb:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8005fc:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8005ff:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800605:	e8 b7 0a 00 00       	call   8010c1 <sys_getenvid>
  80060a:	83 ec 0c             	sub    $0xc,%esp
  80060d:	ff 75 0c             	pushl  0xc(%ebp)
  800610:	ff 75 08             	pushl  0x8(%ebp)
  800613:	56                   	push   %esi
  800614:	50                   	push   %eax
  800615:	68 20 25 80 00       	push   $0x802520
  80061a:	e8 b1 00 00 00       	call   8006d0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80061f:	83 c4 18             	add    $0x18,%esp
  800622:	53                   	push   %ebx
  800623:	ff 75 10             	pushl  0x10(%ebp)
  800626:	e8 54 00 00 00       	call   80067f <vcprintf>
	cprintf("\n");
  80062b:	c7 04 24 30 24 80 00 	movl   $0x802430,(%esp)
  800632:	e8 99 00 00 00       	call   8006d0 <cprintf>
  800637:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80063a:	cc                   	int3   
  80063b:	eb fd                	jmp    80063a <_panic+0x43>

0080063d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80063d:	55                   	push   %ebp
  80063e:	89 e5                	mov    %esp,%ebp
  800640:	53                   	push   %ebx
  800641:	83 ec 04             	sub    $0x4,%esp
  800644:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800647:	8b 13                	mov    (%ebx),%edx
  800649:	8d 42 01             	lea    0x1(%edx),%eax
  80064c:	89 03                	mov    %eax,(%ebx)
  80064e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800651:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800655:	3d ff 00 00 00       	cmp    $0xff,%eax
  80065a:	75 1a                	jne    800676 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80065c:	83 ec 08             	sub    $0x8,%esp
  80065f:	68 ff 00 00 00       	push   $0xff
  800664:	8d 43 08             	lea    0x8(%ebx),%eax
  800667:	50                   	push   %eax
  800668:	e8 d6 09 00 00       	call   801043 <sys_cputs>
		b->idx = 0;
  80066d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800673:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800676:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80067a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80067d:	c9                   	leave  
  80067e:	c3                   	ret    

0080067f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80067f:	55                   	push   %ebp
  800680:	89 e5                	mov    %esp,%ebp
  800682:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800688:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80068f:	00 00 00 
	b.cnt = 0;
  800692:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800699:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80069c:	ff 75 0c             	pushl  0xc(%ebp)
  80069f:	ff 75 08             	pushl  0x8(%ebp)
  8006a2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8006a8:	50                   	push   %eax
  8006a9:	68 3d 06 80 00       	push   $0x80063d
  8006ae:	e8 1a 01 00 00       	call   8007cd <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8006b3:	83 c4 08             	add    $0x8,%esp
  8006b6:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8006bc:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8006c2:	50                   	push   %eax
  8006c3:	e8 7b 09 00 00       	call   801043 <sys_cputs>

	return b.cnt;
}
  8006c8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8006ce:	c9                   	leave  
  8006cf:	c3                   	ret    

008006d0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8006d0:	55                   	push   %ebp
  8006d1:	89 e5                	mov    %esp,%ebp
  8006d3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8006d6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8006d9:	50                   	push   %eax
  8006da:	ff 75 08             	pushl  0x8(%ebp)
  8006dd:	e8 9d ff ff ff       	call   80067f <vcprintf>
	va_end(ap);

	return cnt;
}
  8006e2:	c9                   	leave  
  8006e3:	c3                   	ret    

008006e4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8006e4:	55                   	push   %ebp
  8006e5:	89 e5                	mov    %esp,%ebp
  8006e7:	57                   	push   %edi
  8006e8:	56                   	push   %esi
  8006e9:	53                   	push   %ebx
  8006ea:	83 ec 1c             	sub    $0x1c,%esp
  8006ed:	89 c7                	mov    %eax,%edi
  8006ef:	89 d6                	mov    %edx,%esi
  8006f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006f7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006fa:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8006fd:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800700:	bb 00 00 00 00       	mov    $0x0,%ebx
  800705:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800708:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80070b:	39 d3                	cmp    %edx,%ebx
  80070d:	72 05                	jb     800714 <printnum+0x30>
  80070f:	39 45 10             	cmp    %eax,0x10(%ebp)
  800712:	77 45                	ja     800759 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800714:	83 ec 0c             	sub    $0xc,%esp
  800717:	ff 75 18             	pushl  0x18(%ebp)
  80071a:	8b 45 14             	mov    0x14(%ebp),%eax
  80071d:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800720:	53                   	push   %ebx
  800721:	ff 75 10             	pushl  0x10(%ebp)
  800724:	83 ec 08             	sub    $0x8,%esp
  800727:	ff 75 e4             	pushl  -0x1c(%ebp)
  80072a:	ff 75 e0             	pushl  -0x20(%ebp)
  80072d:	ff 75 dc             	pushl  -0x24(%ebp)
  800730:	ff 75 d8             	pushl  -0x28(%ebp)
  800733:	e8 28 1a 00 00       	call   802160 <__udivdi3>
  800738:	83 c4 18             	add    $0x18,%esp
  80073b:	52                   	push   %edx
  80073c:	50                   	push   %eax
  80073d:	89 f2                	mov    %esi,%edx
  80073f:	89 f8                	mov    %edi,%eax
  800741:	e8 9e ff ff ff       	call   8006e4 <printnum>
  800746:	83 c4 20             	add    $0x20,%esp
  800749:	eb 18                	jmp    800763 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80074b:	83 ec 08             	sub    $0x8,%esp
  80074e:	56                   	push   %esi
  80074f:	ff 75 18             	pushl  0x18(%ebp)
  800752:	ff d7                	call   *%edi
  800754:	83 c4 10             	add    $0x10,%esp
  800757:	eb 03                	jmp    80075c <printnum+0x78>
  800759:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80075c:	83 eb 01             	sub    $0x1,%ebx
  80075f:	85 db                	test   %ebx,%ebx
  800761:	7f e8                	jg     80074b <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800763:	83 ec 08             	sub    $0x8,%esp
  800766:	56                   	push   %esi
  800767:	83 ec 04             	sub    $0x4,%esp
  80076a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80076d:	ff 75 e0             	pushl  -0x20(%ebp)
  800770:	ff 75 dc             	pushl  -0x24(%ebp)
  800773:	ff 75 d8             	pushl  -0x28(%ebp)
  800776:	e8 15 1b 00 00       	call   802290 <__umoddi3>
  80077b:	83 c4 14             	add    $0x14,%esp
  80077e:	0f be 80 43 25 80 00 	movsbl 0x802543(%eax),%eax
  800785:	50                   	push   %eax
  800786:	ff d7                	call   *%edi
}
  800788:	83 c4 10             	add    $0x10,%esp
  80078b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80078e:	5b                   	pop    %ebx
  80078f:	5e                   	pop    %esi
  800790:	5f                   	pop    %edi
  800791:	5d                   	pop    %ebp
  800792:	c3                   	ret    

00800793 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800793:	55                   	push   %ebp
  800794:	89 e5                	mov    %esp,%ebp
  800796:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800799:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80079d:	8b 10                	mov    (%eax),%edx
  80079f:	3b 50 04             	cmp    0x4(%eax),%edx
  8007a2:	73 0a                	jae    8007ae <sprintputch+0x1b>
		*b->buf++ = ch;
  8007a4:	8d 4a 01             	lea    0x1(%edx),%ecx
  8007a7:	89 08                	mov    %ecx,(%eax)
  8007a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ac:	88 02                	mov    %al,(%edx)
}
  8007ae:	5d                   	pop    %ebp
  8007af:	c3                   	ret    

008007b0 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007b0:	55                   	push   %ebp
  8007b1:	89 e5                	mov    %esp,%ebp
  8007b3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8007b6:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8007b9:	50                   	push   %eax
  8007ba:	ff 75 10             	pushl  0x10(%ebp)
  8007bd:	ff 75 0c             	pushl  0xc(%ebp)
  8007c0:	ff 75 08             	pushl  0x8(%ebp)
  8007c3:	e8 05 00 00 00       	call   8007cd <vprintfmt>
	va_end(ap);
}
  8007c8:	83 c4 10             	add    $0x10,%esp
  8007cb:	c9                   	leave  
  8007cc:	c3                   	ret    

008007cd <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8007cd:	55                   	push   %ebp
  8007ce:	89 e5                	mov    %esp,%ebp
  8007d0:	57                   	push   %edi
  8007d1:	56                   	push   %esi
  8007d2:	53                   	push   %ebx
  8007d3:	83 ec 2c             	sub    $0x2c,%esp
  8007d6:	8b 75 08             	mov    0x8(%ebp),%esi
  8007d9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007dc:	8b 7d 10             	mov    0x10(%ebp),%edi
  8007df:	eb 12                	jmp    8007f3 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8007e1:	85 c0                	test   %eax,%eax
  8007e3:	0f 84 6a 04 00 00    	je     800c53 <vprintfmt+0x486>
				return;
			putch(ch, putdat);
  8007e9:	83 ec 08             	sub    $0x8,%esp
  8007ec:	53                   	push   %ebx
  8007ed:	50                   	push   %eax
  8007ee:	ff d6                	call   *%esi
  8007f0:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007f3:	83 c7 01             	add    $0x1,%edi
  8007f6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8007fa:	83 f8 25             	cmp    $0x25,%eax
  8007fd:	75 e2                	jne    8007e1 <vprintfmt+0x14>
  8007ff:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800803:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80080a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800811:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800818:	b9 00 00 00 00       	mov    $0x0,%ecx
  80081d:	eb 07                	jmp    800826 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80081f:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800822:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800826:	8d 47 01             	lea    0x1(%edi),%eax
  800829:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80082c:	0f b6 07             	movzbl (%edi),%eax
  80082f:	0f b6 d0             	movzbl %al,%edx
  800832:	83 e8 23             	sub    $0x23,%eax
  800835:	3c 55                	cmp    $0x55,%al
  800837:	0f 87 fb 03 00 00    	ja     800c38 <vprintfmt+0x46b>
  80083d:	0f b6 c0             	movzbl %al,%eax
  800840:	ff 24 85 80 26 80 00 	jmp    *0x802680(,%eax,4)
  800847:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80084a:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80084e:	eb d6                	jmp    800826 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800850:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800853:	b8 00 00 00 00       	mov    $0x0,%eax
  800858:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80085b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80085e:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800862:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800865:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800868:	83 f9 09             	cmp    $0x9,%ecx
  80086b:	77 3f                	ja     8008ac <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80086d:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800870:	eb e9                	jmp    80085b <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800872:	8b 45 14             	mov    0x14(%ebp),%eax
  800875:	8b 00                	mov    (%eax),%eax
  800877:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80087a:	8b 45 14             	mov    0x14(%ebp),%eax
  80087d:	8d 40 04             	lea    0x4(%eax),%eax
  800880:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800883:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800886:	eb 2a                	jmp    8008b2 <vprintfmt+0xe5>
  800888:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80088b:	85 c0                	test   %eax,%eax
  80088d:	ba 00 00 00 00       	mov    $0x0,%edx
  800892:	0f 49 d0             	cmovns %eax,%edx
  800895:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800898:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80089b:	eb 89                	jmp    800826 <vprintfmt+0x59>
  80089d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8008a0:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8008a7:	e9 7a ff ff ff       	jmp    800826 <vprintfmt+0x59>
  8008ac:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8008af:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8008b2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8008b6:	0f 89 6a ff ff ff    	jns    800826 <vprintfmt+0x59>
				width = precision, precision = -1;
  8008bc:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8008bf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008c2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8008c9:	e9 58 ff ff ff       	jmp    800826 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8008ce:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8008d4:	e9 4d ff ff ff       	jmp    800826 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8008d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8008dc:	8d 78 04             	lea    0x4(%eax),%edi
  8008df:	83 ec 08             	sub    $0x8,%esp
  8008e2:	53                   	push   %ebx
  8008e3:	ff 30                	pushl  (%eax)
  8008e5:	ff d6                	call   *%esi
			break;
  8008e7:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8008ea:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8008f0:	e9 fe fe ff ff       	jmp    8007f3 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8008f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f8:	8d 78 04             	lea    0x4(%eax),%edi
  8008fb:	8b 00                	mov    (%eax),%eax
  8008fd:	99                   	cltd   
  8008fe:	31 d0                	xor    %edx,%eax
  800900:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800902:	83 f8 0f             	cmp    $0xf,%eax
  800905:	7f 0b                	jg     800912 <vprintfmt+0x145>
  800907:	8b 14 85 e0 27 80 00 	mov    0x8027e0(,%eax,4),%edx
  80090e:	85 d2                	test   %edx,%edx
  800910:	75 1b                	jne    80092d <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800912:	50                   	push   %eax
  800913:	68 5b 25 80 00       	push   $0x80255b
  800918:	53                   	push   %ebx
  800919:	56                   	push   %esi
  80091a:	e8 91 fe ff ff       	call   8007b0 <printfmt>
  80091f:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800922:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800925:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800928:	e9 c6 fe ff ff       	jmp    8007f3 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80092d:	52                   	push   %edx
  80092e:	68 3e 29 80 00       	push   $0x80293e
  800933:	53                   	push   %ebx
  800934:	56                   	push   %esi
  800935:	e8 76 fe ff ff       	call   8007b0 <printfmt>
  80093a:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80093d:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800940:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800943:	e9 ab fe ff ff       	jmp    8007f3 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800948:	8b 45 14             	mov    0x14(%ebp),%eax
  80094b:	83 c0 04             	add    $0x4,%eax
  80094e:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800951:	8b 45 14             	mov    0x14(%ebp),%eax
  800954:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800956:	85 ff                	test   %edi,%edi
  800958:	b8 54 25 80 00       	mov    $0x802554,%eax
  80095d:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800960:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800964:	0f 8e 94 00 00 00    	jle    8009fe <vprintfmt+0x231>
  80096a:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80096e:	0f 84 98 00 00 00    	je     800a0c <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800974:	83 ec 08             	sub    $0x8,%esp
  800977:	ff 75 d0             	pushl  -0x30(%ebp)
  80097a:	57                   	push   %edi
  80097b:	e8 5b 03 00 00       	call   800cdb <strnlen>
  800980:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800983:	29 c1                	sub    %eax,%ecx
  800985:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800988:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80098b:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80098f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800992:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800995:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800997:	eb 0f                	jmp    8009a8 <vprintfmt+0x1db>
					putch(padc, putdat);
  800999:	83 ec 08             	sub    $0x8,%esp
  80099c:	53                   	push   %ebx
  80099d:	ff 75 e0             	pushl  -0x20(%ebp)
  8009a0:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009a2:	83 ef 01             	sub    $0x1,%edi
  8009a5:	83 c4 10             	add    $0x10,%esp
  8009a8:	85 ff                	test   %edi,%edi
  8009aa:	7f ed                	jg     800999 <vprintfmt+0x1cc>
  8009ac:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8009af:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8009b2:	85 c9                	test   %ecx,%ecx
  8009b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8009b9:	0f 49 c1             	cmovns %ecx,%eax
  8009bc:	29 c1                	sub    %eax,%ecx
  8009be:	89 75 08             	mov    %esi,0x8(%ebp)
  8009c1:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8009c4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8009c7:	89 cb                	mov    %ecx,%ebx
  8009c9:	eb 4d                	jmp    800a18 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8009cb:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8009cf:	74 1b                	je     8009ec <vprintfmt+0x21f>
  8009d1:	0f be c0             	movsbl %al,%eax
  8009d4:	83 e8 20             	sub    $0x20,%eax
  8009d7:	83 f8 5e             	cmp    $0x5e,%eax
  8009da:	76 10                	jbe    8009ec <vprintfmt+0x21f>
					putch('?', putdat);
  8009dc:	83 ec 08             	sub    $0x8,%esp
  8009df:	ff 75 0c             	pushl  0xc(%ebp)
  8009e2:	6a 3f                	push   $0x3f
  8009e4:	ff 55 08             	call   *0x8(%ebp)
  8009e7:	83 c4 10             	add    $0x10,%esp
  8009ea:	eb 0d                	jmp    8009f9 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  8009ec:	83 ec 08             	sub    $0x8,%esp
  8009ef:	ff 75 0c             	pushl  0xc(%ebp)
  8009f2:	52                   	push   %edx
  8009f3:	ff 55 08             	call   *0x8(%ebp)
  8009f6:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009f9:	83 eb 01             	sub    $0x1,%ebx
  8009fc:	eb 1a                	jmp    800a18 <vprintfmt+0x24b>
  8009fe:	89 75 08             	mov    %esi,0x8(%ebp)
  800a01:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a04:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a07:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800a0a:	eb 0c                	jmp    800a18 <vprintfmt+0x24b>
  800a0c:	89 75 08             	mov    %esi,0x8(%ebp)
  800a0f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a12:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a15:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800a18:	83 c7 01             	add    $0x1,%edi
  800a1b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800a1f:	0f be d0             	movsbl %al,%edx
  800a22:	85 d2                	test   %edx,%edx
  800a24:	74 23                	je     800a49 <vprintfmt+0x27c>
  800a26:	85 f6                	test   %esi,%esi
  800a28:	78 a1                	js     8009cb <vprintfmt+0x1fe>
  800a2a:	83 ee 01             	sub    $0x1,%esi
  800a2d:	79 9c                	jns    8009cb <vprintfmt+0x1fe>
  800a2f:	89 df                	mov    %ebx,%edi
  800a31:	8b 75 08             	mov    0x8(%ebp),%esi
  800a34:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a37:	eb 18                	jmp    800a51 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800a39:	83 ec 08             	sub    $0x8,%esp
  800a3c:	53                   	push   %ebx
  800a3d:	6a 20                	push   $0x20
  800a3f:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a41:	83 ef 01             	sub    $0x1,%edi
  800a44:	83 c4 10             	add    $0x10,%esp
  800a47:	eb 08                	jmp    800a51 <vprintfmt+0x284>
  800a49:	89 df                	mov    %ebx,%edi
  800a4b:	8b 75 08             	mov    0x8(%ebp),%esi
  800a4e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a51:	85 ff                	test   %edi,%edi
  800a53:	7f e4                	jg     800a39 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800a55:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800a58:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a5b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a5e:	e9 90 fd ff ff       	jmp    8007f3 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800a63:	83 f9 01             	cmp    $0x1,%ecx
  800a66:	7e 19                	jle    800a81 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800a68:	8b 45 14             	mov    0x14(%ebp),%eax
  800a6b:	8b 50 04             	mov    0x4(%eax),%edx
  800a6e:	8b 00                	mov    (%eax),%eax
  800a70:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800a73:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800a76:	8b 45 14             	mov    0x14(%ebp),%eax
  800a79:	8d 40 08             	lea    0x8(%eax),%eax
  800a7c:	89 45 14             	mov    %eax,0x14(%ebp)
  800a7f:	eb 38                	jmp    800ab9 <vprintfmt+0x2ec>
	else if (lflag)
  800a81:	85 c9                	test   %ecx,%ecx
  800a83:	74 1b                	je     800aa0 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800a85:	8b 45 14             	mov    0x14(%ebp),%eax
  800a88:	8b 00                	mov    (%eax),%eax
  800a8a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800a8d:	89 c1                	mov    %eax,%ecx
  800a8f:	c1 f9 1f             	sar    $0x1f,%ecx
  800a92:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800a95:	8b 45 14             	mov    0x14(%ebp),%eax
  800a98:	8d 40 04             	lea    0x4(%eax),%eax
  800a9b:	89 45 14             	mov    %eax,0x14(%ebp)
  800a9e:	eb 19                	jmp    800ab9 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800aa0:	8b 45 14             	mov    0x14(%ebp),%eax
  800aa3:	8b 00                	mov    (%eax),%eax
  800aa5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800aa8:	89 c1                	mov    %eax,%ecx
  800aaa:	c1 f9 1f             	sar    $0x1f,%ecx
  800aad:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800ab0:	8b 45 14             	mov    0x14(%ebp),%eax
  800ab3:	8d 40 04             	lea    0x4(%eax),%eax
  800ab6:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800ab9:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800abc:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800abf:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800ac4:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800ac8:	0f 89 36 01 00 00    	jns    800c04 <vprintfmt+0x437>
				putch('-', putdat);
  800ace:	83 ec 08             	sub    $0x8,%esp
  800ad1:	53                   	push   %ebx
  800ad2:	6a 2d                	push   $0x2d
  800ad4:	ff d6                	call   *%esi
				num = -(long long) num;
  800ad6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800ad9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800adc:	f7 da                	neg    %edx
  800ade:	83 d1 00             	adc    $0x0,%ecx
  800ae1:	f7 d9                	neg    %ecx
  800ae3:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800ae6:	b8 0a 00 00 00       	mov    $0xa,%eax
  800aeb:	e9 14 01 00 00       	jmp    800c04 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800af0:	83 f9 01             	cmp    $0x1,%ecx
  800af3:	7e 18                	jle    800b0d <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800af5:	8b 45 14             	mov    0x14(%ebp),%eax
  800af8:	8b 10                	mov    (%eax),%edx
  800afa:	8b 48 04             	mov    0x4(%eax),%ecx
  800afd:	8d 40 08             	lea    0x8(%eax),%eax
  800b00:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800b03:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b08:	e9 f7 00 00 00       	jmp    800c04 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800b0d:	85 c9                	test   %ecx,%ecx
  800b0f:	74 1a                	je     800b2b <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  800b11:	8b 45 14             	mov    0x14(%ebp),%eax
  800b14:	8b 10                	mov    (%eax),%edx
  800b16:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b1b:	8d 40 04             	lea    0x4(%eax),%eax
  800b1e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800b21:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b26:	e9 d9 00 00 00       	jmp    800c04 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800b2b:	8b 45 14             	mov    0x14(%ebp),%eax
  800b2e:	8b 10                	mov    (%eax),%edx
  800b30:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b35:	8d 40 04             	lea    0x4(%eax),%eax
  800b38:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800b3b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b40:	e9 bf 00 00 00       	jmp    800c04 <vprintfmt+0x437>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800b45:	83 f9 01             	cmp    $0x1,%ecx
  800b48:	7e 13                	jle    800b5d <vprintfmt+0x390>
		return va_arg(*ap, long long);
  800b4a:	8b 45 14             	mov    0x14(%ebp),%eax
  800b4d:	8b 50 04             	mov    0x4(%eax),%edx
  800b50:	8b 00                	mov    (%eax),%eax
  800b52:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800b55:	8d 49 08             	lea    0x8(%ecx),%ecx
  800b58:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800b5b:	eb 28                	jmp    800b85 <vprintfmt+0x3b8>
	else if (lflag)
  800b5d:	85 c9                	test   %ecx,%ecx
  800b5f:	74 13                	je     800b74 <vprintfmt+0x3a7>
		return va_arg(*ap, long);
  800b61:	8b 45 14             	mov    0x14(%ebp),%eax
  800b64:	8b 10                	mov    (%eax),%edx
  800b66:	89 d0                	mov    %edx,%eax
  800b68:	99                   	cltd   
  800b69:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800b6c:	8d 49 04             	lea    0x4(%ecx),%ecx
  800b6f:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800b72:	eb 11                	jmp    800b85 <vprintfmt+0x3b8>
	else
		return va_arg(*ap, int);
  800b74:	8b 45 14             	mov    0x14(%ebp),%eax
  800b77:	8b 10                	mov    (%eax),%edx
  800b79:	89 d0                	mov    %edx,%eax
  800b7b:	99                   	cltd   
  800b7c:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800b7f:	8d 49 04             	lea    0x4(%ecx),%ecx
  800b82:	89 4d 14             	mov    %ecx,0x14(%ebp)
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getint(&ap, lflag);
  800b85:	89 d1                	mov    %edx,%ecx
  800b87:	89 c2                	mov    %eax,%edx
			base = 8;
  800b89:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800b8e:	eb 74                	jmp    800c04 <vprintfmt+0x437>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800b90:	83 ec 08             	sub    $0x8,%esp
  800b93:	53                   	push   %ebx
  800b94:	6a 30                	push   $0x30
  800b96:	ff d6                	call   *%esi
			putch('x', putdat);
  800b98:	83 c4 08             	add    $0x8,%esp
  800b9b:	53                   	push   %ebx
  800b9c:	6a 78                	push   $0x78
  800b9e:	ff d6                	call   *%esi
			num = (unsigned long long)
  800ba0:	8b 45 14             	mov    0x14(%ebp),%eax
  800ba3:	8b 10                	mov    (%eax),%edx
  800ba5:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800baa:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800bad:	8d 40 04             	lea    0x4(%eax),%eax
  800bb0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800bb3:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800bb8:	eb 4a                	jmp    800c04 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800bba:	83 f9 01             	cmp    $0x1,%ecx
  800bbd:	7e 15                	jle    800bd4 <vprintfmt+0x407>
		return va_arg(*ap, unsigned long long);
  800bbf:	8b 45 14             	mov    0x14(%ebp),%eax
  800bc2:	8b 10                	mov    (%eax),%edx
  800bc4:	8b 48 04             	mov    0x4(%eax),%ecx
  800bc7:	8d 40 08             	lea    0x8(%eax),%eax
  800bca:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800bcd:	b8 10 00 00 00       	mov    $0x10,%eax
  800bd2:	eb 30                	jmp    800c04 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800bd4:	85 c9                	test   %ecx,%ecx
  800bd6:	74 17                	je     800bef <vprintfmt+0x422>
		return va_arg(*ap, unsigned long);
  800bd8:	8b 45 14             	mov    0x14(%ebp),%eax
  800bdb:	8b 10                	mov    (%eax),%edx
  800bdd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800be2:	8d 40 04             	lea    0x4(%eax),%eax
  800be5:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800be8:	b8 10 00 00 00       	mov    $0x10,%eax
  800bed:	eb 15                	jmp    800c04 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800bef:	8b 45 14             	mov    0x14(%ebp),%eax
  800bf2:	8b 10                	mov    (%eax),%edx
  800bf4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bf9:	8d 40 04             	lea    0x4(%eax),%eax
  800bfc:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800bff:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800c04:	83 ec 0c             	sub    $0xc,%esp
  800c07:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800c0b:	57                   	push   %edi
  800c0c:	ff 75 e0             	pushl  -0x20(%ebp)
  800c0f:	50                   	push   %eax
  800c10:	51                   	push   %ecx
  800c11:	52                   	push   %edx
  800c12:	89 da                	mov    %ebx,%edx
  800c14:	89 f0                	mov    %esi,%eax
  800c16:	e8 c9 fa ff ff       	call   8006e4 <printnum>
			break;
  800c1b:	83 c4 20             	add    $0x20,%esp
  800c1e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800c21:	e9 cd fb ff ff       	jmp    8007f3 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800c26:	83 ec 08             	sub    $0x8,%esp
  800c29:	53                   	push   %ebx
  800c2a:	52                   	push   %edx
  800c2b:	ff d6                	call   *%esi
			break;
  800c2d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c30:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800c33:	e9 bb fb ff ff       	jmp    8007f3 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800c38:	83 ec 08             	sub    $0x8,%esp
  800c3b:	53                   	push   %ebx
  800c3c:	6a 25                	push   $0x25
  800c3e:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c40:	83 c4 10             	add    $0x10,%esp
  800c43:	eb 03                	jmp    800c48 <vprintfmt+0x47b>
  800c45:	83 ef 01             	sub    $0x1,%edi
  800c48:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800c4c:	75 f7                	jne    800c45 <vprintfmt+0x478>
  800c4e:	e9 a0 fb ff ff       	jmp    8007f3 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800c53:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c56:	5b                   	pop    %ebx
  800c57:	5e                   	pop    %esi
  800c58:	5f                   	pop    %edi
  800c59:	5d                   	pop    %ebp
  800c5a:	c3                   	ret    

00800c5b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800c5b:	55                   	push   %ebp
  800c5c:	89 e5                	mov    %esp,%ebp
  800c5e:	83 ec 18             	sub    $0x18,%esp
  800c61:	8b 45 08             	mov    0x8(%ebp),%eax
  800c64:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800c67:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800c6a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800c6e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800c71:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800c78:	85 c0                	test   %eax,%eax
  800c7a:	74 26                	je     800ca2 <vsnprintf+0x47>
  800c7c:	85 d2                	test   %edx,%edx
  800c7e:	7e 22                	jle    800ca2 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800c80:	ff 75 14             	pushl  0x14(%ebp)
  800c83:	ff 75 10             	pushl  0x10(%ebp)
  800c86:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c89:	50                   	push   %eax
  800c8a:	68 93 07 80 00       	push   $0x800793
  800c8f:	e8 39 fb ff ff       	call   8007cd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c94:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c97:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c9d:	83 c4 10             	add    $0x10,%esp
  800ca0:	eb 05                	jmp    800ca7 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800ca2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800ca7:	c9                   	leave  
  800ca8:	c3                   	ret    

00800ca9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800ca9:	55                   	push   %ebp
  800caa:	89 e5                	mov    %esp,%ebp
  800cac:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800caf:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800cb2:	50                   	push   %eax
  800cb3:	ff 75 10             	pushl  0x10(%ebp)
  800cb6:	ff 75 0c             	pushl  0xc(%ebp)
  800cb9:	ff 75 08             	pushl  0x8(%ebp)
  800cbc:	e8 9a ff ff ff       	call   800c5b <vsnprintf>
	va_end(ap);

	return rc;
}
  800cc1:	c9                   	leave  
  800cc2:	c3                   	ret    

00800cc3 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800cc3:	55                   	push   %ebp
  800cc4:	89 e5                	mov    %esp,%ebp
  800cc6:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800cc9:	b8 00 00 00 00       	mov    $0x0,%eax
  800cce:	eb 03                	jmp    800cd3 <strlen+0x10>
		n++;
  800cd0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800cd3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800cd7:	75 f7                	jne    800cd0 <strlen+0xd>
		n++;
	return n;
}
  800cd9:	5d                   	pop    %ebp
  800cda:	c3                   	ret    

00800cdb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800cdb:	55                   	push   %ebp
  800cdc:	89 e5                	mov    %esp,%ebp
  800cde:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ce1:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ce4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce9:	eb 03                	jmp    800cee <strnlen+0x13>
		n++;
  800ceb:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cee:	39 c2                	cmp    %eax,%edx
  800cf0:	74 08                	je     800cfa <strnlen+0x1f>
  800cf2:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800cf6:	75 f3                	jne    800ceb <strnlen+0x10>
  800cf8:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800cfa:	5d                   	pop    %ebp
  800cfb:	c3                   	ret    

00800cfc <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800cfc:	55                   	push   %ebp
  800cfd:	89 e5                	mov    %esp,%ebp
  800cff:	53                   	push   %ebx
  800d00:	8b 45 08             	mov    0x8(%ebp),%eax
  800d03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800d06:	89 c2                	mov    %eax,%edx
  800d08:	83 c2 01             	add    $0x1,%edx
  800d0b:	83 c1 01             	add    $0x1,%ecx
  800d0e:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800d12:	88 5a ff             	mov    %bl,-0x1(%edx)
  800d15:	84 db                	test   %bl,%bl
  800d17:	75 ef                	jne    800d08 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800d19:	5b                   	pop    %ebx
  800d1a:	5d                   	pop    %ebp
  800d1b:	c3                   	ret    

00800d1c <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d1c:	55                   	push   %ebp
  800d1d:	89 e5                	mov    %esp,%ebp
  800d1f:	53                   	push   %ebx
  800d20:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800d23:	53                   	push   %ebx
  800d24:	e8 9a ff ff ff       	call   800cc3 <strlen>
  800d29:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800d2c:	ff 75 0c             	pushl  0xc(%ebp)
  800d2f:	01 d8                	add    %ebx,%eax
  800d31:	50                   	push   %eax
  800d32:	e8 c5 ff ff ff       	call   800cfc <strcpy>
	return dst;
}
  800d37:	89 d8                	mov    %ebx,%eax
  800d39:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d3c:	c9                   	leave  
  800d3d:	c3                   	ret    

00800d3e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d3e:	55                   	push   %ebp
  800d3f:	89 e5                	mov    %esp,%ebp
  800d41:	56                   	push   %esi
  800d42:	53                   	push   %ebx
  800d43:	8b 75 08             	mov    0x8(%ebp),%esi
  800d46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d49:	89 f3                	mov    %esi,%ebx
  800d4b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d4e:	89 f2                	mov    %esi,%edx
  800d50:	eb 0f                	jmp    800d61 <strncpy+0x23>
		*dst++ = *src;
  800d52:	83 c2 01             	add    $0x1,%edx
  800d55:	0f b6 01             	movzbl (%ecx),%eax
  800d58:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800d5b:	80 39 01             	cmpb   $0x1,(%ecx)
  800d5e:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d61:	39 da                	cmp    %ebx,%edx
  800d63:	75 ed                	jne    800d52 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800d65:	89 f0                	mov    %esi,%eax
  800d67:	5b                   	pop    %ebx
  800d68:	5e                   	pop    %esi
  800d69:	5d                   	pop    %ebp
  800d6a:	c3                   	ret    

00800d6b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d6b:	55                   	push   %ebp
  800d6c:	89 e5                	mov    %esp,%ebp
  800d6e:	56                   	push   %esi
  800d6f:	53                   	push   %ebx
  800d70:	8b 75 08             	mov    0x8(%ebp),%esi
  800d73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d76:	8b 55 10             	mov    0x10(%ebp),%edx
  800d79:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800d7b:	85 d2                	test   %edx,%edx
  800d7d:	74 21                	je     800da0 <strlcpy+0x35>
  800d7f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800d83:	89 f2                	mov    %esi,%edx
  800d85:	eb 09                	jmp    800d90 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800d87:	83 c2 01             	add    $0x1,%edx
  800d8a:	83 c1 01             	add    $0x1,%ecx
  800d8d:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d90:	39 c2                	cmp    %eax,%edx
  800d92:	74 09                	je     800d9d <strlcpy+0x32>
  800d94:	0f b6 19             	movzbl (%ecx),%ebx
  800d97:	84 db                	test   %bl,%bl
  800d99:	75 ec                	jne    800d87 <strlcpy+0x1c>
  800d9b:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800d9d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800da0:	29 f0                	sub    %esi,%eax
}
  800da2:	5b                   	pop    %ebx
  800da3:	5e                   	pop    %esi
  800da4:	5d                   	pop    %ebp
  800da5:	c3                   	ret    

00800da6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800da6:	55                   	push   %ebp
  800da7:	89 e5                	mov    %esp,%ebp
  800da9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dac:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800daf:	eb 06                	jmp    800db7 <strcmp+0x11>
		p++, q++;
  800db1:	83 c1 01             	add    $0x1,%ecx
  800db4:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800db7:	0f b6 01             	movzbl (%ecx),%eax
  800dba:	84 c0                	test   %al,%al
  800dbc:	74 04                	je     800dc2 <strcmp+0x1c>
  800dbe:	3a 02                	cmp    (%edx),%al
  800dc0:	74 ef                	je     800db1 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800dc2:	0f b6 c0             	movzbl %al,%eax
  800dc5:	0f b6 12             	movzbl (%edx),%edx
  800dc8:	29 d0                	sub    %edx,%eax
}
  800dca:	5d                   	pop    %ebp
  800dcb:	c3                   	ret    

00800dcc <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800dcc:	55                   	push   %ebp
  800dcd:	89 e5                	mov    %esp,%ebp
  800dcf:	53                   	push   %ebx
  800dd0:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dd6:	89 c3                	mov    %eax,%ebx
  800dd8:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800ddb:	eb 06                	jmp    800de3 <strncmp+0x17>
		n--, p++, q++;
  800ddd:	83 c0 01             	add    $0x1,%eax
  800de0:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800de3:	39 d8                	cmp    %ebx,%eax
  800de5:	74 15                	je     800dfc <strncmp+0x30>
  800de7:	0f b6 08             	movzbl (%eax),%ecx
  800dea:	84 c9                	test   %cl,%cl
  800dec:	74 04                	je     800df2 <strncmp+0x26>
  800dee:	3a 0a                	cmp    (%edx),%cl
  800df0:	74 eb                	je     800ddd <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800df2:	0f b6 00             	movzbl (%eax),%eax
  800df5:	0f b6 12             	movzbl (%edx),%edx
  800df8:	29 d0                	sub    %edx,%eax
  800dfa:	eb 05                	jmp    800e01 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800dfc:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800e01:	5b                   	pop    %ebx
  800e02:	5d                   	pop    %ebp
  800e03:	c3                   	ret    

00800e04 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e04:	55                   	push   %ebp
  800e05:	89 e5                	mov    %esp,%ebp
  800e07:	8b 45 08             	mov    0x8(%ebp),%eax
  800e0a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e0e:	eb 07                	jmp    800e17 <strchr+0x13>
		if (*s == c)
  800e10:	38 ca                	cmp    %cl,%dl
  800e12:	74 0f                	je     800e23 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800e14:	83 c0 01             	add    $0x1,%eax
  800e17:	0f b6 10             	movzbl (%eax),%edx
  800e1a:	84 d2                	test   %dl,%dl
  800e1c:	75 f2                	jne    800e10 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800e1e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e23:	5d                   	pop    %ebp
  800e24:	c3                   	ret    

00800e25 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e25:	55                   	push   %ebp
  800e26:	89 e5                	mov    %esp,%ebp
  800e28:	8b 45 08             	mov    0x8(%ebp),%eax
  800e2b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e2f:	eb 03                	jmp    800e34 <strfind+0xf>
  800e31:	83 c0 01             	add    $0x1,%eax
  800e34:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800e37:	38 ca                	cmp    %cl,%dl
  800e39:	74 04                	je     800e3f <strfind+0x1a>
  800e3b:	84 d2                	test   %dl,%dl
  800e3d:	75 f2                	jne    800e31 <strfind+0xc>
			break;
	return (char *) s;
}
  800e3f:	5d                   	pop    %ebp
  800e40:	c3                   	ret    

00800e41 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e41:	55                   	push   %ebp
  800e42:	89 e5                	mov    %esp,%ebp
  800e44:	57                   	push   %edi
  800e45:	56                   	push   %esi
  800e46:	53                   	push   %ebx
  800e47:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e4a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800e4d:	85 c9                	test   %ecx,%ecx
  800e4f:	74 36                	je     800e87 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800e51:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e57:	75 28                	jne    800e81 <memset+0x40>
  800e59:	f6 c1 03             	test   $0x3,%cl
  800e5c:	75 23                	jne    800e81 <memset+0x40>
		c &= 0xFF;
  800e5e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e62:	89 d3                	mov    %edx,%ebx
  800e64:	c1 e3 08             	shl    $0x8,%ebx
  800e67:	89 d6                	mov    %edx,%esi
  800e69:	c1 e6 18             	shl    $0x18,%esi
  800e6c:	89 d0                	mov    %edx,%eax
  800e6e:	c1 e0 10             	shl    $0x10,%eax
  800e71:	09 f0                	or     %esi,%eax
  800e73:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800e75:	89 d8                	mov    %ebx,%eax
  800e77:	09 d0                	or     %edx,%eax
  800e79:	c1 e9 02             	shr    $0x2,%ecx
  800e7c:	fc                   	cld    
  800e7d:	f3 ab                	rep stos %eax,%es:(%edi)
  800e7f:	eb 06                	jmp    800e87 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800e81:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e84:	fc                   	cld    
  800e85:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800e87:	89 f8                	mov    %edi,%eax
  800e89:	5b                   	pop    %ebx
  800e8a:	5e                   	pop    %esi
  800e8b:	5f                   	pop    %edi
  800e8c:	5d                   	pop    %ebp
  800e8d:	c3                   	ret    

00800e8e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800e8e:	55                   	push   %ebp
  800e8f:	89 e5                	mov    %esp,%ebp
  800e91:	57                   	push   %edi
  800e92:	56                   	push   %esi
  800e93:	8b 45 08             	mov    0x8(%ebp),%eax
  800e96:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e99:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800e9c:	39 c6                	cmp    %eax,%esi
  800e9e:	73 35                	jae    800ed5 <memmove+0x47>
  800ea0:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ea3:	39 d0                	cmp    %edx,%eax
  800ea5:	73 2e                	jae    800ed5 <memmove+0x47>
		s += n;
		d += n;
  800ea7:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800eaa:	89 d6                	mov    %edx,%esi
  800eac:	09 fe                	or     %edi,%esi
  800eae:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800eb4:	75 13                	jne    800ec9 <memmove+0x3b>
  800eb6:	f6 c1 03             	test   $0x3,%cl
  800eb9:	75 0e                	jne    800ec9 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800ebb:	83 ef 04             	sub    $0x4,%edi
  800ebe:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ec1:	c1 e9 02             	shr    $0x2,%ecx
  800ec4:	fd                   	std    
  800ec5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ec7:	eb 09                	jmp    800ed2 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ec9:	83 ef 01             	sub    $0x1,%edi
  800ecc:	8d 72 ff             	lea    -0x1(%edx),%esi
  800ecf:	fd                   	std    
  800ed0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ed2:	fc                   	cld    
  800ed3:	eb 1d                	jmp    800ef2 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ed5:	89 f2                	mov    %esi,%edx
  800ed7:	09 c2                	or     %eax,%edx
  800ed9:	f6 c2 03             	test   $0x3,%dl
  800edc:	75 0f                	jne    800eed <memmove+0x5f>
  800ede:	f6 c1 03             	test   $0x3,%cl
  800ee1:	75 0a                	jne    800eed <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800ee3:	c1 e9 02             	shr    $0x2,%ecx
  800ee6:	89 c7                	mov    %eax,%edi
  800ee8:	fc                   	cld    
  800ee9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800eeb:	eb 05                	jmp    800ef2 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800eed:	89 c7                	mov    %eax,%edi
  800eef:	fc                   	cld    
  800ef0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ef2:	5e                   	pop    %esi
  800ef3:	5f                   	pop    %edi
  800ef4:	5d                   	pop    %ebp
  800ef5:	c3                   	ret    

00800ef6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ef6:	55                   	push   %ebp
  800ef7:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800ef9:	ff 75 10             	pushl  0x10(%ebp)
  800efc:	ff 75 0c             	pushl  0xc(%ebp)
  800eff:	ff 75 08             	pushl  0x8(%ebp)
  800f02:	e8 87 ff ff ff       	call   800e8e <memmove>
}
  800f07:	c9                   	leave  
  800f08:	c3                   	ret    

00800f09 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800f09:	55                   	push   %ebp
  800f0a:	89 e5                	mov    %esp,%ebp
  800f0c:	56                   	push   %esi
  800f0d:	53                   	push   %ebx
  800f0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f11:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f14:	89 c6                	mov    %eax,%esi
  800f16:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f19:	eb 1a                	jmp    800f35 <memcmp+0x2c>
		if (*s1 != *s2)
  800f1b:	0f b6 08             	movzbl (%eax),%ecx
  800f1e:	0f b6 1a             	movzbl (%edx),%ebx
  800f21:	38 d9                	cmp    %bl,%cl
  800f23:	74 0a                	je     800f2f <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800f25:	0f b6 c1             	movzbl %cl,%eax
  800f28:	0f b6 db             	movzbl %bl,%ebx
  800f2b:	29 d8                	sub    %ebx,%eax
  800f2d:	eb 0f                	jmp    800f3e <memcmp+0x35>
		s1++, s2++;
  800f2f:	83 c0 01             	add    $0x1,%eax
  800f32:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f35:	39 f0                	cmp    %esi,%eax
  800f37:	75 e2                	jne    800f1b <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800f39:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f3e:	5b                   	pop    %ebx
  800f3f:	5e                   	pop    %esi
  800f40:	5d                   	pop    %ebp
  800f41:	c3                   	ret    

00800f42 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800f42:	55                   	push   %ebp
  800f43:	89 e5                	mov    %esp,%ebp
  800f45:	53                   	push   %ebx
  800f46:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800f49:	89 c1                	mov    %eax,%ecx
  800f4b:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800f4e:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800f52:	eb 0a                	jmp    800f5e <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800f54:	0f b6 10             	movzbl (%eax),%edx
  800f57:	39 da                	cmp    %ebx,%edx
  800f59:	74 07                	je     800f62 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800f5b:	83 c0 01             	add    $0x1,%eax
  800f5e:	39 c8                	cmp    %ecx,%eax
  800f60:	72 f2                	jb     800f54 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800f62:	5b                   	pop    %ebx
  800f63:	5d                   	pop    %ebp
  800f64:	c3                   	ret    

00800f65 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800f65:	55                   	push   %ebp
  800f66:	89 e5                	mov    %esp,%ebp
  800f68:	57                   	push   %edi
  800f69:	56                   	push   %esi
  800f6a:	53                   	push   %ebx
  800f6b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f6e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f71:	eb 03                	jmp    800f76 <strtol+0x11>
		s++;
  800f73:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f76:	0f b6 01             	movzbl (%ecx),%eax
  800f79:	3c 20                	cmp    $0x20,%al
  800f7b:	74 f6                	je     800f73 <strtol+0xe>
  800f7d:	3c 09                	cmp    $0x9,%al
  800f7f:	74 f2                	je     800f73 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800f81:	3c 2b                	cmp    $0x2b,%al
  800f83:	75 0a                	jne    800f8f <strtol+0x2a>
		s++;
  800f85:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800f88:	bf 00 00 00 00       	mov    $0x0,%edi
  800f8d:	eb 11                	jmp    800fa0 <strtol+0x3b>
  800f8f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800f94:	3c 2d                	cmp    $0x2d,%al
  800f96:	75 08                	jne    800fa0 <strtol+0x3b>
		s++, neg = 1;
  800f98:	83 c1 01             	add    $0x1,%ecx
  800f9b:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800fa0:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800fa6:	75 15                	jne    800fbd <strtol+0x58>
  800fa8:	80 39 30             	cmpb   $0x30,(%ecx)
  800fab:	75 10                	jne    800fbd <strtol+0x58>
  800fad:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800fb1:	75 7c                	jne    80102f <strtol+0xca>
		s += 2, base = 16;
  800fb3:	83 c1 02             	add    $0x2,%ecx
  800fb6:	bb 10 00 00 00       	mov    $0x10,%ebx
  800fbb:	eb 16                	jmp    800fd3 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800fbd:	85 db                	test   %ebx,%ebx
  800fbf:	75 12                	jne    800fd3 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800fc1:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800fc6:	80 39 30             	cmpb   $0x30,(%ecx)
  800fc9:	75 08                	jne    800fd3 <strtol+0x6e>
		s++, base = 8;
  800fcb:	83 c1 01             	add    $0x1,%ecx
  800fce:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800fd3:	b8 00 00 00 00       	mov    $0x0,%eax
  800fd8:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800fdb:	0f b6 11             	movzbl (%ecx),%edx
  800fde:	8d 72 d0             	lea    -0x30(%edx),%esi
  800fe1:	89 f3                	mov    %esi,%ebx
  800fe3:	80 fb 09             	cmp    $0x9,%bl
  800fe6:	77 08                	ja     800ff0 <strtol+0x8b>
			dig = *s - '0';
  800fe8:	0f be d2             	movsbl %dl,%edx
  800feb:	83 ea 30             	sub    $0x30,%edx
  800fee:	eb 22                	jmp    801012 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ff0:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ff3:	89 f3                	mov    %esi,%ebx
  800ff5:	80 fb 19             	cmp    $0x19,%bl
  800ff8:	77 08                	ja     801002 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ffa:	0f be d2             	movsbl %dl,%edx
  800ffd:	83 ea 57             	sub    $0x57,%edx
  801000:	eb 10                	jmp    801012 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801002:	8d 72 bf             	lea    -0x41(%edx),%esi
  801005:	89 f3                	mov    %esi,%ebx
  801007:	80 fb 19             	cmp    $0x19,%bl
  80100a:	77 16                	ja     801022 <strtol+0xbd>
			dig = *s - 'A' + 10;
  80100c:	0f be d2             	movsbl %dl,%edx
  80100f:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801012:	3b 55 10             	cmp    0x10(%ebp),%edx
  801015:	7d 0b                	jge    801022 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801017:	83 c1 01             	add    $0x1,%ecx
  80101a:	0f af 45 10          	imul   0x10(%ebp),%eax
  80101e:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801020:	eb b9                	jmp    800fdb <strtol+0x76>

	if (endptr)
  801022:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801026:	74 0d                	je     801035 <strtol+0xd0>
		*endptr = (char *) s;
  801028:	8b 75 0c             	mov    0xc(%ebp),%esi
  80102b:	89 0e                	mov    %ecx,(%esi)
  80102d:	eb 06                	jmp    801035 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80102f:	85 db                	test   %ebx,%ebx
  801031:	74 98                	je     800fcb <strtol+0x66>
  801033:	eb 9e                	jmp    800fd3 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801035:	89 c2                	mov    %eax,%edx
  801037:	f7 da                	neg    %edx
  801039:	85 ff                	test   %edi,%edi
  80103b:	0f 45 c2             	cmovne %edx,%eax
}
  80103e:	5b                   	pop    %ebx
  80103f:	5e                   	pop    %esi
  801040:	5f                   	pop    %edi
  801041:	5d                   	pop    %ebp
  801042:	c3                   	ret    

00801043 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801043:	55                   	push   %ebp
  801044:	89 e5                	mov    %esp,%ebp
  801046:	57                   	push   %edi
  801047:	56                   	push   %esi
  801048:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801049:	b8 00 00 00 00       	mov    $0x0,%eax
  80104e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801051:	8b 55 08             	mov    0x8(%ebp),%edx
  801054:	89 c3                	mov    %eax,%ebx
  801056:	89 c7                	mov    %eax,%edi
  801058:	89 c6                	mov    %eax,%esi
  80105a:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80105c:	5b                   	pop    %ebx
  80105d:	5e                   	pop    %esi
  80105e:	5f                   	pop    %edi
  80105f:	5d                   	pop    %ebp
  801060:	c3                   	ret    

00801061 <sys_cgetc>:

int
sys_cgetc(void)
{
  801061:	55                   	push   %ebp
  801062:	89 e5                	mov    %esp,%ebp
  801064:	57                   	push   %edi
  801065:	56                   	push   %esi
  801066:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801067:	ba 00 00 00 00       	mov    $0x0,%edx
  80106c:	b8 01 00 00 00       	mov    $0x1,%eax
  801071:	89 d1                	mov    %edx,%ecx
  801073:	89 d3                	mov    %edx,%ebx
  801075:	89 d7                	mov    %edx,%edi
  801077:	89 d6                	mov    %edx,%esi
  801079:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80107b:	5b                   	pop    %ebx
  80107c:	5e                   	pop    %esi
  80107d:	5f                   	pop    %edi
  80107e:	5d                   	pop    %ebp
  80107f:	c3                   	ret    

00801080 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  801080:	55                   	push   %ebp
  801081:	89 e5                	mov    %esp,%ebp
  801083:	57                   	push   %edi
  801084:	56                   	push   %esi
  801085:	53                   	push   %ebx
  801086:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801089:	b9 00 00 00 00       	mov    $0x0,%ecx
  80108e:	b8 03 00 00 00       	mov    $0x3,%eax
  801093:	8b 55 08             	mov    0x8(%ebp),%edx
  801096:	89 cb                	mov    %ecx,%ebx
  801098:	89 cf                	mov    %ecx,%edi
  80109a:	89 ce                	mov    %ecx,%esi
  80109c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80109e:	85 c0                	test   %eax,%eax
  8010a0:	7e 17                	jle    8010b9 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010a2:	83 ec 0c             	sub    $0xc,%esp
  8010a5:	50                   	push   %eax
  8010a6:	6a 03                	push   $0x3
  8010a8:	68 3f 28 80 00       	push   $0x80283f
  8010ad:	6a 23                	push   $0x23
  8010af:	68 5c 28 80 00       	push   $0x80285c
  8010b4:	e8 3e f5 ff ff       	call   8005f7 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8010b9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010bc:	5b                   	pop    %ebx
  8010bd:	5e                   	pop    %esi
  8010be:	5f                   	pop    %edi
  8010bf:	5d                   	pop    %ebp
  8010c0:	c3                   	ret    

008010c1 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8010c1:	55                   	push   %ebp
  8010c2:	89 e5                	mov    %esp,%ebp
  8010c4:	57                   	push   %edi
  8010c5:	56                   	push   %esi
  8010c6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8010cc:	b8 02 00 00 00       	mov    $0x2,%eax
  8010d1:	89 d1                	mov    %edx,%ecx
  8010d3:	89 d3                	mov    %edx,%ebx
  8010d5:	89 d7                	mov    %edx,%edi
  8010d7:	89 d6                	mov    %edx,%esi
  8010d9:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8010db:	5b                   	pop    %ebx
  8010dc:	5e                   	pop    %esi
  8010dd:	5f                   	pop    %edi
  8010de:	5d                   	pop    %ebp
  8010df:	c3                   	ret    

008010e0 <sys_yield>:

void
sys_yield(void)
{
  8010e0:	55                   	push   %ebp
  8010e1:	89 e5                	mov    %esp,%ebp
  8010e3:	57                   	push   %edi
  8010e4:	56                   	push   %esi
  8010e5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8010eb:	b8 0b 00 00 00       	mov    $0xb,%eax
  8010f0:	89 d1                	mov    %edx,%ecx
  8010f2:	89 d3                	mov    %edx,%ebx
  8010f4:	89 d7                	mov    %edx,%edi
  8010f6:	89 d6                	mov    %edx,%esi
  8010f8:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8010fa:	5b                   	pop    %ebx
  8010fb:	5e                   	pop    %esi
  8010fc:	5f                   	pop    %edi
  8010fd:	5d                   	pop    %ebp
  8010fe:	c3                   	ret    

008010ff <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8010ff:	55                   	push   %ebp
  801100:	89 e5                	mov    %esp,%ebp
  801102:	57                   	push   %edi
  801103:	56                   	push   %esi
  801104:	53                   	push   %ebx
  801105:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801108:	be 00 00 00 00       	mov    $0x0,%esi
  80110d:	b8 04 00 00 00       	mov    $0x4,%eax
  801112:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801115:	8b 55 08             	mov    0x8(%ebp),%edx
  801118:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80111b:	89 f7                	mov    %esi,%edi
  80111d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80111f:	85 c0                	test   %eax,%eax
  801121:	7e 17                	jle    80113a <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801123:	83 ec 0c             	sub    $0xc,%esp
  801126:	50                   	push   %eax
  801127:	6a 04                	push   $0x4
  801129:	68 3f 28 80 00       	push   $0x80283f
  80112e:	6a 23                	push   $0x23
  801130:	68 5c 28 80 00       	push   $0x80285c
  801135:	e8 bd f4 ff ff       	call   8005f7 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80113a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80113d:	5b                   	pop    %ebx
  80113e:	5e                   	pop    %esi
  80113f:	5f                   	pop    %edi
  801140:	5d                   	pop    %ebp
  801141:	c3                   	ret    

00801142 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801142:	55                   	push   %ebp
  801143:	89 e5                	mov    %esp,%ebp
  801145:	57                   	push   %edi
  801146:	56                   	push   %esi
  801147:	53                   	push   %ebx
  801148:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80114b:	b8 05 00 00 00       	mov    $0x5,%eax
  801150:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801153:	8b 55 08             	mov    0x8(%ebp),%edx
  801156:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801159:	8b 7d 14             	mov    0x14(%ebp),%edi
  80115c:	8b 75 18             	mov    0x18(%ebp),%esi
  80115f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801161:	85 c0                	test   %eax,%eax
  801163:	7e 17                	jle    80117c <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801165:	83 ec 0c             	sub    $0xc,%esp
  801168:	50                   	push   %eax
  801169:	6a 05                	push   $0x5
  80116b:	68 3f 28 80 00       	push   $0x80283f
  801170:	6a 23                	push   $0x23
  801172:	68 5c 28 80 00       	push   $0x80285c
  801177:	e8 7b f4 ff ff       	call   8005f7 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80117c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80117f:	5b                   	pop    %ebx
  801180:	5e                   	pop    %esi
  801181:	5f                   	pop    %edi
  801182:	5d                   	pop    %ebp
  801183:	c3                   	ret    

00801184 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801184:	55                   	push   %ebp
  801185:	89 e5                	mov    %esp,%ebp
  801187:	57                   	push   %edi
  801188:	56                   	push   %esi
  801189:	53                   	push   %ebx
  80118a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80118d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801192:	b8 06 00 00 00       	mov    $0x6,%eax
  801197:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80119a:	8b 55 08             	mov    0x8(%ebp),%edx
  80119d:	89 df                	mov    %ebx,%edi
  80119f:	89 de                	mov    %ebx,%esi
  8011a1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8011a3:	85 c0                	test   %eax,%eax
  8011a5:	7e 17                	jle    8011be <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011a7:	83 ec 0c             	sub    $0xc,%esp
  8011aa:	50                   	push   %eax
  8011ab:	6a 06                	push   $0x6
  8011ad:	68 3f 28 80 00       	push   $0x80283f
  8011b2:	6a 23                	push   $0x23
  8011b4:	68 5c 28 80 00       	push   $0x80285c
  8011b9:	e8 39 f4 ff ff       	call   8005f7 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8011be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011c1:	5b                   	pop    %ebx
  8011c2:	5e                   	pop    %esi
  8011c3:	5f                   	pop    %edi
  8011c4:	5d                   	pop    %ebp
  8011c5:	c3                   	ret    

008011c6 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8011c6:	55                   	push   %ebp
  8011c7:	89 e5                	mov    %esp,%ebp
  8011c9:	57                   	push   %edi
  8011ca:	56                   	push   %esi
  8011cb:	53                   	push   %ebx
  8011cc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011cf:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011d4:	b8 08 00 00 00       	mov    $0x8,%eax
  8011d9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8011df:	89 df                	mov    %ebx,%edi
  8011e1:	89 de                	mov    %ebx,%esi
  8011e3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8011e5:	85 c0                	test   %eax,%eax
  8011e7:	7e 17                	jle    801200 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011e9:	83 ec 0c             	sub    $0xc,%esp
  8011ec:	50                   	push   %eax
  8011ed:	6a 08                	push   $0x8
  8011ef:	68 3f 28 80 00       	push   $0x80283f
  8011f4:	6a 23                	push   $0x23
  8011f6:	68 5c 28 80 00       	push   $0x80285c
  8011fb:	e8 f7 f3 ff ff       	call   8005f7 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801200:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801203:	5b                   	pop    %ebx
  801204:	5e                   	pop    %esi
  801205:	5f                   	pop    %edi
  801206:	5d                   	pop    %ebp
  801207:	c3                   	ret    

00801208 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801208:	55                   	push   %ebp
  801209:	89 e5                	mov    %esp,%ebp
  80120b:	57                   	push   %edi
  80120c:	56                   	push   %esi
  80120d:	53                   	push   %ebx
  80120e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801211:	bb 00 00 00 00       	mov    $0x0,%ebx
  801216:	b8 09 00 00 00       	mov    $0x9,%eax
  80121b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80121e:	8b 55 08             	mov    0x8(%ebp),%edx
  801221:	89 df                	mov    %ebx,%edi
  801223:	89 de                	mov    %ebx,%esi
  801225:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801227:	85 c0                	test   %eax,%eax
  801229:	7e 17                	jle    801242 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80122b:	83 ec 0c             	sub    $0xc,%esp
  80122e:	50                   	push   %eax
  80122f:	6a 09                	push   $0x9
  801231:	68 3f 28 80 00       	push   $0x80283f
  801236:	6a 23                	push   $0x23
  801238:	68 5c 28 80 00       	push   $0x80285c
  80123d:	e8 b5 f3 ff ff       	call   8005f7 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801242:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801245:	5b                   	pop    %ebx
  801246:	5e                   	pop    %esi
  801247:	5f                   	pop    %edi
  801248:	5d                   	pop    %ebp
  801249:	c3                   	ret    

0080124a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80124a:	55                   	push   %ebp
  80124b:	89 e5                	mov    %esp,%ebp
  80124d:	57                   	push   %edi
  80124e:	56                   	push   %esi
  80124f:	53                   	push   %ebx
  801250:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801253:	bb 00 00 00 00       	mov    $0x0,%ebx
  801258:	b8 0a 00 00 00       	mov    $0xa,%eax
  80125d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801260:	8b 55 08             	mov    0x8(%ebp),%edx
  801263:	89 df                	mov    %ebx,%edi
  801265:	89 de                	mov    %ebx,%esi
  801267:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801269:	85 c0                	test   %eax,%eax
  80126b:	7e 17                	jle    801284 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80126d:	83 ec 0c             	sub    $0xc,%esp
  801270:	50                   	push   %eax
  801271:	6a 0a                	push   $0xa
  801273:	68 3f 28 80 00       	push   $0x80283f
  801278:	6a 23                	push   $0x23
  80127a:	68 5c 28 80 00       	push   $0x80285c
  80127f:	e8 73 f3 ff ff       	call   8005f7 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801284:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801287:	5b                   	pop    %ebx
  801288:	5e                   	pop    %esi
  801289:	5f                   	pop    %edi
  80128a:	5d                   	pop    %ebp
  80128b:	c3                   	ret    

0080128c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80128c:	55                   	push   %ebp
  80128d:	89 e5                	mov    %esp,%ebp
  80128f:	57                   	push   %edi
  801290:	56                   	push   %esi
  801291:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801292:	be 00 00 00 00       	mov    $0x0,%esi
  801297:	b8 0c 00 00 00       	mov    $0xc,%eax
  80129c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80129f:	8b 55 08             	mov    0x8(%ebp),%edx
  8012a2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8012a5:	8b 7d 14             	mov    0x14(%ebp),%edi
  8012a8:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8012aa:	5b                   	pop    %ebx
  8012ab:	5e                   	pop    %esi
  8012ac:	5f                   	pop    %edi
  8012ad:	5d                   	pop    %ebp
  8012ae:	c3                   	ret    

008012af <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8012af:	55                   	push   %ebp
  8012b0:	89 e5                	mov    %esp,%ebp
  8012b2:	57                   	push   %edi
  8012b3:	56                   	push   %esi
  8012b4:	53                   	push   %ebx
  8012b5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012b8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012bd:	b8 0d 00 00 00       	mov    $0xd,%eax
  8012c2:	8b 55 08             	mov    0x8(%ebp),%edx
  8012c5:	89 cb                	mov    %ecx,%ebx
  8012c7:	89 cf                	mov    %ecx,%edi
  8012c9:	89 ce                	mov    %ecx,%esi
  8012cb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8012cd:	85 c0                	test   %eax,%eax
  8012cf:	7e 17                	jle    8012e8 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012d1:	83 ec 0c             	sub    $0xc,%esp
  8012d4:	50                   	push   %eax
  8012d5:	6a 0d                	push   $0xd
  8012d7:	68 3f 28 80 00       	push   $0x80283f
  8012dc:	6a 23                	push   $0x23
  8012de:	68 5c 28 80 00       	push   $0x80285c
  8012e3:	e8 0f f3 ff ff       	call   8005f7 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8012e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012eb:	5b                   	pop    %ebx
  8012ec:	5e                   	pop    %esi
  8012ed:	5f                   	pop    %edi
  8012ee:	5d                   	pop    %ebp
  8012ef:	c3                   	ret    

008012f0 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8012f0:	55                   	push   %ebp
  8012f1:	89 e5                	mov    %esp,%ebp
  8012f3:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8012f6:	83 3d b4 40 80 00 00 	cmpl   $0x0,0x8040b4
  8012fd:	75 31                	jne    801330 <set_pgfault_handler+0x40>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc(thisenv->env_id, (void*)(UXSTACKTOP - PGSIZE), PTE_P | 
  8012ff:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801304:	8b 40 48             	mov    0x48(%eax),%eax
  801307:	83 ec 04             	sub    $0x4,%esp
  80130a:	6a 07                	push   $0x7
  80130c:	68 00 f0 bf ee       	push   $0xeebff000
  801311:	50                   	push   %eax
  801312:	e8 e8 fd ff ff       	call   8010ff <sys_page_alloc>
				PTE_U | PTE_W);
		sys_env_set_pgfault_upcall(thisenv->env_id, (void*)_pgfault_upcall);
  801317:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  80131c:	8b 40 48             	mov    0x48(%eax),%eax
  80131f:	83 c4 08             	add    $0x8,%esp
  801322:	68 3a 13 80 00       	push   $0x80133a
  801327:	50                   	push   %eax
  801328:	e8 1d ff ff ff       	call   80124a <sys_env_set_pgfault_upcall>
  80132d:	83 c4 10             	add    $0x10,%esp

		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801330:	8b 45 08             	mov    0x8(%ebp),%eax
  801333:	a3 b4 40 80 00       	mov    %eax,0x8040b4
}
  801338:	c9                   	leave  
  801339:	c3                   	ret    

0080133a <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80133a:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80133b:	a1 b4 40 80 00       	mov    0x8040b4,%eax
	call *%eax
  801340:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801342:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	addl $8, %esp      // pop utf_fault_va and utf_err
  801345:	83 c4 08             	add    $0x8,%esp
	movl 32(%esp), %eax  // eax <- [esp + 32]
  801348:	8b 44 24 20          	mov    0x20(%esp),%eax
	movl 40(%esp), %ebx  // ebx <- [esp + 40]
  80134c:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	leal -4(%ebx), %ebx  // ebx <- ebx - 4
  801350:	8d 5b fc             	lea    -0x4(%ebx),%ebx
	movl %eax, (%ebx)
  801353:	89 03                	mov    %eax,(%ebx)
	movl %ebx, 40(%esp)  // push trap eip and decrement trap esp manually
  801355:	89 5c 24 28          	mov    %ebx,0x28(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  801359:	61                   	popa   
	addl $4, %esp        // skip eip
  80135a:	83 c4 04             	add    $0x4,%esp

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	popf
  80135d:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	pop %esp
  80135e:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80135f:	c3                   	ret    

00801360 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801360:	55                   	push   %ebp
  801361:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801363:	8b 45 08             	mov    0x8(%ebp),%eax
  801366:	05 00 00 00 30       	add    $0x30000000,%eax
  80136b:	c1 e8 0c             	shr    $0xc,%eax
}
  80136e:	5d                   	pop    %ebp
  80136f:	c3                   	ret    

00801370 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801370:	55                   	push   %ebp
  801371:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801373:	8b 45 08             	mov    0x8(%ebp),%eax
  801376:	05 00 00 00 30       	add    $0x30000000,%eax
  80137b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801380:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801385:	5d                   	pop    %ebp
  801386:	c3                   	ret    

00801387 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801387:	55                   	push   %ebp
  801388:	89 e5                	mov    %esp,%ebp
  80138a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80138d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801392:	89 c2                	mov    %eax,%edx
  801394:	c1 ea 16             	shr    $0x16,%edx
  801397:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80139e:	f6 c2 01             	test   $0x1,%dl
  8013a1:	74 11                	je     8013b4 <fd_alloc+0x2d>
  8013a3:	89 c2                	mov    %eax,%edx
  8013a5:	c1 ea 0c             	shr    $0xc,%edx
  8013a8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013af:	f6 c2 01             	test   $0x1,%dl
  8013b2:	75 09                	jne    8013bd <fd_alloc+0x36>
			*fd_store = fd;
  8013b4:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8013bb:	eb 17                	jmp    8013d4 <fd_alloc+0x4d>
  8013bd:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8013c2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8013c7:	75 c9                	jne    801392 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8013c9:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8013cf:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8013d4:	5d                   	pop    %ebp
  8013d5:	c3                   	ret    

008013d6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8013d6:	55                   	push   %ebp
  8013d7:	89 e5                	mov    %esp,%ebp
  8013d9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8013dc:	83 f8 1f             	cmp    $0x1f,%eax
  8013df:	77 36                	ja     801417 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8013e1:	c1 e0 0c             	shl    $0xc,%eax
  8013e4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8013e9:	89 c2                	mov    %eax,%edx
  8013eb:	c1 ea 16             	shr    $0x16,%edx
  8013ee:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013f5:	f6 c2 01             	test   $0x1,%dl
  8013f8:	74 24                	je     80141e <fd_lookup+0x48>
  8013fa:	89 c2                	mov    %eax,%edx
  8013fc:	c1 ea 0c             	shr    $0xc,%edx
  8013ff:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801406:	f6 c2 01             	test   $0x1,%dl
  801409:	74 1a                	je     801425 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80140b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80140e:	89 02                	mov    %eax,(%edx)
	return 0;
  801410:	b8 00 00 00 00       	mov    $0x0,%eax
  801415:	eb 13                	jmp    80142a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801417:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80141c:	eb 0c                	jmp    80142a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80141e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801423:	eb 05                	jmp    80142a <fd_lookup+0x54>
  801425:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80142a:	5d                   	pop    %ebp
  80142b:	c3                   	ret    

0080142c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80142c:	55                   	push   %ebp
  80142d:	89 e5                	mov    %esp,%ebp
  80142f:	83 ec 08             	sub    $0x8,%esp
  801432:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801435:	ba ec 28 80 00       	mov    $0x8028ec,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80143a:	eb 13                	jmp    80144f <dev_lookup+0x23>
  80143c:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80143f:	39 08                	cmp    %ecx,(%eax)
  801441:	75 0c                	jne    80144f <dev_lookup+0x23>
			*dev = devtab[i];
  801443:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801446:	89 01                	mov    %eax,(%ecx)
			return 0;
  801448:	b8 00 00 00 00       	mov    $0x0,%eax
  80144d:	eb 2e                	jmp    80147d <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80144f:	8b 02                	mov    (%edx),%eax
  801451:	85 c0                	test   %eax,%eax
  801453:	75 e7                	jne    80143c <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801455:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  80145a:	8b 40 48             	mov    0x48(%eax),%eax
  80145d:	83 ec 04             	sub    $0x4,%esp
  801460:	51                   	push   %ecx
  801461:	50                   	push   %eax
  801462:	68 6c 28 80 00       	push   $0x80286c
  801467:	e8 64 f2 ff ff       	call   8006d0 <cprintf>
	*dev = 0;
  80146c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80146f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801475:	83 c4 10             	add    $0x10,%esp
  801478:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80147d:	c9                   	leave  
  80147e:	c3                   	ret    

0080147f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80147f:	55                   	push   %ebp
  801480:	89 e5                	mov    %esp,%ebp
  801482:	56                   	push   %esi
  801483:	53                   	push   %ebx
  801484:	83 ec 10             	sub    $0x10,%esp
  801487:	8b 75 08             	mov    0x8(%ebp),%esi
  80148a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80148d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801490:	50                   	push   %eax
  801491:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801497:	c1 e8 0c             	shr    $0xc,%eax
  80149a:	50                   	push   %eax
  80149b:	e8 36 ff ff ff       	call   8013d6 <fd_lookup>
  8014a0:	83 c4 08             	add    $0x8,%esp
  8014a3:	85 c0                	test   %eax,%eax
  8014a5:	78 05                	js     8014ac <fd_close+0x2d>
	    || fd != fd2)
  8014a7:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8014aa:	74 0c                	je     8014b8 <fd_close+0x39>
		return (must_exist ? r : 0);
  8014ac:	84 db                	test   %bl,%bl
  8014ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8014b3:	0f 44 c2             	cmove  %edx,%eax
  8014b6:	eb 41                	jmp    8014f9 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8014b8:	83 ec 08             	sub    $0x8,%esp
  8014bb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014be:	50                   	push   %eax
  8014bf:	ff 36                	pushl  (%esi)
  8014c1:	e8 66 ff ff ff       	call   80142c <dev_lookup>
  8014c6:	89 c3                	mov    %eax,%ebx
  8014c8:	83 c4 10             	add    $0x10,%esp
  8014cb:	85 c0                	test   %eax,%eax
  8014cd:	78 1a                	js     8014e9 <fd_close+0x6a>
		if (dev->dev_close)
  8014cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014d2:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8014d5:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8014da:	85 c0                	test   %eax,%eax
  8014dc:	74 0b                	je     8014e9 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8014de:	83 ec 0c             	sub    $0xc,%esp
  8014e1:	56                   	push   %esi
  8014e2:	ff d0                	call   *%eax
  8014e4:	89 c3                	mov    %eax,%ebx
  8014e6:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8014e9:	83 ec 08             	sub    $0x8,%esp
  8014ec:	56                   	push   %esi
  8014ed:	6a 00                	push   $0x0
  8014ef:	e8 90 fc ff ff       	call   801184 <sys_page_unmap>
	return r;
  8014f4:	83 c4 10             	add    $0x10,%esp
  8014f7:	89 d8                	mov    %ebx,%eax
}
  8014f9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014fc:	5b                   	pop    %ebx
  8014fd:	5e                   	pop    %esi
  8014fe:	5d                   	pop    %ebp
  8014ff:	c3                   	ret    

00801500 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801500:	55                   	push   %ebp
  801501:	89 e5                	mov    %esp,%ebp
  801503:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801506:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801509:	50                   	push   %eax
  80150a:	ff 75 08             	pushl  0x8(%ebp)
  80150d:	e8 c4 fe ff ff       	call   8013d6 <fd_lookup>
  801512:	83 c4 08             	add    $0x8,%esp
  801515:	85 c0                	test   %eax,%eax
  801517:	78 10                	js     801529 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801519:	83 ec 08             	sub    $0x8,%esp
  80151c:	6a 01                	push   $0x1
  80151e:	ff 75 f4             	pushl  -0xc(%ebp)
  801521:	e8 59 ff ff ff       	call   80147f <fd_close>
  801526:	83 c4 10             	add    $0x10,%esp
}
  801529:	c9                   	leave  
  80152a:	c3                   	ret    

0080152b <close_all>:

void
close_all(void)
{
  80152b:	55                   	push   %ebp
  80152c:	89 e5                	mov    %esp,%ebp
  80152e:	53                   	push   %ebx
  80152f:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801532:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801537:	83 ec 0c             	sub    $0xc,%esp
  80153a:	53                   	push   %ebx
  80153b:	e8 c0 ff ff ff       	call   801500 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801540:	83 c3 01             	add    $0x1,%ebx
  801543:	83 c4 10             	add    $0x10,%esp
  801546:	83 fb 20             	cmp    $0x20,%ebx
  801549:	75 ec                	jne    801537 <close_all+0xc>
		close(i);
}
  80154b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80154e:	c9                   	leave  
  80154f:	c3                   	ret    

00801550 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801550:	55                   	push   %ebp
  801551:	89 e5                	mov    %esp,%ebp
  801553:	57                   	push   %edi
  801554:	56                   	push   %esi
  801555:	53                   	push   %ebx
  801556:	83 ec 2c             	sub    $0x2c,%esp
  801559:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80155c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80155f:	50                   	push   %eax
  801560:	ff 75 08             	pushl  0x8(%ebp)
  801563:	e8 6e fe ff ff       	call   8013d6 <fd_lookup>
  801568:	83 c4 08             	add    $0x8,%esp
  80156b:	85 c0                	test   %eax,%eax
  80156d:	0f 88 c1 00 00 00    	js     801634 <dup+0xe4>
		return r;
	close(newfdnum);
  801573:	83 ec 0c             	sub    $0xc,%esp
  801576:	56                   	push   %esi
  801577:	e8 84 ff ff ff       	call   801500 <close>

	newfd = INDEX2FD(newfdnum);
  80157c:	89 f3                	mov    %esi,%ebx
  80157e:	c1 e3 0c             	shl    $0xc,%ebx
  801581:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801587:	83 c4 04             	add    $0x4,%esp
  80158a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80158d:	e8 de fd ff ff       	call   801370 <fd2data>
  801592:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801594:	89 1c 24             	mov    %ebx,(%esp)
  801597:	e8 d4 fd ff ff       	call   801370 <fd2data>
  80159c:	83 c4 10             	add    $0x10,%esp
  80159f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8015a2:	89 f8                	mov    %edi,%eax
  8015a4:	c1 e8 16             	shr    $0x16,%eax
  8015a7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8015ae:	a8 01                	test   $0x1,%al
  8015b0:	74 37                	je     8015e9 <dup+0x99>
  8015b2:	89 f8                	mov    %edi,%eax
  8015b4:	c1 e8 0c             	shr    $0xc,%eax
  8015b7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8015be:	f6 c2 01             	test   $0x1,%dl
  8015c1:	74 26                	je     8015e9 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8015c3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015ca:	83 ec 0c             	sub    $0xc,%esp
  8015cd:	25 07 0e 00 00       	and    $0xe07,%eax
  8015d2:	50                   	push   %eax
  8015d3:	ff 75 d4             	pushl  -0x2c(%ebp)
  8015d6:	6a 00                	push   $0x0
  8015d8:	57                   	push   %edi
  8015d9:	6a 00                	push   $0x0
  8015db:	e8 62 fb ff ff       	call   801142 <sys_page_map>
  8015e0:	89 c7                	mov    %eax,%edi
  8015e2:	83 c4 20             	add    $0x20,%esp
  8015e5:	85 c0                	test   %eax,%eax
  8015e7:	78 2e                	js     801617 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015e9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8015ec:	89 d0                	mov    %edx,%eax
  8015ee:	c1 e8 0c             	shr    $0xc,%eax
  8015f1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015f8:	83 ec 0c             	sub    $0xc,%esp
  8015fb:	25 07 0e 00 00       	and    $0xe07,%eax
  801600:	50                   	push   %eax
  801601:	53                   	push   %ebx
  801602:	6a 00                	push   $0x0
  801604:	52                   	push   %edx
  801605:	6a 00                	push   $0x0
  801607:	e8 36 fb ff ff       	call   801142 <sys_page_map>
  80160c:	89 c7                	mov    %eax,%edi
  80160e:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801611:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801613:	85 ff                	test   %edi,%edi
  801615:	79 1d                	jns    801634 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801617:	83 ec 08             	sub    $0x8,%esp
  80161a:	53                   	push   %ebx
  80161b:	6a 00                	push   $0x0
  80161d:	e8 62 fb ff ff       	call   801184 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801622:	83 c4 08             	add    $0x8,%esp
  801625:	ff 75 d4             	pushl  -0x2c(%ebp)
  801628:	6a 00                	push   $0x0
  80162a:	e8 55 fb ff ff       	call   801184 <sys_page_unmap>
	return r;
  80162f:	83 c4 10             	add    $0x10,%esp
  801632:	89 f8                	mov    %edi,%eax
}
  801634:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801637:	5b                   	pop    %ebx
  801638:	5e                   	pop    %esi
  801639:	5f                   	pop    %edi
  80163a:	5d                   	pop    %ebp
  80163b:	c3                   	ret    

0080163c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80163c:	55                   	push   %ebp
  80163d:	89 e5                	mov    %esp,%ebp
  80163f:	53                   	push   %ebx
  801640:	83 ec 14             	sub    $0x14,%esp
  801643:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801646:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801649:	50                   	push   %eax
  80164a:	53                   	push   %ebx
  80164b:	e8 86 fd ff ff       	call   8013d6 <fd_lookup>
  801650:	83 c4 08             	add    $0x8,%esp
  801653:	89 c2                	mov    %eax,%edx
  801655:	85 c0                	test   %eax,%eax
  801657:	78 6d                	js     8016c6 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801659:	83 ec 08             	sub    $0x8,%esp
  80165c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80165f:	50                   	push   %eax
  801660:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801663:	ff 30                	pushl  (%eax)
  801665:	e8 c2 fd ff ff       	call   80142c <dev_lookup>
  80166a:	83 c4 10             	add    $0x10,%esp
  80166d:	85 c0                	test   %eax,%eax
  80166f:	78 4c                	js     8016bd <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801671:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801674:	8b 42 08             	mov    0x8(%edx),%eax
  801677:	83 e0 03             	and    $0x3,%eax
  80167a:	83 f8 01             	cmp    $0x1,%eax
  80167d:	75 21                	jne    8016a0 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80167f:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801684:	8b 40 48             	mov    0x48(%eax),%eax
  801687:	83 ec 04             	sub    $0x4,%esp
  80168a:	53                   	push   %ebx
  80168b:	50                   	push   %eax
  80168c:	68 b0 28 80 00       	push   $0x8028b0
  801691:	e8 3a f0 ff ff       	call   8006d0 <cprintf>
		return -E_INVAL;
  801696:	83 c4 10             	add    $0x10,%esp
  801699:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80169e:	eb 26                	jmp    8016c6 <read+0x8a>
	}
	if (!dev->dev_read)
  8016a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016a3:	8b 40 08             	mov    0x8(%eax),%eax
  8016a6:	85 c0                	test   %eax,%eax
  8016a8:	74 17                	je     8016c1 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8016aa:	83 ec 04             	sub    $0x4,%esp
  8016ad:	ff 75 10             	pushl  0x10(%ebp)
  8016b0:	ff 75 0c             	pushl  0xc(%ebp)
  8016b3:	52                   	push   %edx
  8016b4:	ff d0                	call   *%eax
  8016b6:	89 c2                	mov    %eax,%edx
  8016b8:	83 c4 10             	add    $0x10,%esp
  8016bb:	eb 09                	jmp    8016c6 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016bd:	89 c2                	mov    %eax,%edx
  8016bf:	eb 05                	jmp    8016c6 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8016c1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8016c6:	89 d0                	mov    %edx,%eax
  8016c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016cb:	c9                   	leave  
  8016cc:	c3                   	ret    

008016cd <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8016cd:	55                   	push   %ebp
  8016ce:	89 e5                	mov    %esp,%ebp
  8016d0:	57                   	push   %edi
  8016d1:	56                   	push   %esi
  8016d2:	53                   	push   %ebx
  8016d3:	83 ec 0c             	sub    $0xc,%esp
  8016d6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016d9:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016dc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016e1:	eb 21                	jmp    801704 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8016e3:	83 ec 04             	sub    $0x4,%esp
  8016e6:	89 f0                	mov    %esi,%eax
  8016e8:	29 d8                	sub    %ebx,%eax
  8016ea:	50                   	push   %eax
  8016eb:	89 d8                	mov    %ebx,%eax
  8016ed:	03 45 0c             	add    0xc(%ebp),%eax
  8016f0:	50                   	push   %eax
  8016f1:	57                   	push   %edi
  8016f2:	e8 45 ff ff ff       	call   80163c <read>
		if (m < 0)
  8016f7:	83 c4 10             	add    $0x10,%esp
  8016fa:	85 c0                	test   %eax,%eax
  8016fc:	78 10                	js     80170e <readn+0x41>
			return m;
		if (m == 0)
  8016fe:	85 c0                	test   %eax,%eax
  801700:	74 0a                	je     80170c <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801702:	01 c3                	add    %eax,%ebx
  801704:	39 f3                	cmp    %esi,%ebx
  801706:	72 db                	jb     8016e3 <readn+0x16>
  801708:	89 d8                	mov    %ebx,%eax
  80170a:	eb 02                	jmp    80170e <readn+0x41>
  80170c:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80170e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801711:	5b                   	pop    %ebx
  801712:	5e                   	pop    %esi
  801713:	5f                   	pop    %edi
  801714:	5d                   	pop    %ebp
  801715:	c3                   	ret    

00801716 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801716:	55                   	push   %ebp
  801717:	89 e5                	mov    %esp,%ebp
  801719:	53                   	push   %ebx
  80171a:	83 ec 14             	sub    $0x14,%esp
  80171d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801720:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801723:	50                   	push   %eax
  801724:	53                   	push   %ebx
  801725:	e8 ac fc ff ff       	call   8013d6 <fd_lookup>
  80172a:	83 c4 08             	add    $0x8,%esp
  80172d:	89 c2                	mov    %eax,%edx
  80172f:	85 c0                	test   %eax,%eax
  801731:	78 68                	js     80179b <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801733:	83 ec 08             	sub    $0x8,%esp
  801736:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801739:	50                   	push   %eax
  80173a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80173d:	ff 30                	pushl  (%eax)
  80173f:	e8 e8 fc ff ff       	call   80142c <dev_lookup>
  801744:	83 c4 10             	add    $0x10,%esp
  801747:	85 c0                	test   %eax,%eax
  801749:	78 47                	js     801792 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80174b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80174e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801752:	75 21                	jne    801775 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801754:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801759:	8b 40 48             	mov    0x48(%eax),%eax
  80175c:	83 ec 04             	sub    $0x4,%esp
  80175f:	53                   	push   %ebx
  801760:	50                   	push   %eax
  801761:	68 cc 28 80 00       	push   $0x8028cc
  801766:	e8 65 ef ff ff       	call   8006d0 <cprintf>
		return -E_INVAL;
  80176b:	83 c4 10             	add    $0x10,%esp
  80176e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801773:	eb 26                	jmp    80179b <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801775:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801778:	8b 52 0c             	mov    0xc(%edx),%edx
  80177b:	85 d2                	test   %edx,%edx
  80177d:	74 17                	je     801796 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80177f:	83 ec 04             	sub    $0x4,%esp
  801782:	ff 75 10             	pushl  0x10(%ebp)
  801785:	ff 75 0c             	pushl  0xc(%ebp)
  801788:	50                   	push   %eax
  801789:	ff d2                	call   *%edx
  80178b:	89 c2                	mov    %eax,%edx
  80178d:	83 c4 10             	add    $0x10,%esp
  801790:	eb 09                	jmp    80179b <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801792:	89 c2                	mov    %eax,%edx
  801794:	eb 05                	jmp    80179b <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801796:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80179b:	89 d0                	mov    %edx,%eax
  80179d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017a0:	c9                   	leave  
  8017a1:	c3                   	ret    

008017a2 <seek>:

int
seek(int fdnum, off_t offset)
{
  8017a2:	55                   	push   %ebp
  8017a3:	89 e5                	mov    %esp,%ebp
  8017a5:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017a8:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8017ab:	50                   	push   %eax
  8017ac:	ff 75 08             	pushl  0x8(%ebp)
  8017af:	e8 22 fc ff ff       	call   8013d6 <fd_lookup>
  8017b4:	83 c4 08             	add    $0x8,%esp
  8017b7:	85 c0                	test   %eax,%eax
  8017b9:	78 0e                	js     8017c9 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8017bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8017be:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017c1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8017c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017c9:	c9                   	leave  
  8017ca:	c3                   	ret    

008017cb <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8017cb:	55                   	push   %ebp
  8017cc:	89 e5                	mov    %esp,%ebp
  8017ce:	53                   	push   %ebx
  8017cf:	83 ec 14             	sub    $0x14,%esp
  8017d2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017d5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017d8:	50                   	push   %eax
  8017d9:	53                   	push   %ebx
  8017da:	e8 f7 fb ff ff       	call   8013d6 <fd_lookup>
  8017df:	83 c4 08             	add    $0x8,%esp
  8017e2:	89 c2                	mov    %eax,%edx
  8017e4:	85 c0                	test   %eax,%eax
  8017e6:	78 65                	js     80184d <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017e8:	83 ec 08             	sub    $0x8,%esp
  8017eb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017ee:	50                   	push   %eax
  8017ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017f2:	ff 30                	pushl  (%eax)
  8017f4:	e8 33 fc ff ff       	call   80142c <dev_lookup>
  8017f9:	83 c4 10             	add    $0x10,%esp
  8017fc:	85 c0                	test   %eax,%eax
  8017fe:	78 44                	js     801844 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801800:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801803:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801807:	75 21                	jne    80182a <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801809:	a1 b0 40 80 00       	mov    0x8040b0,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80180e:	8b 40 48             	mov    0x48(%eax),%eax
  801811:	83 ec 04             	sub    $0x4,%esp
  801814:	53                   	push   %ebx
  801815:	50                   	push   %eax
  801816:	68 8c 28 80 00       	push   $0x80288c
  80181b:	e8 b0 ee ff ff       	call   8006d0 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801820:	83 c4 10             	add    $0x10,%esp
  801823:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801828:	eb 23                	jmp    80184d <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80182a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80182d:	8b 52 18             	mov    0x18(%edx),%edx
  801830:	85 d2                	test   %edx,%edx
  801832:	74 14                	je     801848 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801834:	83 ec 08             	sub    $0x8,%esp
  801837:	ff 75 0c             	pushl  0xc(%ebp)
  80183a:	50                   	push   %eax
  80183b:	ff d2                	call   *%edx
  80183d:	89 c2                	mov    %eax,%edx
  80183f:	83 c4 10             	add    $0x10,%esp
  801842:	eb 09                	jmp    80184d <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801844:	89 c2                	mov    %eax,%edx
  801846:	eb 05                	jmp    80184d <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801848:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80184d:	89 d0                	mov    %edx,%eax
  80184f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801852:	c9                   	leave  
  801853:	c3                   	ret    

00801854 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801854:	55                   	push   %ebp
  801855:	89 e5                	mov    %esp,%ebp
  801857:	53                   	push   %ebx
  801858:	83 ec 14             	sub    $0x14,%esp
  80185b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80185e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801861:	50                   	push   %eax
  801862:	ff 75 08             	pushl  0x8(%ebp)
  801865:	e8 6c fb ff ff       	call   8013d6 <fd_lookup>
  80186a:	83 c4 08             	add    $0x8,%esp
  80186d:	89 c2                	mov    %eax,%edx
  80186f:	85 c0                	test   %eax,%eax
  801871:	78 58                	js     8018cb <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801873:	83 ec 08             	sub    $0x8,%esp
  801876:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801879:	50                   	push   %eax
  80187a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80187d:	ff 30                	pushl  (%eax)
  80187f:	e8 a8 fb ff ff       	call   80142c <dev_lookup>
  801884:	83 c4 10             	add    $0x10,%esp
  801887:	85 c0                	test   %eax,%eax
  801889:	78 37                	js     8018c2 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80188b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80188e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801892:	74 32                	je     8018c6 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801894:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801897:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80189e:	00 00 00 
	stat->st_isdir = 0;
  8018a1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018a8:	00 00 00 
	stat->st_dev = dev;
  8018ab:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8018b1:	83 ec 08             	sub    $0x8,%esp
  8018b4:	53                   	push   %ebx
  8018b5:	ff 75 f0             	pushl  -0x10(%ebp)
  8018b8:	ff 50 14             	call   *0x14(%eax)
  8018bb:	89 c2                	mov    %eax,%edx
  8018bd:	83 c4 10             	add    $0x10,%esp
  8018c0:	eb 09                	jmp    8018cb <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018c2:	89 c2                	mov    %eax,%edx
  8018c4:	eb 05                	jmp    8018cb <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8018c6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8018cb:	89 d0                	mov    %edx,%eax
  8018cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018d0:	c9                   	leave  
  8018d1:	c3                   	ret    

008018d2 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8018d2:	55                   	push   %ebp
  8018d3:	89 e5                	mov    %esp,%ebp
  8018d5:	56                   	push   %esi
  8018d6:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8018d7:	83 ec 08             	sub    $0x8,%esp
  8018da:	6a 00                	push   $0x0
  8018dc:	ff 75 08             	pushl  0x8(%ebp)
  8018df:	e8 b7 01 00 00       	call   801a9b <open>
  8018e4:	89 c3                	mov    %eax,%ebx
  8018e6:	83 c4 10             	add    $0x10,%esp
  8018e9:	85 c0                	test   %eax,%eax
  8018eb:	78 1b                	js     801908 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8018ed:	83 ec 08             	sub    $0x8,%esp
  8018f0:	ff 75 0c             	pushl  0xc(%ebp)
  8018f3:	50                   	push   %eax
  8018f4:	e8 5b ff ff ff       	call   801854 <fstat>
  8018f9:	89 c6                	mov    %eax,%esi
	close(fd);
  8018fb:	89 1c 24             	mov    %ebx,(%esp)
  8018fe:	e8 fd fb ff ff       	call   801500 <close>
	return r;
  801903:	83 c4 10             	add    $0x10,%esp
  801906:	89 f0                	mov    %esi,%eax
}
  801908:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80190b:	5b                   	pop    %ebx
  80190c:	5e                   	pop    %esi
  80190d:	5d                   	pop    %ebp
  80190e:	c3                   	ret    

0080190f <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80190f:	55                   	push   %ebp
  801910:	89 e5                	mov    %esp,%ebp
  801912:	56                   	push   %esi
  801913:	53                   	push   %ebx
  801914:	89 c6                	mov    %eax,%esi
  801916:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801918:	83 3d ac 40 80 00 00 	cmpl   $0x0,0x8040ac
  80191f:	75 12                	jne    801933 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801921:	83 ec 0c             	sub    $0xc,%esp
  801924:	6a 01                	push   $0x1
  801926:	e8 bc 07 00 00       	call   8020e7 <ipc_find_env>
  80192b:	a3 ac 40 80 00       	mov    %eax,0x8040ac
  801930:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801933:	6a 07                	push   $0x7
  801935:	68 00 50 80 00       	push   $0x805000
  80193a:	56                   	push   %esi
  80193b:	ff 35 ac 40 80 00    	pushl  0x8040ac
  801941:	e8 4d 07 00 00       	call   802093 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801946:	83 c4 0c             	add    $0xc,%esp
  801949:	6a 00                	push   $0x0
  80194b:	53                   	push   %ebx
  80194c:	6a 00                	push   $0x0
  80194e:	e8 cb 06 00 00       	call   80201e <ipc_recv>
}
  801953:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801956:	5b                   	pop    %ebx
  801957:	5e                   	pop    %esi
  801958:	5d                   	pop    %ebp
  801959:	c3                   	ret    

0080195a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80195a:	55                   	push   %ebp
  80195b:	89 e5                	mov    %esp,%ebp
  80195d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801960:	8b 45 08             	mov    0x8(%ebp),%eax
  801963:	8b 40 0c             	mov    0xc(%eax),%eax
  801966:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80196b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80196e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801973:	ba 00 00 00 00       	mov    $0x0,%edx
  801978:	b8 02 00 00 00       	mov    $0x2,%eax
  80197d:	e8 8d ff ff ff       	call   80190f <fsipc>
}
  801982:	c9                   	leave  
  801983:	c3                   	ret    

00801984 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801984:	55                   	push   %ebp
  801985:	89 e5                	mov    %esp,%ebp
  801987:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80198a:	8b 45 08             	mov    0x8(%ebp),%eax
  80198d:	8b 40 0c             	mov    0xc(%eax),%eax
  801990:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801995:	ba 00 00 00 00       	mov    $0x0,%edx
  80199a:	b8 06 00 00 00       	mov    $0x6,%eax
  80199f:	e8 6b ff ff ff       	call   80190f <fsipc>
}
  8019a4:	c9                   	leave  
  8019a5:	c3                   	ret    

008019a6 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8019a6:	55                   	push   %ebp
  8019a7:	89 e5                	mov    %esp,%ebp
  8019a9:	53                   	push   %ebx
  8019aa:	83 ec 04             	sub    $0x4,%esp
  8019ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8019b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b3:	8b 40 0c             	mov    0xc(%eax),%eax
  8019b6:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8019bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8019c0:	b8 05 00 00 00       	mov    $0x5,%eax
  8019c5:	e8 45 ff ff ff       	call   80190f <fsipc>
  8019ca:	85 c0                	test   %eax,%eax
  8019cc:	78 2c                	js     8019fa <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8019ce:	83 ec 08             	sub    $0x8,%esp
  8019d1:	68 00 50 80 00       	push   $0x805000
  8019d6:	53                   	push   %ebx
  8019d7:	e8 20 f3 ff ff       	call   800cfc <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8019dc:	a1 80 50 80 00       	mov    0x805080,%eax
  8019e1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8019e7:	a1 84 50 80 00       	mov    0x805084,%eax
  8019ec:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8019f2:	83 c4 10             	add    $0x10,%esp
  8019f5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019fd:	c9                   	leave  
  8019fe:	c3                   	ret    

008019ff <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8019ff:	55                   	push   %ebp
  801a00:	89 e5                	mov    %esp,%ebp
  801a02:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801a05:	68 fc 28 80 00       	push   $0x8028fc
  801a0a:	68 90 00 00 00       	push   $0x90
  801a0f:	68 1a 29 80 00       	push   $0x80291a
  801a14:	e8 de eb ff ff       	call   8005f7 <_panic>

00801a19 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801a19:	55                   	push   %ebp
  801a1a:	89 e5                	mov    %esp,%ebp
  801a1c:	56                   	push   %esi
  801a1d:	53                   	push   %ebx
  801a1e:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a21:	8b 45 08             	mov    0x8(%ebp),%eax
  801a24:	8b 40 0c             	mov    0xc(%eax),%eax
  801a27:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801a2c:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a32:	ba 00 00 00 00       	mov    $0x0,%edx
  801a37:	b8 03 00 00 00       	mov    $0x3,%eax
  801a3c:	e8 ce fe ff ff       	call   80190f <fsipc>
  801a41:	89 c3                	mov    %eax,%ebx
  801a43:	85 c0                	test   %eax,%eax
  801a45:	78 4b                	js     801a92 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801a47:	39 c6                	cmp    %eax,%esi
  801a49:	73 16                	jae    801a61 <devfile_read+0x48>
  801a4b:	68 25 29 80 00       	push   $0x802925
  801a50:	68 2c 29 80 00       	push   $0x80292c
  801a55:	6a 7c                	push   $0x7c
  801a57:	68 1a 29 80 00       	push   $0x80291a
  801a5c:	e8 96 eb ff ff       	call   8005f7 <_panic>
	assert(r <= PGSIZE);
  801a61:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a66:	7e 16                	jle    801a7e <devfile_read+0x65>
  801a68:	68 41 29 80 00       	push   $0x802941
  801a6d:	68 2c 29 80 00       	push   $0x80292c
  801a72:	6a 7d                	push   $0x7d
  801a74:	68 1a 29 80 00       	push   $0x80291a
  801a79:	e8 79 eb ff ff       	call   8005f7 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a7e:	83 ec 04             	sub    $0x4,%esp
  801a81:	50                   	push   %eax
  801a82:	68 00 50 80 00       	push   $0x805000
  801a87:	ff 75 0c             	pushl  0xc(%ebp)
  801a8a:	e8 ff f3 ff ff       	call   800e8e <memmove>
	return r;
  801a8f:	83 c4 10             	add    $0x10,%esp
}
  801a92:	89 d8                	mov    %ebx,%eax
  801a94:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a97:	5b                   	pop    %ebx
  801a98:	5e                   	pop    %esi
  801a99:	5d                   	pop    %ebp
  801a9a:	c3                   	ret    

00801a9b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a9b:	55                   	push   %ebp
  801a9c:	89 e5                	mov    %esp,%ebp
  801a9e:	53                   	push   %ebx
  801a9f:	83 ec 20             	sub    $0x20,%esp
  801aa2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801aa5:	53                   	push   %ebx
  801aa6:	e8 18 f2 ff ff       	call   800cc3 <strlen>
  801aab:	83 c4 10             	add    $0x10,%esp
  801aae:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801ab3:	7f 67                	jg     801b1c <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801ab5:	83 ec 0c             	sub    $0xc,%esp
  801ab8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801abb:	50                   	push   %eax
  801abc:	e8 c6 f8 ff ff       	call   801387 <fd_alloc>
  801ac1:	83 c4 10             	add    $0x10,%esp
		return r;
  801ac4:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801ac6:	85 c0                	test   %eax,%eax
  801ac8:	78 57                	js     801b21 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801aca:	83 ec 08             	sub    $0x8,%esp
  801acd:	53                   	push   %ebx
  801ace:	68 00 50 80 00       	push   $0x805000
  801ad3:	e8 24 f2 ff ff       	call   800cfc <strcpy>
	fsipcbuf.open.req_omode = mode;
  801ad8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801adb:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801ae0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ae3:	b8 01 00 00 00       	mov    $0x1,%eax
  801ae8:	e8 22 fe ff ff       	call   80190f <fsipc>
  801aed:	89 c3                	mov    %eax,%ebx
  801aef:	83 c4 10             	add    $0x10,%esp
  801af2:	85 c0                	test   %eax,%eax
  801af4:	79 14                	jns    801b0a <open+0x6f>
		fd_close(fd, 0);
  801af6:	83 ec 08             	sub    $0x8,%esp
  801af9:	6a 00                	push   $0x0
  801afb:	ff 75 f4             	pushl  -0xc(%ebp)
  801afe:	e8 7c f9 ff ff       	call   80147f <fd_close>
		return r;
  801b03:	83 c4 10             	add    $0x10,%esp
  801b06:	89 da                	mov    %ebx,%edx
  801b08:	eb 17                	jmp    801b21 <open+0x86>
	}

	return fd2num(fd);
  801b0a:	83 ec 0c             	sub    $0xc,%esp
  801b0d:	ff 75 f4             	pushl  -0xc(%ebp)
  801b10:	e8 4b f8 ff ff       	call   801360 <fd2num>
  801b15:	89 c2                	mov    %eax,%edx
  801b17:	83 c4 10             	add    $0x10,%esp
  801b1a:	eb 05                	jmp    801b21 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801b1c:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801b21:	89 d0                	mov    %edx,%eax
  801b23:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b26:	c9                   	leave  
  801b27:	c3                   	ret    

00801b28 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b28:	55                   	push   %ebp
  801b29:	89 e5                	mov    %esp,%ebp
  801b2b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b2e:	ba 00 00 00 00       	mov    $0x0,%edx
  801b33:	b8 08 00 00 00       	mov    $0x8,%eax
  801b38:	e8 d2 fd ff ff       	call   80190f <fsipc>
}
  801b3d:	c9                   	leave  
  801b3e:	c3                   	ret    

00801b3f <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b3f:	55                   	push   %ebp
  801b40:	89 e5                	mov    %esp,%ebp
  801b42:	56                   	push   %esi
  801b43:	53                   	push   %ebx
  801b44:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b47:	83 ec 0c             	sub    $0xc,%esp
  801b4a:	ff 75 08             	pushl  0x8(%ebp)
  801b4d:	e8 1e f8 ff ff       	call   801370 <fd2data>
  801b52:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b54:	83 c4 08             	add    $0x8,%esp
  801b57:	68 4d 29 80 00       	push   $0x80294d
  801b5c:	53                   	push   %ebx
  801b5d:	e8 9a f1 ff ff       	call   800cfc <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b62:	8b 46 04             	mov    0x4(%esi),%eax
  801b65:	2b 06                	sub    (%esi),%eax
  801b67:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b6d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b74:	00 00 00 
	stat->st_dev = &devpipe;
  801b77:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801b7e:	30 80 00 
	return 0;
}
  801b81:	b8 00 00 00 00       	mov    $0x0,%eax
  801b86:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b89:	5b                   	pop    %ebx
  801b8a:	5e                   	pop    %esi
  801b8b:	5d                   	pop    %ebp
  801b8c:	c3                   	ret    

00801b8d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b8d:	55                   	push   %ebp
  801b8e:	89 e5                	mov    %esp,%ebp
  801b90:	53                   	push   %ebx
  801b91:	83 ec 0c             	sub    $0xc,%esp
  801b94:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b97:	53                   	push   %ebx
  801b98:	6a 00                	push   $0x0
  801b9a:	e8 e5 f5 ff ff       	call   801184 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b9f:	89 1c 24             	mov    %ebx,(%esp)
  801ba2:	e8 c9 f7 ff ff       	call   801370 <fd2data>
  801ba7:	83 c4 08             	add    $0x8,%esp
  801baa:	50                   	push   %eax
  801bab:	6a 00                	push   $0x0
  801bad:	e8 d2 f5 ff ff       	call   801184 <sys_page_unmap>
}
  801bb2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bb5:	c9                   	leave  
  801bb6:	c3                   	ret    

00801bb7 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801bb7:	55                   	push   %ebp
  801bb8:	89 e5                	mov    %esp,%ebp
  801bba:	57                   	push   %edi
  801bbb:	56                   	push   %esi
  801bbc:	53                   	push   %ebx
  801bbd:	83 ec 1c             	sub    $0x1c,%esp
  801bc0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801bc3:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801bc5:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801bca:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801bcd:	83 ec 0c             	sub    $0xc,%esp
  801bd0:	ff 75 e0             	pushl  -0x20(%ebp)
  801bd3:	e8 48 05 00 00       	call   802120 <pageref>
  801bd8:	89 c3                	mov    %eax,%ebx
  801bda:	89 3c 24             	mov    %edi,(%esp)
  801bdd:	e8 3e 05 00 00       	call   802120 <pageref>
  801be2:	83 c4 10             	add    $0x10,%esp
  801be5:	39 c3                	cmp    %eax,%ebx
  801be7:	0f 94 c1             	sete   %cl
  801bea:	0f b6 c9             	movzbl %cl,%ecx
  801bed:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801bf0:	8b 15 b0 40 80 00    	mov    0x8040b0,%edx
  801bf6:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801bf9:	39 ce                	cmp    %ecx,%esi
  801bfb:	74 1b                	je     801c18 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801bfd:	39 c3                	cmp    %eax,%ebx
  801bff:	75 c4                	jne    801bc5 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c01:	8b 42 58             	mov    0x58(%edx),%eax
  801c04:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c07:	50                   	push   %eax
  801c08:	56                   	push   %esi
  801c09:	68 54 29 80 00       	push   $0x802954
  801c0e:	e8 bd ea ff ff       	call   8006d0 <cprintf>
  801c13:	83 c4 10             	add    $0x10,%esp
  801c16:	eb ad                	jmp    801bc5 <_pipeisclosed+0xe>
	}
}
  801c18:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c1b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c1e:	5b                   	pop    %ebx
  801c1f:	5e                   	pop    %esi
  801c20:	5f                   	pop    %edi
  801c21:	5d                   	pop    %ebp
  801c22:	c3                   	ret    

00801c23 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c23:	55                   	push   %ebp
  801c24:	89 e5                	mov    %esp,%ebp
  801c26:	57                   	push   %edi
  801c27:	56                   	push   %esi
  801c28:	53                   	push   %ebx
  801c29:	83 ec 28             	sub    $0x28,%esp
  801c2c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801c2f:	56                   	push   %esi
  801c30:	e8 3b f7 ff ff       	call   801370 <fd2data>
  801c35:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c37:	83 c4 10             	add    $0x10,%esp
  801c3a:	bf 00 00 00 00       	mov    $0x0,%edi
  801c3f:	eb 4b                	jmp    801c8c <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c41:	89 da                	mov    %ebx,%edx
  801c43:	89 f0                	mov    %esi,%eax
  801c45:	e8 6d ff ff ff       	call   801bb7 <_pipeisclosed>
  801c4a:	85 c0                	test   %eax,%eax
  801c4c:	75 48                	jne    801c96 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801c4e:	e8 8d f4 ff ff       	call   8010e0 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c53:	8b 43 04             	mov    0x4(%ebx),%eax
  801c56:	8b 0b                	mov    (%ebx),%ecx
  801c58:	8d 51 20             	lea    0x20(%ecx),%edx
  801c5b:	39 d0                	cmp    %edx,%eax
  801c5d:	73 e2                	jae    801c41 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c62:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c66:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c69:	89 c2                	mov    %eax,%edx
  801c6b:	c1 fa 1f             	sar    $0x1f,%edx
  801c6e:	89 d1                	mov    %edx,%ecx
  801c70:	c1 e9 1b             	shr    $0x1b,%ecx
  801c73:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c76:	83 e2 1f             	and    $0x1f,%edx
  801c79:	29 ca                	sub    %ecx,%edx
  801c7b:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c7f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c83:	83 c0 01             	add    $0x1,%eax
  801c86:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c89:	83 c7 01             	add    $0x1,%edi
  801c8c:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c8f:	75 c2                	jne    801c53 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c91:	8b 45 10             	mov    0x10(%ebp),%eax
  801c94:	eb 05                	jmp    801c9b <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c96:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c9b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c9e:	5b                   	pop    %ebx
  801c9f:	5e                   	pop    %esi
  801ca0:	5f                   	pop    %edi
  801ca1:	5d                   	pop    %ebp
  801ca2:	c3                   	ret    

00801ca3 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ca3:	55                   	push   %ebp
  801ca4:	89 e5                	mov    %esp,%ebp
  801ca6:	57                   	push   %edi
  801ca7:	56                   	push   %esi
  801ca8:	53                   	push   %ebx
  801ca9:	83 ec 18             	sub    $0x18,%esp
  801cac:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801caf:	57                   	push   %edi
  801cb0:	e8 bb f6 ff ff       	call   801370 <fd2data>
  801cb5:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cb7:	83 c4 10             	add    $0x10,%esp
  801cba:	bb 00 00 00 00       	mov    $0x0,%ebx
  801cbf:	eb 3d                	jmp    801cfe <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801cc1:	85 db                	test   %ebx,%ebx
  801cc3:	74 04                	je     801cc9 <devpipe_read+0x26>
				return i;
  801cc5:	89 d8                	mov    %ebx,%eax
  801cc7:	eb 44                	jmp    801d0d <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801cc9:	89 f2                	mov    %esi,%edx
  801ccb:	89 f8                	mov    %edi,%eax
  801ccd:	e8 e5 fe ff ff       	call   801bb7 <_pipeisclosed>
  801cd2:	85 c0                	test   %eax,%eax
  801cd4:	75 32                	jne    801d08 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801cd6:	e8 05 f4 ff ff       	call   8010e0 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801cdb:	8b 06                	mov    (%esi),%eax
  801cdd:	3b 46 04             	cmp    0x4(%esi),%eax
  801ce0:	74 df                	je     801cc1 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801ce2:	99                   	cltd   
  801ce3:	c1 ea 1b             	shr    $0x1b,%edx
  801ce6:	01 d0                	add    %edx,%eax
  801ce8:	83 e0 1f             	and    $0x1f,%eax
  801ceb:	29 d0                	sub    %edx,%eax
  801ced:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801cf2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cf5:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801cf8:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cfb:	83 c3 01             	add    $0x1,%ebx
  801cfe:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801d01:	75 d8                	jne    801cdb <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801d03:	8b 45 10             	mov    0x10(%ebp),%eax
  801d06:	eb 05                	jmp    801d0d <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d08:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801d0d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d10:	5b                   	pop    %ebx
  801d11:	5e                   	pop    %esi
  801d12:	5f                   	pop    %edi
  801d13:	5d                   	pop    %ebp
  801d14:	c3                   	ret    

00801d15 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801d15:	55                   	push   %ebp
  801d16:	89 e5                	mov    %esp,%ebp
  801d18:	56                   	push   %esi
  801d19:	53                   	push   %ebx
  801d1a:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801d1d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d20:	50                   	push   %eax
  801d21:	e8 61 f6 ff ff       	call   801387 <fd_alloc>
  801d26:	83 c4 10             	add    $0x10,%esp
  801d29:	89 c2                	mov    %eax,%edx
  801d2b:	85 c0                	test   %eax,%eax
  801d2d:	0f 88 2c 01 00 00    	js     801e5f <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d33:	83 ec 04             	sub    $0x4,%esp
  801d36:	68 07 04 00 00       	push   $0x407
  801d3b:	ff 75 f4             	pushl  -0xc(%ebp)
  801d3e:	6a 00                	push   $0x0
  801d40:	e8 ba f3 ff ff       	call   8010ff <sys_page_alloc>
  801d45:	83 c4 10             	add    $0x10,%esp
  801d48:	89 c2                	mov    %eax,%edx
  801d4a:	85 c0                	test   %eax,%eax
  801d4c:	0f 88 0d 01 00 00    	js     801e5f <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d52:	83 ec 0c             	sub    $0xc,%esp
  801d55:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d58:	50                   	push   %eax
  801d59:	e8 29 f6 ff ff       	call   801387 <fd_alloc>
  801d5e:	89 c3                	mov    %eax,%ebx
  801d60:	83 c4 10             	add    $0x10,%esp
  801d63:	85 c0                	test   %eax,%eax
  801d65:	0f 88 e2 00 00 00    	js     801e4d <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d6b:	83 ec 04             	sub    $0x4,%esp
  801d6e:	68 07 04 00 00       	push   $0x407
  801d73:	ff 75 f0             	pushl  -0x10(%ebp)
  801d76:	6a 00                	push   $0x0
  801d78:	e8 82 f3 ff ff       	call   8010ff <sys_page_alloc>
  801d7d:	89 c3                	mov    %eax,%ebx
  801d7f:	83 c4 10             	add    $0x10,%esp
  801d82:	85 c0                	test   %eax,%eax
  801d84:	0f 88 c3 00 00 00    	js     801e4d <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d8a:	83 ec 0c             	sub    $0xc,%esp
  801d8d:	ff 75 f4             	pushl  -0xc(%ebp)
  801d90:	e8 db f5 ff ff       	call   801370 <fd2data>
  801d95:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d97:	83 c4 0c             	add    $0xc,%esp
  801d9a:	68 07 04 00 00       	push   $0x407
  801d9f:	50                   	push   %eax
  801da0:	6a 00                	push   $0x0
  801da2:	e8 58 f3 ff ff       	call   8010ff <sys_page_alloc>
  801da7:	89 c3                	mov    %eax,%ebx
  801da9:	83 c4 10             	add    $0x10,%esp
  801dac:	85 c0                	test   %eax,%eax
  801dae:	0f 88 89 00 00 00    	js     801e3d <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801db4:	83 ec 0c             	sub    $0xc,%esp
  801db7:	ff 75 f0             	pushl  -0x10(%ebp)
  801dba:	e8 b1 f5 ff ff       	call   801370 <fd2data>
  801dbf:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801dc6:	50                   	push   %eax
  801dc7:	6a 00                	push   $0x0
  801dc9:	56                   	push   %esi
  801dca:	6a 00                	push   $0x0
  801dcc:	e8 71 f3 ff ff       	call   801142 <sys_page_map>
  801dd1:	89 c3                	mov    %eax,%ebx
  801dd3:	83 c4 20             	add    $0x20,%esp
  801dd6:	85 c0                	test   %eax,%eax
  801dd8:	78 55                	js     801e2f <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801dda:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801de0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801de3:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801de5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801de8:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801def:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801df5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801df8:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801dfa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dfd:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801e04:	83 ec 0c             	sub    $0xc,%esp
  801e07:	ff 75 f4             	pushl  -0xc(%ebp)
  801e0a:	e8 51 f5 ff ff       	call   801360 <fd2num>
  801e0f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e12:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e14:	83 c4 04             	add    $0x4,%esp
  801e17:	ff 75 f0             	pushl  -0x10(%ebp)
  801e1a:	e8 41 f5 ff ff       	call   801360 <fd2num>
  801e1f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e22:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801e25:	83 c4 10             	add    $0x10,%esp
  801e28:	ba 00 00 00 00       	mov    $0x0,%edx
  801e2d:	eb 30                	jmp    801e5f <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801e2f:	83 ec 08             	sub    $0x8,%esp
  801e32:	56                   	push   %esi
  801e33:	6a 00                	push   $0x0
  801e35:	e8 4a f3 ff ff       	call   801184 <sys_page_unmap>
  801e3a:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801e3d:	83 ec 08             	sub    $0x8,%esp
  801e40:	ff 75 f0             	pushl  -0x10(%ebp)
  801e43:	6a 00                	push   $0x0
  801e45:	e8 3a f3 ff ff       	call   801184 <sys_page_unmap>
  801e4a:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801e4d:	83 ec 08             	sub    $0x8,%esp
  801e50:	ff 75 f4             	pushl  -0xc(%ebp)
  801e53:	6a 00                	push   $0x0
  801e55:	e8 2a f3 ff ff       	call   801184 <sys_page_unmap>
  801e5a:	83 c4 10             	add    $0x10,%esp
  801e5d:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801e5f:	89 d0                	mov    %edx,%eax
  801e61:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e64:	5b                   	pop    %ebx
  801e65:	5e                   	pop    %esi
  801e66:	5d                   	pop    %ebp
  801e67:	c3                   	ret    

00801e68 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e68:	55                   	push   %ebp
  801e69:	89 e5                	mov    %esp,%ebp
  801e6b:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e6e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e71:	50                   	push   %eax
  801e72:	ff 75 08             	pushl  0x8(%ebp)
  801e75:	e8 5c f5 ff ff       	call   8013d6 <fd_lookup>
  801e7a:	83 c4 10             	add    $0x10,%esp
  801e7d:	85 c0                	test   %eax,%eax
  801e7f:	78 18                	js     801e99 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e81:	83 ec 0c             	sub    $0xc,%esp
  801e84:	ff 75 f4             	pushl  -0xc(%ebp)
  801e87:	e8 e4 f4 ff ff       	call   801370 <fd2data>
	return _pipeisclosed(fd, p);
  801e8c:	89 c2                	mov    %eax,%edx
  801e8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e91:	e8 21 fd ff ff       	call   801bb7 <_pipeisclosed>
  801e96:	83 c4 10             	add    $0x10,%esp
}
  801e99:	c9                   	leave  
  801e9a:	c3                   	ret    

00801e9b <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e9b:	55                   	push   %ebp
  801e9c:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e9e:	b8 00 00 00 00       	mov    $0x0,%eax
  801ea3:	5d                   	pop    %ebp
  801ea4:	c3                   	ret    

00801ea5 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ea5:	55                   	push   %ebp
  801ea6:	89 e5                	mov    %esp,%ebp
  801ea8:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801eab:	68 6c 29 80 00       	push   $0x80296c
  801eb0:	ff 75 0c             	pushl  0xc(%ebp)
  801eb3:	e8 44 ee ff ff       	call   800cfc <strcpy>
	return 0;
}
  801eb8:	b8 00 00 00 00       	mov    $0x0,%eax
  801ebd:	c9                   	leave  
  801ebe:	c3                   	ret    

00801ebf <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ebf:	55                   	push   %ebp
  801ec0:	89 e5                	mov    %esp,%ebp
  801ec2:	57                   	push   %edi
  801ec3:	56                   	push   %esi
  801ec4:	53                   	push   %ebx
  801ec5:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ecb:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ed0:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ed6:	eb 2d                	jmp    801f05 <devcons_write+0x46>
		m = n - tot;
  801ed8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801edb:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801edd:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801ee0:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801ee5:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ee8:	83 ec 04             	sub    $0x4,%esp
  801eeb:	53                   	push   %ebx
  801eec:	03 45 0c             	add    0xc(%ebp),%eax
  801eef:	50                   	push   %eax
  801ef0:	57                   	push   %edi
  801ef1:	e8 98 ef ff ff       	call   800e8e <memmove>
		sys_cputs(buf, m);
  801ef6:	83 c4 08             	add    $0x8,%esp
  801ef9:	53                   	push   %ebx
  801efa:	57                   	push   %edi
  801efb:	e8 43 f1 ff ff       	call   801043 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f00:	01 de                	add    %ebx,%esi
  801f02:	83 c4 10             	add    $0x10,%esp
  801f05:	89 f0                	mov    %esi,%eax
  801f07:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f0a:	72 cc                	jb     801ed8 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801f0c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f0f:	5b                   	pop    %ebx
  801f10:	5e                   	pop    %esi
  801f11:	5f                   	pop    %edi
  801f12:	5d                   	pop    %ebp
  801f13:	c3                   	ret    

00801f14 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f14:	55                   	push   %ebp
  801f15:	89 e5                	mov    %esp,%ebp
  801f17:	83 ec 08             	sub    $0x8,%esp
  801f1a:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801f1f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f23:	74 2a                	je     801f4f <devcons_read+0x3b>
  801f25:	eb 05                	jmp    801f2c <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f27:	e8 b4 f1 ff ff       	call   8010e0 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f2c:	e8 30 f1 ff ff       	call   801061 <sys_cgetc>
  801f31:	85 c0                	test   %eax,%eax
  801f33:	74 f2                	je     801f27 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801f35:	85 c0                	test   %eax,%eax
  801f37:	78 16                	js     801f4f <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f39:	83 f8 04             	cmp    $0x4,%eax
  801f3c:	74 0c                	je     801f4a <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801f3e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f41:	88 02                	mov    %al,(%edx)
	return 1;
  801f43:	b8 01 00 00 00       	mov    $0x1,%eax
  801f48:	eb 05                	jmp    801f4f <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801f4a:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801f4f:	c9                   	leave  
  801f50:	c3                   	ret    

00801f51 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f51:	55                   	push   %ebp
  801f52:	89 e5                	mov    %esp,%ebp
  801f54:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f57:	8b 45 08             	mov    0x8(%ebp),%eax
  801f5a:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f5d:	6a 01                	push   $0x1
  801f5f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f62:	50                   	push   %eax
  801f63:	e8 db f0 ff ff       	call   801043 <sys_cputs>
}
  801f68:	83 c4 10             	add    $0x10,%esp
  801f6b:	c9                   	leave  
  801f6c:	c3                   	ret    

00801f6d <getchar>:

int
getchar(void)
{
  801f6d:	55                   	push   %ebp
  801f6e:	89 e5                	mov    %esp,%ebp
  801f70:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f73:	6a 01                	push   $0x1
  801f75:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f78:	50                   	push   %eax
  801f79:	6a 00                	push   $0x0
  801f7b:	e8 bc f6 ff ff       	call   80163c <read>
	if (r < 0)
  801f80:	83 c4 10             	add    $0x10,%esp
  801f83:	85 c0                	test   %eax,%eax
  801f85:	78 0f                	js     801f96 <getchar+0x29>
		return r;
	if (r < 1)
  801f87:	85 c0                	test   %eax,%eax
  801f89:	7e 06                	jle    801f91 <getchar+0x24>
		return -E_EOF;
	return c;
  801f8b:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f8f:	eb 05                	jmp    801f96 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f91:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f96:	c9                   	leave  
  801f97:	c3                   	ret    

00801f98 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f98:	55                   	push   %ebp
  801f99:	89 e5                	mov    %esp,%ebp
  801f9b:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f9e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fa1:	50                   	push   %eax
  801fa2:	ff 75 08             	pushl  0x8(%ebp)
  801fa5:	e8 2c f4 ff ff       	call   8013d6 <fd_lookup>
  801faa:	83 c4 10             	add    $0x10,%esp
  801fad:	85 c0                	test   %eax,%eax
  801faf:	78 11                	js     801fc2 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801fb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fb4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fba:	39 10                	cmp    %edx,(%eax)
  801fbc:	0f 94 c0             	sete   %al
  801fbf:	0f b6 c0             	movzbl %al,%eax
}
  801fc2:	c9                   	leave  
  801fc3:	c3                   	ret    

00801fc4 <opencons>:

int
opencons(void)
{
  801fc4:	55                   	push   %ebp
  801fc5:	89 e5                	mov    %esp,%ebp
  801fc7:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fcd:	50                   	push   %eax
  801fce:	e8 b4 f3 ff ff       	call   801387 <fd_alloc>
  801fd3:	83 c4 10             	add    $0x10,%esp
		return r;
  801fd6:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fd8:	85 c0                	test   %eax,%eax
  801fda:	78 3e                	js     80201a <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fdc:	83 ec 04             	sub    $0x4,%esp
  801fdf:	68 07 04 00 00       	push   $0x407
  801fe4:	ff 75 f4             	pushl  -0xc(%ebp)
  801fe7:	6a 00                	push   $0x0
  801fe9:	e8 11 f1 ff ff       	call   8010ff <sys_page_alloc>
  801fee:	83 c4 10             	add    $0x10,%esp
		return r;
  801ff1:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ff3:	85 c0                	test   %eax,%eax
  801ff5:	78 23                	js     80201a <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ff7:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ffd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802000:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802002:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802005:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80200c:	83 ec 0c             	sub    $0xc,%esp
  80200f:	50                   	push   %eax
  802010:	e8 4b f3 ff ff       	call   801360 <fd2num>
  802015:	89 c2                	mov    %eax,%edx
  802017:	83 c4 10             	add    $0x10,%esp
}
  80201a:	89 d0                	mov    %edx,%eax
  80201c:	c9                   	leave  
  80201d:	c3                   	ret    

0080201e <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80201e:	55                   	push   %ebp
  80201f:	89 e5                	mov    %esp,%ebp
  802021:	56                   	push   %esi
  802022:	53                   	push   %ebx
  802023:	8b 75 08             	mov    0x8(%ebp),%esi
  802026:	8b 45 0c             	mov    0xc(%ebp),%eax
  802029:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int ret;
	if (pg) ret = sys_ipc_recv(pg);
  80202c:	85 c0                	test   %eax,%eax
  80202e:	74 0e                	je     80203e <ipc_recv+0x20>
  802030:	83 ec 0c             	sub    $0xc,%esp
  802033:	50                   	push   %eax
  802034:	e8 76 f2 ff ff       	call   8012af <sys_ipc_recv>
  802039:	83 c4 10             	add    $0x10,%esp
  80203c:	eb 10                	jmp    80204e <ipc_recv+0x30>
	else ret = sys_ipc_recv((void*)UTOP);
  80203e:	83 ec 0c             	sub    $0xc,%esp
  802041:	68 00 00 c0 ee       	push   $0xeec00000
  802046:	e8 64 f2 ff ff       	call   8012af <sys_ipc_recv>
  80204b:	83 c4 10             	add    $0x10,%esp
	if (ret) {
  80204e:	85 c0                	test   %eax,%eax
  802050:	74 16                	je     802068 <ipc_recv+0x4a>
		if (from_env_store) *from_env_store = 0;
  802052:	85 f6                	test   %esi,%esi
  802054:	74 06                	je     80205c <ipc_recv+0x3e>
  802056:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  80205c:	85 db                	test   %ebx,%ebx
  80205e:	74 2c                	je     80208c <ipc_recv+0x6e>
  802060:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802066:	eb 24                	jmp    80208c <ipc_recv+0x6e>
		return ret;
	}
	if (from_env_store) *from_env_store = thisenv->env_ipc_from;
  802068:	85 f6                	test   %esi,%esi
  80206a:	74 0a                	je     802076 <ipc_recv+0x58>
  80206c:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  802071:	8b 40 74             	mov    0x74(%eax),%eax
  802074:	89 06                	mov    %eax,(%esi)
	if (perm_store) *perm_store = thisenv->env_ipc_perm;
  802076:	85 db                	test   %ebx,%ebx
  802078:	74 0a                	je     802084 <ipc_recv+0x66>
  80207a:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  80207f:	8b 40 78             	mov    0x78(%eax),%eax
  802082:	89 03                	mov    %eax,(%ebx)

	// panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802084:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  802089:	8b 40 70             	mov    0x70(%eax),%eax
}
  80208c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80208f:	5b                   	pop    %ebx
  802090:	5e                   	pop    %esi
  802091:	5d                   	pop    %ebp
  802092:	c3                   	ret    

00802093 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802093:	55                   	push   %ebp
  802094:	89 e5                	mov    %esp,%ebp
  802096:	57                   	push   %edi
  802097:	56                   	push   %esi
  802098:	53                   	push   %ebx
  802099:	83 ec 0c             	sub    $0xc,%esp
  80209c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80209f:	8b 75 0c             	mov    0xc(%ebp),%esi
  8020a2:	8b 45 10             	mov    0x10(%ebp),%eax
  8020a5:	85 c0                	test   %eax,%eax
  8020a7:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  8020ac:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	while (true) {
		void* srcva = (pg)? pg: (void*)UTOP;
		int ret = sys_ipc_try_send(to_env, val, srcva, perm);
  8020af:	ff 75 14             	pushl  0x14(%ebp)
  8020b2:	53                   	push   %ebx
  8020b3:	56                   	push   %esi
  8020b4:	57                   	push   %edi
  8020b5:	e8 d2 f1 ff ff       	call   80128c <sys_ipc_try_send>
		if (ret == 0) break;
  8020ba:	83 c4 10             	add    $0x10,%esp
  8020bd:	85 c0                	test   %eax,%eax
  8020bf:	74 1e                	je     8020df <ipc_send+0x4c>
		if (ret != -E_IPC_NOT_RECV) panic("ipc_send: %e", ret);
  8020c1:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020c4:	74 12                	je     8020d8 <ipc_send+0x45>
  8020c6:	50                   	push   %eax
  8020c7:	68 78 29 80 00       	push   $0x802978
  8020cc:	6a 39                	push   $0x39
  8020ce:	68 85 29 80 00       	push   $0x802985
  8020d3:	e8 1f e5 ff ff       	call   8005f7 <_panic>
		sys_yield();
  8020d8:	e8 03 f0 ff ff       	call   8010e0 <sys_yield>
	}
  8020dd:	eb d0                	jmp    8020af <ipc_send+0x1c>
	// panic("ipc_send not implemented");
}
  8020df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020e2:	5b                   	pop    %ebx
  8020e3:	5e                   	pop    %esi
  8020e4:	5f                   	pop    %edi
  8020e5:	5d                   	pop    %ebp
  8020e6:	c3                   	ret    

008020e7 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8020e7:	55                   	push   %ebp
  8020e8:	89 e5                	mov    %esp,%ebp
  8020ea:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8020ed:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8020f2:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8020f5:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8020fb:	8b 52 50             	mov    0x50(%edx),%edx
  8020fe:	39 ca                	cmp    %ecx,%edx
  802100:	75 0d                	jne    80210f <ipc_find_env+0x28>
			return envs[i].env_id;
  802102:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802105:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80210a:	8b 40 48             	mov    0x48(%eax),%eax
  80210d:	eb 0f                	jmp    80211e <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80210f:	83 c0 01             	add    $0x1,%eax
  802112:	3d 00 04 00 00       	cmp    $0x400,%eax
  802117:	75 d9                	jne    8020f2 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802119:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80211e:	5d                   	pop    %ebp
  80211f:	c3                   	ret    

00802120 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802120:	55                   	push   %ebp
  802121:	89 e5                	mov    %esp,%ebp
  802123:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802126:	89 d0                	mov    %edx,%eax
  802128:	c1 e8 16             	shr    $0x16,%eax
  80212b:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802132:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802137:	f6 c1 01             	test   $0x1,%cl
  80213a:	74 1d                	je     802159 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80213c:	c1 ea 0c             	shr    $0xc,%edx
  80213f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802146:	f6 c2 01             	test   $0x1,%dl
  802149:	74 0e                	je     802159 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80214b:	c1 ea 0c             	shr    $0xc,%edx
  80214e:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802155:	ef 
  802156:	0f b7 c0             	movzwl %ax,%eax
}
  802159:	5d                   	pop    %ebp
  80215a:	c3                   	ret    
  80215b:	66 90                	xchg   %ax,%ax
  80215d:	66 90                	xchg   %ax,%ax
  80215f:	90                   	nop

00802160 <__udivdi3>:
  802160:	55                   	push   %ebp
  802161:	57                   	push   %edi
  802162:	56                   	push   %esi
  802163:	53                   	push   %ebx
  802164:	83 ec 1c             	sub    $0x1c,%esp
  802167:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80216b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80216f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802173:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802177:	85 f6                	test   %esi,%esi
  802179:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80217d:	89 ca                	mov    %ecx,%edx
  80217f:	89 f8                	mov    %edi,%eax
  802181:	75 3d                	jne    8021c0 <__udivdi3+0x60>
  802183:	39 cf                	cmp    %ecx,%edi
  802185:	0f 87 c5 00 00 00    	ja     802250 <__udivdi3+0xf0>
  80218b:	85 ff                	test   %edi,%edi
  80218d:	89 fd                	mov    %edi,%ebp
  80218f:	75 0b                	jne    80219c <__udivdi3+0x3c>
  802191:	b8 01 00 00 00       	mov    $0x1,%eax
  802196:	31 d2                	xor    %edx,%edx
  802198:	f7 f7                	div    %edi
  80219a:	89 c5                	mov    %eax,%ebp
  80219c:	89 c8                	mov    %ecx,%eax
  80219e:	31 d2                	xor    %edx,%edx
  8021a0:	f7 f5                	div    %ebp
  8021a2:	89 c1                	mov    %eax,%ecx
  8021a4:	89 d8                	mov    %ebx,%eax
  8021a6:	89 cf                	mov    %ecx,%edi
  8021a8:	f7 f5                	div    %ebp
  8021aa:	89 c3                	mov    %eax,%ebx
  8021ac:	89 d8                	mov    %ebx,%eax
  8021ae:	89 fa                	mov    %edi,%edx
  8021b0:	83 c4 1c             	add    $0x1c,%esp
  8021b3:	5b                   	pop    %ebx
  8021b4:	5e                   	pop    %esi
  8021b5:	5f                   	pop    %edi
  8021b6:	5d                   	pop    %ebp
  8021b7:	c3                   	ret    
  8021b8:	90                   	nop
  8021b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021c0:	39 ce                	cmp    %ecx,%esi
  8021c2:	77 74                	ja     802238 <__udivdi3+0xd8>
  8021c4:	0f bd fe             	bsr    %esi,%edi
  8021c7:	83 f7 1f             	xor    $0x1f,%edi
  8021ca:	0f 84 98 00 00 00    	je     802268 <__udivdi3+0x108>
  8021d0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8021d5:	89 f9                	mov    %edi,%ecx
  8021d7:	89 c5                	mov    %eax,%ebp
  8021d9:	29 fb                	sub    %edi,%ebx
  8021db:	d3 e6                	shl    %cl,%esi
  8021dd:	89 d9                	mov    %ebx,%ecx
  8021df:	d3 ed                	shr    %cl,%ebp
  8021e1:	89 f9                	mov    %edi,%ecx
  8021e3:	d3 e0                	shl    %cl,%eax
  8021e5:	09 ee                	or     %ebp,%esi
  8021e7:	89 d9                	mov    %ebx,%ecx
  8021e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021ed:	89 d5                	mov    %edx,%ebp
  8021ef:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021f3:	d3 ed                	shr    %cl,%ebp
  8021f5:	89 f9                	mov    %edi,%ecx
  8021f7:	d3 e2                	shl    %cl,%edx
  8021f9:	89 d9                	mov    %ebx,%ecx
  8021fb:	d3 e8                	shr    %cl,%eax
  8021fd:	09 c2                	or     %eax,%edx
  8021ff:	89 d0                	mov    %edx,%eax
  802201:	89 ea                	mov    %ebp,%edx
  802203:	f7 f6                	div    %esi
  802205:	89 d5                	mov    %edx,%ebp
  802207:	89 c3                	mov    %eax,%ebx
  802209:	f7 64 24 0c          	mull   0xc(%esp)
  80220d:	39 d5                	cmp    %edx,%ebp
  80220f:	72 10                	jb     802221 <__udivdi3+0xc1>
  802211:	8b 74 24 08          	mov    0x8(%esp),%esi
  802215:	89 f9                	mov    %edi,%ecx
  802217:	d3 e6                	shl    %cl,%esi
  802219:	39 c6                	cmp    %eax,%esi
  80221b:	73 07                	jae    802224 <__udivdi3+0xc4>
  80221d:	39 d5                	cmp    %edx,%ebp
  80221f:	75 03                	jne    802224 <__udivdi3+0xc4>
  802221:	83 eb 01             	sub    $0x1,%ebx
  802224:	31 ff                	xor    %edi,%edi
  802226:	89 d8                	mov    %ebx,%eax
  802228:	89 fa                	mov    %edi,%edx
  80222a:	83 c4 1c             	add    $0x1c,%esp
  80222d:	5b                   	pop    %ebx
  80222e:	5e                   	pop    %esi
  80222f:	5f                   	pop    %edi
  802230:	5d                   	pop    %ebp
  802231:	c3                   	ret    
  802232:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802238:	31 ff                	xor    %edi,%edi
  80223a:	31 db                	xor    %ebx,%ebx
  80223c:	89 d8                	mov    %ebx,%eax
  80223e:	89 fa                	mov    %edi,%edx
  802240:	83 c4 1c             	add    $0x1c,%esp
  802243:	5b                   	pop    %ebx
  802244:	5e                   	pop    %esi
  802245:	5f                   	pop    %edi
  802246:	5d                   	pop    %ebp
  802247:	c3                   	ret    
  802248:	90                   	nop
  802249:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802250:	89 d8                	mov    %ebx,%eax
  802252:	f7 f7                	div    %edi
  802254:	31 ff                	xor    %edi,%edi
  802256:	89 c3                	mov    %eax,%ebx
  802258:	89 d8                	mov    %ebx,%eax
  80225a:	89 fa                	mov    %edi,%edx
  80225c:	83 c4 1c             	add    $0x1c,%esp
  80225f:	5b                   	pop    %ebx
  802260:	5e                   	pop    %esi
  802261:	5f                   	pop    %edi
  802262:	5d                   	pop    %ebp
  802263:	c3                   	ret    
  802264:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802268:	39 ce                	cmp    %ecx,%esi
  80226a:	72 0c                	jb     802278 <__udivdi3+0x118>
  80226c:	31 db                	xor    %ebx,%ebx
  80226e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802272:	0f 87 34 ff ff ff    	ja     8021ac <__udivdi3+0x4c>
  802278:	bb 01 00 00 00       	mov    $0x1,%ebx
  80227d:	e9 2a ff ff ff       	jmp    8021ac <__udivdi3+0x4c>
  802282:	66 90                	xchg   %ax,%ax
  802284:	66 90                	xchg   %ax,%ax
  802286:	66 90                	xchg   %ax,%ax
  802288:	66 90                	xchg   %ax,%ax
  80228a:	66 90                	xchg   %ax,%ax
  80228c:	66 90                	xchg   %ax,%ax
  80228e:	66 90                	xchg   %ax,%ax

00802290 <__umoddi3>:
  802290:	55                   	push   %ebp
  802291:	57                   	push   %edi
  802292:	56                   	push   %esi
  802293:	53                   	push   %ebx
  802294:	83 ec 1c             	sub    $0x1c,%esp
  802297:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80229b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80229f:	8b 74 24 34          	mov    0x34(%esp),%esi
  8022a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8022a7:	85 d2                	test   %edx,%edx
  8022a9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8022ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022b1:	89 f3                	mov    %esi,%ebx
  8022b3:	89 3c 24             	mov    %edi,(%esp)
  8022b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022ba:	75 1c                	jne    8022d8 <__umoddi3+0x48>
  8022bc:	39 f7                	cmp    %esi,%edi
  8022be:	76 50                	jbe    802310 <__umoddi3+0x80>
  8022c0:	89 c8                	mov    %ecx,%eax
  8022c2:	89 f2                	mov    %esi,%edx
  8022c4:	f7 f7                	div    %edi
  8022c6:	89 d0                	mov    %edx,%eax
  8022c8:	31 d2                	xor    %edx,%edx
  8022ca:	83 c4 1c             	add    $0x1c,%esp
  8022cd:	5b                   	pop    %ebx
  8022ce:	5e                   	pop    %esi
  8022cf:	5f                   	pop    %edi
  8022d0:	5d                   	pop    %ebp
  8022d1:	c3                   	ret    
  8022d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022d8:	39 f2                	cmp    %esi,%edx
  8022da:	89 d0                	mov    %edx,%eax
  8022dc:	77 52                	ja     802330 <__umoddi3+0xa0>
  8022de:	0f bd ea             	bsr    %edx,%ebp
  8022e1:	83 f5 1f             	xor    $0x1f,%ebp
  8022e4:	75 5a                	jne    802340 <__umoddi3+0xb0>
  8022e6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8022ea:	0f 82 e0 00 00 00    	jb     8023d0 <__umoddi3+0x140>
  8022f0:	39 0c 24             	cmp    %ecx,(%esp)
  8022f3:	0f 86 d7 00 00 00    	jbe    8023d0 <__umoddi3+0x140>
  8022f9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8022fd:	8b 54 24 04          	mov    0x4(%esp),%edx
  802301:	83 c4 1c             	add    $0x1c,%esp
  802304:	5b                   	pop    %ebx
  802305:	5e                   	pop    %esi
  802306:	5f                   	pop    %edi
  802307:	5d                   	pop    %ebp
  802308:	c3                   	ret    
  802309:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802310:	85 ff                	test   %edi,%edi
  802312:	89 fd                	mov    %edi,%ebp
  802314:	75 0b                	jne    802321 <__umoddi3+0x91>
  802316:	b8 01 00 00 00       	mov    $0x1,%eax
  80231b:	31 d2                	xor    %edx,%edx
  80231d:	f7 f7                	div    %edi
  80231f:	89 c5                	mov    %eax,%ebp
  802321:	89 f0                	mov    %esi,%eax
  802323:	31 d2                	xor    %edx,%edx
  802325:	f7 f5                	div    %ebp
  802327:	89 c8                	mov    %ecx,%eax
  802329:	f7 f5                	div    %ebp
  80232b:	89 d0                	mov    %edx,%eax
  80232d:	eb 99                	jmp    8022c8 <__umoddi3+0x38>
  80232f:	90                   	nop
  802330:	89 c8                	mov    %ecx,%eax
  802332:	89 f2                	mov    %esi,%edx
  802334:	83 c4 1c             	add    $0x1c,%esp
  802337:	5b                   	pop    %ebx
  802338:	5e                   	pop    %esi
  802339:	5f                   	pop    %edi
  80233a:	5d                   	pop    %ebp
  80233b:	c3                   	ret    
  80233c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802340:	8b 34 24             	mov    (%esp),%esi
  802343:	bf 20 00 00 00       	mov    $0x20,%edi
  802348:	89 e9                	mov    %ebp,%ecx
  80234a:	29 ef                	sub    %ebp,%edi
  80234c:	d3 e0                	shl    %cl,%eax
  80234e:	89 f9                	mov    %edi,%ecx
  802350:	89 f2                	mov    %esi,%edx
  802352:	d3 ea                	shr    %cl,%edx
  802354:	89 e9                	mov    %ebp,%ecx
  802356:	09 c2                	or     %eax,%edx
  802358:	89 d8                	mov    %ebx,%eax
  80235a:	89 14 24             	mov    %edx,(%esp)
  80235d:	89 f2                	mov    %esi,%edx
  80235f:	d3 e2                	shl    %cl,%edx
  802361:	89 f9                	mov    %edi,%ecx
  802363:	89 54 24 04          	mov    %edx,0x4(%esp)
  802367:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80236b:	d3 e8                	shr    %cl,%eax
  80236d:	89 e9                	mov    %ebp,%ecx
  80236f:	89 c6                	mov    %eax,%esi
  802371:	d3 e3                	shl    %cl,%ebx
  802373:	89 f9                	mov    %edi,%ecx
  802375:	89 d0                	mov    %edx,%eax
  802377:	d3 e8                	shr    %cl,%eax
  802379:	89 e9                	mov    %ebp,%ecx
  80237b:	09 d8                	or     %ebx,%eax
  80237d:	89 d3                	mov    %edx,%ebx
  80237f:	89 f2                	mov    %esi,%edx
  802381:	f7 34 24             	divl   (%esp)
  802384:	89 d6                	mov    %edx,%esi
  802386:	d3 e3                	shl    %cl,%ebx
  802388:	f7 64 24 04          	mull   0x4(%esp)
  80238c:	39 d6                	cmp    %edx,%esi
  80238e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802392:	89 d1                	mov    %edx,%ecx
  802394:	89 c3                	mov    %eax,%ebx
  802396:	72 08                	jb     8023a0 <__umoddi3+0x110>
  802398:	75 11                	jne    8023ab <__umoddi3+0x11b>
  80239a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80239e:	73 0b                	jae    8023ab <__umoddi3+0x11b>
  8023a0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8023a4:	1b 14 24             	sbb    (%esp),%edx
  8023a7:	89 d1                	mov    %edx,%ecx
  8023a9:	89 c3                	mov    %eax,%ebx
  8023ab:	8b 54 24 08          	mov    0x8(%esp),%edx
  8023af:	29 da                	sub    %ebx,%edx
  8023b1:	19 ce                	sbb    %ecx,%esi
  8023b3:	89 f9                	mov    %edi,%ecx
  8023b5:	89 f0                	mov    %esi,%eax
  8023b7:	d3 e0                	shl    %cl,%eax
  8023b9:	89 e9                	mov    %ebp,%ecx
  8023bb:	d3 ea                	shr    %cl,%edx
  8023bd:	89 e9                	mov    %ebp,%ecx
  8023bf:	d3 ee                	shr    %cl,%esi
  8023c1:	09 d0                	or     %edx,%eax
  8023c3:	89 f2                	mov    %esi,%edx
  8023c5:	83 c4 1c             	add    $0x1c,%esp
  8023c8:	5b                   	pop    %ebx
  8023c9:	5e                   	pop    %esi
  8023ca:	5f                   	pop    %edi
  8023cb:	5d                   	pop    %ebp
  8023cc:	c3                   	ret    
  8023cd:	8d 76 00             	lea    0x0(%esi),%esi
  8023d0:	29 f9                	sub    %edi,%ecx
  8023d2:	19 d6                	sbb    %edx,%esi
  8023d4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023d8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8023dc:	e9 18 ff ff ff       	jmp    8022f9 <__umoddi3+0x69>
