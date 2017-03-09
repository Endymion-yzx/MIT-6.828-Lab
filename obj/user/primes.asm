
obj/user/primes.debug:     file format elf32-i386


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
  80002c:	e8 c7 00 00 00       	call   8000f8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
	int i, id, p;
	envid_t envid;

	// fetch a prime from our left neighbor
top:
	p = ipc_recv(&envid, 0, 0);
  80003c:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80003f:	83 ec 04             	sub    $0x4,%esp
  800042:	6a 00                	push   $0x0
  800044:	6a 00                	push   $0x0
  800046:	56                   	push   %esi
  800047:	e8 0f 11 00 00       	call   80115b <ipc_recv>
  80004c:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80004e:	a1 04 40 80 00       	mov    0x804004,%eax
  800053:	8b 40 5c             	mov    0x5c(%eax),%eax
  800056:	83 c4 0c             	add    $0xc,%esp
  800059:	53                   	push   %ebx
  80005a:	50                   	push   %eax
  80005b:	68 60 22 80 00       	push   $0x802260
  800060:	e8 cc 01 00 00       	call   800231 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800065:	e8 94 0f 00 00       	call   800ffe <fork>
  80006a:	89 c7                	mov    %eax,%edi
  80006c:	83 c4 10             	add    $0x10,%esp
  80006f:	85 c0                	test   %eax,%eax
  800071:	79 12                	jns    800085 <primeproc+0x52>
		panic("fork: %e", id);
  800073:	50                   	push   %eax
  800074:	68 6c 22 80 00       	push   $0x80226c
  800079:	6a 1a                	push   $0x1a
  80007b:	68 75 22 80 00       	push   $0x802275
  800080:	e8 d3 00 00 00       	call   800158 <_panic>
	if (id == 0)
  800085:	85 c0                	test   %eax,%eax
  800087:	74 b6                	je     80003f <primeproc+0xc>
		goto top;

	// filter out multiples of our prime
	while (1) {
		i = ipc_recv(&envid, 0, 0);
  800089:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80008c:	83 ec 04             	sub    $0x4,%esp
  80008f:	6a 00                	push   $0x0
  800091:	6a 00                	push   $0x0
  800093:	56                   	push   %esi
  800094:	e8 c2 10 00 00       	call   80115b <ipc_recv>
  800099:	89 c1                	mov    %eax,%ecx
		if (i % p)
  80009b:	99                   	cltd   
  80009c:	f7 fb                	idiv   %ebx
  80009e:	83 c4 10             	add    $0x10,%esp
  8000a1:	85 d2                	test   %edx,%edx
  8000a3:	74 e7                	je     80008c <primeproc+0x59>
			ipc_send(id, i, 0, 0);
  8000a5:	6a 00                	push   $0x0
  8000a7:	6a 00                	push   $0x0
  8000a9:	51                   	push   %ecx
  8000aa:	57                   	push   %edi
  8000ab:	e8 20 11 00 00       	call   8011d0 <ipc_send>
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	eb d7                	jmp    80008c <primeproc+0x59>

008000b5 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
	int i, id;

	// fork the first prime process in the chain
	if ((id = fork()) < 0)
  8000ba:	e8 3f 0f 00 00       	call   800ffe <fork>
  8000bf:	89 c6                	mov    %eax,%esi
  8000c1:	85 c0                	test   %eax,%eax
  8000c3:	79 12                	jns    8000d7 <umain+0x22>
		panic("fork: %e", id);
  8000c5:	50                   	push   %eax
  8000c6:	68 6c 22 80 00       	push   $0x80226c
  8000cb:	6a 2d                	push   $0x2d
  8000cd:	68 75 22 80 00       	push   $0x802275
  8000d2:	e8 81 00 00 00       	call   800158 <_panic>
  8000d7:	bb 02 00 00 00       	mov    $0x2,%ebx
	if (id == 0)
  8000dc:	85 c0                	test   %eax,%eax
  8000de:	75 05                	jne    8000e5 <umain+0x30>
		primeproc();
  8000e0:	e8 4e ff ff ff       	call   800033 <primeproc>

	// feed all the integers through
	for (i = 2; ; i++)
		ipc_send(id, i, 0, 0);
  8000e5:	6a 00                	push   $0x0
  8000e7:	6a 00                	push   $0x0
  8000e9:	53                   	push   %ebx
  8000ea:	56                   	push   %esi
  8000eb:	e8 e0 10 00 00       	call   8011d0 <ipc_send>
		panic("fork: %e", id);
	if (id == 0)
		primeproc();

	// feed all the integers through
	for (i = 2; ; i++)
  8000f0:	83 c3 01             	add    $0x1,%ebx
  8000f3:	83 c4 10             	add    $0x10,%esp
  8000f6:	eb ed                	jmp    8000e5 <umain+0x30>

008000f8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	56                   	push   %esi
  8000fc:	53                   	push   %ebx
  8000fd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800100:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	envid_t envid = sys_getenvid();
  800103:	e8 1a 0b 00 00       	call   800c22 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  800108:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800110:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800115:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80011a:	85 db                	test   %ebx,%ebx
  80011c:	7e 07                	jle    800125 <libmain+0x2d>
		binaryname = argv[0];
  80011e:	8b 06                	mov    (%esi),%eax
  800120:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800125:	83 ec 08             	sub    $0x8,%esp
  800128:	56                   	push   %esi
  800129:	53                   	push   %ebx
  80012a:	e8 86 ff ff ff       	call   8000b5 <umain>

	// exit gracefully
	exit();
  80012f:	e8 0a 00 00 00       	call   80013e <exit>
}
  800134:	83 c4 10             	add    $0x10,%esp
  800137:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80013a:	5b                   	pop    %ebx
  80013b:	5e                   	pop    %esi
  80013c:	5d                   	pop    %ebp
  80013d:	c3                   	ret    

0080013e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80013e:	55                   	push   %ebp
  80013f:	89 e5                	mov    %esp,%ebp
  800141:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800144:	e8 df 12 00 00       	call   801428 <close_all>
	sys_env_destroy(0);
  800149:	83 ec 0c             	sub    $0xc,%esp
  80014c:	6a 00                	push   $0x0
  80014e:	e8 8e 0a 00 00       	call   800be1 <sys_env_destroy>
}
  800153:	83 c4 10             	add    $0x10,%esp
  800156:	c9                   	leave  
  800157:	c3                   	ret    

00800158 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800158:	55                   	push   %ebp
  800159:	89 e5                	mov    %esp,%ebp
  80015b:	56                   	push   %esi
  80015c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80015d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800160:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800166:	e8 b7 0a 00 00       	call   800c22 <sys_getenvid>
  80016b:	83 ec 0c             	sub    $0xc,%esp
  80016e:	ff 75 0c             	pushl  0xc(%ebp)
  800171:	ff 75 08             	pushl  0x8(%ebp)
  800174:	56                   	push   %esi
  800175:	50                   	push   %eax
  800176:	68 90 22 80 00       	push   $0x802290
  80017b:	e8 b1 00 00 00       	call   800231 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800180:	83 c4 18             	add    $0x18,%esp
  800183:	53                   	push   %ebx
  800184:	ff 75 10             	pushl  0x10(%ebp)
  800187:	e8 54 00 00 00       	call   8001e0 <vcprintf>
	cprintf("\n");
  80018c:	c7 04 24 dd 27 80 00 	movl   $0x8027dd,(%esp)
  800193:	e8 99 00 00 00       	call   800231 <cprintf>
  800198:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80019b:	cc                   	int3   
  80019c:	eb fd                	jmp    80019b <_panic+0x43>

0080019e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80019e:	55                   	push   %ebp
  80019f:	89 e5                	mov    %esp,%ebp
  8001a1:	53                   	push   %ebx
  8001a2:	83 ec 04             	sub    $0x4,%esp
  8001a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001a8:	8b 13                	mov    (%ebx),%edx
  8001aa:	8d 42 01             	lea    0x1(%edx),%eax
  8001ad:	89 03                	mov    %eax,(%ebx)
  8001af:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001b2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001b6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001bb:	75 1a                	jne    8001d7 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001bd:	83 ec 08             	sub    $0x8,%esp
  8001c0:	68 ff 00 00 00       	push   $0xff
  8001c5:	8d 43 08             	lea    0x8(%ebx),%eax
  8001c8:	50                   	push   %eax
  8001c9:	e8 d6 09 00 00       	call   800ba4 <sys_cputs>
		b->idx = 0;
  8001ce:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001d4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001d7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001de:	c9                   	leave  
  8001df:	c3                   	ret    

008001e0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001e0:	55                   	push   %ebp
  8001e1:	89 e5                	mov    %esp,%ebp
  8001e3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001e9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001f0:	00 00 00 
	b.cnt = 0;
  8001f3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001fa:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001fd:	ff 75 0c             	pushl  0xc(%ebp)
  800200:	ff 75 08             	pushl  0x8(%ebp)
  800203:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800209:	50                   	push   %eax
  80020a:	68 9e 01 80 00       	push   $0x80019e
  80020f:	e8 1a 01 00 00       	call   80032e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800214:	83 c4 08             	add    $0x8,%esp
  800217:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80021d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800223:	50                   	push   %eax
  800224:	e8 7b 09 00 00       	call   800ba4 <sys_cputs>

	return b.cnt;
}
  800229:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80022f:	c9                   	leave  
  800230:	c3                   	ret    

00800231 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800231:	55                   	push   %ebp
  800232:	89 e5                	mov    %esp,%ebp
  800234:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800237:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80023a:	50                   	push   %eax
  80023b:	ff 75 08             	pushl  0x8(%ebp)
  80023e:	e8 9d ff ff ff       	call   8001e0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800243:	c9                   	leave  
  800244:	c3                   	ret    

00800245 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800245:	55                   	push   %ebp
  800246:	89 e5                	mov    %esp,%ebp
  800248:	57                   	push   %edi
  800249:	56                   	push   %esi
  80024a:	53                   	push   %ebx
  80024b:	83 ec 1c             	sub    $0x1c,%esp
  80024e:	89 c7                	mov    %eax,%edi
  800250:	89 d6                	mov    %edx,%esi
  800252:	8b 45 08             	mov    0x8(%ebp),%eax
  800255:	8b 55 0c             	mov    0xc(%ebp),%edx
  800258:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80025b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80025e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800261:	bb 00 00 00 00       	mov    $0x0,%ebx
  800266:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800269:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80026c:	39 d3                	cmp    %edx,%ebx
  80026e:	72 05                	jb     800275 <printnum+0x30>
  800270:	39 45 10             	cmp    %eax,0x10(%ebp)
  800273:	77 45                	ja     8002ba <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800275:	83 ec 0c             	sub    $0xc,%esp
  800278:	ff 75 18             	pushl  0x18(%ebp)
  80027b:	8b 45 14             	mov    0x14(%ebp),%eax
  80027e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800281:	53                   	push   %ebx
  800282:	ff 75 10             	pushl  0x10(%ebp)
  800285:	83 ec 08             	sub    $0x8,%esp
  800288:	ff 75 e4             	pushl  -0x1c(%ebp)
  80028b:	ff 75 e0             	pushl  -0x20(%ebp)
  80028e:	ff 75 dc             	pushl  -0x24(%ebp)
  800291:	ff 75 d8             	pushl  -0x28(%ebp)
  800294:	e8 37 1d 00 00       	call   801fd0 <__udivdi3>
  800299:	83 c4 18             	add    $0x18,%esp
  80029c:	52                   	push   %edx
  80029d:	50                   	push   %eax
  80029e:	89 f2                	mov    %esi,%edx
  8002a0:	89 f8                	mov    %edi,%eax
  8002a2:	e8 9e ff ff ff       	call   800245 <printnum>
  8002a7:	83 c4 20             	add    $0x20,%esp
  8002aa:	eb 18                	jmp    8002c4 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002ac:	83 ec 08             	sub    $0x8,%esp
  8002af:	56                   	push   %esi
  8002b0:	ff 75 18             	pushl  0x18(%ebp)
  8002b3:	ff d7                	call   *%edi
  8002b5:	83 c4 10             	add    $0x10,%esp
  8002b8:	eb 03                	jmp    8002bd <printnum+0x78>
  8002ba:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002bd:	83 eb 01             	sub    $0x1,%ebx
  8002c0:	85 db                	test   %ebx,%ebx
  8002c2:	7f e8                	jg     8002ac <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002c4:	83 ec 08             	sub    $0x8,%esp
  8002c7:	56                   	push   %esi
  8002c8:	83 ec 04             	sub    $0x4,%esp
  8002cb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002ce:	ff 75 e0             	pushl  -0x20(%ebp)
  8002d1:	ff 75 dc             	pushl  -0x24(%ebp)
  8002d4:	ff 75 d8             	pushl  -0x28(%ebp)
  8002d7:	e8 24 1e 00 00       	call   802100 <__umoddi3>
  8002dc:	83 c4 14             	add    $0x14,%esp
  8002df:	0f be 80 b3 22 80 00 	movsbl 0x8022b3(%eax),%eax
  8002e6:	50                   	push   %eax
  8002e7:	ff d7                	call   *%edi
}
  8002e9:	83 c4 10             	add    $0x10,%esp
  8002ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ef:	5b                   	pop    %ebx
  8002f0:	5e                   	pop    %esi
  8002f1:	5f                   	pop    %edi
  8002f2:	5d                   	pop    %ebp
  8002f3:	c3                   	ret    

008002f4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002f4:	55                   	push   %ebp
  8002f5:	89 e5                	mov    %esp,%ebp
  8002f7:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002fa:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002fe:	8b 10                	mov    (%eax),%edx
  800300:	3b 50 04             	cmp    0x4(%eax),%edx
  800303:	73 0a                	jae    80030f <sprintputch+0x1b>
		*b->buf++ = ch;
  800305:	8d 4a 01             	lea    0x1(%edx),%ecx
  800308:	89 08                	mov    %ecx,(%eax)
  80030a:	8b 45 08             	mov    0x8(%ebp),%eax
  80030d:	88 02                	mov    %al,(%edx)
}
  80030f:	5d                   	pop    %ebp
  800310:	c3                   	ret    

00800311 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800311:	55                   	push   %ebp
  800312:	89 e5                	mov    %esp,%ebp
  800314:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800317:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80031a:	50                   	push   %eax
  80031b:	ff 75 10             	pushl  0x10(%ebp)
  80031e:	ff 75 0c             	pushl  0xc(%ebp)
  800321:	ff 75 08             	pushl  0x8(%ebp)
  800324:	e8 05 00 00 00       	call   80032e <vprintfmt>
	va_end(ap);
}
  800329:	83 c4 10             	add    $0x10,%esp
  80032c:	c9                   	leave  
  80032d:	c3                   	ret    

