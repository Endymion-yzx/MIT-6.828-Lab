
obj/user/icode.debug:     file format elf32-i386


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
  80002c:	e8 03 01 00 00       	call   800134 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	81 ec 1c 02 00 00    	sub    $0x21c,%esp
	int fd, n, r;
	char buf[512+1];

	binaryname = "icode";
  80003e:	c7 05 00 30 80 00 60 	movl   $0x802460,0x803000
  800045:	24 80 00 

	cprintf("icode startup\n");
  800048:	68 66 24 80 00       	push   $0x802466
  80004d:	e8 1b 02 00 00       	call   80026d <cprintf>

	cprintf("icode: open /motd\n");
  800052:	c7 04 24 75 24 80 00 	movl   $0x802475,(%esp)
  800059:	e8 0f 02 00 00       	call   80026d <cprintf>
	if ((fd = open("/motd", O_RDONLY)) < 0)
  80005e:	83 c4 08             	add    $0x8,%esp
  800061:	6a 00                	push   $0x0
  800063:	68 88 24 80 00       	push   $0x802488
  800068:	e8 5b 15 00 00       	call   8015c8 <open>
  80006d:	89 c6                	mov    %eax,%esi
  80006f:	83 c4 10             	add    $0x10,%esp
  800072:	85 c0                	test   %eax,%eax
  800074:	79 12                	jns    800088 <umain+0x55>
		panic("icode: open /motd: %e", fd);
  800076:	50                   	push   %eax
  800077:	68 8e 24 80 00       	push   $0x80248e
  80007c:	6a 0f                	push   $0xf
  80007e:	68 a4 24 80 00       	push   $0x8024a4
  800083:	e8 0c 01 00 00       	call   800194 <_panic>

	cprintf("icode: read /motd\n");
  800088:	83 ec 0c             	sub    $0xc,%esp
  80008b:	68 b1 24 80 00       	push   $0x8024b1
  800090:	e8 d8 01 00 00       	call   80026d <cprintf>
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  800095:	83 c4 10             	add    $0x10,%esp
  800098:	8d 9d f7 fd ff ff    	lea    -0x209(%ebp),%ebx
  80009e:	eb 0d                	jmp    8000ad <umain+0x7a>
		sys_cputs(buf, n);
  8000a0:	83 ec 08             	sub    $0x8,%esp
  8000a3:	50                   	push   %eax
  8000a4:	53                   	push   %ebx
  8000a5:	e8 36 0b 00 00       	call   800be0 <sys_cputs>
  8000aa:	83 c4 10             	add    $0x10,%esp
	cprintf("icode: open /motd\n");
	if ((fd = open("/motd", O_RDONLY)) < 0)
		panic("icode: open /motd: %e", fd);

	cprintf("icode: read /motd\n");
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  8000ad:	83 ec 04             	sub    $0x4,%esp
  8000b0:	68 00 02 00 00       	push   $0x200
  8000b5:	53                   	push   %ebx
  8000b6:	56                   	push   %esi
  8000b7:	e8 ad 10 00 00       	call   801169 <read>
  8000bc:	83 c4 10             	add    $0x10,%esp
  8000bf:	85 c0                	test   %eax,%eax
  8000c1:	7f dd                	jg     8000a0 <umain+0x6d>
		sys_cputs(buf, n);

	cprintf("icode: close /motd\n");
  8000c3:	83 ec 0c             	sub    $0xc,%esp
  8000c6:	68 c4 24 80 00       	push   $0x8024c4
  8000cb:	e8 9d 01 00 00       	call   80026d <cprintf>
	close(fd);
  8000d0:	89 34 24             	mov    %esi,(%esp)
  8000d3:	e8 55 0f 00 00       	call   80102d <close>

	cprintf("icode: spawn /init\n");
  8000d8:	c7 04 24 d8 24 80 00 	movl   $0x8024d8,(%esp)
  8000df:	e8 89 01 00 00       	call   80026d <cprintf>
	if ((r = spawnl("/init", "init", "initarg1", "initarg2", (char*)0)) < 0)
  8000e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000eb:	68 ec 24 80 00       	push   $0x8024ec
  8000f0:	68 f5 24 80 00       	push   $0x8024f5
  8000f5:	68 ff 24 80 00       	push   $0x8024ff
  8000fa:	68 fe 24 80 00       	push   $0x8024fe
  8000ff:	e8 35 1a 00 00       	call   801b39 <spawnl>
  800104:	83 c4 20             	add    $0x20,%esp
  800107:	85 c0                	test   %eax,%eax
  800109:	79 12                	jns    80011d <umain+0xea>
		panic("icode: spawn /init: %e", r);
  80010b:	50                   	push   %eax
  80010c:	68 04 25 80 00       	push   $0x802504
  800111:	6a 1a                	push   $0x1a
  800113:	68 a4 24 80 00       	push   $0x8024a4
  800118:	e8 77 00 00 00       	call   800194 <_panic>

	cprintf("icode: exiting\n");
  80011d:	83 ec 0c             	sub    $0xc,%esp
  800120:	68 1b 25 80 00       	push   $0x80251b
  800125:	e8 43 01 00 00       	call   80026d <cprintf>
}
  80012a:	83 c4 10             	add    $0x10,%esp
  80012d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800130:	5b                   	pop    %ebx
  800131:	5e                   	pop    %esi
  800132:	5d                   	pop    %ebp
  800133:	c3                   	ret    

00800134 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	56                   	push   %esi
  800138:	53                   	push   %ebx
  800139:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80013c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	envid_t envid = sys_getenvid();
  80013f:	e8 1a 0b 00 00       	call   800c5e <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  800144:	25 ff 03 00 00       	and    $0x3ff,%eax
  800149:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80014c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800151:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800156:	85 db                	test   %ebx,%ebx
  800158:	7e 07                	jle    800161 <libmain+0x2d>
		binaryname = argv[0];
  80015a:	8b 06                	mov    (%esi),%eax
  80015c:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800161:	83 ec 08             	sub    $0x8,%esp
  800164:	56                   	push   %esi
  800165:	53                   	push   %ebx
  800166:	e8 c8 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80016b:	e8 0a 00 00 00       	call   80017a <exit>
}
  800170:	83 c4 10             	add    $0x10,%esp
  800173:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800176:	5b                   	pop    %ebx
  800177:	5e                   	pop    %esi
  800178:	5d                   	pop    %ebp
  800179:	c3                   	ret    

0080017a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80017a:	55                   	push   %ebp
  80017b:	89 e5                	mov    %esp,%ebp
  80017d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800180:	e8 d3 0e 00 00       	call   801058 <close_all>
	sys_env_destroy(0);
  800185:	83 ec 0c             	sub    $0xc,%esp
  800188:	6a 00                	push   $0x0
  80018a:	e8 8e 0a 00 00       	call   800c1d <sys_env_destroy>
}
  80018f:	83 c4 10             	add    $0x10,%esp
  800192:	c9                   	leave  
  800193:	c3                   	ret    

00800194 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800194:	55                   	push   %ebp
  800195:	89 e5                	mov    %esp,%ebp
  800197:	56                   	push   %esi
  800198:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800199:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80019c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8001a2:	e8 b7 0a 00 00       	call   800c5e <sys_getenvid>
  8001a7:	83 ec 0c             	sub    $0xc,%esp
  8001aa:	ff 75 0c             	pushl  0xc(%ebp)
  8001ad:	ff 75 08             	pushl  0x8(%ebp)
  8001b0:	56                   	push   %esi
  8001b1:	50                   	push   %eax
  8001b2:	68 38 25 80 00       	push   $0x802538
  8001b7:	e8 b1 00 00 00       	call   80026d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001bc:	83 c4 18             	add    $0x18,%esp
  8001bf:	53                   	push   %ebx
  8001c0:	ff 75 10             	pushl  0x10(%ebp)
  8001c3:	e8 54 00 00 00       	call   80021c <vcprintf>
	cprintf("\n");
  8001c8:	c7 04 24 20 2a 80 00 	movl   $0x802a20,(%esp)
  8001cf:	e8 99 00 00 00       	call   80026d <cprintf>
  8001d4:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001d7:	cc                   	int3   
  8001d8:	eb fd                	jmp    8001d7 <_panic+0x43>

008001da <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001da:	55                   	push   %ebp
  8001db:	89 e5                	mov    %esp,%ebp
  8001dd:	53                   	push   %ebx
  8001de:	83 ec 04             	sub    $0x4,%esp
  8001e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001e4:	8b 13                	mov    (%ebx),%edx
  8001e6:	8d 42 01             	lea    0x1(%edx),%eax
  8001e9:	89 03                	mov    %eax,(%ebx)
  8001eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ee:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001f2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001f7:	75 1a                	jne    800213 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001f9:	83 ec 08             	sub    $0x8,%esp
  8001fc:	68 ff 00 00 00       	push   $0xff
  800201:	8d 43 08             	lea    0x8(%ebx),%eax
  800204:	50                   	push   %eax
  800205:	e8 d6 09 00 00       	call   800be0 <sys_cputs>
		b->idx = 0;
  80020a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800210:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800213:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800217:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80021a:	c9                   	leave  
  80021b:	c3                   	ret    

0080021c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800225:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80022c:	00 00 00 
	b.cnt = 0;
  80022f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800236:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800239:	ff 75 0c             	pushl  0xc(%ebp)
  80023c:	ff 75 08             	pushl  0x8(%ebp)
  80023f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800245:	50                   	push   %eax
  800246:	68 da 01 80 00       	push   $0x8001da
  80024b:	e8 1a 01 00 00       	call   80036a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800250:	83 c4 08             	add    $0x8,%esp
  800253:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800259:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80025f:	50                   	push   %eax
  800260:	e8 7b 09 00 00       	call   800be0 <sys_cputs>

	return b.cnt;
}
  800265:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80026b:	c9                   	leave  
  80026c:	c3                   	ret    

0080026d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80026d:	55                   	push   %ebp
  80026e:	89 e5                	mov    %esp,%ebp
  800270:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800273:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800276:	50                   	push   %eax
  800277:	ff 75 08             	pushl  0x8(%ebp)
  80027a:	e8 9d ff ff ff       	call   80021c <vcprintf>
	va_end(ap);

	return cnt;
}
  80027f:	c9                   	leave  
  800280:	c3                   	ret    

00800281 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800281:	55                   	push   %ebp
  800282:	89 e5                	mov    %esp,%ebp
  800284:	57                   	push   %edi
  800285:	56                   	push   %esi
  800286:	53                   	push   %ebx
  800287:	83 ec 1c             	sub    $0x1c,%esp
  80028a:	89 c7                	mov    %eax,%edi
  80028c:	89 d6                	mov    %edx,%esi
  80028e:	8b 45 08             	mov    0x8(%ebp),%eax
  800291:	8b 55 0c             	mov    0xc(%ebp),%edx
  800294:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800297:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80029a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80029d:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002a2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002a5:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002a8:	39 d3                	cmp    %edx,%ebx
  8002aa:	72 05                	jb     8002b1 <printnum+0x30>
  8002ac:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002af:	77 45                	ja     8002f6 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002b1:	83 ec 0c             	sub    $0xc,%esp
  8002b4:	ff 75 18             	pushl  0x18(%ebp)
  8002b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8002ba:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002bd:	53                   	push   %ebx
  8002be:	ff 75 10             	pushl  0x10(%ebp)
  8002c1:	83 ec 08             	sub    $0x8,%esp
  8002c4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002c7:	ff 75 e0             	pushl  -0x20(%ebp)
  8002ca:	ff 75 dc             	pushl  -0x24(%ebp)
  8002cd:	ff 75 d8             	pushl  -0x28(%ebp)
  8002d0:	e8 fb 1e 00 00       	call   8021d0 <__udivdi3>
  8002d5:	83 c4 18             	add    $0x18,%esp
  8002d8:	52                   	push   %edx
  8002d9:	50                   	push   %eax
  8002da:	89 f2                	mov    %esi,%edx
  8002dc:	89 f8                	mov    %edi,%eax
  8002de:	e8 9e ff ff ff       	call   800281 <printnum>
  8002e3:	83 c4 20             	add    $0x20,%esp
  8002e6:	eb 18                	jmp    800300 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002e8:	83 ec 08             	sub    $0x8,%esp
  8002eb:	56                   	push   %esi
  8002ec:	ff 75 18             	pushl  0x18(%ebp)
  8002ef:	ff d7                	call   *%edi
  8002f1:	83 c4 10             	add    $0x10,%esp
  8002f4:	eb 03                	jmp    8002f9 <printnum+0x78>
  8002f6:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002f9:	83 eb 01             	sub    $0x1,%ebx
  8002fc:	85 db                	test   %ebx,%ebx
  8002fe:	7f e8                	jg     8002e8 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800300:	83 ec 08             	sub    $0x8,%esp
  800303:	56                   	push   %esi
  800304:	83 ec 04             	sub    $0x4,%esp
  800307:	ff 75 e4             	pushl  -0x1c(%ebp)
  80030a:	ff 75 e0             	pushl  -0x20(%ebp)
  80030d:	ff 75 dc             	pushl  -0x24(%ebp)
  800310:	ff 75 d8             	pushl  -0x28(%ebp)
  800313:	e8 e8 1f 00 00       	call   802300 <__umoddi3>
  800318:	83 c4 14             	add    $0x14,%esp
  80031b:	0f be 80 5b 25 80 00 	movsbl 0x80255b(%eax),%eax
  800322:	50                   	push   %eax
  800323:	ff d7                	call   *%edi
}
  800325:	83 c4 10             	add    $0x10,%esp
  800328:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80032b:	5b                   	pop    %ebx
  80032c:	5e                   	pop    %esi
  80032d:	5f                   	pop    %edi
  80032e:	5d                   	pop    %ebp
  80032f:	c3                   	ret    

00800330 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800330:	55                   	push   %ebp
  800331:	89 e5                	mov    %esp,%ebp
  800333:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800336:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80033a:	8b 10                	mov    (%eax),%edx
  80033c:	3b 50 04             	cmp    0x4(%eax),%edx
  80033f:	73 0a                	jae    80034b <sprintputch+0x1b>
		*b->buf++ = ch;
  800341:	8d 4a 01             	lea    0x1(%edx),%ecx
  800344:	89 08                	mov    %ecx,(%eax)
  800346:	8b 45 08             	mov    0x8(%ebp),%eax
  800349:	88 02                	mov    %al,(%edx)
}
  80034b:	5d                   	pop    %ebp
  80034c:	c3                   	ret    

0080034d <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80034d:	55                   	push   %ebp
  80034e:	89 e5                	mov    %esp,%ebp
  800350:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800353:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800356:	50                   	push   %eax
  800357:	ff 75 10             	pushl  0x10(%ebp)
  80035a:	ff 75 0c             	pushl  0xc(%ebp)
  80035d:	ff 75 08             	pushl  0x8(%ebp)
  800360:	e8 05 00 00 00       	call   80036a <vprintfmt>
	va_end(ap);
}
  800365:	83 c4 10             	add    $0x10,%esp
  800368:	c9                   	leave  
  800369:	c3                   	ret    

