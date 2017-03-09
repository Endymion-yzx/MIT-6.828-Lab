
obj/user/testpteshare.debug:     file format elf32-i386


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
  80002c:	e8 47 01 00 00       	call   800178 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <childofspawn>:
	breakpoint();
}

void
childofspawn(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	strcpy(VA, msg2);
  800039:	ff 35 00 30 80 00    	pushl  0x803000
  80003f:	68 00 00 00 a0       	push   $0xa0000000
  800044:	e8 94 08 00 00       	call   8008dd <strcpy>
	exit();
  800049:	e8 70 01 00 00       	call   8001be <exit>
}
  80004e:	83 c4 10             	add    $0x10,%esp
  800051:	c9                   	leave  
  800052:	c3                   	ret    

00800053 <umain>:

void childofspawn(void);

void
umain(int argc, char **argv)
{
  800053:	55                   	push   %ebp
  800054:	89 e5                	mov    %esp,%ebp
  800056:	53                   	push   %ebx
  800057:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (argc != 0)
  80005a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80005e:	74 05                	je     800065 <umain+0x12>
		childofspawn();
  800060:	e8 ce ff ff ff       	call   800033 <childofspawn>

	if ((r = sys_page_alloc(0, VA, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800065:	83 ec 04             	sub    $0x4,%esp
  800068:	68 07 04 00 00       	push   $0x407
  80006d:	68 00 00 00 a0       	push   $0xa0000000
  800072:	6a 00                	push   $0x0
  800074:	e8 67 0c 00 00       	call   800ce0 <sys_page_alloc>
  800079:	83 c4 10             	add    $0x10,%esp
  80007c:	85 c0                	test   %eax,%eax
  80007e:	79 12                	jns    800092 <umain+0x3f>
		panic("sys_page_alloc: %e", r);
  800080:	50                   	push   %eax
  800081:	68 8c 28 80 00       	push   $0x80288c
  800086:	6a 13                	push   $0x13
  800088:	68 9f 28 80 00       	push   $0x80289f
  80008d:	e8 46 01 00 00       	call   8001d8 <_panic>

	// check fork
	if ((r = fork()) < 0)
  800092:	e8 e7 0f 00 00       	call   80107e <fork>
  800097:	89 c3                	mov    %eax,%ebx
  800099:	85 c0                	test   %eax,%eax
  80009b:	79 12                	jns    8000af <umain+0x5c>
		panic("fork: %e", r);
  80009d:	50                   	push   %eax
  80009e:	68 b3 28 80 00       	push   $0x8028b3
  8000a3:	6a 17                	push   $0x17
  8000a5:	68 9f 28 80 00       	push   $0x80289f
  8000aa:	e8 29 01 00 00       	call   8001d8 <_panic>
	if (r == 0) {
  8000af:	85 c0                	test   %eax,%eax
  8000b1:	75 1b                	jne    8000ce <umain+0x7b>
		strcpy(VA, msg);
  8000b3:	83 ec 08             	sub    $0x8,%esp
  8000b6:	ff 35 04 30 80 00    	pushl  0x803004
  8000bc:	68 00 00 00 a0       	push   $0xa0000000
  8000c1:	e8 17 08 00 00       	call   8008dd <strcpy>
		exit();
  8000c6:	e8 f3 00 00 00       	call   8001be <exit>
  8000cb:	83 c4 10             	add    $0x10,%esp
	}
	wait(r);
  8000ce:	83 ec 0c             	sub    $0xc,%esp
  8000d1:	53                   	push   %ebx
  8000d2:	e8 7f 21 00 00       	call   802256 <wait>
	cprintf("fork handles PTE_SHARE %s\n", strcmp(VA, msg) == 0 ? "right" : "wrong");
  8000d7:	83 c4 08             	add    $0x8,%esp
  8000da:	ff 35 04 30 80 00    	pushl  0x803004
  8000e0:	68 00 00 00 a0       	push   $0xa0000000
  8000e5:	e8 9d 08 00 00       	call   800987 <strcmp>
  8000ea:	83 c4 08             	add    $0x8,%esp
  8000ed:	85 c0                	test   %eax,%eax
  8000ef:	ba 86 28 80 00       	mov    $0x802886,%edx
  8000f4:	b8 80 28 80 00       	mov    $0x802880,%eax
  8000f9:	0f 45 c2             	cmovne %edx,%eax
  8000fc:	50                   	push   %eax
  8000fd:	68 bc 28 80 00       	push   $0x8028bc
  800102:	e8 aa 01 00 00       	call   8002b1 <cprintf>

	// check spawn
	if ((r = spawnl("/testpteshare", "testpteshare", "arg", 0)) < 0)
  800107:	6a 00                	push   $0x0
  800109:	68 d7 28 80 00       	push   $0x8028d7
  80010e:	68 dc 28 80 00       	push   $0x8028dc
  800113:	68 db 28 80 00       	push   $0x8028db
  800118:	e8 6a 1d 00 00       	call   801e87 <spawnl>
  80011d:	83 c4 20             	add    $0x20,%esp
  800120:	85 c0                	test   %eax,%eax
  800122:	79 12                	jns    800136 <umain+0xe3>
		panic("spawn: %e", r);
  800124:	50                   	push   %eax
  800125:	68 e9 28 80 00       	push   $0x8028e9
  80012a:	6a 21                	push   $0x21
  80012c:	68 9f 28 80 00       	push   $0x80289f
  800131:	e8 a2 00 00 00       	call   8001d8 <_panic>
	wait(r);
  800136:	83 ec 0c             	sub    $0xc,%esp
  800139:	50                   	push   %eax
  80013a:	e8 17 21 00 00       	call   802256 <wait>
	cprintf("spawn handles PTE_SHARE %s\n", strcmp(VA, msg2) == 0 ? "right" : "wrong");
  80013f:	83 c4 08             	add    $0x8,%esp
  800142:	ff 35 00 30 80 00    	pushl  0x803000
  800148:	68 00 00 00 a0       	push   $0xa0000000
  80014d:	e8 35 08 00 00       	call   800987 <strcmp>
  800152:	83 c4 08             	add    $0x8,%esp
  800155:	85 c0                	test   %eax,%eax
  800157:	ba 86 28 80 00       	mov    $0x802886,%edx
  80015c:	b8 80 28 80 00       	mov    $0x802880,%eax
  800161:	0f 45 c2             	cmovne %edx,%eax
  800164:	50                   	push   %eax
  800165:	68 f3 28 80 00       	push   $0x8028f3
  80016a:	e8 42 01 00 00       	call   8002b1 <cprintf>
#include <inc/types.h>

static inline void
breakpoint(void)
{
	asm volatile("int3");
  80016f:	cc                   	int3   

	breakpoint();
}
  800170:	83 c4 10             	add    $0x10,%esp
  800173:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800176:	c9                   	leave  
  800177:	c3                   	ret    

00800178 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800178:	55                   	push   %ebp
  800179:	89 e5                	mov    %esp,%ebp
  80017b:	56                   	push   %esi
  80017c:	53                   	push   %ebx
  80017d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800180:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	envid_t envid = sys_getenvid();
  800183:	e8 1a 0b 00 00       	call   800ca2 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  800188:	25 ff 03 00 00       	and    $0x3ff,%eax
  80018d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800190:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800195:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80019a:	85 db                	test   %ebx,%ebx
  80019c:	7e 07                	jle    8001a5 <libmain+0x2d>
		binaryname = argv[0];
  80019e:	8b 06                	mov    (%esi),%eax
  8001a0:	a3 08 30 80 00       	mov    %eax,0x803008

	// call user main routine
	umain(argc, argv);
  8001a5:	83 ec 08             	sub    $0x8,%esp
  8001a8:	56                   	push   %esi
  8001a9:	53                   	push   %ebx
  8001aa:	e8 a4 fe ff ff       	call   800053 <umain>

	// exit gracefully
	exit();
  8001af:	e8 0a 00 00 00       	call   8001be <exit>
}
  8001b4:	83 c4 10             	add    $0x10,%esp
  8001b7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001ba:	5b                   	pop    %ebx
  8001bb:	5e                   	pop    %esi
  8001bc:	5d                   	pop    %ebp
  8001bd:	c3                   	ret    

008001be <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001be:	55                   	push   %ebp
  8001bf:	89 e5                	mov    %esp,%ebp
  8001c1:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001c4:	e8 dd 11 00 00       	call   8013a6 <close_all>
	sys_env_destroy(0);
  8001c9:	83 ec 0c             	sub    $0xc,%esp
  8001cc:	6a 00                	push   $0x0
  8001ce:	e8 8e 0a 00 00       	call   800c61 <sys_env_destroy>
}
  8001d3:	83 c4 10             	add    $0x10,%esp
  8001d6:	c9                   	leave  
  8001d7:	c3                   	ret    

008001d8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001d8:	55                   	push   %ebp
  8001d9:	89 e5                	mov    %esp,%ebp
  8001db:	56                   	push   %esi
  8001dc:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001dd:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001e0:	8b 35 08 30 80 00    	mov    0x803008,%esi
  8001e6:	e8 b7 0a 00 00       	call   800ca2 <sys_getenvid>
  8001eb:	83 ec 0c             	sub    $0xc,%esp
  8001ee:	ff 75 0c             	pushl  0xc(%ebp)
  8001f1:	ff 75 08             	pushl  0x8(%ebp)
  8001f4:	56                   	push   %esi
  8001f5:	50                   	push   %eax
  8001f6:	68 38 29 80 00       	push   $0x802938
  8001fb:	e8 b1 00 00 00       	call   8002b1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800200:	83 c4 18             	add    $0x18,%esp
  800203:	53                   	push   %ebx
  800204:	ff 75 10             	pushl  0x10(%ebp)
  800207:	e8 54 00 00 00       	call   800260 <vcprintf>
	cprintf("\n");
  80020c:	c7 04 24 00 2f 80 00 	movl   $0x802f00,(%esp)
  800213:	e8 99 00 00 00       	call   8002b1 <cprintf>
  800218:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80021b:	cc                   	int3   
  80021c:	eb fd                	jmp    80021b <_panic+0x43>

0080021e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80021e:	55                   	push   %ebp
  80021f:	89 e5                	mov    %esp,%ebp
  800221:	53                   	push   %ebx
  800222:	83 ec 04             	sub    $0x4,%esp
  800225:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800228:	8b 13                	mov    (%ebx),%edx
  80022a:	8d 42 01             	lea    0x1(%edx),%eax
  80022d:	89 03                	mov    %eax,(%ebx)
  80022f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800232:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800236:	3d ff 00 00 00       	cmp    $0xff,%eax
  80023b:	75 1a                	jne    800257 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80023d:	83 ec 08             	sub    $0x8,%esp
  800240:	68 ff 00 00 00       	push   $0xff
  800245:	8d 43 08             	lea    0x8(%ebx),%eax
  800248:	50                   	push   %eax
  800249:	e8 d6 09 00 00       	call   800c24 <sys_cputs>
		b->idx = 0;
  80024e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800254:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800257:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80025b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80025e:	c9                   	leave  
  80025f:	c3                   	ret    

00800260 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800260:	55                   	push   %ebp
  800261:	89 e5                	mov    %esp,%ebp
  800263:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800269:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800270:	00 00 00 
	b.cnt = 0;
  800273:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80027a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80027d:	ff 75 0c             	pushl  0xc(%ebp)
  800280:	ff 75 08             	pushl  0x8(%ebp)
  800283:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800289:	50                   	push   %eax
  80028a:	68 1e 02 80 00       	push   $0x80021e
  80028f:	e8 1a 01 00 00       	call   8003ae <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800294:	83 c4 08             	add    $0x8,%esp
  800297:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80029d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002a3:	50                   	push   %eax
  8002a4:	e8 7b 09 00 00       	call   800c24 <sys_cputs>

	return b.cnt;
}
  8002a9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002af:	c9                   	leave  
  8002b0:	c3                   	ret    

008002b1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002b1:	55                   	push   %ebp
  8002b2:	89 e5                	mov    %esp,%ebp
  8002b4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002b7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002ba:	50                   	push   %eax
  8002bb:	ff 75 08             	pushl  0x8(%ebp)
  8002be:	e8 9d ff ff ff       	call   800260 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002c3:	c9                   	leave  
  8002c4:	c3                   	ret    

008002c5 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002c5:	55                   	push   %ebp
  8002c6:	89 e5                	mov    %esp,%ebp
  8002c8:	57                   	push   %edi
  8002c9:	56                   	push   %esi
  8002ca:	53                   	push   %ebx
  8002cb:	83 ec 1c             	sub    $0x1c,%esp
  8002ce:	89 c7                	mov    %eax,%edi
  8002d0:	89 d6                	mov    %edx,%esi
  8002d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002d8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002db:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002de:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002e1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002e6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002e9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002ec:	39 d3                	cmp    %edx,%ebx
  8002ee:	72 05                	jb     8002f5 <printnum+0x30>
  8002f0:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002f3:	77 45                	ja     80033a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002f5:	83 ec 0c             	sub    $0xc,%esp
  8002f8:	ff 75 18             	pushl  0x18(%ebp)
  8002fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8002fe:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800301:	53                   	push   %ebx
  800302:	ff 75 10             	pushl  0x10(%ebp)
  800305:	83 ec 08             	sub    $0x8,%esp
  800308:	ff 75 e4             	pushl  -0x1c(%ebp)
  80030b:	ff 75 e0             	pushl  -0x20(%ebp)
  80030e:	ff 75 dc             	pushl  -0x24(%ebp)
  800311:	ff 75 d8             	pushl  -0x28(%ebp)
  800314:	e8 c7 22 00 00       	call   8025e0 <__udivdi3>
  800319:	83 c4 18             	add    $0x18,%esp
  80031c:	52                   	push   %edx
  80031d:	50                   	push   %eax
  80031e:	89 f2                	mov    %esi,%edx
  800320:	89 f8                	mov    %edi,%eax
  800322:	e8 9e ff ff ff       	call   8002c5 <printnum>
  800327:	83 c4 20             	add    $0x20,%esp
  80032a:	eb 18                	jmp    800344 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80032c:	83 ec 08             	sub    $0x8,%esp
  80032f:	56                   	push   %esi
  800330:	ff 75 18             	pushl  0x18(%ebp)
  800333:	ff d7                	call   *%edi
  800335:	83 c4 10             	add    $0x10,%esp
  800338:	eb 03                	jmp    80033d <printnum+0x78>
  80033a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80033d:	83 eb 01             	sub    $0x1,%ebx
  800340:	85 db                	test   %ebx,%ebx
  800342:	7f e8                	jg     80032c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800344:	83 ec 08             	sub    $0x8,%esp
  800347:	56                   	push   %esi
  800348:	83 ec 04             	sub    $0x4,%esp
  80034b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80034e:	ff 75 e0             	pushl  -0x20(%ebp)
  800351:	ff 75 dc             	pushl  -0x24(%ebp)
  800354:	ff 75 d8             	pushl  -0x28(%ebp)
  800357:	e8 b4 23 00 00       	call   802710 <__umoddi3>
  80035c:	83 c4 14             	add    $0x14,%esp
  80035f:	0f be 80 5b 29 80 00 	movsbl 0x80295b(%eax),%eax
  800366:	50                   	push   %eax
  800367:	ff d7                	call   *%edi
}
  800369:	83 c4 10             	add    $0x10,%esp
  80036c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80036f:	5b                   	pop    %ebx
  800370:	5e                   	pop    %esi
  800371:	5f                   	pop    %edi
  800372:	5d                   	pop    %ebp
  800373:	c3                   	ret    

00800374 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800374:	55                   	push   %ebp
  800375:	89 e5                	mov    %esp,%ebp
  800377:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80037a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80037e:	8b 10                	mov    (%eax),%edx
  800380:	3b 50 04             	cmp    0x4(%eax),%edx
  800383:	73 0a                	jae    80038f <sprintputch+0x1b>
		*b->buf++ = ch;
  800385:	8d 4a 01             	lea    0x1(%edx),%ecx
  800388:	89 08                	mov    %ecx,(%eax)
  80038a:	8b 45 08             	mov    0x8(%ebp),%eax
  80038d:	88 02                	mov    %al,(%edx)
}
  80038f:	5d                   	pop    %ebp
  800390:	c3                   	ret    

00800391 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800391:	55                   	push   %ebp
  800392:	89 e5                	mov    %esp,%ebp
  800394:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800397:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80039a:	50                   	push   %eax
  80039b:	ff 75 10             	pushl  0x10(%ebp)
  80039e:	ff 75 0c             	pushl  0xc(%ebp)
  8003a1:	ff 75 08             	pushl  0x8(%ebp)
  8003a4:	e8 05 00 00 00       	call   8003ae <vprintfmt>
	va_end(ap);
}
  8003a9:	83 c4 10             	add    $0x10,%esp
  8003ac:	c9                   	leave  
  8003ad:	c3                   	ret    