0080032e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80032e:	55                   	push   %ebp
  80032f:	89 e5                	mov    %esp,%ebp
  800331:	57                   	push   %edi
  800332:	56                   	push   %esi
  800333:	53                   	push   %ebx
  800334:	83 ec 2c             	sub    $0x2c,%esp
  800337:	8b 75 08             	mov    0x8(%ebp),%esi
  80033a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80033d:	8b 7d 10             	mov    0x10(%ebp),%edi
  800340:	eb 12                	jmp    800354 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800342:	85 c0                	test   %eax,%eax
  800344:	0f 84 6a 04 00 00    	je     8007b4 <vprintfmt+0x486>
				return;
			putch(ch, putdat);
  80034a:	83 ec 08             	sub    $0x8,%esp
  80034d:	53                   	push   %ebx
  80034e:	50                   	push   %eax
  80034f:	ff d6                	call   *%esi
  800351:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800354:	83 c7 01             	add    $0x1,%edi
  800357:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80035b:	83 f8 25             	cmp    $0x25,%eax
  80035e:	75 e2                	jne    800342 <vprintfmt+0x14>
  800360:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800364:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80036b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800372:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800379:	b9 00 00 00 00       	mov    $0x0,%ecx
  80037e:	eb 07                	jmp    800387 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800380:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800383:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800387:	8d 47 01             	lea    0x1(%edi),%eax
  80038a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80038d:	0f b6 07             	movzbl (%edi),%eax
  800390:	0f b6 d0             	movzbl %al,%edx
  800393:	83 e8 23             	sub    $0x23,%eax
  800396:	3c 55                	cmp    $0x55,%al
  800398:	0f 87 fb 03 00 00    	ja     800799 <vprintfmt+0x46b>
  80039e:	0f b6 c0             	movzbl %al,%eax
  8003a1:	ff 24 85 00 24 80 00 	jmp    *0x802400(,%eax,4)
  8003a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003ab:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003af:	eb d6                	jmp    800387 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8003b9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003bc:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003bf:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003c3:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003c6:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003c9:	83 f9 09             	cmp    $0x9,%ecx
  8003cc:	77 3f                	ja     80040d <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003ce:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003d1:	eb e9                	jmp    8003bc <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d6:	8b 00                	mov    (%eax),%eax
  8003d8:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003db:	8b 45 14             	mov    0x14(%ebp),%eax
  8003de:	8d 40 04             	lea    0x4(%eax),%eax
  8003e1:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003e7:	eb 2a                	jmp    800413 <vprintfmt+0xe5>
  8003e9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003ec:	85 c0                	test   %eax,%eax
  8003ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8003f3:	0f 49 d0             	cmovns %eax,%edx
  8003f6:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003fc:	eb 89                	jmp    800387 <vprintfmt+0x59>
  8003fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800401:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800408:	e9 7a ff ff ff       	jmp    800387 <vprintfmt+0x59>
  80040d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800410:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800413:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800417:	0f 89 6a ff ff ff    	jns    800387 <vprintfmt+0x59>
				width = precision, precision = -1;
  80041d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800420:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800423:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80042a:	e9 58 ff ff ff       	jmp    800387 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80042f:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800432:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800435:	e9 4d ff ff ff       	jmp    800387 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80043a:	8b 45 14             	mov    0x14(%ebp),%eax
  80043d:	8d 78 04             	lea    0x4(%eax),%edi
  800440:	83 ec 08             	sub    $0x8,%esp
  800443:	53                   	push   %ebx
  800444:	ff 30                	pushl  (%eax)
  800446:	ff d6                	call   *%esi
			break;
  800448:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80044b:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800451:	e9 fe fe ff ff       	jmp    800354 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800456:	8b 45 14             	mov    0x14(%ebp),%eax
  800459:	8d 78 04             	lea    0x4(%eax),%edi
  80045c:	8b 00                	mov    (%eax),%eax
  80045e:	99                   	cltd   
  80045f:	31 d0                	xor    %edx,%eax
  800461:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800463:	83 f8 0f             	cmp    $0xf,%eax
  800466:	7f 0b                	jg     800473 <vprintfmt+0x145>
  800468:	8b 14 85 60 25 80 00 	mov    0x802560(,%eax,4),%edx
  80046f:	85 d2                	test   %edx,%edx
  800471:	75 1b                	jne    80048e <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800473:	50                   	push   %eax
  800474:	68 cb 22 80 00       	push   $0x8022cb
  800479:	53                   	push   %ebx
  80047a:	56                   	push   %esi
  80047b:	e8 91 fe ff ff       	call   800311 <printfmt>
  800480:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800483:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800486:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800489:	e9 c6 fe ff ff       	jmp    800354 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80048e:	52                   	push   %edx
  80048f:	68 b6 27 80 00       	push   $0x8027b6
  800494:	53                   	push   %ebx
  800495:	56                   	push   %esi
  800496:	e8 76 fe ff ff       	call   800311 <printfmt>
  80049b:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80049e:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004a4:	e9 ab fe ff ff       	jmp    800354 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ac:	83 c0 04             	add    $0x4,%eax
  8004af:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8004b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b5:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004b7:	85 ff                	test   %edi,%edi
  8004b9:	b8 c4 22 80 00       	mov    $0x8022c4,%eax
  8004be:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004c1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004c5:	0f 8e 94 00 00 00    	jle    80055f <vprintfmt+0x231>
  8004cb:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004cf:	0f 84 98 00 00 00    	je     80056d <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d5:	83 ec 08             	sub    $0x8,%esp
  8004d8:	ff 75 d0             	pushl  -0x30(%ebp)
  8004db:	57                   	push   %edi
  8004dc:	e8 5b 03 00 00       	call   80083c <strnlen>
  8004e1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004e4:	29 c1                	sub    %eax,%ecx
  8004e6:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8004e9:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004ec:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004f0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004f3:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004f6:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f8:	eb 0f                	jmp    800509 <vprintfmt+0x1db>
					putch(padc, putdat);
  8004fa:	83 ec 08             	sub    $0x8,%esp
  8004fd:	53                   	push   %ebx
  8004fe:	ff 75 e0             	pushl  -0x20(%ebp)
  800501:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800503:	83 ef 01             	sub    $0x1,%edi
  800506:	83 c4 10             	add    $0x10,%esp
  800509:	85 ff                	test   %edi,%edi
  80050b:	7f ed                	jg     8004fa <vprintfmt+0x1cc>
  80050d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800510:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800513:	85 c9                	test   %ecx,%ecx
  800515:	b8 00 00 00 00       	mov    $0x0,%eax
  80051a:	0f 49 c1             	cmovns %ecx,%eax
  80051d:	29 c1                	sub    %eax,%ecx
  80051f:	89 75 08             	mov    %esi,0x8(%ebp)
  800522:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800525:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800528:	89 cb                	mov    %ecx,%ebx
  80052a:	eb 4d                	jmp    800579 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80052c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800530:	74 1b                	je     80054d <vprintfmt+0x21f>
  800532:	0f be c0             	movsbl %al,%eax
  800535:	83 e8 20             	sub    $0x20,%eax
  800538:	83 f8 5e             	cmp    $0x5e,%eax
  80053b:	76 10                	jbe    80054d <vprintfmt+0x21f>
					putch('?', putdat);
  80053d:	83 ec 08             	sub    $0x8,%esp
  800540:	ff 75 0c             	pushl  0xc(%ebp)
  800543:	6a 3f                	push   $0x3f
  800545:	ff 55 08             	call   *0x8(%ebp)
  800548:	83 c4 10             	add    $0x10,%esp
  80054b:	eb 0d                	jmp    80055a <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  80054d:	83 ec 08             	sub    $0x8,%esp
  800550:	ff 75 0c             	pushl  0xc(%ebp)
  800553:	52                   	push   %edx
  800554:	ff 55 08             	call   *0x8(%ebp)
  800557:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80055a:	83 eb 01             	sub    $0x1,%ebx
  80055d:	eb 1a                	jmp    800579 <vprintfmt+0x24b>
  80055f:	89 75 08             	mov    %esi,0x8(%ebp)
  800562:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800565:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800568:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80056b:	eb 0c                	jmp    800579 <vprintfmt+0x24b>
  80056d:	89 75 08             	mov    %esi,0x8(%ebp)
  800570:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800573:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800576:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800579:	83 c7 01             	add    $0x1,%edi
  80057c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800580:	0f be d0             	movsbl %al,%edx
  800583:	85 d2                	test   %edx,%edx
  800585:	74 23                	je     8005aa <vprintfmt+0x27c>
  800587:	85 f6                	test   %esi,%esi
  800589:	78 a1                	js     80052c <vprintfmt+0x1fe>
  80058b:	83 ee 01             	sub    $0x1,%esi
  80058e:	79 9c                	jns    80052c <vprintfmt+0x1fe>
  800590:	89 df                	mov    %ebx,%edi
  800592:	8b 75 08             	mov    0x8(%ebp),%esi
  800595:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800598:	eb 18                	jmp    8005b2 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80059a:	83 ec 08             	sub    $0x8,%esp
  80059d:	53                   	push   %ebx
  80059e:	6a 20                	push   $0x20
  8005a0:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005a2:	83 ef 01             	sub    $0x1,%edi
  8005a5:	83 c4 10             	add    $0x10,%esp
  8005a8:	eb 08                	jmp    8005b2 <vprintfmt+0x284>
  8005aa:	89 df                	mov    %ebx,%edi
  8005ac:	8b 75 08             	mov    0x8(%ebp),%esi
  8005af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005b2:	85 ff                	test   %edi,%edi
  8005b4:	7f e4                	jg     80059a <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005b6:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8005b9:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005bf:	e9 90 fd ff ff       	jmp    800354 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005c4:	83 f9 01             	cmp    $0x1,%ecx
  8005c7:	7e 19                	jle    8005e2 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8005c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cc:	8b 50 04             	mov    0x4(%eax),%edx
  8005cf:	8b 00                	mov    (%eax),%eax
  8005d1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005da:	8d 40 08             	lea    0x8(%eax),%eax
  8005dd:	89 45 14             	mov    %eax,0x14(%ebp)
  8005e0:	eb 38                	jmp    80061a <vprintfmt+0x2ec>
	else if (lflag)
  8005e2:	85 c9                	test   %ecx,%ecx
  8005e4:	74 1b                	je     800601 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8005e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e9:	8b 00                	mov    (%eax),%eax
  8005eb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ee:	89 c1                	mov    %eax,%ecx
  8005f0:	c1 f9 1f             	sar    $0x1f,%ecx
  8005f3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f9:	8d 40 04             	lea    0x4(%eax),%eax
  8005fc:	89 45 14             	mov    %eax,0x14(%ebp)
  8005ff:	eb 19                	jmp    80061a <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800601:	8b 45 14             	mov    0x14(%ebp),%eax
  800604:	8b 00                	mov    (%eax),%eax
  800606:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800609:	89 c1                	mov    %eax,%ecx
  80060b:	c1 f9 1f             	sar    $0x1f,%ecx
  80060e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800611:	8b 45 14             	mov    0x14(%ebp),%eax
  800614:	8d 40 04             	lea    0x4(%eax),%eax
  800617:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80061a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80061d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800620:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800625:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800629:	0f 89 36 01 00 00    	jns    800765 <vprintfmt+0x437>
				putch('-', putdat);
  80062f:	83 ec 08             	sub    $0x8,%esp
  800632:	53                   	push   %ebx
  800633:	6a 2d                	push   $0x2d
  800635:	ff d6                	call   *%esi
				num = -(long long) num;
  800637:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80063a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80063d:	f7 da                	neg    %edx
  80063f:	83 d1 00             	adc    $0x0,%ecx
  800642:	f7 d9                	neg    %ecx
  800644:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800647:	b8 0a 00 00 00       	mov    $0xa,%eax
  80064c:	e9 14 01 00 00       	jmp    800765 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800651:	83 f9 01             	cmp    $0x1,%ecx
  800654:	7e 18                	jle    80066e <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800656:	8b 45 14             	mov    0x14(%ebp),%eax
  800659:	8b 10                	mov    (%eax),%edx
  80065b:	8b 48 04             	mov    0x4(%eax),%ecx
  80065e:	8d 40 08             	lea    0x8(%eax),%eax
  800661:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800664:	b8 0a 00 00 00       	mov    $0xa,%eax
  800669:	e9 f7 00 00 00       	jmp    800765 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80066e:	85 c9                	test   %ecx,%ecx
  800670:	74 1a                	je     80068c <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  800672:	8b 45 14             	mov    0x14(%ebp),%eax
  800675:	8b 10                	mov    (%eax),%edx
  800677:	b9 00 00 00 00       	mov    $0x0,%ecx
  80067c:	8d 40 04             	lea    0x4(%eax),%eax
  80067f:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800682:	b8 0a 00 00 00       	mov    $0xa,%eax
  800687:	e9 d9 00 00 00       	jmp    800765 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80068c:	8b 45 14             	mov    0x14(%ebp),%eax
  80068f:	8b 10                	mov    (%eax),%edx
  800691:	b9 00 00 00 00       	mov    $0x0,%ecx
  800696:	8d 40 04             	lea    0x4(%eax),%eax
  800699:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80069c:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006a1:	e9 bf 00 00 00       	jmp    800765 <vprintfmt+0x437>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006a6:	83 f9 01             	cmp    $0x1,%ecx
  8006a9:	7e 13                	jle    8006be <vprintfmt+0x390>
		return va_arg(*ap, long long);
  8006ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ae:	8b 50 04             	mov    0x4(%eax),%edx
  8006b1:	8b 00                	mov    (%eax),%eax
  8006b3:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8006b6:	8d 49 08             	lea    0x8(%ecx),%ecx
  8006b9:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006bc:	eb 28                	jmp    8006e6 <vprintfmt+0x3b8>
	else if (lflag)
  8006be:	85 c9                	test   %ecx,%ecx
  8006c0:	74 13                	je     8006d5 <vprintfmt+0x3a7>
		return va_arg(*ap, long);
  8006c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c5:	8b 10                	mov    (%eax),%edx
  8006c7:	89 d0                	mov    %edx,%eax
  8006c9:	99                   	cltd   
  8006ca:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8006cd:	8d 49 04             	lea    0x4(%ecx),%ecx
  8006d0:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006d3:	eb 11                	jmp    8006e6 <vprintfmt+0x3b8>
	else
		return va_arg(*ap, int);
  8006d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d8:	8b 10                	mov    (%eax),%edx
  8006da:	89 d0                	mov    %edx,%eax
  8006dc:	99                   	cltd   
  8006dd:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8006e0:	8d 49 04             	lea    0x4(%ecx),%ecx
  8006e3:	89 4d 14             	mov    %ecx,0x14(%ebp)
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getint(&ap, lflag);
  8006e6:	89 d1                	mov    %edx,%ecx
  8006e8:	89 c2                	mov    %eax,%edx
			base = 8;
  8006ea:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8006ef:	eb 74                	jmp    800765 <vprintfmt+0x437>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8006f1:	83 ec 08             	sub    $0x8,%esp
  8006f4:	53                   	push   %ebx
  8006f5:	6a 30                	push   $0x30
  8006f7:	ff d6                	call   *%esi
			putch('x', putdat);
  8006f9:	83 c4 08             	add    $0x8,%esp
  8006fc:	53                   	push   %ebx
  8006fd:	6a 78                	push   $0x78
  8006ff:	ff d6                	call   *%esi
			num = (unsigned long long)
  800701:	8b 45 14             	mov    0x14(%ebp),%eax
  800704:	8b 10                	mov    (%eax),%edx
  800706:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80070b:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80070e:	8d 40 04             	lea    0x4(%eax),%eax
  800711:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800714:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800719:	eb 4a                	jmp    800765 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80071b:	83 f9 01             	cmp    $0x1,%ecx
  80071e:	7e 15                	jle    800735 <vprintfmt+0x407>
		return va_arg(*ap, unsigned long long);
  800720:	8b 45 14             	mov    0x14(%ebp),%eax
  800723:	8b 10                	mov    (%eax),%edx
  800725:	8b 48 04             	mov    0x4(%eax),%ecx
  800728:	8d 40 08             	lea    0x8(%eax),%eax
  80072b:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80072e:	b8 10 00 00 00       	mov    $0x10,%eax
  800733:	eb 30                	jmp    800765 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800735:	85 c9                	test   %ecx,%ecx
  800737:	74 17                	je     800750 <vprintfmt+0x422>
		return va_arg(*ap, unsigned long);
  800739:	8b 45 14             	mov    0x14(%ebp),%eax
  80073c:	8b 10                	mov    (%eax),%edx
  80073e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800743:	8d 40 04             	lea    0x4(%eax),%eax
  800746:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800749:	b8 10 00 00 00       	mov    $0x10,%eax
  80074e:	eb 15                	jmp    800765 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800750:	8b 45 14             	mov    0x14(%ebp),%eax
  800753:	8b 10                	mov    (%eax),%edx
  800755:	b9 00 00 00 00       	mov    $0x0,%ecx
  80075a:	8d 40 04             	lea    0x4(%eax),%eax
  80075d:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800760:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800765:	83 ec 0c             	sub    $0xc,%esp
  800768:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80076c:	57                   	push   %edi
  80076d:	ff 75 e0             	pushl  -0x20(%ebp)
  800770:	50                   	push   %eax
  800771:	51                   	push   %ecx
  800772:	52                   	push   %edx
  800773:	89 da                	mov    %ebx,%edx
  800775:	89 f0                	mov    %esi,%eax
  800777:	e8 c9 fa ff ff       	call   800245 <printnum>
			break;
  80077c:	83 c4 20             	add    $0x20,%esp
  80077f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800782:	e9 cd fb ff ff       	jmp    800354 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800787:	83 ec 08             	sub    $0x8,%esp
  80078a:	53                   	push   %ebx
  80078b:	52                   	push   %edx
  80078c:	ff d6                	call   *%esi
			break;
  80078e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800791:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800794:	e9 bb fb ff ff       	jmp    800354 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800799:	83 ec 08             	sub    $0x8,%esp
  80079c:	53                   	push   %ebx
  80079d:	6a 25                	push   $0x25
  80079f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007a1:	83 c4 10             	add    $0x10,%esp
  8007a4:	eb 03                	jmp    8007a9 <vprintfmt+0x47b>
  8007a6:	83 ef 01             	sub    $0x1,%edi
  8007a9:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007ad:	75 f7                	jne    8007a6 <vprintfmt+0x478>
  8007af:	e9 a0 fb ff ff       	jmp    800354 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007b7:	5b                   	pop    %ebx
  8007b8:	5e                   	pop    %esi
  8007b9:	5f                   	pop    %edi
  8007ba:	5d                   	pop    %ebp
  8007bb:	c3                   	ret    

008007bc <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007bc:	55                   	push   %ebp
  8007bd:	89 e5                	mov    %esp,%ebp
  8007bf:	83 ec 18             	sub    $0x18,%esp
  8007c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c5:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007c8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007cb:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007cf:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007d2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007d9:	85 c0                	test   %eax,%eax
  8007db:	74 26                	je     800803 <vsnprintf+0x47>
  8007dd:	85 d2                	test   %edx,%edx
  8007df:	7e 22                	jle    800803 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007e1:	ff 75 14             	pushl  0x14(%ebp)
  8007e4:	ff 75 10             	pushl  0x10(%ebp)
  8007e7:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007ea:	50                   	push   %eax
  8007eb:	68 f4 02 80 00       	push   $0x8002f4
  8007f0:	e8 39 fb ff ff       	call   80032e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007f8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007fe:	83 c4 10             	add    $0x10,%esp
  800801:	eb 05                	jmp    800808 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800803:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800808:	c9                   	leave  
  800809:	c3                   	ret    

0080080a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80080a:	55                   	push   %ebp
  80080b:	89 e5                	mov    %esp,%ebp
  80080d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800810:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800813:	50                   	push   %eax
  800814:	ff 75 10             	pushl  0x10(%ebp)
  800817:	ff 75 0c             	pushl  0xc(%ebp)
  80081a:	ff 75 08             	pushl  0x8(%ebp)
  80081d:	e8 9a ff ff ff       	call   8007bc <vsnprintf>
	va_end(ap);

	return rc;
}
  800822:	c9                   	leave  
  800823:	c3                   	ret    

00800824 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800824:	55                   	push   %ebp
  800825:	89 e5                	mov    %esp,%ebp
  800827:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80082a:	b8 00 00 00 00       	mov    $0x0,%eax
  80082f:	eb 03                	jmp    800834 <strlen+0x10>
		n++;
  800831:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800834:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800838:	75 f7                	jne    800831 <strlen+0xd>
		n++;
	return n;
}
  80083a:	5d                   	pop    %ebp
  80083b:	c3                   	ret    

0080083c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80083c:	55                   	push   %ebp
  80083d:	89 e5                	mov    %esp,%ebp
  80083f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800842:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800845:	ba 00 00 00 00       	mov    $0x0,%edx
  80084a:	eb 03                	jmp    80084f <strnlen+0x13>
		n++;
  80084c:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80084f:	39 c2                	cmp    %eax,%edx
  800851:	74 08                	je     80085b <strnlen+0x1f>
  800853:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800857:	75 f3                	jne    80084c <strnlen+0x10>
  800859:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80085b:	5d                   	pop    %ebp
  80085c:	c3                   	ret    

0080085d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80085d:	55                   	push   %ebp
  80085e:	89 e5                	mov    %esp,%ebp
  800860:	53                   	push   %ebx
  800861:	8b 45 08             	mov    0x8(%ebp),%eax
  800864:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800867:	89 c2                	mov    %eax,%edx
  800869:	83 c2 01             	add    $0x1,%edx
  80086c:	83 c1 01             	add    $0x1,%ecx
  80086f:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800873:	88 5a ff             	mov    %bl,-0x1(%edx)
  800876:	84 db                	test   %bl,%bl
  800878:	75 ef                	jne    800869 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80087a:	5b                   	pop    %ebx
  80087b:	5d                   	pop    %ebp
  80087c:	c3                   	ret    

0080087d <strcat>:

char *
strcat(char *dst, const char *src)
{
  80087d:	55                   	push   %ebp
  80087e:	89 e5                	mov    %esp,%ebp
  800880:	53                   	push   %ebx
  800881:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800884:	53                   	push   %ebx
  800885:	e8 9a ff ff ff       	call   800824 <strlen>
  80088a:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80088d:	ff 75 0c             	pushl  0xc(%ebp)
  800890:	01 d8                	add    %ebx,%eax
  800892:	50                   	push   %eax
  800893:	e8 c5 ff ff ff       	call   80085d <strcpy>
	return dst;
}
  800898:	89 d8                	mov    %ebx,%eax
  80089a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80089d:	c9                   	leave  
  80089e:	c3                   	ret    

0080089f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80089f:	55                   	push   %ebp
  8008a0:	89 e5                	mov    %esp,%ebp
  8008a2:	56                   	push   %esi
  8008a3:	53                   	push   %ebx
  8008a4:	8b 75 08             	mov    0x8(%ebp),%esi
  8008a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008aa:	89 f3                	mov    %esi,%ebx
  8008ac:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008af:	89 f2                	mov    %esi,%edx
  8008b1:	eb 0f                	jmp    8008c2 <strncpy+0x23>
		*dst++ = *src;
  8008b3:	83 c2 01             	add    $0x1,%edx
  8008b6:	0f b6 01             	movzbl (%ecx),%eax
  8008b9:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008bc:	80 39 01             	cmpb   $0x1,(%ecx)
  8008bf:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008c2:	39 da                	cmp    %ebx,%edx
  8008c4:	75 ed                	jne    8008b3 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008c6:	89 f0                	mov    %esi,%eax
  8008c8:	5b                   	pop    %ebx
  8008c9:	5e                   	pop    %esi
  8008ca:	5d                   	pop    %ebp
  8008cb:	c3                   	ret    

008008cc <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008cc:	55                   	push   %ebp
  8008cd:	89 e5                	mov    %esp,%ebp
  8008cf:	56                   	push   %esi
  8008d0:	53                   	push   %ebx
  8008d1:	8b 75 08             	mov    0x8(%ebp),%esi
  8008d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008d7:	8b 55 10             	mov    0x10(%ebp),%edx
  8008da:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008dc:	85 d2                	test   %edx,%edx
  8008de:	74 21                	je     800901 <strlcpy+0x35>
  8008e0:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008e4:	89 f2                	mov    %esi,%edx
  8008e6:	eb 09                	jmp    8008f1 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008e8:	83 c2 01             	add    $0x1,%edx
  8008eb:	83 c1 01             	add    $0x1,%ecx
  8008ee:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008f1:	39 c2                	cmp    %eax,%edx
  8008f3:	74 09                	je     8008fe <strlcpy+0x32>
  8008f5:	0f b6 19             	movzbl (%ecx),%ebx
  8008f8:	84 db                	test   %bl,%bl
  8008fa:	75 ec                	jne    8008e8 <strlcpy+0x1c>
  8008fc:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008fe:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800901:	29 f0                	sub    %esi,%eax
}
  800903:	5b                   	pop    %ebx
  800904:	5e                   	pop    %esi
  800905:	5d                   	pop    %ebp
  800906:	c3                   	ret    

00800907 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800907:	55                   	push   %ebp
  800908:	89 e5                	mov    %esp,%ebp
  80090a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80090d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800910:	eb 06                	jmp    800918 <strcmp+0x11>
		p++, q++;
  800912:	83 c1 01             	add    $0x1,%ecx
  800915:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800918:	0f b6 01             	movzbl (%ecx),%eax
  80091b:	84 c0                	test   %al,%al
  80091d:	74 04                	je     800923 <strcmp+0x1c>
  80091f:	3a 02                	cmp    (%edx),%al
  800921:	74 ef                	je     800912 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800923:	0f b6 c0             	movzbl %al,%eax
  800926:	0f b6 12             	movzbl (%edx),%edx
  800929:	29 d0                	sub    %edx,%eax
}
  80092b:	5d                   	pop    %ebp
  80092c:	c3                   	ret    

0080092d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80092d:	55                   	push   %ebp
  80092e:	89 e5                	mov    %esp,%ebp
  800930:	53                   	push   %ebx
  800931:	8b 45 08             	mov    0x8(%ebp),%eax
  800934:	8b 55 0c             	mov    0xc(%ebp),%edx
  800937:	89 c3                	mov    %eax,%ebx
  800939:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80093c:	eb 06                	jmp    800944 <strncmp+0x17>
		n--, p++, q++;
  80093e:	83 c0 01             	add    $0x1,%eax
  800941:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800944:	39 d8                	cmp    %ebx,%eax
  800946:	74 15                	je     80095d <strncmp+0x30>
  800948:	0f b6 08             	movzbl (%eax),%ecx
  80094b:	84 c9                	test   %cl,%cl
  80094d:	74 04                	je     800953 <strncmp+0x26>
  80094f:	3a 0a                	cmp    (%edx),%cl
  800951:	74 eb                	je     80093e <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800953:	0f b6 00             	movzbl (%eax),%eax
  800956:	0f b6 12             	movzbl (%edx),%edx
  800959:	29 d0                	sub    %edx,%eax
  80095b:	eb 05                	jmp    800962 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80095d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800962:	5b                   	pop    %ebx
  800963:	5d                   	pop    %ebp
  800964:	c3                   	ret    