0080036a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80036a:	55                   	push   %ebp
  80036b:	89 e5                	mov    %esp,%ebp
  80036d:	57                   	push   %edi
  80036e:	56                   	push   %esi
  80036f:	53                   	push   %ebx
  800370:	83 ec 2c             	sub    $0x2c,%esp
  800373:	8b 75 08             	mov    0x8(%ebp),%esi
  800376:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800379:	8b 7d 10             	mov    0x10(%ebp),%edi
  80037c:	eb 12                	jmp    800390 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80037e:	85 c0                	test   %eax,%eax
  800380:	0f 84 6a 04 00 00    	je     8007f0 <vprintfmt+0x486>
				return;
			putch(ch, putdat);
  800386:	83 ec 08             	sub    $0x8,%esp
  800389:	53                   	push   %ebx
  80038a:	50                   	push   %eax
  80038b:	ff d6                	call   *%esi
  80038d:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800390:	83 c7 01             	add    $0x1,%edi
  800393:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800397:	83 f8 25             	cmp    $0x25,%eax
  80039a:	75 e2                	jne    80037e <vprintfmt+0x14>
  80039c:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003a0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003a7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003ae:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003b5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003ba:	eb 07                	jmp    8003c3 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003bf:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c3:	8d 47 01             	lea    0x1(%edi),%eax
  8003c6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003c9:	0f b6 07             	movzbl (%edi),%eax
  8003cc:	0f b6 d0             	movzbl %al,%edx
  8003cf:	83 e8 23             	sub    $0x23,%eax
  8003d2:	3c 55                	cmp    $0x55,%al
  8003d4:	0f 87 fb 03 00 00    	ja     8007d5 <vprintfmt+0x46b>
  8003da:	0f b6 c0             	movzbl %al,%eax
  8003dd:	ff 24 85 a0 26 80 00 	jmp    *0x8026a0(,%eax,4)
  8003e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003e7:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003eb:	eb d6                	jmp    8003c3 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8003f5:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003f8:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003fb:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003ff:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800402:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800405:	83 f9 09             	cmp    $0x9,%ecx
  800408:	77 3f                	ja     800449 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80040a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80040d:	eb e9                	jmp    8003f8 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80040f:	8b 45 14             	mov    0x14(%ebp),%eax
  800412:	8b 00                	mov    (%eax),%eax
  800414:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800417:	8b 45 14             	mov    0x14(%ebp),%eax
  80041a:	8d 40 04             	lea    0x4(%eax),%eax
  80041d:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800420:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800423:	eb 2a                	jmp    80044f <vprintfmt+0xe5>
  800425:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800428:	85 c0                	test   %eax,%eax
  80042a:	ba 00 00 00 00       	mov    $0x0,%edx
  80042f:	0f 49 d0             	cmovns %eax,%edx
  800432:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800435:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800438:	eb 89                	jmp    8003c3 <vprintfmt+0x59>
  80043a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80043d:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800444:	e9 7a ff ff ff       	jmp    8003c3 <vprintfmt+0x59>
  800449:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80044c:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80044f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800453:	0f 89 6a ff ff ff    	jns    8003c3 <vprintfmt+0x59>
				width = precision, precision = -1;
  800459:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80045c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80045f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800466:	e9 58 ff ff ff       	jmp    8003c3 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80046b:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800471:	e9 4d ff ff ff       	jmp    8003c3 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800476:	8b 45 14             	mov    0x14(%ebp),%eax
  800479:	8d 78 04             	lea    0x4(%eax),%edi
  80047c:	83 ec 08             	sub    $0x8,%esp
  80047f:	53                   	push   %ebx
  800480:	ff 30                	pushl  (%eax)
  800482:	ff d6                	call   *%esi
			break;
  800484:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800487:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80048d:	e9 fe fe ff ff       	jmp    800390 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800492:	8b 45 14             	mov    0x14(%ebp),%eax
  800495:	8d 78 04             	lea    0x4(%eax),%edi
  800498:	8b 00                	mov    (%eax),%eax
  80049a:	99                   	cltd   
  80049b:	31 d0                	xor    %edx,%eax
  80049d:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80049f:	83 f8 0f             	cmp    $0xf,%eax
  8004a2:	7f 0b                	jg     8004af <vprintfmt+0x145>
  8004a4:	8b 14 85 00 28 80 00 	mov    0x802800(,%eax,4),%edx
  8004ab:	85 d2                	test   %edx,%edx
  8004ad:	75 1b                	jne    8004ca <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  8004af:	50                   	push   %eax
  8004b0:	68 73 25 80 00       	push   $0x802573
  8004b5:	53                   	push   %ebx
  8004b6:	56                   	push   %esi
  8004b7:	e8 91 fe ff ff       	call   80034d <printfmt>
  8004bc:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004bf:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004c5:	e9 c6 fe ff ff       	jmp    800390 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004ca:	52                   	push   %edx
  8004cb:	68 5a 29 80 00       	push   $0x80295a
  8004d0:	53                   	push   %ebx
  8004d1:	56                   	push   %esi
  8004d2:	e8 76 fe ff ff       	call   80034d <printfmt>
  8004d7:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004da:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004dd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004e0:	e9 ab fe ff ff       	jmp    800390 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e8:	83 c0 04             	add    $0x4,%eax
  8004eb:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8004ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f1:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004f3:	85 ff                	test   %edi,%edi
  8004f5:	b8 6c 25 80 00       	mov    $0x80256c,%eax
  8004fa:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004fd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800501:	0f 8e 94 00 00 00    	jle    80059b <vprintfmt+0x231>
  800507:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80050b:	0f 84 98 00 00 00    	je     8005a9 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800511:	83 ec 08             	sub    $0x8,%esp
  800514:	ff 75 d0             	pushl  -0x30(%ebp)
  800517:	57                   	push   %edi
  800518:	e8 5b 03 00 00       	call   800878 <strnlen>
  80051d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800520:	29 c1                	sub    %eax,%ecx
  800522:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800525:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800528:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80052c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80052f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800532:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800534:	eb 0f                	jmp    800545 <vprintfmt+0x1db>
					putch(padc, putdat);
  800536:	83 ec 08             	sub    $0x8,%esp
  800539:	53                   	push   %ebx
  80053a:	ff 75 e0             	pushl  -0x20(%ebp)
  80053d:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80053f:	83 ef 01             	sub    $0x1,%edi
  800542:	83 c4 10             	add    $0x10,%esp
  800545:	85 ff                	test   %edi,%edi
  800547:	7f ed                	jg     800536 <vprintfmt+0x1cc>
  800549:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80054c:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80054f:	85 c9                	test   %ecx,%ecx
  800551:	b8 00 00 00 00       	mov    $0x0,%eax
  800556:	0f 49 c1             	cmovns %ecx,%eax
  800559:	29 c1                	sub    %eax,%ecx
  80055b:	89 75 08             	mov    %esi,0x8(%ebp)
  80055e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800561:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800564:	89 cb                	mov    %ecx,%ebx
  800566:	eb 4d                	jmp    8005b5 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800568:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80056c:	74 1b                	je     800589 <vprintfmt+0x21f>
  80056e:	0f be c0             	movsbl %al,%eax
  800571:	83 e8 20             	sub    $0x20,%eax
  800574:	83 f8 5e             	cmp    $0x5e,%eax
  800577:	76 10                	jbe    800589 <vprintfmt+0x21f>
					putch('?', putdat);
  800579:	83 ec 08             	sub    $0x8,%esp
  80057c:	ff 75 0c             	pushl  0xc(%ebp)
  80057f:	6a 3f                	push   $0x3f
  800581:	ff 55 08             	call   *0x8(%ebp)
  800584:	83 c4 10             	add    $0x10,%esp
  800587:	eb 0d                	jmp    800596 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  800589:	83 ec 08             	sub    $0x8,%esp
  80058c:	ff 75 0c             	pushl  0xc(%ebp)
  80058f:	52                   	push   %edx
  800590:	ff 55 08             	call   *0x8(%ebp)
  800593:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800596:	83 eb 01             	sub    $0x1,%ebx
  800599:	eb 1a                	jmp    8005b5 <vprintfmt+0x24b>
  80059b:	89 75 08             	mov    %esi,0x8(%ebp)
  80059e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005a1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005a4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005a7:	eb 0c                	jmp    8005b5 <vprintfmt+0x24b>
  8005a9:	89 75 08             	mov    %esi,0x8(%ebp)
  8005ac:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005af:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005b2:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005b5:	83 c7 01             	add    $0x1,%edi
  8005b8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005bc:	0f be d0             	movsbl %al,%edx
  8005bf:	85 d2                	test   %edx,%edx
  8005c1:	74 23                	je     8005e6 <vprintfmt+0x27c>
  8005c3:	85 f6                	test   %esi,%esi
  8005c5:	78 a1                	js     800568 <vprintfmt+0x1fe>
  8005c7:	83 ee 01             	sub    $0x1,%esi
  8005ca:	79 9c                	jns    800568 <vprintfmt+0x1fe>
  8005cc:	89 df                	mov    %ebx,%edi
  8005ce:	8b 75 08             	mov    0x8(%ebp),%esi
  8005d1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005d4:	eb 18                	jmp    8005ee <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005d6:	83 ec 08             	sub    $0x8,%esp
  8005d9:	53                   	push   %ebx
  8005da:	6a 20                	push   $0x20
  8005dc:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005de:	83 ef 01             	sub    $0x1,%edi
  8005e1:	83 c4 10             	add    $0x10,%esp
  8005e4:	eb 08                	jmp    8005ee <vprintfmt+0x284>
  8005e6:	89 df                	mov    %ebx,%edi
  8005e8:	8b 75 08             	mov    0x8(%ebp),%esi
  8005eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005ee:	85 ff                	test   %edi,%edi
  8005f0:	7f e4                	jg     8005d6 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005f2:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8005f5:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005fb:	e9 90 fd ff ff       	jmp    800390 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800600:	83 f9 01             	cmp    $0x1,%ecx
  800603:	7e 19                	jle    80061e <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800605:	8b 45 14             	mov    0x14(%ebp),%eax
  800608:	8b 50 04             	mov    0x4(%eax),%edx
  80060b:	8b 00                	mov    (%eax),%eax
  80060d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800610:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800613:	8b 45 14             	mov    0x14(%ebp),%eax
  800616:	8d 40 08             	lea    0x8(%eax),%eax
  800619:	89 45 14             	mov    %eax,0x14(%ebp)
  80061c:	eb 38                	jmp    800656 <vprintfmt+0x2ec>
	else if (lflag)
  80061e:	85 c9                	test   %ecx,%ecx
  800620:	74 1b                	je     80063d <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800622:	8b 45 14             	mov    0x14(%ebp),%eax
  800625:	8b 00                	mov    (%eax),%eax
  800627:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80062a:	89 c1                	mov    %eax,%ecx
  80062c:	c1 f9 1f             	sar    $0x1f,%ecx
  80062f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800632:	8b 45 14             	mov    0x14(%ebp),%eax
  800635:	8d 40 04             	lea    0x4(%eax),%eax
  800638:	89 45 14             	mov    %eax,0x14(%ebp)
  80063b:	eb 19                	jmp    800656 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  80063d:	8b 45 14             	mov    0x14(%ebp),%eax
  800640:	8b 00                	mov    (%eax),%eax
  800642:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800645:	89 c1                	mov    %eax,%ecx
  800647:	c1 f9 1f             	sar    $0x1f,%ecx
  80064a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80064d:	8b 45 14             	mov    0x14(%ebp),%eax
  800650:	8d 40 04             	lea    0x4(%eax),%eax
  800653:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800656:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800659:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80065c:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800661:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800665:	0f 89 36 01 00 00    	jns    8007a1 <vprintfmt+0x437>
				putch('-', putdat);
  80066b:	83 ec 08             	sub    $0x8,%esp
  80066e:	53                   	push   %ebx
  80066f:	6a 2d                	push   $0x2d
  800671:	ff d6                	call   *%esi
				num = -(long long) num;
  800673:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800676:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800679:	f7 da                	neg    %edx
  80067b:	83 d1 00             	adc    $0x0,%ecx
  80067e:	f7 d9                	neg    %ecx
  800680:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800683:	b8 0a 00 00 00       	mov    $0xa,%eax
  800688:	e9 14 01 00 00       	jmp    8007a1 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80068d:	83 f9 01             	cmp    $0x1,%ecx
  800690:	7e 18                	jle    8006aa <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800692:	8b 45 14             	mov    0x14(%ebp),%eax
  800695:	8b 10                	mov    (%eax),%edx
  800697:	8b 48 04             	mov    0x4(%eax),%ecx
  80069a:	8d 40 08             	lea    0x8(%eax),%eax
  80069d:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8006a0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006a5:	e9 f7 00 00 00       	jmp    8007a1 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8006aa:	85 c9                	test   %ecx,%ecx
  8006ac:	74 1a                	je     8006c8 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  8006ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b1:	8b 10                	mov    (%eax),%edx
  8006b3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006b8:	8d 40 04             	lea    0x4(%eax),%eax
  8006bb:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8006be:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006c3:	e9 d9 00 00 00       	jmp    8007a1 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8006c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cb:	8b 10                	mov    (%eax),%edx
  8006cd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006d2:	8d 40 04             	lea    0x4(%eax),%eax
  8006d5:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8006d8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006dd:	e9 bf 00 00 00       	jmp    8007a1 <vprintfmt+0x437>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006e2:	83 f9 01             	cmp    $0x1,%ecx
  8006e5:	7e 13                	jle    8006fa <vprintfmt+0x390>
		return va_arg(*ap, long long);
  8006e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ea:	8b 50 04             	mov    0x4(%eax),%edx
  8006ed:	8b 00                	mov    (%eax),%eax
  8006ef:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8006f2:	8d 49 08             	lea    0x8(%ecx),%ecx
  8006f5:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006f8:	eb 28                	jmp    800722 <vprintfmt+0x3b8>
	else if (lflag)
  8006fa:	85 c9                	test   %ecx,%ecx
  8006fc:	74 13                	je     800711 <vprintfmt+0x3a7>
		return va_arg(*ap, long);
  8006fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800701:	8b 10                	mov    (%eax),%edx
  800703:	89 d0                	mov    %edx,%eax
  800705:	99                   	cltd   
  800706:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800709:	8d 49 04             	lea    0x4(%ecx),%ecx
  80070c:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80070f:	eb 11                	jmp    800722 <vprintfmt+0x3b8>
	else
		return va_arg(*ap, int);
  800711:	8b 45 14             	mov    0x14(%ebp),%eax
  800714:	8b 10                	mov    (%eax),%edx
  800716:	89 d0                	mov    %edx,%eax
  800718:	99                   	cltd   
  800719:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80071c:	8d 49 04             	lea    0x4(%ecx),%ecx
  80071f:	89 4d 14             	mov    %ecx,0x14(%ebp)
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getint(&ap, lflag);
  800722:	89 d1                	mov    %edx,%ecx
  800724:	89 c2                	mov    %eax,%edx
			base = 8;
  800726:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  80072b:	eb 74                	jmp    8007a1 <vprintfmt+0x437>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80072d:	83 ec 08             	sub    $0x8,%esp
  800730:	53                   	push   %ebx
  800731:	6a 30                	push   $0x30
  800733:	ff d6                	call   *%esi
			putch('x', putdat);
  800735:	83 c4 08             	add    $0x8,%esp
  800738:	53                   	push   %ebx
  800739:	6a 78                	push   $0x78
  80073b:	ff d6                	call   *%esi
			num = (unsigned long long)
  80073d:	8b 45 14             	mov    0x14(%ebp),%eax
  800740:	8b 10                	mov    (%eax),%edx
  800742:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800747:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80074a:	8d 40 04             	lea    0x4(%eax),%eax
  80074d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800750:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800755:	eb 4a                	jmp    8007a1 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800757:	83 f9 01             	cmp    $0x1,%ecx
  80075a:	7e 15                	jle    800771 <vprintfmt+0x407>
		return va_arg(*ap, unsigned long long);
  80075c:	8b 45 14             	mov    0x14(%ebp),%eax
  80075f:	8b 10                	mov    (%eax),%edx
  800761:	8b 48 04             	mov    0x4(%eax),%ecx
  800764:	8d 40 08             	lea    0x8(%eax),%eax
  800767:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80076a:	b8 10 00 00 00       	mov    $0x10,%eax
  80076f:	eb 30                	jmp    8007a1 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800771:	85 c9                	test   %ecx,%ecx
  800773:	74 17                	je     80078c <vprintfmt+0x422>
		return va_arg(*ap, unsigned long);
  800775:	8b 45 14             	mov    0x14(%ebp),%eax
  800778:	8b 10                	mov    (%eax),%edx
  80077a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80077f:	8d 40 04             	lea    0x4(%eax),%eax
  800782:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800785:	b8 10 00 00 00       	mov    $0x10,%eax
  80078a:	eb 15                	jmp    8007a1 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80078c:	8b 45 14             	mov    0x14(%ebp),%eax
  80078f:	8b 10                	mov    (%eax),%edx
  800791:	b9 00 00 00 00       	mov    $0x0,%ecx
  800796:	8d 40 04             	lea    0x4(%eax),%eax
  800799:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80079c:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007a1:	83 ec 0c             	sub    $0xc,%esp
  8007a4:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8007a8:	57                   	push   %edi
  8007a9:	ff 75 e0             	pushl  -0x20(%ebp)
  8007ac:	50                   	push   %eax
  8007ad:	51                   	push   %ecx
  8007ae:	52                   	push   %edx
  8007af:	89 da                	mov    %ebx,%edx
  8007b1:	89 f0                	mov    %esi,%eax
  8007b3:	e8 c9 fa ff ff       	call   800281 <printnum>
			break;
  8007b8:	83 c4 20             	add    $0x20,%esp
  8007bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007be:	e9 cd fb ff ff       	jmp    800390 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007c3:	83 ec 08             	sub    $0x8,%esp
  8007c6:	53                   	push   %ebx
  8007c7:	52                   	push   %edx
  8007c8:	ff d6                	call   *%esi
			break;
  8007ca:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007d0:	e9 bb fb ff ff       	jmp    800390 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007d5:	83 ec 08             	sub    $0x8,%esp
  8007d8:	53                   	push   %ebx
  8007d9:	6a 25                	push   $0x25
  8007db:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007dd:	83 c4 10             	add    $0x10,%esp
  8007e0:	eb 03                	jmp    8007e5 <vprintfmt+0x47b>
  8007e2:	83 ef 01             	sub    $0x1,%edi
  8007e5:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007e9:	75 f7                	jne    8007e2 <vprintfmt+0x478>
  8007eb:	e9 a0 fb ff ff       	jmp    800390 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007f3:	5b                   	pop    %ebx
  8007f4:	5e                   	pop    %esi
  8007f5:	5f                   	pop    %edi
  8007f6:	5d                   	pop    %ebp
  8007f7:	c3                   	ret    

008007f8 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007f8:	55                   	push   %ebp
  8007f9:	89 e5                	mov    %esp,%ebp
  8007fb:	83 ec 18             	sub    $0x18,%esp
  8007fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800801:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800804:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800807:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80080b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80080e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800815:	85 c0                	test   %eax,%eax
  800817:	74 26                	je     80083f <vsnprintf+0x47>
  800819:	85 d2                	test   %edx,%edx
  80081b:	7e 22                	jle    80083f <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80081d:	ff 75 14             	pushl  0x14(%ebp)
  800820:	ff 75 10             	pushl  0x10(%ebp)
  800823:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800826:	50                   	push   %eax
  800827:	68 30 03 80 00       	push   $0x800330
  80082c:	e8 39 fb ff ff       	call   80036a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800831:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800834:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800837:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80083a:	83 c4 10             	add    $0x10,%esp
  80083d:	eb 05                	jmp    800844 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80083f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800844:	c9                   	leave  
  800845:	c3                   	ret    

00800846 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800846:	55                   	push   %ebp
  800847:	89 e5                	mov    %esp,%ebp
  800849:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80084c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80084f:	50                   	push   %eax
  800850:	ff 75 10             	pushl  0x10(%ebp)
  800853:	ff 75 0c             	pushl  0xc(%ebp)
  800856:	ff 75 08             	pushl  0x8(%ebp)
  800859:	e8 9a ff ff ff       	call   8007f8 <vsnprintf>
	va_end(ap);

	return rc;
}
  80085e:	c9                   	leave  
  80085f:	c3                   	ret    

00800860 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800860:	55                   	push   %ebp
  800861:	89 e5                	mov    %esp,%ebp
  800863:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800866:	b8 00 00 00 00       	mov    $0x0,%eax
  80086b:	eb 03                	jmp    800870 <strlen+0x10>
		n++;
  80086d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800870:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800874:	75 f7                	jne    80086d <strlen+0xd>
		n++;
	return n;
}
  800876:	5d                   	pop    %ebp
  800877:	c3                   	ret    

00800878 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800878:	55                   	push   %ebp
  800879:	89 e5                	mov    %esp,%ebp
  80087b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80087e:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800881:	ba 00 00 00 00       	mov    $0x0,%edx
  800886:	eb 03                	jmp    80088b <strnlen+0x13>
		n++;
  800888:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80088b:	39 c2                	cmp    %eax,%edx
  80088d:	74 08                	je     800897 <strnlen+0x1f>
  80088f:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800893:	75 f3                	jne    800888 <strnlen+0x10>
  800895:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800897:	5d                   	pop    %ebp
  800898:	c3                   	ret    

00800899 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800899:	55                   	push   %ebp
  80089a:	89 e5                	mov    %esp,%ebp
  80089c:	53                   	push   %ebx
  80089d:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008a3:	89 c2                	mov    %eax,%edx
  8008a5:	83 c2 01             	add    $0x1,%edx
  8008a8:	83 c1 01             	add    $0x1,%ecx
  8008ab:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008af:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008b2:	84 db                	test   %bl,%bl
  8008b4:	75 ef                	jne    8008a5 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008b6:	5b                   	pop    %ebx
  8008b7:	5d                   	pop    %ebp
  8008b8:	c3                   	ret    

008008b9 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008b9:	55                   	push   %ebp
  8008ba:	89 e5                	mov    %esp,%ebp
  8008bc:	53                   	push   %ebx
  8008bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008c0:	53                   	push   %ebx
  8008c1:	e8 9a ff ff ff       	call   800860 <strlen>
  8008c6:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008c9:	ff 75 0c             	pushl  0xc(%ebp)
  8008cc:	01 d8                	add    %ebx,%eax
  8008ce:	50                   	push   %eax
  8008cf:	e8 c5 ff ff ff       	call   800899 <strcpy>
	return dst;
}
  8008d4:	89 d8                	mov    %ebx,%eax
  8008d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008d9:	c9                   	leave  
  8008da:	c3                   	ret    

008008db <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008db:	55                   	push   %ebp
  8008dc:	89 e5                	mov    %esp,%ebp
  8008de:	56                   	push   %esi
  8008df:	53                   	push   %ebx
  8008e0:	8b 75 08             	mov    0x8(%ebp),%esi
  8008e3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008e6:	89 f3                	mov    %esi,%ebx
  8008e8:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008eb:	89 f2                	mov    %esi,%edx
  8008ed:	eb 0f                	jmp    8008fe <strncpy+0x23>
		*dst++ = *src;
  8008ef:	83 c2 01             	add    $0x1,%edx
  8008f2:	0f b6 01             	movzbl (%ecx),%eax
  8008f5:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008f8:	80 39 01             	cmpb   $0x1,(%ecx)
  8008fb:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008fe:	39 da                	cmp    %ebx,%edx
  800900:	75 ed                	jne    8008ef <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800902:	89 f0                	mov    %esi,%eax
  800904:	5b                   	pop    %ebx
  800905:	5e                   	pop    %esi
  800906:	5d                   	pop    %ebp
  800907:	c3                   	ret    

00800908 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800908:	55                   	push   %ebp
  800909:	89 e5                	mov    %esp,%ebp
  80090b:	56                   	push   %esi
  80090c:	53                   	push   %ebx
  80090d:	8b 75 08             	mov    0x8(%ebp),%esi
  800910:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800913:	8b 55 10             	mov    0x10(%ebp),%edx
  800916:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800918:	85 d2                	test   %edx,%edx
  80091a:	74 21                	je     80093d <strlcpy+0x35>
  80091c:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800920:	89 f2                	mov    %esi,%edx
  800922:	eb 09                	jmp    80092d <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800924:	83 c2 01             	add    $0x1,%edx
  800927:	83 c1 01             	add    $0x1,%ecx
  80092a:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80092d:	39 c2                	cmp    %eax,%edx
  80092f:	74 09                	je     80093a <strlcpy+0x32>
  800931:	0f b6 19             	movzbl (%ecx),%ebx
  800934:	84 db                	test   %bl,%bl
  800936:	75 ec                	jne    800924 <strlcpy+0x1c>
  800938:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80093a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80093d:	29 f0                	sub    %esi,%eax
}
  80093f:	5b                   	pop    %ebx
  800940:	5e                   	pop    %esi
  800941:	5d                   	pop    %ebp
  800942:	c3                   	ret    

00800943 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800943:	55                   	push   %ebp
  800944:	89 e5                	mov    %esp,%ebp
  800946:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800949:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80094c:	eb 06                	jmp    800954 <strcmp+0x11>
		p++, q++;
  80094e:	83 c1 01             	add    $0x1,%ecx
  800951:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800954:	0f b6 01             	movzbl (%ecx),%eax
  800957:	84 c0                	test   %al,%al
  800959:	74 04                	je     80095f <strcmp+0x1c>
  80095b:	3a 02                	cmp    (%edx),%al
  80095d:	74 ef                	je     80094e <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80095f:	0f b6 c0             	movzbl %al,%eax
  800962:	0f b6 12             	movzbl (%edx),%edx
  800965:	29 d0                	sub    %edx,%eax
}
  800967:	5d                   	pop    %ebp
  800968:	c3                   	ret    