008003ae <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003ae:	55                   	push   %ebp
  8003af:	89 e5                	mov    %esp,%ebp
  8003b1:	57                   	push   %edi
  8003b2:	56                   	push   %esi
  8003b3:	53                   	push   %ebx
  8003b4:	83 ec 2c             	sub    $0x2c,%esp
  8003b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8003ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003bd:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003c0:	eb 12                	jmp    8003d4 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003c2:	85 c0                	test   %eax,%eax
  8003c4:	0f 84 6a 04 00 00    	je     800834 <vprintfmt+0x486>
				return;
			putch(ch, putdat);
  8003ca:	83 ec 08             	sub    $0x8,%esp
  8003cd:	53                   	push   %ebx
  8003ce:	50                   	push   %eax
  8003cf:	ff d6                	call   *%esi
  8003d1:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003d4:	83 c7 01             	add    $0x1,%edi
  8003d7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003db:	83 f8 25             	cmp    $0x25,%eax
  8003de:	75 e2                	jne    8003c2 <vprintfmt+0x14>
  8003e0:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003e4:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003eb:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003f2:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003f9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003fe:	eb 07                	jmp    800407 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800400:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800403:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800407:	8d 47 01             	lea    0x1(%edi),%eax
  80040a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80040d:	0f b6 07             	movzbl (%edi),%eax
  800410:	0f b6 d0             	movzbl %al,%edx
  800413:	83 e8 23             	sub    $0x23,%eax
  800416:	3c 55                	cmp    $0x55,%al
  800418:	0f 87 fb 03 00 00    	ja     800819 <vprintfmt+0x46b>
  80041e:	0f b6 c0             	movzbl %al,%eax
  800421:	ff 24 85 a0 2a 80 00 	jmp    *0x802aa0(,%eax,4)
  800428:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80042b:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80042f:	eb d6                	jmp    800407 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800431:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800434:	b8 00 00 00 00       	mov    $0x0,%eax
  800439:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80043c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80043f:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800443:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800446:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800449:	83 f9 09             	cmp    $0x9,%ecx
  80044c:	77 3f                	ja     80048d <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80044e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800451:	eb e9                	jmp    80043c <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800453:	8b 45 14             	mov    0x14(%ebp),%eax
  800456:	8b 00                	mov    (%eax),%eax
  800458:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80045b:	8b 45 14             	mov    0x14(%ebp),%eax
  80045e:	8d 40 04             	lea    0x4(%eax),%eax
  800461:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800464:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800467:	eb 2a                	jmp    800493 <vprintfmt+0xe5>
  800469:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80046c:	85 c0                	test   %eax,%eax
  80046e:	ba 00 00 00 00       	mov    $0x0,%edx
  800473:	0f 49 d0             	cmovns %eax,%edx
  800476:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800479:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80047c:	eb 89                	jmp    800407 <vprintfmt+0x59>
  80047e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800481:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800488:	e9 7a ff ff ff       	jmp    800407 <vprintfmt+0x59>
  80048d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800490:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800493:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800497:	0f 89 6a ff ff ff    	jns    800407 <vprintfmt+0x59>
				width = precision, precision = -1;
  80049d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004a0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004a3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004aa:	e9 58 ff ff ff       	jmp    800407 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004af:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004b5:	e9 4d ff ff ff       	jmp    800407 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8004bd:	8d 78 04             	lea    0x4(%eax),%edi
  8004c0:	83 ec 08             	sub    $0x8,%esp
  8004c3:	53                   	push   %ebx
  8004c4:	ff 30                	pushl  (%eax)
  8004c6:	ff d6                	call   *%esi
			break;
  8004c8:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004cb:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004d1:	e9 fe fe ff ff       	jmp    8003d4 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d9:	8d 78 04             	lea    0x4(%eax),%edi
  8004dc:	8b 00                	mov    (%eax),%eax
  8004de:	99                   	cltd   
  8004df:	31 d0                	xor    %edx,%eax
  8004e1:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004e3:	83 f8 0f             	cmp    $0xf,%eax
  8004e6:	7f 0b                	jg     8004f3 <vprintfmt+0x145>
  8004e8:	8b 14 85 00 2c 80 00 	mov    0x802c00(,%eax,4),%edx
  8004ef:	85 d2                	test   %edx,%edx
  8004f1:	75 1b                	jne    80050e <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  8004f3:	50                   	push   %eax
  8004f4:	68 73 29 80 00       	push   $0x802973
  8004f9:	53                   	push   %ebx
  8004fa:	56                   	push   %esi
  8004fb:	e8 91 fe ff ff       	call   800391 <printfmt>
  800500:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800503:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800506:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800509:	e9 c6 fe ff ff       	jmp    8003d4 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80050e:	52                   	push   %edx
  80050f:	68 3a 2e 80 00       	push   $0x802e3a
  800514:	53                   	push   %ebx
  800515:	56                   	push   %esi
  800516:	e8 76 fe ff ff       	call   800391 <printfmt>
  80051b:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80051e:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800521:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800524:	e9 ab fe ff ff       	jmp    8003d4 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800529:	8b 45 14             	mov    0x14(%ebp),%eax
  80052c:	83 c0 04             	add    $0x4,%eax
  80052f:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800532:	8b 45 14             	mov    0x14(%ebp),%eax
  800535:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800537:	85 ff                	test   %edi,%edi
  800539:	b8 6c 29 80 00       	mov    $0x80296c,%eax
  80053e:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800541:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800545:	0f 8e 94 00 00 00    	jle    8005df <vprintfmt+0x231>
  80054b:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80054f:	0f 84 98 00 00 00    	je     8005ed <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800555:	83 ec 08             	sub    $0x8,%esp
  800558:	ff 75 d0             	pushl  -0x30(%ebp)
  80055b:	57                   	push   %edi
  80055c:	e8 5b 03 00 00       	call   8008bc <strnlen>
  800561:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800564:	29 c1                	sub    %eax,%ecx
  800566:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800569:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80056c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800570:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800573:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800576:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800578:	eb 0f                	jmp    800589 <vprintfmt+0x1db>
					putch(padc, putdat);
  80057a:	83 ec 08             	sub    $0x8,%esp
  80057d:	53                   	push   %ebx
  80057e:	ff 75 e0             	pushl  -0x20(%ebp)
  800581:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800583:	83 ef 01             	sub    $0x1,%edi
  800586:	83 c4 10             	add    $0x10,%esp
  800589:	85 ff                	test   %edi,%edi
  80058b:	7f ed                	jg     80057a <vprintfmt+0x1cc>
  80058d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800590:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800593:	85 c9                	test   %ecx,%ecx
  800595:	b8 00 00 00 00       	mov    $0x0,%eax
  80059a:	0f 49 c1             	cmovns %ecx,%eax
  80059d:	29 c1                	sub    %eax,%ecx
  80059f:	89 75 08             	mov    %esi,0x8(%ebp)
  8005a2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005a5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005a8:	89 cb                	mov    %ecx,%ebx
  8005aa:	eb 4d                	jmp    8005f9 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005ac:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005b0:	74 1b                	je     8005cd <vprintfmt+0x21f>
  8005b2:	0f be c0             	movsbl %al,%eax
  8005b5:	83 e8 20             	sub    $0x20,%eax
  8005b8:	83 f8 5e             	cmp    $0x5e,%eax
  8005bb:	76 10                	jbe    8005cd <vprintfmt+0x21f>
					putch('?', putdat);
  8005bd:	83 ec 08             	sub    $0x8,%esp
  8005c0:	ff 75 0c             	pushl  0xc(%ebp)
  8005c3:	6a 3f                	push   $0x3f
  8005c5:	ff 55 08             	call   *0x8(%ebp)
  8005c8:	83 c4 10             	add    $0x10,%esp
  8005cb:	eb 0d                	jmp    8005da <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  8005cd:	83 ec 08             	sub    $0x8,%esp
  8005d0:	ff 75 0c             	pushl  0xc(%ebp)
  8005d3:	52                   	push   %edx
  8005d4:	ff 55 08             	call   *0x8(%ebp)
  8005d7:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005da:	83 eb 01             	sub    $0x1,%ebx
  8005dd:	eb 1a                	jmp    8005f9 <vprintfmt+0x24b>
  8005df:	89 75 08             	mov    %esi,0x8(%ebp)
  8005e2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005e5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005e8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005eb:	eb 0c                	jmp    8005f9 <vprintfmt+0x24b>
  8005ed:	89 75 08             	mov    %esi,0x8(%ebp)
  8005f0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005f3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005f6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005f9:	83 c7 01             	add    $0x1,%edi
  8005fc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800600:	0f be d0             	movsbl %al,%edx
  800603:	85 d2                	test   %edx,%edx
  800605:	74 23                	je     80062a <vprintfmt+0x27c>
  800607:	85 f6                	test   %esi,%esi
  800609:	78 a1                	js     8005ac <vprintfmt+0x1fe>
  80060b:	83 ee 01             	sub    $0x1,%esi
  80060e:	79 9c                	jns    8005ac <vprintfmt+0x1fe>
  800610:	89 df                	mov    %ebx,%edi
  800612:	8b 75 08             	mov    0x8(%ebp),%esi
  800615:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800618:	eb 18                	jmp    800632 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80061a:	83 ec 08             	sub    $0x8,%esp
  80061d:	53                   	push   %ebx
  80061e:	6a 20                	push   $0x20
  800620:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800622:	83 ef 01             	sub    $0x1,%edi
  800625:	83 c4 10             	add    $0x10,%esp
  800628:	eb 08                	jmp    800632 <vprintfmt+0x284>
  80062a:	89 df                	mov    %ebx,%edi
  80062c:	8b 75 08             	mov    0x8(%ebp),%esi
  80062f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800632:	85 ff                	test   %edi,%edi
  800634:	7f e4                	jg     80061a <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800636:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800639:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80063f:	e9 90 fd ff ff       	jmp    8003d4 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800644:	83 f9 01             	cmp    $0x1,%ecx
  800647:	7e 19                	jle    800662 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800649:	8b 45 14             	mov    0x14(%ebp),%eax
  80064c:	8b 50 04             	mov    0x4(%eax),%edx
  80064f:	8b 00                	mov    (%eax),%eax
  800651:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800654:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800657:	8b 45 14             	mov    0x14(%ebp),%eax
  80065a:	8d 40 08             	lea    0x8(%eax),%eax
  80065d:	89 45 14             	mov    %eax,0x14(%ebp)
  800660:	eb 38                	jmp    80069a <vprintfmt+0x2ec>
	else if (lflag)
  800662:	85 c9                	test   %ecx,%ecx
  800664:	74 1b                	je     800681 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800666:	8b 45 14             	mov    0x14(%ebp),%eax
  800669:	8b 00                	mov    (%eax),%eax
  80066b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80066e:	89 c1                	mov    %eax,%ecx
  800670:	c1 f9 1f             	sar    $0x1f,%ecx
  800673:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800676:	8b 45 14             	mov    0x14(%ebp),%eax
  800679:	8d 40 04             	lea    0x4(%eax),%eax
  80067c:	89 45 14             	mov    %eax,0x14(%ebp)
  80067f:	eb 19                	jmp    80069a <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800681:	8b 45 14             	mov    0x14(%ebp),%eax
  800684:	8b 00                	mov    (%eax),%eax
  800686:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800689:	89 c1                	mov    %eax,%ecx
  80068b:	c1 f9 1f             	sar    $0x1f,%ecx
  80068e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800691:	8b 45 14             	mov    0x14(%ebp),%eax
  800694:	8d 40 04             	lea    0x4(%eax),%eax
  800697:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80069a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80069d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006a0:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006a5:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006a9:	0f 89 36 01 00 00    	jns    8007e5 <vprintfmt+0x437>
				putch('-', putdat);
  8006af:	83 ec 08             	sub    $0x8,%esp
  8006b2:	53                   	push   %ebx
  8006b3:	6a 2d                	push   $0x2d
  8006b5:	ff d6                	call   *%esi
				num = -(long long) num;
  8006b7:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006ba:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8006bd:	f7 da                	neg    %edx
  8006bf:	83 d1 00             	adc    $0x0,%ecx
  8006c2:	f7 d9                	neg    %ecx
  8006c4:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8006c7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006cc:	e9 14 01 00 00       	jmp    8007e5 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006d1:	83 f9 01             	cmp    $0x1,%ecx
  8006d4:	7e 18                	jle    8006ee <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  8006d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d9:	8b 10                	mov    (%eax),%edx
  8006db:	8b 48 04             	mov    0x4(%eax),%ecx
  8006de:	8d 40 08             	lea    0x8(%eax),%eax
  8006e1:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8006e4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006e9:	e9 f7 00 00 00       	jmp    8007e5 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8006ee:	85 c9                	test   %ecx,%ecx
  8006f0:	74 1a                	je     80070c <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  8006f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f5:	8b 10                	mov    (%eax),%edx
  8006f7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006fc:	8d 40 04             	lea    0x4(%eax),%eax
  8006ff:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800702:	b8 0a 00 00 00       	mov    $0xa,%eax
  800707:	e9 d9 00 00 00       	jmp    8007e5 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80070c:	8b 45 14             	mov    0x14(%ebp),%eax
  80070f:	8b 10                	mov    (%eax),%edx
  800711:	b9 00 00 00 00       	mov    $0x0,%ecx
  800716:	8d 40 04             	lea    0x4(%eax),%eax
  800719:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80071c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800721:	e9 bf 00 00 00       	jmp    8007e5 <vprintfmt+0x437>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800726:	83 f9 01             	cmp    $0x1,%ecx
  800729:	7e 13                	jle    80073e <vprintfmt+0x390>
		return va_arg(*ap, long long);
  80072b:	8b 45 14             	mov    0x14(%ebp),%eax
  80072e:	8b 50 04             	mov    0x4(%eax),%edx
  800731:	8b 00                	mov    (%eax),%eax
  800733:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800736:	8d 49 08             	lea    0x8(%ecx),%ecx
  800739:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80073c:	eb 28                	jmp    800766 <vprintfmt+0x3b8>
	else if (lflag)
  80073e:	85 c9                	test   %ecx,%ecx
  800740:	74 13                	je     800755 <vprintfmt+0x3a7>
		return va_arg(*ap, long);
  800742:	8b 45 14             	mov    0x14(%ebp),%eax
  800745:	8b 10                	mov    (%eax),%edx
  800747:	89 d0                	mov    %edx,%eax
  800749:	99                   	cltd   
  80074a:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80074d:	8d 49 04             	lea    0x4(%ecx),%ecx
  800750:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800753:	eb 11                	jmp    800766 <vprintfmt+0x3b8>
	else
		return va_arg(*ap, int);
  800755:	8b 45 14             	mov    0x14(%ebp),%eax
  800758:	8b 10                	mov    (%eax),%edx
  80075a:	89 d0                	mov    %edx,%eax
  80075c:	99                   	cltd   
  80075d:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800760:	8d 49 04             	lea    0x4(%ecx),%ecx
  800763:	89 4d 14             	mov    %ecx,0x14(%ebp)
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getint(&ap, lflag);
  800766:	89 d1                	mov    %edx,%ecx
  800768:	89 c2                	mov    %eax,%edx
			base = 8;
  80076a:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  80076f:	eb 74                	jmp    8007e5 <vprintfmt+0x437>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800771:	83 ec 08             	sub    $0x8,%esp
  800774:	53                   	push   %ebx
  800775:	6a 30                	push   $0x30
  800777:	ff d6                	call   *%esi
			putch('x', putdat);
  800779:	83 c4 08             	add    $0x8,%esp
  80077c:	53                   	push   %ebx
  80077d:	6a 78                	push   $0x78
  80077f:	ff d6                	call   *%esi
			num = (unsigned long long)
  800781:	8b 45 14             	mov    0x14(%ebp),%eax
  800784:	8b 10                	mov    (%eax),%edx
  800786:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80078b:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80078e:	8d 40 04             	lea    0x4(%eax),%eax
  800791:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800794:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800799:	eb 4a                	jmp    8007e5 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80079b:	83 f9 01             	cmp    $0x1,%ecx
  80079e:	7e 15                	jle    8007b5 <vprintfmt+0x407>
		return va_arg(*ap, unsigned long long);
  8007a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a3:	8b 10                	mov    (%eax),%edx
  8007a5:	8b 48 04             	mov    0x4(%eax),%ecx
  8007a8:	8d 40 08             	lea    0x8(%eax),%eax
  8007ab:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8007ae:	b8 10 00 00 00       	mov    $0x10,%eax
  8007b3:	eb 30                	jmp    8007e5 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8007b5:	85 c9                	test   %ecx,%ecx
  8007b7:	74 17                	je     8007d0 <vprintfmt+0x422>
		return va_arg(*ap, unsigned long);
  8007b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007bc:	8b 10                	mov    (%eax),%edx
  8007be:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007c3:	8d 40 04             	lea    0x4(%eax),%eax
  8007c6:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8007c9:	b8 10 00 00 00       	mov    $0x10,%eax
  8007ce:	eb 15                	jmp    8007e5 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8007d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d3:	8b 10                	mov    (%eax),%edx
  8007d5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007da:	8d 40 04             	lea    0x4(%eax),%eax
  8007dd:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8007e0:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007e5:	83 ec 0c             	sub    $0xc,%esp
  8007e8:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8007ec:	57                   	push   %edi
  8007ed:	ff 75 e0             	pushl  -0x20(%ebp)
  8007f0:	50                   	push   %eax
  8007f1:	51                   	push   %ecx
  8007f2:	52                   	push   %edx
  8007f3:	89 da                	mov    %ebx,%edx
  8007f5:	89 f0                	mov    %esi,%eax
  8007f7:	e8 c9 fa ff ff       	call   8002c5 <printnum>
			break;
  8007fc:	83 c4 20             	add    $0x20,%esp
  8007ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800802:	e9 cd fb ff ff       	jmp    8003d4 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800807:	83 ec 08             	sub    $0x8,%esp
  80080a:	53                   	push   %ebx
  80080b:	52                   	push   %edx
  80080c:	ff d6                	call   *%esi
			break;
  80080e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800811:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800814:	e9 bb fb ff ff       	jmp    8003d4 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800819:	83 ec 08             	sub    $0x8,%esp
  80081c:	53                   	push   %ebx
  80081d:	6a 25                	push   $0x25
  80081f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800821:	83 c4 10             	add    $0x10,%esp
  800824:	eb 03                	jmp    800829 <vprintfmt+0x47b>
  800826:	83 ef 01             	sub    $0x1,%edi
  800829:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80082d:	75 f7                	jne    800826 <vprintfmt+0x478>
  80082f:	e9 a0 fb ff ff       	jmp    8003d4 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800834:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800837:	5b                   	pop    %ebx
  800838:	5e                   	pop    %esi
  800839:	5f                   	pop    %edi
  80083a:	5d                   	pop    %ebp
  80083b:	c3                   	ret    

0080083c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80083c:	55                   	push   %ebp
  80083d:	89 e5                	mov    %esp,%ebp
  80083f:	83 ec 18             	sub    $0x18,%esp
  800842:	8b 45 08             	mov    0x8(%ebp),%eax
  800845:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800848:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80084b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80084f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800852:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800859:	85 c0                	test   %eax,%eax
  80085b:	74 26                	je     800883 <vsnprintf+0x47>
  80085d:	85 d2                	test   %edx,%edx
  80085f:	7e 22                	jle    800883 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800861:	ff 75 14             	pushl  0x14(%ebp)
  800864:	ff 75 10             	pushl  0x10(%ebp)
  800867:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80086a:	50                   	push   %eax
  80086b:	68 74 03 80 00       	push   $0x800374
  800870:	e8 39 fb ff ff       	call   8003ae <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800875:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800878:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80087b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80087e:	83 c4 10             	add    $0x10,%esp
  800881:	eb 05                	jmp    800888 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800883:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800888:	c9                   	leave  
  800889:	c3                   	ret    

0080088a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80088a:	55                   	push   %ebp
  80088b:	89 e5                	mov    %esp,%ebp
  80088d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800890:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800893:	50                   	push   %eax
  800894:	ff 75 10             	pushl  0x10(%ebp)
  800897:	ff 75 0c             	pushl  0xc(%ebp)
  80089a:	ff 75 08             	pushl  0x8(%ebp)
  80089d:	e8 9a ff ff ff       	call   80083c <vsnprintf>
	va_end(ap);

	return rc;
}
  8008a2:	c9                   	leave  
  8008a3:	c3                   	ret    

008008a4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008a4:	55                   	push   %ebp
  8008a5:	89 e5                	mov    %esp,%ebp
  8008a7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8008af:	eb 03                	jmp    8008b4 <strlen+0x10>
		n++;
  8008b1:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008b4:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008b8:	75 f7                	jne    8008b1 <strlen+0xd>
		n++;
	return n;
}
  8008ba:	5d                   	pop    %ebp
  8008bb:	c3                   	ret    

008008bc <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008bc:	55                   	push   %ebp
  8008bd:	89 e5                	mov    %esp,%ebp
  8008bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008c2:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8008ca:	eb 03                	jmp    8008cf <strnlen+0x13>
		n++;
  8008cc:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008cf:	39 c2                	cmp    %eax,%edx
  8008d1:	74 08                	je     8008db <strnlen+0x1f>
  8008d3:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8008d7:	75 f3                	jne    8008cc <strnlen+0x10>
  8008d9:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8008db:	5d                   	pop    %ebp
  8008dc:	c3                   	ret    

008008dd <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008dd:	55                   	push   %ebp
  8008de:	89 e5                	mov    %esp,%ebp
  8008e0:	53                   	push   %ebx
  8008e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008e7:	89 c2                	mov    %eax,%edx
  8008e9:	83 c2 01             	add    $0x1,%edx
  8008ec:	83 c1 01             	add    $0x1,%ecx
  8008ef:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008f3:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008f6:	84 db                	test   %bl,%bl
  8008f8:	75 ef                	jne    8008e9 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008fa:	5b                   	pop    %ebx
  8008fb:	5d                   	pop    %ebp
  8008fc:	c3                   	ret    

008008fd <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008fd:	55                   	push   %ebp
  8008fe:	89 e5                	mov    %esp,%ebp
  800900:	53                   	push   %ebx
  800901:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800904:	53                   	push   %ebx
  800905:	e8 9a ff ff ff       	call   8008a4 <strlen>
  80090a:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80090d:	ff 75 0c             	pushl  0xc(%ebp)
  800910:	01 d8                	add    %ebx,%eax
  800912:	50                   	push   %eax
  800913:	e8 c5 ff ff ff       	call   8008dd <strcpy>
	return dst;
}
  800918:	89 d8                	mov    %ebx,%eax
  80091a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80091d:	c9                   	leave  
  80091e:	c3                   	ret    

0080091f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80091f:	55                   	push   %ebp
  800920:	89 e5                	mov    %esp,%ebp
  800922:	56                   	push   %esi
  800923:	53                   	push   %ebx
  800924:	8b 75 08             	mov    0x8(%ebp),%esi
  800927:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80092a:	89 f3                	mov    %esi,%ebx
  80092c:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80092f:	89 f2                	mov    %esi,%edx
  800931:	eb 0f                	jmp    800942 <strncpy+0x23>
		*dst++ = *src;
  800933:	83 c2 01             	add    $0x1,%edx
  800936:	0f b6 01             	movzbl (%ecx),%eax
  800939:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80093c:	80 39 01             	cmpb   $0x1,(%ecx)
  80093f:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800942:	39 da                	cmp    %ebx,%edx
  800944:	75 ed                	jne    800933 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800946:	89 f0                	mov    %esi,%eax
  800948:	5b                   	pop    %ebx
  800949:	5e                   	pop    %esi
  80094a:	5d                   	pop    %ebp
  80094b:	c3                   	ret    

0080094c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80094c:	55                   	push   %ebp
  80094d:	89 e5                	mov    %esp,%ebp
  80094f:	56                   	push   %esi
  800950:	53                   	push   %ebx
  800951:	8b 75 08             	mov    0x8(%ebp),%esi
  800954:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800957:	8b 55 10             	mov    0x10(%ebp),%edx
  80095a:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80095c:	85 d2                	test   %edx,%edx
  80095e:	74 21                	je     800981 <strlcpy+0x35>
  800960:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800964:	89 f2                	mov    %esi,%edx
  800966:	eb 09                	jmp    800971 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800968:	83 c2 01             	add    $0x1,%edx
  80096b:	83 c1 01             	add    $0x1,%ecx
  80096e:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800971:	39 c2                	cmp    %eax,%edx
  800973:	74 09                	je     80097e <strlcpy+0x32>
  800975:	0f b6 19             	movzbl (%ecx),%ebx
  800978:	84 db                	test   %bl,%bl
  80097a:	75 ec                	jne    800968 <strlcpy+0x1c>
  80097c:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80097e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800981:	29 f0                	sub    %esi,%eax
}
  800983:	5b                   	pop    %ebx
  800984:	5e                   	pop    %esi
  800985:	5d                   	pop    %ebp
  800986:	c3                   	ret    

00800987 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800987:	55                   	push   %ebp
  800988:	89 e5                	mov    %esp,%ebp
  80098a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80098d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800990:	eb 06                	jmp    800998 <strcmp+0x11>
		p++, q++;
  800992:	83 c1 01             	add    $0x1,%ecx
  800995:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800998:	0f b6 01             	movzbl (%ecx),%eax
  80099b:	84 c0                	test   %al,%al
  80099d:	74 04                	je     8009a3 <strcmp+0x1c>
  80099f:	3a 02                	cmp    (%edx),%al
  8009a1:	74 ef                	je     800992 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009a3:	0f b6 c0             	movzbl %al,%eax
  8009a6:	0f b6 12             	movzbl (%edx),%edx
  8009a9:	29 d0                	sub    %edx,%eax
}
  8009ab:	5d                   	pop    %ebp
  8009ac:	c3                   	ret    

008009ad <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009ad:	55                   	push   %ebp
  8009ae:	89 e5                	mov    %esp,%ebp
  8009b0:	53                   	push   %ebx
  8009b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009b7:	89 c3                	mov    %eax,%ebx
  8009b9:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009bc:	eb 06                	jmp    8009c4 <strncmp+0x17>
		n--, p++, q++;
  8009be:	83 c0 01             	add    $0x1,%eax
  8009c1:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009c4:	39 d8                	cmp    %ebx,%eax
  8009c6:	74 15                	je     8009dd <strncmp+0x30>
  8009c8:	0f b6 08             	movzbl (%eax),%ecx
  8009cb:	84 c9                	test   %cl,%cl
  8009cd:	74 04                	je     8009d3 <strncmp+0x26>
  8009cf:	3a 0a                	cmp    (%edx),%cl
  8009d1:	74 eb                	je     8009be <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009d3:	0f b6 00             	movzbl (%eax),%eax
  8009d6:	0f b6 12             	movzbl (%edx),%edx
  8009d9:	29 d0                	sub    %edx,%eax
  8009db:	eb 05                	jmp    8009e2 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009dd:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009e2:	5b                   	pop    %ebx
  8009e3:	5d                   	pop    %ebp
  8009e4:	c3                   	ret    

008009e5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009e5:	55                   	push   %ebp
  8009e6:	89 e5                	mov    %esp,%ebp
  8009e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009eb:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009ef:	eb 07                	jmp    8009f8 <strchr+0x13>
		if (*s == c)
  8009f1:	38 ca                	cmp    %cl,%dl
  8009f3:	74 0f                	je     800a04 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009f5:	83 c0 01             	add    $0x1,%eax
  8009f8:	0f b6 10             	movzbl (%eax),%edx
  8009fb:	84 d2                	test   %dl,%dl
  8009fd:	75 f2                	jne    8009f1 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009ff:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a04:	5d                   	pop    %ebp
  800a05:	c3                   	ret    

00800a06 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a06:	55                   	push   %ebp
  800a07:	89 e5                	mov    %esp,%ebp
  800a09:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a10:	eb 03                	jmp    800a15 <strfind+0xf>
  800a12:	83 c0 01             	add    $0x1,%eax
  800a15:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a18:	38 ca                	cmp    %cl,%dl
  800a1a:	74 04                	je     800a20 <strfind+0x1a>
  800a1c:	84 d2                	test   %dl,%dl
  800a1e:	75 f2                	jne    800a12 <strfind+0xc>
			break;
	return (char *) s;
}
  800a20:	5d                   	pop    %ebp
  800a21:	c3                   	ret    

00800a22 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a22:	55                   	push   %ebp
  800a23:	89 e5                	mov    %esp,%ebp
  800a25:	57                   	push   %edi
  800a26:	56                   	push   %esi
  800a27:	53                   	push   %ebx
  800a28:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a2b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a2e:	85 c9                	test   %ecx,%ecx
  800a30:	74 36                	je     800a68 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a32:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a38:	75 28                	jne    800a62 <memset+0x40>
  800a3a:	f6 c1 03             	test   $0x3,%cl
  800a3d:	75 23                	jne    800a62 <memset+0x40>
		c &= 0xFF;
  800a3f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a43:	89 d3                	mov    %edx,%ebx
  800a45:	c1 e3 08             	shl    $0x8,%ebx
  800a48:	89 d6                	mov    %edx,%esi
  800a4a:	c1 e6 18             	shl    $0x18,%esi
  800a4d:	89 d0                	mov    %edx,%eax
  800a4f:	c1 e0 10             	shl    $0x10,%eax
  800a52:	09 f0                	or     %esi,%eax
  800a54:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a56:	89 d8                	mov    %ebx,%eax
  800a58:	09 d0                	or     %edx,%eax
  800a5a:	c1 e9 02             	shr    $0x2,%ecx
  800a5d:	fc                   	cld    
  800a5e:	f3 ab                	rep stos %eax,%es:(%edi)
  800a60:	eb 06                	jmp    800a68 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a62:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a65:	fc                   	cld    
  800a66:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a68:	89 f8                	mov    %edi,%eax
  800a6a:	5b                   	pop    %ebx
  800a6b:	5e                   	pop    %esi
  800a6c:	5f                   	pop    %edi
  800a6d:	5d                   	pop    %ebp
  800a6e:	c3                   	ret    

