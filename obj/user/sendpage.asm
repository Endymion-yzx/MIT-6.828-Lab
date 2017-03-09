
obj/user/sendpage.debug:     file format elf32-i386


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
  80002c:	e8 68 01 00 00       	call   800199 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#define TEMP_ADDR	((char*)0xa00000)
#define TEMP_ADDR_CHILD	((char*)0xb00000)

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	envid_t who;

	if ((who = fork()) == 0) {
  800039:	e8 1b 10 00 00       	call   801059 <fork>
  80003e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800041:	85 c0                	test   %eax,%eax
  800043:	0f 85 9f 00 00 00    	jne    8000e8 <umain+0xb5>
		// Child
		ipc_recv(&who, TEMP_ADDR_CHILD, 0);
  800049:	83 ec 04             	sub    $0x4,%esp
  80004c:	6a 00                	push   $0x0
  80004e:	68 00 00 b0 00       	push   $0xb00000
  800053:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800056:	50                   	push   %eax
  800057:	e8 5a 11 00 00       	call   8011b6 <ipc_recv>
		cprintf("%x got message: %s\n", who, TEMP_ADDR_CHILD);
  80005c:	83 c4 0c             	add    $0xc,%esp
  80005f:	68 00 00 b0 00       	push   $0xb00000
  800064:	ff 75 f4             	pushl  -0xc(%ebp)
  800067:	68 00 23 80 00       	push   $0x802300
  80006c:	e8 1b 02 00 00       	call   80028c <cprintf>
		if (strncmp(TEMP_ADDR_CHILD, str1, strlen(str1)) == 0)
  800071:	83 c4 04             	add    $0x4,%esp
  800074:	ff 35 04 30 80 00    	pushl  0x803004
  80007a:	e8 00 08 00 00       	call   80087f <strlen>
  80007f:	83 c4 0c             	add    $0xc,%esp
  800082:	50                   	push   %eax
  800083:	ff 35 04 30 80 00    	pushl  0x803004
  800089:	68 00 00 b0 00       	push   $0xb00000
  80008e:	e8 f5 08 00 00       	call   800988 <strncmp>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	85 c0                	test   %eax,%eax
  800098:	75 10                	jne    8000aa <umain+0x77>
			cprintf("child received correct message\n");
  80009a:	83 ec 0c             	sub    $0xc,%esp
  80009d:	68 14 23 80 00       	push   $0x802314
  8000a2:	e8 e5 01 00 00       	call   80028c <cprintf>
  8000a7:	83 c4 10             	add    $0x10,%esp

		memcpy(TEMP_ADDR_CHILD, str2, strlen(str2) + 1);
  8000aa:	83 ec 0c             	sub    $0xc,%esp
  8000ad:	ff 35 00 30 80 00    	pushl  0x803000
  8000b3:	e8 c7 07 00 00       	call   80087f <strlen>
  8000b8:	83 c4 0c             	add    $0xc,%esp
  8000bb:	83 c0 01             	add    $0x1,%eax
  8000be:	50                   	push   %eax
  8000bf:	ff 35 00 30 80 00    	pushl  0x803000
  8000c5:	68 00 00 b0 00       	push   $0xb00000
  8000ca:	e8 e3 09 00 00       	call   800ab2 <memcpy>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
  8000cf:	6a 07                	push   $0x7
  8000d1:	68 00 00 b0 00       	push   $0xb00000
  8000d6:	6a 00                	push   $0x0
  8000d8:	ff 75 f4             	pushl  -0xc(%ebp)
  8000db:	e8 4b 11 00 00       	call   80122b <ipc_send>
		return;
  8000e0:	83 c4 20             	add    $0x20,%esp
  8000e3:	e9 af 00 00 00       	jmp    800197 <umain+0x164>
	}

	// Parent
	sys_page_alloc(thisenv->env_id, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  8000e8:	a1 04 40 80 00       	mov    0x804004,%eax
  8000ed:	8b 40 48             	mov    0x48(%eax),%eax
  8000f0:	83 ec 04             	sub    $0x4,%esp
  8000f3:	6a 07                	push   $0x7
  8000f5:	68 00 00 a0 00       	push   $0xa00000
  8000fa:	50                   	push   %eax
  8000fb:	e8 bb 0b 00 00       	call   800cbb <sys_page_alloc>
	memcpy(TEMP_ADDR, str1, strlen(str1) + 1);
  800100:	83 c4 04             	add    $0x4,%esp
  800103:	ff 35 04 30 80 00    	pushl  0x803004
  800109:	e8 71 07 00 00       	call   80087f <strlen>
  80010e:	83 c4 0c             	add    $0xc,%esp
  800111:	83 c0 01             	add    $0x1,%eax
  800114:	50                   	push   %eax
  800115:	ff 35 04 30 80 00    	pushl  0x803004
  80011b:	68 00 00 a0 00       	push   $0xa00000
  800120:	e8 8d 09 00 00       	call   800ab2 <memcpy>
	ipc_send(who, 0, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  800125:	6a 07                	push   $0x7
  800127:	68 00 00 a0 00       	push   $0xa00000
  80012c:	6a 00                	push   $0x0
  80012e:	ff 75 f4             	pushl  -0xc(%ebp)
  800131:	e8 f5 10 00 00       	call   80122b <ipc_send>

	ipc_recv(&who, TEMP_ADDR, 0);
  800136:	83 c4 1c             	add    $0x1c,%esp
  800139:	6a 00                	push   $0x0
  80013b:	68 00 00 a0 00       	push   $0xa00000
  800140:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800143:	50                   	push   %eax
  800144:	e8 6d 10 00 00       	call   8011b6 <ipc_recv>
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
  800149:	83 c4 0c             	add    $0xc,%esp
  80014c:	68 00 00 a0 00       	push   $0xa00000
  800151:	ff 75 f4             	pushl  -0xc(%ebp)
  800154:	68 00 23 80 00       	push   $0x802300
  800159:	e8 2e 01 00 00       	call   80028c <cprintf>
	if (strncmp(TEMP_ADDR, str2, strlen(str2)) == 0)
  80015e:	83 c4 04             	add    $0x4,%esp
  800161:	ff 35 00 30 80 00    	pushl  0x803000
  800167:	e8 13 07 00 00       	call   80087f <strlen>
  80016c:	83 c4 0c             	add    $0xc,%esp
  80016f:	50                   	push   %eax
  800170:	ff 35 00 30 80 00    	pushl  0x803000
  800176:	68 00 00 a0 00       	push   $0xa00000
  80017b:	e8 08 08 00 00       	call   800988 <strncmp>
  800180:	83 c4 10             	add    $0x10,%esp
  800183:	85 c0                	test   %eax,%eax
  800185:	75 10                	jne    800197 <umain+0x164>
		cprintf("parent received correct message\n");
  800187:	83 ec 0c             	sub    $0xc,%esp
  80018a:	68 34 23 80 00       	push   $0x802334
  80018f:	e8 f8 00 00 00       	call   80028c <cprintf>
  800194:	83 c4 10             	add    $0x10,%esp
	return;
}
  800197:	c9                   	leave  
  800198:	c3                   	ret    

00800199 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800199:	55                   	push   %ebp
  80019a:	89 e5                	mov    %esp,%ebp
  80019c:	56                   	push   %esi
  80019d:	53                   	push   %ebx
  80019e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001a1:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	envid_t envid = sys_getenvid();
  8001a4:	e8 d4 0a 00 00       	call   800c7d <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8001a9:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001ae:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001b1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001b6:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001bb:	85 db                	test   %ebx,%ebx
  8001bd:	7e 07                	jle    8001c6 <libmain+0x2d>
		binaryname = argv[0];
  8001bf:	8b 06                	mov    (%esi),%eax
  8001c1:	a3 08 30 80 00       	mov    %eax,0x803008

	// call user main routine
	umain(argc, argv);
  8001c6:	83 ec 08             	sub    $0x8,%esp
  8001c9:	56                   	push   %esi
  8001ca:	53                   	push   %ebx
  8001cb:	e8 63 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8001d0:	e8 0a 00 00 00       	call   8001df <exit>
}
  8001d5:	83 c4 10             	add    $0x10,%esp
  8001d8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001db:	5b                   	pop    %ebx
  8001dc:	5e                   	pop    %esi
  8001dd:	5d                   	pop    %ebp
  8001de:	c3                   	ret    

008001df <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001df:	55                   	push   %ebp
  8001e0:	89 e5                	mov    %esp,%ebp
  8001e2:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001e5:	e8 99 12 00 00       	call   801483 <close_all>
	sys_env_destroy(0);
  8001ea:	83 ec 0c             	sub    $0xc,%esp
  8001ed:	6a 00                	push   $0x0
  8001ef:	e8 48 0a 00 00       	call   800c3c <sys_env_destroy>
}
  8001f4:	83 c4 10             	add    $0x10,%esp
  8001f7:	c9                   	leave  
  8001f8:	c3                   	ret    

008001f9 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001f9:	55                   	push   %ebp
  8001fa:	89 e5                	mov    %esp,%ebp
  8001fc:	53                   	push   %ebx
  8001fd:	83 ec 04             	sub    $0x4,%esp
  800200:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800203:	8b 13                	mov    (%ebx),%edx
  800205:	8d 42 01             	lea    0x1(%edx),%eax
  800208:	89 03                	mov    %eax,(%ebx)
  80020a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80020d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800211:	3d ff 00 00 00       	cmp    $0xff,%eax
  800216:	75 1a                	jne    800232 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800218:	83 ec 08             	sub    $0x8,%esp
  80021b:	68 ff 00 00 00       	push   $0xff
  800220:	8d 43 08             	lea    0x8(%ebx),%eax
  800223:	50                   	push   %eax
  800224:	e8 d6 09 00 00       	call   800bff <sys_cputs>
		b->idx = 0;
  800229:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80022f:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800232:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800236:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800239:	c9                   	leave  
  80023a:	c3                   	ret    

0080023b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80023b:	55                   	push   %ebp
  80023c:	89 e5                	mov    %esp,%ebp
  80023e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800244:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80024b:	00 00 00 
	b.cnt = 0;
  80024e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800255:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800258:	ff 75 0c             	pushl  0xc(%ebp)
  80025b:	ff 75 08             	pushl  0x8(%ebp)
  80025e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800264:	50                   	push   %eax
  800265:	68 f9 01 80 00       	push   $0x8001f9
  80026a:	e8 1a 01 00 00       	call   800389 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80026f:	83 c4 08             	add    $0x8,%esp
  800272:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800278:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80027e:	50                   	push   %eax
  80027f:	e8 7b 09 00 00       	call   800bff <sys_cputs>

	return b.cnt;
}
  800284:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80028a:	c9                   	leave  
  80028b:	c3                   	ret    

0080028c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80028c:	55                   	push   %ebp
  80028d:	89 e5                	mov    %esp,%ebp
  80028f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800292:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800295:	50                   	push   %eax
  800296:	ff 75 08             	pushl  0x8(%ebp)
  800299:	e8 9d ff ff ff       	call   80023b <vcprintf>
	va_end(ap);

	return cnt;
}
  80029e:	c9                   	leave  
  80029f:	c3                   	ret    

008002a0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	57                   	push   %edi
  8002a4:	56                   	push   %esi
  8002a5:	53                   	push   %ebx
  8002a6:	83 ec 1c             	sub    $0x1c,%esp
  8002a9:	89 c7                	mov    %eax,%edi
  8002ab:	89 d6                	mov    %edx,%esi
  8002ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002b3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002b6:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002b9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002bc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002c4:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002c7:	39 d3                	cmp    %edx,%ebx
  8002c9:	72 05                	jb     8002d0 <printnum+0x30>
  8002cb:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002ce:	77 45                	ja     800315 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002d0:	83 ec 0c             	sub    $0xc,%esp
  8002d3:	ff 75 18             	pushl  0x18(%ebp)
  8002d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8002d9:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002dc:	53                   	push   %ebx
  8002dd:	ff 75 10             	pushl  0x10(%ebp)
  8002e0:	83 ec 08             	sub    $0x8,%esp
  8002e3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002e6:	ff 75 e0             	pushl  -0x20(%ebp)
  8002e9:	ff 75 dc             	pushl  -0x24(%ebp)
  8002ec:	ff 75 d8             	pushl  -0x28(%ebp)
  8002ef:	e8 7c 1d 00 00       	call   802070 <__udivdi3>
  8002f4:	83 c4 18             	add    $0x18,%esp
  8002f7:	52                   	push   %edx
  8002f8:	50                   	push   %eax
  8002f9:	89 f2                	mov    %esi,%edx
  8002fb:	89 f8                	mov    %edi,%eax
  8002fd:	e8 9e ff ff ff       	call   8002a0 <printnum>
  800302:	83 c4 20             	add    $0x20,%esp
  800305:	eb 18                	jmp    80031f <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800307:	83 ec 08             	sub    $0x8,%esp
  80030a:	56                   	push   %esi
  80030b:	ff 75 18             	pushl  0x18(%ebp)
  80030e:	ff d7                	call   *%edi
  800310:	83 c4 10             	add    $0x10,%esp
  800313:	eb 03                	jmp    800318 <printnum+0x78>
  800315:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800318:	83 eb 01             	sub    $0x1,%ebx
  80031b:	85 db                	test   %ebx,%ebx
  80031d:	7f e8                	jg     800307 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80031f:	83 ec 08             	sub    $0x8,%esp
  800322:	56                   	push   %esi
  800323:	83 ec 04             	sub    $0x4,%esp
  800326:	ff 75 e4             	pushl  -0x1c(%ebp)
  800329:	ff 75 e0             	pushl  -0x20(%ebp)
  80032c:	ff 75 dc             	pushl  -0x24(%ebp)
  80032f:	ff 75 d8             	pushl  -0x28(%ebp)
  800332:	e8 69 1e 00 00       	call   8021a0 <__umoddi3>
  800337:	83 c4 14             	add    $0x14,%esp
  80033a:	0f be 80 ac 23 80 00 	movsbl 0x8023ac(%eax),%eax
  800341:	50                   	push   %eax
  800342:	ff d7                	call   *%edi
}
  800344:	83 c4 10             	add    $0x10,%esp
  800347:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80034a:	5b                   	pop    %ebx
  80034b:	5e                   	pop    %esi
  80034c:	5f                   	pop    %edi
  80034d:	5d                   	pop    %ebp
  80034e:	c3                   	ret    

0080034f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80034f:	55                   	push   %ebp
  800350:	89 e5                	mov    %esp,%ebp
  800352:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800355:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800359:	8b 10                	mov    (%eax),%edx
  80035b:	3b 50 04             	cmp    0x4(%eax),%edx
  80035e:	73 0a                	jae    80036a <sprintputch+0x1b>
		*b->buf++ = ch;
  800360:	8d 4a 01             	lea    0x1(%edx),%ecx
  800363:	89 08                	mov    %ecx,(%eax)
  800365:	8b 45 08             	mov    0x8(%ebp),%eax
  800368:	88 02                	mov    %al,(%edx)
}
  80036a:	5d                   	pop    %ebp
  80036b:	c3                   	ret    

0080036c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80036c:	55                   	push   %ebp
  80036d:	89 e5                	mov    %esp,%ebp
  80036f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800372:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800375:	50                   	push   %eax
  800376:	ff 75 10             	pushl  0x10(%ebp)
  800379:	ff 75 0c             	pushl  0xc(%ebp)
  80037c:	ff 75 08             	pushl  0x8(%ebp)
  80037f:	e8 05 00 00 00       	call   800389 <vprintfmt>
	va_end(ap);
}
  800384:	83 c4 10             	add    $0x10,%esp
  800387:	c9                   	leave  
  800388:	c3                   	ret    