00800969 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800969:	55                   	push   %ebp
  80096a:	89 e5                	mov    %esp,%ebp
  80096c:	53                   	push   %ebx
  80096d:	8b 45 08             	mov    0x8(%ebp),%eax
  800970:	8b 55 0c             	mov    0xc(%ebp),%edx
  800973:	89 c3                	mov    %eax,%ebx
  800975:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800978:	eb 06                	jmp    800980 <strncmp+0x17>
		n--, p++, q++;
  80097a:	83 c0 01             	add    $0x1,%eax
  80097d:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800980:	39 d8                	cmp    %ebx,%eax
  800982:	74 15                	je     800999 <strncmp+0x30>
  800984:	0f b6 08             	movzbl (%eax),%ecx
  800987:	84 c9                	test   %cl,%cl
  800989:	74 04                	je     80098f <strncmp+0x26>
  80098b:	3a 0a                	cmp    (%edx),%cl
  80098d:	74 eb                	je     80097a <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80098f:	0f b6 00             	movzbl (%eax),%eax
  800992:	0f b6 12             	movzbl (%edx),%edx
  800995:	29 d0                	sub    %edx,%eax
  800997:	eb 05                	jmp    80099e <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800999:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80099e:	5b                   	pop    %ebx
  80099f:	5d                   	pop    %ebp
  8009a0:	c3                   	ret    

008009a1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009a1:	55                   	push   %ebp
  8009a2:	89 e5                	mov    %esp,%ebp
  8009a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009ab:	eb 07                	jmp    8009b4 <strchr+0x13>
		if (*s == c)
  8009ad:	38 ca                	cmp    %cl,%dl
  8009af:	74 0f                	je     8009c0 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009b1:	83 c0 01             	add    $0x1,%eax
  8009b4:	0f b6 10             	movzbl (%eax),%edx
  8009b7:	84 d2                	test   %dl,%dl
  8009b9:	75 f2                	jne    8009ad <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009bb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009c0:	5d                   	pop    %ebp
  8009c1:	c3                   	ret    

008009c2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009c2:	55                   	push   %ebp
  8009c3:	89 e5                	mov    %esp,%ebp
  8009c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009cc:	eb 03                	jmp    8009d1 <strfind+0xf>
  8009ce:	83 c0 01             	add    $0x1,%eax
  8009d1:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009d4:	38 ca                	cmp    %cl,%dl
  8009d6:	74 04                	je     8009dc <strfind+0x1a>
  8009d8:	84 d2                	test   %dl,%dl
  8009da:	75 f2                	jne    8009ce <strfind+0xc>
			break;
	return (char *) s;
}
  8009dc:	5d                   	pop    %ebp
  8009dd:	c3                   	ret    

008009de <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009de:	55                   	push   %ebp
  8009df:	89 e5                	mov    %esp,%ebp
  8009e1:	57                   	push   %edi
  8009e2:	56                   	push   %esi
  8009e3:	53                   	push   %ebx
  8009e4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009e7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009ea:	85 c9                	test   %ecx,%ecx
  8009ec:	74 36                	je     800a24 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009ee:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009f4:	75 28                	jne    800a1e <memset+0x40>
  8009f6:	f6 c1 03             	test   $0x3,%cl
  8009f9:	75 23                	jne    800a1e <memset+0x40>
		c &= 0xFF;
  8009fb:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009ff:	89 d3                	mov    %edx,%ebx
  800a01:	c1 e3 08             	shl    $0x8,%ebx
  800a04:	89 d6                	mov    %edx,%esi
  800a06:	c1 e6 18             	shl    $0x18,%esi
  800a09:	89 d0                	mov    %edx,%eax
  800a0b:	c1 e0 10             	shl    $0x10,%eax
  800a0e:	09 f0                	or     %esi,%eax
  800a10:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a12:	89 d8                	mov    %ebx,%eax
  800a14:	09 d0                	or     %edx,%eax
  800a16:	c1 e9 02             	shr    $0x2,%ecx
  800a19:	fc                   	cld    
  800a1a:	f3 ab                	rep stos %eax,%es:(%edi)
  800a1c:	eb 06                	jmp    800a24 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a1e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a21:	fc                   	cld    
  800a22:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a24:	89 f8                	mov    %edi,%eax
  800a26:	5b                   	pop    %ebx
  800a27:	5e                   	pop    %esi
  800a28:	5f                   	pop    %edi
  800a29:	5d                   	pop    %ebp
  800a2a:	c3                   	ret    

00800a2b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a2b:	55                   	push   %ebp
  800a2c:	89 e5                	mov    %esp,%ebp
  800a2e:	57                   	push   %edi
  800a2f:	56                   	push   %esi
  800a30:	8b 45 08             	mov    0x8(%ebp),%eax
  800a33:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a36:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a39:	39 c6                	cmp    %eax,%esi
  800a3b:	73 35                	jae    800a72 <memmove+0x47>
  800a3d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a40:	39 d0                	cmp    %edx,%eax
  800a42:	73 2e                	jae    800a72 <memmove+0x47>
		s += n;
		d += n;
  800a44:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a47:	89 d6                	mov    %edx,%esi
  800a49:	09 fe                	or     %edi,%esi
  800a4b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a51:	75 13                	jne    800a66 <memmove+0x3b>
  800a53:	f6 c1 03             	test   $0x3,%cl
  800a56:	75 0e                	jne    800a66 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a58:	83 ef 04             	sub    $0x4,%edi
  800a5b:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a5e:	c1 e9 02             	shr    $0x2,%ecx
  800a61:	fd                   	std    
  800a62:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a64:	eb 09                	jmp    800a6f <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a66:	83 ef 01             	sub    $0x1,%edi
  800a69:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a6c:	fd                   	std    
  800a6d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a6f:	fc                   	cld    
  800a70:	eb 1d                	jmp    800a8f <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a72:	89 f2                	mov    %esi,%edx
  800a74:	09 c2                	or     %eax,%edx
  800a76:	f6 c2 03             	test   $0x3,%dl
  800a79:	75 0f                	jne    800a8a <memmove+0x5f>
  800a7b:	f6 c1 03             	test   $0x3,%cl
  800a7e:	75 0a                	jne    800a8a <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a80:	c1 e9 02             	shr    $0x2,%ecx
  800a83:	89 c7                	mov    %eax,%edi
  800a85:	fc                   	cld    
  800a86:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a88:	eb 05                	jmp    800a8f <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a8a:	89 c7                	mov    %eax,%edi
  800a8c:	fc                   	cld    
  800a8d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a8f:	5e                   	pop    %esi
  800a90:	5f                   	pop    %edi
  800a91:	5d                   	pop    %ebp
  800a92:	c3                   	ret    

00800a93 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a93:	55                   	push   %ebp
  800a94:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a96:	ff 75 10             	pushl  0x10(%ebp)
  800a99:	ff 75 0c             	pushl  0xc(%ebp)
  800a9c:	ff 75 08             	pushl  0x8(%ebp)
  800a9f:	e8 87 ff ff ff       	call   800a2b <memmove>
}
  800aa4:	c9                   	leave  
  800aa5:	c3                   	ret    

00800aa6 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800aa6:	55                   	push   %ebp
  800aa7:	89 e5                	mov    %esp,%ebp
  800aa9:	56                   	push   %esi
  800aaa:	53                   	push   %ebx
  800aab:	8b 45 08             	mov    0x8(%ebp),%eax
  800aae:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ab1:	89 c6                	mov    %eax,%esi
  800ab3:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ab6:	eb 1a                	jmp    800ad2 <memcmp+0x2c>
		if (*s1 != *s2)
  800ab8:	0f b6 08             	movzbl (%eax),%ecx
  800abb:	0f b6 1a             	movzbl (%edx),%ebx
  800abe:	38 d9                	cmp    %bl,%cl
  800ac0:	74 0a                	je     800acc <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800ac2:	0f b6 c1             	movzbl %cl,%eax
  800ac5:	0f b6 db             	movzbl %bl,%ebx
  800ac8:	29 d8                	sub    %ebx,%eax
  800aca:	eb 0f                	jmp    800adb <memcmp+0x35>
		s1++, s2++;
  800acc:	83 c0 01             	add    $0x1,%eax
  800acf:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ad2:	39 f0                	cmp    %esi,%eax
  800ad4:	75 e2                	jne    800ab8 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ad6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800adb:	5b                   	pop    %ebx
  800adc:	5e                   	pop    %esi
  800add:	5d                   	pop    %ebp
  800ade:	c3                   	ret    

00800adf <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800adf:	55                   	push   %ebp
  800ae0:	89 e5                	mov    %esp,%ebp
  800ae2:	53                   	push   %ebx
  800ae3:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ae6:	89 c1                	mov    %eax,%ecx
  800ae8:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800aeb:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800aef:	eb 0a                	jmp    800afb <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800af1:	0f b6 10             	movzbl (%eax),%edx
  800af4:	39 da                	cmp    %ebx,%edx
  800af6:	74 07                	je     800aff <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800af8:	83 c0 01             	add    $0x1,%eax
  800afb:	39 c8                	cmp    %ecx,%eax
  800afd:	72 f2                	jb     800af1 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800aff:	5b                   	pop    %ebx
  800b00:	5d                   	pop    %ebp
  800b01:	c3                   	ret    

00800b02 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b02:	55                   	push   %ebp
  800b03:	89 e5                	mov    %esp,%ebp
  800b05:	57                   	push   %edi
  800b06:	56                   	push   %esi
  800b07:	53                   	push   %ebx
  800b08:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b0b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b0e:	eb 03                	jmp    800b13 <strtol+0x11>
		s++;
  800b10:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b13:	0f b6 01             	movzbl (%ecx),%eax
  800b16:	3c 20                	cmp    $0x20,%al
  800b18:	74 f6                	je     800b10 <strtol+0xe>
  800b1a:	3c 09                	cmp    $0x9,%al
  800b1c:	74 f2                	je     800b10 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b1e:	3c 2b                	cmp    $0x2b,%al
  800b20:	75 0a                	jne    800b2c <strtol+0x2a>
		s++;
  800b22:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b25:	bf 00 00 00 00       	mov    $0x0,%edi
  800b2a:	eb 11                	jmp    800b3d <strtol+0x3b>
  800b2c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b31:	3c 2d                	cmp    $0x2d,%al
  800b33:	75 08                	jne    800b3d <strtol+0x3b>
		s++, neg = 1;
  800b35:	83 c1 01             	add    $0x1,%ecx
  800b38:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b3d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b43:	75 15                	jne    800b5a <strtol+0x58>
  800b45:	80 39 30             	cmpb   $0x30,(%ecx)
  800b48:	75 10                	jne    800b5a <strtol+0x58>
  800b4a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b4e:	75 7c                	jne    800bcc <strtol+0xca>
		s += 2, base = 16;
  800b50:	83 c1 02             	add    $0x2,%ecx
  800b53:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b58:	eb 16                	jmp    800b70 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b5a:	85 db                	test   %ebx,%ebx
  800b5c:	75 12                	jne    800b70 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b5e:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b63:	80 39 30             	cmpb   $0x30,(%ecx)
  800b66:	75 08                	jne    800b70 <strtol+0x6e>
		s++, base = 8;
  800b68:	83 c1 01             	add    $0x1,%ecx
  800b6b:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b70:	b8 00 00 00 00       	mov    $0x0,%eax
  800b75:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b78:	0f b6 11             	movzbl (%ecx),%edx
  800b7b:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b7e:	89 f3                	mov    %esi,%ebx
  800b80:	80 fb 09             	cmp    $0x9,%bl
  800b83:	77 08                	ja     800b8d <strtol+0x8b>
			dig = *s - '0';
  800b85:	0f be d2             	movsbl %dl,%edx
  800b88:	83 ea 30             	sub    $0x30,%edx
  800b8b:	eb 22                	jmp    800baf <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b8d:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b90:	89 f3                	mov    %esi,%ebx
  800b92:	80 fb 19             	cmp    $0x19,%bl
  800b95:	77 08                	ja     800b9f <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b97:	0f be d2             	movsbl %dl,%edx
  800b9a:	83 ea 57             	sub    $0x57,%edx
  800b9d:	eb 10                	jmp    800baf <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b9f:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ba2:	89 f3                	mov    %esi,%ebx
  800ba4:	80 fb 19             	cmp    $0x19,%bl
  800ba7:	77 16                	ja     800bbf <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ba9:	0f be d2             	movsbl %dl,%edx
  800bac:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800baf:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bb2:	7d 0b                	jge    800bbf <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800bb4:	83 c1 01             	add    $0x1,%ecx
  800bb7:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bbb:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800bbd:	eb b9                	jmp    800b78 <strtol+0x76>

	if (endptr)
  800bbf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bc3:	74 0d                	je     800bd2 <strtol+0xd0>
		*endptr = (char *) s;
  800bc5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bc8:	89 0e                	mov    %ecx,(%esi)
  800bca:	eb 06                	jmp    800bd2 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bcc:	85 db                	test   %ebx,%ebx
  800bce:	74 98                	je     800b68 <strtol+0x66>
  800bd0:	eb 9e                	jmp    800b70 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800bd2:	89 c2                	mov    %eax,%edx
  800bd4:	f7 da                	neg    %edx
  800bd6:	85 ff                	test   %edi,%edi
  800bd8:	0f 45 c2             	cmovne %edx,%eax
}
  800bdb:	5b                   	pop    %ebx
  800bdc:	5e                   	pop    %esi
  800bdd:	5f                   	pop    %edi
  800bde:	5d                   	pop    %ebp
  800bdf:	c3                   	ret    

00800be0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800be0:	55                   	push   %ebp
  800be1:	89 e5                	mov    %esp,%ebp
  800be3:	57                   	push   %edi
  800be4:	56                   	push   %esi
  800be5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be6:	b8 00 00 00 00       	mov    $0x0,%eax
  800beb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bee:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf1:	89 c3                	mov    %eax,%ebx
  800bf3:	89 c7                	mov    %eax,%edi
  800bf5:	89 c6                	mov    %eax,%esi
  800bf7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bf9:	5b                   	pop    %ebx
  800bfa:	5e                   	pop    %esi
  800bfb:	5f                   	pop    %edi
  800bfc:	5d                   	pop    %ebp
  800bfd:	c3                   	ret    

00800bfe <sys_cgetc>:

int
sys_cgetc(void)
{
  800bfe:	55                   	push   %ebp
  800bff:	89 e5                	mov    %esp,%ebp
  800c01:	57                   	push   %edi
  800c02:	56                   	push   %esi
  800c03:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c04:	ba 00 00 00 00       	mov    $0x0,%edx
  800c09:	b8 01 00 00 00       	mov    $0x1,%eax
  800c0e:	89 d1                	mov    %edx,%ecx
  800c10:	89 d3                	mov    %edx,%ebx
  800c12:	89 d7                	mov    %edx,%edi
  800c14:	89 d6                	mov    %edx,%esi
  800c16:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c18:	5b                   	pop    %ebx
  800c19:	5e                   	pop    %esi
  800c1a:	5f                   	pop    %edi
  800c1b:	5d                   	pop    %ebp
  800c1c:	c3                   	ret    

00800c1d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c1d:	55                   	push   %ebp
  800c1e:	89 e5                	mov    %esp,%ebp
  800c20:	57                   	push   %edi
  800c21:	56                   	push   %esi
  800c22:	53                   	push   %ebx
  800c23:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c26:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c2b:	b8 03 00 00 00       	mov    $0x3,%eax
  800c30:	8b 55 08             	mov    0x8(%ebp),%edx
  800c33:	89 cb                	mov    %ecx,%ebx
  800c35:	89 cf                	mov    %ecx,%edi
  800c37:	89 ce                	mov    %ecx,%esi
  800c39:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c3b:	85 c0                	test   %eax,%eax
  800c3d:	7e 17                	jle    800c56 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3f:	83 ec 0c             	sub    $0xc,%esp
  800c42:	50                   	push   %eax
  800c43:	6a 03                	push   $0x3
  800c45:	68 5f 28 80 00       	push   $0x80285f
  800c4a:	6a 23                	push   $0x23
  800c4c:	68 7c 28 80 00       	push   $0x80287c
  800c51:	e8 3e f5 ff ff       	call   800194 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c59:	5b                   	pop    %ebx
  800c5a:	5e                   	pop    %esi
  800c5b:	5f                   	pop    %edi
  800c5c:	5d                   	pop    %ebp
  800c5d:	c3                   	ret    

00800c5e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c5e:	55                   	push   %ebp
  800c5f:	89 e5                	mov    %esp,%ebp
  800c61:	57                   	push   %edi
  800c62:	56                   	push   %esi
  800c63:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c64:	ba 00 00 00 00       	mov    $0x0,%edx
  800c69:	b8 02 00 00 00       	mov    $0x2,%eax
  800c6e:	89 d1                	mov    %edx,%ecx
  800c70:	89 d3                	mov    %edx,%ebx
  800c72:	89 d7                	mov    %edx,%edi
  800c74:	89 d6                	mov    %edx,%esi
  800c76:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c78:	5b                   	pop    %ebx
  800c79:	5e                   	pop    %esi
  800c7a:	5f                   	pop    %edi
  800c7b:	5d                   	pop    %ebp
  800c7c:	c3                   	ret    

00800c7d <sys_yield>:

void
sys_yield(void)
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
  800c88:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c8d:	89 d1                	mov    %edx,%ecx
  800c8f:	89 d3                	mov    %edx,%ebx
  800c91:	89 d7                	mov    %edx,%edi
  800c93:	89 d6                	mov    %edx,%esi
  800c95:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c97:	5b                   	pop    %ebx
  800c98:	5e                   	pop    %esi
  800c99:	5f                   	pop    %edi
  800c9a:	5d                   	pop    %ebp
  800c9b:	c3                   	ret    

00800c9c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c9c:	55                   	push   %ebp
  800c9d:	89 e5                	mov    %esp,%ebp
  800c9f:	57                   	push   %edi
  800ca0:	56                   	push   %esi
  800ca1:	53                   	push   %ebx
  800ca2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca5:	be 00 00 00 00       	mov    $0x0,%esi
  800caa:	b8 04 00 00 00       	mov    $0x4,%eax
  800caf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cb8:	89 f7                	mov    %esi,%edi
  800cba:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cbc:	85 c0                	test   %eax,%eax
  800cbe:	7e 17                	jle    800cd7 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc0:	83 ec 0c             	sub    $0xc,%esp
  800cc3:	50                   	push   %eax
  800cc4:	6a 04                	push   $0x4
  800cc6:	68 5f 28 80 00       	push   $0x80285f
  800ccb:	6a 23                	push   $0x23
  800ccd:	68 7c 28 80 00       	push   $0x80287c
  800cd2:	e8 bd f4 ff ff       	call   800194 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cd7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cda:	5b                   	pop    %ebx
  800cdb:	5e                   	pop    %esi
  800cdc:	5f                   	pop    %edi
  800cdd:	5d                   	pop    %ebp
  800cde:	c3                   	ret    

00800cdf <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cdf:	55                   	push   %ebp
  800ce0:	89 e5                	mov    %esp,%ebp
  800ce2:	57                   	push   %edi
  800ce3:	56                   	push   %esi
  800ce4:	53                   	push   %ebx
  800ce5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce8:	b8 05 00 00 00       	mov    $0x5,%eax
  800ced:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cf6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cf9:	8b 75 18             	mov    0x18(%ebp),%esi
  800cfc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cfe:	85 c0                	test   %eax,%eax
  800d00:	7e 17                	jle    800d19 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d02:	83 ec 0c             	sub    $0xc,%esp
  800d05:	50                   	push   %eax
  800d06:	6a 05                	push   $0x5
  800d08:	68 5f 28 80 00       	push   $0x80285f
  800d0d:	6a 23                	push   $0x23
  800d0f:	68 7c 28 80 00       	push   $0x80287c
  800d14:	e8 7b f4 ff ff       	call   800194 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d19:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1c:	5b                   	pop    %ebx
  800d1d:	5e                   	pop    %esi
  800d1e:	5f                   	pop    %edi
  800d1f:	5d                   	pop    %ebp
  800d20:	c3                   	ret    

00800d21 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d21:	55                   	push   %ebp
  800d22:	89 e5                	mov    %esp,%ebp
  800d24:	57                   	push   %edi
  800d25:	56                   	push   %esi
  800d26:	53                   	push   %ebx
  800d27:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d2f:	b8 06 00 00 00       	mov    $0x6,%eax
  800d34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d37:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3a:	89 df                	mov    %ebx,%edi
  800d3c:	89 de                	mov    %ebx,%esi
  800d3e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d40:	85 c0                	test   %eax,%eax
  800d42:	7e 17                	jle    800d5b <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d44:	83 ec 0c             	sub    $0xc,%esp
  800d47:	50                   	push   %eax
  800d48:	6a 06                	push   $0x6
  800d4a:	68 5f 28 80 00       	push   $0x80285f
  800d4f:	6a 23                	push   $0x23
  800d51:	68 7c 28 80 00       	push   $0x80287c
  800d56:	e8 39 f4 ff ff       	call   800194 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d5b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d5e:	5b                   	pop    %ebx
  800d5f:	5e                   	pop    %esi
  800d60:	5f                   	pop    %edi
  800d61:	5d                   	pop    %ebp
  800d62:	c3                   	ret    

00800d63 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d63:	55                   	push   %ebp
  800d64:	89 e5                	mov    %esp,%ebp
  800d66:	57                   	push   %edi
  800d67:	56                   	push   %esi
  800d68:	53                   	push   %ebx
  800d69:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d71:	b8 08 00 00 00       	mov    $0x8,%eax
  800d76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d79:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7c:	89 df                	mov    %ebx,%edi
  800d7e:	89 de                	mov    %ebx,%esi
  800d80:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d82:	85 c0                	test   %eax,%eax
  800d84:	7e 17                	jle    800d9d <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d86:	83 ec 0c             	sub    $0xc,%esp
  800d89:	50                   	push   %eax
  800d8a:	6a 08                	push   $0x8
  800d8c:	68 5f 28 80 00       	push   $0x80285f
  800d91:	6a 23                	push   $0x23
  800d93:	68 7c 28 80 00       	push   $0x80287c
  800d98:	e8 f7 f3 ff ff       	call   800194 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d9d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da0:	5b                   	pop    %ebx
  800da1:	5e                   	pop    %esi
  800da2:	5f                   	pop    %edi
  800da3:	5d                   	pop    %ebp
  800da4:	c3                   	ret    

00800da5 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800da5:	55                   	push   %ebp
  800da6:	89 e5                	mov    %esp,%ebp
  800da8:	57                   	push   %edi
  800da9:	56                   	push   %esi
  800daa:	53                   	push   %ebx
  800dab:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dae:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db3:	b8 09 00 00 00       	mov    $0x9,%eax
  800db8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dbb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbe:	89 df                	mov    %ebx,%edi
  800dc0:	89 de                	mov    %ebx,%esi
  800dc2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dc4:	85 c0                	test   %eax,%eax
  800dc6:	7e 17                	jle    800ddf <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc8:	83 ec 0c             	sub    $0xc,%esp
  800dcb:	50                   	push   %eax
  800dcc:	6a 09                	push   $0x9
  800dce:	68 5f 28 80 00       	push   $0x80285f
  800dd3:	6a 23                	push   $0x23
  800dd5:	68 7c 28 80 00       	push   $0x80287c
  800dda:	e8 b5 f3 ff ff       	call   800194 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ddf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de2:	5b                   	pop    %ebx
  800de3:	5e                   	pop    %esi
  800de4:	5f                   	pop    %edi
  800de5:	5d                   	pop    %ebp
  800de6:	c3                   	ret    

00800de7 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800de7:	55                   	push   %ebp
  800de8:	89 e5                	mov    %esp,%ebp
  800dea:	57                   	push   %edi
  800deb:	56                   	push   %esi
  800dec:	53                   	push   %ebx
  800ded:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800df5:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dfa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dfd:	8b 55 08             	mov    0x8(%ebp),%edx
  800e00:	89 df                	mov    %ebx,%edi
  800e02:	89 de                	mov    %ebx,%esi
  800e04:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e06:	85 c0                	test   %eax,%eax
  800e08:	7e 17                	jle    800e21 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e0a:	83 ec 0c             	sub    $0xc,%esp
  800e0d:	50                   	push   %eax
  800e0e:	6a 0a                	push   $0xa
  800e10:	68 5f 28 80 00       	push   $0x80285f
  800e15:	6a 23                	push   $0x23
  800e17:	68 7c 28 80 00       	push   $0x80287c
  800e1c:	e8 73 f3 ff ff       	call   800194 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e21:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e24:	5b                   	pop    %ebx
  800e25:	5e                   	pop    %esi
  800e26:	5f                   	pop    %edi
  800e27:	5d                   	pop    %ebp
  800e28:	c3                   	ret    

00800e29 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e29:	55                   	push   %ebp
  800e2a:	89 e5                	mov    %esp,%ebp
  800e2c:	57                   	push   %edi
  800e2d:	56                   	push   %esi
  800e2e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2f:	be 00 00 00 00       	mov    $0x0,%esi
  800e34:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e39:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e42:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e45:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e47:	5b                   	pop    %ebx
  800e48:	5e                   	pop    %esi
  800e49:	5f                   	pop    %edi
  800e4a:	5d                   	pop    %ebp
  800e4b:	c3                   	ret    

00800e4c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e4c:	55                   	push   %ebp
  800e4d:	89 e5                	mov    %esp,%ebp
  800e4f:	57                   	push   %edi
  800e50:	56                   	push   %esi
  800e51:	53                   	push   %ebx
  800e52:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e55:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e5a:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e5f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e62:	89 cb                	mov    %ecx,%ebx
  800e64:	89 cf                	mov    %ecx,%edi
  800e66:	89 ce                	mov    %ecx,%esi
  800e68:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e6a:	85 c0                	test   %eax,%eax
  800e6c:	7e 17                	jle    800e85 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e6e:	83 ec 0c             	sub    $0xc,%esp
  800e71:	50                   	push   %eax
  800e72:	6a 0d                	push   $0xd
  800e74:	68 5f 28 80 00       	push   $0x80285f
  800e79:	6a 23                	push   $0x23
  800e7b:	68 7c 28 80 00       	push   $0x80287c
  800e80:	e8 0f f3 ff ff       	call   800194 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e85:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e88:	5b                   	pop    %ebx
  800e89:	5e                   	pop    %esi
  800e8a:	5f                   	pop    %edi
  800e8b:	5d                   	pop    %ebp
  800e8c:	c3                   	ret    

00800e8d <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e8d:	55                   	push   %ebp
  800e8e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e90:	8b 45 08             	mov    0x8(%ebp),%eax
  800e93:	05 00 00 00 30       	add    $0x30000000,%eax
  800e98:	c1 e8 0c             	shr    $0xc,%eax
}
  800e9b:	5d                   	pop    %ebp
  800e9c:	c3                   	ret    