00800a6f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a6f:	55                   	push   %ebp
  800a70:	89 e5                	mov    %esp,%ebp
  800a72:	57                   	push   %edi
  800a73:	56                   	push   %esi
  800a74:	8b 45 08             	mov    0x8(%ebp),%eax
  800a77:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a7a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a7d:	39 c6                	cmp    %eax,%esi
  800a7f:	73 35                	jae    800ab6 <memmove+0x47>
  800a81:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a84:	39 d0                	cmp    %edx,%eax
  800a86:	73 2e                	jae    800ab6 <memmove+0x47>
		s += n;
		d += n;
  800a88:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a8b:	89 d6                	mov    %edx,%esi
  800a8d:	09 fe                	or     %edi,%esi
  800a8f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a95:	75 13                	jne    800aaa <memmove+0x3b>
  800a97:	f6 c1 03             	test   $0x3,%cl
  800a9a:	75 0e                	jne    800aaa <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a9c:	83 ef 04             	sub    $0x4,%edi
  800a9f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800aa2:	c1 e9 02             	shr    $0x2,%ecx
  800aa5:	fd                   	std    
  800aa6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aa8:	eb 09                	jmp    800ab3 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800aaa:	83 ef 01             	sub    $0x1,%edi
  800aad:	8d 72 ff             	lea    -0x1(%edx),%esi
  800ab0:	fd                   	std    
  800ab1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ab3:	fc                   	cld    
  800ab4:	eb 1d                	jmp    800ad3 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ab6:	89 f2                	mov    %esi,%edx
  800ab8:	09 c2                	or     %eax,%edx
  800aba:	f6 c2 03             	test   $0x3,%dl
  800abd:	75 0f                	jne    800ace <memmove+0x5f>
  800abf:	f6 c1 03             	test   $0x3,%cl
  800ac2:	75 0a                	jne    800ace <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800ac4:	c1 e9 02             	shr    $0x2,%ecx
  800ac7:	89 c7                	mov    %eax,%edi
  800ac9:	fc                   	cld    
  800aca:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800acc:	eb 05                	jmp    800ad3 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ace:	89 c7                	mov    %eax,%edi
  800ad0:	fc                   	cld    
  800ad1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ad3:	5e                   	pop    %esi
  800ad4:	5f                   	pop    %edi
  800ad5:	5d                   	pop    %ebp
  800ad6:	c3                   	ret    

00800ad7 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ad7:	55                   	push   %ebp
  800ad8:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800ada:	ff 75 10             	pushl  0x10(%ebp)
  800add:	ff 75 0c             	pushl  0xc(%ebp)
  800ae0:	ff 75 08             	pushl  0x8(%ebp)
  800ae3:	e8 87 ff ff ff       	call   800a6f <memmove>
}
  800ae8:	c9                   	leave  
  800ae9:	c3                   	ret    

00800aea <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800aea:	55                   	push   %ebp
  800aeb:	89 e5                	mov    %esp,%ebp
  800aed:	56                   	push   %esi
  800aee:	53                   	push   %ebx
  800aef:	8b 45 08             	mov    0x8(%ebp),%eax
  800af2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800af5:	89 c6                	mov    %eax,%esi
  800af7:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800afa:	eb 1a                	jmp    800b16 <memcmp+0x2c>
		if (*s1 != *s2)
  800afc:	0f b6 08             	movzbl (%eax),%ecx
  800aff:	0f b6 1a             	movzbl (%edx),%ebx
  800b02:	38 d9                	cmp    %bl,%cl
  800b04:	74 0a                	je     800b10 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b06:	0f b6 c1             	movzbl %cl,%eax
  800b09:	0f b6 db             	movzbl %bl,%ebx
  800b0c:	29 d8                	sub    %ebx,%eax
  800b0e:	eb 0f                	jmp    800b1f <memcmp+0x35>
		s1++, s2++;
  800b10:	83 c0 01             	add    $0x1,%eax
  800b13:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b16:	39 f0                	cmp    %esi,%eax
  800b18:	75 e2                	jne    800afc <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b1a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b1f:	5b                   	pop    %ebx
  800b20:	5e                   	pop    %esi
  800b21:	5d                   	pop    %ebp
  800b22:	c3                   	ret    

00800b23 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b23:	55                   	push   %ebp
  800b24:	89 e5                	mov    %esp,%ebp
  800b26:	53                   	push   %ebx
  800b27:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b2a:	89 c1                	mov    %eax,%ecx
  800b2c:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800b2f:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b33:	eb 0a                	jmp    800b3f <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b35:	0f b6 10             	movzbl (%eax),%edx
  800b38:	39 da                	cmp    %ebx,%edx
  800b3a:	74 07                	je     800b43 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b3c:	83 c0 01             	add    $0x1,%eax
  800b3f:	39 c8                	cmp    %ecx,%eax
  800b41:	72 f2                	jb     800b35 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b43:	5b                   	pop    %ebx
  800b44:	5d                   	pop    %ebp
  800b45:	c3                   	ret    

00800b46 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b46:	55                   	push   %ebp
  800b47:	89 e5                	mov    %esp,%ebp
  800b49:	57                   	push   %edi
  800b4a:	56                   	push   %esi
  800b4b:	53                   	push   %ebx
  800b4c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b4f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b52:	eb 03                	jmp    800b57 <strtol+0x11>
		s++;
  800b54:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b57:	0f b6 01             	movzbl (%ecx),%eax
  800b5a:	3c 20                	cmp    $0x20,%al
  800b5c:	74 f6                	je     800b54 <strtol+0xe>
  800b5e:	3c 09                	cmp    $0x9,%al
  800b60:	74 f2                	je     800b54 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b62:	3c 2b                	cmp    $0x2b,%al
  800b64:	75 0a                	jne    800b70 <strtol+0x2a>
		s++;
  800b66:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b69:	bf 00 00 00 00       	mov    $0x0,%edi
  800b6e:	eb 11                	jmp    800b81 <strtol+0x3b>
  800b70:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b75:	3c 2d                	cmp    $0x2d,%al
  800b77:	75 08                	jne    800b81 <strtol+0x3b>
		s++, neg = 1;
  800b79:	83 c1 01             	add    $0x1,%ecx
  800b7c:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b81:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b87:	75 15                	jne    800b9e <strtol+0x58>
  800b89:	80 39 30             	cmpb   $0x30,(%ecx)
  800b8c:	75 10                	jne    800b9e <strtol+0x58>
  800b8e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b92:	75 7c                	jne    800c10 <strtol+0xca>
		s += 2, base = 16;
  800b94:	83 c1 02             	add    $0x2,%ecx
  800b97:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b9c:	eb 16                	jmp    800bb4 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b9e:	85 db                	test   %ebx,%ebx
  800ba0:	75 12                	jne    800bb4 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ba2:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ba7:	80 39 30             	cmpb   $0x30,(%ecx)
  800baa:	75 08                	jne    800bb4 <strtol+0x6e>
		s++, base = 8;
  800bac:	83 c1 01             	add    $0x1,%ecx
  800baf:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800bb4:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb9:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bbc:	0f b6 11             	movzbl (%ecx),%edx
  800bbf:	8d 72 d0             	lea    -0x30(%edx),%esi
  800bc2:	89 f3                	mov    %esi,%ebx
  800bc4:	80 fb 09             	cmp    $0x9,%bl
  800bc7:	77 08                	ja     800bd1 <strtol+0x8b>
			dig = *s - '0';
  800bc9:	0f be d2             	movsbl %dl,%edx
  800bcc:	83 ea 30             	sub    $0x30,%edx
  800bcf:	eb 22                	jmp    800bf3 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800bd1:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bd4:	89 f3                	mov    %esi,%ebx
  800bd6:	80 fb 19             	cmp    $0x19,%bl
  800bd9:	77 08                	ja     800be3 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800bdb:	0f be d2             	movsbl %dl,%edx
  800bde:	83 ea 57             	sub    $0x57,%edx
  800be1:	eb 10                	jmp    800bf3 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800be3:	8d 72 bf             	lea    -0x41(%edx),%esi
  800be6:	89 f3                	mov    %esi,%ebx
  800be8:	80 fb 19             	cmp    $0x19,%bl
  800beb:	77 16                	ja     800c03 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800bed:	0f be d2             	movsbl %dl,%edx
  800bf0:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800bf3:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bf6:	7d 0b                	jge    800c03 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800bf8:	83 c1 01             	add    $0x1,%ecx
  800bfb:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bff:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c01:	eb b9                	jmp    800bbc <strtol+0x76>

	if (endptr)
  800c03:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c07:	74 0d                	je     800c16 <strtol+0xd0>
		*endptr = (char *) s;
  800c09:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c0c:	89 0e                	mov    %ecx,(%esi)
  800c0e:	eb 06                	jmp    800c16 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c10:	85 db                	test   %ebx,%ebx
  800c12:	74 98                	je     800bac <strtol+0x66>
  800c14:	eb 9e                	jmp    800bb4 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800c16:	89 c2                	mov    %eax,%edx
  800c18:	f7 da                	neg    %edx
  800c1a:	85 ff                	test   %edi,%edi
  800c1c:	0f 45 c2             	cmovne %edx,%eax
}
  800c1f:	5b                   	pop    %ebx
  800c20:	5e                   	pop    %esi
  800c21:	5f                   	pop    %edi
  800c22:	5d                   	pop    %ebp
  800c23:	c3                   	ret    

00800c24 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c24:	55                   	push   %ebp
  800c25:	89 e5                	mov    %esp,%ebp
  800c27:	57                   	push   %edi
  800c28:	56                   	push   %esi
  800c29:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2a:	b8 00 00 00 00       	mov    $0x0,%eax
  800c2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c32:	8b 55 08             	mov    0x8(%ebp),%edx
  800c35:	89 c3                	mov    %eax,%ebx
  800c37:	89 c7                	mov    %eax,%edi
  800c39:	89 c6                	mov    %eax,%esi
  800c3b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c3d:	5b                   	pop    %ebx
  800c3e:	5e                   	pop    %esi
  800c3f:	5f                   	pop    %edi
  800c40:	5d                   	pop    %ebp
  800c41:	c3                   	ret    

00800c42 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c42:	55                   	push   %ebp
  800c43:	89 e5                	mov    %esp,%ebp
  800c45:	57                   	push   %edi
  800c46:	56                   	push   %esi
  800c47:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c48:	ba 00 00 00 00       	mov    $0x0,%edx
  800c4d:	b8 01 00 00 00       	mov    $0x1,%eax
  800c52:	89 d1                	mov    %edx,%ecx
  800c54:	89 d3                	mov    %edx,%ebx
  800c56:	89 d7                	mov    %edx,%edi
  800c58:	89 d6                	mov    %edx,%esi
  800c5a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c5c:	5b                   	pop    %ebx
  800c5d:	5e                   	pop    %esi
  800c5e:	5f                   	pop    %edi
  800c5f:	5d                   	pop    %ebp
  800c60:	c3                   	ret    

00800c61 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c61:	55                   	push   %ebp
  800c62:	89 e5                	mov    %esp,%ebp
  800c64:	57                   	push   %edi
  800c65:	56                   	push   %esi
  800c66:	53                   	push   %ebx
  800c67:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c6f:	b8 03 00 00 00       	mov    $0x3,%eax
  800c74:	8b 55 08             	mov    0x8(%ebp),%edx
  800c77:	89 cb                	mov    %ecx,%ebx
  800c79:	89 cf                	mov    %ecx,%edi
  800c7b:	89 ce                	mov    %ecx,%esi
  800c7d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c7f:	85 c0                	test   %eax,%eax
  800c81:	7e 17                	jle    800c9a <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c83:	83 ec 0c             	sub    $0xc,%esp
  800c86:	50                   	push   %eax
  800c87:	6a 03                	push   $0x3
  800c89:	68 5f 2c 80 00       	push   $0x802c5f
  800c8e:	6a 23                	push   $0x23
  800c90:	68 7c 2c 80 00       	push   $0x802c7c
  800c95:	e8 3e f5 ff ff       	call   8001d8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9d:	5b                   	pop    %ebx
  800c9e:	5e                   	pop    %esi
  800c9f:	5f                   	pop    %edi
  800ca0:	5d                   	pop    %ebp
  800ca1:	c3                   	ret    

00800ca2 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ca2:	55                   	push   %ebp
  800ca3:	89 e5                	mov    %esp,%ebp
  800ca5:	57                   	push   %edi
  800ca6:	56                   	push   %esi
  800ca7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca8:	ba 00 00 00 00       	mov    $0x0,%edx
  800cad:	b8 02 00 00 00       	mov    $0x2,%eax
  800cb2:	89 d1                	mov    %edx,%ecx
  800cb4:	89 d3                	mov    %edx,%ebx
  800cb6:	89 d7                	mov    %edx,%edi
  800cb8:	89 d6                	mov    %edx,%esi
  800cba:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cbc:	5b                   	pop    %ebx
  800cbd:	5e                   	pop    %esi
  800cbe:	5f                   	pop    %edi
  800cbf:	5d                   	pop    %ebp
  800cc0:	c3                   	ret    

00800cc1 <sys_yield>:

void
sys_yield(void)
{
  800cc1:	55                   	push   %ebp
  800cc2:	89 e5                	mov    %esp,%ebp
  800cc4:	57                   	push   %edi
  800cc5:	56                   	push   %esi
  800cc6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc7:	ba 00 00 00 00       	mov    $0x0,%edx
  800ccc:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cd1:	89 d1                	mov    %edx,%ecx
  800cd3:	89 d3                	mov    %edx,%ebx
  800cd5:	89 d7                	mov    %edx,%edi
  800cd7:	89 d6                	mov    %edx,%esi
  800cd9:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cdb:	5b                   	pop    %ebx
  800cdc:	5e                   	pop    %esi
  800cdd:	5f                   	pop    %edi
  800cde:	5d                   	pop    %ebp
  800cdf:	c3                   	ret    

00800ce0 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ce0:	55                   	push   %ebp
  800ce1:	89 e5                	mov    %esp,%ebp
  800ce3:	57                   	push   %edi
  800ce4:	56                   	push   %esi
  800ce5:	53                   	push   %ebx
  800ce6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce9:	be 00 00 00 00       	mov    $0x0,%esi
  800cee:	b8 04 00 00 00       	mov    $0x4,%eax
  800cf3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf6:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cfc:	89 f7                	mov    %esi,%edi
  800cfe:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d00:	85 c0                	test   %eax,%eax
  800d02:	7e 17                	jle    800d1b <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d04:	83 ec 0c             	sub    $0xc,%esp
  800d07:	50                   	push   %eax
  800d08:	6a 04                	push   $0x4
  800d0a:	68 5f 2c 80 00       	push   $0x802c5f
  800d0f:	6a 23                	push   $0x23
  800d11:	68 7c 2c 80 00       	push   $0x802c7c
  800d16:	e8 bd f4 ff ff       	call   8001d8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d1b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1e:	5b                   	pop    %ebx
  800d1f:	5e                   	pop    %esi
  800d20:	5f                   	pop    %edi
  800d21:	5d                   	pop    %ebp
  800d22:	c3                   	ret    

00800d23 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d23:	55                   	push   %ebp
  800d24:	89 e5                	mov    %esp,%ebp
  800d26:	57                   	push   %edi
  800d27:	56                   	push   %esi
  800d28:	53                   	push   %ebx
  800d29:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2c:	b8 05 00 00 00       	mov    $0x5,%eax
  800d31:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d34:	8b 55 08             	mov    0x8(%ebp),%edx
  800d37:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d3a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d3d:	8b 75 18             	mov    0x18(%ebp),%esi
  800d40:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d42:	85 c0                	test   %eax,%eax
  800d44:	7e 17                	jle    800d5d <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d46:	83 ec 0c             	sub    $0xc,%esp
  800d49:	50                   	push   %eax
  800d4a:	6a 05                	push   $0x5
  800d4c:	68 5f 2c 80 00       	push   $0x802c5f
  800d51:	6a 23                	push   $0x23
  800d53:	68 7c 2c 80 00       	push   $0x802c7c
  800d58:	e8 7b f4 ff ff       	call   8001d8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d5d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d60:	5b                   	pop    %ebx
  800d61:	5e                   	pop    %esi
  800d62:	5f                   	pop    %edi
  800d63:	5d                   	pop    %ebp
  800d64:	c3                   	ret    

00800d65 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d65:	55                   	push   %ebp
  800d66:	89 e5                	mov    %esp,%ebp
  800d68:	57                   	push   %edi
  800d69:	56                   	push   %esi
  800d6a:	53                   	push   %ebx
  800d6b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d73:	b8 06 00 00 00       	mov    $0x6,%eax
  800d78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7e:	89 df                	mov    %ebx,%edi
  800d80:	89 de                	mov    %ebx,%esi
  800d82:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d84:	85 c0                	test   %eax,%eax
  800d86:	7e 17                	jle    800d9f <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d88:	83 ec 0c             	sub    $0xc,%esp
  800d8b:	50                   	push   %eax
  800d8c:	6a 06                	push   $0x6
  800d8e:	68 5f 2c 80 00       	push   $0x802c5f
  800d93:	6a 23                	push   $0x23
  800d95:	68 7c 2c 80 00       	push   $0x802c7c
  800d9a:	e8 39 f4 ff ff       	call   8001d8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d9f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da2:	5b                   	pop    %ebx
  800da3:	5e                   	pop    %esi
  800da4:	5f                   	pop    %edi
  800da5:	5d                   	pop    %ebp
  800da6:	c3                   	ret    

00800da7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800da7:	55                   	push   %ebp
  800da8:	89 e5                	mov    %esp,%ebp
  800daa:	57                   	push   %edi
  800dab:	56                   	push   %esi
  800dac:	53                   	push   %ebx
  800dad:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db5:	b8 08 00 00 00       	mov    $0x8,%eax
  800dba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dbd:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc0:	89 df                	mov    %ebx,%edi
  800dc2:	89 de                	mov    %ebx,%esi
  800dc4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dc6:	85 c0                	test   %eax,%eax
  800dc8:	7e 17                	jle    800de1 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dca:	83 ec 0c             	sub    $0xc,%esp
  800dcd:	50                   	push   %eax
  800dce:	6a 08                	push   $0x8
  800dd0:	68 5f 2c 80 00       	push   $0x802c5f
  800dd5:	6a 23                	push   $0x23
  800dd7:	68 7c 2c 80 00       	push   $0x802c7c
  800ddc:	e8 f7 f3 ff ff       	call   8001d8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800de1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de4:	5b                   	pop    %ebx
  800de5:	5e                   	pop    %esi
  800de6:	5f                   	pop    %edi
  800de7:	5d                   	pop    %ebp
  800de8:	c3                   	ret    

00800de9 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800de9:	55                   	push   %ebp
  800dea:	89 e5                	mov    %esp,%ebp
  800dec:	57                   	push   %edi
  800ded:	56                   	push   %esi
  800dee:	53                   	push   %ebx
  800def:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800df7:	b8 09 00 00 00       	mov    $0x9,%eax
  800dfc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dff:	8b 55 08             	mov    0x8(%ebp),%edx
  800e02:	89 df                	mov    %ebx,%edi
  800e04:	89 de                	mov    %ebx,%esi
  800e06:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e08:	85 c0                	test   %eax,%eax
  800e0a:	7e 17                	jle    800e23 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e0c:	83 ec 0c             	sub    $0xc,%esp
  800e0f:	50                   	push   %eax
  800e10:	6a 09                	push   $0x9
  800e12:	68 5f 2c 80 00       	push   $0x802c5f
  800e17:	6a 23                	push   $0x23
  800e19:	68 7c 2c 80 00       	push   $0x802c7c
  800e1e:	e8 b5 f3 ff ff       	call   8001d8 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e23:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e26:	5b                   	pop    %ebx
  800e27:	5e                   	pop    %esi
  800e28:	5f                   	pop    %edi
  800e29:	5d                   	pop    %ebp
  800e2a:	c3                   	ret    

00800e2b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e2b:	55                   	push   %ebp
  800e2c:	89 e5                	mov    %esp,%ebp
  800e2e:	57                   	push   %edi
  800e2f:	56                   	push   %esi
  800e30:	53                   	push   %ebx
  800e31:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e34:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e39:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e3e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e41:	8b 55 08             	mov    0x8(%ebp),%edx
  800e44:	89 df                	mov    %ebx,%edi
  800e46:	89 de                	mov    %ebx,%esi
  800e48:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e4a:	85 c0                	test   %eax,%eax
  800e4c:	7e 17                	jle    800e65 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e4e:	83 ec 0c             	sub    $0xc,%esp
  800e51:	50                   	push   %eax
  800e52:	6a 0a                	push   $0xa
  800e54:	68 5f 2c 80 00       	push   $0x802c5f
  800e59:	6a 23                	push   $0x23
  800e5b:	68 7c 2c 80 00       	push   $0x802c7c
  800e60:	e8 73 f3 ff ff       	call   8001d8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e65:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e68:	5b                   	pop    %ebx
  800e69:	5e                   	pop    %esi
  800e6a:	5f                   	pop    %edi
  800e6b:	5d                   	pop    %ebp
  800e6c:	c3                   	ret    

00800e6d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e6d:	55                   	push   %ebp
  800e6e:	89 e5                	mov    %esp,%ebp
  800e70:	57                   	push   %edi
  800e71:	56                   	push   %esi
  800e72:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e73:	be 00 00 00 00       	mov    $0x0,%esi
  800e78:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e80:	8b 55 08             	mov    0x8(%ebp),%edx
  800e83:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e86:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e89:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e8b:	5b                   	pop    %ebx
  800e8c:	5e                   	pop    %esi
  800e8d:	5f                   	pop    %edi
  800e8e:	5d                   	pop    %ebp
  800e8f:	c3                   	ret    

00800e90 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e90:	55                   	push   %ebp
  800e91:	89 e5                	mov    %esp,%ebp
  800e93:	57                   	push   %edi
  800e94:	56                   	push   %esi
  800e95:	53                   	push   %ebx
  800e96:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e99:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e9e:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ea3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea6:	89 cb                	mov    %ecx,%ebx
  800ea8:	89 cf                	mov    %ecx,%edi
  800eaa:	89 ce                	mov    %ecx,%esi
  800eac:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800eae:	85 c0                	test   %eax,%eax
  800eb0:	7e 17                	jle    800ec9 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eb2:	83 ec 0c             	sub    $0xc,%esp
  800eb5:	50                   	push   %eax
  800eb6:	6a 0d                	push   $0xd
  800eb8:	68 5f 2c 80 00       	push   $0x802c5f
  800ebd:	6a 23                	push   $0x23
  800ebf:	68 7c 2c 80 00       	push   $0x802c7c
  800ec4:	e8 0f f3 ff ff       	call   8001d8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ec9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ecc:	5b                   	pop    %ebx
  800ecd:	5e                   	pop    %esi
  800ece:	5f                   	pop    %edi
  800ecf:	5d                   	pop    %ebp
  800ed0:	c3                   	ret    

00800ed1 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ed1:	55                   	push   %ebp
  800ed2:	89 e5                	mov    %esp,%ebp
  800ed4:	53                   	push   %ebx
  800ed5:	83 ec 04             	sub    $0x4,%esp
  800ed8:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800edb:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & 
  800edd:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800ee1:	0f 84 48 01 00 00    	je     80102f <pgfault+0x15e>
  800ee7:	89 d8                	mov    %ebx,%eax
  800ee9:	c1 e8 16             	shr    $0x16,%eax
  800eec:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ef3:	a8 01                	test   $0x1,%al
  800ef5:	0f 84 5f 01 00 00    	je     80105a <pgfault+0x189>
  800efb:	89 d8                	mov    %ebx,%eax
  800efd:	c1 e8 0c             	shr    $0xc,%eax
  800f00:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f07:	f6 c2 01             	test   $0x1,%dl
  800f0a:	0f 84 4a 01 00 00    	je     80105a <pgfault+0x189>
				PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW))) {
  800f10:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & 
  800f17:	f6 c4 08             	test   $0x8,%ah
  800f1a:	75 79                	jne    800f95 <pgfault+0xc4>
  800f1c:	e9 39 01 00 00       	jmp    80105a <pgfault+0x189>
				PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW))) {
		cprintf("Fault address = %08x, envid = %08x\n", addr, thisenv->env_id);
		if (!(err & FEC_WR)) cprintf("Not write\n");
		if (!(uvpd[PDX(addr)] & PTE_P)) cprintf("PDE not present\n");
  800f21:	89 d8                	mov    %ebx,%eax
  800f23:	c1 e8 16             	shr    $0x16,%eax
  800f26:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f2d:	a8 01                	test   $0x1,%al
  800f2f:	75 10                	jne    800f41 <pgfault+0x70>
  800f31:	83 ec 0c             	sub    $0xc,%esp
  800f34:	68 8a 2c 80 00       	push   $0x802c8a
  800f39:	e8 73 f3 ff ff       	call   8002b1 <cprintf>
  800f3e:	83 c4 10             	add    $0x10,%esp
		if (!(uvpt[PTX(addr)] & PTE_P)) cprintf("PTE not present\n");
  800f41:	c1 eb 0c             	shr    $0xc,%ebx
  800f44:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  800f4a:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800f51:	a8 01                	test   $0x1,%al
  800f53:	75 10                	jne    800f65 <pgfault+0x94>
  800f55:	83 ec 0c             	sub    $0xc,%esp
  800f58:	68 9b 2c 80 00       	push   $0x802c9b
  800f5d:	e8 4f f3 ff ff       	call   8002b1 <cprintf>
  800f62:	83 c4 10             	add    $0x10,%esp
		if (!(uvpt[PTX(addr)] & PTE_COW)) cprintf("Not copy-on-write\n");
  800f65:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800f6c:	f6 c4 08             	test   $0x8,%ah
  800f6f:	75 10                	jne    800f81 <pgfault+0xb0>
  800f71:	83 ec 0c             	sub    $0xc,%esp
  800f74:	68 ac 2c 80 00       	push   $0x802cac
  800f79:	e8 33 f3 ff ff       	call   8002b1 <cprintf>
  800f7e:	83 c4 10             	add    $0x10,%esp
		panic("User page fault");
  800f81:	83 ec 04             	sub    $0x4,%esp
  800f84:	68 bf 2c 80 00       	push   $0x802cbf
  800f89:	6a 23                	push   $0x23
  800f8b:	68 cf 2c 80 00       	push   $0x802ccf
  800f90:	e8 43 f2 ff ff       	call   8001d8 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// 0 refers to curenv
	if ((r = sys_page_alloc(0, (void*)PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  800f95:	83 ec 04             	sub    $0x4,%esp
  800f98:	6a 07                	push   $0x7
  800f9a:	68 00 f0 7f 00       	push   $0x7ff000
  800f9f:	6a 00                	push   $0x0
  800fa1:	e8 3a fd ff ff       	call   800ce0 <sys_page_alloc>
  800fa6:	83 c4 10             	add    $0x10,%esp
  800fa9:	85 c0                	test   %eax,%eax
  800fab:	79 12                	jns    800fbf <pgfault+0xee>
		panic("sys_page_alloc failed: %e", r);
  800fad:	50                   	push   %eax
  800fae:	68 da 2c 80 00       	push   $0x802cda
  800fb3:	6a 2f                	push   $0x2f
  800fb5:	68 cf 2c 80 00       	push   $0x802ccf
  800fba:	e8 19 f2 ff ff       	call   8001d8 <_panic>
	memcpy((void*)PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  800fbf:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800fc5:	83 ec 04             	sub    $0x4,%esp
  800fc8:	68 00 10 00 00       	push   $0x1000
  800fcd:	53                   	push   %ebx
  800fce:	68 00 f0 7f 00       	push   $0x7ff000
  800fd3:	e8 ff fa ff ff       	call   800ad7 <memcpy>
	if ((r = sys_page_map(0, (void*)PFTEMP, 0, (void*)ROUNDDOWN(addr, PGSIZE), 
  800fd8:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800fdf:	53                   	push   %ebx
  800fe0:	6a 00                	push   $0x0
  800fe2:	68 00 f0 7f 00       	push   $0x7ff000
  800fe7:	6a 00                	push   $0x0
  800fe9:	e8 35 fd ff ff       	call   800d23 <sys_page_map>
  800fee:	83 c4 20             	add    $0x20,%esp
  800ff1:	85 c0                	test   %eax,%eax
  800ff3:	79 12                	jns    801007 <pgfault+0x136>
					PTE_P | PTE_U | PTE_W)) < 0)
		panic("sys_page_map failed: %e", r);
  800ff5:	50                   	push   %eax
  800ff6:	68 f4 2c 80 00       	push   $0x802cf4
  800ffb:	6a 33                	push   $0x33
  800ffd:	68 cf 2c 80 00       	push   $0x802ccf
  801002:	e8 d1 f1 ff ff       	call   8001d8 <_panic>
	if ((r = sys_page_unmap(0, (void*)PFTEMP)) < 0)
  801007:	83 ec 08             	sub    $0x8,%esp
  80100a:	68 00 f0 7f 00       	push   $0x7ff000
  80100f:	6a 00                	push   $0x0
  801011:	e8 4f fd ff ff       	call   800d65 <sys_page_unmap>
  801016:	83 c4 10             	add    $0x10,%esp
  801019:	85 c0                	test   %eax,%eax
  80101b:	79 5c                	jns    801079 <pgfault+0x1a8>
		panic("sys_page_unmap failed: %e", r);
  80101d:	50                   	push   %eax
  80101e:	68 0c 2d 80 00       	push   $0x802d0c
  801023:	6a 35                	push   $0x35
  801025:	68 cf 2c 80 00       	push   $0x802ccf
  80102a:	e8 a9 f1 ff ff       	call   8001d8 <_panic>
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & 
				PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW))) {
		cprintf("Fault address = %08x, envid = %08x\n", addr, thisenv->env_id);
  80102f:	a1 04 40 80 00       	mov    0x804004,%eax
  801034:	8b 40 48             	mov    0x48(%eax),%eax
  801037:	83 ec 04             	sub    $0x4,%esp
  80103a:	50                   	push   %eax
  80103b:	53                   	push   %ebx
  80103c:	68 48 2d 80 00       	push   $0x802d48
  801041:	e8 6b f2 ff ff       	call   8002b1 <cprintf>
		if (!(err & FEC_WR)) cprintf("Not write\n");
  801046:	c7 04 24 26 2d 80 00 	movl   $0x802d26,(%esp)
  80104d:	e8 5f f2 ff ff       	call   8002b1 <cprintf>
  801052:	83 c4 10             	add    $0x10,%esp
  801055:	e9 c7 fe ff ff       	jmp    800f21 <pgfault+0x50>
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & 
				PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW))) {
		cprintf("Fault address = %08x, envid = %08x\n", addr, thisenv->env_id);
  80105a:	a1 04 40 80 00       	mov    0x804004,%eax
  80105f:	8b 40 48             	mov    0x48(%eax),%eax
  801062:	83 ec 04             	sub    $0x4,%esp
  801065:	50                   	push   %eax
  801066:	53                   	push   %ebx
  801067:	68 48 2d 80 00       	push   $0x802d48
  80106c:	e8 40 f2 ff ff       	call   8002b1 <cprintf>
  801071:	83 c4 10             	add    $0x10,%esp
  801074:	e9 a8 fe ff ff       	jmp    800f21 <pgfault+0x50>
		panic("sys_page_map failed: %e", r);
	if ((r = sys_page_unmap(0, (void*)PFTEMP)) < 0)
		panic("sys_page_unmap failed: %e", r);

	// panic("pgfault not implemented");
}
  801079:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80107c:	c9                   	leave  
  80107d:	c3                   	ret    