00800389 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800389:	55                   	push   %ebp
  80038a:	89 e5                	mov    %esp,%ebp
  80038c:	57                   	push   %edi
  80038d:	56                   	push   %esi
  80038e:	53                   	push   %ebx
  80038f:	83 ec 2c             	sub    $0x2c,%esp
  800392:	8b 75 08             	mov    0x8(%ebp),%esi
  800395:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800398:	8b 7d 10             	mov    0x10(%ebp),%edi
  80039b:	eb 12                	jmp    8003af <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80039d:	85 c0                	test   %eax,%eax
  80039f:	0f 84 6a 04 00 00    	je     80080f <vprintfmt+0x486>
				return;
			putch(ch, putdat);
  8003a5:	83 ec 08             	sub    $0x8,%esp
  8003a8:	53                   	push   %ebx
  8003a9:	50                   	push   %eax
  8003aa:	ff d6                	call   *%esi
  8003ac:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003af:	83 c7 01             	add    $0x1,%edi
  8003b2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003b6:	83 f8 25             	cmp    $0x25,%eax
  8003b9:	75 e2                	jne    80039d <vprintfmt+0x14>
  8003bb:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003bf:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003c6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003cd:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003d4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003d9:	eb 07                	jmp    8003e2 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003db:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003de:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e2:	8d 47 01             	lea    0x1(%edi),%eax
  8003e5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003e8:	0f b6 07             	movzbl (%edi),%eax
  8003eb:	0f b6 d0             	movzbl %al,%edx
  8003ee:	83 e8 23             	sub    $0x23,%eax
  8003f1:	3c 55                	cmp    $0x55,%al
  8003f3:	0f 87 fb 03 00 00    	ja     8007f4 <vprintfmt+0x46b>
  8003f9:	0f b6 c0             	movzbl %al,%eax
  8003fc:	ff 24 85 e0 24 80 00 	jmp    *0x8024e0(,%eax,4)
  800403:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800406:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80040a:	eb d6                	jmp    8003e2 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80040f:	b8 00 00 00 00       	mov    $0x0,%eax
  800414:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800417:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80041a:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80041e:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800421:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800424:	83 f9 09             	cmp    $0x9,%ecx
  800427:	77 3f                	ja     800468 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800429:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80042c:	eb e9                	jmp    800417 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80042e:	8b 45 14             	mov    0x14(%ebp),%eax
  800431:	8b 00                	mov    (%eax),%eax
  800433:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800436:	8b 45 14             	mov    0x14(%ebp),%eax
  800439:	8d 40 04             	lea    0x4(%eax),%eax
  80043c:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800442:	eb 2a                	jmp    80046e <vprintfmt+0xe5>
  800444:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800447:	85 c0                	test   %eax,%eax
  800449:	ba 00 00 00 00       	mov    $0x0,%edx
  80044e:	0f 49 d0             	cmovns %eax,%edx
  800451:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800454:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800457:	eb 89                	jmp    8003e2 <vprintfmt+0x59>
  800459:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80045c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800463:	e9 7a ff ff ff       	jmp    8003e2 <vprintfmt+0x59>
  800468:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80046b:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80046e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800472:	0f 89 6a ff ff ff    	jns    8003e2 <vprintfmt+0x59>
				width = precision, precision = -1;
  800478:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80047b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80047e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800485:	e9 58 ff ff ff       	jmp    8003e2 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80048a:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800490:	e9 4d ff ff ff       	jmp    8003e2 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800495:	8b 45 14             	mov    0x14(%ebp),%eax
  800498:	8d 78 04             	lea    0x4(%eax),%edi
  80049b:	83 ec 08             	sub    $0x8,%esp
  80049e:	53                   	push   %ebx
  80049f:	ff 30                	pushl  (%eax)
  8004a1:	ff d6                	call   *%esi
			break;
  8004a3:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004a6:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004ac:	e9 fe fe ff ff       	jmp    8003af <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b4:	8d 78 04             	lea    0x4(%eax),%edi
  8004b7:	8b 00                	mov    (%eax),%eax
  8004b9:	99                   	cltd   
  8004ba:	31 d0                	xor    %edx,%eax
  8004bc:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004be:	83 f8 0f             	cmp    $0xf,%eax
  8004c1:	7f 0b                	jg     8004ce <vprintfmt+0x145>
  8004c3:	8b 14 85 40 26 80 00 	mov    0x802640(,%eax,4),%edx
  8004ca:	85 d2                	test   %edx,%edx
  8004cc:	75 1b                	jne    8004e9 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  8004ce:	50                   	push   %eax
  8004cf:	68 c4 23 80 00       	push   $0x8023c4
  8004d4:	53                   	push   %ebx
  8004d5:	56                   	push   %esi
  8004d6:	e8 91 fe ff ff       	call   80036c <printfmt>
  8004db:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004de:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004e4:	e9 c6 fe ff ff       	jmp    8003af <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004e9:	52                   	push   %edx
  8004ea:	68 92 28 80 00       	push   $0x802892
  8004ef:	53                   	push   %ebx
  8004f0:	56                   	push   %esi
  8004f1:	e8 76 fe ff ff       	call   80036c <printfmt>
  8004f6:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004f9:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004ff:	e9 ab fe ff ff       	jmp    8003af <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800504:	8b 45 14             	mov    0x14(%ebp),%eax
  800507:	83 c0 04             	add    $0x4,%eax
  80050a:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80050d:	8b 45 14             	mov    0x14(%ebp),%eax
  800510:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800512:	85 ff                	test   %edi,%edi
  800514:	b8 bd 23 80 00       	mov    $0x8023bd,%eax
  800519:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80051c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800520:	0f 8e 94 00 00 00    	jle    8005ba <vprintfmt+0x231>
  800526:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80052a:	0f 84 98 00 00 00    	je     8005c8 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800530:	83 ec 08             	sub    $0x8,%esp
  800533:	ff 75 d0             	pushl  -0x30(%ebp)
  800536:	57                   	push   %edi
  800537:	e8 5b 03 00 00       	call   800897 <strnlen>
  80053c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80053f:	29 c1                	sub    %eax,%ecx
  800541:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800544:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800547:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80054b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80054e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800551:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800553:	eb 0f                	jmp    800564 <vprintfmt+0x1db>
					putch(padc, putdat);
  800555:	83 ec 08             	sub    $0x8,%esp
  800558:	53                   	push   %ebx
  800559:	ff 75 e0             	pushl  -0x20(%ebp)
  80055c:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80055e:	83 ef 01             	sub    $0x1,%edi
  800561:	83 c4 10             	add    $0x10,%esp
  800564:	85 ff                	test   %edi,%edi
  800566:	7f ed                	jg     800555 <vprintfmt+0x1cc>
  800568:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80056b:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80056e:	85 c9                	test   %ecx,%ecx
  800570:	b8 00 00 00 00       	mov    $0x0,%eax
  800575:	0f 49 c1             	cmovns %ecx,%eax
  800578:	29 c1                	sub    %eax,%ecx
  80057a:	89 75 08             	mov    %esi,0x8(%ebp)
  80057d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800580:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800583:	89 cb                	mov    %ecx,%ebx
  800585:	eb 4d                	jmp    8005d4 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800587:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80058b:	74 1b                	je     8005a8 <vprintfmt+0x21f>
  80058d:	0f be c0             	movsbl %al,%eax
  800590:	83 e8 20             	sub    $0x20,%eax
  800593:	83 f8 5e             	cmp    $0x5e,%eax
  800596:	76 10                	jbe    8005a8 <vprintfmt+0x21f>
					putch('?', putdat);
  800598:	83 ec 08             	sub    $0x8,%esp
  80059b:	ff 75 0c             	pushl  0xc(%ebp)
  80059e:	6a 3f                	push   $0x3f
  8005a0:	ff 55 08             	call   *0x8(%ebp)
  8005a3:	83 c4 10             	add    $0x10,%esp
  8005a6:	eb 0d                	jmp    8005b5 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  8005a8:	83 ec 08             	sub    $0x8,%esp
  8005ab:	ff 75 0c             	pushl  0xc(%ebp)
  8005ae:	52                   	push   %edx
  8005af:	ff 55 08             	call   *0x8(%ebp)
  8005b2:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005b5:	83 eb 01             	sub    $0x1,%ebx
  8005b8:	eb 1a                	jmp    8005d4 <vprintfmt+0x24b>
  8005ba:	89 75 08             	mov    %esi,0x8(%ebp)
  8005bd:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005c0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005c3:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005c6:	eb 0c                	jmp    8005d4 <vprintfmt+0x24b>
  8005c8:	89 75 08             	mov    %esi,0x8(%ebp)
  8005cb:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005ce:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005d1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005d4:	83 c7 01             	add    $0x1,%edi
  8005d7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005db:	0f be d0             	movsbl %al,%edx
  8005de:	85 d2                	test   %edx,%edx
  8005e0:	74 23                	je     800605 <vprintfmt+0x27c>
  8005e2:	85 f6                	test   %esi,%esi
  8005e4:	78 a1                	js     800587 <vprintfmt+0x1fe>
  8005e6:	83 ee 01             	sub    $0x1,%esi
  8005e9:	79 9c                	jns    800587 <vprintfmt+0x1fe>
  8005eb:	89 df                	mov    %ebx,%edi
  8005ed:	8b 75 08             	mov    0x8(%ebp),%esi
  8005f0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005f3:	eb 18                	jmp    80060d <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005f5:	83 ec 08             	sub    $0x8,%esp
  8005f8:	53                   	push   %ebx
  8005f9:	6a 20                	push   $0x20
  8005fb:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005fd:	83 ef 01             	sub    $0x1,%edi
  800600:	83 c4 10             	add    $0x10,%esp
  800603:	eb 08                	jmp    80060d <vprintfmt+0x284>
  800605:	89 df                	mov    %ebx,%edi
  800607:	8b 75 08             	mov    0x8(%ebp),%esi
  80060a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80060d:	85 ff                	test   %edi,%edi
  80060f:	7f e4                	jg     8005f5 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800611:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800614:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800617:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80061a:	e9 90 fd ff ff       	jmp    8003af <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80061f:	83 f9 01             	cmp    $0x1,%ecx
  800622:	7e 19                	jle    80063d <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800624:	8b 45 14             	mov    0x14(%ebp),%eax
  800627:	8b 50 04             	mov    0x4(%eax),%edx
  80062a:	8b 00                	mov    (%eax),%eax
  80062c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80062f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800632:	8b 45 14             	mov    0x14(%ebp),%eax
  800635:	8d 40 08             	lea    0x8(%eax),%eax
  800638:	89 45 14             	mov    %eax,0x14(%ebp)
  80063b:	eb 38                	jmp    800675 <vprintfmt+0x2ec>
	else if (lflag)
  80063d:	85 c9                	test   %ecx,%ecx
  80063f:	74 1b                	je     80065c <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800641:	8b 45 14             	mov    0x14(%ebp),%eax
  800644:	8b 00                	mov    (%eax),%eax
  800646:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800649:	89 c1                	mov    %eax,%ecx
  80064b:	c1 f9 1f             	sar    $0x1f,%ecx
  80064e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800651:	8b 45 14             	mov    0x14(%ebp),%eax
  800654:	8d 40 04             	lea    0x4(%eax),%eax
  800657:	89 45 14             	mov    %eax,0x14(%ebp)
  80065a:	eb 19                	jmp    800675 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  80065c:	8b 45 14             	mov    0x14(%ebp),%eax
  80065f:	8b 00                	mov    (%eax),%eax
  800661:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800664:	89 c1                	mov    %eax,%ecx
  800666:	c1 f9 1f             	sar    $0x1f,%ecx
  800669:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80066c:	8b 45 14             	mov    0x14(%ebp),%eax
  80066f:	8d 40 04             	lea    0x4(%eax),%eax
  800672:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800675:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800678:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80067b:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800680:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800684:	0f 89 36 01 00 00    	jns    8007c0 <vprintfmt+0x437>
				putch('-', putdat);
  80068a:	83 ec 08             	sub    $0x8,%esp
  80068d:	53                   	push   %ebx
  80068e:	6a 2d                	push   $0x2d
  800690:	ff d6                	call   *%esi
				num = -(long long) num;
  800692:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800695:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800698:	f7 da                	neg    %edx
  80069a:	83 d1 00             	adc    $0x0,%ecx
  80069d:	f7 d9                	neg    %ecx
  80069f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8006a2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006a7:	e9 14 01 00 00       	jmp    8007c0 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006ac:	83 f9 01             	cmp    $0x1,%ecx
  8006af:	7e 18                	jle    8006c9 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  8006b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b4:	8b 10                	mov    (%eax),%edx
  8006b6:	8b 48 04             	mov    0x4(%eax),%ecx
  8006b9:	8d 40 08             	lea    0x8(%eax),%eax
  8006bc:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8006bf:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006c4:	e9 f7 00 00 00       	jmp    8007c0 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8006c9:	85 c9                	test   %ecx,%ecx
  8006cb:	74 1a                	je     8006e7 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  8006cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d0:	8b 10                	mov    (%eax),%edx
  8006d2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006d7:	8d 40 04             	lea    0x4(%eax),%eax
  8006da:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8006dd:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006e2:	e9 d9 00 00 00       	jmp    8007c0 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8006e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ea:	8b 10                	mov    (%eax),%edx
  8006ec:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006f1:	8d 40 04             	lea    0x4(%eax),%eax
  8006f4:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8006f7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006fc:	e9 bf 00 00 00       	jmp    8007c0 <vprintfmt+0x437>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800701:	83 f9 01             	cmp    $0x1,%ecx
  800704:	7e 13                	jle    800719 <vprintfmt+0x390>
		return va_arg(*ap, long long);
  800706:	8b 45 14             	mov    0x14(%ebp),%eax
  800709:	8b 50 04             	mov    0x4(%eax),%edx
  80070c:	8b 00                	mov    (%eax),%eax
  80070e:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800711:	8d 49 08             	lea    0x8(%ecx),%ecx
  800714:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800717:	eb 28                	jmp    800741 <vprintfmt+0x3b8>
	else if (lflag)
  800719:	85 c9                	test   %ecx,%ecx
  80071b:	74 13                	je     800730 <vprintfmt+0x3a7>
		return va_arg(*ap, long);
  80071d:	8b 45 14             	mov    0x14(%ebp),%eax
  800720:	8b 10                	mov    (%eax),%edx
  800722:	89 d0                	mov    %edx,%eax
  800724:	99                   	cltd   
  800725:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800728:	8d 49 04             	lea    0x4(%ecx),%ecx
  80072b:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80072e:	eb 11                	jmp    800741 <vprintfmt+0x3b8>
	else
		return va_arg(*ap, int);
  800730:	8b 45 14             	mov    0x14(%ebp),%eax
  800733:	8b 10                	mov    (%eax),%edx
  800735:	89 d0                	mov    %edx,%eax
  800737:	99                   	cltd   
  800738:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80073b:	8d 49 04             	lea    0x4(%ecx),%ecx
  80073e:	89 4d 14             	mov    %ecx,0x14(%ebp)
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getint(&ap, lflag);
  800741:	89 d1                	mov    %edx,%ecx
  800743:	89 c2                	mov    %eax,%edx
			base = 8;
  800745:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  80074a:	eb 74                	jmp    8007c0 <vprintfmt+0x437>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80074c:	83 ec 08             	sub    $0x8,%esp
  80074f:	53                   	push   %ebx
  800750:	6a 30                	push   $0x30
  800752:	ff d6                	call   *%esi
			putch('x', putdat);
  800754:	83 c4 08             	add    $0x8,%esp
  800757:	53                   	push   %ebx
  800758:	6a 78                	push   $0x78
  80075a:	ff d6                	call   *%esi
			num = (unsigned long long)
  80075c:	8b 45 14             	mov    0x14(%ebp),%eax
  80075f:	8b 10                	mov    (%eax),%edx
  800761:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800766:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800769:	8d 40 04             	lea    0x4(%eax),%eax
  80076c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80076f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800774:	eb 4a                	jmp    8007c0 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800776:	83 f9 01             	cmp    $0x1,%ecx
  800779:	7e 15                	jle    800790 <vprintfmt+0x407>
		return va_arg(*ap, unsigned long long);
  80077b:	8b 45 14             	mov    0x14(%ebp),%eax
  80077e:	8b 10                	mov    (%eax),%edx
  800780:	8b 48 04             	mov    0x4(%eax),%ecx
  800783:	8d 40 08             	lea    0x8(%eax),%eax
  800786:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800789:	b8 10 00 00 00       	mov    $0x10,%eax
  80078e:	eb 30                	jmp    8007c0 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800790:	85 c9                	test   %ecx,%ecx
  800792:	74 17                	je     8007ab <vprintfmt+0x422>
		return va_arg(*ap, unsigned long);
  800794:	8b 45 14             	mov    0x14(%ebp),%eax
  800797:	8b 10                	mov    (%eax),%edx
  800799:	b9 00 00 00 00       	mov    $0x0,%ecx
  80079e:	8d 40 04             	lea    0x4(%eax),%eax
  8007a1:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8007a4:	b8 10 00 00 00       	mov    $0x10,%eax
  8007a9:	eb 15                	jmp    8007c0 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8007ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ae:	8b 10                	mov    (%eax),%edx
  8007b0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007b5:	8d 40 04             	lea    0x4(%eax),%eax
  8007b8:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8007bb:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007c0:	83 ec 0c             	sub    $0xc,%esp
  8007c3:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8007c7:	57                   	push   %edi
  8007c8:	ff 75 e0             	pushl  -0x20(%ebp)
  8007cb:	50                   	push   %eax
  8007cc:	51                   	push   %ecx
  8007cd:	52                   	push   %edx
  8007ce:	89 da                	mov    %ebx,%edx
  8007d0:	89 f0                	mov    %esi,%eax
  8007d2:	e8 c9 fa ff ff       	call   8002a0 <printnum>
			break;
  8007d7:	83 c4 20             	add    $0x20,%esp
  8007da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007dd:	e9 cd fb ff ff       	jmp    8003af <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007e2:	83 ec 08             	sub    $0x8,%esp
  8007e5:	53                   	push   %ebx
  8007e6:	52                   	push   %edx
  8007e7:	ff d6                	call   *%esi
			break;
  8007e9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007ef:	e9 bb fb ff ff       	jmp    8003af <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007f4:	83 ec 08             	sub    $0x8,%esp
  8007f7:	53                   	push   %ebx
  8007f8:	6a 25                	push   $0x25
  8007fa:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007fc:	83 c4 10             	add    $0x10,%esp
  8007ff:	eb 03                	jmp    800804 <vprintfmt+0x47b>
  800801:	83 ef 01             	sub    $0x1,%edi
  800804:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800808:	75 f7                	jne    800801 <vprintfmt+0x478>
  80080a:	e9 a0 fb ff ff       	jmp    8003af <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80080f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800812:	5b                   	pop    %ebx
  800813:	5e                   	pop    %esi
  800814:	5f                   	pop    %edi
  800815:	5d                   	pop    %ebp
  800816:	c3                   	ret    

00800817 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800817:	55                   	push   %ebp
  800818:	89 e5                	mov    %esp,%ebp
  80081a:	83 ec 18             	sub    $0x18,%esp
  80081d:	8b 45 08             	mov    0x8(%ebp),%eax
  800820:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800823:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800826:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80082a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80082d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800834:	85 c0                	test   %eax,%eax
  800836:	74 26                	je     80085e <vsnprintf+0x47>
  800838:	85 d2                	test   %edx,%edx
  80083a:	7e 22                	jle    80085e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80083c:	ff 75 14             	pushl  0x14(%ebp)
  80083f:	ff 75 10             	pushl  0x10(%ebp)
  800842:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800845:	50                   	push   %eax
  800846:	68 4f 03 80 00       	push   $0x80034f
  80084b:	e8 39 fb ff ff       	call   800389 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800850:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800853:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800856:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800859:	83 c4 10             	add    $0x10,%esp
  80085c:	eb 05                	jmp    800863 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80085e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800863:	c9                   	leave  
  800864:	c3                   	ret    

00800865 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800865:	55                   	push   %ebp
  800866:	89 e5                	mov    %esp,%ebp
  800868:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80086b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80086e:	50                   	push   %eax
  80086f:	ff 75 10             	pushl  0x10(%ebp)
  800872:	ff 75 0c             	pushl  0xc(%ebp)
  800875:	ff 75 08             	pushl  0x8(%ebp)
  800878:	e8 9a ff ff ff       	call   800817 <vsnprintf>
	va_end(ap);

	return rc;
}
  80087d:	c9                   	leave  
  80087e:	c3                   	ret    

0080087f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80087f:	55                   	push   %ebp
  800880:	89 e5                	mov    %esp,%ebp
  800882:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800885:	b8 00 00 00 00       	mov    $0x0,%eax
  80088a:	eb 03                	jmp    80088f <strlen+0x10>
		n++;
  80088c:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80088f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800893:	75 f7                	jne    80088c <strlen+0xd>
		n++;
	return n;
}
  800895:	5d                   	pop    %ebp
  800896:	c3                   	ret    

00800897 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800897:	55                   	push   %ebp
  800898:	89 e5                	mov    %esp,%ebp
  80089a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80089d:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8008a5:	eb 03                	jmp    8008aa <strnlen+0x13>
		n++;
  8008a7:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008aa:	39 c2                	cmp    %eax,%edx
  8008ac:	74 08                	je     8008b6 <strnlen+0x1f>
  8008ae:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8008b2:	75 f3                	jne    8008a7 <strnlen+0x10>
  8008b4:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8008b6:	5d                   	pop    %ebp
  8008b7:	c3                   	ret    

008008b8 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008b8:	55                   	push   %ebp
  8008b9:	89 e5                	mov    %esp,%ebp
  8008bb:	53                   	push   %ebx
  8008bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008c2:	89 c2                	mov    %eax,%edx
  8008c4:	83 c2 01             	add    $0x1,%edx
  8008c7:	83 c1 01             	add    $0x1,%ecx
  8008ca:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008ce:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008d1:	84 db                	test   %bl,%bl
  8008d3:	75 ef                	jne    8008c4 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008d5:	5b                   	pop    %ebx
  8008d6:	5d                   	pop    %ebp
  8008d7:	c3                   	ret    

008008d8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008d8:	55                   	push   %ebp
  8008d9:	89 e5                	mov    %esp,%ebp
  8008db:	53                   	push   %ebx
  8008dc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008df:	53                   	push   %ebx
  8008e0:	e8 9a ff ff ff       	call   80087f <strlen>
  8008e5:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008e8:	ff 75 0c             	pushl  0xc(%ebp)
  8008eb:	01 d8                	add    %ebx,%eax
  8008ed:	50                   	push   %eax
  8008ee:	e8 c5 ff ff ff       	call   8008b8 <strcpy>
	return dst;
}
  8008f3:	89 d8                	mov    %ebx,%eax
  8008f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008f8:	c9                   	leave  
  8008f9:	c3                   	ret    

008008fa <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008fa:	55                   	push   %ebp
  8008fb:	89 e5                	mov    %esp,%ebp
  8008fd:	56                   	push   %esi
  8008fe:	53                   	push   %ebx
  8008ff:	8b 75 08             	mov    0x8(%ebp),%esi
  800902:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800905:	89 f3                	mov    %esi,%ebx
  800907:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80090a:	89 f2                	mov    %esi,%edx
  80090c:	eb 0f                	jmp    80091d <strncpy+0x23>
		*dst++ = *src;
  80090e:	83 c2 01             	add    $0x1,%edx
  800911:	0f b6 01             	movzbl (%ecx),%eax
  800914:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800917:	80 39 01             	cmpb   $0x1,(%ecx)
  80091a:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80091d:	39 da                	cmp    %ebx,%edx
  80091f:	75 ed                	jne    80090e <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800921:	89 f0                	mov    %esi,%eax
  800923:	5b                   	pop    %ebx
  800924:	5e                   	pop    %esi
  800925:	5d                   	pop    %ebp
  800926:	c3                   	ret    

00800927 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800927:	55                   	push   %ebp
  800928:	89 e5                	mov    %esp,%ebp
  80092a:	56                   	push   %esi
  80092b:	53                   	push   %ebx
  80092c:	8b 75 08             	mov    0x8(%ebp),%esi
  80092f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800932:	8b 55 10             	mov    0x10(%ebp),%edx
  800935:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800937:	85 d2                	test   %edx,%edx
  800939:	74 21                	je     80095c <strlcpy+0x35>
  80093b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80093f:	89 f2                	mov    %esi,%edx
  800941:	eb 09                	jmp    80094c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800943:	83 c2 01             	add    $0x1,%edx
  800946:	83 c1 01             	add    $0x1,%ecx
  800949:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80094c:	39 c2                	cmp    %eax,%edx
  80094e:	74 09                	je     800959 <strlcpy+0x32>
  800950:	0f b6 19             	movzbl (%ecx),%ebx
  800953:	84 db                	test   %bl,%bl
  800955:	75 ec                	jne    800943 <strlcpy+0x1c>
  800957:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800959:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80095c:	29 f0                	sub    %esi,%eax
}
  80095e:	5b                   	pop    %ebx
  80095f:	5e                   	pop    %esi
  800960:	5d                   	pop    %ebp
  800961:	c3                   	ret    

00800962 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800962:	55                   	push   %ebp
  800963:	89 e5                	mov    %esp,%ebp
  800965:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800968:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80096b:	eb 06                	jmp    800973 <strcmp+0x11>
		p++, q++;
  80096d:	83 c1 01             	add    $0x1,%ecx
  800970:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800973:	0f b6 01             	movzbl (%ecx),%eax
  800976:	84 c0                	test   %al,%al
  800978:	74 04                	je     80097e <strcmp+0x1c>
  80097a:	3a 02                	cmp    (%edx),%al
  80097c:	74 ef                	je     80096d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80097e:	0f b6 c0             	movzbl %al,%eax
  800981:	0f b6 12             	movzbl (%edx),%edx
  800984:	29 d0                	sub    %edx,%eax
}
  800986:	5d                   	pop    %ebp
  800987:	c3                   	ret    

00800988 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800988:	55                   	push   %ebp
  800989:	89 e5                	mov    %esp,%ebp
  80098b:	53                   	push   %ebx
  80098c:	8b 45 08             	mov    0x8(%ebp),%eax
  80098f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800992:	89 c3                	mov    %eax,%ebx
  800994:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800997:	eb 06                	jmp    80099f <strncmp+0x17>
		n--, p++, q++;
  800999:	83 c0 01             	add    $0x1,%eax
  80099c:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80099f:	39 d8                	cmp    %ebx,%eax
  8009a1:	74 15                	je     8009b8 <strncmp+0x30>
  8009a3:	0f b6 08             	movzbl (%eax),%ecx
  8009a6:	84 c9                	test   %cl,%cl
  8009a8:	74 04                	je     8009ae <strncmp+0x26>
  8009aa:	3a 0a                	cmp    (%edx),%cl
  8009ac:	74 eb                	je     800999 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009ae:	0f b6 00             	movzbl (%eax),%eax
  8009b1:	0f b6 12             	movzbl (%edx),%edx
  8009b4:	29 d0                	sub    %edx,%eax
  8009b6:	eb 05                	jmp    8009bd <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009b8:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009bd:	5b                   	pop    %ebx
  8009be:	5d                   	pop    %ebp
  8009bf:	c3                   	ret    