00800e9d <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e9d:	55                   	push   %ebp
  800e9e:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800ea0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea3:	05 00 00 00 30       	add    $0x30000000,%eax
  800ea8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800ead:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800eb2:	5d                   	pop    %ebp
  800eb3:	c3                   	ret    

00800eb4 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800eb4:	55                   	push   %ebp
  800eb5:	89 e5                	mov    %esp,%ebp
  800eb7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eba:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800ebf:	89 c2                	mov    %eax,%edx
  800ec1:	c1 ea 16             	shr    $0x16,%edx
  800ec4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ecb:	f6 c2 01             	test   $0x1,%dl
  800ece:	74 11                	je     800ee1 <fd_alloc+0x2d>
  800ed0:	89 c2                	mov    %eax,%edx
  800ed2:	c1 ea 0c             	shr    $0xc,%edx
  800ed5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800edc:	f6 c2 01             	test   $0x1,%dl
  800edf:	75 09                	jne    800eea <fd_alloc+0x36>
			*fd_store = fd;
  800ee1:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ee3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee8:	eb 17                	jmp    800f01 <fd_alloc+0x4d>
  800eea:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800eef:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800ef4:	75 c9                	jne    800ebf <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800ef6:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800efc:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f01:	5d                   	pop    %ebp
  800f02:	c3                   	ret    

00800f03 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f03:	55                   	push   %ebp
  800f04:	89 e5                	mov    %esp,%ebp
  800f06:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f09:	83 f8 1f             	cmp    $0x1f,%eax
  800f0c:	77 36                	ja     800f44 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f0e:	c1 e0 0c             	shl    $0xc,%eax
  800f11:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f16:	89 c2                	mov    %eax,%edx
  800f18:	c1 ea 16             	shr    $0x16,%edx
  800f1b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f22:	f6 c2 01             	test   $0x1,%dl
  800f25:	74 24                	je     800f4b <fd_lookup+0x48>
  800f27:	89 c2                	mov    %eax,%edx
  800f29:	c1 ea 0c             	shr    $0xc,%edx
  800f2c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f33:	f6 c2 01             	test   $0x1,%dl
  800f36:	74 1a                	je     800f52 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f38:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f3b:	89 02                	mov    %eax,(%edx)
	return 0;
  800f3d:	b8 00 00 00 00       	mov    $0x0,%eax
  800f42:	eb 13                	jmp    800f57 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f44:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f49:	eb 0c                	jmp    800f57 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f4b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f50:	eb 05                	jmp    800f57 <fd_lookup+0x54>
  800f52:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f57:	5d                   	pop    %ebp
  800f58:	c3                   	ret    

00800f59 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f59:	55                   	push   %ebp
  800f5a:	89 e5                	mov    %esp,%ebp
  800f5c:	83 ec 08             	sub    $0x8,%esp
  800f5f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f62:	ba 08 29 80 00       	mov    $0x802908,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f67:	eb 13                	jmp    800f7c <dev_lookup+0x23>
  800f69:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f6c:	39 08                	cmp    %ecx,(%eax)
  800f6e:	75 0c                	jne    800f7c <dev_lookup+0x23>
			*dev = devtab[i];
  800f70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f73:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f75:	b8 00 00 00 00       	mov    $0x0,%eax
  800f7a:	eb 2e                	jmp    800faa <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f7c:	8b 02                	mov    (%edx),%eax
  800f7e:	85 c0                	test   %eax,%eax
  800f80:	75 e7                	jne    800f69 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f82:	a1 04 40 80 00       	mov    0x804004,%eax
  800f87:	8b 40 48             	mov    0x48(%eax),%eax
  800f8a:	83 ec 04             	sub    $0x4,%esp
  800f8d:	51                   	push   %ecx
  800f8e:	50                   	push   %eax
  800f8f:	68 8c 28 80 00       	push   $0x80288c
  800f94:	e8 d4 f2 ff ff       	call   80026d <cprintf>
	*dev = 0;
  800f99:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f9c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800fa2:	83 c4 10             	add    $0x10,%esp
  800fa5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800faa:	c9                   	leave  
  800fab:	c3                   	ret    

00800fac <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800fac:	55                   	push   %ebp
  800fad:	89 e5                	mov    %esp,%ebp
  800faf:	56                   	push   %esi
  800fb0:	53                   	push   %ebx
  800fb1:	83 ec 10             	sub    $0x10,%esp
  800fb4:	8b 75 08             	mov    0x8(%ebp),%esi
  800fb7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fbd:	50                   	push   %eax
  800fbe:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800fc4:	c1 e8 0c             	shr    $0xc,%eax
  800fc7:	50                   	push   %eax
  800fc8:	e8 36 ff ff ff       	call   800f03 <fd_lookup>
  800fcd:	83 c4 08             	add    $0x8,%esp
  800fd0:	85 c0                	test   %eax,%eax
  800fd2:	78 05                	js     800fd9 <fd_close+0x2d>
	    || fd != fd2)
  800fd4:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800fd7:	74 0c                	je     800fe5 <fd_close+0x39>
		return (must_exist ? r : 0);
  800fd9:	84 db                	test   %bl,%bl
  800fdb:	ba 00 00 00 00       	mov    $0x0,%edx
  800fe0:	0f 44 c2             	cmove  %edx,%eax
  800fe3:	eb 41                	jmp    801026 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800fe5:	83 ec 08             	sub    $0x8,%esp
  800fe8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800feb:	50                   	push   %eax
  800fec:	ff 36                	pushl  (%esi)
  800fee:	e8 66 ff ff ff       	call   800f59 <dev_lookup>
  800ff3:	89 c3                	mov    %eax,%ebx
  800ff5:	83 c4 10             	add    $0x10,%esp
  800ff8:	85 c0                	test   %eax,%eax
  800ffa:	78 1a                	js     801016 <fd_close+0x6a>
		if (dev->dev_close)
  800ffc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fff:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801002:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801007:	85 c0                	test   %eax,%eax
  801009:	74 0b                	je     801016 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80100b:	83 ec 0c             	sub    $0xc,%esp
  80100e:	56                   	push   %esi
  80100f:	ff d0                	call   *%eax
  801011:	89 c3                	mov    %eax,%ebx
  801013:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801016:	83 ec 08             	sub    $0x8,%esp
  801019:	56                   	push   %esi
  80101a:	6a 00                	push   $0x0
  80101c:	e8 00 fd ff ff       	call   800d21 <sys_page_unmap>
	return r;
  801021:	83 c4 10             	add    $0x10,%esp
  801024:	89 d8                	mov    %ebx,%eax
}
  801026:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801029:	5b                   	pop    %ebx
  80102a:	5e                   	pop    %esi
  80102b:	5d                   	pop    %ebp
  80102c:	c3                   	ret    

0080102d <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80102d:	55                   	push   %ebp
  80102e:	89 e5                	mov    %esp,%ebp
  801030:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801033:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801036:	50                   	push   %eax
  801037:	ff 75 08             	pushl  0x8(%ebp)
  80103a:	e8 c4 fe ff ff       	call   800f03 <fd_lookup>
  80103f:	83 c4 08             	add    $0x8,%esp
  801042:	85 c0                	test   %eax,%eax
  801044:	78 10                	js     801056 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801046:	83 ec 08             	sub    $0x8,%esp
  801049:	6a 01                	push   $0x1
  80104b:	ff 75 f4             	pushl  -0xc(%ebp)
  80104e:	e8 59 ff ff ff       	call   800fac <fd_close>
  801053:	83 c4 10             	add    $0x10,%esp
}
  801056:	c9                   	leave  
  801057:	c3                   	ret    

00801058 <close_all>:

void
close_all(void)
{
  801058:	55                   	push   %ebp
  801059:	89 e5                	mov    %esp,%ebp
  80105b:	53                   	push   %ebx
  80105c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80105f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801064:	83 ec 0c             	sub    $0xc,%esp
  801067:	53                   	push   %ebx
  801068:	e8 c0 ff ff ff       	call   80102d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80106d:	83 c3 01             	add    $0x1,%ebx
  801070:	83 c4 10             	add    $0x10,%esp
  801073:	83 fb 20             	cmp    $0x20,%ebx
  801076:	75 ec                	jne    801064 <close_all+0xc>
		close(i);
}
  801078:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80107b:	c9                   	leave  
  80107c:	c3                   	ret    

0080107d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80107d:	55                   	push   %ebp
  80107e:	89 e5                	mov    %esp,%ebp
  801080:	57                   	push   %edi
  801081:	56                   	push   %esi
  801082:	53                   	push   %ebx
  801083:	83 ec 2c             	sub    $0x2c,%esp
  801086:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801089:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80108c:	50                   	push   %eax
  80108d:	ff 75 08             	pushl  0x8(%ebp)
  801090:	e8 6e fe ff ff       	call   800f03 <fd_lookup>
  801095:	83 c4 08             	add    $0x8,%esp
  801098:	85 c0                	test   %eax,%eax
  80109a:	0f 88 c1 00 00 00    	js     801161 <dup+0xe4>
		return r;
	close(newfdnum);
  8010a0:	83 ec 0c             	sub    $0xc,%esp
  8010a3:	56                   	push   %esi
  8010a4:	e8 84 ff ff ff       	call   80102d <close>

	newfd = INDEX2FD(newfdnum);
  8010a9:	89 f3                	mov    %esi,%ebx
  8010ab:	c1 e3 0c             	shl    $0xc,%ebx
  8010ae:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8010b4:	83 c4 04             	add    $0x4,%esp
  8010b7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010ba:	e8 de fd ff ff       	call   800e9d <fd2data>
  8010bf:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8010c1:	89 1c 24             	mov    %ebx,(%esp)
  8010c4:	e8 d4 fd ff ff       	call   800e9d <fd2data>
  8010c9:	83 c4 10             	add    $0x10,%esp
  8010cc:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010cf:	89 f8                	mov    %edi,%eax
  8010d1:	c1 e8 16             	shr    $0x16,%eax
  8010d4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010db:	a8 01                	test   $0x1,%al
  8010dd:	74 37                	je     801116 <dup+0x99>
  8010df:	89 f8                	mov    %edi,%eax
  8010e1:	c1 e8 0c             	shr    $0xc,%eax
  8010e4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010eb:	f6 c2 01             	test   $0x1,%dl
  8010ee:	74 26                	je     801116 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010f0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010f7:	83 ec 0c             	sub    $0xc,%esp
  8010fa:	25 07 0e 00 00       	and    $0xe07,%eax
  8010ff:	50                   	push   %eax
  801100:	ff 75 d4             	pushl  -0x2c(%ebp)
  801103:	6a 00                	push   $0x0
  801105:	57                   	push   %edi
  801106:	6a 00                	push   $0x0
  801108:	e8 d2 fb ff ff       	call   800cdf <sys_page_map>
  80110d:	89 c7                	mov    %eax,%edi
  80110f:	83 c4 20             	add    $0x20,%esp
  801112:	85 c0                	test   %eax,%eax
  801114:	78 2e                	js     801144 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801116:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801119:	89 d0                	mov    %edx,%eax
  80111b:	c1 e8 0c             	shr    $0xc,%eax
  80111e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801125:	83 ec 0c             	sub    $0xc,%esp
  801128:	25 07 0e 00 00       	and    $0xe07,%eax
  80112d:	50                   	push   %eax
  80112e:	53                   	push   %ebx
  80112f:	6a 00                	push   $0x0
  801131:	52                   	push   %edx
  801132:	6a 00                	push   $0x0
  801134:	e8 a6 fb ff ff       	call   800cdf <sys_page_map>
  801139:	89 c7                	mov    %eax,%edi
  80113b:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80113e:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801140:	85 ff                	test   %edi,%edi
  801142:	79 1d                	jns    801161 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801144:	83 ec 08             	sub    $0x8,%esp
  801147:	53                   	push   %ebx
  801148:	6a 00                	push   $0x0
  80114a:	e8 d2 fb ff ff       	call   800d21 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80114f:	83 c4 08             	add    $0x8,%esp
  801152:	ff 75 d4             	pushl  -0x2c(%ebp)
  801155:	6a 00                	push   $0x0
  801157:	e8 c5 fb ff ff       	call   800d21 <sys_page_unmap>
	return r;
  80115c:	83 c4 10             	add    $0x10,%esp
  80115f:	89 f8                	mov    %edi,%eax
}
  801161:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801164:	5b                   	pop    %ebx
  801165:	5e                   	pop    %esi
  801166:	5f                   	pop    %edi
  801167:	5d                   	pop    %ebp
  801168:	c3                   	ret    

00801169 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801169:	55                   	push   %ebp
  80116a:	89 e5                	mov    %esp,%ebp
  80116c:	53                   	push   %ebx
  80116d:	83 ec 14             	sub    $0x14,%esp
  801170:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801173:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801176:	50                   	push   %eax
  801177:	53                   	push   %ebx
  801178:	e8 86 fd ff ff       	call   800f03 <fd_lookup>
  80117d:	83 c4 08             	add    $0x8,%esp
  801180:	89 c2                	mov    %eax,%edx
  801182:	85 c0                	test   %eax,%eax
  801184:	78 6d                	js     8011f3 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801186:	83 ec 08             	sub    $0x8,%esp
  801189:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80118c:	50                   	push   %eax
  80118d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801190:	ff 30                	pushl  (%eax)
  801192:	e8 c2 fd ff ff       	call   800f59 <dev_lookup>
  801197:	83 c4 10             	add    $0x10,%esp
  80119a:	85 c0                	test   %eax,%eax
  80119c:	78 4c                	js     8011ea <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80119e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011a1:	8b 42 08             	mov    0x8(%edx),%eax
  8011a4:	83 e0 03             	and    $0x3,%eax
  8011a7:	83 f8 01             	cmp    $0x1,%eax
  8011aa:	75 21                	jne    8011cd <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011ac:	a1 04 40 80 00       	mov    0x804004,%eax
  8011b1:	8b 40 48             	mov    0x48(%eax),%eax
  8011b4:	83 ec 04             	sub    $0x4,%esp
  8011b7:	53                   	push   %ebx
  8011b8:	50                   	push   %eax
  8011b9:	68 cd 28 80 00       	push   $0x8028cd
  8011be:	e8 aa f0 ff ff       	call   80026d <cprintf>
		return -E_INVAL;
  8011c3:	83 c4 10             	add    $0x10,%esp
  8011c6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011cb:	eb 26                	jmp    8011f3 <read+0x8a>
	}
	if (!dev->dev_read)
  8011cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011d0:	8b 40 08             	mov    0x8(%eax),%eax
  8011d3:	85 c0                	test   %eax,%eax
  8011d5:	74 17                	je     8011ee <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011d7:	83 ec 04             	sub    $0x4,%esp
  8011da:	ff 75 10             	pushl  0x10(%ebp)
  8011dd:	ff 75 0c             	pushl  0xc(%ebp)
  8011e0:	52                   	push   %edx
  8011e1:	ff d0                	call   *%eax
  8011e3:	89 c2                	mov    %eax,%edx
  8011e5:	83 c4 10             	add    $0x10,%esp
  8011e8:	eb 09                	jmp    8011f3 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011ea:	89 c2                	mov    %eax,%edx
  8011ec:	eb 05                	jmp    8011f3 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8011ee:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8011f3:	89 d0                	mov    %edx,%eax
  8011f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011f8:	c9                   	leave  
  8011f9:	c3                   	ret    