0080107e <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80107e:	55                   	push   %ebp
  80107f:	89 e5                	mov    %esp,%ebp
  801081:	57                   	push   %edi
  801082:	56                   	push   %esi
  801083:	53                   	push   %ebx
  801084:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	int ret;
	set_pgfault_handler(pgfault);
  801087:	68 d1 0e 80 00       	push   $0x800ed1
  80108c:	e8 97 13 00 00       	call   802428 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801091:	b8 07 00 00 00       	mov    $0x7,%eax
  801096:	cd 30                	int    $0x30
  801098:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80109b:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	envid_t envid = sys_exofork();

	if (envid < 0) return envid;
  80109e:	83 c4 10             	add    $0x10,%esp
  8010a1:	85 c0                	test   %eax,%eax
  8010a3:	0f 88 0d 01 00 00    	js     8011b6 <fork+0x138>
  8010a9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010ae:	be 00 00 00 00       	mov    $0x0,%esi
	else if (envid == 0) {
  8010b3:	85 c0                	test   %eax,%eax
  8010b5:	75 2f                	jne    8010e6 <fork+0x68>
		// Child returns
		thisenv = &envs[ENVX(sys_getenvid())];
  8010b7:	e8 e6 fb ff ff       	call   800ca2 <sys_getenvid>
  8010bc:	25 ff 03 00 00       	and    $0x3ff,%eax
  8010c1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8010c4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010c9:	a3 04 40 80 00       	mov    %eax,0x804004
		// set_pgfault_handler(pgfault);
		return 0;
  8010ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8010d3:	e9 e1 00 00 00       	jmp    8011b9 <fork+0x13b>
  8010d8:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
	}
	else {
		uint32_t pn;
		for (pn = 0; pn * PGSIZE < UTOP; pn++){
			// cprintf("virtual page %08x\n", pn * PGSIZE);
			if (pn * PGSIZE == UXSTACKTOP - PGSIZE) 
  8010de:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  8010e4:	74 77                	je     80115d <fork+0xdf>
{
	int r;

	// LAB 4: Your code here.
	int perm = PTE_P | PTE_U;
	pde_t pde = uvpd[pn / NPTENTRIES];
  8010e6:	89 f0                	mov    %esi,%eax
  8010e8:	c1 e8 0a             	shr    $0xa,%eax
  8010eb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
	if (!(pde & PTE_P)) return 0;
  8010f2:	a8 01                	test   $0x1,%al
  8010f4:	74 0b                	je     801101 <fork+0x83>
	pte_t pte = uvpt[pn];
  8010f6:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	if (!(pte & PTE_P)) return 0;
  8010fd:	a8 01                	test   $0x1,%al
  8010ff:	75 08                	jne    801109 <fork+0x8b>
  801101:	8d 5e 01             	lea    0x1(%esi),%ebx
  801104:	c1 e3 0c             	shl    $0xc,%ebx
  801107:	eb 56                	jmp    80115f <fork+0xe1>
	// cprintf("virtual page %08x\n", pn * PGSIZE);

	if ((pte & PTE_W) || (pte & PTE_COW)) perm |= PTE_COW;
  801109:	25 02 08 00 00       	and    $0x802,%eax
  80110e:	83 f8 01             	cmp    $0x1,%eax
  801111:	19 ff                	sbb    %edi,%edi
  801113:	81 e7 00 f8 ff ff    	and    $0xfffff800,%edi
  801119:	81 c7 05 08 00 00    	add    $0x805,%edi

	if ((r = sys_page_map(thisenv->env_id, (void*)(pn * PGSIZE), envid, 
  80111f:	a1 04 40 80 00       	mov    0x804004,%eax
  801124:	8b 40 48             	mov    0x48(%eax),%eax
  801127:	83 ec 0c             	sub    $0xc,%esp
  80112a:	57                   	push   %edi
  80112b:	53                   	push   %ebx
  80112c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80112f:	53                   	push   %ebx
  801130:	50                   	push   %eax
  801131:	e8 ed fb ff ff       	call   800d23 <sys_page_map>
  801136:	83 c4 20             	add    $0x20,%esp
  801139:	85 c0                	test   %eax,%eax
  80113b:	78 7c                	js     8011b9 <fork+0x13b>
				(void*)(pn * PGSIZE), perm)) < 0) 
		return r;
	r = sys_page_map(envid, (void*)(pn * PGSIZE), thisenv->env_id, 
  80113d:	a1 04 40 80 00       	mov    0x804004,%eax
  801142:	8b 40 48             	mov    0x48(%eax),%eax
  801145:	83 ec 0c             	sub    $0xc,%esp
  801148:	57                   	push   %edi
  801149:	53                   	push   %ebx
  80114a:	50                   	push   %eax
  80114b:	53                   	push   %ebx
  80114c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80114f:	e8 cf fb ff ff       	call   800d23 <sys_page_map>
		uint32_t pn;
		for (pn = 0; pn * PGSIZE < UTOP; pn++){
			// cprintf("virtual page %08x\n", pn * PGSIZE);
			if (pn * PGSIZE == UXSTACKTOP - PGSIZE) 
				continue;
			if ((ret = duppage(envid, pn)) < 0)
  801154:	83 c4 20             	add    $0x20,%esp
  801157:	85 c0                	test   %eax,%eax
  801159:	79 a6                	jns    801101 <fork+0x83>
  80115b:	eb 5c                	jmp    8011b9 <fork+0x13b>
  80115d:	89 c3                	mov    %eax,%ebx
		// set_pgfault_handler(pgfault);
		return 0;
	}
	else {
		uint32_t pn;
		for (pn = 0; pn * PGSIZE < UTOP; pn++){
  80115f:	83 c6 01             	add    $0x1,%esi
  801162:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
  801168:	0f 86 6a ff ff ff    	jbe    8010d8 <fork+0x5a>
				return ret;
		}
		// cprintf("Fork: duppage finished\n");

		// Should be done by parent
		if ((ret = sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P |
  80116e:	83 ec 04             	sub    $0x4,%esp
  801171:	6a 07                	push   $0x7
  801173:	68 00 f0 bf ee       	push   $0xeebff000
  801178:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80117b:	57                   	push   %edi
  80117c:	e8 5f fb ff ff       	call   800ce0 <sys_page_alloc>
  801181:	83 c4 10             	add    $0x10,%esp
  801184:	85 c0                	test   %eax,%eax
  801186:	78 31                	js     8011b9 <fork+0x13b>
						PTE_U | PTE_W)) < 0)
			return ret;
		if ((ret = sys_env_set_pgfault_upcall(envid, 
						thisenv->env_pgfault_upcall)) < 0)
  801188:	a1 04 40 80 00       	mov    0x804004,%eax

		// Should be done by parent
		if ((ret = sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P |
						PTE_U | PTE_W)) < 0)
			return ret;
		if ((ret = sys_env_set_pgfault_upcall(envid, 
  80118d:	8b 40 64             	mov    0x64(%eax),%eax
  801190:	83 ec 08             	sub    $0x8,%esp
  801193:	50                   	push   %eax
  801194:	57                   	push   %edi
  801195:	e8 91 fc ff ff       	call   800e2b <sys_env_set_pgfault_upcall>
  80119a:	83 c4 10             	add    $0x10,%esp
  80119d:	85 c0                	test   %eax,%eax
  80119f:	78 18                	js     8011b9 <fork+0x13b>
						thisenv->env_pgfault_upcall)) < 0)
			return ret;

		if ((ret = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8011a1:	83 ec 08             	sub    $0x8,%esp
  8011a4:	6a 02                	push   $0x2
  8011a6:	57                   	push   %edi
  8011a7:	e8 fb fb ff ff       	call   800da7 <sys_env_set_status>
  8011ac:	83 c4 10             	add    $0x10,%esp
			return ret;
		return envid;
  8011af:	85 c0                	test   %eax,%eax
  8011b1:	0f 49 c7             	cmovns %edi,%eax
  8011b4:	eb 03                	jmp    8011b9 <fork+0x13b>
	int ret;
	set_pgfault_handler(pgfault);

	envid_t envid = sys_exofork();

	if (envid < 0) return envid;
  8011b6:	8b 45 e0             	mov    -0x20(%ebp),%eax
			return ret;
		return envid;
	}

	panic("fork not implemented");
}
  8011b9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011bc:	5b                   	pop    %ebx
  8011bd:	5e                   	pop    %esi
  8011be:	5f                   	pop    %edi
  8011bf:	5d                   	pop    %ebp
  8011c0:	c3                   	ret    

008011c1 <sfork>:

// Challenge!
int
sfork(void)
{
  8011c1:	55                   	push   %ebp
  8011c2:	89 e5                	mov    %esp,%ebp
  8011c4:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8011c7:	68 31 2d 80 00       	push   $0x802d31
  8011cc:	68 9f 00 00 00       	push   $0x9f
  8011d1:	68 cf 2c 80 00       	push   $0x802ccf
  8011d6:	e8 fd ef ff ff       	call   8001d8 <_panic>

008011db <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011db:	55                   	push   %ebp
  8011dc:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011de:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e1:	05 00 00 00 30       	add    $0x30000000,%eax
  8011e6:	c1 e8 0c             	shr    $0xc,%eax
}
  8011e9:	5d                   	pop    %ebp
  8011ea:	c3                   	ret    

008011eb <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011eb:	55                   	push   %ebp
  8011ec:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f1:	05 00 00 00 30       	add    $0x30000000,%eax
  8011f6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011fb:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801200:	5d                   	pop    %ebp
  801201:	c3                   	ret    

00801202 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801202:	55                   	push   %ebp
  801203:	89 e5                	mov    %esp,%ebp
  801205:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801208:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80120d:	89 c2                	mov    %eax,%edx
  80120f:	c1 ea 16             	shr    $0x16,%edx
  801212:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801219:	f6 c2 01             	test   $0x1,%dl
  80121c:	74 11                	je     80122f <fd_alloc+0x2d>
  80121e:	89 c2                	mov    %eax,%edx
  801220:	c1 ea 0c             	shr    $0xc,%edx
  801223:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80122a:	f6 c2 01             	test   $0x1,%dl
  80122d:	75 09                	jne    801238 <fd_alloc+0x36>
			*fd_store = fd;
  80122f:	89 01                	mov    %eax,(%ecx)
			return 0;
  801231:	b8 00 00 00 00       	mov    $0x0,%eax
  801236:	eb 17                	jmp    80124f <fd_alloc+0x4d>
  801238:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80123d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801242:	75 c9                	jne    80120d <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801244:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80124a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80124f:	5d                   	pop    %ebp
  801250:	c3                   	ret    

00801251 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801251:	55                   	push   %ebp
  801252:	89 e5                	mov    %esp,%ebp
  801254:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801257:	83 f8 1f             	cmp    $0x1f,%eax
  80125a:	77 36                	ja     801292 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80125c:	c1 e0 0c             	shl    $0xc,%eax
  80125f:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801264:	89 c2                	mov    %eax,%edx
  801266:	c1 ea 16             	shr    $0x16,%edx
  801269:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801270:	f6 c2 01             	test   $0x1,%dl
  801273:	74 24                	je     801299 <fd_lookup+0x48>
  801275:	89 c2                	mov    %eax,%edx
  801277:	c1 ea 0c             	shr    $0xc,%edx
  80127a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801281:	f6 c2 01             	test   $0x1,%dl
  801284:	74 1a                	je     8012a0 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801286:	8b 55 0c             	mov    0xc(%ebp),%edx
  801289:	89 02                	mov    %eax,(%edx)
	return 0;
  80128b:	b8 00 00 00 00       	mov    $0x0,%eax
  801290:	eb 13                	jmp    8012a5 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801292:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801297:	eb 0c                	jmp    8012a5 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801299:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80129e:	eb 05                	jmp    8012a5 <fd_lookup+0x54>
  8012a0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012a5:	5d                   	pop    %ebp
  8012a6:	c3                   	ret    

008012a7 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012a7:	55                   	push   %ebp
  8012a8:	89 e5                	mov    %esp,%ebp
  8012aa:	83 ec 08             	sub    $0x8,%esp
  8012ad:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012b0:	ba e8 2d 80 00       	mov    $0x802de8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012b5:	eb 13                	jmp    8012ca <dev_lookup+0x23>
  8012b7:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8012ba:	39 08                	cmp    %ecx,(%eax)
  8012bc:	75 0c                	jne    8012ca <dev_lookup+0x23>
			*dev = devtab[i];
  8012be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012c1:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8012c8:	eb 2e                	jmp    8012f8 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012ca:	8b 02                	mov    (%edx),%eax
  8012cc:	85 c0                	test   %eax,%eax
  8012ce:	75 e7                	jne    8012b7 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012d0:	a1 04 40 80 00       	mov    0x804004,%eax
  8012d5:	8b 40 48             	mov    0x48(%eax),%eax
  8012d8:	83 ec 04             	sub    $0x4,%esp
  8012db:	51                   	push   %ecx
  8012dc:	50                   	push   %eax
  8012dd:	68 6c 2d 80 00       	push   $0x802d6c
  8012e2:	e8 ca ef ff ff       	call   8002b1 <cprintf>
	*dev = 0;
  8012e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012ea:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012f0:	83 c4 10             	add    $0x10,%esp
  8012f3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012f8:	c9                   	leave  
  8012f9:	c3                   	ret    

008012fa <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012fa:	55                   	push   %ebp
  8012fb:	89 e5                	mov    %esp,%ebp
  8012fd:	56                   	push   %esi
  8012fe:	53                   	push   %ebx
  8012ff:	83 ec 10             	sub    $0x10,%esp
  801302:	8b 75 08             	mov    0x8(%ebp),%esi
  801305:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801308:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80130b:	50                   	push   %eax
  80130c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801312:	c1 e8 0c             	shr    $0xc,%eax
  801315:	50                   	push   %eax
  801316:	e8 36 ff ff ff       	call   801251 <fd_lookup>
  80131b:	83 c4 08             	add    $0x8,%esp
  80131e:	85 c0                	test   %eax,%eax
  801320:	78 05                	js     801327 <fd_close+0x2d>
	    || fd != fd2)
  801322:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801325:	74 0c                	je     801333 <fd_close+0x39>
		return (must_exist ? r : 0);
  801327:	84 db                	test   %bl,%bl
  801329:	ba 00 00 00 00       	mov    $0x0,%edx
  80132e:	0f 44 c2             	cmove  %edx,%eax
  801331:	eb 41                	jmp    801374 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801333:	83 ec 08             	sub    $0x8,%esp
  801336:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801339:	50                   	push   %eax
  80133a:	ff 36                	pushl  (%esi)
  80133c:	e8 66 ff ff ff       	call   8012a7 <dev_lookup>
  801341:	89 c3                	mov    %eax,%ebx
  801343:	83 c4 10             	add    $0x10,%esp
  801346:	85 c0                	test   %eax,%eax
  801348:	78 1a                	js     801364 <fd_close+0x6a>
		if (dev->dev_close)
  80134a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80134d:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801350:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801355:	85 c0                	test   %eax,%eax
  801357:	74 0b                	je     801364 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801359:	83 ec 0c             	sub    $0xc,%esp
  80135c:	56                   	push   %esi
  80135d:	ff d0                	call   *%eax
  80135f:	89 c3                	mov    %eax,%ebx
  801361:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801364:	83 ec 08             	sub    $0x8,%esp
  801367:	56                   	push   %esi
  801368:	6a 00                	push   $0x0
  80136a:	e8 f6 f9 ff ff       	call   800d65 <sys_page_unmap>
	return r;
  80136f:	83 c4 10             	add    $0x10,%esp
  801372:	89 d8                	mov    %ebx,%eax
}
  801374:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801377:	5b                   	pop    %ebx
  801378:	5e                   	pop    %esi
  801379:	5d                   	pop    %ebp
  80137a:	c3                   	ret    

0080137b <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80137b:	55                   	push   %ebp
  80137c:	89 e5                	mov    %esp,%ebp
  80137e:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801381:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801384:	50                   	push   %eax
  801385:	ff 75 08             	pushl  0x8(%ebp)
  801388:	e8 c4 fe ff ff       	call   801251 <fd_lookup>
  80138d:	83 c4 08             	add    $0x8,%esp
  801390:	85 c0                	test   %eax,%eax
  801392:	78 10                	js     8013a4 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801394:	83 ec 08             	sub    $0x8,%esp
  801397:	6a 01                	push   $0x1
  801399:	ff 75 f4             	pushl  -0xc(%ebp)
  80139c:	e8 59 ff ff ff       	call   8012fa <fd_close>
  8013a1:	83 c4 10             	add    $0x10,%esp
}
  8013a4:	c9                   	leave  
  8013a5:	c3                   	ret    