00800965 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800965:	55                   	push   %ebp
  800966:	89 e5                	mov    %esp,%ebp
  800968:	8b 45 08             	mov    0x8(%ebp),%eax
  80096b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80096f:	eb 07                	jmp    800978 <strchr+0x13>
		if (*s == c)
  800971:	38 ca                	cmp    %cl,%dl
  800973:	74 0f                	je     800984 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800975:	83 c0 01             	add    $0x1,%eax
  800978:	0f b6 10             	movzbl (%eax),%edx
  80097b:	84 d2                	test   %dl,%dl
  80097d:	75 f2                	jne    800971 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80097f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800984:	5d                   	pop    %ebp
  800985:	c3                   	ret    

00800986 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800986:	55                   	push   %ebp
  800987:	89 e5                	mov    %esp,%ebp
  800989:	8b 45 08             	mov    0x8(%ebp),%eax
  80098c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800990:	eb 03                	jmp    800995 <strfind+0xf>
  800992:	83 c0 01             	add    $0x1,%eax
  800995:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800998:	38 ca                	cmp    %cl,%dl
  80099a:	74 04                	je     8009a0 <strfind+0x1a>
  80099c:	84 d2                	test   %dl,%dl
  80099e:	75 f2                	jne    800992 <strfind+0xc>
			break;
	return (char *) s;
}
  8009a0:	5d                   	pop    %ebp
  8009a1:	c3                   	ret    

008009a2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009a2:	55                   	push   %ebp
  8009a3:	89 e5                	mov    %esp,%ebp
  8009a5:	57                   	push   %edi
  8009a6:	56                   	push   %esi
  8009a7:	53                   	push   %ebx
  8009a8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009ab:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009ae:	85 c9                	test   %ecx,%ecx
  8009b0:	74 36                	je     8009e8 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009b2:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009b8:	75 28                	jne    8009e2 <memset+0x40>
  8009ba:	f6 c1 03             	test   $0x3,%cl
  8009bd:	75 23                	jne    8009e2 <memset+0x40>
		c &= 0xFF;
  8009bf:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009c3:	89 d3                	mov    %edx,%ebx
  8009c5:	c1 e3 08             	shl    $0x8,%ebx
  8009c8:	89 d6                	mov    %edx,%esi
  8009ca:	c1 e6 18             	shl    $0x18,%esi
  8009cd:	89 d0                	mov    %edx,%eax
  8009cf:	c1 e0 10             	shl    $0x10,%eax
  8009d2:	09 f0                	or     %esi,%eax
  8009d4:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8009d6:	89 d8                	mov    %ebx,%eax
  8009d8:	09 d0                	or     %edx,%eax
  8009da:	c1 e9 02             	shr    $0x2,%ecx
  8009dd:	fc                   	cld    
  8009de:	f3 ab                	rep stos %eax,%es:(%edi)
  8009e0:	eb 06                	jmp    8009e8 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009e5:	fc                   	cld    
  8009e6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009e8:	89 f8                	mov    %edi,%eax
  8009ea:	5b                   	pop    %ebx
  8009eb:	5e                   	pop    %esi
  8009ec:	5f                   	pop    %edi
  8009ed:	5d                   	pop    %ebp
  8009ee:	c3                   	ret    

008009ef <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009ef:	55                   	push   %ebp
  8009f0:	89 e5                	mov    %esp,%ebp
  8009f2:	57                   	push   %edi
  8009f3:	56                   	push   %esi
  8009f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009fa:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009fd:	39 c6                	cmp    %eax,%esi
  8009ff:	73 35                	jae    800a36 <memmove+0x47>
  800a01:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a04:	39 d0                	cmp    %edx,%eax
  800a06:	73 2e                	jae    800a36 <memmove+0x47>
		s += n;
		d += n;
  800a08:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a0b:	89 d6                	mov    %edx,%esi
  800a0d:	09 fe                	or     %edi,%esi
  800a0f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a15:	75 13                	jne    800a2a <memmove+0x3b>
  800a17:	f6 c1 03             	test   $0x3,%cl
  800a1a:	75 0e                	jne    800a2a <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a1c:	83 ef 04             	sub    $0x4,%edi
  800a1f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a22:	c1 e9 02             	shr    $0x2,%ecx
  800a25:	fd                   	std    
  800a26:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a28:	eb 09                	jmp    800a33 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a2a:	83 ef 01             	sub    $0x1,%edi
  800a2d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a30:	fd                   	std    
  800a31:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a33:	fc                   	cld    
  800a34:	eb 1d                	jmp    800a53 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a36:	89 f2                	mov    %esi,%edx
  800a38:	09 c2                	or     %eax,%edx
  800a3a:	f6 c2 03             	test   $0x3,%dl
  800a3d:	75 0f                	jne    800a4e <memmove+0x5f>
  800a3f:	f6 c1 03             	test   $0x3,%cl
  800a42:	75 0a                	jne    800a4e <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a44:	c1 e9 02             	shr    $0x2,%ecx
  800a47:	89 c7                	mov    %eax,%edi
  800a49:	fc                   	cld    
  800a4a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a4c:	eb 05                	jmp    800a53 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a4e:	89 c7                	mov    %eax,%edi
  800a50:	fc                   	cld    
  800a51:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a53:	5e                   	pop    %esi
  800a54:	5f                   	pop    %edi
  800a55:	5d                   	pop    %ebp
  800a56:	c3                   	ret    

00800a57 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a57:	55                   	push   %ebp
  800a58:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a5a:	ff 75 10             	pushl  0x10(%ebp)
  800a5d:	ff 75 0c             	pushl  0xc(%ebp)
  800a60:	ff 75 08             	pushl  0x8(%ebp)
  800a63:	e8 87 ff ff ff       	call   8009ef <memmove>
}
  800a68:	c9                   	leave  
  800a69:	c3                   	ret    

00800a6a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a6a:	55                   	push   %ebp
  800a6b:	89 e5                	mov    %esp,%ebp
  800a6d:	56                   	push   %esi
  800a6e:	53                   	push   %ebx
  800a6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a72:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a75:	89 c6                	mov    %eax,%esi
  800a77:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a7a:	eb 1a                	jmp    800a96 <memcmp+0x2c>
		if (*s1 != *s2)
  800a7c:	0f b6 08             	movzbl (%eax),%ecx
  800a7f:	0f b6 1a             	movzbl (%edx),%ebx
  800a82:	38 d9                	cmp    %bl,%cl
  800a84:	74 0a                	je     800a90 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a86:	0f b6 c1             	movzbl %cl,%eax
  800a89:	0f b6 db             	movzbl %bl,%ebx
  800a8c:	29 d8                	sub    %ebx,%eax
  800a8e:	eb 0f                	jmp    800a9f <memcmp+0x35>
		s1++, s2++;
  800a90:	83 c0 01             	add    $0x1,%eax
  800a93:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a96:	39 f0                	cmp    %esi,%eax
  800a98:	75 e2                	jne    800a7c <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a9a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a9f:	5b                   	pop    %ebx
  800aa0:	5e                   	pop    %esi
  800aa1:	5d                   	pop    %ebp
  800aa2:	c3                   	ret    

00800aa3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800aa3:	55                   	push   %ebp
  800aa4:	89 e5                	mov    %esp,%ebp
  800aa6:	53                   	push   %ebx
  800aa7:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800aaa:	89 c1                	mov    %eax,%ecx
  800aac:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800aaf:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ab3:	eb 0a                	jmp    800abf <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ab5:	0f b6 10             	movzbl (%eax),%edx
  800ab8:	39 da                	cmp    %ebx,%edx
  800aba:	74 07                	je     800ac3 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800abc:	83 c0 01             	add    $0x1,%eax
  800abf:	39 c8                	cmp    %ecx,%eax
  800ac1:	72 f2                	jb     800ab5 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ac3:	5b                   	pop    %ebx
  800ac4:	5d                   	pop    %ebp
  800ac5:	c3                   	ret    

00800ac6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ac6:	55                   	push   %ebp
  800ac7:	89 e5                	mov    %esp,%ebp
  800ac9:	57                   	push   %edi
  800aca:	56                   	push   %esi
  800acb:	53                   	push   %ebx
  800acc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800acf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ad2:	eb 03                	jmp    800ad7 <strtol+0x11>
		s++;
  800ad4:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ad7:	0f b6 01             	movzbl (%ecx),%eax
  800ada:	3c 20                	cmp    $0x20,%al
  800adc:	74 f6                	je     800ad4 <strtol+0xe>
  800ade:	3c 09                	cmp    $0x9,%al
  800ae0:	74 f2                	je     800ad4 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ae2:	3c 2b                	cmp    $0x2b,%al
  800ae4:	75 0a                	jne    800af0 <strtol+0x2a>
		s++;
  800ae6:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ae9:	bf 00 00 00 00       	mov    $0x0,%edi
  800aee:	eb 11                	jmp    800b01 <strtol+0x3b>
  800af0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800af5:	3c 2d                	cmp    $0x2d,%al
  800af7:	75 08                	jne    800b01 <strtol+0x3b>
		s++, neg = 1;
  800af9:	83 c1 01             	add    $0x1,%ecx
  800afc:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b01:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b07:	75 15                	jne    800b1e <strtol+0x58>
  800b09:	80 39 30             	cmpb   $0x30,(%ecx)
  800b0c:	75 10                	jne    800b1e <strtol+0x58>
  800b0e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b12:	75 7c                	jne    800b90 <strtol+0xca>
		s += 2, base = 16;
  800b14:	83 c1 02             	add    $0x2,%ecx
  800b17:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b1c:	eb 16                	jmp    800b34 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b1e:	85 db                	test   %ebx,%ebx
  800b20:	75 12                	jne    800b34 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b22:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b27:	80 39 30             	cmpb   $0x30,(%ecx)
  800b2a:	75 08                	jne    800b34 <strtol+0x6e>
		s++, base = 8;
  800b2c:	83 c1 01             	add    $0x1,%ecx
  800b2f:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b34:	b8 00 00 00 00       	mov    $0x0,%eax
  800b39:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b3c:	0f b6 11             	movzbl (%ecx),%edx
  800b3f:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b42:	89 f3                	mov    %esi,%ebx
  800b44:	80 fb 09             	cmp    $0x9,%bl
  800b47:	77 08                	ja     800b51 <strtol+0x8b>
			dig = *s - '0';
  800b49:	0f be d2             	movsbl %dl,%edx
  800b4c:	83 ea 30             	sub    $0x30,%edx
  800b4f:	eb 22                	jmp    800b73 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b51:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b54:	89 f3                	mov    %esi,%ebx
  800b56:	80 fb 19             	cmp    $0x19,%bl
  800b59:	77 08                	ja     800b63 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b5b:	0f be d2             	movsbl %dl,%edx
  800b5e:	83 ea 57             	sub    $0x57,%edx
  800b61:	eb 10                	jmp    800b73 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b63:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b66:	89 f3                	mov    %esi,%ebx
  800b68:	80 fb 19             	cmp    $0x19,%bl
  800b6b:	77 16                	ja     800b83 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b6d:	0f be d2             	movsbl %dl,%edx
  800b70:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b73:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b76:	7d 0b                	jge    800b83 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b78:	83 c1 01             	add    $0x1,%ecx
  800b7b:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b7f:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b81:	eb b9                	jmp    800b3c <strtol+0x76>

	if (endptr)
  800b83:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b87:	74 0d                	je     800b96 <strtol+0xd0>
		*endptr = (char *) s;
  800b89:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b8c:	89 0e                	mov    %ecx,(%esi)
  800b8e:	eb 06                	jmp    800b96 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b90:	85 db                	test   %ebx,%ebx
  800b92:	74 98                	je     800b2c <strtol+0x66>
  800b94:	eb 9e                	jmp    800b34 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b96:	89 c2                	mov    %eax,%edx
  800b98:	f7 da                	neg    %edx
  800b9a:	85 ff                	test   %edi,%edi
  800b9c:	0f 45 c2             	cmovne %edx,%eax
}
  800b9f:	5b                   	pop    %ebx
  800ba0:	5e                   	pop    %esi
  800ba1:	5f                   	pop    %edi
  800ba2:	5d                   	pop    %ebp
  800ba3:	c3                   	ret    

00800ba4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ba4:	55                   	push   %ebp
  800ba5:	89 e5                	mov    %esp,%ebp
  800ba7:	57                   	push   %edi
  800ba8:	56                   	push   %esi
  800ba9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800baa:	b8 00 00 00 00       	mov    $0x0,%eax
  800baf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb2:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb5:	89 c3                	mov    %eax,%ebx
  800bb7:	89 c7                	mov    %eax,%edi
  800bb9:	89 c6                	mov    %eax,%esi
  800bbb:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bbd:	5b                   	pop    %ebx
  800bbe:	5e                   	pop    %esi
  800bbf:	5f                   	pop    %edi
  800bc0:	5d                   	pop    %ebp
  800bc1:	c3                   	ret    

00800bc2 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bc2:	55                   	push   %ebp
  800bc3:	89 e5                	mov    %esp,%ebp
  800bc5:	57                   	push   %edi
  800bc6:	56                   	push   %esi
  800bc7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc8:	ba 00 00 00 00       	mov    $0x0,%edx
  800bcd:	b8 01 00 00 00       	mov    $0x1,%eax
  800bd2:	89 d1                	mov    %edx,%ecx
  800bd4:	89 d3                	mov    %edx,%ebx
  800bd6:	89 d7                	mov    %edx,%edi
  800bd8:	89 d6                	mov    %edx,%esi
  800bda:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bdc:	5b                   	pop    %ebx
  800bdd:	5e                   	pop    %esi
  800bde:	5f                   	pop    %edi
  800bdf:	5d                   	pop    %ebp
  800be0:	c3                   	ret    

00800be1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800be1:	55                   	push   %ebp
  800be2:	89 e5                	mov    %esp,%ebp
  800be4:	57                   	push   %edi
  800be5:	56                   	push   %esi
  800be6:	53                   	push   %ebx
  800be7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bea:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bef:	b8 03 00 00 00       	mov    $0x3,%eax
  800bf4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf7:	89 cb                	mov    %ecx,%ebx
  800bf9:	89 cf                	mov    %ecx,%edi
  800bfb:	89 ce                	mov    %ecx,%esi
  800bfd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bff:	85 c0                	test   %eax,%eax
  800c01:	7e 17                	jle    800c1a <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c03:	83 ec 0c             	sub    $0xc,%esp
  800c06:	50                   	push   %eax
  800c07:	6a 03                	push   $0x3
  800c09:	68 bf 25 80 00       	push   $0x8025bf
  800c0e:	6a 23                	push   $0x23
  800c10:	68 dc 25 80 00       	push   $0x8025dc
  800c15:	e8 3e f5 ff ff       	call   800158 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c1d:	5b                   	pop    %ebx
  800c1e:	5e                   	pop    %esi
  800c1f:	5f                   	pop    %edi
  800c20:	5d                   	pop    %ebp
  800c21:	c3                   	ret    

00800c22 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c22:	55                   	push   %ebp
  800c23:	89 e5                	mov    %esp,%ebp
  800c25:	57                   	push   %edi
  800c26:	56                   	push   %esi
  800c27:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c28:	ba 00 00 00 00       	mov    $0x0,%edx
  800c2d:	b8 02 00 00 00       	mov    $0x2,%eax
  800c32:	89 d1                	mov    %edx,%ecx
  800c34:	89 d3                	mov    %edx,%ebx
  800c36:	89 d7                	mov    %edx,%edi
  800c38:	89 d6                	mov    %edx,%esi
  800c3a:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c3c:	5b                   	pop    %ebx
  800c3d:	5e                   	pop    %esi
  800c3e:	5f                   	pop    %edi
  800c3f:	5d                   	pop    %ebp
  800c40:	c3                   	ret    

00800c41 <sys_yield>:

void
sys_yield(void)
{
  800c41:	55                   	push   %ebp
  800c42:	89 e5                	mov    %esp,%ebp
  800c44:	57                   	push   %edi
  800c45:	56                   	push   %esi
  800c46:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c47:	ba 00 00 00 00       	mov    $0x0,%edx
  800c4c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c51:	89 d1                	mov    %edx,%ecx
  800c53:	89 d3                	mov    %edx,%ebx
  800c55:	89 d7                	mov    %edx,%edi
  800c57:	89 d6                	mov    %edx,%esi
  800c59:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c5b:	5b                   	pop    %ebx
  800c5c:	5e                   	pop    %esi
  800c5d:	5f                   	pop    %edi
  800c5e:	5d                   	pop    %ebp
  800c5f:	c3                   	ret    

00800c60 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c60:	55                   	push   %ebp
  800c61:	89 e5                	mov    %esp,%ebp
  800c63:	57                   	push   %edi
  800c64:	56                   	push   %esi
  800c65:	53                   	push   %ebx
  800c66:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c69:	be 00 00 00 00       	mov    $0x0,%esi
  800c6e:	b8 04 00 00 00       	mov    $0x4,%eax
  800c73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c76:	8b 55 08             	mov    0x8(%ebp),%edx
  800c79:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c7c:	89 f7                	mov    %esi,%edi
  800c7e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c80:	85 c0                	test   %eax,%eax
  800c82:	7e 17                	jle    800c9b <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c84:	83 ec 0c             	sub    $0xc,%esp
  800c87:	50                   	push   %eax
  800c88:	6a 04                	push   $0x4
  800c8a:	68 bf 25 80 00       	push   $0x8025bf
  800c8f:	6a 23                	push   $0x23
  800c91:	68 dc 25 80 00       	push   $0x8025dc
  800c96:	e8 bd f4 ff ff       	call   800158 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c9b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9e:	5b                   	pop    %ebx
  800c9f:	5e                   	pop    %esi
  800ca0:	5f                   	pop    %edi
  800ca1:	5d                   	pop    %ebp
  800ca2:	c3                   	ret    

00800ca3 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ca3:	55                   	push   %ebp
  800ca4:	89 e5                	mov    %esp,%ebp
  800ca6:	57                   	push   %edi
  800ca7:	56                   	push   %esi
  800ca8:	53                   	push   %ebx
  800ca9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cac:	b8 05 00 00 00       	mov    $0x5,%eax
  800cb1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cba:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cbd:	8b 75 18             	mov    0x18(%ebp),%esi
  800cc0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc2:	85 c0                	test   %eax,%eax
  800cc4:	7e 17                	jle    800cdd <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc6:	83 ec 0c             	sub    $0xc,%esp
  800cc9:	50                   	push   %eax
  800cca:	6a 05                	push   $0x5
  800ccc:	68 bf 25 80 00       	push   $0x8025bf
  800cd1:	6a 23                	push   $0x23
  800cd3:	68 dc 25 80 00       	push   $0x8025dc
  800cd8:	e8 7b f4 ff ff       	call   800158 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cdd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce0:	5b                   	pop    %ebx
  800ce1:	5e                   	pop    %esi
  800ce2:	5f                   	pop    %edi
  800ce3:	5d                   	pop    %ebp
  800ce4:	c3                   	ret    

00800ce5 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ce5:	55                   	push   %ebp
  800ce6:	89 e5                	mov    %esp,%ebp
  800ce8:	57                   	push   %edi
  800ce9:	56                   	push   %esi
  800cea:	53                   	push   %ebx
  800ceb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cee:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf3:	b8 06 00 00 00       	mov    $0x6,%eax
  800cf8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfe:	89 df                	mov    %ebx,%edi
  800d00:	89 de                	mov    %ebx,%esi
  800d02:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d04:	85 c0                	test   %eax,%eax
  800d06:	7e 17                	jle    800d1f <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d08:	83 ec 0c             	sub    $0xc,%esp
  800d0b:	50                   	push   %eax
  800d0c:	6a 06                	push   $0x6
  800d0e:	68 bf 25 80 00       	push   $0x8025bf
  800d13:	6a 23                	push   $0x23
  800d15:	68 dc 25 80 00       	push   $0x8025dc
  800d1a:	e8 39 f4 ff ff       	call   800158 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d1f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d22:	5b                   	pop    %ebx
  800d23:	5e                   	pop    %esi
  800d24:	5f                   	pop    %edi
  800d25:	5d                   	pop    %ebp
  800d26:	c3                   	ret    

00800d27 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d27:	55                   	push   %ebp
  800d28:	89 e5                	mov    %esp,%ebp
  800d2a:	57                   	push   %edi
  800d2b:	56                   	push   %esi
  800d2c:	53                   	push   %ebx
  800d2d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d30:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d35:	b8 08 00 00 00       	mov    $0x8,%eax
  800d3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d40:	89 df                	mov    %ebx,%edi
  800d42:	89 de                	mov    %ebx,%esi
  800d44:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d46:	85 c0                	test   %eax,%eax
  800d48:	7e 17                	jle    800d61 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4a:	83 ec 0c             	sub    $0xc,%esp
  800d4d:	50                   	push   %eax
  800d4e:	6a 08                	push   $0x8
  800d50:	68 bf 25 80 00       	push   $0x8025bf
  800d55:	6a 23                	push   $0x23
  800d57:	68 dc 25 80 00       	push   $0x8025dc
  800d5c:	e8 f7 f3 ff ff       	call   800158 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d61:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d64:	5b                   	pop    %ebx
  800d65:	5e                   	pop    %esi
  800d66:	5f                   	pop    %edi
  800d67:	5d                   	pop    %ebp
  800d68:	c3                   	ret    

00800d69 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d69:	55                   	push   %ebp
  800d6a:	89 e5                	mov    %esp,%ebp
  800d6c:	57                   	push   %edi
  800d6d:	56                   	push   %esi
  800d6e:	53                   	push   %ebx
  800d6f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d72:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d77:	b8 09 00 00 00       	mov    $0x9,%eax
  800d7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d82:	89 df                	mov    %ebx,%edi
  800d84:	89 de                	mov    %ebx,%esi
  800d86:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d88:	85 c0                	test   %eax,%eax
  800d8a:	7e 17                	jle    800da3 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8c:	83 ec 0c             	sub    $0xc,%esp
  800d8f:	50                   	push   %eax
  800d90:	6a 09                	push   $0x9
  800d92:	68 bf 25 80 00       	push   $0x8025bf
  800d97:	6a 23                	push   $0x23
  800d99:	68 dc 25 80 00       	push   $0x8025dc
  800d9e:	e8 b5 f3 ff ff       	call   800158 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800da3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da6:	5b                   	pop    %ebx
  800da7:	5e                   	pop    %esi
  800da8:	5f                   	pop    %edi
  800da9:	5d                   	pop    %ebp
  800daa:	c3                   	ret    

00800dab <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dab:	55                   	push   %ebp
  800dac:	89 e5                	mov    %esp,%ebp
  800dae:	57                   	push   %edi
  800daf:	56                   	push   %esi
  800db0:	53                   	push   %ebx
  800db1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dbe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc1:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc4:	89 df                	mov    %ebx,%edi
  800dc6:	89 de                	mov    %ebx,%esi
  800dc8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dca:	85 c0                	test   %eax,%eax
  800dcc:	7e 17                	jle    800de5 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dce:	83 ec 0c             	sub    $0xc,%esp
  800dd1:	50                   	push   %eax
  800dd2:	6a 0a                	push   $0xa
  800dd4:	68 bf 25 80 00       	push   $0x8025bf
  800dd9:	6a 23                	push   $0x23
  800ddb:	68 dc 25 80 00       	push   $0x8025dc
  800de0:	e8 73 f3 ff ff       	call   800158 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800de5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de8:	5b                   	pop    %ebx
  800de9:	5e                   	pop    %esi
  800dea:	5f                   	pop    %edi
  800deb:	5d                   	pop    %ebp
  800dec:	c3                   	ret    

00800ded <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ded:	55                   	push   %ebp
  800dee:	89 e5                	mov    %esp,%ebp
  800df0:	57                   	push   %edi
  800df1:	56                   	push   %esi
  800df2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df3:	be 00 00 00 00       	mov    $0x0,%esi
  800df8:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dfd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e00:	8b 55 08             	mov    0x8(%ebp),%edx
  800e03:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e06:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e09:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e0b:	5b                   	pop    %ebx
  800e0c:	5e                   	pop    %esi
  800e0d:	5f                   	pop    %edi
  800e0e:	5d                   	pop    %ebp
  800e0f:	c3                   	ret    

00800e10 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e10:	55                   	push   %ebp
  800e11:	89 e5                	mov    %esp,%ebp
  800e13:	57                   	push   %edi
  800e14:	56                   	push   %esi
  800e15:	53                   	push   %ebx
  800e16:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e19:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e1e:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e23:	8b 55 08             	mov    0x8(%ebp),%edx
  800e26:	89 cb                	mov    %ecx,%ebx
  800e28:	89 cf                	mov    %ecx,%edi
  800e2a:	89 ce                	mov    %ecx,%esi
  800e2c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e2e:	85 c0                	test   %eax,%eax
  800e30:	7e 17                	jle    800e49 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e32:	83 ec 0c             	sub    $0xc,%esp
  800e35:	50                   	push   %eax
  800e36:	6a 0d                	push   $0xd
  800e38:	68 bf 25 80 00       	push   $0x8025bf
  800e3d:	6a 23                	push   $0x23
  800e3f:	68 dc 25 80 00       	push   $0x8025dc
  800e44:	e8 0f f3 ff ff       	call   800158 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e49:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e4c:	5b                   	pop    %ebx
  800e4d:	5e                   	pop    %esi
  800e4e:	5f                   	pop    %edi
  800e4f:	5d                   	pop    %ebp
  800e50:	c3                   	ret    

00800e51 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e51:	55                   	push   %ebp
  800e52:	89 e5                	mov    %esp,%ebp
  800e54:	53                   	push   %ebx
  800e55:	83 ec 04             	sub    $0x4,%esp
  800e58:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e5b:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & 
  800e5d:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e61:	0f 84 48 01 00 00    	je     800faf <pgfault+0x15e>
  800e67:	89 d8                	mov    %ebx,%eax
  800e69:	c1 e8 16             	shr    $0x16,%eax
  800e6c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e73:	a8 01                	test   $0x1,%al
  800e75:	0f 84 5f 01 00 00    	je     800fda <pgfault+0x189>
  800e7b:	89 d8                	mov    %ebx,%eax
  800e7d:	c1 e8 0c             	shr    $0xc,%eax
  800e80:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800e87:	f6 c2 01             	test   $0x1,%dl
  800e8a:	0f 84 4a 01 00 00    	je     800fda <pgfault+0x189>
				PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW))) {
  800e90:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & 
  800e97:	f6 c4 08             	test   $0x8,%ah
  800e9a:	75 79                	jne    800f15 <pgfault+0xc4>
  800e9c:	e9 39 01 00 00       	jmp    800fda <pgfault+0x189>
				PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW))) {
		cprintf("Fault address = %08x, envid = %08x\n", addr, thisenv->env_id);
		if (!(err & FEC_WR)) cprintf("Not write\n");
		if (!(uvpd[PDX(addr)] & PTE_P)) cprintf("PDE not present\n");
  800ea1:	89 d8                	mov    %ebx,%eax
  800ea3:	c1 e8 16             	shr    $0x16,%eax
  800ea6:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ead:	a8 01                	test   $0x1,%al
  800eaf:	75 10                	jne    800ec1 <pgfault+0x70>
  800eb1:	83 ec 0c             	sub    $0xc,%esp
  800eb4:	68 ea 25 80 00       	push   $0x8025ea
  800eb9:	e8 73 f3 ff ff       	call   800231 <cprintf>
  800ebe:	83 c4 10             	add    $0x10,%esp
		if (!(uvpt[PTX(addr)] & PTE_P)) cprintf("PTE not present\n");
  800ec1:	c1 eb 0c             	shr    $0xc,%ebx
  800ec4:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  800eca:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800ed1:	a8 01                	test   $0x1,%al
  800ed3:	75 10                	jne    800ee5 <pgfault+0x94>
  800ed5:	83 ec 0c             	sub    $0xc,%esp
  800ed8:	68 fb 25 80 00       	push   $0x8025fb
  800edd:	e8 4f f3 ff ff       	call   800231 <cprintf>
  800ee2:	83 c4 10             	add    $0x10,%esp
		if (!(uvpt[PTX(addr)] & PTE_COW)) cprintf("Not copy-on-write\n");
  800ee5:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800eec:	f6 c4 08             	test   $0x8,%ah
  800eef:	75 10                	jne    800f01 <pgfault+0xb0>
  800ef1:	83 ec 0c             	sub    $0xc,%esp
  800ef4:	68 0c 26 80 00       	push   $0x80260c
  800ef9:	e8 33 f3 ff ff       	call   800231 <cprintf>
  800efe:	83 c4 10             	add    $0x10,%esp
		panic("User page fault");
  800f01:	83 ec 04             	sub    $0x4,%esp
  800f04:	68 1f 26 80 00       	push   $0x80261f
  800f09:	6a 23                	push   $0x23
  800f0b:	68 2f 26 80 00       	push   $0x80262f
  800f10:	e8 43 f2 ff ff       	call   800158 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// 0 refers to curenv
	if ((r = sys_page_alloc(0, (void*)PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  800f15:	83 ec 04             	sub    $0x4,%esp
  800f18:	6a 07                	push   $0x7
  800f1a:	68 00 f0 7f 00       	push   $0x7ff000
  800f1f:	6a 00                	push   $0x0
  800f21:	e8 3a fd ff ff       	call   800c60 <sys_page_alloc>
  800f26:	83 c4 10             	add    $0x10,%esp
  800f29:	85 c0                	test   %eax,%eax
  800f2b:	79 12                	jns    800f3f <pgfault+0xee>
		panic("sys_page_alloc failed: %e", r);
  800f2d:	50                   	push   %eax
  800f2e:	68 3a 26 80 00       	push   $0x80263a
  800f33:	6a 2f                	push   $0x2f
  800f35:	68 2f 26 80 00       	push   $0x80262f
  800f3a:	e8 19 f2 ff ff       	call   800158 <_panic>
	memcpy((void*)PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  800f3f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800f45:	83 ec 04             	sub    $0x4,%esp
  800f48:	68 00 10 00 00       	push   $0x1000
  800f4d:	53                   	push   %ebx
  800f4e:	68 00 f0 7f 00       	push   $0x7ff000
  800f53:	e8 ff fa ff ff       	call   800a57 <memcpy>
	if ((r = sys_page_map(0, (void*)PFTEMP, 0, (void*)ROUNDDOWN(addr, PGSIZE), 
  800f58:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f5f:	53                   	push   %ebx
  800f60:	6a 00                	push   $0x0
  800f62:	68 00 f0 7f 00       	push   $0x7ff000
  800f67:	6a 00                	push   $0x0
  800f69:	e8 35 fd ff ff       	call   800ca3 <sys_page_map>
  800f6e:	83 c4 20             	add    $0x20,%esp
  800f71:	85 c0                	test   %eax,%eax
  800f73:	79 12                	jns    800f87 <pgfault+0x136>
					PTE_P | PTE_U | PTE_W)) < 0)
		panic("sys_page_map failed: %e", r);
  800f75:	50                   	push   %eax
  800f76:	68 54 26 80 00       	push   $0x802654
  800f7b:	6a 33                	push   $0x33
  800f7d:	68 2f 26 80 00       	push   $0x80262f
  800f82:	e8 d1 f1 ff ff       	call   800158 <_panic>
	if ((r = sys_page_unmap(0, (void*)PFTEMP)) < 0)
  800f87:	83 ec 08             	sub    $0x8,%esp
  800f8a:	68 00 f0 7f 00       	push   $0x7ff000
  800f8f:	6a 00                	push   $0x0
  800f91:	e8 4f fd ff ff       	call   800ce5 <sys_page_unmap>
  800f96:	83 c4 10             	add    $0x10,%esp
  800f99:	85 c0                	test   %eax,%eax
  800f9b:	79 5c                	jns    800ff9 <pgfault+0x1a8>
		panic("sys_page_unmap failed: %e", r);
  800f9d:	50                   	push   %eax
  800f9e:	68 6c 26 80 00       	push   $0x80266c
  800fa3:	6a 35                	push   $0x35
  800fa5:	68 2f 26 80 00       	push   $0x80262f
  800faa:	e8 a9 f1 ff ff       	call   800158 <_panic>
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & 
				PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW))) {
		cprintf("Fault address = %08x, envid = %08x\n", addr, thisenv->env_id);
  800faf:	a1 04 40 80 00       	mov    0x804004,%eax
  800fb4:	8b 40 48             	mov    0x48(%eax),%eax
  800fb7:	83 ec 04             	sub    $0x4,%esp
  800fba:	50                   	push   %eax
  800fbb:	53                   	push   %ebx
  800fbc:	68 a8 26 80 00       	push   $0x8026a8
  800fc1:	e8 6b f2 ff ff       	call   800231 <cprintf>
		if (!(err & FEC_WR)) cprintf("Not write\n");
  800fc6:	c7 04 24 86 26 80 00 	movl   $0x802686,(%esp)
  800fcd:	e8 5f f2 ff ff       	call   800231 <cprintf>
  800fd2:	83 c4 10             	add    $0x10,%esp
  800fd5:	e9 c7 fe ff ff       	jmp    800ea1 <pgfault+0x50>
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & 
				PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW))) {
		cprintf("Fault address = %08x, envid = %08x\n", addr, thisenv->env_id);
  800fda:	a1 04 40 80 00       	mov    0x804004,%eax
  800fdf:	8b 40 48             	mov    0x48(%eax),%eax
  800fe2:	83 ec 04             	sub    $0x4,%esp
  800fe5:	50                   	push   %eax
  800fe6:	53                   	push   %ebx
  800fe7:	68 a8 26 80 00       	push   $0x8026a8
  800fec:	e8 40 f2 ff ff       	call   800231 <cprintf>
  800ff1:	83 c4 10             	add    $0x10,%esp
  800ff4:	e9 a8 fe ff ff       	jmp    800ea1 <pgfault+0x50>
		panic("sys_page_map failed: %e", r);
	if ((r = sys_page_unmap(0, (void*)PFTEMP)) < 0)
		panic("sys_page_unmap failed: %e", r);

	// panic("pgfault not implemented");
}
  800ff9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ffc:	c9                   	leave  
  800ffd:	c3                   	ret    