008011fa <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011fa:	55                   	push   %ebp
  8011fb:	89 e5                	mov    %esp,%ebp
  8011fd:	57                   	push   %edi
  8011fe:	56                   	push   %esi
  8011ff:	53                   	push   %ebx
  801200:	83 ec 0c             	sub    $0xc,%esp
  801203:	8b 7d 08             	mov    0x8(%ebp),%edi
  801206:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801209:	bb 00 00 00 00       	mov    $0x0,%ebx
  80120e:	eb 21                	jmp    801231 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801210:	83 ec 04             	sub    $0x4,%esp
  801213:	89 f0                	mov    %esi,%eax
  801215:	29 d8                	sub    %ebx,%eax
  801217:	50                   	push   %eax
  801218:	89 d8                	mov    %ebx,%eax
  80121a:	03 45 0c             	add    0xc(%ebp),%eax
  80121d:	50                   	push   %eax
  80121e:	57                   	push   %edi
  80121f:	e8 45 ff ff ff       	call   801169 <read>
		if (m < 0)
  801224:	83 c4 10             	add    $0x10,%esp
  801227:	85 c0                	test   %eax,%eax
  801229:	78 10                	js     80123b <readn+0x41>
			return m;
		if (m == 0)
  80122b:	85 c0                	test   %eax,%eax
  80122d:	74 0a                	je     801239 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80122f:	01 c3                	add    %eax,%ebx
  801231:	39 f3                	cmp    %esi,%ebx
  801233:	72 db                	jb     801210 <readn+0x16>
  801235:	89 d8                	mov    %ebx,%eax
  801237:	eb 02                	jmp    80123b <readn+0x41>
  801239:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80123b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80123e:	5b                   	pop    %ebx
  80123f:	5e                   	pop    %esi
  801240:	5f                   	pop    %edi
  801241:	5d                   	pop    %ebp
  801242:	c3                   	ret    

00801243 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801243:	55                   	push   %ebp
  801244:	89 e5                	mov    %esp,%ebp
  801246:	53                   	push   %ebx
  801247:	83 ec 14             	sub    $0x14,%esp
  80124a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80124d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801250:	50                   	push   %eax
  801251:	53                   	push   %ebx
  801252:	e8 ac fc ff ff       	call   800f03 <fd_lookup>
  801257:	83 c4 08             	add    $0x8,%esp
  80125a:	89 c2                	mov    %eax,%edx
  80125c:	85 c0                	test   %eax,%eax
  80125e:	78 68                	js     8012c8 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801260:	83 ec 08             	sub    $0x8,%esp
  801263:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801266:	50                   	push   %eax
  801267:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80126a:	ff 30                	pushl  (%eax)
  80126c:	e8 e8 fc ff ff       	call   800f59 <dev_lookup>
  801271:	83 c4 10             	add    $0x10,%esp
  801274:	85 c0                	test   %eax,%eax
  801276:	78 47                	js     8012bf <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801278:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80127b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80127f:	75 21                	jne    8012a2 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801281:	a1 04 40 80 00       	mov    0x804004,%eax
  801286:	8b 40 48             	mov    0x48(%eax),%eax
  801289:	83 ec 04             	sub    $0x4,%esp
  80128c:	53                   	push   %ebx
  80128d:	50                   	push   %eax
  80128e:	68 e9 28 80 00       	push   $0x8028e9
  801293:	e8 d5 ef ff ff       	call   80026d <cprintf>
		return -E_INVAL;
  801298:	83 c4 10             	add    $0x10,%esp
  80129b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012a0:	eb 26                	jmp    8012c8 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012a5:	8b 52 0c             	mov    0xc(%edx),%edx
  8012a8:	85 d2                	test   %edx,%edx
  8012aa:	74 17                	je     8012c3 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012ac:	83 ec 04             	sub    $0x4,%esp
  8012af:	ff 75 10             	pushl  0x10(%ebp)
  8012b2:	ff 75 0c             	pushl  0xc(%ebp)
  8012b5:	50                   	push   %eax
  8012b6:	ff d2                	call   *%edx
  8012b8:	89 c2                	mov    %eax,%edx
  8012ba:	83 c4 10             	add    $0x10,%esp
  8012bd:	eb 09                	jmp    8012c8 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012bf:	89 c2                	mov    %eax,%edx
  8012c1:	eb 05                	jmp    8012c8 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8012c3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8012c8:	89 d0                	mov    %edx,%eax
  8012ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012cd:	c9                   	leave  
  8012ce:	c3                   	ret    

008012cf <seek>:

int
seek(int fdnum, off_t offset)
{
  8012cf:	55                   	push   %ebp
  8012d0:	89 e5                	mov    %esp,%ebp
  8012d2:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012d5:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012d8:	50                   	push   %eax
  8012d9:	ff 75 08             	pushl  0x8(%ebp)
  8012dc:	e8 22 fc ff ff       	call   800f03 <fd_lookup>
  8012e1:	83 c4 08             	add    $0x8,%esp
  8012e4:	85 c0                	test   %eax,%eax
  8012e6:	78 0e                	js     8012f6 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8012e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012ee:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012f1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012f6:	c9                   	leave  
  8012f7:	c3                   	ret    

008012f8 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012f8:	55                   	push   %ebp
  8012f9:	89 e5                	mov    %esp,%ebp
  8012fb:	53                   	push   %ebx
  8012fc:	83 ec 14             	sub    $0x14,%esp
  8012ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801302:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801305:	50                   	push   %eax
  801306:	53                   	push   %ebx
  801307:	e8 f7 fb ff ff       	call   800f03 <fd_lookup>
  80130c:	83 c4 08             	add    $0x8,%esp
  80130f:	89 c2                	mov    %eax,%edx
  801311:	85 c0                	test   %eax,%eax
  801313:	78 65                	js     80137a <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801315:	83 ec 08             	sub    $0x8,%esp
  801318:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80131b:	50                   	push   %eax
  80131c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80131f:	ff 30                	pushl  (%eax)
  801321:	e8 33 fc ff ff       	call   800f59 <dev_lookup>
  801326:	83 c4 10             	add    $0x10,%esp
  801329:	85 c0                	test   %eax,%eax
  80132b:	78 44                	js     801371 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80132d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801330:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801334:	75 21                	jne    801357 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801336:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80133b:	8b 40 48             	mov    0x48(%eax),%eax
  80133e:	83 ec 04             	sub    $0x4,%esp
  801341:	53                   	push   %ebx
  801342:	50                   	push   %eax
  801343:	68 ac 28 80 00       	push   $0x8028ac
  801348:	e8 20 ef ff ff       	call   80026d <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80134d:	83 c4 10             	add    $0x10,%esp
  801350:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801355:	eb 23                	jmp    80137a <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801357:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80135a:	8b 52 18             	mov    0x18(%edx),%edx
  80135d:	85 d2                	test   %edx,%edx
  80135f:	74 14                	je     801375 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801361:	83 ec 08             	sub    $0x8,%esp
  801364:	ff 75 0c             	pushl  0xc(%ebp)
  801367:	50                   	push   %eax
  801368:	ff d2                	call   *%edx
  80136a:	89 c2                	mov    %eax,%edx
  80136c:	83 c4 10             	add    $0x10,%esp
  80136f:	eb 09                	jmp    80137a <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801371:	89 c2                	mov    %eax,%edx
  801373:	eb 05                	jmp    80137a <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801375:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80137a:	89 d0                	mov    %edx,%eax
  80137c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80137f:	c9                   	leave  
  801380:	c3                   	ret    

00801381 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801381:	55                   	push   %ebp
  801382:	89 e5                	mov    %esp,%ebp
  801384:	53                   	push   %ebx
  801385:	83 ec 14             	sub    $0x14,%esp
  801388:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80138b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80138e:	50                   	push   %eax
  80138f:	ff 75 08             	pushl  0x8(%ebp)
  801392:	e8 6c fb ff ff       	call   800f03 <fd_lookup>
  801397:	83 c4 08             	add    $0x8,%esp
  80139a:	89 c2                	mov    %eax,%edx
  80139c:	85 c0                	test   %eax,%eax
  80139e:	78 58                	js     8013f8 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013a0:	83 ec 08             	sub    $0x8,%esp
  8013a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013a6:	50                   	push   %eax
  8013a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013aa:	ff 30                	pushl  (%eax)
  8013ac:	e8 a8 fb ff ff       	call   800f59 <dev_lookup>
  8013b1:	83 c4 10             	add    $0x10,%esp
  8013b4:	85 c0                	test   %eax,%eax
  8013b6:	78 37                	js     8013ef <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8013b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013bb:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013bf:	74 32                	je     8013f3 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013c1:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013c4:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013cb:	00 00 00 
	stat->st_isdir = 0;
  8013ce:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013d5:	00 00 00 
	stat->st_dev = dev;
  8013d8:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013de:	83 ec 08             	sub    $0x8,%esp
  8013e1:	53                   	push   %ebx
  8013e2:	ff 75 f0             	pushl  -0x10(%ebp)
  8013e5:	ff 50 14             	call   *0x14(%eax)
  8013e8:	89 c2                	mov    %eax,%edx
  8013ea:	83 c4 10             	add    $0x10,%esp
  8013ed:	eb 09                	jmp    8013f8 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013ef:	89 c2                	mov    %eax,%edx
  8013f1:	eb 05                	jmp    8013f8 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8013f3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8013f8:	89 d0                	mov    %edx,%eax
  8013fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013fd:	c9                   	leave  
  8013fe:	c3                   	ret    

008013ff <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013ff:	55                   	push   %ebp
  801400:	89 e5                	mov    %esp,%ebp
  801402:	56                   	push   %esi
  801403:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801404:	83 ec 08             	sub    $0x8,%esp
  801407:	6a 00                	push   $0x0
  801409:	ff 75 08             	pushl  0x8(%ebp)
  80140c:	e8 b7 01 00 00       	call   8015c8 <open>
  801411:	89 c3                	mov    %eax,%ebx
  801413:	83 c4 10             	add    $0x10,%esp
  801416:	85 c0                	test   %eax,%eax
  801418:	78 1b                	js     801435 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80141a:	83 ec 08             	sub    $0x8,%esp
  80141d:	ff 75 0c             	pushl  0xc(%ebp)
  801420:	50                   	push   %eax
  801421:	e8 5b ff ff ff       	call   801381 <fstat>
  801426:	89 c6                	mov    %eax,%esi
	close(fd);
  801428:	89 1c 24             	mov    %ebx,(%esp)
  80142b:	e8 fd fb ff ff       	call   80102d <close>
	return r;
  801430:	83 c4 10             	add    $0x10,%esp
  801433:	89 f0                	mov    %esi,%eax
}
  801435:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801438:	5b                   	pop    %ebx
  801439:	5e                   	pop    %esi
  80143a:	5d                   	pop    %ebp
  80143b:	c3                   	ret    

0080143c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80143c:	55                   	push   %ebp
  80143d:	89 e5                	mov    %esp,%ebp
  80143f:	56                   	push   %esi
  801440:	53                   	push   %ebx
  801441:	89 c6                	mov    %eax,%esi
  801443:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801445:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80144c:	75 12                	jne    801460 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80144e:	83 ec 0c             	sub    $0xc,%esp
  801451:	6a 01                	push   $0x1
  801453:	e8 fc 0c 00 00       	call   802154 <ipc_find_env>
  801458:	a3 00 40 80 00       	mov    %eax,0x804000
  80145d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801460:	6a 07                	push   $0x7
  801462:	68 00 50 80 00       	push   $0x805000
  801467:	56                   	push   %esi
  801468:	ff 35 00 40 80 00    	pushl  0x804000
  80146e:	e8 8d 0c 00 00       	call   802100 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801473:	83 c4 0c             	add    $0xc,%esp
  801476:	6a 00                	push   $0x0
  801478:	53                   	push   %ebx
  801479:	6a 00                	push   $0x0
  80147b:	e8 0b 0c 00 00       	call   80208b <ipc_recv>
}
  801480:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801483:	5b                   	pop    %ebx
  801484:	5e                   	pop    %esi
  801485:	5d                   	pop    %ebp
  801486:	c3                   	ret    

00801487 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801487:	55                   	push   %ebp
  801488:	89 e5                	mov    %esp,%ebp
  80148a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80148d:	8b 45 08             	mov    0x8(%ebp),%eax
  801490:	8b 40 0c             	mov    0xc(%eax),%eax
  801493:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801498:	8b 45 0c             	mov    0xc(%ebp),%eax
  80149b:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8014a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8014a5:	b8 02 00 00 00       	mov    $0x2,%eax
  8014aa:	e8 8d ff ff ff       	call   80143c <fsipc>
}
  8014af:	c9                   	leave  
  8014b0:	c3                   	ret    

008014b1 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8014b1:	55                   	push   %ebp
  8014b2:	89 e5                	mov    %esp,%ebp
  8014b4:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ba:	8b 40 0c             	mov    0xc(%eax),%eax
  8014bd:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8014c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8014c7:	b8 06 00 00 00       	mov    $0x6,%eax
  8014cc:	e8 6b ff ff ff       	call   80143c <fsipc>
}
  8014d1:	c9                   	leave  
  8014d2:	c3                   	ret    

008014d3 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8014d3:	55                   	push   %ebp
  8014d4:	89 e5                	mov    %esp,%ebp
  8014d6:	53                   	push   %ebx
  8014d7:	83 ec 04             	sub    $0x4,%esp
  8014da:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8014e0:	8b 40 0c             	mov    0xc(%eax),%eax
  8014e3:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014e8:	ba 00 00 00 00       	mov    $0x0,%edx
  8014ed:	b8 05 00 00 00       	mov    $0x5,%eax
  8014f2:	e8 45 ff ff ff       	call   80143c <fsipc>
  8014f7:	85 c0                	test   %eax,%eax
  8014f9:	78 2c                	js     801527 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014fb:	83 ec 08             	sub    $0x8,%esp
  8014fe:	68 00 50 80 00       	push   $0x805000
  801503:	53                   	push   %ebx
  801504:	e8 90 f3 ff ff       	call   800899 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801509:	a1 80 50 80 00       	mov    0x805080,%eax
  80150e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801514:	a1 84 50 80 00       	mov    0x805084,%eax
  801519:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80151f:	83 c4 10             	add    $0x10,%esp
  801522:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801527:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80152a:	c9                   	leave  
  80152b:	c3                   	ret    

0080152c <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80152c:	55                   	push   %ebp
  80152d:	89 e5                	mov    %esp,%ebp
  80152f:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801532:	68 18 29 80 00       	push   $0x802918
  801537:	68 90 00 00 00       	push   $0x90
  80153c:	68 36 29 80 00       	push   $0x802936
  801541:	e8 4e ec ff ff       	call   800194 <_panic>

00801546 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801546:	55                   	push   %ebp
  801547:	89 e5                	mov    %esp,%ebp
  801549:	56                   	push   %esi
  80154a:	53                   	push   %ebx
  80154b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80154e:	8b 45 08             	mov    0x8(%ebp),%eax
  801551:	8b 40 0c             	mov    0xc(%eax),%eax
  801554:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801559:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80155f:	ba 00 00 00 00       	mov    $0x0,%edx
  801564:	b8 03 00 00 00       	mov    $0x3,%eax
  801569:	e8 ce fe ff ff       	call   80143c <fsipc>
  80156e:	89 c3                	mov    %eax,%ebx
  801570:	85 c0                	test   %eax,%eax
  801572:	78 4b                	js     8015bf <devfile_read+0x79>
		return r;
	assert(r <= n);
  801574:	39 c6                	cmp    %eax,%esi
  801576:	73 16                	jae    80158e <devfile_read+0x48>
  801578:	68 41 29 80 00       	push   $0x802941
  80157d:	68 48 29 80 00       	push   $0x802948
  801582:	6a 7c                	push   $0x7c
  801584:	68 36 29 80 00       	push   $0x802936
  801589:	e8 06 ec ff ff       	call   800194 <_panic>
	assert(r <= PGSIZE);
  80158e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801593:	7e 16                	jle    8015ab <devfile_read+0x65>
  801595:	68 5d 29 80 00       	push   $0x80295d
  80159a:	68 48 29 80 00       	push   $0x802948
  80159f:	6a 7d                	push   $0x7d
  8015a1:	68 36 29 80 00       	push   $0x802936
  8015a6:	e8 e9 eb ff ff       	call   800194 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8015ab:	83 ec 04             	sub    $0x4,%esp
  8015ae:	50                   	push   %eax
  8015af:	68 00 50 80 00       	push   $0x805000
  8015b4:	ff 75 0c             	pushl  0xc(%ebp)
  8015b7:	e8 6f f4 ff ff       	call   800a2b <memmove>
	return r;
  8015bc:	83 c4 10             	add    $0x10,%esp
}
  8015bf:	89 d8                	mov    %ebx,%eax
  8015c1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015c4:	5b                   	pop    %ebx
  8015c5:	5e                   	pop    %esi
  8015c6:	5d                   	pop    %ebp
  8015c7:	c3                   	ret    

008015c8 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8015c8:	55                   	push   %ebp
  8015c9:	89 e5                	mov    %esp,%ebp
  8015cb:	53                   	push   %ebx
  8015cc:	83 ec 20             	sub    $0x20,%esp
  8015cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015d2:	53                   	push   %ebx
  8015d3:	e8 88 f2 ff ff       	call   800860 <strlen>
  8015d8:	83 c4 10             	add    $0x10,%esp
  8015db:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015e0:	7f 67                	jg     801649 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015e2:	83 ec 0c             	sub    $0xc,%esp
  8015e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015e8:	50                   	push   %eax
  8015e9:	e8 c6 f8 ff ff       	call   800eb4 <fd_alloc>
  8015ee:	83 c4 10             	add    $0x10,%esp
		return r;
  8015f1:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015f3:	85 c0                	test   %eax,%eax
  8015f5:	78 57                	js     80164e <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015f7:	83 ec 08             	sub    $0x8,%esp
  8015fa:	53                   	push   %ebx
  8015fb:	68 00 50 80 00       	push   $0x805000
  801600:	e8 94 f2 ff ff       	call   800899 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801605:	8b 45 0c             	mov    0xc(%ebp),%eax
  801608:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80160d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801610:	b8 01 00 00 00       	mov    $0x1,%eax
  801615:	e8 22 fe ff ff       	call   80143c <fsipc>
  80161a:	89 c3                	mov    %eax,%ebx
  80161c:	83 c4 10             	add    $0x10,%esp
  80161f:	85 c0                	test   %eax,%eax
  801621:	79 14                	jns    801637 <open+0x6f>
		fd_close(fd, 0);
  801623:	83 ec 08             	sub    $0x8,%esp
  801626:	6a 00                	push   $0x0
  801628:	ff 75 f4             	pushl  -0xc(%ebp)
  80162b:	e8 7c f9 ff ff       	call   800fac <fd_close>
		return r;
  801630:	83 c4 10             	add    $0x10,%esp
  801633:	89 da                	mov    %ebx,%edx
  801635:	eb 17                	jmp    80164e <open+0x86>
	}

	return fd2num(fd);
  801637:	83 ec 0c             	sub    $0xc,%esp
  80163a:	ff 75 f4             	pushl  -0xc(%ebp)
  80163d:	e8 4b f8 ff ff       	call   800e8d <fd2num>
  801642:	89 c2                	mov    %eax,%edx
  801644:	83 c4 10             	add    $0x10,%esp
  801647:	eb 05                	jmp    80164e <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801649:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80164e:	89 d0                	mov    %edx,%eax
  801650:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801653:	c9                   	leave  
  801654:	c3                   	ret    