008013a6 <close_all>:

void
close_all(void)
{
  8013a6:	55                   	push   %ebp
  8013a7:	89 e5                	mov    %esp,%ebp
  8013a9:	53                   	push   %ebx
  8013aa:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013ad:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013b2:	83 ec 0c             	sub    $0xc,%esp
  8013b5:	53                   	push   %ebx
  8013b6:	e8 c0 ff ff ff       	call   80137b <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013bb:	83 c3 01             	add    $0x1,%ebx
  8013be:	83 c4 10             	add    $0x10,%esp
  8013c1:	83 fb 20             	cmp    $0x20,%ebx
  8013c4:	75 ec                	jne    8013b2 <close_all+0xc>
		close(i);
}
  8013c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013c9:	c9                   	leave  
  8013ca:	c3                   	ret    

008013cb <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013cb:	55                   	push   %ebp
  8013cc:	89 e5                	mov    %esp,%ebp
  8013ce:	57                   	push   %edi
  8013cf:	56                   	push   %esi
  8013d0:	53                   	push   %ebx
  8013d1:	83 ec 2c             	sub    $0x2c,%esp
  8013d4:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013d7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013da:	50                   	push   %eax
  8013db:	ff 75 08             	pushl  0x8(%ebp)
  8013de:	e8 6e fe ff ff       	call   801251 <fd_lookup>
  8013e3:	83 c4 08             	add    $0x8,%esp
  8013e6:	85 c0                	test   %eax,%eax
  8013e8:	0f 88 c1 00 00 00    	js     8014af <dup+0xe4>
		return r;
	close(newfdnum);
  8013ee:	83 ec 0c             	sub    $0xc,%esp
  8013f1:	56                   	push   %esi
  8013f2:	e8 84 ff ff ff       	call   80137b <close>

	newfd = INDEX2FD(newfdnum);
  8013f7:	89 f3                	mov    %esi,%ebx
  8013f9:	c1 e3 0c             	shl    $0xc,%ebx
  8013fc:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801402:	83 c4 04             	add    $0x4,%esp
  801405:	ff 75 e4             	pushl  -0x1c(%ebp)
  801408:	e8 de fd ff ff       	call   8011eb <fd2data>
  80140d:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80140f:	89 1c 24             	mov    %ebx,(%esp)
  801412:	e8 d4 fd ff ff       	call   8011eb <fd2data>
  801417:	83 c4 10             	add    $0x10,%esp
  80141a:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80141d:	89 f8                	mov    %edi,%eax
  80141f:	c1 e8 16             	shr    $0x16,%eax
  801422:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801429:	a8 01                	test   $0x1,%al
  80142b:	74 37                	je     801464 <dup+0x99>
  80142d:	89 f8                	mov    %edi,%eax
  80142f:	c1 e8 0c             	shr    $0xc,%eax
  801432:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801439:	f6 c2 01             	test   $0x1,%dl
  80143c:	74 26                	je     801464 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80143e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801445:	83 ec 0c             	sub    $0xc,%esp
  801448:	25 07 0e 00 00       	and    $0xe07,%eax
  80144d:	50                   	push   %eax
  80144e:	ff 75 d4             	pushl  -0x2c(%ebp)
  801451:	6a 00                	push   $0x0
  801453:	57                   	push   %edi
  801454:	6a 00                	push   $0x0
  801456:	e8 c8 f8 ff ff       	call   800d23 <sys_page_map>
  80145b:	89 c7                	mov    %eax,%edi
  80145d:	83 c4 20             	add    $0x20,%esp
  801460:	85 c0                	test   %eax,%eax
  801462:	78 2e                	js     801492 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801464:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801467:	89 d0                	mov    %edx,%eax
  801469:	c1 e8 0c             	shr    $0xc,%eax
  80146c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801473:	83 ec 0c             	sub    $0xc,%esp
  801476:	25 07 0e 00 00       	and    $0xe07,%eax
  80147b:	50                   	push   %eax
  80147c:	53                   	push   %ebx
  80147d:	6a 00                	push   $0x0
  80147f:	52                   	push   %edx
  801480:	6a 00                	push   $0x0
  801482:	e8 9c f8 ff ff       	call   800d23 <sys_page_map>
  801487:	89 c7                	mov    %eax,%edi
  801489:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80148c:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80148e:	85 ff                	test   %edi,%edi
  801490:	79 1d                	jns    8014af <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801492:	83 ec 08             	sub    $0x8,%esp
  801495:	53                   	push   %ebx
  801496:	6a 00                	push   $0x0
  801498:	e8 c8 f8 ff ff       	call   800d65 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80149d:	83 c4 08             	add    $0x8,%esp
  8014a0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014a3:	6a 00                	push   $0x0
  8014a5:	e8 bb f8 ff ff       	call   800d65 <sys_page_unmap>
	return r;
  8014aa:	83 c4 10             	add    $0x10,%esp
  8014ad:	89 f8                	mov    %edi,%eax
}
  8014af:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014b2:	5b                   	pop    %ebx
  8014b3:	5e                   	pop    %esi
  8014b4:	5f                   	pop    %edi
  8014b5:	5d                   	pop    %ebp
  8014b6:	c3                   	ret    

008014b7 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014b7:	55                   	push   %ebp
  8014b8:	89 e5                	mov    %esp,%ebp
  8014ba:	53                   	push   %ebx
  8014bb:	83 ec 14             	sub    $0x14,%esp
  8014be:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014c1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014c4:	50                   	push   %eax
  8014c5:	53                   	push   %ebx
  8014c6:	e8 86 fd ff ff       	call   801251 <fd_lookup>
  8014cb:	83 c4 08             	add    $0x8,%esp
  8014ce:	89 c2                	mov    %eax,%edx
  8014d0:	85 c0                	test   %eax,%eax
  8014d2:	78 6d                	js     801541 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014d4:	83 ec 08             	sub    $0x8,%esp
  8014d7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014da:	50                   	push   %eax
  8014db:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014de:	ff 30                	pushl  (%eax)
  8014e0:	e8 c2 fd ff ff       	call   8012a7 <dev_lookup>
  8014e5:	83 c4 10             	add    $0x10,%esp
  8014e8:	85 c0                	test   %eax,%eax
  8014ea:	78 4c                	js     801538 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014ec:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014ef:	8b 42 08             	mov    0x8(%edx),%eax
  8014f2:	83 e0 03             	and    $0x3,%eax
  8014f5:	83 f8 01             	cmp    $0x1,%eax
  8014f8:	75 21                	jne    80151b <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014fa:	a1 04 40 80 00       	mov    0x804004,%eax
  8014ff:	8b 40 48             	mov    0x48(%eax),%eax
  801502:	83 ec 04             	sub    $0x4,%esp
  801505:	53                   	push   %ebx
  801506:	50                   	push   %eax
  801507:	68 ad 2d 80 00       	push   $0x802dad
  80150c:	e8 a0 ed ff ff       	call   8002b1 <cprintf>
		return -E_INVAL;
  801511:	83 c4 10             	add    $0x10,%esp
  801514:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801519:	eb 26                	jmp    801541 <read+0x8a>
	}
	if (!dev->dev_read)
  80151b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80151e:	8b 40 08             	mov    0x8(%eax),%eax
  801521:	85 c0                	test   %eax,%eax
  801523:	74 17                	je     80153c <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801525:	83 ec 04             	sub    $0x4,%esp
  801528:	ff 75 10             	pushl  0x10(%ebp)
  80152b:	ff 75 0c             	pushl  0xc(%ebp)
  80152e:	52                   	push   %edx
  80152f:	ff d0                	call   *%eax
  801531:	89 c2                	mov    %eax,%edx
  801533:	83 c4 10             	add    $0x10,%esp
  801536:	eb 09                	jmp    801541 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801538:	89 c2                	mov    %eax,%edx
  80153a:	eb 05                	jmp    801541 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80153c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801541:	89 d0                	mov    %edx,%eax
  801543:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801546:	c9                   	leave  
  801547:	c3                   	ret    

00801548 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801548:	55                   	push   %ebp
  801549:	89 e5                	mov    %esp,%ebp
  80154b:	57                   	push   %edi
  80154c:	56                   	push   %esi
  80154d:	53                   	push   %ebx
  80154e:	83 ec 0c             	sub    $0xc,%esp
  801551:	8b 7d 08             	mov    0x8(%ebp),%edi
  801554:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801557:	bb 00 00 00 00       	mov    $0x0,%ebx
  80155c:	eb 21                	jmp    80157f <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80155e:	83 ec 04             	sub    $0x4,%esp
  801561:	89 f0                	mov    %esi,%eax
  801563:	29 d8                	sub    %ebx,%eax
  801565:	50                   	push   %eax
  801566:	89 d8                	mov    %ebx,%eax
  801568:	03 45 0c             	add    0xc(%ebp),%eax
  80156b:	50                   	push   %eax
  80156c:	57                   	push   %edi
  80156d:	e8 45 ff ff ff       	call   8014b7 <read>
		if (m < 0)
  801572:	83 c4 10             	add    $0x10,%esp
  801575:	85 c0                	test   %eax,%eax
  801577:	78 10                	js     801589 <readn+0x41>
			return m;
		if (m == 0)
  801579:	85 c0                	test   %eax,%eax
  80157b:	74 0a                	je     801587 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80157d:	01 c3                	add    %eax,%ebx
  80157f:	39 f3                	cmp    %esi,%ebx
  801581:	72 db                	jb     80155e <readn+0x16>
  801583:	89 d8                	mov    %ebx,%eax
  801585:	eb 02                	jmp    801589 <readn+0x41>
  801587:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801589:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80158c:	5b                   	pop    %ebx
  80158d:	5e                   	pop    %esi
  80158e:	5f                   	pop    %edi
  80158f:	5d                   	pop    %ebp
  801590:	c3                   	ret    

00801591 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801591:	55                   	push   %ebp
  801592:	89 e5                	mov    %esp,%ebp
  801594:	53                   	push   %ebx
  801595:	83 ec 14             	sub    $0x14,%esp
  801598:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80159b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80159e:	50                   	push   %eax
  80159f:	53                   	push   %ebx
  8015a0:	e8 ac fc ff ff       	call   801251 <fd_lookup>
  8015a5:	83 c4 08             	add    $0x8,%esp
  8015a8:	89 c2                	mov    %eax,%edx
  8015aa:	85 c0                	test   %eax,%eax
  8015ac:	78 68                	js     801616 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ae:	83 ec 08             	sub    $0x8,%esp
  8015b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015b4:	50                   	push   %eax
  8015b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015b8:	ff 30                	pushl  (%eax)
  8015ba:	e8 e8 fc ff ff       	call   8012a7 <dev_lookup>
  8015bf:	83 c4 10             	add    $0x10,%esp
  8015c2:	85 c0                	test   %eax,%eax
  8015c4:	78 47                	js     80160d <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015c9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015cd:	75 21                	jne    8015f0 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015cf:	a1 04 40 80 00       	mov    0x804004,%eax
  8015d4:	8b 40 48             	mov    0x48(%eax),%eax
  8015d7:	83 ec 04             	sub    $0x4,%esp
  8015da:	53                   	push   %ebx
  8015db:	50                   	push   %eax
  8015dc:	68 c9 2d 80 00       	push   $0x802dc9
  8015e1:	e8 cb ec ff ff       	call   8002b1 <cprintf>
		return -E_INVAL;
  8015e6:	83 c4 10             	add    $0x10,%esp
  8015e9:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015ee:	eb 26                	jmp    801616 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015f0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015f3:	8b 52 0c             	mov    0xc(%edx),%edx
  8015f6:	85 d2                	test   %edx,%edx
  8015f8:	74 17                	je     801611 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015fa:	83 ec 04             	sub    $0x4,%esp
  8015fd:	ff 75 10             	pushl  0x10(%ebp)
  801600:	ff 75 0c             	pushl  0xc(%ebp)
  801603:	50                   	push   %eax
  801604:	ff d2                	call   *%edx
  801606:	89 c2                	mov    %eax,%edx
  801608:	83 c4 10             	add    $0x10,%esp
  80160b:	eb 09                	jmp    801616 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80160d:	89 c2                	mov    %eax,%edx
  80160f:	eb 05                	jmp    801616 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801611:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801616:	89 d0                	mov    %edx,%eax
  801618:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80161b:	c9                   	leave  
  80161c:	c3                   	ret    

0080161d <seek>:

int
seek(int fdnum, off_t offset)
{
  80161d:	55                   	push   %ebp
  80161e:	89 e5                	mov    %esp,%ebp
  801620:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801623:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801626:	50                   	push   %eax
  801627:	ff 75 08             	pushl  0x8(%ebp)
  80162a:	e8 22 fc ff ff       	call   801251 <fd_lookup>
  80162f:	83 c4 08             	add    $0x8,%esp
  801632:	85 c0                	test   %eax,%eax
  801634:	78 0e                	js     801644 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801636:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801639:	8b 55 0c             	mov    0xc(%ebp),%edx
  80163c:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80163f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801644:	c9                   	leave  
  801645:	c3                   	ret    

00801646 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801646:	55                   	push   %ebp
  801647:	89 e5                	mov    %esp,%ebp
  801649:	53                   	push   %ebx
  80164a:	83 ec 14             	sub    $0x14,%esp
  80164d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801650:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801653:	50                   	push   %eax
  801654:	53                   	push   %ebx
  801655:	e8 f7 fb ff ff       	call   801251 <fd_lookup>
  80165a:	83 c4 08             	add    $0x8,%esp
  80165d:	89 c2                	mov    %eax,%edx
  80165f:	85 c0                	test   %eax,%eax
  801661:	78 65                	js     8016c8 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801663:	83 ec 08             	sub    $0x8,%esp
  801666:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801669:	50                   	push   %eax
  80166a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80166d:	ff 30                	pushl  (%eax)
  80166f:	e8 33 fc ff ff       	call   8012a7 <dev_lookup>
  801674:	83 c4 10             	add    $0x10,%esp
  801677:	85 c0                	test   %eax,%eax
  801679:	78 44                	js     8016bf <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80167b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80167e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801682:	75 21                	jne    8016a5 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801684:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801689:	8b 40 48             	mov    0x48(%eax),%eax
  80168c:	83 ec 04             	sub    $0x4,%esp
  80168f:	53                   	push   %ebx
  801690:	50                   	push   %eax
  801691:	68 8c 2d 80 00       	push   $0x802d8c
  801696:	e8 16 ec ff ff       	call   8002b1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80169b:	83 c4 10             	add    $0x10,%esp
  80169e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016a3:	eb 23                	jmp    8016c8 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8016a5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016a8:	8b 52 18             	mov    0x18(%edx),%edx
  8016ab:	85 d2                	test   %edx,%edx
  8016ad:	74 14                	je     8016c3 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016af:	83 ec 08             	sub    $0x8,%esp
  8016b2:	ff 75 0c             	pushl  0xc(%ebp)
  8016b5:	50                   	push   %eax
  8016b6:	ff d2                	call   *%edx
  8016b8:	89 c2                	mov    %eax,%edx
  8016ba:	83 c4 10             	add    $0x10,%esp
  8016bd:	eb 09                	jmp    8016c8 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016bf:	89 c2                	mov    %eax,%edx
  8016c1:	eb 05                	jmp    8016c8 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016c3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8016c8:	89 d0                	mov    %edx,%eax
  8016ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016cd:	c9                   	leave  
  8016ce:	c3                   	ret    

008016cf <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016cf:	55                   	push   %ebp
  8016d0:	89 e5                	mov    %esp,%ebp
  8016d2:	53                   	push   %ebx
  8016d3:	83 ec 14             	sub    $0x14,%esp
  8016d6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016d9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016dc:	50                   	push   %eax
  8016dd:	ff 75 08             	pushl  0x8(%ebp)
  8016e0:	e8 6c fb ff ff       	call   801251 <fd_lookup>
  8016e5:	83 c4 08             	add    $0x8,%esp
  8016e8:	89 c2                	mov    %eax,%edx
  8016ea:	85 c0                	test   %eax,%eax
  8016ec:	78 58                	js     801746 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016ee:	83 ec 08             	sub    $0x8,%esp
  8016f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016f4:	50                   	push   %eax
  8016f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016f8:	ff 30                	pushl  (%eax)
  8016fa:	e8 a8 fb ff ff       	call   8012a7 <dev_lookup>
  8016ff:	83 c4 10             	add    $0x10,%esp
  801702:	85 c0                	test   %eax,%eax
  801704:	78 37                	js     80173d <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801706:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801709:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80170d:	74 32                	je     801741 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80170f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801712:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801719:	00 00 00 
	stat->st_isdir = 0;
  80171c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801723:	00 00 00 
	stat->st_dev = dev;
  801726:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80172c:	83 ec 08             	sub    $0x8,%esp
  80172f:	53                   	push   %ebx
  801730:	ff 75 f0             	pushl  -0x10(%ebp)
  801733:	ff 50 14             	call   *0x14(%eax)
  801736:	89 c2                	mov    %eax,%edx
  801738:	83 c4 10             	add    $0x10,%esp
  80173b:	eb 09                	jmp    801746 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80173d:	89 c2                	mov    %eax,%edx
  80173f:	eb 05                	jmp    801746 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801741:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801746:	89 d0                	mov    %edx,%eax
  801748:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80174b:	c9                   	leave  
  80174c:	c3                   	ret    

0080174d <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80174d:	55                   	push   %ebp
  80174e:	89 e5                	mov    %esp,%ebp
  801750:	56                   	push   %esi
  801751:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801752:	83 ec 08             	sub    $0x8,%esp
  801755:	6a 00                	push   $0x0
  801757:	ff 75 08             	pushl  0x8(%ebp)
  80175a:	e8 b7 01 00 00       	call   801916 <open>
  80175f:	89 c3                	mov    %eax,%ebx
  801761:	83 c4 10             	add    $0x10,%esp
  801764:	85 c0                	test   %eax,%eax
  801766:	78 1b                	js     801783 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801768:	83 ec 08             	sub    $0x8,%esp
  80176b:	ff 75 0c             	pushl  0xc(%ebp)
  80176e:	50                   	push   %eax
  80176f:	e8 5b ff ff ff       	call   8016cf <fstat>
  801774:	89 c6                	mov    %eax,%esi
	close(fd);
  801776:	89 1c 24             	mov    %ebx,(%esp)
  801779:	e8 fd fb ff ff       	call   80137b <close>
	return r;
  80177e:	83 c4 10             	add    $0x10,%esp
  801781:	89 f0                	mov    %esi,%eax
}
  801783:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801786:	5b                   	pop    %ebx
  801787:	5e                   	pop    %esi
  801788:	5d                   	pop    %ebp
  801789:	c3                   	ret    

0080178a <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80178a:	55                   	push   %ebp
  80178b:	89 e5                	mov    %esp,%ebp
  80178d:	56                   	push   %esi
  80178e:	53                   	push   %ebx
  80178f:	89 c6                	mov    %eax,%esi
  801791:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801793:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80179a:	75 12                	jne    8017ae <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80179c:	83 ec 0c             	sub    $0xc,%esp
  80179f:	6a 01                	push   $0x1
  8017a1:	e8 bb 0d 00 00       	call   802561 <ipc_find_env>
  8017a6:	a3 00 40 80 00       	mov    %eax,0x804000
  8017ab:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017ae:	6a 07                	push   $0x7
  8017b0:	68 00 50 80 00       	push   $0x805000
  8017b5:	56                   	push   %esi
  8017b6:	ff 35 00 40 80 00    	pushl  0x804000
  8017bc:	e8 4c 0d 00 00       	call   80250d <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017c1:	83 c4 0c             	add    $0xc,%esp
  8017c4:	6a 00                	push   $0x0
  8017c6:	53                   	push   %ebx
  8017c7:	6a 00                	push   $0x0
  8017c9:	e8 ca 0c 00 00       	call   802498 <ipc_recv>
}
  8017ce:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017d1:	5b                   	pop    %ebx
  8017d2:	5e                   	pop    %esi
  8017d3:	5d                   	pop    %ebp
  8017d4:	c3                   	ret    

008017d5 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017d5:	55                   	push   %ebp
  8017d6:	89 e5                	mov    %esp,%ebp
  8017d8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017db:	8b 45 08             	mov    0x8(%ebp),%eax
  8017de:	8b 40 0c             	mov    0xc(%eax),%eax
  8017e1:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017e9:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8017f3:	b8 02 00 00 00       	mov    $0x2,%eax
  8017f8:	e8 8d ff ff ff       	call   80178a <fsipc>
}
  8017fd:	c9                   	leave  
  8017fe:	c3                   	ret    

008017ff <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017ff:	55                   	push   %ebp
  801800:	89 e5                	mov    %esp,%ebp
  801802:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801805:	8b 45 08             	mov    0x8(%ebp),%eax
  801808:	8b 40 0c             	mov    0xc(%eax),%eax
  80180b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801810:	ba 00 00 00 00       	mov    $0x0,%edx
  801815:	b8 06 00 00 00       	mov    $0x6,%eax
  80181a:	e8 6b ff ff ff       	call   80178a <fsipc>
}
  80181f:	c9                   	leave  
  801820:	c3                   	ret    

00801821 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801821:	55                   	push   %ebp
  801822:	89 e5                	mov    %esp,%ebp
  801824:	53                   	push   %ebx
  801825:	83 ec 04             	sub    $0x4,%esp
  801828:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80182b:	8b 45 08             	mov    0x8(%ebp),%eax
  80182e:	8b 40 0c             	mov    0xc(%eax),%eax
  801831:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801836:	ba 00 00 00 00       	mov    $0x0,%edx
  80183b:	b8 05 00 00 00       	mov    $0x5,%eax
  801840:	e8 45 ff ff ff       	call   80178a <fsipc>
  801845:	85 c0                	test   %eax,%eax
  801847:	78 2c                	js     801875 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801849:	83 ec 08             	sub    $0x8,%esp
  80184c:	68 00 50 80 00       	push   $0x805000
  801851:	53                   	push   %ebx
  801852:	e8 86 f0 ff ff       	call   8008dd <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801857:	a1 80 50 80 00       	mov    0x805080,%eax
  80185c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801862:	a1 84 50 80 00       	mov    0x805084,%eax
  801867:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80186d:	83 c4 10             	add    $0x10,%esp
  801870:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801875:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801878:	c9                   	leave  
  801879:	c3                   	ret    

0080187a <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80187a:	55                   	push   %ebp
  80187b:	89 e5                	mov    %esp,%ebp
  80187d:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801880:	68 f8 2d 80 00       	push   $0x802df8
  801885:	68 90 00 00 00       	push   $0x90
  80188a:	68 16 2e 80 00       	push   $0x802e16
  80188f:	e8 44 e9 ff ff       	call   8001d8 <_panic>