008009c0 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009c0:	55                   	push   %ebp
  8009c1:	89 e5                	mov    %esp,%ebp
  8009c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009ca:	eb 07                	jmp    8009d3 <strchr+0x13>
		if (*s == c)
  8009cc:	38 ca                	cmp    %cl,%dl
  8009ce:	74 0f                	je     8009df <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009d0:	83 c0 01             	add    $0x1,%eax
  8009d3:	0f b6 10             	movzbl (%eax),%edx
  8009d6:	84 d2                	test   %dl,%dl
  8009d8:	75 f2                	jne    8009cc <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009da:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009df:	5d                   	pop    %ebp
  8009e0:	c3                   	ret    

008009e1 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009e1:	55                   	push   %ebp
  8009e2:	89 e5                	mov    %esp,%ebp
  8009e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009eb:	eb 03                	jmp    8009f0 <strfind+0xf>
  8009ed:	83 c0 01             	add    $0x1,%eax
  8009f0:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009f3:	38 ca                	cmp    %cl,%dl
  8009f5:	74 04                	je     8009fb <strfind+0x1a>
  8009f7:	84 d2                	test   %dl,%dl
  8009f9:	75 f2                	jne    8009ed <strfind+0xc>
			break;
	return (char *) s;
}
  8009fb:	5d                   	pop    %ebp
  8009fc:	c3                   	ret    

008009fd <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009fd:	55                   	push   %ebp
  8009fe:	89 e5                	mov    %esp,%ebp
  800a00:	57                   	push   %edi
  800a01:	56                   	push   %esi
  800a02:	53                   	push   %ebx
  800a03:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a06:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a09:	85 c9                	test   %ecx,%ecx
  800a0b:	74 36                	je     800a43 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a0d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a13:	75 28                	jne    800a3d <memset+0x40>
  800a15:	f6 c1 03             	test   $0x3,%cl
  800a18:	75 23                	jne    800a3d <memset+0x40>
		c &= 0xFF;
  800a1a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a1e:	89 d3                	mov    %edx,%ebx
  800a20:	c1 e3 08             	shl    $0x8,%ebx
  800a23:	89 d6                	mov    %edx,%esi
  800a25:	c1 e6 18             	shl    $0x18,%esi
  800a28:	89 d0                	mov    %edx,%eax
  800a2a:	c1 e0 10             	shl    $0x10,%eax
  800a2d:	09 f0                	or     %esi,%eax
  800a2f:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a31:	89 d8                	mov    %ebx,%eax
  800a33:	09 d0                	or     %edx,%eax
  800a35:	c1 e9 02             	shr    $0x2,%ecx
  800a38:	fc                   	cld    
  800a39:	f3 ab                	rep stos %eax,%es:(%edi)
  800a3b:	eb 06                	jmp    800a43 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a3d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a40:	fc                   	cld    
  800a41:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a43:	89 f8                	mov    %edi,%eax
  800a45:	5b                   	pop    %ebx
  800a46:	5e                   	pop    %esi
  800a47:	5f                   	pop    %edi
  800a48:	5d                   	pop    %ebp
  800a49:	c3                   	ret    

00800a4a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a4a:	55                   	push   %ebp
  800a4b:	89 e5                	mov    %esp,%ebp
  800a4d:	57                   	push   %edi
  800a4e:	56                   	push   %esi
  800a4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a52:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a55:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a58:	39 c6                	cmp    %eax,%esi
  800a5a:	73 35                	jae    800a91 <memmove+0x47>
  800a5c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a5f:	39 d0                	cmp    %edx,%eax
  800a61:	73 2e                	jae    800a91 <memmove+0x47>
		s += n;
		d += n;
  800a63:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a66:	89 d6                	mov    %edx,%esi
  800a68:	09 fe                	or     %edi,%esi
  800a6a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a70:	75 13                	jne    800a85 <memmove+0x3b>
  800a72:	f6 c1 03             	test   $0x3,%cl
  800a75:	75 0e                	jne    800a85 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a77:	83 ef 04             	sub    $0x4,%edi
  800a7a:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a7d:	c1 e9 02             	shr    $0x2,%ecx
  800a80:	fd                   	std    
  800a81:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a83:	eb 09                	jmp    800a8e <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a85:	83 ef 01             	sub    $0x1,%edi
  800a88:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a8b:	fd                   	std    
  800a8c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a8e:	fc                   	cld    
  800a8f:	eb 1d                	jmp    800aae <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a91:	89 f2                	mov    %esi,%edx
  800a93:	09 c2                	or     %eax,%edx
  800a95:	f6 c2 03             	test   $0x3,%dl
  800a98:	75 0f                	jne    800aa9 <memmove+0x5f>
  800a9a:	f6 c1 03             	test   $0x3,%cl
  800a9d:	75 0a                	jne    800aa9 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a9f:	c1 e9 02             	shr    $0x2,%ecx
  800aa2:	89 c7                	mov    %eax,%edi
  800aa4:	fc                   	cld    
  800aa5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aa7:	eb 05                	jmp    800aae <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800aa9:	89 c7                	mov    %eax,%edi
  800aab:	fc                   	cld    
  800aac:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800aae:	5e                   	pop    %esi
  800aaf:	5f                   	pop    %edi
  800ab0:	5d                   	pop    %ebp
  800ab1:	c3                   	ret    

00800ab2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ab2:	55                   	push   %ebp
  800ab3:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800ab5:	ff 75 10             	pushl  0x10(%ebp)
  800ab8:	ff 75 0c             	pushl  0xc(%ebp)
  800abb:	ff 75 08             	pushl  0x8(%ebp)
  800abe:	e8 87 ff ff ff       	call   800a4a <memmove>
}
  800ac3:	c9                   	leave  
  800ac4:	c3                   	ret    

00800ac5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ac5:	55                   	push   %ebp
  800ac6:	89 e5                	mov    %esp,%ebp
  800ac8:	56                   	push   %esi
  800ac9:	53                   	push   %ebx
  800aca:	8b 45 08             	mov    0x8(%ebp),%eax
  800acd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ad0:	89 c6                	mov    %eax,%esi
  800ad2:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ad5:	eb 1a                	jmp    800af1 <memcmp+0x2c>
		if (*s1 != *s2)
  800ad7:	0f b6 08             	movzbl (%eax),%ecx
  800ada:	0f b6 1a             	movzbl (%edx),%ebx
  800add:	38 d9                	cmp    %bl,%cl
  800adf:	74 0a                	je     800aeb <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800ae1:	0f b6 c1             	movzbl %cl,%eax
  800ae4:	0f b6 db             	movzbl %bl,%ebx
  800ae7:	29 d8                	sub    %ebx,%eax
  800ae9:	eb 0f                	jmp    800afa <memcmp+0x35>
		s1++, s2++;
  800aeb:	83 c0 01             	add    $0x1,%eax
  800aee:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800af1:	39 f0                	cmp    %esi,%eax
  800af3:	75 e2                	jne    800ad7 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800af5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800afa:	5b                   	pop    %ebx
  800afb:	5e                   	pop    %esi
  800afc:	5d                   	pop    %ebp
  800afd:	c3                   	ret    

00800afe <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800afe:	55                   	push   %ebp
  800aff:	89 e5                	mov    %esp,%ebp
  800b01:	53                   	push   %ebx
  800b02:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b05:	89 c1                	mov    %eax,%ecx
  800b07:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800b0a:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b0e:	eb 0a                	jmp    800b1a <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b10:	0f b6 10             	movzbl (%eax),%edx
  800b13:	39 da                	cmp    %ebx,%edx
  800b15:	74 07                	je     800b1e <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b17:	83 c0 01             	add    $0x1,%eax
  800b1a:	39 c8                	cmp    %ecx,%eax
  800b1c:	72 f2                	jb     800b10 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b1e:	5b                   	pop    %ebx
  800b1f:	5d                   	pop    %ebp
  800b20:	c3                   	ret    

00800b21 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b21:	55                   	push   %ebp
  800b22:	89 e5                	mov    %esp,%ebp
  800b24:	57                   	push   %edi
  800b25:	56                   	push   %esi
  800b26:	53                   	push   %ebx
  800b27:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b2a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b2d:	eb 03                	jmp    800b32 <strtol+0x11>
		s++;
  800b2f:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b32:	0f b6 01             	movzbl (%ecx),%eax
  800b35:	3c 20                	cmp    $0x20,%al
  800b37:	74 f6                	je     800b2f <strtol+0xe>
  800b39:	3c 09                	cmp    $0x9,%al
  800b3b:	74 f2                	je     800b2f <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b3d:	3c 2b                	cmp    $0x2b,%al
  800b3f:	75 0a                	jne    800b4b <strtol+0x2a>
		s++;
  800b41:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b44:	bf 00 00 00 00       	mov    $0x0,%edi
  800b49:	eb 11                	jmp    800b5c <strtol+0x3b>
  800b4b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b50:	3c 2d                	cmp    $0x2d,%al
  800b52:	75 08                	jne    800b5c <strtol+0x3b>
		s++, neg = 1;
  800b54:	83 c1 01             	add    $0x1,%ecx
  800b57:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b5c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b62:	75 15                	jne    800b79 <strtol+0x58>
  800b64:	80 39 30             	cmpb   $0x30,(%ecx)
  800b67:	75 10                	jne    800b79 <strtol+0x58>
  800b69:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b6d:	75 7c                	jne    800beb <strtol+0xca>
		s += 2, base = 16;
  800b6f:	83 c1 02             	add    $0x2,%ecx
  800b72:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b77:	eb 16                	jmp    800b8f <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b79:	85 db                	test   %ebx,%ebx
  800b7b:	75 12                	jne    800b8f <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b7d:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b82:	80 39 30             	cmpb   $0x30,(%ecx)
  800b85:	75 08                	jne    800b8f <strtol+0x6e>
		s++, base = 8;
  800b87:	83 c1 01             	add    $0x1,%ecx
  800b8a:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b8f:	b8 00 00 00 00       	mov    $0x0,%eax
  800b94:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b97:	0f b6 11             	movzbl (%ecx),%edx
  800b9a:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b9d:	89 f3                	mov    %esi,%ebx
  800b9f:	80 fb 09             	cmp    $0x9,%bl
  800ba2:	77 08                	ja     800bac <strtol+0x8b>
			dig = *s - '0';
  800ba4:	0f be d2             	movsbl %dl,%edx
  800ba7:	83 ea 30             	sub    $0x30,%edx
  800baa:	eb 22                	jmp    800bce <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800bac:	8d 72 9f             	lea    -0x61(%edx),%esi
  800baf:	89 f3                	mov    %esi,%ebx
  800bb1:	80 fb 19             	cmp    $0x19,%bl
  800bb4:	77 08                	ja     800bbe <strtol+0x9d>
			dig = *s - 'a' + 10;
  800bb6:	0f be d2             	movsbl %dl,%edx
  800bb9:	83 ea 57             	sub    $0x57,%edx
  800bbc:	eb 10                	jmp    800bce <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800bbe:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bc1:	89 f3                	mov    %esi,%ebx
  800bc3:	80 fb 19             	cmp    $0x19,%bl
  800bc6:	77 16                	ja     800bde <strtol+0xbd>
			dig = *s - 'A' + 10;
  800bc8:	0f be d2             	movsbl %dl,%edx
  800bcb:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800bce:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bd1:	7d 0b                	jge    800bde <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800bd3:	83 c1 01             	add    $0x1,%ecx
  800bd6:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bda:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800bdc:	eb b9                	jmp    800b97 <strtol+0x76>

	if (endptr)
  800bde:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800be2:	74 0d                	je     800bf1 <strtol+0xd0>
		*endptr = (char *) s;
  800be4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800be7:	89 0e                	mov    %ecx,(%esi)
  800be9:	eb 06                	jmp    800bf1 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800beb:	85 db                	test   %ebx,%ebx
  800bed:	74 98                	je     800b87 <strtol+0x66>
  800bef:	eb 9e                	jmp    800b8f <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800bf1:	89 c2                	mov    %eax,%edx
  800bf3:	f7 da                	neg    %edx
  800bf5:	85 ff                	test   %edi,%edi
  800bf7:	0f 45 c2             	cmovne %edx,%eax
}
  800bfa:	5b                   	pop    %ebx
  800bfb:	5e                   	pop    %esi
  800bfc:	5f                   	pop    %edi
  800bfd:	5d                   	pop    %ebp
  800bfe:	c3                   	ret    

00800bff <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bff:	55                   	push   %ebp
  800c00:	89 e5                	mov    %esp,%ebp
  800c02:	57                   	push   %edi
  800c03:	56                   	push   %esi
  800c04:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c05:	b8 00 00 00 00       	mov    $0x0,%eax
  800c0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c10:	89 c3                	mov    %eax,%ebx
  800c12:	89 c7                	mov    %eax,%edi
  800c14:	89 c6                	mov    %eax,%esi
  800c16:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c18:	5b                   	pop    %ebx
  800c19:	5e                   	pop    %esi
  800c1a:	5f                   	pop    %edi
  800c1b:	5d                   	pop    %ebp
  800c1c:	c3                   	ret    

00800c1d <sys_cgetc>:

int
sys_cgetc(void)
{
  800c1d:	55                   	push   %ebp
  800c1e:	89 e5                	mov    %esp,%ebp
  800c20:	57                   	push   %edi
  800c21:	56                   	push   %esi
  800c22:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c23:	ba 00 00 00 00       	mov    $0x0,%edx
  800c28:	b8 01 00 00 00       	mov    $0x1,%eax
  800c2d:	89 d1                	mov    %edx,%ecx
  800c2f:	89 d3                	mov    %edx,%ebx
  800c31:	89 d7                	mov    %edx,%edi
  800c33:	89 d6                	mov    %edx,%esi
  800c35:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c37:	5b                   	pop    %ebx
  800c38:	5e                   	pop    %esi
  800c39:	5f                   	pop    %edi
  800c3a:	5d                   	pop    %ebp
  800c3b:	c3                   	ret    

00800c3c <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c3c:	55                   	push   %ebp
  800c3d:	89 e5                	mov    %esp,%ebp
  800c3f:	57                   	push   %edi
  800c40:	56                   	push   %esi
  800c41:	53                   	push   %ebx
  800c42:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c45:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c4a:	b8 03 00 00 00       	mov    $0x3,%eax
  800c4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c52:	89 cb                	mov    %ecx,%ebx
  800c54:	89 cf                	mov    %ecx,%edi
  800c56:	89 ce                	mov    %ecx,%esi
  800c58:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c5a:	85 c0                	test   %eax,%eax
  800c5c:	7e 17                	jle    800c75 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5e:	83 ec 0c             	sub    $0xc,%esp
  800c61:	50                   	push   %eax
  800c62:	6a 03                	push   $0x3
  800c64:	68 9f 26 80 00       	push   $0x80269f
  800c69:	6a 23                	push   $0x23
  800c6b:	68 bc 26 80 00       	push   $0x8026bc
  800c70:	e8 01 13 00 00       	call   801f76 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c75:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c78:	5b                   	pop    %ebx
  800c79:	5e                   	pop    %esi
  800c7a:	5f                   	pop    %edi
  800c7b:	5d                   	pop    %ebp
  800c7c:	c3                   	ret    

00800c7d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c7d:	55                   	push   %ebp
  800c7e:	89 e5                	mov    %esp,%ebp
  800c80:	57                   	push   %edi
  800c81:	56                   	push   %esi
  800c82:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c83:	ba 00 00 00 00       	mov    $0x0,%edx
  800c88:	b8 02 00 00 00       	mov    $0x2,%eax
  800c8d:	89 d1                	mov    %edx,%ecx
  800c8f:	89 d3                	mov    %edx,%ebx
  800c91:	89 d7                	mov    %edx,%edi
  800c93:	89 d6                	mov    %edx,%esi
  800c95:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c97:	5b                   	pop    %ebx
  800c98:	5e                   	pop    %esi
  800c99:	5f                   	pop    %edi
  800c9a:	5d                   	pop    %ebp
  800c9b:	c3                   	ret    

00800c9c <sys_yield>:

void
sys_yield(void)
{
  800c9c:	55                   	push   %ebp
  800c9d:	89 e5                	mov    %esp,%ebp
  800c9f:	57                   	push   %edi
  800ca0:	56                   	push   %esi
  800ca1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ca7:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cac:	89 d1                	mov    %edx,%ecx
  800cae:	89 d3                	mov    %edx,%ebx
  800cb0:	89 d7                	mov    %edx,%edi
  800cb2:	89 d6                	mov    %edx,%esi
  800cb4:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cb6:	5b                   	pop    %ebx
  800cb7:	5e                   	pop    %esi
  800cb8:	5f                   	pop    %edi
  800cb9:	5d                   	pop    %ebp
  800cba:	c3                   	ret    

00800cbb <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cbb:	55                   	push   %ebp
  800cbc:	89 e5                	mov    %esp,%ebp
  800cbe:	57                   	push   %edi
  800cbf:	56                   	push   %esi
  800cc0:	53                   	push   %ebx
  800cc1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc4:	be 00 00 00 00       	mov    $0x0,%esi
  800cc9:	b8 04 00 00 00       	mov    $0x4,%eax
  800cce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd1:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cd7:	89 f7                	mov    %esi,%edi
  800cd9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cdb:	85 c0                	test   %eax,%eax
  800cdd:	7e 17                	jle    800cf6 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cdf:	83 ec 0c             	sub    $0xc,%esp
  800ce2:	50                   	push   %eax
  800ce3:	6a 04                	push   $0x4
  800ce5:	68 9f 26 80 00       	push   $0x80269f
  800cea:	6a 23                	push   $0x23
  800cec:	68 bc 26 80 00       	push   $0x8026bc
  800cf1:	e8 80 12 00 00       	call   801f76 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cf6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf9:	5b                   	pop    %ebx
  800cfa:	5e                   	pop    %esi
  800cfb:	5f                   	pop    %edi
  800cfc:	5d                   	pop    %ebp
  800cfd:	c3                   	ret    

00800cfe <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cfe:	55                   	push   %ebp
  800cff:	89 e5                	mov    %esp,%ebp
  800d01:	57                   	push   %edi
  800d02:	56                   	push   %esi
  800d03:	53                   	push   %ebx
  800d04:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d07:	b8 05 00 00 00       	mov    $0x5,%eax
  800d0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d12:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d15:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d18:	8b 75 18             	mov    0x18(%ebp),%esi
  800d1b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d1d:	85 c0                	test   %eax,%eax
  800d1f:	7e 17                	jle    800d38 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d21:	83 ec 0c             	sub    $0xc,%esp
  800d24:	50                   	push   %eax
  800d25:	6a 05                	push   $0x5
  800d27:	68 9f 26 80 00       	push   $0x80269f
  800d2c:	6a 23                	push   $0x23
  800d2e:	68 bc 26 80 00       	push   $0x8026bc
  800d33:	e8 3e 12 00 00       	call   801f76 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d38:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3b:	5b                   	pop    %ebx
  800d3c:	5e                   	pop    %esi
  800d3d:	5f                   	pop    %edi
  800d3e:	5d                   	pop    %ebp
  800d3f:	c3                   	ret    

00800d40 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d40:	55                   	push   %ebp
  800d41:	89 e5                	mov    %esp,%ebp
  800d43:	57                   	push   %edi
  800d44:	56                   	push   %esi
  800d45:	53                   	push   %ebx
  800d46:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d49:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d4e:	b8 06 00 00 00       	mov    $0x6,%eax
  800d53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d56:	8b 55 08             	mov    0x8(%ebp),%edx
  800d59:	89 df                	mov    %ebx,%edi
  800d5b:	89 de                	mov    %ebx,%esi
  800d5d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d5f:	85 c0                	test   %eax,%eax
  800d61:	7e 17                	jle    800d7a <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d63:	83 ec 0c             	sub    $0xc,%esp
  800d66:	50                   	push   %eax
  800d67:	6a 06                	push   $0x6
  800d69:	68 9f 26 80 00       	push   $0x80269f
  800d6e:	6a 23                	push   $0x23
  800d70:	68 bc 26 80 00       	push   $0x8026bc
  800d75:	e8 fc 11 00 00       	call   801f76 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d7d:	5b                   	pop    %ebx
  800d7e:	5e                   	pop    %esi
  800d7f:	5f                   	pop    %edi
  800d80:	5d                   	pop    %ebp
  800d81:	c3                   	ret    

00800d82 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d82:	55                   	push   %ebp
  800d83:	89 e5                	mov    %esp,%ebp
  800d85:	57                   	push   %edi
  800d86:	56                   	push   %esi
  800d87:	53                   	push   %ebx
  800d88:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d90:	b8 08 00 00 00       	mov    $0x8,%eax
  800d95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d98:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9b:	89 df                	mov    %ebx,%edi
  800d9d:	89 de                	mov    %ebx,%esi
  800d9f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800da1:	85 c0                	test   %eax,%eax
  800da3:	7e 17                	jle    800dbc <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da5:	83 ec 0c             	sub    $0xc,%esp
  800da8:	50                   	push   %eax
  800da9:	6a 08                	push   $0x8
  800dab:	68 9f 26 80 00       	push   $0x80269f
  800db0:	6a 23                	push   $0x23
  800db2:	68 bc 26 80 00       	push   $0x8026bc
  800db7:	e8 ba 11 00 00       	call   801f76 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dbf:	5b                   	pop    %ebx
  800dc0:	5e                   	pop    %esi
  800dc1:	5f                   	pop    %edi
  800dc2:	5d                   	pop    %ebp
  800dc3:	c3                   	ret    

00800dc4 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800dc4:	55                   	push   %ebp
  800dc5:	89 e5                	mov    %esp,%ebp
  800dc7:	57                   	push   %edi
  800dc8:	56                   	push   %esi
  800dc9:	53                   	push   %ebx
  800dca:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dcd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dd2:	b8 09 00 00 00       	mov    $0x9,%eax
  800dd7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dda:	8b 55 08             	mov    0x8(%ebp),%edx
  800ddd:	89 df                	mov    %ebx,%edi
  800ddf:	89 de                	mov    %ebx,%esi
  800de1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800de3:	85 c0                	test   %eax,%eax
  800de5:	7e 17                	jle    800dfe <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de7:	83 ec 0c             	sub    $0xc,%esp
  800dea:	50                   	push   %eax
  800deb:	6a 09                	push   $0x9
  800ded:	68 9f 26 80 00       	push   $0x80269f
  800df2:	6a 23                	push   $0x23
  800df4:	68 bc 26 80 00       	push   $0x8026bc
  800df9:	e8 78 11 00 00       	call   801f76 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800dfe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e01:	5b                   	pop    %ebx
  800e02:	5e                   	pop    %esi
  800e03:	5f                   	pop    %edi
  800e04:	5d                   	pop    %ebp
  800e05:	c3                   	ret    

00800e06 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e06:	55                   	push   %ebp
  800e07:	89 e5                	mov    %esp,%ebp
  800e09:	57                   	push   %edi
  800e0a:	56                   	push   %esi
  800e0b:	53                   	push   %ebx
  800e0c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e14:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e19:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e1c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1f:	89 df                	mov    %ebx,%edi
  800e21:	89 de                	mov    %ebx,%esi
  800e23:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e25:	85 c0                	test   %eax,%eax
  800e27:	7e 17                	jle    800e40 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e29:	83 ec 0c             	sub    $0xc,%esp
  800e2c:	50                   	push   %eax
  800e2d:	6a 0a                	push   $0xa
  800e2f:	68 9f 26 80 00       	push   $0x80269f
  800e34:	6a 23                	push   $0x23
  800e36:	68 bc 26 80 00       	push   $0x8026bc
  800e3b:	e8 36 11 00 00       	call   801f76 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e40:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e43:	5b                   	pop    %ebx
  800e44:	5e                   	pop    %esi
  800e45:	5f                   	pop    %edi
  800e46:	5d                   	pop    %ebp
  800e47:	c3                   	ret    

00800e48 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e48:	55                   	push   %ebp
  800e49:	89 e5                	mov    %esp,%ebp
  800e4b:	57                   	push   %edi
  800e4c:	56                   	push   %esi
  800e4d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e4e:	be 00 00 00 00       	mov    $0x0,%esi
  800e53:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e5b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e61:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e64:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e66:	5b                   	pop    %ebx
  800e67:	5e                   	pop    %esi
  800e68:	5f                   	pop    %edi
  800e69:	5d                   	pop    %ebp
  800e6a:	c3                   	ret    

00800e6b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e6b:	55                   	push   %ebp
  800e6c:	89 e5                	mov    %esp,%ebp
  800e6e:	57                   	push   %edi
  800e6f:	56                   	push   %esi
  800e70:	53                   	push   %ebx
  800e71:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e74:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e79:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e7e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e81:	89 cb                	mov    %ecx,%ebx
  800e83:	89 cf                	mov    %ecx,%edi
  800e85:	89 ce                	mov    %ecx,%esi
  800e87:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e89:	85 c0                	test   %eax,%eax
  800e8b:	7e 17                	jle    800ea4 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e8d:	83 ec 0c             	sub    $0xc,%esp
  800e90:	50                   	push   %eax
  800e91:	6a 0d                	push   $0xd
  800e93:	68 9f 26 80 00       	push   $0x80269f
  800e98:	6a 23                	push   $0x23
  800e9a:	68 bc 26 80 00       	push   $0x8026bc
  800e9f:	e8 d2 10 00 00       	call   801f76 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ea4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ea7:	5b                   	pop    %ebx
  800ea8:	5e                   	pop    %esi
  800ea9:	5f                   	pop    %edi
  800eaa:	5d                   	pop    %ebp
  800eab:	c3                   	ret    

00800eac <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800eac:	55                   	push   %ebp
  800ead:	89 e5                	mov    %esp,%ebp
  800eaf:	53                   	push   %ebx
  800eb0:	83 ec 04             	sub    $0x4,%esp
  800eb3:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800eb6:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & 
  800eb8:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800ebc:	0f 84 48 01 00 00    	je     80100a <pgfault+0x15e>
  800ec2:	89 d8                	mov    %ebx,%eax
  800ec4:	c1 e8 16             	shr    $0x16,%eax
  800ec7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ece:	a8 01                	test   $0x1,%al
  800ed0:	0f 84 5f 01 00 00    	je     801035 <pgfault+0x189>
  800ed6:	89 d8                	mov    %ebx,%eax
  800ed8:	c1 e8 0c             	shr    $0xc,%eax
  800edb:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ee2:	f6 c2 01             	test   $0x1,%dl
  800ee5:	0f 84 4a 01 00 00    	je     801035 <pgfault+0x189>
				PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW))) {
  800eeb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & 
  800ef2:	f6 c4 08             	test   $0x8,%ah
  800ef5:	75 79                	jne    800f70 <pgfault+0xc4>
  800ef7:	e9 39 01 00 00       	jmp    801035 <pgfault+0x189>
				PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW))) {
		cprintf("Fault address = %08x, envid = %08x\n", addr, thisenv->env_id);
		if (!(err & FEC_WR)) cprintf("Not write\n");
		if (!(uvpd[PDX(addr)] & PTE_P)) cprintf("PDE not present\n");
  800efc:	89 d8                	mov    %ebx,%eax
  800efe:	c1 e8 16             	shr    $0x16,%eax
  800f01:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f08:	a8 01                	test   $0x1,%al
  800f0a:	75 10                	jne    800f1c <pgfault+0x70>
  800f0c:	83 ec 0c             	sub    $0xc,%esp
  800f0f:	68 ca 26 80 00       	push   $0x8026ca
  800f14:	e8 73 f3 ff ff       	call   80028c <cprintf>
  800f19:	83 c4 10             	add    $0x10,%esp
		if (!(uvpt[PTX(addr)] & PTE_P)) cprintf("PTE not present\n");
  800f1c:	c1 eb 0c             	shr    $0xc,%ebx
  800f1f:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  800f25:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800f2c:	a8 01                	test   $0x1,%al
  800f2e:	75 10                	jne    800f40 <pgfault+0x94>
  800f30:	83 ec 0c             	sub    $0xc,%esp
  800f33:	68 db 26 80 00       	push   $0x8026db
  800f38:	e8 4f f3 ff ff       	call   80028c <cprintf>
  800f3d:	83 c4 10             	add    $0x10,%esp
		if (!(uvpt[PTX(addr)] & PTE_COW)) cprintf("Not copy-on-write\n");
  800f40:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800f47:	f6 c4 08             	test   $0x8,%ah
  800f4a:	75 10                	jne    800f5c <pgfault+0xb0>
  800f4c:	83 ec 0c             	sub    $0xc,%esp
  800f4f:	68 ec 26 80 00       	push   $0x8026ec
  800f54:	e8 33 f3 ff ff       	call   80028c <cprintf>
  800f59:	83 c4 10             	add    $0x10,%esp
		panic("User page fault");
  800f5c:	83 ec 04             	sub    $0x4,%esp
  800f5f:	68 ff 26 80 00       	push   $0x8026ff
  800f64:	6a 23                	push   $0x23
  800f66:	68 0f 27 80 00       	push   $0x80270f
  800f6b:	e8 06 10 00 00       	call   801f76 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// 0 refers to curenv
	if ((r = sys_page_alloc(0, (void*)PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  800f70:	83 ec 04             	sub    $0x4,%esp
  800f73:	6a 07                	push   $0x7
  800f75:	68 00 f0 7f 00       	push   $0x7ff000
  800f7a:	6a 00                	push   $0x0
  800f7c:	e8 3a fd ff ff       	call   800cbb <sys_page_alloc>
  800f81:	83 c4 10             	add    $0x10,%esp
  800f84:	85 c0                	test   %eax,%eax
  800f86:	79 12                	jns    800f9a <pgfault+0xee>
		panic("sys_page_alloc failed: %e", r);
  800f88:	50                   	push   %eax
  800f89:	68 1a 27 80 00       	push   $0x80271a
  800f8e:	6a 2f                	push   $0x2f
  800f90:	68 0f 27 80 00       	push   $0x80270f
  800f95:	e8 dc 0f 00 00       	call   801f76 <_panic>
	memcpy((void*)PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  800f9a:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800fa0:	83 ec 04             	sub    $0x4,%esp
  800fa3:	68 00 10 00 00       	push   $0x1000
  800fa8:	53                   	push   %ebx
  800fa9:	68 00 f0 7f 00       	push   $0x7ff000
  800fae:	e8 ff fa ff ff       	call   800ab2 <memcpy>
	if ((r = sys_page_map(0, (void*)PFTEMP, 0, (void*)ROUNDDOWN(addr, PGSIZE), 
  800fb3:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800fba:	53                   	push   %ebx
  800fbb:	6a 00                	push   $0x0
  800fbd:	68 00 f0 7f 00       	push   $0x7ff000
  800fc2:	6a 00                	push   $0x0
  800fc4:	e8 35 fd ff ff       	call   800cfe <sys_page_map>
  800fc9:	83 c4 20             	add    $0x20,%esp
  800fcc:	85 c0                	test   %eax,%eax
  800fce:	79 12                	jns    800fe2 <pgfault+0x136>
					PTE_P | PTE_U | PTE_W)) < 0)
		panic("sys_page_map failed: %e", r);
  800fd0:	50                   	push   %eax
  800fd1:	68 34 27 80 00       	push   $0x802734
  800fd6:	6a 33                	push   $0x33
  800fd8:	68 0f 27 80 00       	push   $0x80270f
  800fdd:	e8 94 0f 00 00       	call   801f76 <_panic>
	if ((r = sys_page_unmap(0, (void*)PFTEMP)) < 0)
  800fe2:	83 ec 08             	sub    $0x8,%esp
  800fe5:	68 00 f0 7f 00       	push   $0x7ff000
  800fea:	6a 00                	push   $0x0
  800fec:	e8 4f fd ff ff       	call   800d40 <sys_page_unmap>
  800ff1:	83 c4 10             	add    $0x10,%esp
  800ff4:	85 c0                	test   %eax,%eax
  800ff6:	79 5c                	jns    801054 <pgfault+0x1a8>
		panic("sys_page_unmap failed: %e", r);
  800ff8:	50                   	push   %eax
  800ff9:	68 4c 27 80 00       	push   $0x80274c
  800ffe:	6a 35                	push   $0x35
  801000:	68 0f 27 80 00       	push   $0x80270f
  801005:	e8 6c 0f 00 00       	call   801f76 <_panic>
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & 
				PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW))) {
		cprintf("Fault address = %08x, envid = %08x\n", addr, thisenv->env_id);
  80100a:	a1 04 40 80 00       	mov    0x804004,%eax
  80100f:	8b 40 48             	mov    0x48(%eax),%eax
  801012:	83 ec 04             	sub    $0x4,%esp
  801015:	50                   	push   %eax
  801016:	53                   	push   %ebx
  801017:	68 88 27 80 00       	push   $0x802788
  80101c:	e8 6b f2 ff ff       	call   80028c <cprintf>
		if (!(err & FEC_WR)) cprintf("Not write\n");
  801021:	c7 04 24 66 27 80 00 	movl   $0x802766,(%esp)
  801028:	e8 5f f2 ff ff       	call   80028c <cprintf>
  80102d:	83 c4 10             	add    $0x10,%esp
  801030:	e9 c7 fe ff ff       	jmp    800efc <pgfault+0x50>
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & 
				PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW))) {
		cprintf("Fault address = %08x, envid = %08x\n", addr, thisenv->env_id);
  801035:	a1 04 40 80 00       	mov    0x804004,%eax
  80103a:	8b 40 48             	mov    0x48(%eax),%eax
  80103d:	83 ec 04             	sub    $0x4,%esp
  801040:	50                   	push   %eax
  801041:	53                   	push   %ebx
  801042:	68 88 27 80 00       	push   $0x802788
  801047:	e8 40 f2 ff ff       	call   80028c <cprintf>
  80104c:	83 c4 10             	add    $0x10,%esp
  80104f:	e9 a8 fe ff ff       	jmp    800efc <pgfault+0x50>
		panic("sys_page_map failed: %e", r);
	if ((r = sys_page_unmap(0, (void*)PFTEMP)) < 0)
		panic("sys_page_unmap failed: %e", r);

	// panic("pgfault not implemented");
}
  801054:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801057:	c9                   	leave  
  801058:	c3                   	ret    