00801655 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801655:	55                   	push   %ebp
  801656:	89 e5                	mov    %esp,%ebp
  801658:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80165b:	ba 00 00 00 00       	mov    $0x0,%edx
  801660:	b8 08 00 00 00       	mov    $0x8,%eax
  801665:	e8 d2 fd ff ff       	call   80143c <fsipc>
}
  80166a:	c9                   	leave  
  80166b:	c3                   	ret    

0080166c <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  80166c:	55                   	push   %ebp
  80166d:	89 e5                	mov    %esp,%ebp
  80166f:	57                   	push   %edi
  801670:	56                   	push   %esi
  801671:	53                   	push   %ebx
  801672:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801678:	6a 00                	push   $0x0
  80167a:	ff 75 08             	pushl  0x8(%ebp)
  80167d:	e8 46 ff ff ff       	call   8015c8 <open>
  801682:	89 c7                	mov    %eax,%edi
  801684:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  80168a:	83 c4 10             	add    $0x10,%esp
  80168d:	85 c0                	test   %eax,%eax
  80168f:	0f 88 3a 04 00 00    	js     801acf <spawn+0x463>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801695:	83 ec 04             	sub    $0x4,%esp
  801698:	68 00 02 00 00       	push   $0x200
  80169d:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8016a3:	50                   	push   %eax
  8016a4:	57                   	push   %edi
  8016a5:	e8 50 fb ff ff       	call   8011fa <readn>
  8016aa:	83 c4 10             	add    $0x10,%esp
  8016ad:	3d 00 02 00 00       	cmp    $0x200,%eax
  8016b2:	75 0c                	jne    8016c0 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  8016b4:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8016bb:	45 4c 46 
  8016be:	74 33                	je     8016f3 <spawn+0x87>
		close(fd);
  8016c0:	83 ec 0c             	sub    $0xc,%esp
  8016c3:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8016c9:	e8 5f f9 ff ff       	call   80102d <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  8016ce:	83 c4 0c             	add    $0xc,%esp
  8016d1:	68 7f 45 4c 46       	push   $0x464c457f
  8016d6:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  8016dc:	68 69 29 80 00       	push   $0x802969
  8016e1:	e8 87 eb ff ff       	call   80026d <cprintf>
		return -E_NOT_EXEC;
  8016e6:	83 c4 10             	add    $0x10,%esp
  8016e9:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  8016ee:	e9 3c 04 00 00       	jmp    801b2f <spawn+0x4c3>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8016f3:	b8 07 00 00 00       	mov    $0x7,%eax
  8016f8:	cd 30                	int    $0x30
  8016fa:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801700:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801706:	85 c0                	test   %eax,%eax
  801708:	0f 88 c9 03 00 00    	js     801ad7 <spawn+0x46b>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  80170e:	89 c6                	mov    %eax,%esi
  801710:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801716:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801719:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  80171f:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801725:	b9 11 00 00 00       	mov    $0x11,%ecx
  80172a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  80172c:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801732:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801738:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  80173d:	be 00 00 00 00       	mov    $0x0,%esi
  801742:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801745:	eb 13                	jmp    80175a <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801747:	83 ec 0c             	sub    $0xc,%esp
  80174a:	50                   	push   %eax
  80174b:	e8 10 f1 ff ff       	call   800860 <strlen>
  801750:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801754:	83 c3 01             	add    $0x1,%ebx
  801757:	83 c4 10             	add    $0x10,%esp
  80175a:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801761:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801764:	85 c0                	test   %eax,%eax
  801766:	75 df                	jne    801747 <spawn+0xdb>
  801768:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  80176e:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801774:	bf 00 10 40 00       	mov    $0x401000,%edi
  801779:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  80177b:	89 fa                	mov    %edi,%edx
  80177d:	83 e2 fc             	and    $0xfffffffc,%edx
  801780:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801787:	29 c2                	sub    %eax,%edx
  801789:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  80178f:	8d 42 f8             	lea    -0x8(%edx),%eax
  801792:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801797:	0f 86 4a 03 00 00    	jbe    801ae7 <spawn+0x47b>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80179d:	83 ec 04             	sub    $0x4,%esp
  8017a0:	6a 07                	push   $0x7
  8017a2:	68 00 00 40 00       	push   $0x400000
  8017a7:	6a 00                	push   $0x0
  8017a9:	e8 ee f4 ff ff       	call   800c9c <sys_page_alloc>
  8017ae:	83 c4 10             	add    $0x10,%esp
  8017b1:	85 c0                	test   %eax,%eax
  8017b3:	0f 88 35 03 00 00    	js     801aee <spawn+0x482>
  8017b9:	be 00 00 00 00       	mov    $0x0,%esi
  8017be:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  8017c4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8017c7:	eb 30                	jmp    8017f9 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  8017c9:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  8017cf:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  8017d5:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  8017d8:	83 ec 08             	sub    $0x8,%esp
  8017db:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8017de:	57                   	push   %edi
  8017df:	e8 b5 f0 ff ff       	call   800899 <strcpy>
		string_store += strlen(argv[i]) + 1;
  8017e4:	83 c4 04             	add    $0x4,%esp
  8017e7:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8017ea:	e8 71 f0 ff ff       	call   800860 <strlen>
  8017ef:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  8017f3:	83 c6 01             	add    $0x1,%esi
  8017f6:	83 c4 10             	add    $0x10,%esp
  8017f9:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  8017ff:	7f c8                	jg     8017c9 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801801:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801807:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  80180d:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801814:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  80181a:	74 19                	je     801835 <spawn+0x1c9>
  80181c:	68 e0 29 80 00       	push   $0x8029e0
  801821:	68 48 29 80 00       	push   $0x802948
  801826:	68 f2 00 00 00       	push   $0xf2
  80182b:	68 83 29 80 00       	push   $0x802983
  801830:	e8 5f e9 ff ff       	call   800194 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801835:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  80183b:	89 c8                	mov    %ecx,%eax
  80183d:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801842:	89 41 fc             	mov    %eax,-0x4(%ecx)
	argv_store[-2] = argc;
  801845:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  80184b:	89 41 f8             	mov    %eax,-0x8(%ecx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  80184e:	8d 81 f8 cf 7f ee    	lea    -0x11803008(%ecx),%eax
  801854:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  80185a:	83 ec 0c             	sub    $0xc,%esp
  80185d:	6a 07                	push   $0x7
  80185f:	68 00 d0 bf ee       	push   $0xeebfd000
  801864:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  80186a:	68 00 00 40 00       	push   $0x400000
  80186f:	6a 00                	push   $0x0
  801871:	e8 69 f4 ff ff       	call   800cdf <sys_page_map>
  801876:	89 c3                	mov    %eax,%ebx
  801878:	83 c4 20             	add    $0x20,%esp
  80187b:	85 c0                	test   %eax,%eax
  80187d:	0f 88 9a 02 00 00    	js     801b1d <spawn+0x4b1>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801883:	83 ec 08             	sub    $0x8,%esp
  801886:	68 00 00 40 00       	push   $0x400000
  80188b:	6a 00                	push   $0x0
  80188d:	e8 8f f4 ff ff       	call   800d21 <sys_page_unmap>
  801892:	89 c3                	mov    %eax,%ebx
  801894:	83 c4 10             	add    $0x10,%esp
  801897:	85 c0                	test   %eax,%eax
  801899:	0f 88 7e 02 00 00    	js     801b1d <spawn+0x4b1>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  80189f:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  8018a5:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  8018ac:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8018b2:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  8018b9:	00 00 00 
  8018bc:	e9 86 01 00 00       	jmp    801a47 <spawn+0x3db>
		if (ph->p_type != ELF_PROG_LOAD)
  8018c1:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  8018c7:	83 38 01             	cmpl   $0x1,(%eax)
  8018ca:	0f 85 69 01 00 00    	jne    801a39 <spawn+0x3cd>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  8018d0:	89 c1                	mov    %eax,%ecx
  8018d2:	8b 40 18             	mov    0x18(%eax),%eax
  8018d5:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  8018db:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  8018de:	83 f8 01             	cmp    $0x1,%eax
  8018e1:	19 c0                	sbb    %eax,%eax
  8018e3:	83 e0 fe             	and    $0xfffffffe,%eax
  8018e6:	83 c0 07             	add    $0x7,%eax
  8018e9:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  8018ef:	89 c8                	mov    %ecx,%eax
  8018f1:	8b 49 04             	mov    0x4(%ecx),%ecx
  8018f4:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
  8018fa:	8b 78 10             	mov    0x10(%eax),%edi
  8018fd:	8b 50 14             	mov    0x14(%eax),%edx
  801900:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  801906:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801909:	89 f0                	mov    %esi,%eax
  80190b:	25 ff 0f 00 00       	and    $0xfff,%eax
  801910:	74 14                	je     801926 <spawn+0x2ba>
		va -= i;
  801912:	29 c6                	sub    %eax,%esi
		memsz += i;
  801914:	01 c2                	add    %eax,%edx
  801916:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  80191c:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  80191e:	29 c1                	sub    %eax,%ecx
  801920:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801926:	bb 00 00 00 00       	mov    $0x0,%ebx
  80192b:	e9 f7 00 00 00       	jmp    801a27 <spawn+0x3bb>
		if (i >= filesz) {
  801930:	39 df                	cmp    %ebx,%edi
  801932:	77 27                	ja     80195b <spawn+0x2ef>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801934:	83 ec 04             	sub    $0x4,%esp
  801937:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  80193d:	56                   	push   %esi
  80193e:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801944:	e8 53 f3 ff ff       	call   800c9c <sys_page_alloc>
  801949:	83 c4 10             	add    $0x10,%esp
  80194c:	85 c0                	test   %eax,%eax
  80194e:	0f 89 c7 00 00 00    	jns    801a1b <spawn+0x3af>
  801954:	89 c3                	mov    %eax,%ebx
  801956:	e9 a1 01 00 00       	jmp    801afc <spawn+0x490>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80195b:	83 ec 04             	sub    $0x4,%esp
  80195e:	6a 07                	push   $0x7
  801960:	68 00 00 40 00       	push   $0x400000
  801965:	6a 00                	push   $0x0
  801967:	e8 30 f3 ff ff       	call   800c9c <sys_page_alloc>
  80196c:	83 c4 10             	add    $0x10,%esp
  80196f:	85 c0                	test   %eax,%eax
  801971:	0f 88 7b 01 00 00    	js     801af2 <spawn+0x486>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801977:	83 ec 08             	sub    $0x8,%esp
  80197a:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801980:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801986:	50                   	push   %eax
  801987:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80198d:	e8 3d f9 ff ff       	call   8012cf <seek>
  801992:	83 c4 10             	add    $0x10,%esp
  801995:	85 c0                	test   %eax,%eax
  801997:	0f 88 59 01 00 00    	js     801af6 <spawn+0x48a>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  80199d:	83 ec 04             	sub    $0x4,%esp
  8019a0:	89 f8                	mov    %edi,%eax
  8019a2:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  8019a8:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8019ad:	b9 00 10 00 00       	mov    $0x1000,%ecx
  8019b2:	0f 47 c1             	cmova  %ecx,%eax
  8019b5:	50                   	push   %eax
  8019b6:	68 00 00 40 00       	push   $0x400000
  8019bb:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8019c1:	e8 34 f8 ff ff       	call   8011fa <readn>
  8019c6:	83 c4 10             	add    $0x10,%esp
  8019c9:	85 c0                	test   %eax,%eax
  8019cb:	0f 88 29 01 00 00    	js     801afa <spawn+0x48e>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  8019d1:	83 ec 0c             	sub    $0xc,%esp
  8019d4:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  8019da:	56                   	push   %esi
  8019db:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  8019e1:	68 00 00 40 00       	push   $0x400000
  8019e6:	6a 00                	push   $0x0
  8019e8:	e8 f2 f2 ff ff       	call   800cdf <sys_page_map>
  8019ed:	83 c4 20             	add    $0x20,%esp
  8019f0:	85 c0                	test   %eax,%eax
  8019f2:	79 15                	jns    801a09 <spawn+0x39d>
				panic("spawn: sys_page_map data: %e", r);
  8019f4:	50                   	push   %eax
  8019f5:	68 8f 29 80 00       	push   $0x80298f
  8019fa:	68 25 01 00 00       	push   $0x125
  8019ff:	68 83 29 80 00       	push   $0x802983
  801a04:	e8 8b e7 ff ff       	call   800194 <_panic>
			sys_page_unmap(0, UTEMP);
  801a09:	83 ec 08             	sub    $0x8,%esp
  801a0c:	68 00 00 40 00       	push   $0x400000
  801a11:	6a 00                	push   $0x0
  801a13:	e8 09 f3 ff ff       	call   800d21 <sys_page_unmap>
  801a18:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801a1b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801a21:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801a27:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801a2d:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  801a33:	0f 87 f7 fe ff ff    	ja     801930 <spawn+0x2c4>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801a39:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801a40:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801a47:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801a4e:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801a54:	0f 8c 67 fe ff ff    	jl     8018c1 <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801a5a:	83 ec 0c             	sub    $0xc,%esp
  801a5d:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801a63:	e8 c5 f5 ff ff       	call   80102d <close>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801a68:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801a6f:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801a72:	83 c4 08             	add    $0x8,%esp
  801a75:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801a7b:	50                   	push   %eax
  801a7c:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801a82:	e8 1e f3 ff ff       	call   800da5 <sys_env_set_trapframe>
  801a87:	83 c4 10             	add    $0x10,%esp
  801a8a:	85 c0                	test   %eax,%eax
  801a8c:	79 15                	jns    801aa3 <spawn+0x437>
		panic("sys_env_set_trapframe: %e", r);
  801a8e:	50                   	push   %eax
  801a8f:	68 ac 29 80 00       	push   $0x8029ac
  801a94:	68 86 00 00 00       	push   $0x86
  801a99:	68 83 29 80 00       	push   $0x802983
  801a9e:	e8 f1 e6 ff ff       	call   800194 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801aa3:	83 ec 08             	sub    $0x8,%esp
  801aa6:	6a 02                	push   $0x2
  801aa8:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801aae:	e8 b0 f2 ff ff       	call   800d63 <sys_env_set_status>
  801ab3:	83 c4 10             	add    $0x10,%esp
  801ab6:	85 c0                	test   %eax,%eax
  801ab8:	79 25                	jns    801adf <spawn+0x473>
		panic("sys_env_set_status: %e", r);
  801aba:	50                   	push   %eax
  801abb:	68 c6 29 80 00       	push   $0x8029c6
  801ac0:	68 89 00 00 00       	push   $0x89
  801ac5:	68 83 29 80 00       	push   $0x802983
  801aca:	e8 c5 e6 ff ff       	call   800194 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801acf:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801ad5:	eb 58                	jmp    801b2f <spawn+0x4c3>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801ad7:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801add:	eb 50                	jmp    801b2f <spawn+0x4c3>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801adf:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801ae5:	eb 48                	jmp    801b2f <spawn+0x4c3>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801ae7:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801aec:	eb 41                	jmp    801b2f <spawn+0x4c3>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801aee:	89 c3                	mov    %eax,%ebx
  801af0:	eb 3d                	jmp    801b2f <spawn+0x4c3>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801af2:	89 c3                	mov    %eax,%ebx
  801af4:	eb 06                	jmp    801afc <spawn+0x490>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801af6:	89 c3                	mov    %eax,%ebx
  801af8:	eb 02                	jmp    801afc <spawn+0x490>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801afa:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801afc:	83 ec 0c             	sub    $0xc,%esp
  801aff:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801b05:	e8 13 f1 ff ff       	call   800c1d <sys_env_destroy>
	close(fd);
  801b0a:	83 c4 04             	add    $0x4,%esp
  801b0d:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801b13:	e8 15 f5 ff ff       	call   80102d <close>
	return r;
  801b18:	83 c4 10             	add    $0x10,%esp
  801b1b:	eb 12                	jmp    801b2f <spawn+0x4c3>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801b1d:	83 ec 08             	sub    $0x8,%esp
  801b20:	68 00 00 40 00       	push   $0x400000
  801b25:	6a 00                	push   $0x0
  801b27:	e8 f5 f1 ff ff       	call   800d21 <sys_page_unmap>
  801b2c:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801b2f:	89 d8                	mov    %ebx,%eax
  801b31:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b34:	5b                   	pop    %ebx
  801b35:	5e                   	pop    %esi
  801b36:	5f                   	pop    %edi
  801b37:	5d                   	pop    %ebp
  801b38:	c3                   	ret    

00801b39 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801b39:	55                   	push   %ebp
  801b3a:	89 e5                	mov    %esp,%ebp
  801b3c:	56                   	push   %esi
  801b3d:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801b3e:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801b41:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801b46:	eb 03                	jmp    801b4b <spawnl+0x12>
		argc++;
  801b48:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801b4b:	83 c2 04             	add    $0x4,%edx
  801b4e:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801b52:	75 f4                	jne    801b48 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801b54:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801b5b:	83 e2 f0             	and    $0xfffffff0,%edx
  801b5e:	29 d4                	sub    %edx,%esp
  801b60:	8d 54 24 03          	lea    0x3(%esp),%edx
  801b64:	c1 ea 02             	shr    $0x2,%edx
  801b67:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801b6e:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801b70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b73:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801b7a:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801b81:	00 
  801b82:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801b84:	b8 00 00 00 00       	mov    $0x0,%eax
  801b89:	eb 0a                	jmp    801b95 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801b8b:	83 c0 01             	add    $0x1,%eax
  801b8e:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801b92:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801b95:	39 d0                	cmp    %edx,%eax
  801b97:	75 f2                	jne    801b8b <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801b99:	83 ec 08             	sub    $0x8,%esp
  801b9c:	56                   	push   %esi
  801b9d:	ff 75 08             	pushl  0x8(%ebp)
  801ba0:	e8 c7 fa ff ff       	call   80166c <spawn>
}
  801ba5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ba8:	5b                   	pop    %ebx
  801ba9:	5e                   	pop    %esi
  801baa:	5d                   	pop    %ebp
  801bab:	c3                   	ret    

00801bac <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801bac:	55                   	push   %ebp
  801bad:	89 e5                	mov    %esp,%ebp
  801baf:	56                   	push   %esi
  801bb0:	53                   	push   %ebx
  801bb1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801bb4:	83 ec 0c             	sub    $0xc,%esp
  801bb7:	ff 75 08             	pushl  0x8(%ebp)
  801bba:	e8 de f2 ff ff       	call   800e9d <fd2data>
  801bbf:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801bc1:	83 c4 08             	add    $0x8,%esp
  801bc4:	68 08 2a 80 00       	push   $0x802a08
  801bc9:	53                   	push   %ebx
  801bca:	e8 ca ec ff ff       	call   800899 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801bcf:	8b 46 04             	mov    0x4(%esi),%eax
  801bd2:	2b 06                	sub    (%esi),%eax
  801bd4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801bda:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801be1:	00 00 00 
	stat->st_dev = &devpipe;
  801be4:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801beb:	30 80 00 
	return 0;
}
  801bee:	b8 00 00 00 00       	mov    $0x0,%eax
  801bf3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bf6:	5b                   	pop    %ebx
  801bf7:	5e                   	pop    %esi
  801bf8:	5d                   	pop    %ebp
  801bf9:	c3                   	ret    

00801bfa <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801bfa:	55                   	push   %ebp
  801bfb:	89 e5                	mov    %esp,%ebp
  801bfd:	53                   	push   %ebx
  801bfe:	83 ec 0c             	sub    $0xc,%esp
  801c01:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c04:	53                   	push   %ebx
  801c05:	6a 00                	push   $0x0
  801c07:	e8 15 f1 ff ff       	call   800d21 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c0c:	89 1c 24             	mov    %ebx,(%esp)
  801c0f:	e8 89 f2 ff ff       	call   800e9d <fd2data>
  801c14:	83 c4 08             	add    $0x8,%esp
  801c17:	50                   	push   %eax
  801c18:	6a 00                	push   $0x0
  801c1a:	e8 02 f1 ff ff       	call   800d21 <sys_page_unmap>
}
  801c1f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c22:	c9                   	leave  
  801c23:	c3                   	ret    