00800ffe <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ffe:	55                   	push   %ebp
  800fff:	89 e5                	mov    %esp,%ebp
  801001:	57                   	push   %edi
  801002:	56                   	push   %esi
  801003:	53                   	push   %ebx
  801004:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	int ret;
	set_pgfault_handler(pgfault);
  801007:	68 51 0e 80 00       	push   $0x800e51
  80100c:	e8 0a 0f 00 00       	call   801f1b <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801011:	b8 07 00 00 00       	mov    $0x7,%eax
  801016:	cd 30                	int    $0x30
  801018:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80101b:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	envid_t envid = sys_exofork();

	if (envid < 0) return envid;
  80101e:	83 c4 10             	add    $0x10,%esp
  801021:	85 c0                	test   %eax,%eax
  801023:	0f 88 0d 01 00 00    	js     801136 <fork+0x138>
  801029:	bb 00 00 00 00       	mov    $0x0,%ebx
  80102e:	be 00 00 00 00       	mov    $0x0,%esi
	else if (envid == 0) {
  801033:	85 c0                	test   %eax,%eax
  801035:	75 2f                	jne    801066 <fork+0x68>
		// Child returns
		thisenv = &envs[ENVX(sys_getenvid())];
  801037:	e8 e6 fb ff ff       	call   800c22 <sys_getenvid>
  80103c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801041:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801044:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801049:	a3 04 40 80 00       	mov    %eax,0x804004
		// set_pgfault_handler(pgfault);
		return 0;
  80104e:	b8 00 00 00 00       	mov    $0x0,%eax
  801053:	e9 e1 00 00 00       	jmp    801139 <fork+0x13b>
  801058:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
	}
	else {
		uint32_t pn;
		for (pn = 0; pn * PGSIZE < UTOP; pn++){
			// cprintf("virtual page %08x\n", pn * PGSIZE);
			if (pn * PGSIZE == UXSTACKTOP - PGSIZE) 
  80105e:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801064:	74 77                	je     8010dd <fork+0xdf>
{
	int r;

	// LAB 4: Your code here.
	int perm = PTE_P | PTE_U;
	pde_t pde = uvpd[pn / NPTENTRIES];
  801066:	89 f0                	mov    %esi,%eax
  801068:	c1 e8 0a             	shr    $0xa,%eax
  80106b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
	if (!(pde & PTE_P)) return 0;
  801072:	a8 01                	test   $0x1,%al
  801074:	74 0b                	je     801081 <fork+0x83>
	pte_t pte = uvpt[pn];
  801076:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	if (!(pte & PTE_P)) return 0;
  80107d:	a8 01                	test   $0x1,%al
  80107f:	75 08                	jne    801089 <fork+0x8b>
  801081:	8d 5e 01             	lea    0x1(%esi),%ebx
  801084:	c1 e3 0c             	shl    $0xc,%ebx
  801087:	eb 56                	jmp    8010df <fork+0xe1>
	// cprintf("virtual page %08x\n", pn * PGSIZE);

	if ((pte & PTE_W) || (pte & PTE_COW)) perm |= PTE_COW;
  801089:	25 02 08 00 00       	and    $0x802,%eax
  80108e:	83 f8 01             	cmp    $0x1,%eax
  801091:	19 ff                	sbb    %edi,%edi
  801093:	81 e7 00 f8 ff ff    	and    $0xfffff800,%edi
  801099:	81 c7 05 08 00 00    	add    $0x805,%edi

	if ((r = sys_page_map(thisenv->env_id, (void*)(pn * PGSIZE), envid, 
  80109f:	a1 04 40 80 00       	mov    0x804004,%eax
  8010a4:	8b 40 48             	mov    0x48(%eax),%eax
  8010a7:	83 ec 0c             	sub    $0xc,%esp
  8010aa:	57                   	push   %edi
  8010ab:	53                   	push   %ebx
  8010ac:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010af:	53                   	push   %ebx
  8010b0:	50                   	push   %eax
  8010b1:	e8 ed fb ff ff       	call   800ca3 <sys_page_map>
  8010b6:	83 c4 20             	add    $0x20,%esp
  8010b9:	85 c0                	test   %eax,%eax
  8010bb:	78 7c                	js     801139 <fork+0x13b>
				(void*)(pn * PGSIZE), perm)) < 0) 
		return r;
	r = sys_page_map(envid, (void*)(pn * PGSIZE), thisenv->env_id, 
  8010bd:	a1 04 40 80 00       	mov    0x804004,%eax
  8010c2:	8b 40 48             	mov    0x48(%eax),%eax
  8010c5:	83 ec 0c             	sub    $0xc,%esp
  8010c8:	57                   	push   %edi
  8010c9:	53                   	push   %ebx
  8010ca:	50                   	push   %eax
  8010cb:	53                   	push   %ebx
  8010cc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010cf:	e8 cf fb ff ff       	call   800ca3 <sys_page_map>
		uint32_t pn;
		for (pn = 0; pn * PGSIZE < UTOP; pn++){
			// cprintf("virtual page %08x\n", pn * PGSIZE);
			if (pn * PGSIZE == UXSTACKTOP - PGSIZE) 
				continue;
			if ((ret = duppage(envid, pn)) < 0)
  8010d4:	83 c4 20             	add    $0x20,%esp
  8010d7:	85 c0                	test   %eax,%eax
  8010d9:	79 a6                	jns    801081 <fork+0x83>
  8010db:	eb 5c                	jmp    801139 <fork+0x13b>
  8010dd:	89 c3                	mov    %eax,%ebx
		// set_pgfault_handler(pgfault);
		return 0;
	}
	else {
		uint32_t pn;
		for (pn = 0; pn * PGSIZE < UTOP; pn++){
  8010df:	83 c6 01             	add    $0x1,%esi
  8010e2:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
  8010e8:	0f 86 6a ff ff ff    	jbe    801058 <fork+0x5a>
				return ret;
		}
		// cprintf("Fork: duppage finished\n");

		// Should be done by parent
		if ((ret = sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P |
  8010ee:	83 ec 04             	sub    $0x4,%esp
  8010f1:	6a 07                	push   $0x7
  8010f3:	68 00 f0 bf ee       	push   $0xeebff000
  8010f8:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8010fb:	57                   	push   %edi
  8010fc:	e8 5f fb ff ff       	call   800c60 <sys_page_alloc>
  801101:	83 c4 10             	add    $0x10,%esp
  801104:	85 c0                	test   %eax,%eax
  801106:	78 31                	js     801139 <fork+0x13b>
						PTE_U | PTE_W)) < 0)
			return ret;
		if ((ret = sys_env_set_pgfault_upcall(envid, 
						thisenv->env_pgfault_upcall)) < 0)
  801108:	a1 04 40 80 00       	mov    0x804004,%eax

		// Should be done by parent
		if ((ret = sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P |
						PTE_U | PTE_W)) < 0)
			return ret;
		if ((ret = sys_env_set_pgfault_upcall(envid, 
  80110d:	8b 40 64             	mov    0x64(%eax),%eax
  801110:	83 ec 08             	sub    $0x8,%esp
  801113:	50                   	push   %eax
  801114:	57                   	push   %edi
  801115:	e8 91 fc ff ff       	call   800dab <sys_env_set_pgfault_upcall>
  80111a:	83 c4 10             	add    $0x10,%esp
  80111d:	85 c0                	test   %eax,%eax
  80111f:	78 18                	js     801139 <fork+0x13b>
						thisenv->env_pgfault_upcall)) < 0)
			return ret;

		if ((ret = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  801121:	83 ec 08             	sub    $0x8,%esp
  801124:	6a 02                	push   $0x2
  801126:	57                   	push   %edi
  801127:	e8 fb fb ff ff       	call   800d27 <sys_env_set_status>
  80112c:	83 c4 10             	add    $0x10,%esp
			return ret;
		return envid;
  80112f:	85 c0                	test   %eax,%eax
  801131:	0f 49 c7             	cmovns %edi,%eax
  801134:	eb 03                	jmp    801139 <fork+0x13b>
	int ret;
	set_pgfault_handler(pgfault);

	envid_t envid = sys_exofork();

	if (envid < 0) return envid;
  801136:	8b 45 e0             	mov    -0x20(%ebp),%eax
			return ret;
		return envid;
	}

	panic("fork not implemented");
}
  801139:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80113c:	5b                   	pop    %ebx
  80113d:	5e                   	pop    %esi
  80113e:	5f                   	pop    %edi
  80113f:	5d                   	pop    %ebp
  801140:	c3                   	ret    

00801141 <sfork>:

// Challenge!
int
sfork(void)
{
  801141:	55                   	push   %ebp
  801142:	89 e5                	mov    %esp,%ebp
  801144:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801147:	68 91 26 80 00       	push   $0x802691
  80114c:	68 9f 00 00 00       	push   $0x9f
  801151:	68 2f 26 80 00       	push   $0x80262f
  801156:	e8 fd ef ff ff       	call   800158 <_panic>

0080115b <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80115b:	55                   	push   %ebp
  80115c:	89 e5                	mov    %esp,%ebp
  80115e:	56                   	push   %esi
  80115f:	53                   	push   %ebx
  801160:	8b 75 08             	mov    0x8(%ebp),%esi
  801163:	8b 45 0c             	mov    0xc(%ebp),%eax
  801166:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int ret;
	if (pg) ret = sys_ipc_recv(pg);
  801169:	85 c0                	test   %eax,%eax
  80116b:	74 0e                	je     80117b <ipc_recv+0x20>
  80116d:	83 ec 0c             	sub    $0xc,%esp
  801170:	50                   	push   %eax
  801171:	e8 9a fc ff ff       	call   800e10 <sys_ipc_recv>
  801176:	83 c4 10             	add    $0x10,%esp
  801179:	eb 10                	jmp    80118b <ipc_recv+0x30>
	else ret = sys_ipc_recv((void*)UTOP);
  80117b:	83 ec 0c             	sub    $0xc,%esp
  80117e:	68 00 00 c0 ee       	push   $0xeec00000
  801183:	e8 88 fc ff ff       	call   800e10 <sys_ipc_recv>
  801188:	83 c4 10             	add    $0x10,%esp
	if (ret) {
  80118b:	85 c0                	test   %eax,%eax
  80118d:	74 16                	je     8011a5 <ipc_recv+0x4a>
		if (from_env_store) *from_env_store = 0;
  80118f:	85 f6                	test   %esi,%esi
  801191:	74 06                	je     801199 <ipc_recv+0x3e>
  801193:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  801199:	85 db                	test   %ebx,%ebx
  80119b:	74 2c                	je     8011c9 <ipc_recv+0x6e>
  80119d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8011a3:	eb 24                	jmp    8011c9 <ipc_recv+0x6e>
		return ret;
	}
	if (from_env_store) *from_env_store = thisenv->env_ipc_from;
  8011a5:	85 f6                	test   %esi,%esi
  8011a7:	74 0a                	je     8011b3 <ipc_recv+0x58>
  8011a9:	a1 04 40 80 00       	mov    0x804004,%eax
  8011ae:	8b 40 74             	mov    0x74(%eax),%eax
  8011b1:	89 06                	mov    %eax,(%esi)
	if (perm_store) *perm_store = thisenv->env_ipc_perm;
  8011b3:	85 db                	test   %ebx,%ebx
  8011b5:	74 0a                	je     8011c1 <ipc_recv+0x66>
  8011b7:	a1 04 40 80 00       	mov    0x804004,%eax
  8011bc:	8b 40 78             	mov    0x78(%eax),%eax
  8011bf:	89 03                	mov    %eax,(%ebx)

	// panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8011c1:	a1 04 40 80 00       	mov    0x804004,%eax
  8011c6:	8b 40 70             	mov    0x70(%eax),%eax
}
  8011c9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011cc:	5b                   	pop    %ebx
  8011cd:	5e                   	pop    %esi
  8011ce:	5d                   	pop    %ebp
  8011cf:	c3                   	ret    

008011d0 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8011d0:	55                   	push   %ebp
  8011d1:	89 e5                	mov    %esp,%ebp
  8011d3:	57                   	push   %edi
  8011d4:	56                   	push   %esi
  8011d5:	53                   	push   %ebx
  8011d6:	83 ec 0c             	sub    $0xc,%esp
  8011d9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011dc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8011df:	8b 45 10             	mov    0x10(%ebp),%eax
  8011e2:	85 c0                	test   %eax,%eax
  8011e4:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  8011e9:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	while (true) {
		void* srcva = (pg)? pg: (void*)UTOP;
		int ret = sys_ipc_try_send(to_env, val, srcva, perm);
  8011ec:	ff 75 14             	pushl  0x14(%ebp)
  8011ef:	53                   	push   %ebx
  8011f0:	56                   	push   %esi
  8011f1:	57                   	push   %edi
  8011f2:	e8 f6 fb ff ff       	call   800ded <sys_ipc_try_send>
		if (ret == 0) break;
  8011f7:	83 c4 10             	add    $0x10,%esp
  8011fa:	85 c0                	test   %eax,%eax
  8011fc:	74 1e                	je     80121c <ipc_send+0x4c>
		if (ret != -E_IPC_NOT_RECV) panic("ipc_send: %e", ret);
  8011fe:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801201:	74 12                	je     801215 <ipc_send+0x45>
  801203:	50                   	push   %eax
  801204:	68 cc 26 80 00       	push   $0x8026cc
  801209:	6a 39                	push   $0x39
  80120b:	68 d9 26 80 00       	push   $0x8026d9
  801210:	e8 43 ef ff ff       	call   800158 <_panic>
		sys_yield();
  801215:	e8 27 fa ff ff       	call   800c41 <sys_yield>
	}
  80121a:	eb d0                	jmp    8011ec <ipc_send+0x1c>
	// panic("ipc_send not implemented");
}
  80121c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80121f:	5b                   	pop    %ebx
  801220:	5e                   	pop    %esi
  801221:	5f                   	pop    %edi
  801222:	5d                   	pop    %ebp
  801223:	c3                   	ret    

00801224 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801224:	55                   	push   %ebp
  801225:	89 e5                	mov    %esp,%ebp
  801227:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80122a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80122f:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801232:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801238:	8b 52 50             	mov    0x50(%edx),%edx
  80123b:	39 ca                	cmp    %ecx,%edx
  80123d:	75 0d                	jne    80124c <ipc_find_env+0x28>
			return envs[i].env_id;
  80123f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801242:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801247:	8b 40 48             	mov    0x48(%eax),%eax
  80124a:	eb 0f                	jmp    80125b <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80124c:	83 c0 01             	add    $0x1,%eax
  80124f:	3d 00 04 00 00       	cmp    $0x400,%eax
  801254:	75 d9                	jne    80122f <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801256:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80125b:	5d                   	pop    %ebp
  80125c:	c3                   	ret    

0080125d <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80125d:	55                   	push   %ebp
  80125e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801260:	8b 45 08             	mov    0x8(%ebp),%eax
  801263:	05 00 00 00 30       	add    $0x30000000,%eax
  801268:	c1 e8 0c             	shr    $0xc,%eax
}
  80126b:	5d                   	pop    %ebp
  80126c:	c3                   	ret    

0080126d <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80126d:	55                   	push   %ebp
  80126e:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801270:	8b 45 08             	mov    0x8(%ebp),%eax
  801273:	05 00 00 00 30       	add    $0x30000000,%eax
  801278:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80127d:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801282:	5d                   	pop    %ebp
  801283:	c3                   	ret    

00801284 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801284:	55                   	push   %ebp
  801285:	89 e5                	mov    %esp,%ebp
  801287:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80128a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80128f:	89 c2                	mov    %eax,%edx
  801291:	c1 ea 16             	shr    $0x16,%edx
  801294:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80129b:	f6 c2 01             	test   $0x1,%dl
  80129e:	74 11                	je     8012b1 <fd_alloc+0x2d>
  8012a0:	89 c2                	mov    %eax,%edx
  8012a2:	c1 ea 0c             	shr    $0xc,%edx
  8012a5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012ac:	f6 c2 01             	test   $0x1,%dl
  8012af:	75 09                	jne    8012ba <fd_alloc+0x36>
			*fd_store = fd;
  8012b1:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8012b8:	eb 17                	jmp    8012d1 <fd_alloc+0x4d>
  8012ba:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8012bf:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012c4:	75 c9                	jne    80128f <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012c6:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8012cc:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8012d1:	5d                   	pop    %ebp
  8012d2:	c3                   	ret    

008012d3 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012d3:	55                   	push   %ebp
  8012d4:	89 e5                	mov    %esp,%ebp
  8012d6:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012d9:	83 f8 1f             	cmp    $0x1f,%eax
  8012dc:	77 36                	ja     801314 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012de:	c1 e0 0c             	shl    $0xc,%eax
  8012e1:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012e6:	89 c2                	mov    %eax,%edx
  8012e8:	c1 ea 16             	shr    $0x16,%edx
  8012eb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012f2:	f6 c2 01             	test   $0x1,%dl
  8012f5:	74 24                	je     80131b <fd_lookup+0x48>
  8012f7:	89 c2                	mov    %eax,%edx
  8012f9:	c1 ea 0c             	shr    $0xc,%edx
  8012fc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801303:	f6 c2 01             	test   $0x1,%dl
  801306:	74 1a                	je     801322 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801308:	8b 55 0c             	mov    0xc(%ebp),%edx
  80130b:	89 02                	mov    %eax,(%edx)
	return 0;
  80130d:	b8 00 00 00 00       	mov    $0x0,%eax
  801312:	eb 13                	jmp    801327 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801314:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801319:	eb 0c                	jmp    801327 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80131b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801320:	eb 05                	jmp    801327 <fd_lookup+0x54>
  801322:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801327:	5d                   	pop    %ebp
  801328:	c3                   	ret    

00801329 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801329:	55                   	push   %ebp
  80132a:	89 e5                	mov    %esp,%ebp
  80132c:	83 ec 08             	sub    $0x8,%esp
  80132f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801332:	ba 64 27 80 00       	mov    $0x802764,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801337:	eb 13                	jmp    80134c <dev_lookup+0x23>
  801339:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80133c:	39 08                	cmp    %ecx,(%eax)
  80133e:	75 0c                	jne    80134c <dev_lookup+0x23>
			*dev = devtab[i];
  801340:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801343:	89 01                	mov    %eax,(%ecx)
			return 0;
  801345:	b8 00 00 00 00       	mov    $0x0,%eax
  80134a:	eb 2e                	jmp    80137a <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80134c:	8b 02                	mov    (%edx),%eax
  80134e:	85 c0                	test   %eax,%eax
  801350:	75 e7                	jne    801339 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801352:	a1 04 40 80 00       	mov    0x804004,%eax
  801357:	8b 40 48             	mov    0x48(%eax),%eax
  80135a:	83 ec 04             	sub    $0x4,%esp
  80135d:	51                   	push   %ecx
  80135e:	50                   	push   %eax
  80135f:	68 e4 26 80 00       	push   $0x8026e4
  801364:	e8 c8 ee ff ff       	call   800231 <cprintf>
	*dev = 0;
  801369:	8b 45 0c             	mov    0xc(%ebp),%eax
  80136c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801372:	83 c4 10             	add    $0x10,%esp
  801375:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80137a:	c9                   	leave  
  80137b:	c3                   	ret    

0080137c <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80137c:	55                   	push   %ebp
  80137d:	89 e5                	mov    %esp,%ebp
  80137f:	56                   	push   %esi
  801380:	53                   	push   %ebx
  801381:	83 ec 10             	sub    $0x10,%esp
  801384:	8b 75 08             	mov    0x8(%ebp),%esi
  801387:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80138a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80138d:	50                   	push   %eax
  80138e:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801394:	c1 e8 0c             	shr    $0xc,%eax
  801397:	50                   	push   %eax
  801398:	e8 36 ff ff ff       	call   8012d3 <fd_lookup>
  80139d:	83 c4 08             	add    $0x8,%esp
  8013a0:	85 c0                	test   %eax,%eax
  8013a2:	78 05                	js     8013a9 <fd_close+0x2d>
	    || fd != fd2)
  8013a4:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8013a7:	74 0c                	je     8013b5 <fd_close+0x39>
		return (must_exist ? r : 0);
  8013a9:	84 db                	test   %bl,%bl
  8013ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8013b0:	0f 44 c2             	cmove  %edx,%eax
  8013b3:	eb 41                	jmp    8013f6 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013b5:	83 ec 08             	sub    $0x8,%esp
  8013b8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013bb:	50                   	push   %eax
  8013bc:	ff 36                	pushl  (%esi)
  8013be:	e8 66 ff ff ff       	call   801329 <dev_lookup>
  8013c3:	89 c3                	mov    %eax,%ebx
  8013c5:	83 c4 10             	add    $0x10,%esp
  8013c8:	85 c0                	test   %eax,%eax
  8013ca:	78 1a                	js     8013e6 <fd_close+0x6a>
		if (dev->dev_close)
  8013cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013cf:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8013d2:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8013d7:	85 c0                	test   %eax,%eax
  8013d9:	74 0b                	je     8013e6 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8013db:	83 ec 0c             	sub    $0xc,%esp
  8013de:	56                   	push   %esi
  8013df:	ff d0                	call   *%eax
  8013e1:	89 c3                	mov    %eax,%ebx
  8013e3:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013e6:	83 ec 08             	sub    $0x8,%esp
  8013e9:	56                   	push   %esi
  8013ea:	6a 00                	push   $0x0
  8013ec:	e8 f4 f8 ff ff       	call   800ce5 <sys_page_unmap>
	return r;
  8013f1:	83 c4 10             	add    $0x10,%esp
  8013f4:	89 d8                	mov    %ebx,%eax
}
  8013f6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013f9:	5b                   	pop    %ebx
  8013fa:	5e                   	pop    %esi
  8013fb:	5d                   	pop    %ebp
  8013fc:	c3                   	ret    

008013fd <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8013fd:	55                   	push   %ebp
  8013fe:	89 e5                	mov    %esp,%ebp
  801400:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801403:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801406:	50                   	push   %eax
  801407:	ff 75 08             	pushl  0x8(%ebp)
  80140a:	e8 c4 fe ff ff       	call   8012d3 <fd_lookup>
  80140f:	83 c4 08             	add    $0x8,%esp
  801412:	85 c0                	test   %eax,%eax
  801414:	78 10                	js     801426 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801416:	83 ec 08             	sub    $0x8,%esp
  801419:	6a 01                	push   $0x1
  80141b:	ff 75 f4             	pushl  -0xc(%ebp)
  80141e:	e8 59 ff ff ff       	call   80137c <fd_close>
  801423:	83 c4 10             	add    $0x10,%esp
}
  801426:	c9                   	leave  
  801427:	c3                   	ret    

00801428 <close_all>:

void
close_all(void)
{
  801428:	55                   	push   %ebp
  801429:	89 e5                	mov    %esp,%ebp
  80142b:	53                   	push   %ebx
  80142c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80142f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801434:	83 ec 0c             	sub    $0xc,%esp
  801437:	53                   	push   %ebx
  801438:	e8 c0 ff ff ff       	call   8013fd <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80143d:	83 c3 01             	add    $0x1,%ebx
  801440:	83 c4 10             	add    $0x10,%esp
  801443:	83 fb 20             	cmp    $0x20,%ebx
  801446:	75 ec                	jne    801434 <close_all+0xc>
		close(i);
}
  801448:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80144b:	c9                   	leave  
  80144c:	c3                   	ret    

0080144d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80144d:	55                   	push   %ebp
  80144e:	89 e5                	mov    %esp,%ebp
  801450:	57                   	push   %edi
  801451:	56                   	push   %esi
  801452:	53                   	push   %ebx
  801453:	83 ec 2c             	sub    $0x2c,%esp
  801456:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801459:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80145c:	50                   	push   %eax
  80145d:	ff 75 08             	pushl  0x8(%ebp)
  801460:	e8 6e fe ff ff       	call   8012d3 <fd_lookup>
  801465:	83 c4 08             	add    $0x8,%esp
  801468:	85 c0                	test   %eax,%eax
  80146a:	0f 88 c1 00 00 00    	js     801531 <dup+0xe4>
		return r;
	close(newfdnum);
  801470:	83 ec 0c             	sub    $0xc,%esp
  801473:	56                   	push   %esi
  801474:	e8 84 ff ff ff       	call   8013fd <close>

	newfd = INDEX2FD(newfdnum);
  801479:	89 f3                	mov    %esi,%ebx
  80147b:	c1 e3 0c             	shl    $0xc,%ebx
  80147e:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801484:	83 c4 04             	add    $0x4,%esp
  801487:	ff 75 e4             	pushl  -0x1c(%ebp)
  80148a:	e8 de fd ff ff       	call   80126d <fd2data>
  80148f:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801491:	89 1c 24             	mov    %ebx,(%esp)
  801494:	e8 d4 fd ff ff       	call   80126d <fd2data>
  801499:	83 c4 10             	add    $0x10,%esp
  80149c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80149f:	89 f8                	mov    %edi,%eax
  8014a1:	c1 e8 16             	shr    $0x16,%eax
  8014a4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014ab:	a8 01                	test   $0x1,%al
  8014ad:	74 37                	je     8014e6 <dup+0x99>
  8014af:	89 f8                	mov    %edi,%eax
  8014b1:	c1 e8 0c             	shr    $0xc,%eax
  8014b4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014bb:	f6 c2 01             	test   $0x1,%dl
  8014be:	74 26                	je     8014e6 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014c0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014c7:	83 ec 0c             	sub    $0xc,%esp
  8014ca:	25 07 0e 00 00       	and    $0xe07,%eax
  8014cf:	50                   	push   %eax
  8014d0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014d3:	6a 00                	push   $0x0
  8014d5:	57                   	push   %edi
  8014d6:	6a 00                	push   $0x0
  8014d8:	e8 c6 f7 ff ff       	call   800ca3 <sys_page_map>
  8014dd:	89 c7                	mov    %eax,%edi
  8014df:	83 c4 20             	add    $0x20,%esp
  8014e2:	85 c0                	test   %eax,%eax
  8014e4:	78 2e                	js     801514 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014e6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8014e9:	89 d0                	mov    %edx,%eax
  8014eb:	c1 e8 0c             	shr    $0xc,%eax
  8014ee:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014f5:	83 ec 0c             	sub    $0xc,%esp
  8014f8:	25 07 0e 00 00       	and    $0xe07,%eax
  8014fd:	50                   	push   %eax
  8014fe:	53                   	push   %ebx
  8014ff:	6a 00                	push   $0x0
  801501:	52                   	push   %edx
  801502:	6a 00                	push   $0x0
  801504:	e8 9a f7 ff ff       	call   800ca3 <sys_page_map>
  801509:	89 c7                	mov    %eax,%edi
  80150b:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80150e:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801510:	85 ff                	test   %edi,%edi
  801512:	79 1d                	jns    801531 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801514:	83 ec 08             	sub    $0x8,%esp
  801517:	53                   	push   %ebx
  801518:	6a 00                	push   $0x0
  80151a:	e8 c6 f7 ff ff       	call   800ce5 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80151f:	83 c4 08             	add    $0x8,%esp
  801522:	ff 75 d4             	pushl  -0x2c(%ebp)
  801525:	6a 00                	push   $0x0
  801527:	e8 b9 f7 ff ff       	call   800ce5 <sys_page_unmap>
	return r;
  80152c:	83 c4 10             	add    $0x10,%esp
  80152f:	89 f8                	mov    %edi,%eax
}
  801531:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801534:	5b                   	pop    %ebx
  801535:	5e                   	pop    %esi
  801536:	5f                   	pop    %edi
  801537:	5d                   	pop    %ebp
  801538:	c3                   	ret    