00801059 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801059:	55                   	push   %ebp
  80105a:	89 e5                	mov    %esp,%ebp
  80105c:	57                   	push   %edi
  80105d:	56                   	push   %esi
  80105e:	53                   	push   %ebx
  80105f:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	int ret;
	set_pgfault_handler(pgfault);
  801062:	68 ac 0e 80 00       	push   $0x800eac
  801067:	e8 50 0f 00 00       	call   801fbc <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80106c:	b8 07 00 00 00       	mov    $0x7,%eax
  801071:	cd 30                	int    $0x30
  801073:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801076:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	envid_t envid = sys_exofork();

	if (envid < 0) return envid;
  801079:	83 c4 10             	add    $0x10,%esp
  80107c:	85 c0                	test   %eax,%eax
  80107e:	0f 88 0d 01 00 00    	js     801191 <fork+0x138>
  801084:	bb 00 00 00 00       	mov    $0x0,%ebx
  801089:	be 00 00 00 00       	mov    $0x0,%esi
	else if (envid == 0) {
  80108e:	85 c0                	test   %eax,%eax
  801090:	75 2f                	jne    8010c1 <fork+0x68>
		// Child returns
		thisenv = &envs[ENVX(sys_getenvid())];
  801092:	e8 e6 fb ff ff       	call   800c7d <sys_getenvid>
  801097:	25 ff 03 00 00       	and    $0x3ff,%eax
  80109c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80109f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010a4:	a3 04 40 80 00       	mov    %eax,0x804004
		// set_pgfault_handler(pgfault);
		return 0;
  8010a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8010ae:	e9 e1 00 00 00       	jmp    801194 <fork+0x13b>
  8010b3:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
	}
	else {
		uint32_t pn;
		for (pn = 0; pn * PGSIZE < UTOP; pn++){
			// cprintf("virtual page %08x\n", pn * PGSIZE);
			if (pn * PGSIZE == UXSTACKTOP - PGSIZE) 
  8010b9:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  8010bf:	74 77                	je     801138 <fork+0xdf>
{
	int r;

	// LAB 4: Your code here.
	int perm = PTE_P | PTE_U;
	pde_t pde = uvpd[pn / NPTENTRIES];
  8010c1:	89 f0                	mov    %esi,%eax
  8010c3:	c1 e8 0a             	shr    $0xa,%eax
  8010c6:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
	if (!(pde & PTE_P)) return 0;
  8010cd:	a8 01                	test   $0x1,%al
  8010cf:	74 0b                	je     8010dc <fork+0x83>
	pte_t pte = uvpt[pn];
  8010d1:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	if (!(pte & PTE_P)) return 0;
  8010d8:	a8 01                	test   $0x1,%al
  8010da:	75 08                	jne    8010e4 <fork+0x8b>
  8010dc:	8d 5e 01             	lea    0x1(%esi),%ebx
  8010df:	c1 e3 0c             	shl    $0xc,%ebx
  8010e2:	eb 56                	jmp    80113a <fork+0xe1>
	// cprintf("virtual page %08x\n", pn * PGSIZE);

	if ((pte & PTE_W) || (pte & PTE_COW)) perm |= PTE_COW;
  8010e4:	25 02 08 00 00       	and    $0x802,%eax
  8010e9:	83 f8 01             	cmp    $0x1,%eax
  8010ec:	19 ff                	sbb    %edi,%edi
  8010ee:	81 e7 00 f8 ff ff    	and    $0xfffff800,%edi
  8010f4:	81 c7 05 08 00 00    	add    $0x805,%edi

	if ((r = sys_page_map(thisenv->env_id, (void*)(pn * PGSIZE), envid, 
  8010fa:	a1 04 40 80 00       	mov    0x804004,%eax
  8010ff:	8b 40 48             	mov    0x48(%eax),%eax
  801102:	83 ec 0c             	sub    $0xc,%esp
  801105:	57                   	push   %edi
  801106:	53                   	push   %ebx
  801107:	ff 75 e4             	pushl  -0x1c(%ebp)
  80110a:	53                   	push   %ebx
  80110b:	50                   	push   %eax
  80110c:	e8 ed fb ff ff       	call   800cfe <sys_page_map>
  801111:	83 c4 20             	add    $0x20,%esp
  801114:	85 c0                	test   %eax,%eax
  801116:	78 7c                	js     801194 <fork+0x13b>
				(void*)(pn * PGSIZE), perm)) < 0) 
		return r;
	r = sys_page_map(envid, (void*)(pn * PGSIZE), thisenv->env_id, 
  801118:	a1 04 40 80 00       	mov    0x804004,%eax
  80111d:	8b 40 48             	mov    0x48(%eax),%eax
  801120:	83 ec 0c             	sub    $0xc,%esp
  801123:	57                   	push   %edi
  801124:	53                   	push   %ebx
  801125:	50                   	push   %eax
  801126:	53                   	push   %ebx
  801127:	ff 75 e4             	pushl  -0x1c(%ebp)
  80112a:	e8 cf fb ff ff       	call   800cfe <sys_page_map>
		uint32_t pn;
		for (pn = 0; pn * PGSIZE < UTOP; pn++){
			// cprintf("virtual page %08x\n", pn * PGSIZE);
			if (pn * PGSIZE == UXSTACKTOP - PGSIZE) 
				continue;
			if ((ret = duppage(envid, pn)) < 0)
  80112f:	83 c4 20             	add    $0x20,%esp
  801132:	85 c0                	test   %eax,%eax
  801134:	79 a6                	jns    8010dc <fork+0x83>
  801136:	eb 5c                	jmp    801194 <fork+0x13b>
  801138:	89 c3                	mov    %eax,%ebx
		// set_pgfault_handler(pgfault);
		return 0;
	}
	else {
		uint32_t pn;
		for (pn = 0; pn * PGSIZE < UTOP; pn++){
  80113a:	83 c6 01             	add    $0x1,%esi
  80113d:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
  801143:	0f 86 6a ff ff ff    	jbe    8010b3 <fork+0x5a>
				return ret;
		}
		// cprintf("Fork: duppage finished\n");

		// Should be done by parent
		if ((ret = sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P |
  801149:	83 ec 04             	sub    $0x4,%esp
  80114c:	6a 07                	push   $0x7
  80114e:	68 00 f0 bf ee       	push   $0xeebff000
  801153:	8b 7d e0             	mov    -0x20(%ebp),%edi
  801156:	57                   	push   %edi
  801157:	e8 5f fb ff ff       	call   800cbb <sys_page_alloc>
  80115c:	83 c4 10             	add    $0x10,%esp
  80115f:	85 c0                	test   %eax,%eax
  801161:	78 31                	js     801194 <fork+0x13b>
						PTE_U | PTE_W)) < 0)
			return ret;
		if ((ret = sys_env_set_pgfault_upcall(envid, 
						thisenv->env_pgfault_upcall)) < 0)
  801163:	a1 04 40 80 00       	mov    0x804004,%eax

		// Should be done by parent
		if ((ret = sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P |
						PTE_U | PTE_W)) < 0)
			return ret;
		if ((ret = sys_env_set_pgfault_upcall(envid, 
  801168:	8b 40 64             	mov    0x64(%eax),%eax
  80116b:	83 ec 08             	sub    $0x8,%esp
  80116e:	50                   	push   %eax
  80116f:	57                   	push   %edi
  801170:	e8 91 fc ff ff       	call   800e06 <sys_env_set_pgfault_upcall>
  801175:	83 c4 10             	add    $0x10,%esp
  801178:	85 c0                	test   %eax,%eax
  80117a:	78 18                	js     801194 <fork+0x13b>
						thisenv->env_pgfault_upcall)) < 0)
			return ret;

		if ((ret = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  80117c:	83 ec 08             	sub    $0x8,%esp
  80117f:	6a 02                	push   $0x2
  801181:	57                   	push   %edi
  801182:	e8 fb fb ff ff       	call   800d82 <sys_env_set_status>
  801187:	83 c4 10             	add    $0x10,%esp
			return ret;
		return envid;
  80118a:	85 c0                	test   %eax,%eax
  80118c:	0f 49 c7             	cmovns %edi,%eax
  80118f:	eb 03                	jmp    801194 <fork+0x13b>
	int ret;
	set_pgfault_handler(pgfault);

	envid_t envid = sys_exofork();

	if (envid < 0) return envid;
  801191:	8b 45 e0             	mov    -0x20(%ebp),%eax
			return ret;
		return envid;
	}

	panic("fork not implemented");
}
  801194:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801197:	5b                   	pop    %ebx
  801198:	5e                   	pop    %esi
  801199:	5f                   	pop    %edi
  80119a:	5d                   	pop    %ebp
  80119b:	c3                   	ret    

0080119c <sfork>:

// Challenge!
int
sfork(void)
{
  80119c:	55                   	push   %ebp
  80119d:	89 e5                	mov    %esp,%ebp
  80119f:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8011a2:	68 71 27 80 00       	push   $0x802771
  8011a7:	68 9f 00 00 00       	push   $0x9f
  8011ac:	68 0f 27 80 00       	push   $0x80270f
  8011b1:	e8 c0 0d 00 00       	call   801f76 <_panic>

008011b6 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8011b6:	55                   	push   %ebp
  8011b7:	89 e5                	mov    %esp,%ebp
  8011b9:	56                   	push   %esi
  8011ba:	53                   	push   %ebx
  8011bb:	8b 75 08             	mov    0x8(%ebp),%esi
  8011be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011c1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int ret;
	if (pg) ret = sys_ipc_recv(pg);
  8011c4:	85 c0                	test   %eax,%eax
  8011c6:	74 0e                	je     8011d6 <ipc_recv+0x20>
  8011c8:	83 ec 0c             	sub    $0xc,%esp
  8011cb:	50                   	push   %eax
  8011cc:	e8 9a fc ff ff       	call   800e6b <sys_ipc_recv>
  8011d1:	83 c4 10             	add    $0x10,%esp
  8011d4:	eb 10                	jmp    8011e6 <ipc_recv+0x30>
	else ret = sys_ipc_recv((void*)UTOP);
  8011d6:	83 ec 0c             	sub    $0xc,%esp
  8011d9:	68 00 00 c0 ee       	push   $0xeec00000
  8011de:	e8 88 fc ff ff       	call   800e6b <sys_ipc_recv>
  8011e3:	83 c4 10             	add    $0x10,%esp
	if (ret) {
  8011e6:	85 c0                	test   %eax,%eax
  8011e8:	74 16                	je     801200 <ipc_recv+0x4a>
		if (from_env_store) *from_env_store = 0;
  8011ea:	85 f6                	test   %esi,%esi
  8011ec:	74 06                	je     8011f4 <ipc_recv+0x3e>
  8011ee:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  8011f4:	85 db                	test   %ebx,%ebx
  8011f6:	74 2c                	je     801224 <ipc_recv+0x6e>
  8011f8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8011fe:	eb 24                	jmp    801224 <ipc_recv+0x6e>
		return ret;
	}
	if (from_env_store) *from_env_store = thisenv->env_ipc_from;
  801200:	85 f6                	test   %esi,%esi
  801202:	74 0a                	je     80120e <ipc_recv+0x58>
  801204:	a1 04 40 80 00       	mov    0x804004,%eax
  801209:	8b 40 74             	mov    0x74(%eax),%eax
  80120c:	89 06                	mov    %eax,(%esi)
	if (perm_store) *perm_store = thisenv->env_ipc_perm;
  80120e:	85 db                	test   %ebx,%ebx
  801210:	74 0a                	je     80121c <ipc_recv+0x66>
  801212:	a1 04 40 80 00       	mov    0x804004,%eax
  801217:	8b 40 78             	mov    0x78(%eax),%eax
  80121a:	89 03                	mov    %eax,(%ebx)

	// panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  80121c:	a1 04 40 80 00       	mov    0x804004,%eax
  801221:	8b 40 70             	mov    0x70(%eax),%eax
}
  801224:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801227:	5b                   	pop    %ebx
  801228:	5e                   	pop    %esi
  801229:	5d                   	pop    %ebp
  80122a:	c3                   	ret    

0080122b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80122b:	55                   	push   %ebp
  80122c:	89 e5                	mov    %esp,%ebp
  80122e:	57                   	push   %edi
  80122f:	56                   	push   %esi
  801230:	53                   	push   %ebx
  801231:	83 ec 0c             	sub    $0xc,%esp
  801234:	8b 7d 08             	mov    0x8(%ebp),%edi
  801237:	8b 75 0c             	mov    0xc(%ebp),%esi
  80123a:	8b 45 10             	mov    0x10(%ebp),%eax
  80123d:	85 c0                	test   %eax,%eax
  80123f:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801244:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	while (true) {
		void* srcva = (pg)? pg: (void*)UTOP;
		int ret = sys_ipc_try_send(to_env, val, srcva, perm);
  801247:	ff 75 14             	pushl  0x14(%ebp)
  80124a:	53                   	push   %ebx
  80124b:	56                   	push   %esi
  80124c:	57                   	push   %edi
  80124d:	e8 f6 fb ff ff       	call   800e48 <sys_ipc_try_send>
		if (ret == 0) break;
  801252:	83 c4 10             	add    $0x10,%esp
  801255:	85 c0                	test   %eax,%eax
  801257:	74 1e                	je     801277 <ipc_send+0x4c>
		if (ret != -E_IPC_NOT_RECV) panic("ipc_send: %e", ret);
  801259:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80125c:	74 12                	je     801270 <ipc_send+0x45>
  80125e:	50                   	push   %eax
  80125f:	68 ac 27 80 00       	push   $0x8027ac
  801264:	6a 39                	push   $0x39
  801266:	68 b9 27 80 00       	push   $0x8027b9
  80126b:	e8 06 0d 00 00       	call   801f76 <_panic>
		sys_yield();
  801270:	e8 27 fa ff ff       	call   800c9c <sys_yield>
	}
  801275:	eb d0                	jmp    801247 <ipc_send+0x1c>
	// panic("ipc_send not implemented");
}
  801277:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80127a:	5b                   	pop    %ebx
  80127b:	5e                   	pop    %esi
  80127c:	5f                   	pop    %edi
  80127d:	5d                   	pop    %ebp
  80127e:	c3                   	ret    

0080127f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80127f:	55                   	push   %ebp
  801280:	89 e5                	mov    %esp,%ebp
  801282:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801285:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80128a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80128d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801293:	8b 52 50             	mov    0x50(%edx),%edx
  801296:	39 ca                	cmp    %ecx,%edx
  801298:	75 0d                	jne    8012a7 <ipc_find_env+0x28>
			return envs[i].env_id;
  80129a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80129d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8012a2:	8b 40 48             	mov    0x48(%eax),%eax
  8012a5:	eb 0f                	jmp    8012b6 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8012a7:	83 c0 01             	add    $0x1,%eax
  8012aa:	3d 00 04 00 00       	cmp    $0x400,%eax
  8012af:	75 d9                	jne    80128a <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8012b1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012b6:	5d                   	pop    %ebp
  8012b7:	c3                   	ret    

008012b8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8012b8:	55                   	push   %ebp
  8012b9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8012be:	05 00 00 00 30       	add    $0x30000000,%eax
  8012c3:	c1 e8 0c             	shr    $0xc,%eax
}
  8012c6:	5d                   	pop    %ebp
  8012c7:	c3                   	ret    

008012c8 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8012c8:	55                   	push   %ebp
  8012c9:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8012cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8012ce:	05 00 00 00 30       	add    $0x30000000,%eax
  8012d3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8012d8:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8012dd:	5d                   	pop    %ebp
  8012de:	c3                   	ret    

008012df <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8012df:	55                   	push   %ebp
  8012e0:	89 e5                	mov    %esp,%ebp
  8012e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012e5:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8012ea:	89 c2                	mov    %eax,%edx
  8012ec:	c1 ea 16             	shr    $0x16,%edx
  8012ef:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012f6:	f6 c2 01             	test   $0x1,%dl
  8012f9:	74 11                	je     80130c <fd_alloc+0x2d>
  8012fb:	89 c2                	mov    %eax,%edx
  8012fd:	c1 ea 0c             	shr    $0xc,%edx
  801300:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801307:	f6 c2 01             	test   $0x1,%dl
  80130a:	75 09                	jne    801315 <fd_alloc+0x36>
			*fd_store = fd;
  80130c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80130e:	b8 00 00 00 00       	mov    $0x0,%eax
  801313:	eb 17                	jmp    80132c <fd_alloc+0x4d>
  801315:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80131a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80131f:	75 c9                	jne    8012ea <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801321:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801327:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80132c:	5d                   	pop    %ebp
  80132d:	c3                   	ret    

0080132e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80132e:	55                   	push   %ebp
  80132f:	89 e5                	mov    %esp,%ebp
  801331:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801334:	83 f8 1f             	cmp    $0x1f,%eax
  801337:	77 36                	ja     80136f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801339:	c1 e0 0c             	shl    $0xc,%eax
  80133c:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801341:	89 c2                	mov    %eax,%edx
  801343:	c1 ea 16             	shr    $0x16,%edx
  801346:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80134d:	f6 c2 01             	test   $0x1,%dl
  801350:	74 24                	je     801376 <fd_lookup+0x48>
  801352:	89 c2                	mov    %eax,%edx
  801354:	c1 ea 0c             	shr    $0xc,%edx
  801357:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80135e:	f6 c2 01             	test   $0x1,%dl
  801361:	74 1a                	je     80137d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801363:	8b 55 0c             	mov    0xc(%ebp),%edx
  801366:	89 02                	mov    %eax,(%edx)
	return 0;
  801368:	b8 00 00 00 00       	mov    $0x0,%eax
  80136d:	eb 13                	jmp    801382 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80136f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801374:	eb 0c                	jmp    801382 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801376:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80137b:	eb 05                	jmp    801382 <fd_lookup+0x54>
  80137d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801382:	5d                   	pop    %ebp
  801383:	c3                   	ret    

00801384 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801384:	55                   	push   %ebp
  801385:	89 e5                	mov    %esp,%ebp
  801387:	83 ec 08             	sub    $0x8,%esp
  80138a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80138d:	ba 40 28 80 00       	mov    $0x802840,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801392:	eb 13                	jmp    8013a7 <dev_lookup+0x23>
  801394:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801397:	39 08                	cmp    %ecx,(%eax)
  801399:	75 0c                	jne    8013a7 <dev_lookup+0x23>
			*dev = devtab[i];
  80139b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80139e:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8013a5:	eb 2e                	jmp    8013d5 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8013a7:	8b 02                	mov    (%edx),%eax
  8013a9:	85 c0                	test   %eax,%eax
  8013ab:	75 e7                	jne    801394 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8013ad:	a1 04 40 80 00       	mov    0x804004,%eax
  8013b2:	8b 40 48             	mov    0x48(%eax),%eax
  8013b5:	83 ec 04             	sub    $0x4,%esp
  8013b8:	51                   	push   %ecx
  8013b9:	50                   	push   %eax
  8013ba:	68 c4 27 80 00       	push   $0x8027c4
  8013bf:	e8 c8 ee ff ff       	call   80028c <cprintf>
	*dev = 0;
  8013c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013c7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8013cd:	83 c4 10             	add    $0x10,%esp
  8013d0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013d5:	c9                   	leave  
  8013d6:	c3                   	ret    

008013d7 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8013d7:	55                   	push   %ebp
  8013d8:	89 e5                	mov    %esp,%ebp
  8013da:	56                   	push   %esi
  8013db:	53                   	push   %ebx
  8013dc:	83 ec 10             	sub    $0x10,%esp
  8013df:	8b 75 08             	mov    0x8(%ebp),%esi
  8013e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013e8:	50                   	push   %eax
  8013e9:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8013ef:	c1 e8 0c             	shr    $0xc,%eax
  8013f2:	50                   	push   %eax
  8013f3:	e8 36 ff ff ff       	call   80132e <fd_lookup>
  8013f8:	83 c4 08             	add    $0x8,%esp
  8013fb:	85 c0                	test   %eax,%eax
  8013fd:	78 05                	js     801404 <fd_close+0x2d>
	    || fd != fd2)
  8013ff:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801402:	74 0c                	je     801410 <fd_close+0x39>
		return (must_exist ? r : 0);
  801404:	84 db                	test   %bl,%bl
  801406:	ba 00 00 00 00       	mov    $0x0,%edx
  80140b:	0f 44 c2             	cmove  %edx,%eax
  80140e:	eb 41                	jmp    801451 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801410:	83 ec 08             	sub    $0x8,%esp
  801413:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801416:	50                   	push   %eax
  801417:	ff 36                	pushl  (%esi)
  801419:	e8 66 ff ff ff       	call   801384 <dev_lookup>
  80141e:	89 c3                	mov    %eax,%ebx
  801420:	83 c4 10             	add    $0x10,%esp
  801423:	85 c0                	test   %eax,%eax
  801425:	78 1a                	js     801441 <fd_close+0x6a>
		if (dev->dev_close)
  801427:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80142a:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80142d:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801432:	85 c0                	test   %eax,%eax
  801434:	74 0b                	je     801441 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801436:	83 ec 0c             	sub    $0xc,%esp
  801439:	56                   	push   %esi
  80143a:	ff d0                	call   *%eax
  80143c:	89 c3                	mov    %eax,%ebx
  80143e:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801441:	83 ec 08             	sub    $0x8,%esp
  801444:	56                   	push   %esi
  801445:	6a 00                	push   $0x0
  801447:	e8 f4 f8 ff ff       	call   800d40 <sys_page_unmap>
	return r;
  80144c:	83 c4 10             	add    $0x10,%esp
  80144f:	89 d8                	mov    %ebx,%eax
}
  801451:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801454:	5b                   	pop    %ebx
  801455:	5e                   	pop    %esi
  801456:	5d                   	pop    %ebp
  801457:	c3                   	ret    

00801458 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801458:	55                   	push   %ebp
  801459:	89 e5                	mov    %esp,%ebp
  80145b:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80145e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801461:	50                   	push   %eax
  801462:	ff 75 08             	pushl  0x8(%ebp)
  801465:	e8 c4 fe ff ff       	call   80132e <fd_lookup>
  80146a:	83 c4 08             	add    $0x8,%esp
  80146d:	85 c0                	test   %eax,%eax
  80146f:	78 10                	js     801481 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801471:	83 ec 08             	sub    $0x8,%esp
  801474:	6a 01                	push   $0x1
  801476:	ff 75 f4             	pushl  -0xc(%ebp)
  801479:	e8 59 ff ff ff       	call   8013d7 <fd_close>
  80147e:	83 c4 10             	add    $0x10,%esp
}
  801481:	c9                   	leave  
  801482:	c3                   	ret    

00801483 <close_all>:

void
close_all(void)
{
  801483:	55                   	push   %ebp
  801484:	89 e5                	mov    %esp,%ebp
  801486:	53                   	push   %ebx
  801487:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80148a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80148f:	83 ec 0c             	sub    $0xc,%esp
  801492:	53                   	push   %ebx
  801493:	e8 c0 ff ff ff       	call   801458 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801498:	83 c3 01             	add    $0x1,%ebx
  80149b:	83 c4 10             	add    $0x10,%esp
  80149e:	83 fb 20             	cmp    $0x20,%ebx
  8014a1:	75 ec                	jne    80148f <close_all+0xc>
		close(i);
}
  8014a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014a6:	c9                   	leave  
  8014a7:	c3                   	ret    

008014a8 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8014a8:	55                   	push   %ebp
  8014a9:	89 e5                	mov    %esp,%ebp
  8014ab:	57                   	push   %edi
  8014ac:	56                   	push   %esi
  8014ad:	53                   	push   %ebx
  8014ae:	83 ec 2c             	sub    $0x2c,%esp
  8014b1:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014b4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014b7:	50                   	push   %eax
  8014b8:	ff 75 08             	pushl  0x8(%ebp)
  8014bb:	e8 6e fe ff ff       	call   80132e <fd_lookup>
  8014c0:	83 c4 08             	add    $0x8,%esp
  8014c3:	85 c0                	test   %eax,%eax
  8014c5:	0f 88 c1 00 00 00    	js     80158c <dup+0xe4>
		return r;
	close(newfdnum);
  8014cb:	83 ec 0c             	sub    $0xc,%esp
  8014ce:	56                   	push   %esi
  8014cf:	e8 84 ff ff ff       	call   801458 <close>

	newfd = INDEX2FD(newfdnum);
  8014d4:	89 f3                	mov    %esi,%ebx
  8014d6:	c1 e3 0c             	shl    $0xc,%ebx
  8014d9:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8014df:	83 c4 04             	add    $0x4,%esp
  8014e2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014e5:	e8 de fd ff ff       	call   8012c8 <fd2data>
  8014ea:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8014ec:	89 1c 24             	mov    %ebx,(%esp)
  8014ef:	e8 d4 fd ff ff       	call   8012c8 <fd2data>
  8014f4:	83 c4 10             	add    $0x10,%esp
  8014f7:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014fa:	89 f8                	mov    %edi,%eax
  8014fc:	c1 e8 16             	shr    $0x16,%eax
  8014ff:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801506:	a8 01                	test   $0x1,%al
  801508:	74 37                	je     801541 <dup+0x99>
  80150a:	89 f8                	mov    %edi,%eax
  80150c:	c1 e8 0c             	shr    $0xc,%eax
  80150f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801516:	f6 c2 01             	test   $0x1,%dl
  801519:	74 26                	je     801541 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80151b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801522:	83 ec 0c             	sub    $0xc,%esp
  801525:	25 07 0e 00 00       	and    $0xe07,%eax
  80152a:	50                   	push   %eax
  80152b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80152e:	6a 00                	push   $0x0
  801530:	57                   	push   %edi
  801531:	6a 00                	push   $0x0
  801533:	e8 c6 f7 ff ff       	call   800cfe <sys_page_map>
  801538:	89 c7                	mov    %eax,%edi
  80153a:	83 c4 20             	add    $0x20,%esp
  80153d:	85 c0                	test   %eax,%eax
  80153f:	78 2e                	js     80156f <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801541:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801544:	89 d0                	mov    %edx,%eax
  801546:	c1 e8 0c             	shr    $0xc,%eax
  801549:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801550:	83 ec 0c             	sub    $0xc,%esp
  801553:	25 07 0e 00 00       	and    $0xe07,%eax
  801558:	50                   	push   %eax
  801559:	53                   	push   %ebx
  80155a:	6a 00                	push   $0x0
  80155c:	52                   	push   %edx
  80155d:	6a 00                	push   $0x0
  80155f:	e8 9a f7 ff ff       	call   800cfe <sys_page_map>
  801564:	89 c7                	mov    %eax,%edi
  801566:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801569:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80156b:	85 ff                	test   %edi,%edi
  80156d:	79 1d                	jns    80158c <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80156f:	83 ec 08             	sub    $0x8,%esp
  801572:	53                   	push   %ebx
  801573:	6a 00                	push   $0x0
  801575:	e8 c6 f7 ff ff       	call   800d40 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80157a:	83 c4 08             	add    $0x8,%esp
  80157d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801580:	6a 00                	push   $0x0
  801582:	e8 b9 f7 ff ff       	call   800d40 <sys_page_unmap>
	return r;
  801587:	83 c4 10             	add    $0x10,%esp
  80158a:	89 f8                	mov    %edi,%eax
}
  80158c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80158f:	5b                   	pop    %ebx
  801590:	5e                   	pop    %esi
  801591:	5f                   	pop    %edi
  801592:	5d                   	pop    %ebp
  801593:	c3                   	ret    