00801c24 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801c24:	55                   	push   %ebp
  801c25:	89 e5                	mov    %esp,%ebp
  801c27:	57                   	push   %edi
  801c28:	56                   	push   %esi
  801c29:	53                   	push   %ebx
  801c2a:	83 ec 1c             	sub    $0x1c,%esp
  801c2d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801c30:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801c32:	a1 04 40 80 00       	mov    0x804004,%eax
  801c37:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801c3a:	83 ec 0c             	sub    $0xc,%esp
  801c3d:	ff 75 e0             	pushl  -0x20(%ebp)
  801c40:	e8 48 05 00 00       	call   80218d <pageref>
  801c45:	89 c3                	mov    %eax,%ebx
  801c47:	89 3c 24             	mov    %edi,(%esp)
  801c4a:	e8 3e 05 00 00       	call   80218d <pageref>
  801c4f:	83 c4 10             	add    $0x10,%esp
  801c52:	39 c3                	cmp    %eax,%ebx
  801c54:	0f 94 c1             	sete   %cl
  801c57:	0f b6 c9             	movzbl %cl,%ecx
  801c5a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801c5d:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801c63:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801c66:	39 ce                	cmp    %ecx,%esi
  801c68:	74 1b                	je     801c85 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801c6a:	39 c3                	cmp    %eax,%ebx
  801c6c:	75 c4                	jne    801c32 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c6e:	8b 42 58             	mov    0x58(%edx),%eax
  801c71:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c74:	50                   	push   %eax
  801c75:	56                   	push   %esi
  801c76:	68 0f 2a 80 00       	push   $0x802a0f
  801c7b:	e8 ed e5 ff ff       	call   80026d <cprintf>
  801c80:	83 c4 10             	add    $0x10,%esp
  801c83:	eb ad                	jmp    801c32 <_pipeisclosed+0xe>
	}
}
  801c85:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c88:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c8b:	5b                   	pop    %ebx
  801c8c:	5e                   	pop    %esi
  801c8d:	5f                   	pop    %edi
  801c8e:	5d                   	pop    %ebp
  801c8f:	c3                   	ret    

00801c90 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c90:	55                   	push   %ebp
  801c91:	89 e5                	mov    %esp,%ebp
  801c93:	57                   	push   %edi
  801c94:	56                   	push   %esi
  801c95:	53                   	push   %ebx
  801c96:	83 ec 28             	sub    $0x28,%esp
  801c99:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801c9c:	56                   	push   %esi
  801c9d:	e8 fb f1 ff ff       	call   800e9d <fd2data>
  801ca2:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ca4:	83 c4 10             	add    $0x10,%esp
  801ca7:	bf 00 00 00 00       	mov    $0x0,%edi
  801cac:	eb 4b                	jmp    801cf9 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801cae:	89 da                	mov    %ebx,%edx
  801cb0:	89 f0                	mov    %esi,%eax
  801cb2:	e8 6d ff ff ff       	call   801c24 <_pipeisclosed>
  801cb7:	85 c0                	test   %eax,%eax
  801cb9:	75 48                	jne    801d03 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801cbb:	e8 bd ef ff ff       	call   800c7d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801cc0:	8b 43 04             	mov    0x4(%ebx),%eax
  801cc3:	8b 0b                	mov    (%ebx),%ecx
  801cc5:	8d 51 20             	lea    0x20(%ecx),%edx
  801cc8:	39 d0                	cmp    %edx,%eax
  801cca:	73 e2                	jae    801cae <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ccc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ccf:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801cd3:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801cd6:	89 c2                	mov    %eax,%edx
  801cd8:	c1 fa 1f             	sar    $0x1f,%edx
  801cdb:	89 d1                	mov    %edx,%ecx
  801cdd:	c1 e9 1b             	shr    $0x1b,%ecx
  801ce0:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801ce3:	83 e2 1f             	and    $0x1f,%edx
  801ce6:	29 ca                	sub    %ecx,%edx
  801ce8:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801cec:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801cf0:	83 c0 01             	add    $0x1,%eax
  801cf3:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cf6:	83 c7 01             	add    $0x1,%edi
  801cf9:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801cfc:	75 c2                	jne    801cc0 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801cfe:	8b 45 10             	mov    0x10(%ebp),%eax
  801d01:	eb 05                	jmp    801d08 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d03:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801d08:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d0b:	5b                   	pop    %ebx
  801d0c:	5e                   	pop    %esi
  801d0d:	5f                   	pop    %edi
  801d0e:	5d                   	pop    %ebp
  801d0f:	c3                   	ret    

00801d10 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d10:	55                   	push   %ebp
  801d11:	89 e5                	mov    %esp,%ebp
  801d13:	57                   	push   %edi
  801d14:	56                   	push   %esi
  801d15:	53                   	push   %ebx
  801d16:	83 ec 18             	sub    $0x18,%esp
  801d19:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801d1c:	57                   	push   %edi
  801d1d:	e8 7b f1 ff ff       	call   800e9d <fd2data>
  801d22:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d24:	83 c4 10             	add    $0x10,%esp
  801d27:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d2c:	eb 3d                	jmp    801d6b <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801d2e:	85 db                	test   %ebx,%ebx
  801d30:	74 04                	je     801d36 <devpipe_read+0x26>
				return i;
  801d32:	89 d8                	mov    %ebx,%eax
  801d34:	eb 44                	jmp    801d7a <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801d36:	89 f2                	mov    %esi,%edx
  801d38:	89 f8                	mov    %edi,%eax
  801d3a:	e8 e5 fe ff ff       	call   801c24 <_pipeisclosed>
  801d3f:	85 c0                	test   %eax,%eax
  801d41:	75 32                	jne    801d75 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801d43:	e8 35 ef ff ff       	call   800c7d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801d48:	8b 06                	mov    (%esi),%eax
  801d4a:	3b 46 04             	cmp    0x4(%esi),%eax
  801d4d:	74 df                	je     801d2e <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d4f:	99                   	cltd   
  801d50:	c1 ea 1b             	shr    $0x1b,%edx
  801d53:	01 d0                	add    %edx,%eax
  801d55:	83 e0 1f             	and    $0x1f,%eax
  801d58:	29 d0                	sub    %edx,%eax
  801d5a:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801d5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d62:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801d65:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d68:	83 c3 01             	add    $0x1,%ebx
  801d6b:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801d6e:	75 d8                	jne    801d48 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801d70:	8b 45 10             	mov    0x10(%ebp),%eax
  801d73:	eb 05                	jmp    801d7a <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d75:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801d7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d7d:	5b                   	pop    %ebx
  801d7e:	5e                   	pop    %esi
  801d7f:	5f                   	pop    %edi
  801d80:	5d                   	pop    %ebp
  801d81:	c3                   	ret    

00801d82 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801d82:	55                   	push   %ebp
  801d83:	89 e5                	mov    %esp,%ebp
  801d85:	56                   	push   %esi
  801d86:	53                   	push   %ebx
  801d87:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801d8a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d8d:	50                   	push   %eax
  801d8e:	e8 21 f1 ff ff       	call   800eb4 <fd_alloc>
  801d93:	83 c4 10             	add    $0x10,%esp
  801d96:	89 c2                	mov    %eax,%edx
  801d98:	85 c0                	test   %eax,%eax
  801d9a:	0f 88 2c 01 00 00    	js     801ecc <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801da0:	83 ec 04             	sub    $0x4,%esp
  801da3:	68 07 04 00 00       	push   $0x407
  801da8:	ff 75 f4             	pushl  -0xc(%ebp)
  801dab:	6a 00                	push   $0x0
  801dad:	e8 ea ee ff ff       	call   800c9c <sys_page_alloc>
  801db2:	83 c4 10             	add    $0x10,%esp
  801db5:	89 c2                	mov    %eax,%edx
  801db7:	85 c0                	test   %eax,%eax
  801db9:	0f 88 0d 01 00 00    	js     801ecc <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801dbf:	83 ec 0c             	sub    $0xc,%esp
  801dc2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801dc5:	50                   	push   %eax
  801dc6:	e8 e9 f0 ff ff       	call   800eb4 <fd_alloc>
  801dcb:	89 c3                	mov    %eax,%ebx
  801dcd:	83 c4 10             	add    $0x10,%esp
  801dd0:	85 c0                	test   %eax,%eax
  801dd2:	0f 88 e2 00 00 00    	js     801eba <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dd8:	83 ec 04             	sub    $0x4,%esp
  801ddb:	68 07 04 00 00       	push   $0x407
  801de0:	ff 75 f0             	pushl  -0x10(%ebp)
  801de3:	6a 00                	push   $0x0
  801de5:	e8 b2 ee ff ff       	call   800c9c <sys_page_alloc>
  801dea:	89 c3                	mov    %eax,%ebx
  801dec:	83 c4 10             	add    $0x10,%esp
  801def:	85 c0                	test   %eax,%eax
  801df1:	0f 88 c3 00 00 00    	js     801eba <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801df7:	83 ec 0c             	sub    $0xc,%esp
  801dfa:	ff 75 f4             	pushl  -0xc(%ebp)
  801dfd:	e8 9b f0 ff ff       	call   800e9d <fd2data>
  801e02:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e04:	83 c4 0c             	add    $0xc,%esp
  801e07:	68 07 04 00 00       	push   $0x407
  801e0c:	50                   	push   %eax
  801e0d:	6a 00                	push   $0x0
  801e0f:	e8 88 ee ff ff       	call   800c9c <sys_page_alloc>
  801e14:	89 c3                	mov    %eax,%ebx
  801e16:	83 c4 10             	add    $0x10,%esp
  801e19:	85 c0                	test   %eax,%eax
  801e1b:	0f 88 89 00 00 00    	js     801eaa <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e21:	83 ec 0c             	sub    $0xc,%esp
  801e24:	ff 75 f0             	pushl  -0x10(%ebp)
  801e27:	e8 71 f0 ff ff       	call   800e9d <fd2data>
  801e2c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801e33:	50                   	push   %eax
  801e34:	6a 00                	push   $0x0
  801e36:	56                   	push   %esi
  801e37:	6a 00                	push   $0x0
  801e39:	e8 a1 ee ff ff       	call   800cdf <sys_page_map>
  801e3e:	89 c3                	mov    %eax,%ebx
  801e40:	83 c4 20             	add    $0x20,%esp
  801e43:	85 c0                	test   %eax,%eax
  801e45:	78 55                	js     801e9c <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801e47:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e50:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801e52:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e55:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801e5c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e62:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e65:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e67:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e6a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801e71:	83 ec 0c             	sub    $0xc,%esp
  801e74:	ff 75 f4             	pushl  -0xc(%ebp)
  801e77:	e8 11 f0 ff ff       	call   800e8d <fd2num>
  801e7c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e7f:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e81:	83 c4 04             	add    $0x4,%esp
  801e84:	ff 75 f0             	pushl  -0x10(%ebp)
  801e87:	e8 01 f0 ff ff       	call   800e8d <fd2num>
  801e8c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e8f:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801e92:	83 c4 10             	add    $0x10,%esp
  801e95:	ba 00 00 00 00       	mov    $0x0,%edx
  801e9a:	eb 30                	jmp    801ecc <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801e9c:	83 ec 08             	sub    $0x8,%esp
  801e9f:	56                   	push   %esi
  801ea0:	6a 00                	push   $0x0
  801ea2:	e8 7a ee ff ff       	call   800d21 <sys_page_unmap>
  801ea7:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801eaa:	83 ec 08             	sub    $0x8,%esp
  801ead:	ff 75 f0             	pushl  -0x10(%ebp)
  801eb0:	6a 00                	push   $0x0
  801eb2:	e8 6a ee ff ff       	call   800d21 <sys_page_unmap>
  801eb7:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801eba:	83 ec 08             	sub    $0x8,%esp
  801ebd:	ff 75 f4             	pushl  -0xc(%ebp)
  801ec0:	6a 00                	push   $0x0
  801ec2:	e8 5a ee ff ff       	call   800d21 <sys_page_unmap>
  801ec7:	83 c4 10             	add    $0x10,%esp
  801eca:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801ecc:	89 d0                	mov    %edx,%eax
  801ece:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ed1:	5b                   	pop    %ebx
  801ed2:	5e                   	pop    %esi
  801ed3:	5d                   	pop    %ebp
  801ed4:	c3                   	ret    

00801ed5 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801ed5:	55                   	push   %ebp
  801ed6:	89 e5                	mov    %esp,%ebp
  801ed8:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801edb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ede:	50                   	push   %eax
  801edf:	ff 75 08             	pushl  0x8(%ebp)
  801ee2:	e8 1c f0 ff ff       	call   800f03 <fd_lookup>
  801ee7:	83 c4 10             	add    $0x10,%esp
  801eea:	85 c0                	test   %eax,%eax
  801eec:	78 18                	js     801f06 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801eee:	83 ec 0c             	sub    $0xc,%esp
  801ef1:	ff 75 f4             	pushl  -0xc(%ebp)
  801ef4:	e8 a4 ef ff ff       	call   800e9d <fd2data>
	return _pipeisclosed(fd, p);
  801ef9:	89 c2                	mov    %eax,%edx
  801efb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801efe:	e8 21 fd ff ff       	call   801c24 <_pipeisclosed>
  801f03:	83 c4 10             	add    $0x10,%esp
}
  801f06:	c9                   	leave  
  801f07:	c3                   	ret    

00801f08 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f08:	55                   	push   %ebp
  801f09:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801f0b:	b8 00 00 00 00       	mov    $0x0,%eax
  801f10:	5d                   	pop    %ebp
  801f11:	c3                   	ret    

00801f12 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f12:	55                   	push   %ebp
  801f13:	89 e5                	mov    %esp,%ebp
  801f15:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801f18:	68 27 2a 80 00       	push   $0x802a27
  801f1d:	ff 75 0c             	pushl  0xc(%ebp)
  801f20:	e8 74 e9 ff ff       	call   800899 <strcpy>
	return 0;
}
  801f25:	b8 00 00 00 00       	mov    $0x0,%eax
  801f2a:	c9                   	leave  
  801f2b:	c3                   	ret    

00801f2c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f2c:	55                   	push   %ebp
  801f2d:	89 e5                	mov    %esp,%ebp
  801f2f:	57                   	push   %edi
  801f30:	56                   	push   %esi
  801f31:	53                   	push   %ebx
  801f32:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f38:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f3d:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f43:	eb 2d                	jmp    801f72 <devcons_write+0x46>
		m = n - tot;
  801f45:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801f48:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801f4a:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801f4d:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801f52:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f55:	83 ec 04             	sub    $0x4,%esp
  801f58:	53                   	push   %ebx
  801f59:	03 45 0c             	add    0xc(%ebp),%eax
  801f5c:	50                   	push   %eax
  801f5d:	57                   	push   %edi
  801f5e:	e8 c8 ea ff ff       	call   800a2b <memmove>
		sys_cputs(buf, m);
  801f63:	83 c4 08             	add    $0x8,%esp
  801f66:	53                   	push   %ebx
  801f67:	57                   	push   %edi
  801f68:	e8 73 ec ff ff       	call   800be0 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f6d:	01 de                	add    %ebx,%esi
  801f6f:	83 c4 10             	add    $0x10,%esp
  801f72:	89 f0                	mov    %esi,%eax
  801f74:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f77:	72 cc                	jb     801f45 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801f79:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f7c:	5b                   	pop    %ebx
  801f7d:	5e                   	pop    %esi
  801f7e:	5f                   	pop    %edi
  801f7f:	5d                   	pop    %ebp
  801f80:	c3                   	ret    

00801f81 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f81:	55                   	push   %ebp
  801f82:	89 e5                	mov    %esp,%ebp
  801f84:	83 ec 08             	sub    $0x8,%esp
  801f87:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801f8c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f90:	74 2a                	je     801fbc <devcons_read+0x3b>
  801f92:	eb 05                	jmp    801f99 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f94:	e8 e4 ec ff ff       	call   800c7d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f99:	e8 60 ec ff ff       	call   800bfe <sys_cgetc>
  801f9e:	85 c0                	test   %eax,%eax
  801fa0:	74 f2                	je     801f94 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801fa2:	85 c0                	test   %eax,%eax
  801fa4:	78 16                	js     801fbc <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801fa6:	83 f8 04             	cmp    $0x4,%eax
  801fa9:	74 0c                	je     801fb7 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801fab:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fae:	88 02                	mov    %al,(%edx)
	return 1;
  801fb0:	b8 01 00 00 00       	mov    $0x1,%eax
  801fb5:	eb 05                	jmp    801fbc <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801fb7:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801fbc:	c9                   	leave  
  801fbd:	c3                   	ret    

00801fbe <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801fbe:	55                   	push   %ebp
  801fbf:	89 e5                	mov    %esp,%ebp
  801fc1:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801fc4:	8b 45 08             	mov    0x8(%ebp),%eax
  801fc7:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801fca:	6a 01                	push   $0x1
  801fcc:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fcf:	50                   	push   %eax
  801fd0:	e8 0b ec ff ff       	call   800be0 <sys_cputs>
}
  801fd5:	83 c4 10             	add    $0x10,%esp
  801fd8:	c9                   	leave  
  801fd9:	c3                   	ret    

00801fda <getchar>:

int
getchar(void)
{
  801fda:	55                   	push   %ebp
  801fdb:	89 e5                	mov    %esp,%ebp
  801fdd:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801fe0:	6a 01                	push   $0x1
  801fe2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fe5:	50                   	push   %eax
  801fe6:	6a 00                	push   $0x0
  801fe8:	e8 7c f1 ff ff       	call   801169 <read>
	if (r < 0)
  801fed:	83 c4 10             	add    $0x10,%esp
  801ff0:	85 c0                	test   %eax,%eax
  801ff2:	78 0f                	js     802003 <getchar+0x29>
		return r;
	if (r < 1)
  801ff4:	85 c0                	test   %eax,%eax
  801ff6:	7e 06                	jle    801ffe <getchar+0x24>
		return -E_EOF;
	return c;
  801ff8:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801ffc:	eb 05                	jmp    802003 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801ffe:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802003:	c9                   	leave  
  802004:	c3                   	ret    

00802005 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802005:	55                   	push   %ebp
  802006:	89 e5                	mov    %esp,%ebp
  802008:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80200b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80200e:	50                   	push   %eax
  80200f:	ff 75 08             	pushl  0x8(%ebp)
  802012:	e8 ec ee ff ff       	call   800f03 <fd_lookup>
  802017:	83 c4 10             	add    $0x10,%esp
  80201a:	85 c0                	test   %eax,%eax
  80201c:	78 11                	js     80202f <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80201e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802021:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802027:	39 10                	cmp    %edx,(%eax)
  802029:	0f 94 c0             	sete   %al
  80202c:	0f b6 c0             	movzbl %al,%eax
}
  80202f:	c9                   	leave  
  802030:	c3                   	ret    

00802031 <opencons>:

int
opencons(void)
{
  802031:	55                   	push   %ebp
  802032:	89 e5                	mov    %esp,%ebp
  802034:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802037:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80203a:	50                   	push   %eax
  80203b:	e8 74 ee ff ff       	call   800eb4 <fd_alloc>
  802040:	83 c4 10             	add    $0x10,%esp
		return r;
  802043:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802045:	85 c0                	test   %eax,%eax
  802047:	78 3e                	js     802087 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802049:	83 ec 04             	sub    $0x4,%esp
  80204c:	68 07 04 00 00       	push   $0x407
  802051:	ff 75 f4             	pushl  -0xc(%ebp)
  802054:	6a 00                	push   $0x0
  802056:	e8 41 ec ff ff       	call   800c9c <sys_page_alloc>
  80205b:	83 c4 10             	add    $0x10,%esp
		return r;
  80205e:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802060:	85 c0                	test   %eax,%eax
  802062:	78 23                	js     802087 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802064:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80206a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80206d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80206f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802072:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802079:	83 ec 0c             	sub    $0xc,%esp
  80207c:	50                   	push   %eax
  80207d:	e8 0b ee ff ff       	call   800e8d <fd2num>
  802082:	89 c2                	mov    %eax,%edx
  802084:	83 c4 10             	add    $0x10,%esp
}
  802087:	89 d0                	mov    %edx,%eax
  802089:	c9                   	leave  
  80208a:	c3                   	ret    