00801894 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801894:	55                   	push   %ebp
  801895:	89 e5                	mov    %esp,%ebp
  801897:	56                   	push   %esi
  801898:	53                   	push   %ebx
  801899:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80189c:	8b 45 08             	mov    0x8(%ebp),%eax
  80189f:	8b 40 0c             	mov    0xc(%eax),%eax
  8018a2:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018a7:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8018b2:	b8 03 00 00 00       	mov    $0x3,%eax
  8018b7:	e8 ce fe ff ff       	call   80178a <fsipc>
  8018bc:	89 c3                	mov    %eax,%ebx
  8018be:	85 c0                	test   %eax,%eax
  8018c0:	78 4b                	js     80190d <devfile_read+0x79>
		return r;
	assert(r <= n);
  8018c2:	39 c6                	cmp    %eax,%esi
  8018c4:	73 16                	jae    8018dc <devfile_read+0x48>
  8018c6:	68 21 2e 80 00       	push   $0x802e21
  8018cb:	68 28 2e 80 00       	push   $0x802e28
  8018d0:	6a 7c                	push   $0x7c
  8018d2:	68 16 2e 80 00       	push   $0x802e16
  8018d7:	e8 fc e8 ff ff       	call   8001d8 <_panic>
	assert(r <= PGSIZE);
  8018dc:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018e1:	7e 16                	jle    8018f9 <devfile_read+0x65>
  8018e3:	68 3d 2e 80 00       	push   $0x802e3d
  8018e8:	68 28 2e 80 00       	push   $0x802e28
  8018ed:	6a 7d                	push   $0x7d
  8018ef:	68 16 2e 80 00       	push   $0x802e16
  8018f4:	e8 df e8 ff ff       	call   8001d8 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018f9:	83 ec 04             	sub    $0x4,%esp
  8018fc:	50                   	push   %eax
  8018fd:	68 00 50 80 00       	push   $0x805000
  801902:	ff 75 0c             	pushl  0xc(%ebp)
  801905:	e8 65 f1 ff ff       	call   800a6f <memmove>
	return r;
  80190a:	83 c4 10             	add    $0x10,%esp
}
  80190d:	89 d8                	mov    %ebx,%eax
  80190f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801912:	5b                   	pop    %ebx
  801913:	5e                   	pop    %esi
  801914:	5d                   	pop    %ebp
  801915:	c3                   	ret    

00801916 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801916:	55                   	push   %ebp
  801917:	89 e5                	mov    %esp,%ebp
  801919:	53                   	push   %ebx
  80191a:	83 ec 20             	sub    $0x20,%esp
  80191d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801920:	53                   	push   %ebx
  801921:	e8 7e ef ff ff       	call   8008a4 <strlen>
  801926:	83 c4 10             	add    $0x10,%esp
  801929:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80192e:	7f 67                	jg     801997 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801930:	83 ec 0c             	sub    $0xc,%esp
  801933:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801936:	50                   	push   %eax
  801937:	e8 c6 f8 ff ff       	call   801202 <fd_alloc>
  80193c:	83 c4 10             	add    $0x10,%esp
		return r;
  80193f:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801941:	85 c0                	test   %eax,%eax
  801943:	78 57                	js     80199c <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801945:	83 ec 08             	sub    $0x8,%esp
  801948:	53                   	push   %ebx
  801949:	68 00 50 80 00       	push   $0x805000
  80194e:	e8 8a ef ff ff       	call   8008dd <strcpy>
	fsipcbuf.open.req_omode = mode;
  801953:	8b 45 0c             	mov    0xc(%ebp),%eax
  801956:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80195b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80195e:	b8 01 00 00 00       	mov    $0x1,%eax
  801963:	e8 22 fe ff ff       	call   80178a <fsipc>
  801968:	89 c3                	mov    %eax,%ebx
  80196a:	83 c4 10             	add    $0x10,%esp
  80196d:	85 c0                	test   %eax,%eax
  80196f:	79 14                	jns    801985 <open+0x6f>
		fd_close(fd, 0);
  801971:	83 ec 08             	sub    $0x8,%esp
  801974:	6a 00                	push   $0x0
  801976:	ff 75 f4             	pushl  -0xc(%ebp)
  801979:	e8 7c f9 ff ff       	call   8012fa <fd_close>
		return r;
  80197e:	83 c4 10             	add    $0x10,%esp
  801981:	89 da                	mov    %ebx,%edx
  801983:	eb 17                	jmp    80199c <open+0x86>
	}

	return fd2num(fd);
  801985:	83 ec 0c             	sub    $0xc,%esp
  801988:	ff 75 f4             	pushl  -0xc(%ebp)
  80198b:	e8 4b f8 ff ff       	call   8011db <fd2num>
  801990:	89 c2                	mov    %eax,%edx
  801992:	83 c4 10             	add    $0x10,%esp
  801995:	eb 05                	jmp    80199c <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801997:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80199c:	89 d0                	mov    %edx,%eax
  80199e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019a1:	c9                   	leave  
  8019a2:	c3                   	ret    

008019a3 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019a3:	55                   	push   %ebp
  8019a4:	89 e5                	mov    %esp,%ebp
  8019a6:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8019ae:	b8 08 00 00 00       	mov    $0x8,%eax
  8019b3:	e8 d2 fd ff ff       	call   80178a <fsipc>
}
  8019b8:	c9                   	leave  
  8019b9:	c3                   	ret    

008019ba <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8019ba:	55                   	push   %ebp
  8019bb:	89 e5                	mov    %esp,%ebp
  8019bd:	57                   	push   %edi
  8019be:	56                   	push   %esi
  8019bf:	53                   	push   %ebx
  8019c0:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8019c6:	6a 00                	push   $0x0
  8019c8:	ff 75 08             	pushl  0x8(%ebp)
  8019cb:	e8 46 ff ff ff       	call   801916 <open>
  8019d0:	89 c7                	mov    %eax,%edi
  8019d2:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  8019d8:	83 c4 10             	add    $0x10,%esp
  8019db:	85 c0                	test   %eax,%eax
  8019dd:	0f 88 3a 04 00 00    	js     801e1d <spawn+0x463>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8019e3:	83 ec 04             	sub    $0x4,%esp
  8019e6:	68 00 02 00 00       	push   $0x200
  8019eb:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8019f1:	50                   	push   %eax
  8019f2:	57                   	push   %edi
  8019f3:	e8 50 fb ff ff       	call   801548 <readn>
  8019f8:	83 c4 10             	add    $0x10,%esp
  8019fb:	3d 00 02 00 00       	cmp    $0x200,%eax
  801a00:	75 0c                	jne    801a0e <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  801a02:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801a09:	45 4c 46 
  801a0c:	74 33                	je     801a41 <spawn+0x87>
		close(fd);
  801a0e:	83 ec 0c             	sub    $0xc,%esp
  801a11:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801a17:	e8 5f f9 ff ff       	call   80137b <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801a1c:	83 c4 0c             	add    $0xc,%esp
  801a1f:	68 7f 45 4c 46       	push   $0x464c457f
  801a24:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801a2a:	68 49 2e 80 00       	push   $0x802e49
  801a2f:	e8 7d e8 ff ff       	call   8002b1 <cprintf>
		return -E_NOT_EXEC;
  801a34:	83 c4 10             	add    $0x10,%esp
  801a37:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  801a3c:	e9 3c 04 00 00       	jmp    801e7d <spawn+0x4c3>
  801a41:	b8 07 00 00 00       	mov    $0x7,%eax
  801a46:	cd 30                	int    $0x30
  801a48:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801a4e:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801a54:	85 c0                	test   %eax,%eax
  801a56:	0f 88 c9 03 00 00    	js     801e25 <spawn+0x46b>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801a5c:	89 c6                	mov    %eax,%esi
  801a5e:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801a64:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801a67:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801a6d:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801a73:	b9 11 00 00 00       	mov    $0x11,%ecx
  801a78:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801a7a:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801a80:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801a86:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801a8b:	be 00 00 00 00       	mov    $0x0,%esi
  801a90:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801a93:	eb 13                	jmp    801aa8 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801a95:	83 ec 0c             	sub    $0xc,%esp
  801a98:	50                   	push   %eax
  801a99:	e8 06 ee ff ff       	call   8008a4 <strlen>
  801a9e:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801aa2:	83 c3 01             	add    $0x1,%ebx
  801aa5:	83 c4 10             	add    $0x10,%esp
  801aa8:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801aaf:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801ab2:	85 c0                	test   %eax,%eax
  801ab4:	75 df                	jne    801a95 <spawn+0xdb>
  801ab6:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801abc:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801ac2:	bf 00 10 40 00       	mov    $0x401000,%edi
  801ac7:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801ac9:	89 fa                	mov    %edi,%edx
  801acb:	83 e2 fc             	and    $0xfffffffc,%edx
  801ace:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801ad5:	29 c2                	sub    %eax,%edx
  801ad7:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801add:	8d 42 f8             	lea    -0x8(%edx),%eax
  801ae0:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801ae5:	0f 86 4a 03 00 00    	jbe    801e35 <spawn+0x47b>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801aeb:	83 ec 04             	sub    $0x4,%esp
  801aee:	6a 07                	push   $0x7
  801af0:	68 00 00 40 00       	push   $0x400000
  801af5:	6a 00                	push   $0x0
  801af7:	e8 e4 f1 ff ff       	call   800ce0 <sys_page_alloc>
  801afc:	83 c4 10             	add    $0x10,%esp
  801aff:	85 c0                	test   %eax,%eax
  801b01:	0f 88 35 03 00 00    	js     801e3c <spawn+0x482>
  801b07:	be 00 00 00 00       	mov    $0x0,%esi
  801b0c:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801b12:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801b15:	eb 30                	jmp    801b47 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801b17:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801b1d:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801b23:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801b26:	83 ec 08             	sub    $0x8,%esp
  801b29:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801b2c:	57                   	push   %edi
  801b2d:	e8 ab ed ff ff       	call   8008dd <strcpy>
		string_store += strlen(argv[i]) + 1;
  801b32:	83 c4 04             	add    $0x4,%esp
  801b35:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801b38:	e8 67 ed ff ff       	call   8008a4 <strlen>
  801b3d:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801b41:	83 c6 01             	add    $0x1,%esi
  801b44:	83 c4 10             	add    $0x10,%esp
  801b47:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801b4d:	7f c8                	jg     801b17 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801b4f:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801b55:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801b5b:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801b62:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801b68:	74 19                	je     801b83 <spawn+0x1c9>
  801b6a:	68 c0 2e 80 00       	push   $0x802ec0
  801b6f:	68 28 2e 80 00       	push   $0x802e28
  801b74:	68 f2 00 00 00       	push   $0xf2
  801b79:	68 63 2e 80 00       	push   $0x802e63
  801b7e:	e8 55 e6 ff ff       	call   8001d8 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801b83:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801b89:	89 c8                	mov    %ecx,%eax
  801b8b:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801b90:	89 41 fc             	mov    %eax,-0x4(%ecx)
	argv_store[-2] = argc;
  801b93:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801b99:	89 41 f8             	mov    %eax,-0x8(%ecx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801b9c:	8d 81 f8 cf 7f ee    	lea    -0x11803008(%ecx),%eax
  801ba2:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801ba8:	83 ec 0c             	sub    $0xc,%esp
  801bab:	6a 07                	push   $0x7
  801bad:	68 00 d0 bf ee       	push   $0xeebfd000
  801bb2:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801bb8:	68 00 00 40 00       	push   $0x400000
  801bbd:	6a 00                	push   $0x0
  801bbf:	e8 5f f1 ff ff       	call   800d23 <sys_page_map>
  801bc4:	89 c3                	mov    %eax,%ebx
  801bc6:	83 c4 20             	add    $0x20,%esp
  801bc9:	85 c0                	test   %eax,%eax
  801bcb:	0f 88 9a 02 00 00    	js     801e6b <spawn+0x4b1>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801bd1:	83 ec 08             	sub    $0x8,%esp
  801bd4:	68 00 00 40 00       	push   $0x400000
  801bd9:	6a 00                	push   $0x0
  801bdb:	e8 85 f1 ff ff       	call   800d65 <sys_page_unmap>
  801be0:	89 c3                	mov    %eax,%ebx
  801be2:	83 c4 10             	add    $0x10,%esp
  801be5:	85 c0                	test   %eax,%eax
  801be7:	0f 88 7e 02 00 00    	js     801e6b <spawn+0x4b1>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801bed:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801bf3:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801bfa:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801c00:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801c07:	00 00 00 
  801c0a:	e9 86 01 00 00       	jmp    801d95 <spawn+0x3db>
		if (ph->p_type != ELF_PROG_LOAD)
  801c0f:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801c15:	83 38 01             	cmpl   $0x1,(%eax)
  801c18:	0f 85 69 01 00 00    	jne    801d87 <spawn+0x3cd>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801c1e:	89 c1                	mov    %eax,%ecx
  801c20:	8b 40 18             	mov    0x18(%eax),%eax
  801c23:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801c29:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801c2c:	83 f8 01             	cmp    $0x1,%eax
  801c2f:	19 c0                	sbb    %eax,%eax
  801c31:	83 e0 fe             	and    $0xfffffffe,%eax
  801c34:	83 c0 07             	add    $0x7,%eax
  801c37:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801c3d:	89 c8                	mov    %ecx,%eax
  801c3f:	8b 49 04             	mov    0x4(%ecx),%ecx
  801c42:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
  801c48:	8b 78 10             	mov    0x10(%eax),%edi
  801c4b:	8b 50 14             	mov    0x14(%eax),%edx
  801c4e:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  801c54:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801c57:	89 f0                	mov    %esi,%eax
  801c59:	25 ff 0f 00 00       	and    $0xfff,%eax
  801c5e:	74 14                	je     801c74 <spawn+0x2ba>
		va -= i;
  801c60:	29 c6                	sub    %eax,%esi
		memsz += i;
  801c62:	01 c2                	add    %eax,%edx
  801c64:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  801c6a:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801c6c:	29 c1                	sub    %eax,%ecx
  801c6e:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801c74:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c79:	e9 f7 00 00 00       	jmp    801d75 <spawn+0x3bb>
		if (i >= filesz) {
  801c7e:	39 df                	cmp    %ebx,%edi
  801c80:	77 27                	ja     801ca9 <spawn+0x2ef>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801c82:	83 ec 04             	sub    $0x4,%esp
  801c85:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801c8b:	56                   	push   %esi
  801c8c:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801c92:	e8 49 f0 ff ff       	call   800ce0 <sys_page_alloc>
  801c97:	83 c4 10             	add    $0x10,%esp
  801c9a:	85 c0                	test   %eax,%eax
  801c9c:	0f 89 c7 00 00 00    	jns    801d69 <spawn+0x3af>
  801ca2:	89 c3                	mov    %eax,%ebx
  801ca4:	e9 a1 01 00 00       	jmp    801e4a <spawn+0x490>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801ca9:	83 ec 04             	sub    $0x4,%esp
  801cac:	6a 07                	push   $0x7
  801cae:	68 00 00 40 00       	push   $0x400000
  801cb3:	6a 00                	push   $0x0
  801cb5:	e8 26 f0 ff ff       	call   800ce0 <sys_page_alloc>
  801cba:	83 c4 10             	add    $0x10,%esp
  801cbd:	85 c0                	test   %eax,%eax
  801cbf:	0f 88 7b 01 00 00    	js     801e40 <spawn+0x486>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801cc5:	83 ec 08             	sub    $0x8,%esp
  801cc8:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801cce:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801cd4:	50                   	push   %eax
  801cd5:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801cdb:	e8 3d f9 ff ff       	call   80161d <seek>
  801ce0:	83 c4 10             	add    $0x10,%esp
  801ce3:	85 c0                	test   %eax,%eax
  801ce5:	0f 88 59 01 00 00    	js     801e44 <spawn+0x48a>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801ceb:	83 ec 04             	sub    $0x4,%esp
  801cee:	89 f8                	mov    %edi,%eax
  801cf0:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801cf6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801cfb:	b9 00 10 00 00       	mov    $0x1000,%ecx
  801d00:	0f 47 c1             	cmova  %ecx,%eax
  801d03:	50                   	push   %eax
  801d04:	68 00 00 40 00       	push   $0x400000
  801d09:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801d0f:	e8 34 f8 ff ff       	call   801548 <readn>
  801d14:	83 c4 10             	add    $0x10,%esp
  801d17:	85 c0                	test   %eax,%eax
  801d19:	0f 88 29 01 00 00    	js     801e48 <spawn+0x48e>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801d1f:	83 ec 0c             	sub    $0xc,%esp
  801d22:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801d28:	56                   	push   %esi
  801d29:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801d2f:	68 00 00 40 00       	push   $0x400000
  801d34:	6a 00                	push   $0x0
  801d36:	e8 e8 ef ff ff       	call   800d23 <sys_page_map>
  801d3b:	83 c4 20             	add    $0x20,%esp
  801d3e:	85 c0                	test   %eax,%eax
  801d40:	79 15                	jns    801d57 <spawn+0x39d>
				panic("spawn: sys_page_map data: %e", r);
  801d42:	50                   	push   %eax
  801d43:	68 6f 2e 80 00       	push   $0x802e6f
  801d48:	68 25 01 00 00       	push   $0x125
  801d4d:	68 63 2e 80 00       	push   $0x802e63
  801d52:	e8 81 e4 ff ff       	call   8001d8 <_panic>
			sys_page_unmap(0, UTEMP);
  801d57:	83 ec 08             	sub    $0x8,%esp
  801d5a:	68 00 00 40 00       	push   $0x400000
  801d5f:	6a 00                	push   $0x0
  801d61:	e8 ff ef ff ff       	call   800d65 <sys_page_unmap>
  801d66:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801d69:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801d6f:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801d75:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801d7b:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  801d81:	0f 87 f7 fe ff ff    	ja     801c7e <spawn+0x2c4>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801d87:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801d8e:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801d95:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801d9c:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801da2:	0f 8c 67 fe ff ff    	jl     801c0f <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801da8:	83 ec 0c             	sub    $0xc,%esp
  801dab:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801db1:	e8 c5 f5 ff ff       	call   80137b <close>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801db6:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801dbd:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801dc0:	83 c4 08             	add    $0x8,%esp
  801dc3:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801dc9:	50                   	push   %eax
  801dca:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801dd0:	e8 14 f0 ff ff       	call   800de9 <sys_env_set_trapframe>
  801dd5:	83 c4 10             	add    $0x10,%esp
  801dd8:	85 c0                	test   %eax,%eax
  801dda:	79 15                	jns    801df1 <spawn+0x437>
		panic("sys_env_set_trapframe: %e", r);
  801ddc:	50                   	push   %eax
  801ddd:	68 8c 2e 80 00       	push   $0x802e8c
  801de2:	68 86 00 00 00       	push   $0x86
  801de7:	68 63 2e 80 00       	push   $0x802e63
  801dec:	e8 e7 e3 ff ff       	call   8001d8 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801df1:	83 ec 08             	sub    $0x8,%esp
  801df4:	6a 02                	push   $0x2
  801df6:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801dfc:	e8 a6 ef ff ff       	call   800da7 <sys_env_set_status>
  801e01:	83 c4 10             	add    $0x10,%esp
  801e04:	85 c0                	test   %eax,%eax
  801e06:	79 25                	jns    801e2d <spawn+0x473>
		panic("sys_env_set_status: %e", r);
  801e08:	50                   	push   %eax
  801e09:	68 a6 2e 80 00       	push   $0x802ea6
  801e0e:	68 89 00 00 00       	push   $0x89
  801e13:	68 63 2e 80 00       	push   $0x802e63
  801e18:	e8 bb e3 ff ff       	call   8001d8 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801e1d:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801e23:	eb 58                	jmp    801e7d <spawn+0x4c3>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801e25:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801e2b:	eb 50                	jmp    801e7d <spawn+0x4c3>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801e2d:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801e33:	eb 48                	jmp    801e7d <spawn+0x4c3>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801e35:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801e3a:	eb 41                	jmp    801e7d <spawn+0x4c3>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801e3c:	89 c3                	mov    %eax,%ebx
  801e3e:	eb 3d                	jmp    801e7d <spawn+0x4c3>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801e40:	89 c3                	mov    %eax,%ebx
  801e42:	eb 06                	jmp    801e4a <spawn+0x490>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801e44:	89 c3                	mov    %eax,%ebx
  801e46:	eb 02                	jmp    801e4a <spawn+0x490>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801e48:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801e4a:	83 ec 0c             	sub    $0xc,%esp
  801e4d:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801e53:	e8 09 ee ff ff       	call   800c61 <sys_env_destroy>
	close(fd);
  801e58:	83 c4 04             	add    $0x4,%esp
  801e5b:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801e61:	e8 15 f5 ff ff       	call   80137b <close>
	return r;
  801e66:	83 c4 10             	add    $0x10,%esp
  801e69:	eb 12                	jmp    801e7d <spawn+0x4c3>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801e6b:	83 ec 08             	sub    $0x8,%esp
  801e6e:	68 00 00 40 00       	push   $0x400000
  801e73:	6a 00                	push   $0x0
  801e75:	e8 eb ee ff ff       	call   800d65 <sys_page_unmap>
  801e7a:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801e7d:	89 d8                	mov    %ebx,%eax
  801e7f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e82:	5b                   	pop    %ebx
  801e83:	5e                   	pop    %esi
  801e84:	5f                   	pop    %edi
  801e85:	5d                   	pop    %ebp
  801e86:	c3                   	ret    

00801e87 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801e87:	55                   	push   %ebp
  801e88:	89 e5                	mov    %esp,%ebp
  801e8a:	56                   	push   %esi
  801e8b:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801e8c:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801e8f:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801e94:	eb 03                	jmp    801e99 <spawnl+0x12>
		argc++;
  801e96:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801e99:	83 c2 04             	add    $0x4,%edx
  801e9c:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801ea0:	75 f4                	jne    801e96 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801ea2:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801ea9:	83 e2 f0             	and    $0xfffffff0,%edx
  801eac:	29 d4                	sub    %edx,%esp
  801eae:	8d 54 24 03          	lea    0x3(%esp),%edx
  801eb2:	c1 ea 02             	shr    $0x2,%edx
  801eb5:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801ebc:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801ebe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ec1:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801ec8:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801ecf:	00 
  801ed0:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801ed2:	b8 00 00 00 00       	mov    $0x0,%eax
  801ed7:	eb 0a                	jmp    801ee3 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801ed9:	83 c0 01             	add    $0x1,%eax
  801edc:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801ee0:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801ee3:	39 d0                	cmp    %edx,%eax
  801ee5:	75 f2                	jne    801ed9 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801ee7:	83 ec 08             	sub    $0x8,%esp
  801eea:	56                   	push   %esi
  801eeb:	ff 75 08             	pushl  0x8(%ebp)
  801eee:	e8 c7 fa ff ff       	call   8019ba <spawn>
}
  801ef3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ef6:	5b                   	pop    %ebx
  801ef7:	5e                   	pop    %esi
  801ef8:	5d                   	pop    %ebp
  801ef9:	c3                   	ret    

00801efa <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801efa:	55                   	push   %ebp
  801efb:	89 e5                	mov    %esp,%ebp
  801efd:	56                   	push   %esi
  801efe:	53                   	push   %ebx
  801eff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801f02:	83 ec 0c             	sub    $0xc,%esp
  801f05:	ff 75 08             	pushl  0x8(%ebp)
  801f08:	e8 de f2 ff ff       	call   8011eb <fd2data>
  801f0d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801f0f:	83 c4 08             	add    $0x8,%esp
  801f12:	68 e8 2e 80 00       	push   $0x802ee8
  801f17:	53                   	push   %ebx
  801f18:	e8 c0 e9 ff ff       	call   8008dd <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801f1d:	8b 46 04             	mov    0x4(%esi),%eax
  801f20:	2b 06                	sub    (%esi),%eax
  801f22:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801f28:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801f2f:	00 00 00 
	stat->st_dev = &devpipe;
  801f32:	c7 83 88 00 00 00 28 	movl   $0x803028,0x88(%ebx)
  801f39:	30 80 00 
	return 0;
}
  801f3c:	b8 00 00 00 00       	mov    $0x0,%eax
  801f41:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f44:	5b                   	pop    %ebx
  801f45:	5e                   	pop    %esi
  801f46:	5d                   	pop    %ebp
  801f47:	c3                   	ret    