00801594 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801594:	55                   	push   %ebp
  801595:	89 e5                	mov    %esp,%ebp
  801597:	53                   	push   %ebx
  801598:	83 ec 14             	sub    $0x14,%esp
  80159b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80159e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015a1:	50                   	push   %eax
  8015a2:	53                   	push   %ebx
  8015a3:	e8 86 fd ff ff       	call   80132e <fd_lookup>
  8015a8:	83 c4 08             	add    $0x8,%esp
  8015ab:	89 c2                	mov    %eax,%edx
  8015ad:	85 c0                	test   %eax,%eax
  8015af:	78 6d                	js     80161e <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015b1:	83 ec 08             	sub    $0x8,%esp
  8015b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015b7:	50                   	push   %eax
  8015b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015bb:	ff 30                	pushl  (%eax)
  8015bd:	e8 c2 fd ff ff       	call   801384 <dev_lookup>
  8015c2:	83 c4 10             	add    $0x10,%esp
  8015c5:	85 c0                	test   %eax,%eax
  8015c7:	78 4c                	js     801615 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8015c9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015cc:	8b 42 08             	mov    0x8(%edx),%eax
  8015cf:	83 e0 03             	and    $0x3,%eax
  8015d2:	83 f8 01             	cmp    $0x1,%eax
  8015d5:	75 21                	jne    8015f8 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015d7:	a1 04 40 80 00       	mov    0x804004,%eax
  8015dc:	8b 40 48             	mov    0x48(%eax),%eax
  8015df:	83 ec 04             	sub    $0x4,%esp
  8015e2:	53                   	push   %ebx
  8015e3:	50                   	push   %eax
  8015e4:	68 05 28 80 00       	push   $0x802805
  8015e9:	e8 9e ec ff ff       	call   80028c <cprintf>
		return -E_INVAL;
  8015ee:	83 c4 10             	add    $0x10,%esp
  8015f1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015f6:	eb 26                	jmp    80161e <read+0x8a>
	}
	if (!dev->dev_read)
  8015f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015fb:	8b 40 08             	mov    0x8(%eax),%eax
  8015fe:	85 c0                	test   %eax,%eax
  801600:	74 17                	je     801619 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801602:	83 ec 04             	sub    $0x4,%esp
  801605:	ff 75 10             	pushl  0x10(%ebp)
  801608:	ff 75 0c             	pushl  0xc(%ebp)
  80160b:	52                   	push   %edx
  80160c:	ff d0                	call   *%eax
  80160e:	89 c2                	mov    %eax,%edx
  801610:	83 c4 10             	add    $0x10,%esp
  801613:	eb 09                	jmp    80161e <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801615:	89 c2                	mov    %eax,%edx
  801617:	eb 05                	jmp    80161e <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801619:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80161e:	89 d0                	mov    %edx,%eax
  801620:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801623:	c9                   	leave  
  801624:	c3                   	ret    

00801625 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801625:	55                   	push   %ebp
  801626:	89 e5                	mov    %esp,%ebp
  801628:	57                   	push   %edi
  801629:	56                   	push   %esi
  80162a:	53                   	push   %ebx
  80162b:	83 ec 0c             	sub    $0xc,%esp
  80162e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801631:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801634:	bb 00 00 00 00       	mov    $0x0,%ebx
  801639:	eb 21                	jmp    80165c <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80163b:	83 ec 04             	sub    $0x4,%esp
  80163e:	89 f0                	mov    %esi,%eax
  801640:	29 d8                	sub    %ebx,%eax
  801642:	50                   	push   %eax
  801643:	89 d8                	mov    %ebx,%eax
  801645:	03 45 0c             	add    0xc(%ebp),%eax
  801648:	50                   	push   %eax
  801649:	57                   	push   %edi
  80164a:	e8 45 ff ff ff       	call   801594 <read>
		if (m < 0)
  80164f:	83 c4 10             	add    $0x10,%esp
  801652:	85 c0                	test   %eax,%eax
  801654:	78 10                	js     801666 <readn+0x41>
			return m;
		if (m == 0)
  801656:	85 c0                	test   %eax,%eax
  801658:	74 0a                	je     801664 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80165a:	01 c3                	add    %eax,%ebx
  80165c:	39 f3                	cmp    %esi,%ebx
  80165e:	72 db                	jb     80163b <readn+0x16>
  801660:	89 d8                	mov    %ebx,%eax
  801662:	eb 02                	jmp    801666 <readn+0x41>
  801664:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801666:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801669:	5b                   	pop    %ebx
  80166a:	5e                   	pop    %esi
  80166b:	5f                   	pop    %edi
  80166c:	5d                   	pop    %ebp
  80166d:	c3                   	ret    

0080166e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80166e:	55                   	push   %ebp
  80166f:	89 e5                	mov    %esp,%ebp
  801671:	53                   	push   %ebx
  801672:	83 ec 14             	sub    $0x14,%esp
  801675:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801678:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80167b:	50                   	push   %eax
  80167c:	53                   	push   %ebx
  80167d:	e8 ac fc ff ff       	call   80132e <fd_lookup>
  801682:	83 c4 08             	add    $0x8,%esp
  801685:	89 c2                	mov    %eax,%edx
  801687:	85 c0                	test   %eax,%eax
  801689:	78 68                	js     8016f3 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80168b:	83 ec 08             	sub    $0x8,%esp
  80168e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801691:	50                   	push   %eax
  801692:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801695:	ff 30                	pushl  (%eax)
  801697:	e8 e8 fc ff ff       	call   801384 <dev_lookup>
  80169c:	83 c4 10             	add    $0x10,%esp
  80169f:	85 c0                	test   %eax,%eax
  8016a1:	78 47                	js     8016ea <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016a6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016aa:	75 21                	jne    8016cd <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8016ac:	a1 04 40 80 00       	mov    0x804004,%eax
  8016b1:	8b 40 48             	mov    0x48(%eax),%eax
  8016b4:	83 ec 04             	sub    $0x4,%esp
  8016b7:	53                   	push   %ebx
  8016b8:	50                   	push   %eax
  8016b9:	68 21 28 80 00       	push   $0x802821
  8016be:	e8 c9 eb ff ff       	call   80028c <cprintf>
		return -E_INVAL;
  8016c3:	83 c4 10             	add    $0x10,%esp
  8016c6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016cb:	eb 26                	jmp    8016f3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8016cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016d0:	8b 52 0c             	mov    0xc(%edx),%edx
  8016d3:	85 d2                	test   %edx,%edx
  8016d5:	74 17                	je     8016ee <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8016d7:	83 ec 04             	sub    $0x4,%esp
  8016da:	ff 75 10             	pushl  0x10(%ebp)
  8016dd:	ff 75 0c             	pushl  0xc(%ebp)
  8016e0:	50                   	push   %eax
  8016e1:	ff d2                	call   *%edx
  8016e3:	89 c2                	mov    %eax,%edx
  8016e5:	83 c4 10             	add    $0x10,%esp
  8016e8:	eb 09                	jmp    8016f3 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016ea:	89 c2                	mov    %eax,%edx
  8016ec:	eb 05                	jmp    8016f3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8016ee:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8016f3:	89 d0                	mov    %edx,%eax
  8016f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016f8:	c9                   	leave  
  8016f9:	c3                   	ret    

008016fa <seek>:

int
seek(int fdnum, off_t offset)
{
  8016fa:	55                   	push   %ebp
  8016fb:	89 e5                	mov    %esp,%ebp
  8016fd:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801700:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801703:	50                   	push   %eax
  801704:	ff 75 08             	pushl  0x8(%ebp)
  801707:	e8 22 fc ff ff       	call   80132e <fd_lookup>
  80170c:	83 c4 08             	add    $0x8,%esp
  80170f:	85 c0                	test   %eax,%eax
  801711:	78 0e                	js     801721 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801713:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801716:	8b 55 0c             	mov    0xc(%ebp),%edx
  801719:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80171c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801721:	c9                   	leave  
  801722:	c3                   	ret    

00801723 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801723:	55                   	push   %ebp
  801724:	89 e5                	mov    %esp,%ebp
  801726:	53                   	push   %ebx
  801727:	83 ec 14             	sub    $0x14,%esp
  80172a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80172d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801730:	50                   	push   %eax
  801731:	53                   	push   %ebx
  801732:	e8 f7 fb ff ff       	call   80132e <fd_lookup>
  801737:	83 c4 08             	add    $0x8,%esp
  80173a:	89 c2                	mov    %eax,%edx
  80173c:	85 c0                	test   %eax,%eax
  80173e:	78 65                	js     8017a5 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801740:	83 ec 08             	sub    $0x8,%esp
  801743:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801746:	50                   	push   %eax
  801747:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80174a:	ff 30                	pushl  (%eax)
  80174c:	e8 33 fc ff ff       	call   801384 <dev_lookup>
  801751:	83 c4 10             	add    $0x10,%esp
  801754:	85 c0                	test   %eax,%eax
  801756:	78 44                	js     80179c <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801758:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80175b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80175f:	75 21                	jne    801782 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801761:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801766:	8b 40 48             	mov    0x48(%eax),%eax
  801769:	83 ec 04             	sub    $0x4,%esp
  80176c:	53                   	push   %ebx
  80176d:	50                   	push   %eax
  80176e:	68 e4 27 80 00       	push   $0x8027e4
  801773:	e8 14 eb ff ff       	call   80028c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801778:	83 c4 10             	add    $0x10,%esp
  80177b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801780:	eb 23                	jmp    8017a5 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801782:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801785:	8b 52 18             	mov    0x18(%edx),%edx
  801788:	85 d2                	test   %edx,%edx
  80178a:	74 14                	je     8017a0 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80178c:	83 ec 08             	sub    $0x8,%esp
  80178f:	ff 75 0c             	pushl  0xc(%ebp)
  801792:	50                   	push   %eax
  801793:	ff d2                	call   *%edx
  801795:	89 c2                	mov    %eax,%edx
  801797:	83 c4 10             	add    $0x10,%esp
  80179a:	eb 09                	jmp    8017a5 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80179c:	89 c2                	mov    %eax,%edx
  80179e:	eb 05                	jmp    8017a5 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8017a0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8017a5:	89 d0                	mov    %edx,%eax
  8017a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017aa:	c9                   	leave  
  8017ab:	c3                   	ret    

008017ac <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8017ac:	55                   	push   %ebp
  8017ad:	89 e5                	mov    %esp,%ebp
  8017af:	53                   	push   %ebx
  8017b0:	83 ec 14             	sub    $0x14,%esp
  8017b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017b6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017b9:	50                   	push   %eax
  8017ba:	ff 75 08             	pushl  0x8(%ebp)
  8017bd:	e8 6c fb ff ff       	call   80132e <fd_lookup>
  8017c2:	83 c4 08             	add    $0x8,%esp
  8017c5:	89 c2                	mov    %eax,%edx
  8017c7:	85 c0                	test   %eax,%eax
  8017c9:	78 58                	js     801823 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017cb:	83 ec 08             	sub    $0x8,%esp
  8017ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017d1:	50                   	push   %eax
  8017d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017d5:	ff 30                	pushl  (%eax)
  8017d7:	e8 a8 fb ff ff       	call   801384 <dev_lookup>
  8017dc:	83 c4 10             	add    $0x10,%esp
  8017df:	85 c0                	test   %eax,%eax
  8017e1:	78 37                	js     80181a <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8017e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017e6:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8017ea:	74 32                	je     80181e <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8017ec:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8017ef:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017f6:	00 00 00 
	stat->st_isdir = 0;
  8017f9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801800:	00 00 00 
	stat->st_dev = dev;
  801803:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801809:	83 ec 08             	sub    $0x8,%esp
  80180c:	53                   	push   %ebx
  80180d:	ff 75 f0             	pushl  -0x10(%ebp)
  801810:	ff 50 14             	call   *0x14(%eax)
  801813:	89 c2                	mov    %eax,%edx
  801815:	83 c4 10             	add    $0x10,%esp
  801818:	eb 09                	jmp    801823 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80181a:	89 c2                	mov    %eax,%edx
  80181c:	eb 05                	jmp    801823 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80181e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801823:	89 d0                	mov    %edx,%eax
  801825:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801828:	c9                   	leave  
  801829:	c3                   	ret    

0080182a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80182a:	55                   	push   %ebp
  80182b:	89 e5                	mov    %esp,%ebp
  80182d:	56                   	push   %esi
  80182e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80182f:	83 ec 08             	sub    $0x8,%esp
  801832:	6a 00                	push   $0x0
  801834:	ff 75 08             	pushl  0x8(%ebp)
  801837:	e8 b7 01 00 00       	call   8019f3 <open>
  80183c:	89 c3                	mov    %eax,%ebx
  80183e:	83 c4 10             	add    $0x10,%esp
  801841:	85 c0                	test   %eax,%eax
  801843:	78 1b                	js     801860 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801845:	83 ec 08             	sub    $0x8,%esp
  801848:	ff 75 0c             	pushl  0xc(%ebp)
  80184b:	50                   	push   %eax
  80184c:	e8 5b ff ff ff       	call   8017ac <fstat>
  801851:	89 c6                	mov    %eax,%esi
	close(fd);
  801853:	89 1c 24             	mov    %ebx,(%esp)
  801856:	e8 fd fb ff ff       	call   801458 <close>
	return r;
  80185b:	83 c4 10             	add    $0x10,%esp
  80185e:	89 f0                	mov    %esi,%eax
}
  801860:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801863:	5b                   	pop    %ebx
  801864:	5e                   	pop    %esi
  801865:	5d                   	pop    %ebp
  801866:	c3                   	ret    

00801867 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801867:	55                   	push   %ebp
  801868:	89 e5                	mov    %esp,%ebp
  80186a:	56                   	push   %esi
  80186b:	53                   	push   %ebx
  80186c:	89 c6                	mov    %eax,%esi
  80186e:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801870:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801877:	75 12                	jne    80188b <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801879:	83 ec 0c             	sub    $0xc,%esp
  80187c:	6a 01                	push   $0x1
  80187e:	e8 fc f9 ff ff       	call   80127f <ipc_find_env>
  801883:	a3 00 40 80 00       	mov    %eax,0x804000
  801888:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80188b:	6a 07                	push   $0x7
  80188d:	68 00 50 80 00       	push   $0x805000
  801892:	56                   	push   %esi
  801893:	ff 35 00 40 80 00    	pushl  0x804000
  801899:	e8 8d f9 ff ff       	call   80122b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80189e:	83 c4 0c             	add    $0xc,%esp
  8018a1:	6a 00                	push   $0x0
  8018a3:	53                   	push   %ebx
  8018a4:	6a 00                	push   $0x0
  8018a6:	e8 0b f9 ff ff       	call   8011b6 <ipc_recv>
}
  8018ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018ae:	5b                   	pop    %ebx
  8018af:	5e                   	pop    %esi
  8018b0:	5d                   	pop    %ebp
  8018b1:	c3                   	ret    

008018b2 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8018b2:	55                   	push   %ebp
  8018b3:	89 e5                	mov    %esp,%ebp
  8018b5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8018b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8018bb:	8b 40 0c             	mov    0xc(%eax),%eax
  8018be:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8018c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018c6:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8018cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8018d0:	b8 02 00 00 00       	mov    $0x2,%eax
  8018d5:	e8 8d ff ff ff       	call   801867 <fsipc>
}
  8018da:	c9                   	leave  
  8018db:	c3                   	ret    

008018dc <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8018dc:	55                   	push   %ebp
  8018dd:	89 e5                	mov    %esp,%ebp
  8018df:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e5:	8b 40 0c             	mov    0xc(%eax),%eax
  8018e8:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8018ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8018f2:	b8 06 00 00 00       	mov    $0x6,%eax
  8018f7:	e8 6b ff ff ff       	call   801867 <fsipc>
}
  8018fc:	c9                   	leave  
  8018fd:	c3                   	ret    

008018fe <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8018fe:	55                   	push   %ebp
  8018ff:	89 e5                	mov    %esp,%ebp
  801901:	53                   	push   %ebx
  801902:	83 ec 04             	sub    $0x4,%esp
  801905:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801908:	8b 45 08             	mov    0x8(%ebp),%eax
  80190b:	8b 40 0c             	mov    0xc(%eax),%eax
  80190e:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801913:	ba 00 00 00 00       	mov    $0x0,%edx
  801918:	b8 05 00 00 00       	mov    $0x5,%eax
  80191d:	e8 45 ff ff ff       	call   801867 <fsipc>
  801922:	85 c0                	test   %eax,%eax
  801924:	78 2c                	js     801952 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801926:	83 ec 08             	sub    $0x8,%esp
  801929:	68 00 50 80 00       	push   $0x805000
  80192e:	53                   	push   %ebx
  80192f:	e8 84 ef ff ff       	call   8008b8 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801934:	a1 80 50 80 00       	mov    0x805080,%eax
  801939:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80193f:	a1 84 50 80 00       	mov    0x805084,%eax
  801944:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80194a:	83 c4 10             	add    $0x10,%esp
  80194d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801952:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801955:	c9                   	leave  
  801956:	c3                   	ret    

00801957 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801957:	55                   	push   %ebp
  801958:	89 e5                	mov    %esp,%ebp
  80195a:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  80195d:	68 50 28 80 00       	push   $0x802850
  801962:	68 90 00 00 00       	push   $0x90
  801967:	68 6e 28 80 00       	push   $0x80286e
  80196c:	e8 05 06 00 00       	call   801f76 <_panic>

00801971 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801971:	55                   	push   %ebp
  801972:	89 e5                	mov    %esp,%ebp
  801974:	56                   	push   %esi
  801975:	53                   	push   %ebx
  801976:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801979:	8b 45 08             	mov    0x8(%ebp),%eax
  80197c:	8b 40 0c             	mov    0xc(%eax),%eax
  80197f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801984:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80198a:	ba 00 00 00 00       	mov    $0x0,%edx
  80198f:	b8 03 00 00 00       	mov    $0x3,%eax
  801994:	e8 ce fe ff ff       	call   801867 <fsipc>
  801999:	89 c3                	mov    %eax,%ebx
  80199b:	85 c0                	test   %eax,%eax
  80199d:	78 4b                	js     8019ea <devfile_read+0x79>
		return r;
	assert(r <= n);
  80199f:	39 c6                	cmp    %eax,%esi
  8019a1:	73 16                	jae    8019b9 <devfile_read+0x48>
  8019a3:	68 79 28 80 00       	push   $0x802879
  8019a8:	68 80 28 80 00       	push   $0x802880
  8019ad:	6a 7c                	push   $0x7c
  8019af:	68 6e 28 80 00       	push   $0x80286e
  8019b4:	e8 bd 05 00 00       	call   801f76 <_panic>
	assert(r <= PGSIZE);
  8019b9:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8019be:	7e 16                	jle    8019d6 <devfile_read+0x65>
  8019c0:	68 95 28 80 00       	push   $0x802895
  8019c5:	68 80 28 80 00       	push   $0x802880
  8019ca:	6a 7d                	push   $0x7d
  8019cc:	68 6e 28 80 00       	push   $0x80286e
  8019d1:	e8 a0 05 00 00       	call   801f76 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8019d6:	83 ec 04             	sub    $0x4,%esp
  8019d9:	50                   	push   %eax
  8019da:	68 00 50 80 00       	push   $0x805000
  8019df:	ff 75 0c             	pushl  0xc(%ebp)
  8019e2:	e8 63 f0 ff ff       	call   800a4a <memmove>
	return r;
  8019e7:	83 c4 10             	add    $0x10,%esp
}
  8019ea:	89 d8                	mov    %ebx,%eax
  8019ec:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019ef:	5b                   	pop    %ebx
  8019f0:	5e                   	pop    %esi
  8019f1:	5d                   	pop    %ebp
  8019f2:	c3                   	ret    

008019f3 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8019f3:	55                   	push   %ebp
  8019f4:	89 e5                	mov    %esp,%ebp
  8019f6:	53                   	push   %ebx
  8019f7:	83 ec 20             	sub    $0x20,%esp
  8019fa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8019fd:	53                   	push   %ebx
  8019fe:	e8 7c ee ff ff       	call   80087f <strlen>
  801a03:	83 c4 10             	add    $0x10,%esp
  801a06:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a0b:	7f 67                	jg     801a74 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a0d:	83 ec 0c             	sub    $0xc,%esp
  801a10:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a13:	50                   	push   %eax
  801a14:	e8 c6 f8 ff ff       	call   8012df <fd_alloc>
  801a19:	83 c4 10             	add    $0x10,%esp
		return r;
  801a1c:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a1e:	85 c0                	test   %eax,%eax
  801a20:	78 57                	js     801a79 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a22:	83 ec 08             	sub    $0x8,%esp
  801a25:	53                   	push   %ebx
  801a26:	68 00 50 80 00       	push   $0x805000
  801a2b:	e8 88 ee ff ff       	call   8008b8 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a30:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a33:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a38:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a3b:	b8 01 00 00 00       	mov    $0x1,%eax
  801a40:	e8 22 fe ff ff       	call   801867 <fsipc>
  801a45:	89 c3                	mov    %eax,%ebx
  801a47:	83 c4 10             	add    $0x10,%esp
  801a4a:	85 c0                	test   %eax,%eax
  801a4c:	79 14                	jns    801a62 <open+0x6f>
		fd_close(fd, 0);
  801a4e:	83 ec 08             	sub    $0x8,%esp
  801a51:	6a 00                	push   $0x0
  801a53:	ff 75 f4             	pushl  -0xc(%ebp)
  801a56:	e8 7c f9 ff ff       	call   8013d7 <fd_close>
		return r;
  801a5b:	83 c4 10             	add    $0x10,%esp
  801a5e:	89 da                	mov    %ebx,%edx
  801a60:	eb 17                	jmp    801a79 <open+0x86>
	}

	return fd2num(fd);
  801a62:	83 ec 0c             	sub    $0xc,%esp
  801a65:	ff 75 f4             	pushl  -0xc(%ebp)
  801a68:	e8 4b f8 ff ff       	call   8012b8 <fd2num>
  801a6d:	89 c2                	mov    %eax,%edx
  801a6f:	83 c4 10             	add    $0x10,%esp
  801a72:	eb 05                	jmp    801a79 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a74:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a79:	89 d0                	mov    %edx,%eax
  801a7b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a7e:	c9                   	leave  
  801a7f:	c3                   	ret    

00801a80 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a80:	55                   	push   %ebp
  801a81:	89 e5                	mov    %esp,%ebp
  801a83:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a86:	ba 00 00 00 00       	mov    $0x0,%edx
  801a8b:	b8 08 00 00 00       	mov    $0x8,%eax
  801a90:	e8 d2 fd ff ff       	call   801867 <fsipc>
}
  801a95:	c9                   	leave  
  801a96:	c3                   	ret    