00801539 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801539:	55                   	push   %ebp
  80153a:	89 e5                	mov    %esp,%ebp
  80153c:	53                   	push   %ebx
  80153d:	83 ec 14             	sub    $0x14,%esp
  801540:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801543:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801546:	50                   	push   %eax
  801547:	53                   	push   %ebx
  801548:	e8 86 fd ff ff       	call   8012d3 <fd_lookup>
  80154d:	83 c4 08             	add    $0x8,%esp
  801550:	89 c2                	mov    %eax,%edx
  801552:	85 c0                	test   %eax,%eax
  801554:	78 6d                	js     8015c3 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801556:	83 ec 08             	sub    $0x8,%esp
  801559:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80155c:	50                   	push   %eax
  80155d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801560:	ff 30                	pushl  (%eax)
  801562:	e8 c2 fd ff ff       	call   801329 <dev_lookup>
  801567:	83 c4 10             	add    $0x10,%esp
  80156a:	85 c0                	test   %eax,%eax
  80156c:	78 4c                	js     8015ba <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80156e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801571:	8b 42 08             	mov    0x8(%edx),%eax
  801574:	83 e0 03             	and    $0x3,%eax
  801577:	83 f8 01             	cmp    $0x1,%eax
  80157a:	75 21                	jne    80159d <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80157c:	a1 04 40 80 00       	mov    0x804004,%eax
  801581:	8b 40 48             	mov    0x48(%eax),%eax
  801584:	83 ec 04             	sub    $0x4,%esp
  801587:	53                   	push   %ebx
  801588:	50                   	push   %eax
  801589:	68 28 27 80 00       	push   $0x802728
  80158e:	e8 9e ec ff ff       	call   800231 <cprintf>
		return -E_INVAL;
  801593:	83 c4 10             	add    $0x10,%esp
  801596:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80159b:	eb 26                	jmp    8015c3 <read+0x8a>
	}
	if (!dev->dev_read)
  80159d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015a0:	8b 40 08             	mov    0x8(%eax),%eax
  8015a3:	85 c0                	test   %eax,%eax
  8015a5:	74 17                	je     8015be <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8015a7:	83 ec 04             	sub    $0x4,%esp
  8015aa:	ff 75 10             	pushl  0x10(%ebp)
  8015ad:	ff 75 0c             	pushl  0xc(%ebp)
  8015b0:	52                   	push   %edx
  8015b1:	ff d0                	call   *%eax
  8015b3:	89 c2                	mov    %eax,%edx
  8015b5:	83 c4 10             	add    $0x10,%esp
  8015b8:	eb 09                	jmp    8015c3 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ba:	89 c2                	mov    %eax,%edx
  8015bc:	eb 05                	jmp    8015c3 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8015be:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8015c3:	89 d0                	mov    %edx,%eax
  8015c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015c8:	c9                   	leave  
  8015c9:	c3                   	ret    

008015ca <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015ca:	55                   	push   %ebp
  8015cb:	89 e5                	mov    %esp,%ebp
  8015cd:	57                   	push   %edi
  8015ce:	56                   	push   %esi
  8015cf:	53                   	push   %ebx
  8015d0:	83 ec 0c             	sub    $0xc,%esp
  8015d3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015d6:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015d9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015de:	eb 21                	jmp    801601 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015e0:	83 ec 04             	sub    $0x4,%esp
  8015e3:	89 f0                	mov    %esi,%eax
  8015e5:	29 d8                	sub    %ebx,%eax
  8015e7:	50                   	push   %eax
  8015e8:	89 d8                	mov    %ebx,%eax
  8015ea:	03 45 0c             	add    0xc(%ebp),%eax
  8015ed:	50                   	push   %eax
  8015ee:	57                   	push   %edi
  8015ef:	e8 45 ff ff ff       	call   801539 <read>
		if (m < 0)
  8015f4:	83 c4 10             	add    $0x10,%esp
  8015f7:	85 c0                	test   %eax,%eax
  8015f9:	78 10                	js     80160b <readn+0x41>
			return m;
		if (m == 0)
  8015fb:	85 c0                	test   %eax,%eax
  8015fd:	74 0a                	je     801609 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015ff:	01 c3                	add    %eax,%ebx
  801601:	39 f3                	cmp    %esi,%ebx
  801603:	72 db                	jb     8015e0 <readn+0x16>
  801605:	89 d8                	mov    %ebx,%eax
  801607:	eb 02                	jmp    80160b <readn+0x41>
  801609:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80160b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80160e:	5b                   	pop    %ebx
  80160f:	5e                   	pop    %esi
  801610:	5f                   	pop    %edi
  801611:	5d                   	pop    %ebp
  801612:	c3                   	ret    

00801613 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801613:	55                   	push   %ebp
  801614:	89 e5                	mov    %esp,%ebp
  801616:	53                   	push   %ebx
  801617:	83 ec 14             	sub    $0x14,%esp
  80161a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80161d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801620:	50                   	push   %eax
  801621:	53                   	push   %ebx
  801622:	e8 ac fc ff ff       	call   8012d3 <fd_lookup>
  801627:	83 c4 08             	add    $0x8,%esp
  80162a:	89 c2                	mov    %eax,%edx
  80162c:	85 c0                	test   %eax,%eax
  80162e:	78 68                	js     801698 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801630:	83 ec 08             	sub    $0x8,%esp
  801633:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801636:	50                   	push   %eax
  801637:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80163a:	ff 30                	pushl  (%eax)
  80163c:	e8 e8 fc ff ff       	call   801329 <dev_lookup>
  801641:	83 c4 10             	add    $0x10,%esp
  801644:	85 c0                	test   %eax,%eax
  801646:	78 47                	js     80168f <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801648:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80164b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80164f:	75 21                	jne    801672 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801651:	a1 04 40 80 00       	mov    0x804004,%eax
  801656:	8b 40 48             	mov    0x48(%eax),%eax
  801659:	83 ec 04             	sub    $0x4,%esp
  80165c:	53                   	push   %ebx
  80165d:	50                   	push   %eax
  80165e:	68 44 27 80 00       	push   $0x802744
  801663:	e8 c9 eb ff ff       	call   800231 <cprintf>
		return -E_INVAL;
  801668:	83 c4 10             	add    $0x10,%esp
  80166b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801670:	eb 26                	jmp    801698 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801672:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801675:	8b 52 0c             	mov    0xc(%edx),%edx
  801678:	85 d2                	test   %edx,%edx
  80167a:	74 17                	je     801693 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80167c:	83 ec 04             	sub    $0x4,%esp
  80167f:	ff 75 10             	pushl  0x10(%ebp)
  801682:	ff 75 0c             	pushl  0xc(%ebp)
  801685:	50                   	push   %eax
  801686:	ff d2                	call   *%edx
  801688:	89 c2                	mov    %eax,%edx
  80168a:	83 c4 10             	add    $0x10,%esp
  80168d:	eb 09                	jmp    801698 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80168f:	89 c2                	mov    %eax,%edx
  801691:	eb 05                	jmp    801698 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801693:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801698:	89 d0                	mov    %edx,%eax
  80169a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80169d:	c9                   	leave  
  80169e:	c3                   	ret    

0080169f <seek>:

int
seek(int fdnum, off_t offset)
{
  80169f:	55                   	push   %ebp
  8016a0:	89 e5                	mov    %esp,%ebp
  8016a2:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016a5:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8016a8:	50                   	push   %eax
  8016a9:	ff 75 08             	pushl  0x8(%ebp)
  8016ac:	e8 22 fc ff ff       	call   8012d3 <fd_lookup>
  8016b1:	83 c4 08             	add    $0x8,%esp
  8016b4:	85 c0                	test   %eax,%eax
  8016b6:	78 0e                	js     8016c6 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8016b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016be:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016c1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016c6:	c9                   	leave  
  8016c7:	c3                   	ret    

008016c8 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016c8:	55                   	push   %ebp
  8016c9:	89 e5                	mov    %esp,%ebp
  8016cb:	53                   	push   %ebx
  8016cc:	83 ec 14             	sub    $0x14,%esp
  8016cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016d2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016d5:	50                   	push   %eax
  8016d6:	53                   	push   %ebx
  8016d7:	e8 f7 fb ff ff       	call   8012d3 <fd_lookup>
  8016dc:	83 c4 08             	add    $0x8,%esp
  8016df:	89 c2                	mov    %eax,%edx
  8016e1:	85 c0                	test   %eax,%eax
  8016e3:	78 65                	js     80174a <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016e5:	83 ec 08             	sub    $0x8,%esp
  8016e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016eb:	50                   	push   %eax
  8016ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ef:	ff 30                	pushl  (%eax)
  8016f1:	e8 33 fc ff ff       	call   801329 <dev_lookup>
  8016f6:	83 c4 10             	add    $0x10,%esp
  8016f9:	85 c0                	test   %eax,%eax
  8016fb:	78 44                	js     801741 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801700:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801704:	75 21                	jne    801727 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801706:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80170b:	8b 40 48             	mov    0x48(%eax),%eax
  80170e:	83 ec 04             	sub    $0x4,%esp
  801711:	53                   	push   %ebx
  801712:	50                   	push   %eax
  801713:	68 04 27 80 00       	push   $0x802704
  801718:	e8 14 eb ff ff       	call   800231 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80171d:	83 c4 10             	add    $0x10,%esp
  801720:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801725:	eb 23                	jmp    80174a <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801727:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80172a:	8b 52 18             	mov    0x18(%edx),%edx
  80172d:	85 d2                	test   %edx,%edx
  80172f:	74 14                	je     801745 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801731:	83 ec 08             	sub    $0x8,%esp
  801734:	ff 75 0c             	pushl  0xc(%ebp)
  801737:	50                   	push   %eax
  801738:	ff d2                	call   *%edx
  80173a:	89 c2                	mov    %eax,%edx
  80173c:	83 c4 10             	add    $0x10,%esp
  80173f:	eb 09                	jmp    80174a <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801741:	89 c2                	mov    %eax,%edx
  801743:	eb 05                	jmp    80174a <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801745:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80174a:	89 d0                	mov    %edx,%eax
  80174c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80174f:	c9                   	leave  
  801750:	c3                   	ret    

00801751 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801751:	55                   	push   %ebp
  801752:	89 e5                	mov    %esp,%ebp
  801754:	53                   	push   %ebx
  801755:	83 ec 14             	sub    $0x14,%esp
  801758:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80175b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80175e:	50                   	push   %eax
  80175f:	ff 75 08             	pushl  0x8(%ebp)
  801762:	e8 6c fb ff ff       	call   8012d3 <fd_lookup>
  801767:	83 c4 08             	add    $0x8,%esp
  80176a:	89 c2                	mov    %eax,%edx
  80176c:	85 c0                	test   %eax,%eax
  80176e:	78 58                	js     8017c8 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801770:	83 ec 08             	sub    $0x8,%esp
  801773:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801776:	50                   	push   %eax
  801777:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80177a:	ff 30                	pushl  (%eax)
  80177c:	e8 a8 fb ff ff       	call   801329 <dev_lookup>
  801781:	83 c4 10             	add    $0x10,%esp
  801784:	85 c0                	test   %eax,%eax
  801786:	78 37                	js     8017bf <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801788:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80178b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80178f:	74 32                	je     8017c3 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801791:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801794:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80179b:	00 00 00 
	stat->st_isdir = 0;
  80179e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017a5:	00 00 00 
	stat->st_dev = dev;
  8017a8:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017ae:	83 ec 08             	sub    $0x8,%esp
  8017b1:	53                   	push   %ebx
  8017b2:	ff 75 f0             	pushl  -0x10(%ebp)
  8017b5:	ff 50 14             	call   *0x14(%eax)
  8017b8:	89 c2                	mov    %eax,%edx
  8017ba:	83 c4 10             	add    $0x10,%esp
  8017bd:	eb 09                	jmp    8017c8 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017bf:	89 c2                	mov    %eax,%edx
  8017c1:	eb 05                	jmp    8017c8 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8017c3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8017c8:	89 d0                	mov    %edx,%eax
  8017ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017cd:	c9                   	leave  
  8017ce:	c3                   	ret    

008017cf <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017cf:	55                   	push   %ebp
  8017d0:	89 e5                	mov    %esp,%ebp
  8017d2:	56                   	push   %esi
  8017d3:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017d4:	83 ec 08             	sub    $0x8,%esp
  8017d7:	6a 00                	push   $0x0
  8017d9:	ff 75 08             	pushl  0x8(%ebp)
  8017dc:	e8 b7 01 00 00       	call   801998 <open>
  8017e1:	89 c3                	mov    %eax,%ebx
  8017e3:	83 c4 10             	add    $0x10,%esp
  8017e6:	85 c0                	test   %eax,%eax
  8017e8:	78 1b                	js     801805 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8017ea:	83 ec 08             	sub    $0x8,%esp
  8017ed:	ff 75 0c             	pushl  0xc(%ebp)
  8017f0:	50                   	push   %eax
  8017f1:	e8 5b ff ff ff       	call   801751 <fstat>
  8017f6:	89 c6                	mov    %eax,%esi
	close(fd);
  8017f8:	89 1c 24             	mov    %ebx,(%esp)
  8017fb:	e8 fd fb ff ff       	call   8013fd <close>
	return r;
  801800:	83 c4 10             	add    $0x10,%esp
  801803:	89 f0                	mov    %esi,%eax
}
  801805:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801808:	5b                   	pop    %ebx
  801809:	5e                   	pop    %esi
  80180a:	5d                   	pop    %ebp
  80180b:	c3                   	ret    

0080180c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80180c:	55                   	push   %ebp
  80180d:	89 e5                	mov    %esp,%ebp
  80180f:	56                   	push   %esi
  801810:	53                   	push   %ebx
  801811:	89 c6                	mov    %eax,%esi
  801813:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801815:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80181c:	75 12                	jne    801830 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80181e:	83 ec 0c             	sub    $0xc,%esp
  801821:	6a 01                	push   $0x1
  801823:	e8 fc f9 ff ff       	call   801224 <ipc_find_env>
  801828:	a3 00 40 80 00       	mov    %eax,0x804000
  80182d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801830:	6a 07                	push   $0x7
  801832:	68 00 50 80 00       	push   $0x805000
  801837:	56                   	push   %esi
  801838:	ff 35 00 40 80 00    	pushl  0x804000
  80183e:	e8 8d f9 ff ff       	call   8011d0 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801843:	83 c4 0c             	add    $0xc,%esp
  801846:	6a 00                	push   $0x0
  801848:	53                   	push   %ebx
  801849:	6a 00                	push   $0x0
  80184b:	e8 0b f9 ff ff       	call   80115b <ipc_recv>
}
  801850:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801853:	5b                   	pop    %ebx
  801854:	5e                   	pop    %esi
  801855:	5d                   	pop    %ebp
  801856:	c3                   	ret    

00801857 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801857:	55                   	push   %ebp
  801858:	89 e5                	mov    %esp,%ebp
  80185a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80185d:	8b 45 08             	mov    0x8(%ebp),%eax
  801860:	8b 40 0c             	mov    0xc(%eax),%eax
  801863:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801868:	8b 45 0c             	mov    0xc(%ebp),%eax
  80186b:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801870:	ba 00 00 00 00       	mov    $0x0,%edx
  801875:	b8 02 00 00 00       	mov    $0x2,%eax
  80187a:	e8 8d ff ff ff       	call   80180c <fsipc>
}
  80187f:	c9                   	leave  
  801880:	c3                   	ret    

00801881 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801881:	55                   	push   %ebp
  801882:	89 e5                	mov    %esp,%ebp
  801884:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801887:	8b 45 08             	mov    0x8(%ebp),%eax
  80188a:	8b 40 0c             	mov    0xc(%eax),%eax
  80188d:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801892:	ba 00 00 00 00       	mov    $0x0,%edx
  801897:	b8 06 00 00 00       	mov    $0x6,%eax
  80189c:	e8 6b ff ff ff       	call   80180c <fsipc>
}
  8018a1:	c9                   	leave  
  8018a2:	c3                   	ret    

008018a3 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8018a3:	55                   	push   %ebp
  8018a4:	89 e5                	mov    %esp,%ebp
  8018a6:	53                   	push   %ebx
  8018a7:	83 ec 04             	sub    $0x4,%esp
  8018aa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b0:	8b 40 0c             	mov    0xc(%eax),%eax
  8018b3:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8018bd:	b8 05 00 00 00       	mov    $0x5,%eax
  8018c2:	e8 45 ff ff ff       	call   80180c <fsipc>
  8018c7:	85 c0                	test   %eax,%eax
  8018c9:	78 2c                	js     8018f7 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018cb:	83 ec 08             	sub    $0x8,%esp
  8018ce:	68 00 50 80 00       	push   $0x805000
  8018d3:	53                   	push   %ebx
  8018d4:	e8 84 ef ff ff       	call   80085d <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018d9:	a1 80 50 80 00       	mov    0x805080,%eax
  8018de:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018e4:	a1 84 50 80 00       	mov    0x805084,%eax
  8018e9:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018ef:	83 c4 10             	add    $0x10,%esp
  8018f2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018fa:	c9                   	leave  
  8018fb:	c3                   	ret    

008018fc <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8018fc:	55                   	push   %ebp
  8018fd:	89 e5                	mov    %esp,%ebp
  8018ff:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801902:	68 74 27 80 00       	push   $0x802774
  801907:	68 90 00 00 00       	push   $0x90
  80190c:	68 92 27 80 00       	push   $0x802792
  801911:	e8 42 e8 ff ff       	call   800158 <_panic>

00801916 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801916:	55                   	push   %ebp
  801917:	89 e5                	mov    %esp,%ebp
  801919:	56                   	push   %esi
  80191a:	53                   	push   %ebx
  80191b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80191e:	8b 45 08             	mov    0x8(%ebp),%eax
  801921:	8b 40 0c             	mov    0xc(%eax),%eax
  801924:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801929:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80192f:	ba 00 00 00 00       	mov    $0x0,%edx
  801934:	b8 03 00 00 00       	mov    $0x3,%eax
  801939:	e8 ce fe ff ff       	call   80180c <fsipc>
  80193e:	89 c3                	mov    %eax,%ebx
  801940:	85 c0                	test   %eax,%eax
  801942:	78 4b                	js     80198f <devfile_read+0x79>
		return r;
	assert(r <= n);
  801944:	39 c6                	cmp    %eax,%esi
  801946:	73 16                	jae    80195e <devfile_read+0x48>
  801948:	68 9d 27 80 00       	push   $0x80279d
  80194d:	68 a4 27 80 00       	push   $0x8027a4
  801952:	6a 7c                	push   $0x7c
  801954:	68 92 27 80 00       	push   $0x802792
  801959:	e8 fa e7 ff ff       	call   800158 <_panic>
	assert(r <= PGSIZE);
  80195e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801963:	7e 16                	jle    80197b <devfile_read+0x65>
  801965:	68 b9 27 80 00       	push   $0x8027b9
  80196a:	68 a4 27 80 00       	push   $0x8027a4
  80196f:	6a 7d                	push   $0x7d
  801971:	68 92 27 80 00       	push   $0x802792
  801976:	e8 dd e7 ff ff       	call   800158 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80197b:	83 ec 04             	sub    $0x4,%esp
  80197e:	50                   	push   %eax
  80197f:	68 00 50 80 00       	push   $0x805000
  801984:	ff 75 0c             	pushl  0xc(%ebp)
  801987:	e8 63 f0 ff ff       	call   8009ef <memmove>
	return r;
  80198c:	83 c4 10             	add    $0x10,%esp
}
  80198f:	89 d8                	mov    %ebx,%eax
  801991:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801994:	5b                   	pop    %ebx
  801995:	5e                   	pop    %esi
  801996:	5d                   	pop    %ebp
  801997:	c3                   	ret    

00801998 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801998:	55                   	push   %ebp
  801999:	89 e5                	mov    %esp,%ebp
  80199b:	53                   	push   %ebx
  80199c:	83 ec 20             	sub    $0x20,%esp
  80199f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8019a2:	53                   	push   %ebx
  8019a3:	e8 7c ee ff ff       	call   800824 <strlen>
  8019a8:	83 c4 10             	add    $0x10,%esp
  8019ab:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019b0:	7f 67                	jg     801a19 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019b2:	83 ec 0c             	sub    $0xc,%esp
  8019b5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019b8:	50                   	push   %eax
  8019b9:	e8 c6 f8 ff ff       	call   801284 <fd_alloc>
  8019be:	83 c4 10             	add    $0x10,%esp
		return r;
  8019c1:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019c3:	85 c0                	test   %eax,%eax
  8019c5:	78 57                	js     801a1e <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8019c7:	83 ec 08             	sub    $0x8,%esp
  8019ca:	53                   	push   %ebx
  8019cb:	68 00 50 80 00       	push   $0x805000
  8019d0:	e8 88 ee ff ff       	call   80085d <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019d8:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019dd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019e0:	b8 01 00 00 00       	mov    $0x1,%eax
  8019e5:	e8 22 fe ff ff       	call   80180c <fsipc>
  8019ea:	89 c3                	mov    %eax,%ebx
  8019ec:	83 c4 10             	add    $0x10,%esp
  8019ef:	85 c0                	test   %eax,%eax
  8019f1:	79 14                	jns    801a07 <open+0x6f>
		fd_close(fd, 0);
  8019f3:	83 ec 08             	sub    $0x8,%esp
  8019f6:	6a 00                	push   $0x0
  8019f8:	ff 75 f4             	pushl  -0xc(%ebp)
  8019fb:	e8 7c f9 ff ff       	call   80137c <fd_close>
		return r;
  801a00:	83 c4 10             	add    $0x10,%esp
  801a03:	89 da                	mov    %ebx,%edx
  801a05:	eb 17                	jmp    801a1e <open+0x86>
	}

	return fd2num(fd);
  801a07:	83 ec 0c             	sub    $0xc,%esp
  801a0a:	ff 75 f4             	pushl  -0xc(%ebp)
  801a0d:	e8 4b f8 ff ff       	call   80125d <fd2num>
  801a12:	89 c2                	mov    %eax,%edx
  801a14:	83 c4 10             	add    $0x10,%esp
  801a17:	eb 05                	jmp    801a1e <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a19:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a1e:	89 d0                	mov    %edx,%eax
  801a20:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a23:	c9                   	leave  
  801a24:	c3                   	ret    