00801f48 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801f48:	55                   	push   %ebp
  801f49:	89 e5                	mov    %esp,%ebp
  801f4b:	53                   	push   %ebx
  801f4c:	83 ec 0c             	sub    $0xc,%esp
  801f4f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801f52:	53                   	push   %ebx
  801f53:	6a 00                	push   $0x0
  801f55:	e8 0b ee ff ff       	call   800d65 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801f5a:	89 1c 24             	mov    %ebx,(%esp)
  801f5d:	e8 89 f2 ff ff       	call   8011eb <fd2data>
  801f62:	83 c4 08             	add    $0x8,%esp
  801f65:	50                   	push   %eax
  801f66:	6a 00                	push   $0x0
  801f68:	e8 f8 ed ff ff       	call   800d65 <sys_page_unmap>
}
  801f6d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f70:	c9                   	leave  
  801f71:	c3                   	ret    

00801f72 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801f72:	55                   	push   %ebp
  801f73:	89 e5                	mov    %esp,%ebp
  801f75:	57                   	push   %edi
  801f76:	56                   	push   %esi
  801f77:	53                   	push   %ebx
  801f78:	83 ec 1c             	sub    $0x1c,%esp
  801f7b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801f7e:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801f80:	a1 04 40 80 00       	mov    0x804004,%eax
  801f85:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801f88:	83 ec 0c             	sub    $0xc,%esp
  801f8b:	ff 75 e0             	pushl  -0x20(%ebp)
  801f8e:	e8 07 06 00 00       	call   80259a <pageref>
  801f93:	89 c3                	mov    %eax,%ebx
  801f95:	89 3c 24             	mov    %edi,(%esp)
  801f98:	e8 fd 05 00 00       	call   80259a <pageref>
  801f9d:	83 c4 10             	add    $0x10,%esp
  801fa0:	39 c3                	cmp    %eax,%ebx
  801fa2:	0f 94 c1             	sete   %cl
  801fa5:	0f b6 c9             	movzbl %cl,%ecx
  801fa8:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801fab:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801fb1:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801fb4:	39 ce                	cmp    %ecx,%esi
  801fb6:	74 1b                	je     801fd3 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801fb8:	39 c3                	cmp    %eax,%ebx
  801fba:	75 c4                	jne    801f80 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801fbc:	8b 42 58             	mov    0x58(%edx),%eax
  801fbf:	ff 75 e4             	pushl  -0x1c(%ebp)
  801fc2:	50                   	push   %eax
  801fc3:	56                   	push   %esi
  801fc4:	68 ef 2e 80 00       	push   $0x802eef
  801fc9:	e8 e3 e2 ff ff       	call   8002b1 <cprintf>
  801fce:	83 c4 10             	add    $0x10,%esp
  801fd1:	eb ad                	jmp    801f80 <_pipeisclosed+0xe>
	}
}
  801fd3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801fd6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fd9:	5b                   	pop    %ebx
  801fda:	5e                   	pop    %esi
  801fdb:	5f                   	pop    %edi
  801fdc:	5d                   	pop    %ebp
  801fdd:	c3                   	ret    

00801fde <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801fde:	55                   	push   %ebp
  801fdf:	89 e5                	mov    %esp,%ebp
  801fe1:	57                   	push   %edi
  801fe2:	56                   	push   %esi
  801fe3:	53                   	push   %ebx
  801fe4:	83 ec 28             	sub    $0x28,%esp
  801fe7:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801fea:	56                   	push   %esi
  801feb:	e8 fb f1 ff ff       	call   8011eb <fd2data>
  801ff0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ff2:	83 c4 10             	add    $0x10,%esp
  801ff5:	bf 00 00 00 00       	mov    $0x0,%edi
  801ffa:	eb 4b                	jmp    802047 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801ffc:	89 da                	mov    %ebx,%edx
  801ffe:	89 f0                	mov    %esi,%eax
  802000:	e8 6d ff ff ff       	call   801f72 <_pipeisclosed>
  802005:	85 c0                	test   %eax,%eax
  802007:	75 48                	jne    802051 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802009:	e8 b3 ec ff ff       	call   800cc1 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80200e:	8b 43 04             	mov    0x4(%ebx),%eax
  802011:	8b 0b                	mov    (%ebx),%ecx
  802013:	8d 51 20             	lea    0x20(%ecx),%edx
  802016:	39 d0                	cmp    %edx,%eax
  802018:	73 e2                	jae    801ffc <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80201a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80201d:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802021:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802024:	89 c2                	mov    %eax,%edx
  802026:	c1 fa 1f             	sar    $0x1f,%edx
  802029:	89 d1                	mov    %edx,%ecx
  80202b:	c1 e9 1b             	shr    $0x1b,%ecx
  80202e:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802031:	83 e2 1f             	and    $0x1f,%edx
  802034:	29 ca                	sub    %ecx,%edx
  802036:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80203a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80203e:	83 c0 01             	add    $0x1,%eax
  802041:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802044:	83 c7 01             	add    $0x1,%edi
  802047:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80204a:	75 c2                	jne    80200e <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80204c:	8b 45 10             	mov    0x10(%ebp),%eax
  80204f:	eb 05                	jmp    802056 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802051:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802056:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802059:	5b                   	pop    %ebx
  80205a:	5e                   	pop    %esi
  80205b:	5f                   	pop    %edi
  80205c:	5d                   	pop    %ebp
  80205d:	c3                   	ret    

0080205e <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80205e:	55                   	push   %ebp
  80205f:	89 e5                	mov    %esp,%ebp
  802061:	57                   	push   %edi
  802062:	56                   	push   %esi
  802063:	53                   	push   %ebx
  802064:	83 ec 18             	sub    $0x18,%esp
  802067:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80206a:	57                   	push   %edi
  80206b:	e8 7b f1 ff ff       	call   8011eb <fd2data>
  802070:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802072:	83 c4 10             	add    $0x10,%esp
  802075:	bb 00 00 00 00       	mov    $0x0,%ebx
  80207a:	eb 3d                	jmp    8020b9 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80207c:	85 db                	test   %ebx,%ebx
  80207e:	74 04                	je     802084 <devpipe_read+0x26>
				return i;
  802080:	89 d8                	mov    %ebx,%eax
  802082:	eb 44                	jmp    8020c8 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802084:	89 f2                	mov    %esi,%edx
  802086:	89 f8                	mov    %edi,%eax
  802088:	e8 e5 fe ff ff       	call   801f72 <_pipeisclosed>
  80208d:	85 c0                	test   %eax,%eax
  80208f:	75 32                	jne    8020c3 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802091:	e8 2b ec ff ff       	call   800cc1 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802096:	8b 06                	mov    (%esi),%eax
  802098:	3b 46 04             	cmp    0x4(%esi),%eax
  80209b:	74 df                	je     80207c <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80209d:	99                   	cltd   
  80209e:	c1 ea 1b             	shr    $0x1b,%edx
  8020a1:	01 d0                	add    %edx,%eax
  8020a3:	83 e0 1f             	and    $0x1f,%eax
  8020a6:	29 d0                	sub    %edx,%eax
  8020a8:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8020ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8020b0:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8020b3:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020b6:	83 c3 01             	add    $0x1,%ebx
  8020b9:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8020bc:	75 d8                	jne    802096 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8020be:	8b 45 10             	mov    0x10(%ebp),%eax
  8020c1:	eb 05                	jmp    8020c8 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8020c3:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8020c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020cb:	5b                   	pop    %ebx
  8020cc:	5e                   	pop    %esi
  8020cd:	5f                   	pop    %edi
  8020ce:	5d                   	pop    %ebp
  8020cf:	c3                   	ret    

008020d0 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8020d0:	55                   	push   %ebp
  8020d1:	89 e5                	mov    %esp,%ebp
  8020d3:	56                   	push   %esi
  8020d4:	53                   	push   %ebx
  8020d5:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8020d8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020db:	50                   	push   %eax
  8020dc:	e8 21 f1 ff ff       	call   801202 <fd_alloc>
  8020e1:	83 c4 10             	add    $0x10,%esp
  8020e4:	89 c2                	mov    %eax,%edx
  8020e6:	85 c0                	test   %eax,%eax
  8020e8:	0f 88 2c 01 00 00    	js     80221a <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020ee:	83 ec 04             	sub    $0x4,%esp
  8020f1:	68 07 04 00 00       	push   $0x407
  8020f6:	ff 75 f4             	pushl  -0xc(%ebp)
  8020f9:	6a 00                	push   $0x0
  8020fb:	e8 e0 eb ff ff       	call   800ce0 <sys_page_alloc>
  802100:	83 c4 10             	add    $0x10,%esp
  802103:	89 c2                	mov    %eax,%edx
  802105:	85 c0                	test   %eax,%eax
  802107:	0f 88 0d 01 00 00    	js     80221a <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80210d:	83 ec 0c             	sub    $0xc,%esp
  802110:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802113:	50                   	push   %eax
  802114:	e8 e9 f0 ff ff       	call   801202 <fd_alloc>
  802119:	89 c3                	mov    %eax,%ebx
  80211b:	83 c4 10             	add    $0x10,%esp
  80211e:	85 c0                	test   %eax,%eax
  802120:	0f 88 e2 00 00 00    	js     802208 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802126:	83 ec 04             	sub    $0x4,%esp
  802129:	68 07 04 00 00       	push   $0x407
  80212e:	ff 75 f0             	pushl  -0x10(%ebp)
  802131:	6a 00                	push   $0x0
  802133:	e8 a8 eb ff ff       	call   800ce0 <sys_page_alloc>
  802138:	89 c3                	mov    %eax,%ebx
  80213a:	83 c4 10             	add    $0x10,%esp
  80213d:	85 c0                	test   %eax,%eax
  80213f:	0f 88 c3 00 00 00    	js     802208 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802145:	83 ec 0c             	sub    $0xc,%esp
  802148:	ff 75 f4             	pushl  -0xc(%ebp)
  80214b:	e8 9b f0 ff ff       	call   8011eb <fd2data>
  802150:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802152:	83 c4 0c             	add    $0xc,%esp
  802155:	68 07 04 00 00       	push   $0x407
  80215a:	50                   	push   %eax
  80215b:	6a 00                	push   $0x0
  80215d:	e8 7e eb ff ff       	call   800ce0 <sys_page_alloc>
  802162:	89 c3                	mov    %eax,%ebx
  802164:	83 c4 10             	add    $0x10,%esp
  802167:	85 c0                	test   %eax,%eax
  802169:	0f 88 89 00 00 00    	js     8021f8 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80216f:	83 ec 0c             	sub    $0xc,%esp
  802172:	ff 75 f0             	pushl  -0x10(%ebp)
  802175:	e8 71 f0 ff ff       	call   8011eb <fd2data>
  80217a:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802181:	50                   	push   %eax
  802182:	6a 00                	push   $0x0
  802184:	56                   	push   %esi
  802185:	6a 00                	push   $0x0
  802187:	e8 97 eb ff ff       	call   800d23 <sys_page_map>
  80218c:	89 c3                	mov    %eax,%ebx
  80218e:	83 c4 20             	add    $0x20,%esp
  802191:	85 c0                	test   %eax,%eax
  802193:	78 55                	js     8021ea <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802195:	8b 15 28 30 80 00    	mov    0x803028,%edx
  80219b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80219e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8021a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021a3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8021aa:	8b 15 28 30 80 00    	mov    0x803028,%edx
  8021b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021b3:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8021b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021b8:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8021bf:	83 ec 0c             	sub    $0xc,%esp
  8021c2:	ff 75 f4             	pushl  -0xc(%ebp)
  8021c5:	e8 11 f0 ff ff       	call   8011db <fd2num>
  8021ca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021cd:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8021cf:	83 c4 04             	add    $0x4,%esp
  8021d2:	ff 75 f0             	pushl  -0x10(%ebp)
  8021d5:	e8 01 f0 ff ff       	call   8011db <fd2num>
  8021da:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021dd:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8021e0:	83 c4 10             	add    $0x10,%esp
  8021e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8021e8:	eb 30                	jmp    80221a <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8021ea:	83 ec 08             	sub    $0x8,%esp
  8021ed:	56                   	push   %esi
  8021ee:	6a 00                	push   $0x0
  8021f0:	e8 70 eb ff ff       	call   800d65 <sys_page_unmap>
  8021f5:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8021f8:	83 ec 08             	sub    $0x8,%esp
  8021fb:	ff 75 f0             	pushl  -0x10(%ebp)
  8021fe:	6a 00                	push   $0x0
  802200:	e8 60 eb ff ff       	call   800d65 <sys_page_unmap>
  802205:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802208:	83 ec 08             	sub    $0x8,%esp
  80220b:	ff 75 f4             	pushl  -0xc(%ebp)
  80220e:	6a 00                	push   $0x0
  802210:	e8 50 eb ff ff       	call   800d65 <sys_page_unmap>
  802215:	83 c4 10             	add    $0x10,%esp
  802218:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80221a:	89 d0                	mov    %edx,%eax
  80221c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80221f:	5b                   	pop    %ebx
  802220:	5e                   	pop    %esi
  802221:	5d                   	pop    %ebp
  802222:	c3                   	ret    

00802223 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802223:	55                   	push   %ebp
  802224:	89 e5                	mov    %esp,%ebp
  802226:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802229:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80222c:	50                   	push   %eax
  80222d:	ff 75 08             	pushl  0x8(%ebp)
  802230:	e8 1c f0 ff ff       	call   801251 <fd_lookup>
  802235:	83 c4 10             	add    $0x10,%esp
  802238:	85 c0                	test   %eax,%eax
  80223a:	78 18                	js     802254 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80223c:	83 ec 0c             	sub    $0xc,%esp
  80223f:	ff 75 f4             	pushl  -0xc(%ebp)
  802242:	e8 a4 ef ff ff       	call   8011eb <fd2data>
	return _pipeisclosed(fd, p);
  802247:	89 c2                	mov    %eax,%edx
  802249:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80224c:	e8 21 fd ff ff       	call   801f72 <_pipeisclosed>
  802251:	83 c4 10             	add    $0x10,%esp
}
  802254:	c9                   	leave  
  802255:	c3                   	ret    

00802256 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802256:	55                   	push   %ebp
  802257:	89 e5                	mov    %esp,%ebp
  802259:	56                   	push   %esi
  80225a:	53                   	push   %ebx
  80225b:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  80225e:	85 f6                	test   %esi,%esi
  802260:	75 16                	jne    802278 <wait+0x22>
  802262:	68 07 2f 80 00       	push   $0x802f07
  802267:	68 28 2e 80 00       	push   $0x802e28
  80226c:	6a 09                	push   $0x9
  80226e:	68 12 2f 80 00       	push   $0x802f12
  802273:	e8 60 df ff ff       	call   8001d8 <_panic>
	e = &envs[ENVX(envid)];
  802278:	89 f3                	mov    %esi,%ebx
  80227a:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802280:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  802283:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  802289:	eb 05                	jmp    802290 <wait+0x3a>
		sys_yield();
  80228b:	e8 31 ea ff ff       	call   800cc1 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802290:	8b 43 48             	mov    0x48(%ebx),%eax
  802293:	39 c6                	cmp    %eax,%esi
  802295:	75 07                	jne    80229e <wait+0x48>
  802297:	8b 43 54             	mov    0x54(%ebx),%eax
  80229a:	85 c0                	test   %eax,%eax
  80229c:	75 ed                	jne    80228b <wait+0x35>
		sys_yield();
}
  80229e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022a1:	5b                   	pop    %ebx
  8022a2:	5e                   	pop    %esi
  8022a3:	5d                   	pop    %ebp
  8022a4:	c3                   	ret    

008022a5 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8022a5:	55                   	push   %ebp
  8022a6:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8022a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8022ad:	5d                   	pop    %ebp
  8022ae:	c3                   	ret    

008022af <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8022af:	55                   	push   %ebp
  8022b0:	89 e5                	mov    %esp,%ebp
  8022b2:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8022b5:	68 1d 2f 80 00       	push   $0x802f1d
  8022ba:	ff 75 0c             	pushl  0xc(%ebp)
  8022bd:	e8 1b e6 ff ff       	call   8008dd <strcpy>
	return 0;
}
  8022c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8022c7:	c9                   	leave  
  8022c8:	c3                   	ret    

008022c9 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8022c9:	55                   	push   %ebp
  8022ca:	89 e5                	mov    %esp,%ebp
  8022cc:	57                   	push   %edi
  8022cd:	56                   	push   %esi
  8022ce:	53                   	push   %ebx
  8022cf:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022d5:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8022da:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022e0:	eb 2d                	jmp    80230f <devcons_write+0x46>
		m = n - tot;
  8022e2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8022e5:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8022e7:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8022ea:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8022ef:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8022f2:	83 ec 04             	sub    $0x4,%esp
  8022f5:	53                   	push   %ebx
  8022f6:	03 45 0c             	add    0xc(%ebp),%eax
  8022f9:	50                   	push   %eax
  8022fa:	57                   	push   %edi
  8022fb:	e8 6f e7 ff ff       	call   800a6f <memmove>
		sys_cputs(buf, m);
  802300:	83 c4 08             	add    $0x8,%esp
  802303:	53                   	push   %ebx
  802304:	57                   	push   %edi
  802305:	e8 1a e9 ff ff       	call   800c24 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80230a:	01 de                	add    %ebx,%esi
  80230c:	83 c4 10             	add    $0x10,%esp
  80230f:	89 f0                	mov    %esi,%eax
  802311:	3b 75 10             	cmp    0x10(%ebp),%esi
  802314:	72 cc                	jb     8022e2 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802316:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802319:	5b                   	pop    %ebx
  80231a:	5e                   	pop    %esi
  80231b:	5f                   	pop    %edi
  80231c:	5d                   	pop    %ebp
  80231d:	c3                   	ret    

0080231e <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80231e:	55                   	push   %ebp
  80231f:	89 e5                	mov    %esp,%ebp
  802321:	83 ec 08             	sub    $0x8,%esp
  802324:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802329:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80232d:	74 2a                	je     802359 <devcons_read+0x3b>
  80232f:	eb 05                	jmp    802336 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802331:	e8 8b e9 ff ff       	call   800cc1 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802336:	e8 07 e9 ff ff       	call   800c42 <sys_cgetc>
  80233b:	85 c0                	test   %eax,%eax
  80233d:	74 f2                	je     802331 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80233f:	85 c0                	test   %eax,%eax
  802341:	78 16                	js     802359 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802343:	83 f8 04             	cmp    $0x4,%eax
  802346:	74 0c                	je     802354 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802348:	8b 55 0c             	mov    0xc(%ebp),%edx
  80234b:	88 02                	mov    %al,(%edx)
	return 1;
  80234d:	b8 01 00 00 00       	mov    $0x1,%eax
  802352:	eb 05                	jmp    802359 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802354:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802359:	c9                   	leave  
  80235a:	c3                   	ret    

0080235b <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80235b:	55                   	push   %ebp
  80235c:	89 e5                	mov    %esp,%ebp
  80235e:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802361:	8b 45 08             	mov    0x8(%ebp),%eax
  802364:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802367:	6a 01                	push   $0x1
  802369:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80236c:	50                   	push   %eax
  80236d:	e8 b2 e8 ff ff       	call   800c24 <sys_cputs>
}
  802372:	83 c4 10             	add    $0x10,%esp
  802375:	c9                   	leave  
  802376:	c3                   	ret    

00802377 <getchar>:

int
getchar(void)
{
  802377:	55                   	push   %ebp
  802378:	89 e5                	mov    %esp,%ebp
  80237a:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80237d:	6a 01                	push   $0x1
  80237f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802382:	50                   	push   %eax
  802383:	6a 00                	push   $0x0
  802385:	e8 2d f1 ff ff       	call   8014b7 <read>
	if (r < 0)
  80238a:	83 c4 10             	add    $0x10,%esp
  80238d:	85 c0                	test   %eax,%eax
  80238f:	78 0f                	js     8023a0 <getchar+0x29>
		return r;
	if (r < 1)
  802391:	85 c0                	test   %eax,%eax
  802393:	7e 06                	jle    80239b <getchar+0x24>
		return -E_EOF;
	return c;
  802395:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802399:	eb 05                	jmp    8023a0 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80239b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8023a0:	c9                   	leave  
  8023a1:	c3                   	ret    

008023a2 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8023a2:	55                   	push   %ebp
  8023a3:	89 e5                	mov    %esp,%ebp
  8023a5:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8023a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023ab:	50                   	push   %eax
  8023ac:	ff 75 08             	pushl  0x8(%ebp)
  8023af:	e8 9d ee ff ff       	call   801251 <fd_lookup>
  8023b4:	83 c4 10             	add    $0x10,%esp
  8023b7:	85 c0                	test   %eax,%eax
  8023b9:	78 11                	js     8023cc <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8023bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023be:	8b 15 44 30 80 00    	mov    0x803044,%edx
  8023c4:	39 10                	cmp    %edx,(%eax)
  8023c6:	0f 94 c0             	sete   %al
  8023c9:	0f b6 c0             	movzbl %al,%eax
}
  8023cc:	c9                   	leave  
  8023cd:	c3                   	ret    

008023ce <opencons>:

int
opencons(void)
{
  8023ce:	55                   	push   %ebp
  8023cf:	89 e5                	mov    %esp,%ebp
  8023d1:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8023d4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023d7:	50                   	push   %eax
  8023d8:	e8 25 ee ff ff       	call   801202 <fd_alloc>
  8023dd:	83 c4 10             	add    $0x10,%esp
		return r;
  8023e0:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8023e2:	85 c0                	test   %eax,%eax
  8023e4:	78 3e                	js     802424 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8023e6:	83 ec 04             	sub    $0x4,%esp
  8023e9:	68 07 04 00 00       	push   $0x407
  8023ee:	ff 75 f4             	pushl  -0xc(%ebp)
  8023f1:	6a 00                	push   $0x0
  8023f3:	e8 e8 e8 ff ff       	call   800ce0 <sys_page_alloc>
  8023f8:	83 c4 10             	add    $0x10,%esp
		return r;
  8023fb:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8023fd:	85 c0                	test   %eax,%eax
  8023ff:	78 23                	js     802424 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802401:	8b 15 44 30 80 00    	mov    0x803044,%edx
  802407:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80240a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80240c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80240f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802416:	83 ec 0c             	sub    $0xc,%esp
  802419:	50                   	push   %eax
  80241a:	e8 bc ed ff ff       	call   8011db <fd2num>
  80241f:	89 c2                	mov    %eax,%edx
  802421:	83 c4 10             	add    $0x10,%esp
}
  802424:	89 d0                	mov    %edx,%eax
  802426:	c9                   	leave  
  802427:	c3                   	ret    