00801a97 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a97:	55                   	push   %ebp
  801a98:	89 e5                	mov    %esp,%ebp
  801a9a:	56                   	push   %esi
  801a9b:	53                   	push   %ebx
  801a9c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a9f:	83 ec 0c             	sub    $0xc,%esp
  801aa2:	ff 75 08             	pushl  0x8(%ebp)
  801aa5:	e8 1e f8 ff ff       	call   8012c8 <fd2data>
  801aaa:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801aac:	83 c4 08             	add    $0x8,%esp
  801aaf:	68 a1 28 80 00       	push   $0x8028a1
  801ab4:	53                   	push   %ebx
  801ab5:	e8 fe ed ff ff       	call   8008b8 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801aba:	8b 46 04             	mov    0x4(%esi),%eax
  801abd:	2b 06                	sub    (%esi),%eax
  801abf:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ac5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801acc:	00 00 00 
	stat->st_dev = &devpipe;
  801acf:	c7 83 88 00 00 00 28 	movl   $0x803028,0x88(%ebx)
  801ad6:	30 80 00 
	return 0;
}
  801ad9:	b8 00 00 00 00       	mov    $0x0,%eax
  801ade:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ae1:	5b                   	pop    %ebx
  801ae2:	5e                   	pop    %esi
  801ae3:	5d                   	pop    %ebp
  801ae4:	c3                   	ret    

00801ae5 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ae5:	55                   	push   %ebp
  801ae6:	89 e5                	mov    %esp,%ebp
  801ae8:	53                   	push   %ebx
  801ae9:	83 ec 0c             	sub    $0xc,%esp
  801aec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801aef:	53                   	push   %ebx
  801af0:	6a 00                	push   $0x0
  801af2:	e8 49 f2 ff ff       	call   800d40 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801af7:	89 1c 24             	mov    %ebx,(%esp)
  801afa:	e8 c9 f7 ff ff       	call   8012c8 <fd2data>
  801aff:	83 c4 08             	add    $0x8,%esp
  801b02:	50                   	push   %eax
  801b03:	6a 00                	push   $0x0
  801b05:	e8 36 f2 ff ff       	call   800d40 <sys_page_unmap>
}
  801b0a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b0d:	c9                   	leave  
  801b0e:	c3                   	ret    

00801b0f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b0f:	55                   	push   %ebp
  801b10:	89 e5                	mov    %esp,%ebp
  801b12:	57                   	push   %edi
  801b13:	56                   	push   %esi
  801b14:	53                   	push   %ebx
  801b15:	83 ec 1c             	sub    $0x1c,%esp
  801b18:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801b1b:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b1d:	a1 04 40 80 00       	mov    0x804004,%eax
  801b22:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801b25:	83 ec 0c             	sub    $0xc,%esp
  801b28:	ff 75 e0             	pushl  -0x20(%ebp)
  801b2b:	e8 fc 04 00 00       	call   80202c <pageref>
  801b30:	89 c3                	mov    %eax,%ebx
  801b32:	89 3c 24             	mov    %edi,(%esp)
  801b35:	e8 f2 04 00 00       	call   80202c <pageref>
  801b3a:	83 c4 10             	add    $0x10,%esp
  801b3d:	39 c3                	cmp    %eax,%ebx
  801b3f:	0f 94 c1             	sete   %cl
  801b42:	0f b6 c9             	movzbl %cl,%ecx
  801b45:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801b48:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801b4e:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b51:	39 ce                	cmp    %ecx,%esi
  801b53:	74 1b                	je     801b70 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801b55:	39 c3                	cmp    %eax,%ebx
  801b57:	75 c4                	jne    801b1d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b59:	8b 42 58             	mov    0x58(%edx),%eax
  801b5c:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b5f:	50                   	push   %eax
  801b60:	56                   	push   %esi
  801b61:	68 a8 28 80 00       	push   $0x8028a8
  801b66:	e8 21 e7 ff ff       	call   80028c <cprintf>
  801b6b:	83 c4 10             	add    $0x10,%esp
  801b6e:	eb ad                	jmp    801b1d <_pipeisclosed+0xe>
	}
}
  801b70:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b73:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b76:	5b                   	pop    %ebx
  801b77:	5e                   	pop    %esi
  801b78:	5f                   	pop    %edi
  801b79:	5d                   	pop    %ebp
  801b7a:	c3                   	ret    

00801b7b <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b7b:	55                   	push   %ebp
  801b7c:	89 e5                	mov    %esp,%ebp
  801b7e:	57                   	push   %edi
  801b7f:	56                   	push   %esi
  801b80:	53                   	push   %ebx
  801b81:	83 ec 28             	sub    $0x28,%esp
  801b84:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b87:	56                   	push   %esi
  801b88:	e8 3b f7 ff ff       	call   8012c8 <fd2data>
  801b8d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b8f:	83 c4 10             	add    $0x10,%esp
  801b92:	bf 00 00 00 00       	mov    $0x0,%edi
  801b97:	eb 4b                	jmp    801be4 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b99:	89 da                	mov    %ebx,%edx
  801b9b:	89 f0                	mov    %esi,%eax
  801b9d:	e8 6d ff ff ff       	call   801b0f <_pipeisclosed>
  801ba2:	85 c0                	test   %eax,%eax
  801ba4:	75 48                	jne    801bee <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ba6:	e8 f1 f0 ff ff       	call   800c9c <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801bab:	8b 43 04             	mov    0x4(%ebx),%eax
  801bae:	8b 0b                	mov    (%ebx),%ecx
  801bb0:	8d 51 20             	lea    0x20(%ecx),%edx
  801bb3:	39 d0                	cmp    %edx,%eax
  801bb5:	73 e2                	jae    801b99 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801bb7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bba:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801bbe:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801bc1:	89 c2                	mov    %eax,%edx
  801bc3:	c1 fa 1f             	sar    $0x1f,%edx
  801bc6:	89 d1                	mov    %edx,%ecx
  801bc8:	c1 e9 1b             	shr    $0x1b,%ecx
  801bcb:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801bce:	83 e2 1f             	and    $0x1f,%edx
  801bd1:	29 ca                	sub    %ecx,%edx
  801bd3:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801bd7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801bdb:	83 c0 01             	add    $0x1,%eax
  801bde:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801be1:	83 c7 01             	add    $0x1,%edi
  801be4:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801be7:	75 c2                	jne    801bab <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801be9:	8b 45 10             	mov    0x10(%ebp),%eax
  801bec:	eb 05                	jmp    801bf3 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bee:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801bf3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bf6:	5b                   	pop    %ebx
  801bf7:	5e                   	pop    %esi
  801bf8:	5f                   	pop    %edi
  801bf9:	5d                   	pop    %ebp
  801bfa:	c3                   	ret    

00801bfb <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801bfb:	55                   	push   %ebp
  801bfc:	89 e5                	mov    %esp,%ebp
  801bfe:	57                   	push   %edi
  801bff:	56                   	push   %esi
  801c00:	53                   	push   %ebx
  801c01:	83 ec 18             	sub    $0x18,%esp
  801c04:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c07:	57                   	push   %edi
  801c08:	e8 bb f6 ff ff       	call   8012c8 <fd2data>
  801c0d:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c0f:	83 c4 10             	add    $0x10,%esp
  801c12:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c17:	eb 3d                	jmp    801c56 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c19:	85 db                	test   %ebx,%ebx
  801c1b:	74 04                	je     801c21 <devpipe_read+0x26>
				return i;
  801c1d:	89 d8                	mov    %ebx,%eax
  801c1f:	eb 44                	jmp    801c65 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c21:	89 f2                	mov    %esi,%edx
  801c23:	89 f8                	mov    %edi,%eax
  801c25:	e8 e5 fe ff ff       	call   801b0f <_pipeisclosed>
  801c2a:	85 c0                	test   %eax,%eax
  801c2c:	75 32                	jne    801c60 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c2e:	e8 69 f0 ff ff       	call   800c9c <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c33:	8b 06                	mov    (%esi),%eax
  801c35:	3b 46 04             	cmp    0x4(%esi),%eax
  801c38:	74 df                	je     801c19 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c3a:	99                   	cltd   
  801c3b:	c1 ea 1b             	shr    $0x1b,%edx
  801c3e:	01 d0                	add    %edx,%eax
  801c40:	83 e0 1f             	and    $0x1f,%eax
  801c43:	29 d0                	sub    %edx,%eax
  801c45:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801c4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c4d:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801c50:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c53:	83 c3 01             	add    $0x1,%ebx
  801c56:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c59:	75 d8                	jne    801c33 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c5b:	8b 45 10             	mov    0x10(%ebp),%eax
  801c5e:	eb 05                	jmp    801c65 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c60:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c65:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c68:	5b                   	pop    %ebx
  801c69:	5e                   	pop    %esi
  801c6a:	5f                   	pop    %edi
  801c6b:	5d                   	pop    %ebp
  801c6c:	c3                   	ret    

00801c6d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c6d:	55                   	push   %ebp
  801c6e:	89 e5                	mov    %esp,%ebp
  801c70:	56                   	push   %esi
  801c71:	53                   	push   %ebx
  801c72:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c75:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c78:	50                   	push   %eax
  801c79:	e8 61 f6 ff ff       	call   8012df <fd_alloc>
  801c7e:	83 c4 10             	add    $0x10,%esp
  801c81:	89 c2                	mov    %eax,%edx
  801c83:	85 c0                	test   %eax,%eax
  801c85:	0f 88 2c 01 00 00    	js     801db7 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c8b:	83 ec 04             	sub    $0x4,%esp
  801c8e:	68 07 04 00 00       	push   $0x407
  801c93:	ff 75 f4             	pushl  -0xc(%ebp)
  801c96:	6a 00                	push   $0x0
  801c98:	e8 1e f0 ff ff       	call   800cbb <sys_page_alloc>
  801c9d:	83 c4 10             	add    $0x10,%esp
  801ca0:	89 c2                	mov    %eax,%edx
  801ca2:	85 c0                	test   %eax,%eax
  801ca4:	0f 88 0d 01 00 00    	js     801db7 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801caa:	83 ec 0c             	sub    $0xc,%esp
  801cad:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801cb0:	50                   	push   %eax
  801cb1:	e8 29 f6 ff ff       	call   8012df <fd_alloc>
  801cb6:	89 c3                	mov    %eax,%ebx
  801cb8:	83 c4 10             	add    $0x10,%esp
  801cbb:	85 c0                	test   %eax,%eax
  801cbd:	0f 88 e2 00 00 00    	js     801da5 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cc3:	83 ec 04             	sub    $0x4,%esp
  801cc6:	68 07 04 00 00       	push   $0x407
  801ccb:	ff 75 f0             	pushl  -0x10(%ebp)
  801cce:	6a 00                	push   $0x0
  801cd0:	e8 e6 ef ff ff       	call   800cbb <sys_page_alloc>
  801cd5:	89 c3                	mov    %eax,%ebx
  801cd7:	83 c4 10             	add    $0x10,%esp
  801cda:	85 c0                	test   %eax,%eax
  801cdc:	0f 88 c3 00 00 00    	js     801da5 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801ce2:	83 ec 0c             	sub    $0xc,%esp
  801ce5:	ff 75 f4             	pushl  -0xc(%ebp)
  801ce8:	e8 db f5 ff ff       	call   8012c8 <fd2data>
  801ced:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cef:	83 c4 0c             	add    $0xc,%esp
  801cf2:	68 07 04 00 00       	push   $0x407
  801cf7:	50                   	push   %eax
  801cf8:	6a 00                	push   $0x0
  801cfa:	e8 bc ef ff ff       	call   800cbb <sys_page_alloc>
  801cff:	89 c3                	mov    %eax,%ebx
  801d01:	83 c4 10             	add    $0x10,%esp
  801d04:	85 c0                	test   %eax,%eax
  801d06:	0f 88 89 00 00 00    	js     801d95 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d0c:	83 ec 0c             	sub    $0xc,%esp
  801d0f:	ff 75 f0             	pushl  -0x10(%ebp)
  801d12:	e8 b1 f5 ff ff       	call   8012c8 <fd2data>
  801d17:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d1e:	50                   	push   %eax
  801d1f:	6a 00                	push   $0x0
  801d21:	56                   	push   %esi
  801d22:	6a 00                	push   $0x0
  801d24:	e8 d5 ef ff ff       	call   800cfe <sys_page_map>
  801d29:	89 c3                	mov    %eax,%ebx
  801d2b:	83 c4 20             	add    $0x20,%esp
  801d2e:	85 c0                	test   %eax,%eax
  801d30:	78 55                	js     801d87 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d32:	8b 15 28 30 80 00    	mov    0x803028,%edx
  801d38:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d3b:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d40:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d47:	8b 15 28 30 80 00    	mov    0x803028,%edx
  801d4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d50:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d52:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d55:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d5c:	83 ec 0c             	sub    $0xc,%esp
  801d5f:	ff 75 f4             	pushl  -0xc(%ebp)
  801d62:	e8 51 f5 ff ff       	call   8012b8 <fd2num>
  801d67:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d6a:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d6c:	83 c4 04             	add    $0x4,%esp
  801d6f:	ff 75 f0             	pushl  -0x10(%ebp)
  801d72:	e8 41 f5 ff ff       	call   8012b8 <fd2num>
  801d77:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d7a:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d7d:	83 c4 10             	add    $0x10,%esp
  801d80:	ba 00 00 00 00       	mov    $0x0,%edx
  801d85:	eb 30                	jmp    801db7 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d87:	83 ec 08             	sub    $0x8,%esp
  801d8a:	56                   	push   %esi
  801d8b:	6a 00                	push   $0x0
  801d8d:	e8 ae ef ff ff       	call   800d40 <sys_page_unmap>
  801d92:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d95:	83 ec 08             	sub    $0x8,%esp
  801d98:	ff 75 f0             	pushl  -0x10(%ebp)
  801d9b:	6a 00                	push   $0x0
  801d9d:	e8 9e ef ff ff       	call   800d40 <sys_page_unmap>
  801da2:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801da5:	83 ec 08             	sub    $0x8,%esp
  801da8:	ff 75 f4             	pushl  -0xc(%ebp)
  801dab:	6a 00                	push   $0x0
  801dad:	e8 8e ef ff ff       	call   800d40 <sys_page_unmap>
  801db2:	83 c4 10             	add    $0x10,%esp
  801db5:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801db7:	89 d0                	mov    %edx,%eax
  801db9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dbc:	5b                   	pop    %ebx
  801dbd:	5e                   	pop    %esi
  801dbe:	5d                   	pop    %ebp
  801dbf:	c3                   	ret    

00801dc0 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801dc0:	55                   	push   %ebp
  801dc1:	89 e5                	mov    %esp,%ebp
  801dc3:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801dc6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dc9:	50                   	push   %eax
  801dca:	ff 75 08             	pushl  0x8(%ebp)
  801dcd:	e8 5c f5 ff ff       	call   80132e <fd_lookup>
  801dd2:	83 c4 10             	add    $0x10,%esp
  801dd5:	85 c0                	test   %eax,%eax
  801dd7:	78 18                	js     801df1 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801dd9:	83 ec 0c             	sub    $0xc,%esp
  801ddc:	ff 75 f4             	pushl  -0xc(%ebp)
  801ddf:	e8 e4 f4 ff ff       	call   8012c8 <fd2data>
	return _pipeisclosed(fd, p);
  801de4:	89 c2                	mov    %eax,%edx
  801de6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801de9:	e8 21 fd ff ff       	call   801b0f <_pipeisclosed>
  801dee:	83 c4 10             	add    $0x10,%esp
}
  801df1:	c9                   	leave  
  801df2:	c3                   	ret    

00801df3 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801df3:	55                   	push   %ebp
  801df4:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801df6:	b8 00 00 00 00       	mov    $0x0,%eax
  801dfb:	5d                   	pop    %ebp
  801dfc:	c3                   	ret    

00801dfd <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801dfd:	55                   	push   %ebp
  801dfe:	89 e5                	mov    %esp,%ebp
  801e00:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e03:	68 c0 28 80 00       	push   $0x8028c0
  801e08:	ff 75 0c             	pushl  0xc(%ebp)
  801e0b:	e8 a8 ea ff ff       	call   8008b8 <strcpy>
	return 0;
}
  801e10:	b8 00 00 00 00       	mov    $0x0,%eax
  801e15:	c9                   	leave  
  801e16:	c3                   	ret    

00801e17 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e17:	55                   	push   %ebp
  801e18:	89 e5                	mov    %esp,%ebp
  801e1a:	57                   	push   %edi
  801e1b:	56                   	push   %esi
  801e1c:	53                   	push   %ebx
  801e1d:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e23:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e28:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e2e:	eb 2d                	jmp    801e5d <devcons_write+0x46>
		m = n - tot;
  801e30:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e33:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801e35:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e38:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801e3d:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e40:	83 ec 04             	sub    $0x4,%esp
  801e43:	53                   	push   %ebx
  801e44:	03 45 0c             	add    0xc(%ebp),%eax
  801e47:	50                   	push   %eax
  801e48:	57                   	push   %edi
  801e49:	e8 fc eb ff ff       	call   800a4a <memmove>
		sys_cputs(buf, m);
  801e4e:	83 c4 08             	add    $0x8,%esp
  801e51:	53                   	push   %ebx
  801e52:	57                   	push   %edi
  801e53:	e8 a7 ed ff ff       	call   800bff <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e58:	01 de                	add    %ebx,%esi
  801e5a:	83 c4 10             	add    $0x10,%esp
  801e5d:	89 f0                	mov    %esi,%eax
  801e5f:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e62:	72 cc                	jb     801e30 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e64:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e67:	5b                   	pop    %ebx
  801e68:	5e                   	pop    %esi
  801e69:	5f                   	pop    %edi
  801e6a:	5d                   	pop    %ebp
  801e6b:	c3                   	ret    

00801e6c <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e6c:	55                   	push   %ebp
  801e6d:	89 e5                	mov    %esp,%ebp
  801e6f:	83 ec 08             	sub    $0x8,%esp
  801e72:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801e77:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e7b:	74 2a                	je     801ea7 <devcons_read+0x3b>
  801e7d:	eb 05                	jmp    801e84 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e7f:	e8 18 ee ff ff       	call   800c9c <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e84:	e8 94 ed ff ff       	call   800c1d <sys_cgetc>
  801e89:	85 c0                	test   %eax,%eax
  801e8b:	74 f2                	je     801e7f <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801e8d:	85 c0                	test   %eax,%eax
  801e8f:	78 16                	js     801ea7 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e91:	83 f8 04             	cmp    $0x4,%eax
  801e94:	74 0c                	je     801ea2 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e96:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e99:	88 02                	mov    %al,(%edx)
	return 1;
  801e9b:	b8 01 00 00 00       	mov    $0x1,%eax
  801ea0:	eb 05                	jmp    801ea7 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ea2:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801ea7:	c9                   	leave  
  801ea8:	c3                   	ret    

00801ea9 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801ea9:	55                   	push   %ebp
  801eaa:	89 e5                	mov    %esp,%ebp
  801eac:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801eaf:	8b 45 08             	mov    0x8(%ebp),%eax
  801eb2:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801eb5:	6a 01                	push   $0x1
  801eb7:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801eba:	50                   	push   %eax
  801ebb:	e8 3f ed ff ff       	call   800bff <sys_cputs>
}
  801ec0:	83 c4 10             	add    $0x10,%esp
  801ec3:	c9                   	leave  
  801ec4:	c3                   	ret    

00801ec5 <getchar>:

int
getchar(void)
{
  801ec5:	55                   	push   %ebp
  801ec6:	89 e5                	mov    %esp,%ebp
  801ec8:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801ecb:	6a 01                	push   $0x1
  801ecd:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ed0:	50                   	push   %eax
  801ed1:	6a 00                	push   $0x0
  801ed3:	e8 bc f6 ff ff       	call   801594 <read>
	if (r < 0)
  801ed8:	83 c4 10             	add    $0x10,%esp
  801edb:	85 c0                	test   %eax,%eax
  801edd:	78 0f                	js     801eee <getchar+0x29>
		return r;
	if (r < 1)
  801edf:	85 c0                	test   %eax,%eax
  801ee1:	7e 06                	jle    801ee9 <getchar+0x24>
		return -E_EOF;
	return c;
  801ee3:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801ee7:	eb 05                	jmp    801eee <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801ee9:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801eee:	c9                   	leave  
  801eef:	c3                   	ret    

00801ef0 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801ef0:	55                   	push   %ebp
  801ef1:	89 e5                	mov    %esp,%ebp
  801ef3:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ef6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ef9:	50                   	push   %eax
  801efa:	ff 75 08             	pushl  0x8(%ebp)
  801efd:	e8 2c f4 ff ff       	call   80132e <fd_lookup>
  801f02:	83 c4 10             	add    $0x10,%esp
  801f05:	85 c0                	test   %eax,%eax
  801f07:	78 11                	js     801f1a <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f09:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f0c:	8b 15 44 30 80 00    	mov    0x803044,%edx
  801f12:	39 10                	cmp    %edx,(%eax)
  801f14:	0f 94 c0             	sete   %al
  801f17:	0f b6 c0             	movzbl %al,%eax
}
  801f1a:	c9                   	leave  
  801f1b:	c3                   	ret    