0080208b <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80208b:	55                   	push   %ebp
  80208c:	89 e5                	mov    %esp,%ebp
  80208e:	56                   	push   %esi
  80208f:	53                   	push   %ebx
  802090:	8b 75 08             	mov    0x8(%ebp),%esi
  802093:	8b 45 0c             	mov    0xc(%ebp),%eax
  802096:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int ret;
	if (pg) ret = sys_ipc_recv(pg);
  802099:	85 c0                	test   %eax,%eax
  80209b:	74 0e                	je     8020ab <ipc_recv+0x20>
  80209d:	83 ec 0c             	sub    $0xc,%esp
  8020a0:	50                   	push   %eax
  8020a1:	e8 a6 ed ff ff       	call   800e4c <sys_ipc_recv>
  8020a6:	83 c4 10             	add    $0x10,%esp
  8020a9:	eb 10                	jmp    8020bb <ipc_recv+0x30>
	else ret = sys_ipc_recv((void*)UTOP);
  8020ab:	83 ec 0c             	sub    $0xc,%esp
  8020ae:	68 00 00 c0 ee       	push   $0xeec00000
  8020b3:	e8 94 ed ff ff       	call   800e4c <sys_ipc_recv>
  8020b8:	83 c4 10             	add    $0x10,%esp
	if (ret) {
  8020bb:	85 c0                	test   %eax,%eax
  8020bd:	74 16                	je     8020d5 <ipc_recv+0x4a>
		if (from_env_store) *from_env_store = 0;
  8020bf:	85 f6                	test   %esi,%esi
  8020c1:	74 06                	je     8020c9 <ipc_recv+0x3e>
  8020c3:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  8020c9:	85 db                	test   %ebx,%ebx
  8020cb:	74 2c                	je     8020f9 <ipc_recv+0x6e>
  8020cd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8020d3:	eb 24                	jmp    8020f9 <ipc_recv+0x6e>
		return ret;
	}
	if (from_env_store) *from_env_store = thisenv->env_ipc_from;
  8020d5:	85 f6                	test   %esi,%esi
  8020d7:	74 0a                	je     8020e3 <ipc_recv+0x58>
  8020d9:	a1 04 40 80 00       	mov    0x804004,%eax
  8020de:	8b 40 74             	mov    0x74(%eax),%eax
  8020e1:	89 06                	mov    %eax,(%esi)
	if (perm_store) *perm_store = thisenv->env_ipc_perm;
  8020e3:	85 db                	test   %ebx,%ebx
  8020e5:	74 0a                	je     8020f1 <ipc_recv+0x66>
  8020e7:	a1 04 40 80 00       	mov    0x804004,%eax
  8020ec:	8b 40 78             	mov    0x78(%eax),%eax
  8020ef:	89 03                	mov    %eax,(%ebx)

	// panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8020f1:	a1 04 40 80 00       	mov    0x804004,%eax
  8020f6:	8b 40 70             	mov    0x70(%eax),%eax
}
  8020f9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020fc:	5b                   	pop    %ebx
  8020fd:	5e                   	pop    %esi
  8020fe:	5d                   	pop    %ebp
  8020ff:	c3                   	ret    

00802100 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802100:	55                   	push   %ebp
  802101:	89 e5                	mov    %esp,%ebp
  802103:	57                   	push   %edi
  802104:	56                   	push   %esi
  802105:	53                   	push   %ebx
  802106:	83 ec 0c             	sub    $0xc,%esp
  802109:	8b 7d 08             	mov    0x8(%ebp),%edi
  80210c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80210f:	8b 45 10             	mov    0x10(%ebp),%eax
  802112:	85 c0                	test   %eax,%eax
  802114:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  802119:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	while (true) {
		void* srcva = (pg)? pg: (void*)UTOP;
		int ret = sys_ipc_try_send(to_env, val, srcva, perm);
  80211c:	ff 75 14             	pushl  0x14(%ebp)
  80211f:	53                   	push   %ebx
  802120:	56                   	push   %esi
  802121:	57                   	push   %edi
  802122:	e8 02 ed ff ff       	call   800e29 <sys_ipc_try_send>
		if (ret == 0) break;
  802127:	83 c4 10             	add    $0x10,%esp
  80212a:	85 c0                	test   %eax,%eax
  80212c:	74 1e                	je     80214c <ipc_send+0x4c>
		if (ret != -E_IPC_NOT_RECV) panic("ipc_send: %e", ret);
  80212e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802131:	74 12                	je     802145 <ipc_send+0x45>
  802133:	50                   	push   %eax
  802134:	68 33 2a 80 00       	push   $0x802a33
  802139:	6a 39                	push   $0x39
  80213b:	68 40 2a 80 00       	push   $0x802a40
  802140:	e8 4f e0 ff ff       	call   800194 <_panic>
		sys_yield();
  802145:	e8 33 eb ff ff       	call   800c7d <sys_yield>
	}
  80214a:	eb d0                	jmp    80211c <ipc_send+0x1c>
	// panic("ipc_send not implemented");
}
  80214c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80214f:	5b                   	pop    %ebx
  802150:	5e                   	pop    %esi
  802151:	5f                   	pop    %edi
  802152:	5d                   	pop    %ebp
  802153:	c3                   	ret    

00802154 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802154:	55                   	push   %ebp
  802155:	89 e5                	mov    %esp,%ebp
  802157:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80215a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80215f:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802162:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802168:	8b 52 50             	mov    0x50(%edx),%edx
  80216b:	39 ca                	cmp    %ecx,%edx
  80216d:	75 0d                	jne    80217c <ipc_find_env+0x28>
			return envs[i].env_id;
  80216f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802172:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802177:	8b 40 48             	mov    0x48(%eax),%eax
  80217a:	eb 0f                	jmp    80218b <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80217c:	83 c0 01             	add    $0x1,%eax
  80217f:	3d 00 04 00 00       	cmp    $0x400,%eax
  802184:	75 d9                	jne    80215f <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802186:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80218b:	5d                   	pop    %ebp
  80218c:	c3                   	ret    

0080218d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80218d:	55                   	push   %ebp
  80218e:	89 e5                	mov    %esp,%ebp
  802190:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802193:	89 d0                	mov    %edx,%eax
  802195:	c1 e8 16             	shr    $0x16,%eax
  802198:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80219f:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021a4:	f6 c1 01             	test   $0x1,%cl
  8021a7:	74 1d                	je     8021c6 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8021a9:	c1 ea 0c             	shr    $0xc,%edx
  8021ac:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8021b3:	f6 c2 01             	test   $0x1,%dl
  8021b6:	74 0e                	je     8021c6 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8021b8:	c1 ea 0c             	shr    $0xc,%edx
  8021bb:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8021c2:	ef 
  8021c3:	0f b7 c0             	movzwl %ax,%eax
}
  8021c6:	5d                   	pop    %ebp
  8021c7:	c3                   	ret    
  8021c8:	66 90                	xchg   %ax,%ax
  8021ca:	66 90                	xchg   %ax,%ax
  8021cc:	66 90                	xchg   %ax,%ax
  8021ce:	66 90                	xchg   %ax,%ax

008021d0 <__udivdi3>:
  8021d0:	55                   	push   %ebp
  8021d1:	57                   	push   %edi
  8021d2:	56                   	push   %esi
  8021d3:	53                   	push   %ebx
  8021d4:	83 ec 1c             	sub    $0x1c,%esp
  8021d7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8021db:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8021df:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8021e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021e7:	85 f6                	test   %esi,%esi
  8021e9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021ed:	89 ca                	mov    %ecx,%edx
  8021ef:	89 f8                	mov    %edi,%eax
  8021f1:	75 3d                	jne    802230 <__udivdi3+0x60>
  8021f3:	39 cf                	cmp    %ecx,%edi
  8021f5:	0f 87 c5 00 00 00    	ja     8022c0 <__udivdi3+0xf0>
  8021fb:	85 ff                	test   %edi,%edi
  8021fd:	89 fd                	mov    %edi,%ebp
  8021ff:	75 0b                	jne    80220c <__udivdi3+0x3c>
  802201:	b8 01 00 00 00       	mov    $0x1,%eax
  802206:	31 d2                	xor    %edx,%edx
  802208:	f7 f7                	div    %edi
  80220a:	89 c5                	mov    %eax,%ebp
  80220c:	89 c8                	mov    %ecx,%eax
  80220e:	31 d2                	xor    %edx,%edx
  802210:	f7 f5                	div    %ebp
  802212:	89 c1                	mov    %eax,%ecx
  802214:	89 d8                	mov    %ebx,%eax
  802216:	89 cf                	mov    %ecx,%edi
  802218:	f7 f5                	div    %ebp
  80221a:	89 c3                	mov    %eax,%ebx
  80221c:	89 d8                	mov    %ebx,%eax
  80221e:	89 fa                	mov    %edi,%edx
  802220:	83 c4 1c             	add    $0x1c,%esp
  802223:	5b                   	pop    %ebx
  802224:	5e                   	pop    %esi
  802225:	5f                   	pop    %edi
  802226:	5d                   	pop    %ebp
  802227:	c3                   	ret    
  802228:	90                   	nop
  802229:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802230:	39 ce                	cmp    %ecx,%esi
  802232:	77 74                	ja     8022a8 <__udivdi3+0xd8>
  802234:	0f bd fe             	bsr    %esi,%edi
  802237:	83 f7 1f             	xor    $0x1f,%edi
  80223a:	0f 84 98 00 00 00    	je     8022d8 <__udivdi3+0x108>
  802240:	bb 20 00 00 00       	mov    $0x20,%ebx
  802245:	89 f9                	mov    %edi,%ecx
  802247:	89 c5                	mov    %eax,%ebp
  802249:	29 fb                	sub    %edi,%ebx
  80224b:	d3 e6                	shl    %cl,%esi
  80224d:	89 d9                	mov    %ebx,%ecx
  80224f:	d3 ed                	shr    %cl,%ebp
  802251:	89 f9                	mov    %edi,%ecx
  802253:	d3 e0                	shl    %cl,%eax
  802255:	09 ee                	or     %ebp,%esi
  802257:	89 d9                	mov    %ebx,%ecx
  802259:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80225d:	89 d5                	mov    %edx,%ebp
  80225f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802263:	d3 ed                	shr    %cl,%ebp
  802265:	89 f9                	mov    %edi,%ecx
  802267:	d3 e2                	shl    %cl,%edx
  802269:	89 d9                	mov    %ebx,%ecx
  80226b:	d3 e8                	shr    %cl,%eax
  80226d:	09 c2                	or     %eax,%edx
  80226f:	89 d0                	mov    %edx,%eax
  802271:	89 ea                	mov    %ebp,%edx
  802273:	f7 f6                	div    %esi
  802275:	89 d5                	mov    %edx,%ebp
  802277:	89 c3                	mov    %eax,%ebx
  802279:	f7 64 24 0c          	mull   0xc(%esp)
  80227d:	39 d5                	cmp    %edx,%ebp
  80227f:	72 10                	jb     802291 <__udivdi3+0xc1>
  802281:	8b 74 24 08          	mov    0x8(%esp),%esi
  802285:	89 f9                	mov    %edi,%ecx
  802287:	d3 e6                	shl    %cl,%esi
  802289:	39 c6                	cmp    %eax,%esi
  80228b:	73 07                	jae    802294 <__udivdi3+0xc4>
  80228d:	39 d5                	cmp    %edx,%ebp
  80228f:	75 03                	jne    802294 <__udivdi3+0xc4>
  802291:	83 eb 01             	sub    $0x1,%ebx
  802294:	31 ff                	xor    %edi,%edi
  802296:	89 d8                	mov    %ebx,%eax
  802298:	89 fa                	mov    %edi,%edx
  80229a:	83 c4 1c             	add    $0x1c,%esp
  80229d:	5b                   	pop    %ebx
  80229e:	5e                   	pop    %esi
  80229f:	5f                   	pop    %edi
  8022a0:	5d                   	pop    %ebp
  8022a1:	c3                   	ret    
  8022a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022a8:	31 ff                	xor    %edi,%edi
  8022aa:	31 db                	xor    %ebx,%ebx
  8022ac:	89 d8                	mov    %ebx,%eax
  8022ae:	89 fa                	mov    %edi,%edx
  8022b0:	83 c4 1c             	add    $0x1c,%esp
  8022b3:	5b                   	pop    %ebx
  8022b4:	5e                   	pop    %esi
  8022b5:	5f                   	pop    %edi
  8022b6:	5d                   	pop    %ebp
  8022b7:	c3                   	ret    
  8022b8:	90                   	nop
  8022b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022c0:	89 d8                	mov    %ebx,%eax
  8022c2:	f7 f7                	div    %edi
  8022c4:	31 ff                	xor    %edi,%edi
  8022c6:	89 c3                	mov    %eax,%ebx
  8022c8:	89 d8                	mov    %ebx,%eax
  8022ca:	89 fa                	mov    %edi,%edx
  8022cc:	83 c4 1c             	add    $0x1c,%esp
  8022cf:	5b                   	pop    %ebx
  8022d0:	5e                   	pop    %esi
  8022d1:	5f                   	pop    %edi
  8022d2:	5d                   	pop    %ebp
  8022d3:	c3                   	ret    
  8022d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022d8:	39 ce                	cmp    %ecx,%esi
  8022da:	72 0c                	jb     8022e8 <__udivdi3+0x118>
  8022dc:	31 db                	xor    %ebx,%ebx
  8022de:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8022e2:	0f 87 34 ff ff ff    	ja     80221c <__udivdi3+0x4c>
  8022e8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8022ed:	e9 2a ff ff ff       	jmp    80221c <__udivdi3+0x4c>
  8022f2:	66 90                	xchg   %ax,%ax
  8022f4:	66 90                	xchg   %ax,%ax
  8022f6:	66 90                	xchg   %ax,%ax
  8022f8:	66 90                	xchg   %ax,%ax
  8022fa:	66 90                	xchg   %ax,%ax
  8022fc:	66 90                	xchg   %ax,%ax
  8022fe:	66 90                	xchg   %ax,%ax

00802300 <__umoddi3>:
  802300:	55                   	push   %ebp
  802301:	57                   	push   %edi
  802302:	56                   	push   %esi
  802303:	53                   	push   %ebx
  802304:	83 ec 1c             	sub    $0x1c,%esp
  802307:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80230b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80230f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802313:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802317:	85 d2                	test   %edx,%edx
  802319:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80231d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802321:	89 f3                	mov    %esi,%ebx
  802323:	89 3c 24             	mov    %edi,(%esp)
  802326:	89 74 24 04          	mov    %esi,0x4(%esp)
  80232a:	75 1c                	jne    802348 <__umoddi3+0x48>
  80232c:	39 f7                	cmp    %esi,%edi
  80232e:	76 50                	jbe    802380 <__umoddi3+0x80>
  802330:	89 c8                	mov    %ecx,%eax
  802332:	89 f2                	mov    %esi,%edx
  802334:	f7 f7                	div    %edi
  802336:	89 d0                	mov    %edx,%eax
  802338:	31 d2                	xor    %edx,%edx
  80233a:	83 c4 1c             	add    $0x1c,%esp
  80233d:	5b                   	pop    %ebx
  80233e:	5e                   	pop    %esi
  80233f:	5f                   	pop    %edi
  802340:	5d                   	pop    %ebp
  802341:	c3                   	ret    
  802342:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802348:	39 f2                	cmp    %esi,%edx
  80234a:	89 d0                	mov    %edx,%eax
  80234c:	77 52                	ja     8023a0 <__umoddi3+0xa0>
  80234e:	0f bd ea             	bsr    %edx,%ebp
  802351:	83 f5 1f             	xor    $0x1f,%ebp
  802354:	75 5a                	jne    8023b0 <__umoddi3+0xb0>
  802356:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80235a:	0f 82 e0 00 00 00    	jb     802440 <__umoddi3+0x140>
  802360:	39 0c 24             	cmp    %ecx,(%esp)
  802363:	0f 86 d7 00 00 00    	jbe    802440 <__umoddi3+0x140>
  802369:	8b 44 24 08          	mov    0x8(%esp),%eax
  80236d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802371:	83 c4 1c             	add    $0x1c,%esp
  802374:	5b                   	pop    %ebx
  802375:	5e                   	pop    %esi
  802376:	5f                   	pop    %edi
  802377:	5d                   	pop    %ebp
  802378:	c3                   	ret    
  802379:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802380:	85 ff                	test   %edi,%edi
  802382:	89 fd                	mov    %edi,%ebp
  802384:	75 0b                	jne    802391 <__umoddi3+0x91>
  802386:	b8 01 00 00 00       	mov    $0x1,%eax
  80238b:	31 d2                	xor    %edx,%edx
  80238d:	f7 f7                	div    %edi
  80238f:	89 c5                	mov    %eax,%ebp
  802391:	89 f0                	mov    %esi,%eax
  802393:	31 d2                	xor    %edx,%edx
  802395:	f7 f5                	div    %ebp
  802397:	89 c8                	mov    %ecx,%eax
  802399:	f7 f5                	div    %ebp
  80239b:	89 d0                	mov    %edx,%eax
  80239d:	eb 99                	jmp    802338 <__umoddi3+0x38>
  80239f:	90                   	nop
  8023a0:	89 c8                	mov    %ecx,%eax
  8023a2:	89 f2                	mov    %esi,%edx
  8023a4:	83 c4 1c             	add    $0x1c,%esp
  8023a7:	5b                   	pop    %ebx
  8023a8:	5e                   	pop    %esi
  8023a9:	5f                   	pop    %edi
  8023aa:	5d                   	pop    %ebp
  8023ab:	c3                   	ret    
  8023ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023b0:	8b 34 24             	mov    (%esp),%esi
  8023b3:	bf 20 00 00 00       	mov    $0x20,%edi
  8023b8:	89 e9                	mov    %ebp,%ecx
  8023ba:	29 ef                	sub    %ebp,%edi
  8023bc:	d3 e0                	shl    %cl,%eax
  8023be:	89 f9                	mov    %edi,%ecx
  8023c0:	89 f2                	mov    %esi,%edx
  8023c2:	d3 ea                	shr    %cl,%edx
  8023c4:	89 e9                	mov    %ebp,%ecx
  8023c6:	09 c2                	or     %eax,%edx
  8023c8:	89 d8                	mov    %ebx,%eax
  8023ca:	89 14 24             	mov    %edx,(%esp)
  8023cd:	89 f2                	mov    %esi,%edx
  8023cf:	d3 e2                	shl    %cl,%edx
  8023d1:	89 f9                	mov    %edi,%ecx
  8023d3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8023d7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8023db:	d3 e8                	shr    %cl,%eax
  8023dd:	89 e9                	mov    %ebp,%ecx
  8023df:	89 c6                	mov    %eax,%esi
  8023e1:	d3 e3                	shl    %cl,%ebx
  8023e3:	89 f9                	mov    %edi,%ecx
  8023e5:	89 d0                	mov    %edx,%eax
  8023e7:	d3 e8                	shr    %cl,%eax
  8023e9:	89 e9                	mov    %ebp,%ecx
  8023eb:	09 d8                	or     %ebx,%eax
  8023ed:	89 d3                	mov    %edx,%ebx
  8023ef:	89 f2                	mov    %esi,%edx
  8023f1:	f7 34 24             	divl   (%esp)
  8023f4:	89 d6                	mov    %edx,%esi
  8023f6:	d3 e3                	shl    %cl,%ebx
  8023f8:	f7 64 24 04          	mull   0x4(%esp)
  8023fc:	39 d6                	cmp    %edx,%esi
  8023fe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802402:	89 d1                	mov    %edx,%ecx
  802404:	89 c3                	mov    %eax,%ebx
  802406:	72 08                	jb     802410 <__umoddi3+0x110>
  802408:	75 11                	jne    80241b <__umoddi3+0x11b>
  80240a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80240e:	73 0b                	jae    80241b <__umoddi3+0x11b>
  802410:	2b 44 24 04          	sub    0x4(%esp),%eax
  802414:	1b 14 24             	sbb    (%esp),%edx
  802417:	89 d1                	mov    %edx,%ecx
  802419:	89 c3                	mov    %eax,%ebx
  80241b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80241f:	29 da                	sub    %ebx,%edx
  802421:	19 ce                	sbb    %ecx,%esi
  802423:	89 f9                	mov    %edi,%ecx
  802425:	89 f0                	mov    %esi,%eax
  802427:	d3 e0                	shl    %cl,%eax
  802429:	89 e9                	mov    %ebp,%ecx
  80242b:	d3 ea                	shr    %cl,%edx
  80242d:	89 e9                	mov    %ebp,%ecx
  80242f:	d3 ee                	shr    %cl,%esi
  802431:	09 d0                	or     %edx,%eax
  802433:	89 f2                	mov    %esi,%edx
  802435:	83 c4 1c             	add    $0x1c,%esp
  802438:	5b                   	pop    %ebx
  802439:	5e                   	pop    %esi
  80243a:	5f                   	pop    %edi
  80243b:	5d                   	pop    %ebp
  80243c:	c3                   	ret    
  80243d:	8d 76 00             	lea    0x0(%esi),%esi
  802440:	29 f9                	sub    %edi,%ecx
  802442:	19 d6                	sbb    %edx,%esi
  802444:	89 74 24 04          	mov    %esi,0x4(%esp)
  802448:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80244c:	e9 18 ff ff ff       	jmp    802369 <__umoddi3+0x69>