00802428 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802428:	55                   	push   %ebp
  802429:	89 e5                	mov    %esp,%ebp
  80242b:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80242e:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802435:	75 31                	jne    802468 <set_pgfault_handler+0x40>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc(thisenv->env_id, (void*)(UXSTACKTOP - PGSIZE), PTE_P | 
  802437:	a1 04 40 80 00       	mov    0x804004,%eax
  80243c:	8b 40 48             	mov    0x48(%eax),%eax
  80243f:	83 ec 04             	sub    $0x4,%esp
  802442:	6a 07                	push   $0x7
  802444:	68 00 f0 bf ee       	push   $0xeebff000
  802449:	50                   	push   %eax
  80244a:	e8 91 e8 ff ff       	call   800ce0 <sys_page_alloc>
				PTE_U | PTE_W);
		sys_env_set_pgfault_upcall(thisenv->env_id, (void*)_pgfault_upcall);
  80244f:	a1 04 40 80 00       	mov    0x804004,%eax
  802454:	8b 40 48             	mov    0x48(%eax),%eax
  802457:	83 c4 08             	add    $0x8,%esp
  80245a:	68 72 24 80 00       	push   $0x802472
  80245f:	50                   	push   %eax
  802460:	e8 c6 e9 ff ff       	call   800e2b <sys_env_set_pgfault_upcall>
  802465:	83 c4 10             	add    $0x10,%esp

		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802468:	8b 45 08             	mov    0x8(%ebp),%eax
  80246b:	a3 00 60 80 00       	mov    %eax,0x806000
}
  802470:	c9                   	leave  
  802471:	c3                   	ret    

00802472 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802472:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802473:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802478:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80247a:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	addl $8, %esp      // pop utf_fault_va and utf_err
  80247d:	83 c4 08             	add    $0x8,%esp
	movl 32(%esp), %eax  // eax <- [esp + 32]
  802480:	8b 44 24 20          	mov    0x20(%esp),%eax
	movl 40(%esp), %ebx  // ebx <- [esp + 40]
  802484:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	leal -4(%ebx), %ebx  // ebx <- ebx - 4
  802488:	8d 5b fc             	lea    -0x4(%ebx),%ebx
	movl %eax, (%ebx)
  80248b:	89 03                	mov    %eax,(%ebx)
	movl %ebx, 40(%esp)  // push trap eip and decrement trap esp manually
  80248d:	89 5c 24 28          	mov    %ebx,0x28(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  802491:	61                   	popa   
	addl $4, %esp        // skip eip
  802492:	83 c4 04             	add    $0x4,%esp

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	popf
  802495:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	pop %esp
  802496:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802497:	c3                   	ret    

00802498 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802498:	55                   	push   %ebp
  802499:	89 e5                	mov    %esp,%ebp
  80249b:	56                   	push   %esi
  80249c:	53                   	push   %ebx
  80249d:	8b 75 08             	mov    0x8(%ebp),%esi
  8024a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024a3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int ret;
	if (pg) ret = sys_ipc_recv(pg);
  8024a6:	85 c0                	test   %eax,%eax
  8024a8:	74 0e                	je     8024b8 <ipc_recv+0x20>
  8024aa:	83 ec 0c             	sub    $0xc,%esp
  8024ad:	50                   	push   %eax
  8024ae:	e8 dd e9 ff ff       	call   800e90 <sys_ipc_recv>
  8024b3:	83 c4 10             	add    $0x10,%esp
  8024b6:	eb 10                	jmp    8024c8 <ipc_recv+0x30>
	else ret = sys_ipc_recv((void*)UTOP);
  8024b8:	83 ec 0c             	sub    $0xc,%esp
  8024bb:	68 00 00 c0 ee       	push   $0xeec00000
  8024c0:	e8 cb e9 ff ff       	call   800e90 <sys_ipc_recv>
  8024c5:	83 c4 10             	add    $0x10,%esp
	if (ret) {
  8024c8:	85 c0                	test   %eax,%eax
  8024ca:	74 16                	je     8024e2 <ipc_recv+0x4a>
		if (from_env_store) *from_env_store = 0;
  8024cc:	85 f6                	test   %esi,%esi
  8024ce:	74 06                	je     8024d6 <ipc_recv+0x3e>
  8024d0:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  8024d6:	85 db                	test   %ebx,%ebx
  8024d8:	74 2c                	je     802506 <ipc_recv+0x6e>
  8024da:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8024e0:	eb 24                	jmp    802506 <ipc_recv+0x6e>
		return ret;
	}
	if (from_env_store) *from_env_store = thisenv->env_ipc_from;
  8024e2:	85 f6                	test   %esi,%esi
  8024e4:	74 0a                	je     8024f0 <ipc_recv+0x58>
  8024e6:	a1 04 40 80 00       	mov    0x804004,%eax
  8024eb:	8b 40 74             	mov    0x74(%eax),%eax
  8024ee:	89 06                	mov    %eax,(%esi)
	if (perm_store) *perm_store = thisenv->env_ipc_perm;
  8024f0:	85 db                	test   %ebx,%ebx
  8024f2:	74 0a                	je     8024fe <ipc_recv+0x66>
  8024f4:	a1 04 40 80 00       	mov    0x804004,%eax
  8024f9:	8b 40 78             	mov    0x78(%eax),%eax
  8024fc:	89 03                	mov    %eax,(%ebx)

	// panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8024fe:	a1 04 40 80 00       	mov    0x804004,%eax
  802503:	8b 40 70             	mov    0x70(%eax),%eax
}
  802506:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802509:	5b                   	pop    %ebx
  80250a:	5e                   	pop    %esi
  80250b:	5d                   	pop    %ebp
  80250c:	c3                   	ret    

0080250d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80250d:	55                   	push   %ebp
  80250e:	89 e5                	mov    %esp,%ebp
  802510:	57                   	push   %edi
  802511:	56                   	push   %esi
  802512:	53                   	push   %ebx
  802513:	83 ec 0c             	sub    $0xc,%esp
  802516:	8b 7d 08             	mov    0x8(%ebp),%edi
  802519:	8b 75 0c             	mov    0xc(%ebp),%esi
  80251c:	8b 45 10             	mov    0x10(%ebp),%eax
  80251f:	85 c0                	test   %eax,%eax
  802521:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  802526:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	while (true) {
		void* srcva = (pg)? pg: (void*)UTOP;
		int ret = sys_ipc_try_send(to_env, val, srcva, perm);
  802529:	ff 75 14             	pushl  0x14(%ebp)
  80252c:	53                   	push   %ebx
  80252d:	56                   	push   %esi
  80252e:	57                   	push   %edi
  80252f:	e8 39 e9 ff ff       	call   800e6d <sys_ipc_try_send>
		if (ret == 0) break;
  802534:	83 c4 10             	add    $0x10,%esp
  802537:	85 c0                	test   %eax,%eax
  802539:	74 1e                	je     802559 <ipc_send+0x4c>
		if (ret != -E_IPC_NOT_RECV) panic("ipc_send: %e", ret);
  80253b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80253e:	74 12                	je     802552 <ipc_send+0x45>
  802540:	50                   	push   %eax
  802541:	68 29 2f 80 00       	push   $0x802f29
  802546:	6a 39                	push   $0x39
  802548:	68 36 2f 80 00       	push   $0x802f36
  80254d:	e8 86 dc ff ff       	call   8001d8 <_panic>
		sys_yield();
  802552:	e8 6a e7 ff ff       	call   800cc1 <sys_yield>
	}
  802557:	eb d0                	jmp    802529 <ipc_send+0x1c>
	// panic("ipc_send not implemented");
}
  802559:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80255c:	5b                   	pop    %ebx
  80255d:	5e                   	pop    %esi
  80255e:	5f                   	pop    %edi
  80255f:	5d                   	pop    %ebp
  802560:	c3                   	ret    

00802561 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802561:	55                   	push   %ebp
  802562:	89 e5                	mov    %esp,%ebp
  802564:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802567:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80256c:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80256f:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802575:	8b 52 50             	mov    0x50(%edx),%edx
  802578:	39 ca                	cmp    %ecx,%edx
  80257a:	75 0d                	jne    802589 <ipc_find_env+0x28>
			return envs[i].env_id;
  80257c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80257f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802584:	8b 40 48             	mov    0x48(%eax),%eax
  802587:	eb 0f                	jmp    802598 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802589:	83 c0 01             	add    $0x1,%eax
  80258c:	3d 00 04 00 00       	cmp    $0x400,%eax
  802591:	75 d9                	jne    80256c <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802593:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802598:	5d                   	pop    %ebp
  802599:	c3                   	ret    

0080259a <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80259a:	55                   	push   %ebp
  80259b:	89 e5                	mov    %esp,%ebp
  80259d:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8025a0:	89 d0                	mov    %edx,%eax
  8025a2:	c1 e8 16             	shr    $0x16,%eax
  8025a5:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8025ac:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8025b1:	f6 c1 01             	test   $0x1,%cl
  8025b4:	74 1d                	je     8025d3 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8025b6:	c1 ea 0c             	shr    $0xc,%edx
  8025b9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8025c0:	f6 c2 01             	test   $0x1,%dl
  8025c3:	74 0e                	je     8025d3 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8025c5:	c1 ea 0c             	shr    $0xc,%edx
  8025c8:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8025cf:	ef 
  8025d0:	0f b7 c0             	movzwl %ax,%eax
}
  8025d3:	5d                   	pop    %ebp
  8025d4:	c3                   	ret    
  8025d5:	66 90                	xchg   %ax,%ax
  8025d7:	66 90                	xchg   %ax,%ax
  8025d9:	66 90                	xchg   %ax,%ax
  8025db:	66 90                	xchg   %ax,%ax
  8025dd:	66 90                	xchg   %ax,%ax
  8025df:	90                   	nop

008025e0 <__udivdi3>:
  8025e0:	55                   	push   %ebp
  8025e1:	57                   	push   %edi
  8025e2:	56                   	push   %esi
  8025e3:	53                   	push   %ebx
  8025e4:	83 ec 1c             	sub    $0x1c,%esp
  8025e7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8025eb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8025ef:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8025f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8025f7:	85 f6                	test   %esi,%esi
  8025f9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8025fd:	89 ca                	mov    %ecx,%edx
  8025ff:	89 f8                	mov    %edi,%eax
  802601:	75 3d                	jne    802640 <__udivdi3+0x60>
  802603:	39 cf                	cmp    %ecx,%edi
  802605:	0f 87 c5 00 00 00    	ja     8026d0 <__udivdi3+0xf0>
  80260b:	85 ff                	test   %edi,%edi
  80260d:	89 fd                	mov    %edi,%ebp
  80260f:	75 0b                	jne    80261c <__udivdi3+0x3c>
  802611:	b8 01 00 00 00       	mov    $0x1,%eax
  802616:	31 d2                	xor    %edx,%edx
  802618:	f7 f7                	div    %edi
  80261a:	89 c5                	mov    %eax,%ebp
  80261c:	89 c8                	mov    %ecx,%eax
  80261e:	31 d2                	xor    %edx,%edx
  802620:	f7 f5                	div    %ebp
  802622:	89 c1                	mov    %eax,%ecx
  802624:	89 d8                	mov    %ebx,%eax
  802626:	89 cf                	mov    %ecx,%edi
  802628:	f7 f5                	div    %ebp
  80262a:	89 c3                	mov    %eax,%ebx
  80262c:	89 d8                	mov    %ebx,%eax
  80262e:	89 fa                	mov    %edi,%edx
  802630:	83 c4 1c             	add    $0x1c,%esp
  802633:	5b                   	pop    %ebx
  802634:	5e                   	pop    %esi
  802635:	5f                   	pop    %edi
  802636:	5d                   	pop    %ebp
  802637:	c3                   	ret    
  802638:	90                   	nop
  802639:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802640:	39 ce                	cmp    %ecx,%esi
  802642:	77 74                	ja     8026b8 <__udivdi3+0xd8>
  802644:	0f bd fe             	bsr    %esi,%edi
  802647:	83 f7 1f             	xor    $0x1f,%edi
  80264a:	0f 84 98 00 00 00    	je     8026e8 <__udivdi3+0x108>
  802650:	bb 20 00 00 00       	mov    $0x20,%ebx
  802655:	89 f9                	mov    %edi,%ecx
  802657:	89 c5                	mov    %eax,%ebp
  802659:	29 fb                	sub    %edi,%ebx
  80265b:	d3 e6                	shl    %cl,%esi
  80265d:	89 d9                	mov    %ebx,%ecx
  80265f:	d3 ed                	shr    %cl,%ebp
  802661:	89 f9                	mov    %edi,%ecx
  802663:	d3 e0                	shl    %cl,%eax
  802665:	09 ee                	or     %ebp,%esi
  802667:	89 d9                	mov    %ebx,%ecx
  802669:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80266d:	89 d5                	mov    %edx,%ebp
  80266f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802673:	d3 ed                	shr    %cl,%ebp
  802675:	89 f9                	mov    %edi,%ecx
  802677:	d3 e2                	shl    %cl,%edx
  802679:	89 d9                	mov    %ebx,%ecx
  80267b:	d3 e8                	shr    %cl,%eax
  80267d:	09 c2                	or     %eax,%edx
  80267f:	89 d0                	mov    %edx,%eax
  802681:	89 ea                	mov    %ebp,%edx
  802683:	f7 f6                	div    %esi
  802685:	89 d5                	mov    %edx,%ebp
  802687:	89 c3                	mov    %eax,%ebx
  802689:	f7 64 24 0c          	mull   0xc(%esp)
  80268d:	39 d5                	cmp    %edx,%ebp
  80268f:	72 10                	jb     8026a1 <__udivdi3+0xc1>
  802691:	8b 74 24 08          	mov    0x8(%esp),%esi
  802695:	89 f9                	mov    %edi,%ecx
  802697:	d3 e6                	shl    %cl,%esi
  802699:	39 c6                	cmp    %eax,%esi
  80269b:	73 07                	jae    8026a4 <__udivdi3+0xc4>
  80269d:	39 d5                	cmp    %edx,%ebp
  80269f:	75 03                	jne    8026a4 <__udivdi3+0xc4>
  8026a1:	83 eb 01             	sub    $0x1,%ebx
  8026a4:	31 ff                	xor    %edi,%edi
  8026a6:	89 d8                	mov    %ebx,%eax
  8026a8:	89 fa                	mov    %edi,%edx
  8026aa:	83 c4 1c             	add    $0x1c,%esp
  8026ad:	5b                   	pop    %ebx
  8026ae:	5e                   	pop    %esi
  8026af:	5f                   	pop    %edi
  8026b0:	5d                   	pop    %ebp
  8026b1:	c3                   	ret    
  8026b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8026b8:	31 ff                	xor    %edi,%edi
  8026ba:	31 db                	xor    %ebx,%ebx
  8026bc:	89 d8                	mov    %ebx,%eax
  8026be:	89 fa                	mov    %edi,%edx
  8026c0:	83 c4 1c             	add    $0x1c,%esp
  8026c3:	5b                   	pop    %ebx
  8026c4:	5e                   	pop    %esi
  8026c5:	5f                   	pop    %edi
  8026c6:	5d                   	pop    %ebp
  8026c7:	c3                   	ret    
  8026c8:	90                   	nop
  8026c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8026d0:	89 d8                	mov    %ebx,%eax
  8026d2:	f7 f7                	div    %edi
  8026d4:	31 ff                	xor    %edi,%edi
  8026d6:	89 c3                	mov    %eax,%ebx
  8026d8:	89 d8                	mov    %ebx,%eax
  8026da:	89 fa                	mov    %edi,%edx
  8026dc:	83 c4 1c             	add    $0x1c,%esp
  8026df:	5b                   	pop    %ebx
  8026e0:	5e                   	pop    %esi
  8026e1:	5f                   	pop    %edi
  8026e2:	5d                   	pop    %ebp
  8026e3:	c3                   	ret    
  8026e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8026e8:	39 ce                	cmp    %ecx,%esi
  8026ea:	72 0c                	jb     8026f8 <__udivdi3+0x118>
  8026ec:	31 db                	xor    %ebx,%ebx
  8026ee:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8026f2:	0f 87 34 ff ff ff    	ja     80262c <__udivdi3+0x4c>
  8026f8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8026fd:	e9 2a ff ff ff       	jmp    80262c <__udivdi3+0x4c>
  802702:	66 90                	xchg   %ax,%ax
  802704:	66 90                	xchg   %ax,%ax
  802706:	66 90                	xchg   %ax,%ax
  802708:	66 90                	xchg   %ax,%ax
  80270a:	66 90                	xchg   %ax,%ax
  80270c:	66 90                	xchg   %ax,%ax
  80270e:	66 90                	xchg   %ax,%ax

00802710 <__umoddi3>:
  802710:	55                   	push   %ebp
  802711:	57                   	push   %edi
  802712:	56                   	push   %esi
  802713:	53                   	push   %ebx
  802714:	83 ec 1c             	sub    $0x1c,%esp
  802717:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80271b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80271f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802723:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802727:	85 d2                	test   %edx,%edx
  802729:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80272d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802731:	89 f3                	mov    %esi,%ebx
  802733:	89 3c 24             	mov    %edi,(%esp)
  802736:	89 74 24 04          	mov    %esi,0x4(%esp)
  80273a:	75 1c                	jne    802758 <__umoddi3+0x48>
  80273c:	39 f7                	cmp    %esi,%edi
  80273e:	76 50                	jbe    802790 <__umoddi3+0x80>
  802740:	89 c8                	mov    %ecx,%eax
  802742:	89 f2                	mov    %esi,%edx
  802744:	f7 f7                	div    %edi
  802746:	89 d0                	mov    %edx,%eax
  802748:	31 d2                	xor    %edx,%edx
  80274a:	83 c4 1c             	add    $0x1c,%esp
  80274d:	5b                   	pop    %ebx
  80274e:	5e                   	pop    %esi
  80274f:	5f                   	pop    %edi
  802750:	5d                   	pop    %ebp
  802751:	c3                   	ret    
  802752:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802758:	39 f2                	cmp    %esi,%edx
  80275a:	89 d0                	mov    %edx,%eax
  80275c:	77 52                	ja     8027b0 <__umoddi3+0xa0>
  80275e:	0f bd ea             	bsr    %edx,%ebp
  802761:	83 f5 1f             	xor    $0x1f,%ebp
  802764:	75 5a                	jne    8027c0 <__umoddi3+0xb0>
  802766:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80276a:	0f 82 e0 00 00 00    	jb     802850 <__umoddi3+0x140>
  802770:	39 0c 24             	cmp    %ecx,(%esp)
  802773:	0f 86 d7 00 00 00    	jbe    802850 <__umoddi3+0x140>
  802779:	8b 44 24 08          	mov    0x8(%esp),%eax
  80277d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802781:	83 c4 1c             	add    $0x1c,%esp
  802784:	5b                   	pop    %ebx
  802785:	5e                   	pop    %esi
  802786:	5f                   	pop    %edi
  802787:	5d                   	pop    %ebp
  802788:	c3                   	ret    
  802789:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802790:	85 ff                	test   %edi,%edi
  802792:	89 fd                	mov    %edi,%ebp
  802794:	75 0b                	jne    8027a1 <__umoddi3+0x91>
  802796:	b8 01 00 00 00       	mov    $0x1,%eax
  80279b:	31 d2                	xor    %edx,%edx
  80279d:	f7 f7                	div    %edi
  80279f:	89 c5                	mov    %eax,%ebp
  8027a1:	89 f0                	mov    %esi,%eax
  8027a3:	31 d2                	xor    %edx,%edx
  8027a5:	f7 f5                	div    %ebp
  8027a7:	89 c8                	mov    %ecx,%eax
  8027a9:	f7 f5                	div    %ebp
  8027ab:	89 d0                	mov    %edx,%eax
  8027ad:	eb 99                	jmp    802748 <__umoddi3+0x38>
  8027af:	90                   	nop
  8027b0:	89 c8                	mov    %ecx,%eax
  8027b2:	89 f2                	mov    %esi,%edx
  8027b4:	83 c4 1c             	add    $0x1c,%esp
  8027b7:	5b                   	pop    %ebx
  8027b8:	5e                   	pop    %esi
  8027b9:	5f                   	pop    %edi
  8027ba:	5d                   	pop    %ebp
  8027bb:	c3                   	ret    
  8027bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8027c0:	8b 34 24             	mov    (%esp),%esi
  8027c3:	bf 20 00 00 00       	mov    $0x20,%edi
  8027c8:	89 e9                	mov    %ebp,%ecx
  8027ca:	29 ef                	sub    %ebp,%edi
  8027cc:	d3 e0                	shl    %cl,%eax
  8027ce:	89 f9                	mov    %edi,%ecx
  8027d0:	89 f2                	mov    %esi,%edx
  8027d2:	d3 ea                	shr    %cl,%edx
  8027d4:	89 e9                	mov    %ebp,%ecx
  8027d6:	09 c2                	or     %eax,%edx
  8027d8:	89 d8                	mov    %ebx,%eax
  8027da:	89 14 24             	mov    %edx,(%esp)
  8027dd:	89 f2                	mov    %esi,%edx
  8027df:	d3 e2                	shl    %cl,%edx
  8027e1:	89 f9                	mov    %edi,%ecx
  8027e3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8027e7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8027eb:	d3 e8                	shr    %cl,%eax
  8027ed:	89 e9                	mov    %ebp,%ecx
  8027ef:	89 c6                	mov    %eax,%esi
  8027f1:	d3 e3                	shl    %cl,%ebx
  8027f3:	89 f9                	mov    %edi,%ecx
  8027f5:	89 d0                	mov    %edx,%eax
  8027f7:	d3 e8                	shr    %cl,%eax
  8027f9:	89 e9                	mov    %ebp,%ecx
  8027fb:	09 d8                	or     %ebx,%eax
  8027fd:	89 d3                	mov    %edx,%ebx
  8027ff:	89 f2                	mov    %esi,%edx
  802801:	f7 34 24             	divl   (%esp)
  802804:	89 d6                	mov    %edx,%esi
  802806:	d3 e3                	shl    %cl,%ebx
  802808:	f7 64 24 04          	mull   0x4(%esp)
  80280c:	39 d6                	cmp    %edx,%esi
  80280e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802812:	89 d1                	mov    %edx,%ecx
  802814:	89 c3                	mov    %eax,%ebx
  802816:	72 08                	jb     802820 <__umoddi3+0x110>
  802818:	75 11                	jne    80282b <__umoddi3+0x11b>
  80281a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80281e:	73 0b                	jae    80282b <__umoddi3+0x11b>
  802820:	2b 44 24 04          	sub    0x4(%esp),%eax
  802824:	1b 14 24             	sbb    (%esp),%edx
  802827:	89 d1                	mov    %edx,%ecx
  802829:	89 c3                	mov    %eax,%ebx
  80282b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80282f:	29 da                	sub    %ebx,%edx
  802831:	19 ce                	sbb    %ecx,%esi
  802833:	89 f9                	mov    %edi,%ecx
  802835:	89 f0                	mov    %esi,%eax
  802837:	d3 e0                	shl    %cl,%eax
  802839:	89 e9                	mov    %ebp,%ecx
  80283b:	d3 ea                	shr    %cl,%edx
  80283d:	89 e9                	mov    %ebp,%ecx
  80283f:	d3 ee                	shr    %cl,%esi
  802841:	09 d0                	or     %edx,%eax
  802843:	89 f2                	mov    %esi,%edx
  802845:	83 c4 1c             	add    $0x1c,%esp
  802848:	5b                   	pop    %ebx
  802849:	5e                   	pop    %esi
  80284a:	5f                   	pop    %edi
  80284b:	5d                   	pop    %ebp
  80284c:	c3                   	ret    
  80284d:	8d 76 00             	lea    0x0(%esi),%esi
  802850:	29 f9                	sub    %edi,%ecx
  802852:	19 d6                	sbb    %edx,%esi
  802854:	89 74 24 04          	mov    %esi,0x4(%esp)
  802858:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80285c:	e9 18 ff ff ff       	jmp    802779 <__umoddi3+0x69>