00801f1c <opencons>:

int
opencons(void)
{
  801f1c:	55                   	push   %ebp
  801f1d:	89 e5                	mov    %esp,%ebp
  801f1f:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f22:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f25:	50                   	push   %eax
  801f26:	e8 b4 f3 ff ff       	call   8012df <fd_alloc>
  801f2b:	83 c4 10             	add    $0x10,%esp
		return r;
  801f2e:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f30:	85 c0                	test   %eax,%eax
  801f32:	78 3e                	js     801f72 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f34:	83 ec 04             	sub    $0x4,%esp
  801f37:	68 07 04 00 00       	push   $0x407
  801f3c:	ff 75 f4             	pushl  -0xc(%ebp)
  801f3f:	6a 00                	push   $0x0
  801f41:	e8 75 ed ff ff       	call   800cbb <sys_page_alloc>
  801f46:	83 c4 10             	add    $0x10,%esp
		return r;
  801f49:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f4b:	85 c0                	test   %eax,%eax
  801f4d:	78 23                	js     801f72 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f4f:	8b 15 44 30 80 00    	mov    0x803044,%edx
  801f55:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f58:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f5d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f64:	83 ec 0c             	sub    $0xc,%esp
  801f67:	50                   	push   %eax
  801f68:	e8 4b f3 ff ff       	call   8012b8 <fd2num>
  801f6d:	89 c2                	mov    %eax,%edx
  801f6f:	83 c4 10             	add    $0x10,%esp
}
  801f72:	89 d0                	mov    %edx,%eax
  801f74:	c9                   	leave  
  801f75:	c3                   	ret    

00801f76 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801f76:	55                   	push   %ebp
  801f77:	89 e5                	mov    %esp,%ebp
  801f79:	56                   	push   %esi
  801f7a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801f7b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801f7e:	8b 35 08 30 80 00    	mov    0x803008,%esi
  801f84:	e8 f4 ec ff ff       	call   800c7d <sys_getenvid>
  801f89:	83 ec 0c             	sub    $0xc,%esp
  801f8c:	ff 75 0c             	pushl  0xc(%ebp)
  801f8f:	ff 75 08             	pushl  0x8(%ebp)
  801f92:	56                   	push   %esi
  801f93:	50                   	push   %eax
  801f94:	68 cc 28 80 00       	push   $0x8028cc
  801f99:	e8 ee e2 ff ff       	call   80028c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801f9e:	83 c4 18             	add    $0x18,%esp
  801fa1:	53                   	push   %ebx
  801fa2:	ff 75 10             	pushl  0x10(%ebp)
  801fa5:	e8 91 e2 ff ff       	call   80023b <vcprintf>
	cprintf("\n");
  801faa:	c7 04 24 b9 28 80 00 	movl   $0x8028b9,(%esp)
  801fb1:	e8 d6 e2 ff ff       	call   80028c <cprintf>
  801fb6:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801fb9:	cc                   	int3   
  801fba:	eb fd                	jmp    801fb9 <_panic+0x43>

00801fbc <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801fbc:	55                   	push   %ebp
  801fbd:	89 e5                	mov    %esp,%ebp
  801fbf:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801fc2:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801fc9:	75 31                	jne    801ffc <set_pgfault_handler+0x40>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc(thisenv->env_id, (void*)(UXSTACKTOP - PGSIZE), PTE_P | 
  801fcb:	a1 04 40 80 00       	mov    0x804004,%eax
  801fd0:	8b 40 48             	mov    0x48(%eax),%eax
  801fd3:	83 ec 04             	sub    $0x4,%esp
  801fd6:	6a 07                	push   $0x7
  801fd8:	68 00 f0 bf ee       	push   $0xeebff000
  801fdd:	50                   	push   %eax
  801fde:	e8 d8 ec ff ff       	call   800cbb <sys_page_alloc>
				PTE_U | PTE_W);
		sys_env_set_pgfault_upcall(thisenv->env_id, (void*)_pgfault_upcall);
  801fe3:	a1 04 40 80 00       	mov    0x804004,%eax
  801fe8:	8b 40 48             	mov    0x48(%eax),%eax
  801feb:	83 c4 08             	add    $0x8,%esp
  801fee:	68 06 20 80 00       	push   $0x802006
  801ff3:	50                   	push   %eax
  801ff4:	e8 0d ee ff ff       	call   800e06 <sys_env_set_pgfault_upcall>
  801ff9:	83 c4 10             	add    $0x10,%esp

		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801ffc:	8b 45 08             	mov    0x8(%ebp),%eax
  801fff:	a3 00 60 80 00       	mov    %eax,0x806000
}
  802004:	c9                   	leave  
  802005:	c3                   	ret    

00802006 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802006:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802007:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  80200c:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80200e:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	addl $8, %esp      // pop utf_fault_va and utf_err
  802011:	83 c4 08             	add    $0x8,%esp
	movl 32(%esp), %eax  // eax <- [esp + 32]
  802014:	8b 44 24 20          	mov    0x20(%esp),%eax
	movl 40(%esp), %ebx  // ebx <- [esp + 40]
  802018:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	leal -4(%ebx), %ebx  // ebx <- ebx - 4
  80201c:	8d 5b fc             	lea    -0x4(%ebx),%ebx
	movl %eax, (%ebx)
  80201f:	89 03                	mov    %eax,(%ebx)
	movl %ebx, 40(%esp)  // push trap eip and decrement trap esp manually
  802021:	89 5c 24 28          	mov    %ebx,0x28(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  802025:	61                   	popa   
	addl $4, %esp        // skip eip
  802026:	83 c4 04             	add    $0x4,%esp

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	popf
  802029:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	pop %esp
  80202a:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80202b:	c3                   	ret    

0080202c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80202c:	55                   	push   %ebp
  80202d:	89 e5                	mov    %esp,%ebp
  80202f:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802032:	89 d0                	mov    %edx,%eax
  802034:	c1 e8 16             	shr    $0x16,%eax
  802037:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80203e:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802043:	f6 c1 01             	test   $0x1,%cl
  802046:	74 1d                	je     802065 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802048:	c1 ea 0c             	shr    $0xc,%edx
  80204b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802052:	f6 c2 01             	test   $0x1,%dl
  802055:	74 0e                	je     802065 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802057:	c1 ea 0c             	shr    $0xc,%edx
  80205a:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802061:	ef 
  802062:	0f b7 c0             	movzwl %ax,%eax
}
  802065:	5d                   	pop    %ebp
  802066:	c3                   	ret    
  802067:	66 90                	xchg   %ax,%ax
  802069:	66 90                	xchg   %ax,%ax
  80206b:	66 90                	xchg   %ax,%ax
  80206d:	66 90                	xchg   %ax,%ax
  80206f:	90                   	nop

00802070 <__udivdi3>:
  802070:	55                   	push   %ebp
  802071:	57                   	push   %edi
  802072:	56                   	push   %esi
  802073:	53                   	push   %ebx
  802074:	83 ec 1c             	sub    $0x1c,%esp
  802077:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80207b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80207f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802083:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802087:	85 f6                	test   %esi,%esi
  802089:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80208d:	89 ca                	mov    %ecx,%edx
  80208f:	89 f8                	mov    %edi,%eax
  802091:	75 3d                	jne    8020d0 <__udivdi3+0x60>
  802093:	39 cf                	cmp    %ecx,%edi
  802095:	0f 87 c5 00 00 00    	ja     802160 <__udivdi3+0xf0>
  80209b:	85 ff                	test   %edi,%edi
  80209d:	89 fd                	mov    %edi,%ebp
  80209f:	75 0b                	jne    8020ac <__udivdi3+0x3c>
  8020a1:	b8 01 00 00 00       	mov    $0x1,%eax
  8020a6:	31 d2                	xor    %edx,%edx
  8020a8:	f7 f7                	div    %edi
  8020aa:	89 c5                	mov    %eax,%ebp
  8020ac:	89 c8                	mov    %ecx,%eax
  8020ae:	31 d2                	xor    %edx,%edx
  8020b0:	f7 f5                	div    %ebp
  8020b2:	89 c1                	mov    %eax,%ecx
  8020b4:	89 d8                	mov    %ebx,%eax
  8020b6:	89 cf                	mov    %ecx,%edi
  8020b8:	f7 f5                	div    %ebp
  8020ba:	89 c3                	mov    %eax,%ebx
  8020bc:	89 d8                	mov    %ebx,%eax
  8020be:	89 fa                	mov    %edi,%edx
  8020c0:	83 c4 1c             	add    $0x1c,%esp
  8020c3:	5b                   	pop    %ebx
  8020c4:	5e                   	pop    %esi
  8020c5:	5f                   	pop    %edi
  8020c6:	5d                   	pop    %ebp
  8020c7:	c3                   	ret    
  8020c8:	90                   	nop
  8020c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020d0:	39 ce                	cmp    %ecx,%esi
  8020d2:	77 74                	ja     802148 <__udivdi3+0xd8>
  8020d4:	0f bd fe             	bsr    %esi,%edi
  8020d7:	83 f7 1f             	xor    $0x1f,%edi
  8020da:	0f 84 98 00 00 00    	je     802178 <__udivdi3+0x108>
  8020e0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8020e5:	89 f9                	mov    %edi,%ecx
  8020e7:	89 c5                	mov    %eax,%ebp
  8020e9:	29 fb                	sub    %edi,%ebx
  8020eb:	d3 e6                	shl    %cl,%esi
  8020ed:	89 d9                	mov    %ebx,%ecx
  8020ef:	d3 ed                	shr    %cl,%ebp
  8020f1:	89 f9                	mov    %edi,%ecx
  8020f3:	d3 e0                	shl    %cl,%eax
  8020f5:	09 ee                	or     %ebp,%esi
  8020f7:	89 d9                	mov    %ebx,%ecx
  8020f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020fd:	89 d5                	mov    %edx,%ebp
  8020ff:	8b 44 24 08          	mov    0x8(%esp),%eax
  802103:	d3 ed                	shr    %cl,%ebp
  802105:	89 f9                	mov    %edi,%ecx
  802107:	d3 e2                	shl    %cl,%edx
  802109:	89 d9                	mov    %ebx,%ecx
  80210b:	d3 e8                	shr    %cl,%eax
  80210d:	09 c2                	or     %eax,%edx
  80210f:	89 d0                	mov    %edx,%eax
  802111:	89 ea                	mov    %ebp,%edx
  802113:	f7 f6                	div    %esi
  802115:	89 d5                	mov    %edx,%ebp
  802117:	89 c3                	mov    %eax,%ebx
  802119:	f7 64 24 0c          	mull   0xc(%esp)
  80211d:	39 d5                	cmp    %edx,%ebp
  80211f:	72 10                	jb     802131 <__udivdi3+0xc1>
  802121:	8b 74 24 08          	mov    0x8(%esp),%esi
  802125:	89 f9                	mov    %edi,%ecx
  802127:	d3 e6                	shl    %cl,%esi
  802129:	39 c6                	cmp    %eax,%esi
  80212b:	73 07                	jae    802134 <__udivdi3+0xc4>
  80212d:	39 d5                	cmp    %edx,%ebp
  80212f:	75 03                	jne    802134 <__udivdi3+0xc4>
  802131:	83 eb 01             	sub    $0x1,%ebx
  802134:	31 ff                	xor    %edi,%edi
  802136:	89 d8                	mov    %ebx,%eax
  802138:	89 fa                	mov    %edi,%edx
  80213a:	83 c4 1c             	add    $0x1c,%esp
  80213d:	5b                   	pop    %ebx
  80213e:	5e                   	pop    %esi
  80213f:	5f                   	pop    %edi
  802140:	5d                   	pop    %ebp
  802141:	c3                   	ret    
  802142:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802148:	31 ff                	xor    %edi,%edi
  80214a:	31 db                	xor    %ebx,%ebx
  80214c:	89 d8                	mov    %ebx,%eax
  80214e:	89 fa                	mov    %edi,%edx
  802150:	83 c4 1c             	add    $0x1c,%esp
  802153:	5b                   	pop    %ebx
  802154:	5e                   	pop    %esi
  802155:	5f                   	pop    %edi
  802156:	5d                   	pop    %ebp
  802157:	c3                   	ret    
  802158:	90                   	nop
  802159:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802160:	89 d8                	mov    %ebx,%eax
  802162:	f7 f7                	div    %edi
  802164:	31 ff                	xor    %edi,%edi
  802166:	89 c3                	mov    %eax,%ebx
  802168:	89 d8                	mov    %ebx,%eax
  80216a:	89 fa                	mov    %edi,%edx
  80216c:	83 c4 1c             	add    $0x1c,%esp
  80216f:	5b                   	pop    %ebx
  802170:	5e                   	pop    %esi
  802171:	5f                   	pop    %edi
  802172:	5d                   	pop    %ebp
  802173:	c3                   	ret    
  802174:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802178:	39 ce                	cmp    %ecx,%esi
  80217a:	72 0c                	jb     802188 <__udivdi3+0x118>
  80217c:	31 db                	xor    %ebx,%ebx
  80217e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802182:	0f 87 34 ff ff ff    	ja     8020bc <__udivdi3+0x4c>
  802188:	bb 01 00 00 00       	mov    $0x1,%ebx
  80218d:	e9 2a ff ff ff       	jmp    8020bc <__udivdi3+0x4c>
  802192:	66 90                	xchg   %ax,%ax
  802194:	66 90                	xchg   %ax,%ax
  802196:	66 90                	xchg   %ax,%ax
  802198:	66 90                	xchg   %ax,%ax
  80219a:	66 90                	xchg   %ax,%ax
  80219c:	66 90                	xchg   %ax,%ax
  80219e:	66 90                	xchg   %ax,%ax

008021a0 <__umoddi3>:
  8021a0:	55                   	push   %ebp
  8021a1:	57                   	push   %edi
  8021a2:	56                   	push   %esi
  8021a3:	53                   	push   %ebx
  8021a4:	83 ec 1c             	sub    $0x1c,%esp
  8021a7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8021ab:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8021af:	8b 74 24 34          	mov    0x34(%esp),%esi
  8021b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021b7:	85 d2                	test   %edx,%edx
  8021b9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8021bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021c1:	89 f3                	mov    %esi,%ebx
  8021c3:	89 3c 24             	mov    %edi,(%esp)
  8021c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021ca:	75 1c                	jne    8021e8 <__umoddi3+0x48>
  8021cc:	39 f7                	cmp    %esi,%edi
  8021ce:	76 50                	jbe    802220 <__umoddi3+0x80>
  8021d0:	89 c8                	mov    %ecx,%eax
  8021d2:	89 f2                	mov    %esi,%edx
  8021d4:	f7 f7                	div    %edi
  8021d6:	89 d0                	mov    %edx,%eax
  8021d8:	31 d2                	xor    %edx,%edx
  8021da:	83 c4 1c             	add    $0x1c,%esp
  8021dd:	5b                   	pop    %ebx
  8021de:	5e                   	pop    %esi
  8021df:	5f                   	pop    %edi
  8021e0:	5d                   	pop    %ebp
  8021e1:	c3                   	ret    
  8021e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021e8:	39 f2                	cmp    %esi,%edx
  8021ea:	89 d0                	mov    %edx,%eax
  8021ec:	77 52                	ja     802240 <__umoddi3+0xa0>
  8021ee:	0f bd ea             	bsr    %edx,%ebp
  8021f1:	83 f5 1f             	xor    $0x1f,%ebp
  8021f4:	75 5a                	jne    802250 <__umoddi3+0xb0>
  8021f6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8021fa:	0f 82 e0 00 00 00    	jb     8022e0 <__umoddi3+0x140>
  802200:	39 0c 24             	cmp    %ecx,(%esp)
  802203:	0f 86 d7 00 00 00    	jbe    8022e0 <__umoddi3+0x140>
  802209:	8b 44 24 08          	mov    0x8(%esp),%eax
  80220d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802211:	83 c4 1c             	add    $0x1c,%esp
  802214:	5b                   	pop    %ebx
  802215:	5e                   	pop    %esi
  802216:	5f                   	pop    %edi
  802217:	5d                   	pop    %ebp
  802218:	c3                   	ret    
  802219:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802220:	85 ff                	test   %edi,%edi
  802222:	89 fd                	mov    %edi,%ebp
  802224:	75 0b                	jne    802231 <__umoddi3+0x91>
  802226:	b8 01 00 00 00       	mov    $0x1,%eax
  80222b:	31 d2                	xor    %edx,%edx
  80222d:	f7 f7                	div    %edi
  80222f:	89 c5                	mov    %eax,%ebp
  802231:	89 f0                	mov    %esi,%eax
  802233:	31 d2                	xor    %edx,%edx
  802235:	f7 f5                	div    %ebp
  802237:	89 c8                	mov    %ecx,%eax
  802239:	f7 f5                	div    %ebp
  80223b:	89 d0                	mov    %edx,%eax
  80223d:	eb 99                	jmp    8021d8 <__umoddi3+0x38>
  80223f:	90                   	nop
  802240:	89 c8                	mov    %ecx,%eax
  802242:	89 f2                	mov    %esi,%edx
  802244:	83 c4 1c             	add    $0x1c,%esp
  802247:	5b                   	pop    %ebx
  802248:	5e                   	pop    %esi
  802249:	5f                   	pop    %edi
  80224a:	5d                   	pop    %ebp
  80224b:	c3                   	ret    
  80224c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802250:	8b 34 24             	mov    (%esp),%esi
  802253:	bf 20 00 00 00       	mov    $0x20,%edi
  802258:	89 e9                	mov    %ebp,%ecx
  80225a:	29 ef                	sub    %ebp,%edi
  80225c:	d3 e0                	shl    %cl,%eax
  80225e:	89 f9                	mov    %edi,%ecx
  802260:	89 f2                	mov    %esi,%edx
  802262:	d3 ea                	shr    %cl,%edx
  802264:	89 e9                	mov    %ebp,%ecx
  802266:	09 c2                	or     %eax,%edx
  802268:	89 d8                	mov    %ebx,%eax
  80226a:	89 14 24             	mov    %edx,(%esp)
  80226d:	89 f2                	mov    %esi,%edx
  80226f:	d3 e2                	shl    %cl,%edx
  802271:	89 f9                	mov    %edi,%ecx
  802273:	89 54 24 04          	mov    %edx,0x4(%esp)
  802277:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80227b:	d3 e8                	shr    %cl,%eax
  80227d:	89 e9                	mov    %ebp,%ecx
  80227f:	89 c6                	mov    %eax,%esi
  802281:	d3 e3                	shl    %cl,%ebx
  802283:	89 f9                	mov    %edi,%ecx
  802285:	89 d0                	mov    %edx,%eax
  802287:	d3 e8                	shr    %cl,%eax
  802289:	89 e9                	mov    %ebp,%ecx
  80228b:	09 d8                	or     %ebx,%eax
  80228d:	89 d3                	mov    %edx,%ebx
  80228f:	89 f2                	mov    %esi,%edx
  802291:	f7 34 24             	divl   (%esp)
  802294:	89 d6                	mov    %edx,%esi
  802296:	d3 e3                	shl    %cl,%ebx
  802298:	f7 64 24 04          	mull   0x4(%esp)
  80229c:	39 d6                	cmp    %edx,%esi
  80229e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022a2:	89 d1                	mov    %edx,%ecx
  8022a4:	89 c3                	mov    %eax,%ebx
  8022a6:	72 08                	jb     8022b0 <__umoddi3+0x110>
  8022a8:	75 11                	jne    8022bb <__umoddi3+0x11b>
  8022aa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8022ae:	73 0b                	jae    8022bb <__umoddi3+0x11b>
  8022b0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8022b4:	1b 14 24             	sbb    (%esp),%edx
  8022b7:	89 d1                	mov    %edx,%ecx
  8022b9:	89 c3                	mov    %eax,%ebx
  8022bb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8022bf:	29 da                	sub    %ebx,%edx
  8022c1:	19 ce                	sbb    %ecx,%esi
  8022c3:	89 f9                	mov    %edi,%ecx
  8022c5:	89 f0                	mov    %esi,%eax
  8022c7:	d3 e0                	shl    %cl,%eax
  8022c9:	89 e9                	mov    %ebp,%ecx
  8022cb:	d3 ea                	shr    %cl,%edx
  8022cd:	89 e9                	mov    %ebp,%ecx
  8022cf:	d3 ee                	shr    %cl,%esi
  8022d1:	09 d0                	or     %edx,%eax
  8022d3:	89 f2                	mov    %esi,%edx
  8022d5:	83 c4 1c             	add    $0x1c,%esp
  8022d8:	5b                   	pop    %ebx
  8022d9:	5e                   	pop    %esi
  8022da:	5f                   	pop    %edi
  8022db:	5d                   	pop    %ebp
  8022dc:	c3                   	ret    
  8022dd:	8d 76 00             	lea    0x0(%esi),%esi
  8022e0:	29 f9                	sub    %edi,%ecx
  8022e2:	19 d6                	sbb    %edx,%esi
  8022e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022e8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022ec:	e9 18 ff ff ff       	jmp    802209 <__umoddi3+0x69>