00801a25 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a25:	55                   	push   %ebp
  801a26:	89 e5                	mov    %esp,%ebp
  801a28:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a2b:	ba 00 00 00 00       	mov    $0x0,%edx
  801a30:	b8 08 00 00 00       	mov    $0x8,%eax
  801a35:	e8 d2 fd ff ff       	call   80180c <fsipc>
}
  801a3a:	c9                   	leave  
  801a3b:	c3                   	ret    

00801a3c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a3c:	55                   	push   %ebp
  801a3d:	89 e5                	mov    %esp,%ebp
  801a3f:	56                   	push   %esi
  801a40:	53                   	push   %ebx
  801a41:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a44:	83 ec 0c             	sub    $0xc,%esp
  801a47:	ff 75 08             	pushl  0x8(%ebp)
  801a4a:	e8 1e f8 ff ff       	call   80126d <fd2data>
  801a4f:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a51:	83 c4 08             	add    $0x8,%esp
  801a54:	68 c5 27 80 00       	push   $0x8027c5
  801a59:	53                   	push   %ebx
  801a5a:	e8 fe ed ff ff       	call   80085d <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a5f:	8b 46 04             	mov    0x4(%esi),%eax
  801a62:	2b 06                	sub    (%esi),%eax
  801a64:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a6a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a71:	00 00 00 
	stat->st_dev = &devpipe;
  801a74:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a7b:	30 80 00 
	return 0;
}
  801a7e:	b8 00 00 00 00       	mov    $0x0,%eax
  801a83:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a86:	5b                   	pop    %ebx
  801a87:	5e                   	pop    %esi
  801a88:	5d                   	pop    %ebp
  801a89:	c3                   	ret    

00801a8a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a8a:	55                   	push   %ebp
  801a8b:	89 e5                	mov    %esp,%ebp
  801a8d:	53                   	push   %ebx
  801a8e:	83 ec 0c             	sub    $0xc,%esp
  801a91:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a94:	53                   	push   %ebx
  801a95:	6a 00                	push   $0x0
  801a97:	e8 49 f2 ff ff       	call   800ce5 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a9c:	89 1c 24             	mov    %ebx,(%esp)
  801a9f:	e8 c9 f7 ff ff       	call   80126d <fd2data>
  801aa4:	83 c4 08             	add    $0x8,%esp
  801aa7:	50                   	push   %eax
  801aa8:	6a 00                	push   $0x0
  801aaa:	e8 36 f2 ff ff       	call   800ce5 <sys_page_unmap>
}
  801aaf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ab2:	c9                   	leave  
  801ab3:	c3                   	ret    

00801ab4 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801ab4:	55                   	push   %ebp
  801ab5:	89 e5                	mov    %esp,%ebp
  801ab7:	57                   	push   %edi
  801ab8:	56                   	push   %esi
  801ab9:	53                   	push   %ebx
  801aba:	83 ec 1c             	sub    $0x1c,%esp
  801abd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801ac0:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ac2:	a1 04 40 80 00       	mov    0x804004,%eax
  801ac7:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801aca:	83 ec 0c             	sub    $0xc,%esp
  801acd:	ff 75 e0             	pushl  -0x20(%ebp)
  801ad0:	e8 b6 04 00 00       	call   801f8b <pageref>
  801ad5:	89 c3                	mov    %eax,%ebx
  801ad7:	89 3c 24             	mov    %edi,(%esp)
  801ada:	e8 ac 04 00 00       	call   801f8b <pageref>
  801adf:	83 c4 10             	add    $0x10,%esp
  801ae2:	39 c3                	cmp    %eax,%ebx
  801ae4:	0f 94 c1             	sete   %cl
  801ae7:	0f b6 c9             	movzbl %cl,%ecx
  801aea:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801aed:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801af3:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801af6:	39 ce                	cmp    %ecx,%esi
  801af8:	74 1b                	je     801b15 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801afa:	39 c3                	cmp    %eax,%ebx
  801afc:	75 c4                	jne    801ac2 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801afe:	8b 42 58             	mov    0x58(%edx),%eax
  801b01:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b04:	50                   	push   %eax
  801b05:	56                   	push   %esi
  801b06:	68 cc 27 80 00       	push   $0x8027cc
  801b0b:	e8 21 e7 ff ff       	call   800231 <cprintf>
  801b10:	83 c4 10             	add    $0x10,%esp
  801b13:	eb ad                	jmp    801ac2 <_pipeisclosed+0xe>
	}
}
  801b15:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b18:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b1b:	5b                   	pop    %ebx
  801b1c:	5e                   	pop    %esi
  801b1d:	5f                   	pop    %edi
  801b1e:	5d                   	pop    %ebp
  801b1f:	c3                   	ret    

00801b20 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b20:	55                   	push   %ebp
  801b21:	89 e5                	mov    %esp,%ebp
  801b23:	57                   	push   %edi
  801b24:	56                   	push   %esi
  801b25:	53                   	push   %ebx
  801b26:	83 ec 28             	sub    $0x28,%esp
  801b29:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b2c:	56                   	push   %esi
  801b2d:	e8 3b f7 ff ff       	call   80126d <fd2data>
  801b32:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b34:	83 c4 10             	add    $0x10,%esp
  801b37:	bf 00 00 00 00       	mov    $0x0,%edi
  801b3c:	eb 4b                	jmp    801b89 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b3e:	89 da                	mov    %ebx,%edx
  801b40:	89 f0                	mov    %esi,%eax
  801b42:	e8 6d ff ff ff       	call   801ab4 <_pipeisclosed>
  801b47:	85 c0                	test   %eax,%eax
  801b49:	75 48                	jne    801b93 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b4b:	e8 f1 f0 ff ff       	call   800c41 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b50:	8b 43 04             	mov    0x4(%ebx),%eax
  801b53:	8b 0b                	mov    (%ebx),%ecx
  801b55:	8d 51 20             	lea    0x20(%ecx),%edx
  801b58:	39 d0                	cmp    %edx,%eax
  801b5a:	73 e2                	jae    801b3e <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b5c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b5f:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b63:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b66:	89 c2                	mov    %eax,%edx
  801b68:	c1 fa 1f             	sar    $0x1f,%edx
  801b6b:	89 d1                	mov    %edx,%ecx
  801b6d:	c1 e9 1b             	shr    $0x1b,%ecx
  801b70:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b73:	83 e2 1f             	and    $0x1f,%edx
  801b76:	29 ca                	sub    %ecx,%edx
  801b78:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b7c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b80:	83 c0 01             	add    $0x1,%eax
  801b83:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b86:	83 c7 01             	add    $0x1,%edi
  801b89:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b8c:	75 c2                	jne    801b50 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b8e:	8b 45 10             	mov    0x10(%ebp),%eax
  801b91:	eb 05                	jmp    801b98 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b93:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b98:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b9b:	5b                   	pop    %ebx
  801b9c:	5e                   	pop    %esi
  801b9d:	5f                   	pop    %edi
  801b9e:	5d                   	pop    %ebp
  801b9f:	c3                   	ret    

00801ba0 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ba0:	55                   	push   %ebp
  801ba1:	89 e5                	mov    %esp,%ebp
  801ba3:	57                   	push   %edi
  801ba4:	56                   	push   %esi
  801ba5:	53                   	push   %ebx
  801ba6:	83 ec 18             	sub    $0x18,%esp
  801ba9:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801bac:	57                   	push   %edi
  801bad:	e8 bb f6 ff ff       	call   80126d <fd2data>
  801bb2:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bb4:	83 c4 10             	add    $0x10,%esp
  801bb7:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bbc:	eb 3d                	jmp    801bfb <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801bbe:	85 db                	test   %ebx,%ebx
  801bc0:	74 04                	je     801bc6 <devpipe_read+0x26>
				return i;
  801bc2:	89 d8                	mov    %ebx,%eax
  801bc4:	eb 44                	jmp    801c0a <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801bc6:	89 f2                	mov    %esi,%edx
  801bc8:	89 f8                	mov    %edi,%eax
  801bca:	e8 e5 fe ff ff       	call   801ab4 <_pipeisclosed>
  801bcf:	85 c0                	test   %eax,%eax
  801bd1:	75 32                	jne    801c05 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801bd3:	e8 69 f0 ff ff       	call   800c41 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801bd8:	8b 06                	mov    (%esi),%eax
  801bda:	3b 46 04             	cmp    0x4(%esi),%eax
  801bdd:	74 df                	je     801bbe <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801bdf:	99                   	cltd   
  801be0:	c1 ea 1b             	shr    $0x1b,%edx
  801be3:	01 d0                	add    %edx,%eax
  801be5:	83 e0 1f             	and    $0x1f,%eax
  801be8:	29 d0                	sub    %edx,%eax
  801bea:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801bef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bf2:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801bf5:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bf8:	83 c3 01             	add    $0x1,%ebx
  801bfb:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801bfe:	75 d8                	jne    801bd8 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c00:	8b 45 10             	mov    0x10(%ebp),%eax
  801c03:	eb 05                	jmp    801c0a <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c05:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c0a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c0d:	5b                   	pop    %ebx
  801c0e:	5e                   	pop    %esi
  801c0f:	5f                   	pop    %edi
  801c10:	5d                   	pop    %ebp
  801c11:	c3                   	ret    

00801c12 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c12:	55                   	push   %ebp
  801c13:	89 e5                	mov    %esp,%ebp
  801c15:	56                   	push   %esi
  801c16:	53                   	push   %ebx
  801c17:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c1a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c1d:	50                   	push   %eax
  801c1e:	e8 61 f6 ff ff       	call   801284 <fd_alloc>
  801c23:	83 c4 10             	add    $0x10,%esp
  801c26:	89 c2                	mov    %eax,%edx
  801c28:	85 c0                	test   %eax,%eax
  801c2a:	0f 88 2c 01 00 00    	js     801d5c <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c30:	83 ec 04             	sub    $0x4,%esp
  801c33:	68 07 04 00 00       	push   $0x407
  801c38:	ff 75 f4             	pushl  -0xc(%ebp)
  801c3b:	6a 00                	push   $0x0
  801c3d:	e8 1e f0 ff ff       	call   800c60 <sys_page_alloc>
  801c42:	83 c4 10             	add    $0x10,%esp
  801c45:	89 c2                	mov    %eax,%edx
  801c47:	85 c0                	test   %eax,%eax
  801c49:	0f 88 0d 01 00 00    	js     801d5c <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c4f:	83 ec 0c             	sub    $0xc,%esp
  801c52:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c55:	50                   	push   %eax
  801c56:	e8 29 f6 ff ff       	call   801284 <fd_alloc>
  801c5b:	89 c3                	mov    %eax,%ebx
  801c5d:	83 c4 10             	add    $0x10,%esp
  801c60:	85 c0                	test   %eax,%eax
  801c62:	0f 88 e2 00 00 00    	js     801d4a <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c68:	83 ec 04             	sub    $0x4,%esp
  801c6b:	68 07 04 00 00       	push   $0x407
  801c70:	ff 75 f0             	pushl  -0x10(%ebp)
  801c73:	6a 00                	push   $0x0
  801c75:	e8 e6 ef ff ff       	call   800c60 <sys_page_alloc>
  801c7a:	89 c3                	mov    %eax,%ebx
  801c7c:	83 c4 10             	add    $0x10,%esp
  801c7f:	85 c0                	test   %eax,%eax
  801c81:	0f 88 c3 00 00 00    	js     801d4a <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c87:	83 ec 0c             	sub    $0xc,%esp
  801c8a:	ff 75 f4             	pushl  -0xc(%ebp)
  801c8d:	e8 db f5 ff ff       	call   80126d <fd2data>
  801c92:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c94:	83 c4 0c             	add    $0xc,%esp
  801c97:	68 07 04 00 00       	push   $0x407
  801c9c:	50                   	push   %eax
  801c9d:	6a 00                	push   $0x0
  801c9f:	e8 bc ef ff ff       	call   800c60 <sys_page_alloc>
  801ca4:	89 c3                	mov    %eax,%ebx
  801ca6:	83 c4 10             	add    $0x10,%esp
  801ca9:	85 c0                	test   %eax,%eax
  801cab:	0f 88 89 00 00 00    	js     801d3a <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cb1:	83 ec 0c             	sub    $0xc,%esp
  801cb4:	ff 75 f0             	pushl  -0x10(%ebp)
  801cb7:	e8 b1 f5 ff ff       	call   80126d <fd2data>
  801cbc:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801cc3:	50                   	push   %eax
  801cc4:	6a 00                	push   $0x0
  801cc6:	56                   	push   %esi
  801cc7:	6a 00                	push   $0x0
  801cc9:	e8 d5 ef ff ff       	call   800ca3 <sys_page_map>
  801cce:	89 c3                	mov    %eax,%ebx
  801cd0:	83 c4 20             	add    $0x20,%esp
  801cd3:	85 c0                	test   %eax,%eax
  801cd5:	78 55                	js     801d2c <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801cd7:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ce0:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ce2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ce5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801cec:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cf2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cf5:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801cf7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cfa:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d01:	83 ec 0c             	sub    $0xc,%esp
  801d04:	ff 75 f4             	pushl  -0xc(%ebp)
  801d07:	e8 51 f5 ff ff       	call   80125d <fd2num>
  801d0c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d0f:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d11:	83 c4 04             	add    $0x4,%esp
  801d14:	ff 75 f0             	pushl  -0x10(%ebp)
  801d17:	e8 41 f5 ff ff       	call   80125d <fd2num>
  801d1c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d1f:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d22:	83 c4 10             	add    $0x10,%esp
  801d25:	ba 00 00 00 00       	mov    $0x0,%edx
  801d2a:	eb 30                	jmp    801d5c <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d2c:	83 ec 08             	sub    $0x8,%esp
  801d2f:	56                   	push   %esi
  801d30:	6a 00                	push   $0x0
  801d32:	e8 ae ef ff ff       	call   800ce5 <sys_page_unmap>
  801d37:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d3a:	83 ec 08             	sub    $0x8,%esp
  801d3d:	ff 75 f0             	pushl  -0x10(%ebp)
  801d40:	6a 00                	push   $0x0
  801d42:	e8 9e ef ff ff       	call   800ce5 <sys_page_unmap>
  801d47:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d4a:	83 ec 08             	sub    $0x8,%esp
  801d4d:	ff 75 f4             	pushl  -0xc(%ebp)
  801d50:	6a 00                	push   $0x0
  801d52:	e8 8e ef ff ff       	call   800ce5 <sys_page_unmap>
  801d57:	83 c4 10             	add    $0x10,%esp
  801d5a:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d5c:	89 d0                	mov    %edx,%eax
  801d5e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d61:	5b                   	pop    %ebx
  801d62:	5e                   	pop    %esi
  801d63:	5d                   	pop    %ebp
  801d64:	c3                   	ret    

00801d65 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d65:	55                   	push   %ebp
  801d66:	89 e5                	mov    %esp,%ebp
  801d68:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d6b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d6e:	50                   	push   %eax
  801d6f:	ff 75 08             	pushl  0x8(%ebp)
  801d72:	e8 5c f5 ff ff       	call   8012d3 <fd_lookup>
  801d77:	83 c4 10             	add    $0x10,%esp
  801d7a:	85 c0                	test   %eax,%eax
  801d7c:	78 18                	js     801d96 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d7e:	83 ec 0c             	sub    $0xc,%esp
  801d81:	ff 75 f4             	pushl  -0xc(%ebp)
  801d84:	e8 e4 f4 ff ff       	call   80126d <fd2data>
	return _pipeisclosed(fd, p);
  801d89:	89 c2                	mov    %eax,%edx
  801d8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d8e:	e8 21 fd ff ff       	call   801ab4 <_pipeisclosed>
  801d93:	83 c4 10             	add    $0x10,%esp
}
  801d96:	c9                   	leave  
  801d97:	c3                   	ret    

00801d98 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d98:	55                   	push   %ebp
  801d99:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d9b:	b8 00 00 00 00       	mov    $0x0,%eax
  801da0:	5d                   	pop    %ebp
  801da1:	c3                   	ret    

00801da2 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801da2:	55                   	push   %ebp
  801da3:	89 e5                	mov    %esp,%ebp
  801da5:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801da8:	68 e4 27 80 00       	push   $0x8027e4
  801dad:	ff 75 0c             	pushl  0xc(%ebp)
  801db0:	e8 a8 ea ff ff       	call   80085d <strcpy>
	return 0;
}
  801db5:	b8 00 00 00 00       	mov    $0x0,%eax
  801dba:	c9                   	leave  
  801dbb:	c3                   	ret    

00801dbc <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801dbc:	55                   	push   %ebp
  801dbd:	89 e5                	mov    %esp,%ebp
  801dbf:	57                   	push   %edi
  801dc0:	56                   	push   %esi
  801dc1:	53                   	push   %ebx
  801dc2:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dc8:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801dcd:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dd3:	eb 2d                	jmp    801e02 <devcons_write+0x46>
		m = n - tot;
  801dd5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801dd8:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801dda:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801ddd:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801de2:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801de5:	83 ec 04             	sub    $0x4,%esp
  801de8:	53                   	push   %ebx
  801de9:	03 45 0c             	add    0xc(%ebp),%eax
  801dec:	50                   	push   %eax
  801ded:	57                   	push   %edi
  801dee:	e8 fc eb ff ff       	call   8009ef <memmove>
		sys_cputs(buf, m);
  801df3:	83 c4 08             	add    $0x8,%esp
  801df6:	53                   	push   %ebx
  801df7:	57                   	push   %edi
  801df8:	e8 a7 ed ff ff       	call   800ba4 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dfd:	01 de                	add    %ebx,%esi
  801dff:	83 c4 10             	add    $0x10,%esp
  801e02:	89 f0                	mov    %esi,%eax
  801e04:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e07:	72 cc                	jb     801dd5 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e09:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e0c:	5b                   	pop    %ebx
  801e0d:	5e                   	pop    %esi
  801e0e:	5f                   	pop    %edi
  801e0f:	5d                   	pop    %ebp
  801e10:	c3                   	ret    

00801e11 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e11:	55                   	push   %ebp
  801e12:	89 e5                	mov    %esp,%ebp
  801e14:	83 ec 08             	sub    $0x8,%esp
  801e17:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801e1c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e20:	74 2a                	je     801e4c <devcons_read+0x3b>
  801e22:	eb 05                	jmp    801e29 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e24:	e8 18 ee ff ff       	call   800c41 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e29:	e8 94 ed ff ff       	call   800bc2 <sys_cgetc>
  801e2e:	85 c0                	test   %eax,%eax
  801e30:	74 f2                	je     801e24 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801e32:	85 c0                	test   %eax,%eax
  801e34:	78 16                	js     801e4c <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e36:	83 f8 04             	cmp    $0x4,%eax
  801e39:	74 0c                	je     801e47 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e3b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e3e:	88 02                	mov    %al,(%edx)
	return 1;
  801e40:	b8 01 00 00 00       	mov    $0x1,%eax
  801e45:	eb 05                	jmp    801e4c <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e47:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e4c:	c9                   	leave  
  801e4d:	c3                   	ret    

00801e4e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e4e:	55                   	push   %ebp
  801e4f:	89 e5                	mov    %esp,%ebp
  801e51:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e54:	8b 45 08             	mov    0x8(%ebp),%eax
  801e57:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e5a:	6a 01                	push   $0x1
  801e5c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e5f:	50                   	push   %eax
  801e60:	e8 3f ed ff ff       	call   800ba4 <sys_cputs>
}
  801e65:	83 c4 10             	add    $0x10,%esp
  801e68:	c9                   	leave  
  801e69:	c3                   	ret    

00801e6a <getchar>:

int
getchar(void)
{
  801e6a:	55                   	push   %ebp
  801e6b:	89 e5                	mov    %esp,%ebp
  801e6d:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e70:	6a 01                	push   $0x1
  801e72:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e75:	50                   	push   %eax
  801e76:	6a 00                	push   $0x0
  801e78:	e8 bc f6 ff ff       	call   801539 <read>
	if (r < 0)
  801e7d:	83 c4 10             	add    $0x10,%esp
  801e80:	85 c0                	test   %eax,%eax
  801e82:	78 0f                	js     801e93 <getchar+0x29>
		return r;
	if (r < 1)
  801e84:	85 c0                	test   %eax,%eax
  801e86:	7e 06                	jle    801e8e <getchar+0x24>
		return -E_EOF;
	return c;
  801e88:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e8c:	eb 05                	jmp    801e93 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e8e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e93:	c9                   	leave  
  801e94:	c3                   	ret    

00801e95 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e95:	55                   	push   %ebp
  801e96:	89 e5                	mov    %esp,%ebp
  801e98:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e9b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e9e:	50                   	push   %eax
  801e9f:	ff 75 08             	pushl  0x8(%ebp)
  801ea2:	e8 2c f4 ff ff       	call   8012d3 <fd_lookup>
  801ea7:	83 c4 10             	add    $0x10,%esp
  801eaa:	85 c0                	test   %eax,%eax
  801eac:	78 11                	js     801ebf <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801eae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eb1:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801eb7:	39 10                	cmp    %edx,(%eax)
  801eb9:	0f 94 c0             	sete   %al
  801ebc:	0f b6 c0             	movzbl %al,%eax
}
  801ebf:	c9                   	leave  
  801ec0:	c3                   	ret    

00801ec1 <opencons>:

int
opencons(void)
{
  801ec1:	55                   	push   %ebp
  801ec2:	89 e5                	mov    %esp,%ebp
  801ec4:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ec7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801eca:	50                   	push   %eax
  801ecb:	e8 b4 f3 ff ff       	call   801284 <fd_alloc>
  801ed0:	83 c4 10             	add    $0x10,%esp
		return r;
  801ed3:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ed5:	85 c0                	test   %eax,%eax
  801ed7:	78 3e                	js     801f17 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ed9:	83 ec 04             	sub    $0x4,%esp
  801edc:	68 07 04 00 00       	push   $0x407
  801ee1:	ff 75 f4             	pushl  -0xc(%ebp)
  801ee4:	6a 00                	push   $0x0
  801ee6:	e8 75 ed ff ff       	call   800c60 <sys_page_alloc>
  801eeb:	83 c4 10             	add    $0x10,%esp
		return r;
  801eee:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ef0:	85 c0                	test   %eax,%eax
  801ef2:	78 23                	js     801f17 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ef4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801efa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801efd:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801eff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f02:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f09:	83 ec 0c             	sub    $0xc,%esp
  801f0c:	50                   	push   %eax
  801f0d:	e8 4b f3 ff ff       	call   80125d <fd2num>
  801f12:	89 c2                	mov    %eax,%edx
  801f14:	83 c4 10             	add    $0x10,%esp
}
  801f17:	89 d0                	mov    %edx,%eax
  801f19:	c9                   	leave  
  801f1a:	c3                   	ret    

00801f1b <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f1b:	55                   	push   %ebp
  801f1c:	89 e5                	mov    %esp,%ebp
  801f1e:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f21:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f28:	75 31                	jne    801f5b <set_pgfault_handler+0x40>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc(thisenv->env_id, (void*)(UXSTACKTOP - PGSIZE), PTE_P | 
  801f2a:	a1 04 40 80 00       	mov    0x804004,%eax
  801f2f:	8b 40 48             	mov    0x48(%eax),%eax
  801f32:	83 ec 04             	sub    $0x4,%esp
  801f35:	6a 07                	push   $0x7
  801f37:	68 00 f0 bf ee       	push   $0xeebff000
  801f3c:	50                   	push   %eax
  801f3d:	e8 1e ed ff ff       	call   800c60 <sys_page_alloc>
				PTE_U | PTE_W);
		sys_env_set_pgfault_upcall(thisenv->env_id, (void*)_pgfault_upcall);
  801f42:	a1 04 40 80 00       	mov    0x804004,%eax
  801f47:	8b 40 48             	mov    0x48(%eax),%eax
  801f4a:	83 c4 08             	add    $0x8,%esp
  801f4d:	68 65 1f 80 00       	push   $0x801f65
  801f52:	50                   	push   %eax
  801f53:	e8 53 ee ff ff       	call   800dab <sys_env_set_pgfault_upcall>
  801f58:	83 c4 10             	add    $0x10,%esp

		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f5b:	8b 45 08             	mov    0x8(%ebp),%eax
  801f5e:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801f63:	c9                   	leave  
  801f64:	c3                   	ret    

00801f65 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f65:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f66:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f6b:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f6d:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	addl $8, %esp      // pop utf_fault_va and utf_err
  801f70:	83 c4 08             	add    $0x8,%esp
	movl 32(%esp), %eax  // eax <- [esp + 32]
  801f73:	8b 44 24 20          	mov    0x20(%esp),%eax
	movl 40(%esp), %ebx  // ebx <- [esp + 40]
  801f77:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	leal -4(%ebx), %ebx  // ebx <- ebx - 4
  801f7b:	8d 5b fc             	lea    -0x4(%ebx),%ebx
	movl %eax, (%ebx)
  801f7e:	89 03                	mov    %eax,(%ebx)
	movl %ebx, 40(%esp)  // push trap eip and decrement trap esp manually
  801f80:	89 5c 24 28          	mov    %ebx,0x28(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  801f84:	61                   	popa   
	addl $4, %esp        // skip eip
  801f85:	83 c4 04             	add    $0x4,%esp

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	popf
  801f88:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	pop %esp
  801f89:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801f8a:	c3                   	ret    

00801f8b <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f8b:	55                   	push   %ebp
  801f8c:	89 e5                	mov    %esp,%ebp
  801f8e:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f91:	89 d0                	mov    %edx,%eax
  801f93:	c1 e8 16             	shr    $0x16,%eax
  801f96:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f9d:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fa2:	f6 c1 01             	test   $0x1,%cl
  801fa5:	74 1d                	je     801fc4 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fa7:	c1 ea 0c             	shr    $0xc,%edx
  801faa:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fb1:	f6 c2 01             	test   $0x1,%dl
  801fb4:	74 0e                	je     801fc4 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fb6:	c1 ea 0c             	shr    $0xc,%edx
  801fb9:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fc0:	ef 
  801fc1:	0f b7 c0             	movzwl %ax,%eax
}
  801fc4:	5d                   	pop    %ebp
  801fc5:	c3                   	ret    
  801fc6:	66 90                	xchg   %ax,%ax
  801fc8:	66 90                	xchg   %ax,%ax
  801fca:	66 90                	xchg   %ax,%ax
  801fcc:	66 90                	xchg   %ax,%ax
  801fce:	66 90                	xchg   %ax,%ax

00801fd0 <__udivdi3>:
  801fd0:	55                   	push   %ebp
  801fd1:	57                   	push   %edi
  801fd2:	56                   	push   %esi
  801fd3:	53                   	push   %ebx
  801fd4:	83 ec 1c             	sub    $0x1c,%esp
  801fd7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801fdb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801fdf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801fe3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801fe7:	85 f6                	test   %esi,%esi
  801fe9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fed:	89 ca                	mov    %ecx,%edx
  801fef:	89 f8                	mov    %edi,%eax
  801ff1:	75 3d                	jne    802030 <__udivdi3+0x60>
  801ff3:	39 cf                	cmp    %ecx,%edi
  801ff5:	0f 87 c5 00 00 00    	ja     8020c0 <__udivdi3+0xf0>
  801ffb:	85 ff                	test   %edi,%edi
  801ffd:	89 fd                	mov    %edi,%ebp
  801fff:	75 0b                	jne    80200c <__udivdi3+0x3c>
  802001:	b8 01 00 00 00       	mov    $0x1,%eax
  802006:	31 d2                	xor    %edx,%edx
  802008:	f7 f7                	div    %edi
  80200a:	89 c5                	mov    %eax,%ebp
  80200c:	89 c8                	mov    %ecx,%eax
  80200e:	31 d2                	xor    %edx,%edx
  802010:	f7 f5                	div    %ebp
  802012:	89 c1                	mov    %eax,%ecx
  802014:	89 d8                	mov    %ebx,%eax
  802016:	89 cf                	mov    %ecx,%edi
  802018:	f7 f5                	div    %ebp
  80201a:	89 c3                	mov    %eax,%ebx
  80201c:	89 d8                	mov    %ebx,%eax
  80201e:	89 fa                	mov    %edi,%edx
  802020:	83 c4 1c             	add    $0x1c,%esp
  802023:	5b                   	pop    %ebx
  802024:	5e                   	pop    %esi
  802025:	5f                   	pop    %edi
  802026:	5d                   	pop    %ebp
  802027:	c3                   	ret    
  802028:	90                   	nop
  802029:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802030:	39 ce                	cmp    %ecx,%esi
  802032:	77 74                	ja     8020a8 <__udivdi3+0xd8>
  802034:	0f bd fe             	bsr    %esi,%edi
  802037:	83 f7 1f             	xor    $0x1f,%edi
  80203a:	0f 84 98 00 00 00    	je     8020d8 <__udivdi3+0x108>
  802040:	bb 20 00 00 00       	mov    $0x20,%ebx
  802045:	89 f9                	mov    %edi,%ecx
  802047:	89 c5                	mov    %eax,%ebp
  802049:	29 fb                	sub    %edi,%ebx
  80204b:	d3 e6                	shl    %cl,%esi
  80204d:	89 d9                	mov    %ebx,%ecx
  80204f:	d3 ed                	shr    %cl,%ebp
  802051:	89 f9                	mov    %edi,%ecx
  802053:	d3 e0                	shl    %cl,%eax
  802055:	09 ee                	or     %ebp,%esi
  802057:	89 d9                	mov    %ebx,%ecx
  802059:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80205d:	89 d5                	mov    %edx,%ebp
  80205f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802063:	d3 ed                	shr    %cl,%ebp
  802065:	89 f9                	mov    %edi,%ecx
  802067:	d3 e2                	shl    %cl,%edx
  802069:	89 d9                	mov    %ebx,%ecx
  80206b:	d3 e8                	shr    %cl,%eax
  80206d:	09 c2                	or     %eax,%edx
  80206f:	89 d0                	mov    %edx,%eax
  802071:	89 ea                	mov    %ebp,%edx
  802073:	f7 f6                	div    %esi
  802075:	89 d5                	mov    %edx,%ebp
  802077:	89 c3                	mov    %eax,%ebx
  802079:	f7 64 24 0c          	mull   0xc(%esp)
  80207d:	39 d5                	cmp    %edx,%ebp
  80207f:	72 10                	jb     802091 <__udivdi3+0xc1>
  802081:	8b 74 24 08          	mov    0x8(%esp),%esi
  802085:	89 f9                	mov    %edi,%ecx
  802087:	d3 e6                	shl    %cl,%esi
  802089:	39 c6                	cmp    %eax,%esi
  80208b:	73 07                	jae    802094 <__udivdi3+0xc4>
  80208d:	39 d5                	cmp    %edx,%ebp
  80208f:	75 03                	jne    802094 <__udivdi3+0xc4>
  802091:	83 eb 01             	sub    $0x1,%ebx
  802094:	31 ff                	xor    %edi,%edi
  802096:	89 d8                	mov    %ebx,%eax
  802098:	89 fa                	mov    %edi,%edx
  80209a:	83 c4 1c             	add    $0x1c,%esp
  80209d:	5b                   	pop    %ebx
  80209e:	5e                   	pop    %esi
  80209f:	5f                   	pop    %edi
  8020a0:	5d                   	pop    %ebp
  8020a1:	c3                   	ret    
  8020a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020a8:	31 ff                	xor    %edi,%edi
  8020aa:	31 db                	xor    %ebx,%ebx
  8020ac:	89 d8                	mov    %ebx,%eax
  8020ae:	89 fa                	mov    %edi,%edx
  8020b0:	83 c4 1c             	add    $0x1c,%esp
  8020b3:	5b                   	pop    %ebx
  8020b4:	5e                   	pop    %esi
  8020b5:	5f                   	pop    %edi
  8020b6:	5d                   	pop    %ebp
  8020b7:	c3                   	ret    
  8020b8:	90                   	nop
  8020b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020c0:	89 d8                	mov    %ebx,%eax
  8020c2:	f7 f7                	div    %edi
  8020c4:	31 ff                	xor    %edi,%edi
  8020c6:	89 c3                	mov    %eax,%ebx
  8020c8:	89 d8                	mov    %ebx,%eax
  8020ca:	89 fa                	mov    %edi,%edx
  8020cc:	83 c4 1c             	add    $0x1c,%esp
  8020cf:	5b                   	pop    %ebx
  8020d0:	5e                   	pop    %esi
  8020d1:	5f                   	pop    %edi
  8020d2:	5d                   	pop    %ebp
  8020d3:	c3                   	ret    
  8020d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020d8:	39 ce                	cmp    %ecx,%esi
  8020da:	72 0c                	jb     8020e8 <__udivdi3+0x118>
  8020dc:	31 db                	xor    %ebx,%ebx
  8020de:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8020e2:	0f 87 34 ff ff ff    	ja     80201c <__udivdi3+0x4c>
  8020e8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8020ed:	e9 2a ff ff ff       	jmp    80201c <__udivdi3+0x4c>
  8020f2:	66 90                	xchg   %ax,%ax
  8020f4:	66 90                	xchg   %ax,%ax
  8020f6:	66 90                	xchg   %ax,%ax
  8020f8:	66 90                	xchg   %ax,%ax
  8020fa:	66 90                	xchg   %ax,%ax
  8020fc:	66 90                	xchg   %ax,%ax
  8020fe:	66 90                	xchg   %ax,%ax

00802100 <__umoddi3>:
  802100:	55                   	push   %ebp
  802101:	57                   	push   %edi
  802102:	56                   	push   %esi
  802103:	53                   	push   %ebx
  802104:	83 ec 1c             	sub    $0x1c,%esp
  802107:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80210b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80210f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802113:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802117:	85 d2                	test   %edx,%edx
  802119:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80211d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802121:	89 f3                	mov    %esi,%ebx
  802123:	89 3c 24             	mov    %edi,(%esp)
  802126:	89 74 24 04          	mov    %esi,0x4(%esp)
  80212a:	75 1c                	jne    802148 <__umoddi3+0x48>
  80212c:	39 f7                	cmp    %esi,%edi
  80212e:	76 50                	jbe    802180 <__umoddi3+0x80>
  802130:	89 c8                	mov    %ecx,%eax
  802132:	89 f2                	mov    %esi,%edx
  802134:	f7 f7                	div    %edi
  802136:	89 d0                	mov    %edx,%eax
  802138:	31 d2                	xor    %edx,%edx
  80213a:	83 c4 1c             	add    $0x1c,%esp
  80213d:	5b                   	pop    %ebx
  80213e:	5e                   	pop    %esi
  80213f:	5f                   	pop    %edi
  802140:	5d                   	pop    %ebp
  802141:	c3                   	ret    
  802142:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802148:	39 f2                	cmp    %esi,%edx
  80214a:	89 d0                	mov    %edx,%eax
  80214c:	77 52                	ja     8021a0 <__umoddi3+0xa0>
  80214e:	0f bd ea             	bsr    %edx,%ebp
  802151:	83 f5 1f             	xor    $0x1f,%ebp
  802154:	75 5a                	jne    8021b0 <__umoddi3+0xb0>
  802156:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80215a:	0f 82 e0 00 00 00    	jb     802240 <__umoddi3+0x140>
  802160:	39 0c 24             	cmp    %ecx,(%esp)
  802163:	0f 86 d7 00 00 00    	jbe    802240 <__umoddi3+0x140>
  802169:	8b 44 24 08          	mov    0x8(%esp),%eax
  80216d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802171:	83 c4 1c             	add    $0x1c,%esp
  802174:	5b                   	pop    %ebx
  802175:	5e                   	pop    %esi
  802176:	5f                   	pop    %edi
  802177:	5d                   	pop    %ebp
  802178:	c3                   	ret    
  802179:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802180:	85 ff                	test   %edi,%edi
  802182:	89 fd                	mov    %edi,%ebp
  802184:	75 0b                	jne    802191 <__umoddi3+0x91>
  802186:	b8 01 00 00 00       	mov    $0x1,%eax
  80218b:	31 d2                	xor    %edx,%edx
  80218d:	f7 f7                	div    %edi
  80218f:	89 c5                	mov    %eax,%ebp
  802191:	89 f0                	mov    %esi,%eax
  802193:	31 d2                	xor    %edx,%edx
  802195:	f7 f5                	div    %ebp
  802197:	89 c8                	mov    %ecx,%eax
  802199:	f7 f5                	div    %ebp
  80219b:	89 d0                	mov    %edx,%eax
  80219d:	eb 99                	jmp    802138 <__umoddi3+0x38>
  80219f:	90                   	nop
  8021a0:	89 c8                	mov    %ecx,%eax
  8021a2:	89 f2                	mov    %esi,%edx
  8021a4:	83 c4 1c             	add    $0x1c,%esp
  8021a7:	5b                   	pop    %ebx
  8021a8:	5e                   	pop    %esi
  8021a9:	5f                   	pop    %edi
  8021aa:	5d                   	pop    %ebp
  8021ab:	c3                   	ret    
  8021ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021b0:	8b 34 24             	mov    (%esp),%esi
  8021b3:	bf 20 00 00 00       	mov    $0x20,%edi
  8021b8:	89 e9                	mov    %ebp,%ecx
  8021ba:	29 ef                	sub    %ebp,%edi
  8021bc:	d3 e0                	shl    %cl,%eax
  8021be:	89 f9                	mov    %edi,%ecx
  8021c0:	89 f2                	mov    %esi,%edx
  8021c2:	d3 ea                	shr    %cl,%edx
  8021c4:	89 e9                	mov    %ebp,%ecx
  8021c6:	09 c2                	or     %eax,%edx
  8021c8:	89 d8                	mov    %ebx,%eax
  8021ca:	89 14 24             	mov    %edx,(%esp)
  8021cd:	89 f2                	mov    %esi,%edx
  8021cf:	d3 e2                	shl    %cl,%edx
  8021d1:	89 f9                	mov    %edi,%ecx
  8021d3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021d7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8021db:	d3 e8                	shr    %cl,%eax
  8021dd:	89 e9                	mov    %ebp,%ecx
  8021df:	89 c6                	mov    %eax,%esi
  8021e1:	d3 e3                	shl    %cl,%ebx
  8021e3:	89 f9                	mov    %edi,%ecx
  8021e5:	89 d0                	mov    %edx,%eax
  8021e7:	d3 e8                	shr    %cl,%eax
  8021e9:	89 e9                	mov    %ebp,%ecx
  8021eb:	09 d8                	or     %ebx,%eax
  8021ed:	89 d3                	mov    %edx,%ebx
  8021ef:	89 f2                	mov    %esi,%edx
  8021f1:	f7 34 24             	divl   (%esp)
  8021f4:	89 d6                	mov    %edx,%esi
  8021f6:	d3 e3                	shl    %cl,%ebx
  8021f8:	f7 64 24 04          	mull   0x4(%esp)
  8021fc:	39 d6                	cmp    %edx,%esi
  8021fe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802202:	89 d1                	mov    %edx,%ecx
  802204:	89 c3                	mov    %eax,%ebx
  802206:	72 08                	jb     802210 <__umoddi3+0x110>
  802208:	75 11                	jne    80221b <__umoddi3+0x11b>
  80220a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80220e:	73 0b                	jae    80221b <__umoddi3+0x11b>
  802210:	2b 44 24 04          	sub    0x4(%esp),%eax
  802214:	1b 14 24             	sbb    (%esp),%edx
  802217:	89 d1                	mov    %edx,%ecx
  802219:	89 c3                	mov    %eax,%ebx
  80221b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80221f:	29 da                	sub    %ebx,%edx
  802221:	19 ce                	sbb    %ecx,%esi
  802223:	89 f9                	mov    %edi,%ecx
  802225:	89 f0                	mov    %esi,%eax
  802227:	d3 e0                	shl    %cl,%eax
  802229:	89 e9                	mov    %ebp,%ecx
  80222b:	d3 ea                	shr    %cl,%edx
  80222d:	89 e9                	mov    %ebp,%ecx
  80222f:	d3 ee                	shr    %cl,%esi
  802231:	09 d0                	or     %edx,%eax
  802233:	89 f2                	mov    %esi,%edx
  802235:	83 c4 1c             	add    $0x1c,%esp
  802238:	5b                   	pop    %ebx
  802239:	5e                   	pop    %esi
  80223a:	5f                   	pop    %edi
  80223b:	5d                   	pop    %ebp
  80223c:	c3                   	ret    
  80223d:	8d 76 00             	lea    0x0(%esi),%esi
  802240:	29 f9                	sub    %edi,%ecx
  802242:	19 d6                	sbb    %edx,%esi
  802244:	89 74 24 04          	mov    %esi,0x4(%esp)
  802248:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80224c:	e9 18 ff ff ff       	jmp    802169 <__umoddi3+0x69>
