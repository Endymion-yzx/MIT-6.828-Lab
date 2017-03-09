
obj/user/testpiperace2.debug:     file format elf32-i386


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
  80002c:	e8 a5 01 00 00       	call   8001d6 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 38             	sub    $0x38,%esp
	int p[2], r, i;
	struct Fd *fd;
	const volatile struct Env *kid;

	cprintf("testing for pipeisclosed race...\n");
  80003c:	68 40 23 80 00       	push   $0x802340
  800041:	e8 c9 02 00 00       	call   80030f <cprintf>
	if ((r = pipe(p)) < 0)
  800046:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800049:	89 04 24             	mov    %eax,(%esp)
  80004c:	e8 9d 1b 00 00       	call   801bee <pipe>
  800051:	83 c4 10             	add    $0x10,%esp
  800054:	85 c0                	test   %eax,%eax
  800056:	79 12                	jns    80006a <umain+0x37>
		panic("pipe: %e", r);
  800058:	50                   	push   %eax
  800059:	68 8e 23 80 00       	push   $0x80238e
  80005e:	6a 0d                	push   $0xd
  800060:	68 97 23 80 00       	push   $0x802397
  800065:	e8 cc 01 00 00       	call   800236 <_panic>
	if ((r = fork()) < 0)
  80006a:	e8 6d 10 00 00       	call   8010dc <fork>
  80006f:	89 c6                	mov    %eax,%esi
  800071:	85 c0                	test   %eax,%eax
  800073:	79 12                	jns    800087 <umain+0x54>
		panic("fork: %e", r);
  800075:	50                   	push   %eax
  800076:	68 ac 23 80 00       	push   $0x8023ac
  80007b:	6a 0f                	push   $0xf
  80007d:	68 97 23 80 00       	push   $0x802397
  800082:	e8 af 01 00 00       	call   800236 <_panic>
	if (r == 0) {
  800087:	85 c0                	test   %eax,%eax
  800089:	75 76                	jne    800101 <umain+0xce>
		// child just dups and closes repeatedly,
		// yielding so the parent can see
		// the fd state between the two.
		close(p[1]);
  80008b:	83 ec 0c             	sub    $0xc,%esp
  80008e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800091:	e8 43 13 00 00       	call   8013d9 <close>
  800096:	83 c4 10             	add    $0x10,%esp
		for (i = 0; i < 200; i++) {
  800099:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (i % 10 == 0)
  80009e:	bf 67 66 66 66       	mov    $0x66666667,%edi
  8000a3:	89 d8                	mov    %ebx,%eax
  8000a5:	f7 ef                	imul   %edi
  8000a7:	c1 fa 02             	sar    $0x2,%edx
  8000aa:	89 d8                	mov    %ebx,%eax
  8000ac:	c1 f8 1f             	sar    $0x1f,%eax
  8000af:	29 c2                	sub    %eax,%edx
  8000b1:	8d 04 92             	lea    (%edx,%edx,4),%eax
  8000b4:	01 c0                	add    %eax,%eax
  8000b6:	39 c3                	cmp    %eax,%ebx
  8000b8:	75 11                	jne    8000cb <umain+0x98>
				cprintf("%d.", i);
  8000ba:	83 ec 08             	sub    $0x8,%esp
  8000bd:	53                   	push   %ebx
  8000be:	68 b5 23 80 00       	push   $0x8023b5
  8000c3:	e8 47 02 00 00       	call   80030f <cprintf>
  8000c8:	83 c4 10             	add    $0x10,%esp
			// dup, then close.  yield so that other guy will
			// see us while we're between them.
			dup(p[0], 10);
  8000cb:	83 ec 08             	sub    $0x8,%esp
  8000ce:	6a 0a                	push   $0xa
  8000d0:	ff 75 e0             	pushl  -0x20(%ebp)
  8000d3:	e8 51 13 00 00       	call   801429 <dup>
			sys_yield();
  8000d8:	e8 42 0c 00 00       	call   800d1f <sys_yield>
			close(10);
  8000dd:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  8000e4:	e8 f0 12 00 00       	call   8013d9 <close>
			sys_yield();
  8000e9:	e8 31 0c 00 00       	call   800d1f <sys_yield>
	if (r == 0) {
		// child just dups and closes repeatedly,
		// yielding so the parent can see
		// the fd state between the two.
		close(p[1]);
		for (i = 0; i < 200; i++) {
  8000ee:	83 c3 01             	add    $0x1,%ebx
  8000f1:	83 c4 10             	add    $0x10,%esp
  8000f4:	81 fb c8 00 00 00    	cmp    $0xc8,%ebx
  8000fa:	75 a7                	jne    8000a3 <umain+0x70>
			dup(p[0], 10);
			sys_yield();
			close(10);
			sys_yield();
		}
		exit();
  8000fc:	e8 1b 01 00 00       	call   80021c <exit>
	// pageref(p[0]) and gets 3, then it will return true when
	// it shouldn't.
	//
	// So either way, pipeisclosed is going give a wrong answer.
	//
	kid = &envs[ENVX(r)];
  800101:	89 f0                	mov    %esi,%eax
  800103:	25 ff 03 00 00       	and    $0x3ff,%eax
	while (kid->env_status == ENV_RUNNABLE)
  800108:	8d 3c 85 00 00 00 00 	lea    0x0(,%eax,4),%edi
  80010f:	c1 e0 07             	shl    $0x7,%eax
  800112:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800115:	eb 2f                	jmp    800146 <umain+0x113>
		if (pipeisclosed(p[0]) != 0) {
  800117:	83 ec 0c             	sub    $0xc,%esp
  80011a:	ff 75 e0             	pushl  -0x20(%ebp)
  80011d:	e8 1f 1c 00 00       	call   801d41 <pipeisclosed>
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	85 c0                	test   %eax,%eax
  800127:	74 28                	je     800151 <umain+0x11e>
			cprintf("\nRACE: pipe appears closed\n");
  800129:	83 ec 0c             	sub    $0xc,%esp
  80012c:	68 b9 23 80 00       	push   $0x8023b9
  800131:	e8 d9 01 00 00       	call   80030f <cprintf>
			sys_env_destroy(r);
  800136:	89 34 24             	mov    %esi,(%esp)
  800139:	e8 81 0b 00 00       	call   800cbf <sys_env_destroy>
			exit();
  80013e:	e8 d9 00 00 00       	call   80021c <exit>
  800143:	83 c4 10             	add    $0x10,%esp
	// it shouldn't.
	//
	// So either way, pipeisclosed is going give a wrong answer.
	//
	kid = &envs[ENVX(r)];
	while (kid->env_status == ENV_RUNNABLE)
  800146:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800149:	29 fb                	sub    %edi,%ebx
  80014b:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  800151:	8b 43 54             	mov    0x54(%ebx),%eax
  800154:	83 f8 02             	cmp    $0x2,%eax
  800157:	74 be                	je     800117 <umain+0xe4>
		if (pipeisclosed(p[0]) != 0) {
			cprintf("\nRACE: pipe appears closed\n");
			sys_env_destroy(r);
			exit();
		}
	cprintf("child done with loop\n");
  800159:	83 ec 0c             	sub    $0xc,%esp
  80015c:	68 d5 23 80 00       	push   $0x8023d5
  800161:	e8 a9 01 00 00       	call   80030f <cprintf>
	if (pipeisclosed(p[0]))
  800166:	83 c4 04             	add    $0x4,%esp
  800169:	ff 75 e0             	pushl  -0x20(%ebp)
  80016c:	e8 d0 1b 00 00       	call   801d41 <pipeisclosed>
  800171:	83 c4 10             	add    $0x10,%esp
  800174:	85 c0                	test   %eax,%eax
  800176:	74 14                	je     80018c <umain+0x159>
		panic("somehow the other end of p[0] got closed!");
  800178:	83 ec 04             	sub    $0x4,%esp
  80017b:	68 64 23 80 00       	push   $0x802364
  800180:	6a 40                	push   $0x40
  800182:	68 97 23 80 00       	push   $0x802397
  800187:	e8 aa 00 00 00       	call   800236 <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  80018c:	83 ec 08             	sub    $0x8,%esp
  80018f:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800192:	50                   	push   %eax
  800193:	ff 75 e0             	pushl  -0x20(%ebp)
  800196:	e8 14 11 00 00       	call   8012af <fd_lookup>
  80019b:	83 c4 10             	add    $0x10,%esp
  80019e:	85 c0                	test   %eax,%eax
  8001a0:	79 12                	jns    8001b4 <umain+0x181>
		panic("cannot look up p[0]: %e", r);
  8001a2:	50                   	push   %eax
  8001a3:	68 eb 23 80 00       	push   $0x8023eb
  8001a8:	6a 42                	push   $0x42
  8001aa:	68 97 23 80 00       	push   $0x802397
  8001af:	e8 82 00 00 00       	call   800236 <_panic>
	(void) fd2data(fd);
  8001b4:	83 ec 0c             	sub    $0xc,%esp
  8001b7:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ba:	e8 8a 10 00 00       	call   801249 <fd2data>
	cprintf("race didn't happen\n");
  8001bf:	c7 04 24 03 24 80 00 	movl   $0x802403,(%esp)
  8001c6:	e8 44 01 00 00       	call   80030f <cprintf>
}
  8001cb:	83 c4 10             	add    $0x10,%esp
  8001ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d1:	5b                   	pop    %ebx
  8001d2:	5e                   	pop    %esi
  8001d3:	5f                   	pop    %edi
  8001d4:	5d                   	pop    %ebp
  8001d5:	c3                   	ret    

008001d6 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001d6:	55                   	push   %ebp
  8001d7:	89 e5                	mov    %esp,%ebp
  8001d9:	56                   	push   %esi
  8001da:	53                   	push   %ebx
  8001db:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001de:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	envid_t envid = sys_getenvid();
  8001e1:	e8 1a 0b 00 00       	call   800d00 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8001e6:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001eb:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001ee:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001f3:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001f8:	85 db                	test   %ebx,%ebx
  8001fa:	7e 07                	jle    800203 <libmain+0x2d>
		binaryname = argv[0];
  8001fc:	8b 06                	mov    (%esi),%eax
  8001fe:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800203:	83 ec 08             	sub    $0x8,%esp
  800206:	56                   	push   %esi
  800207:	53                   	push   %ebx
  800208:	e8 26 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80020d:	e8 0a 00 00 00       	call   80021c <exit>
}
  800212:	83 c4 10             	add    $0x10,%esp
  800215:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800218:	5b                   	pop    %ebx
  800219:	5e                   	pop    %esi
  80021a:	5d                   	pop    %ebp
  80021b:	c3                   	ret    

0080021c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800222:	e8 dd 11 00 00       	call   801404 <close_all>
	sys_env_destroy(0);
  800227:	83 ec 0c             	sub    $0xc,%esp
  80022a:	6a 00                	push   $0x0
  80022c:	e8 8e 0a 00 00       	call   800cbf <sys_env_destroy>
}
  800231:	83 c4 10             	add    $0x10,%esp
  800234:	c9                   	leave  
  800235:	c3                   	ret    

00800236 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800236:	55                   	push   %ebp
  800237:	89 e5                	mov    %esp,%ebp
  800239:	56                   	push   %esi
  80023a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80023b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80023e:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800244:	e8 b7 0a 00 00       	call   800d00 <sys_getenvid>
  800249:	83 ec 0c             	sub    $0xc,%esp
  80024c:	ff 75 0c             	pushl  0xc(%ebp)
  80024f:	ff 75 08             	pushl  0x8(%ebp)
  800252:	56                   	push   %esi
  800253:	50                   	push   %eax
  800254:	68 24 24 80 00       	push   $0x802424
  800259:	e8 b1 00 00 00       	call   80030f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80025e:	83 c4 18             	add    $0x18,%esp
  800261:	53                   	push   %ebx
  800262:	ff 75 10             	pushl  0x10(%ebp)
  800265:	e8 54 00 00 00       	call   8002be <vcprintf>
	cprintf("\n");
  80026a:	c7 04 24 45 29 80 00 	movl   $0x802945,(%esp)
  800271:	e8 99 00 00 00       	call   80030f <cprintf>
  800276:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800279:	cc                   	int3   
  80027a:	eb fd                	jmp    800279 <_panic+0x43>

0080027c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80027c:	55                   	push   %ebp
  80027d:	89 e5                	mov    %esp,%ebp
  80027f:	53                   	push   %ebx
  800280:	83 ec 04             	sub    $0x4,%esp
  800283:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800286:	8b 13                	mov    (%ebx),%edx
  800288:	8d 42 01             	lea    0x1(%edx),%eax
  80028b:	89 03                	mov    %eax,(%ebx)
  80028d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800290:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800294:	3d ff 00 00 00       	cmp    $0xff,%eax
  800299:	75 1a                	jne    8002b5 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80029b:	83 ec 08             	sub    $0x8,%esp
  80029e:	68 ff 00 00 00       	push   $0xff
  8002a3:	8d 43 08             	lea    0x8(%ebx),%eax
  8002a6:	50                   	push   %eax
  8002a7:	e8 d6 09 00 00       	call   800c82 <sys_cputs>
		b->idx = 0;
  8002ac:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002b2:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002b5:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002bc:	c9                   	leave  
  8002bd:	c3                   	ret    

008002be <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002be:	55                   	push   %ebp
  8002bf:	89 e5                	mov    %esp,%ebp
  8002c1:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002c7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002ce:	00 00 00 
	b.cnt = 0;
  8002d1:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002d8:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002db:	ff 75 0c             	pushl  0xc(%ebp)
  8002de:	ff 75 08             	pushl  0x8(%ebp)
  8002e1:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002e7:	50                   	push   %eax
  8002e8:	68 7c 02 80 00       	push   $0x80027c
  8002ed:	e8 1a 01 00 00       	call   80040c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002f2:	83 c4 08             	add    $0x8,%esp
  8002f5:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002fb:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800301:	50                   	push   %eax
  800302:	e8 7b 09 00 00       	call   800c82 <sys_cputs>

	return b.cnt;
}
  800307:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80030d:	c9                   	leave  
  80030e:	c3                   	ret    

0080030f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80030f:	55                   	push   %ebp
  800310:	89 e5                	mov    %esp,%ebp
  800312:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800315:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800318:	50                   	push   %eax
  800319:	ff 75 08             	pushl  0x8(%ebp)
  80031c:	e8 9d ff ff ff       	call   8002be <vcprintf>
	va_end(ap);

	return cnt;
}
  800321:	c9                   	leave  
  800322:	c3                   	ret    

00800323 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800323:	55                   	push   %ebp
  800324:	89 e5                	mov    %esp,%ebp
  800326:	57                   	push   %edi
  800327:	56                   	push   %esi
  800328:	53                   	push   %ebx
  800329:	83 ec 1c             	sub    $0x1c,%esp
  80032c:	89 c7                	mov    %eax,%edi
  80032e:	89 d6                	mov    %edx,%esi
  800330:	8b 45 08             	mov    0x8(%ebp),%eax
  800333:	8b 55 0c             	mov    0xc(%ebp),%edx
  800336:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800339:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80033c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80033f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800344:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800347:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80034a:	39 d3                	cmp    %edx,%ebx
  80034c:	72 05                	jb     800353 <printnum+0x30>
  80034e:	39 45 10             	cmp    %eax,0x10(%ebp)
  800351:	77 45                	ja     800398 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800353:	83 ec 0c             	sub    $0xc,%esp
  800356:	ff 75 18             	pushl  0x18(%ebp)
  800359:	8b 45 14             	mov    0x14(%ebp),%eax
  80035c:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80035f:	53                   	push   %ebx
  800360:	ff 75 10             	pushl  0x10(%ebp)
  800363:	83 ec 08             	sub    $0x8,%esp
  800366:	ff 75 e4             	pushl  -0x1c(%ebp)
  800369:	ff 75 e0             	pushl  -0x20(%ebp)
  80036c:	ff 75 dc             	pushl  -0x24(%ebp)
  80036f:	ff 75 d8             	pushl  -0x28(%ebp)
  800372:	e8 39 1d 00 00       	call   8020b0 <__udivdi3>
  800377:	83 c4 18             	add    $0x18,%esp
  80037a:	52                   	push   %edx
  80037b:	50                   	push   %eax
  80037c:	89 f2                	mov    %esi,%edx
  80037e:	89 f8                	mov    %edi,%eax
  800380:	e8 9e ff ff ff       	call   800323 <printnum>
  800385:	83 c4 20             	add    $0x20,%esp
  800388:	eb 18                	jmp    8003a2 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80038a:	83 ec 08             	sub    $0x8,%esp
  80038d:	56                   	push   %esi
  80038e:	ff 75 18             	pushl  0x18(%ebp)
  800391:	ff d7                	call   *%edi
  800393:	83 c4 10             	add    $0x10,%esp
  800396:	eb 03                	jmp    80039b <printnum+0x78>
  800398:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80039b:	83 eb 01             	sub    $0x1,%ebx
  80039e:	85 db                	test   %ebx,%ebx
  8003a0:	7f e8                	jg     80038a <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003a2:	83 ec 08             	sub    $0x8,%esp
  8003a5:	56                   	push   %esi
  8003a6:	83 ec 04             	sub    $0x4,%esp
  8003a9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003ac:	ff 75 e0             	pushl  -0x20(%ebp)
  8003af:	ff 75 dc             	pushl  -0x24(%ebp)
  8003b2:	ff 75 d8             	pushl  -0x28(%ebp)
  8003b5:	e8 26 1e 00 00       	call   8021e0 <__umoddi3>
  8003ba:	83 c4 14             	add    $0x14,%esp
  8003bd:	0f be 80 47 24 80 00 	movsbl 0x802447(%eax),%eax
  8003c4:	50                   	push   %eax
  8003c5:	ff d7                	call   *%edi
}
  8003c7:	83 c4 10             	add    $0x10,%esp
  8003ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003cd:	5b                   	pop    %ebx
  8003ce:	5e                   	pop    %esi
  8003cf:	5f                   	pop    %edi
  8003d0:	5d                   	pop    %ebp
  8003d1:	c3                   	ret    

008003d2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003d2:	55                   	push   %ebp
  8003d3:	89 e5                	mov    %esp,%ebp
  8003d5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003d8:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003dc:	8b 10                	mov    (%eax),%edx
  8003de:	3b 50 04             	cmp    0x4(%eax),%edx
  8003e1:	73 0a                	jae    8003ed <sprintputch+0x1b>
		*b->buf++ = ch;
  8003e3:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003e6:	89 08                	mov    %ecx,(%eax)
  8003e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8003eb:	88 02                	mov    %al,(%edx)
}
  8003ed:	5d                   	pop    %ebp
  8003ee:	c3                   	ret    

008003ef <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003ef:	55                   	push   %ebp
  8003f0:	89 e5                	mov    %esp,%ebp
  8003f2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003f5:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003f8:	50                   	push   %eax
  8003f9:	ff 75 10             	pushl  0x10(%ebp)
  8003fc:	ff 75 0c             	pushl  0xc(%ebp)
  8003ff:	ff 75 08             	pushl  0x8(%ebp)
  800402:	e8 05 00 00 00       	call   80040c <vprintfmt>
	va_end(ap);
}
  800407:	83 c4 10             	add    $0x10,%esp
  80040a:	c9                   	leave  
  80040b:	c3                   	ret    

0080040c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80040c:	55                   	push   %ebp
  80040d:	89 e5                	mov    %esp,%ebp
  80040f:	57                   	push   %edi
  800410:	56                   	push   %esi
  800411:	53                   	push   %ebx
  800412:	83 ec 2c             	sub    $0x2c,%esp
  800415:	8b 75 08             	mov    0x8(%ebp),%esi
  800418:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80041b:	8b 7d 10             	mov    0x10(%ebp),%edi
  80041e:	eb 12                	jmp    800432 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800420:	85 c0                	test   %eax,%eax
  800422:	0f 84 6a 04 00 00    	je     800892 <vprintfmt+0x486>
				return;
			putch(ch, putdat);
  800428:	83 ec 08             	sub    $0x8,%esp
  80042b:	53                   	push   %ebx
  80042c:	50                   	push   %eax
  80042d:	ff d6                	call   *%esi
  80042f:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800432:	83 c7 01             	add    $0x1,%edi
  800435:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800439:	83 f8 25             	cmp    $0x25,%eax
  80043c:	75 e2                	jne    800420 <vprintfmt+0x14>
  80043e:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800442:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800449:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800450:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800457:	b9 00 00 00 00       	mov    $0x0,%ecx
  80045c:	eb 07                	jmp    800465 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045e:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800461:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800465:	8d 47 01             	lea    0x1(%edi),%eax
  800468:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80046b:	0f b6 07             	movzbl (%edi),%eax
  80046e:	0f b6 d0             	movzbl %al,%edx
  800471:	83 e8 23             	sub    $0x23,%eax
  800474:	3c 55                	cmp    $0x55,%al
  800476:	0f 87 fb 03 00 00    	ja     800877 <vprintfmt+0x46b>
  80047c:	0f b6 c0             	movzbl %al,%eax
  80047f:	ff 24 85 80 25 80 00 	jmp    *0x802580(,%eax,4)
  800486:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800489:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80048d:	eb d6                	jmp    800465 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800492:	b8 00 00 00 00       	mov    $0x0,%eax
  800497:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80049a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80049d:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8004a1:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8004a4:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8004a7:	83 f9 09             	cmp    $0x9,%ecx
  8004aa:	77 3f                	ja     8004eb <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004ac:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004af:	eb e9                	jmp    80049a <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b4:	8b 00                	mov    (%eax),%eax
  8004b6:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004bc:	8d 40 04             	lea    0x4(%eax),%eax
  8004bf:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004c5:	eb 2a                	jmp    8004f1 <vprintfmt+0xe5>
  8004c7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004ca:	85 c0                	test   %eax,%eax
  8004cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8004d1:	0f 49 d0             	cmovns %eax,%edx
  8004d4:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004da:	eb 89                	jmp    800465 <vprintfmt+0x59>
  8004dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004df:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004e6:	e9 7a ff ff ff       	jmp    800465 <vprintfmt+0x59>
  8004eb:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8004ee:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8004f1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004f5:	0f 89 6a ff ff ff    	jns    800465 <vprintfmt+0x59>
				width = precision, precision = -1;
  8004fb:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004fe:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800501:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800508:	e9 58 ff ff ff       	jmp    800465 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80050d:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800510:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800513:	e9 4d ff ff ff       	jmp    800465 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800518:	8b 45 14             	mov    0x14(%ebp),%eax
  80051b:	8d 78 04             	lea    0x4(%eax),%edi
  80051e:	83 ec 08             	sub    $0x8,%esp
  800521:	53                   	push   %ebx
  800522:	ff 30                	pushl  (%eax)
  800524:	ff d6                	call   *%esi
			break;
  800526:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800529:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80052f:	e9 fe fe ff ff       	jmp    800432 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800534:	8b 45 14             	mov    0x14(%ebp),%eax
  800537:	8d 78 04             	lea    0x4(%eax),%edi
  80053a:	8b 00                	mov    (%eax),%eax
  80053c:	99                   	cltd   
  80053d:	31 d0                	xor    %edx,%eax
  80053f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800541:	83 f8 0f             	cmp    $0xf,%eax
  800544:	7f 0b                	jg     800551 <vprintfmt+0x145>
  800546:	8b 14 85 e0 26 80 00 	mov    0x8026e0(,%eax,4),%edx
  80054d:	85 d2                	test   %edx,%edx
  80054f:	75 1b                	jne    80056c <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800551:	50                   	push   %eax
  800552:	68 5f 24 80 00       	push   $0x80245f
  800557:	53                   	push   %ebx
  800558:	56                   	push   %esi
  800559:	e8 91 fe ff ff       	call   8003ef <printfmt>
  80055e:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800561:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800564:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800567:	e9 c6 fe ff ff       	jmp    800432 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80056c:	52                   	push   %edx
  80056d:	68 1e 29 80 00       	push   $0x80291e
  800572:	53                   	push   %ebx
  800573:	56                   	push   %esi
  800574:	e8 76 fe ff ff       	call   8003ef <printfmt>
  800579:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80057c:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800582:	e9 ab fe ff ff       	jmp    800432 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800587:	8b 45 14             	mov    0x14(%ebp),%eax
  80058a:	83 c0 04             	add    $0x4,%eax
  80058d:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800590:	8b 45 14             	mov    0x14(%ebp),%eax
  800593:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800595:	85 ff                	test   %edi,%edi
  800597:	b8 58 24 80 00       	mov    $0x802458,%eax
  80059c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80059f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005a3:	0f 8e 94 00 00 00    	jle    80063d <vprintfmt+0x231>
  8005a9:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005ad:	0f 84 98 00 00 00    	je     80064b <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b3:	83 ec 08             	sub    $0x8,%esp
  8005b6:	ff 75 d0             	pushl  -0x30(%ebp)
  8005b9:	57                   	push   %edi
  8005ba:	e8 5b 03 00 00       	call   80091a <strnlen>
  8005bf:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005c2:	29 c1                	sub    %eax,%ecx
  8005c4:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8005c7:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005ca:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005ce:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005d1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005d4:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005d6:	eb 0f                	jmp    8005e7 <vprintfmt+0x1db>
					putch(padc, putdat);
  8005d8:	83 ec 08             	sub    $0x8,%esp
  8005db:	53                   	push   %ebx
  8005dc:	ff 75 e0             	pushl  -0x20(%ebp)
  8005df:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e1:	83 ef 01             	sub    $0x1,%edi
  8005e4:	83 c4 10             	add    $0x10,%esp
  8005e7:	85 ff                	test   %edi,%edi
  8005e9:	7f ed                	jg     8005d8 <vprintfmt+0x1cc>
  8005eb:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005ee:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8005f1:	85 c9                	test   %ecx,%ecx
  8005f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8005f8:	0f 49 c1             	cmovns %ecx,%eax
  8005fb:	29 c1                	sub    %eax,%ecx
  8005fd:	89 75 08             	mov    %esi,0x8(%ebp)
  800600:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800603:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800606:	89 cb                	mov    %ecx,%ebx
  800608:	eb 4d                	jmp    800657 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80060a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80060e:	74 1b                	je     80062b <vprintfmt+0x21f>
  800610:	0f be c0             	movsbl %al,%eax
  800613:	83 e8 20             	sub    $0x20,%eax
  800616:	83 f8 5e             	cmp    $0x5e,%eax
  800619:	76 10                	jbe    80062b <vprintfmt+0x21f>
					putch('?', putdat);
  80061b:	83 ec 08             	sub    $0x8,%esp
  80061e:	ff 75 0c             	pushl  0xc(%ebp)
  800621:	6a 3f                	push   $0x3f
  800623:	ff 55 08             	call   *0x8(%ebp)
  800626:	83 c4 10             	add    $0x10,%esp
  800629:	eb 0d                	jmp    800638 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  80062b:	83 ec 08             	sub    $0x8,%esp
  80062e:	ff 75 0c             	pushl  0xc(%ebp)
  800631:	52                   	push   %edx
  800632:	ff 55 08             	call   *0x8(%ebp)
  800635:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800638:	83 eb 01             	sub    $0x1,%ebx
  80063b:	eb 1a                	jmp    800657 <vprintfmt+0x24b>
  80063d:	89 75 08             	mov    %esi,0x8(%ebp)
  800640:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800643:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800646:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800649:	eb 0c                	jmp    800657 <vprintfmt+0x24b>
  80064b:	89 75 08             	mov    %esi,0x8(%ebp)
  80064e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800651:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800654:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800657:	83 c7 01             	add    $0x1,%edi
  80065a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80065e:	0f be d0             	movsbl %al,%edx
  800661:	85 d2                	test   %edx,%edx
  800663:	74 23                	je     800688 <vprintfmt+0x27c>
  800665:	85 f6                	test   %esi,%esi
  800667:	78 a1                	js     80060a <vprintfmt+0x1fe>
  800669:	83 ee 01             	sub    $0x1,%esi
  80066c:	79 9c                	jns    80060a <vprintfmt+0x1fe>
  80066e:	89 df                	mov    %ebx,%edi
  800670:	8b 75 08             	mov    0x8(%ebp),%esi
  800673:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800676:	eb 18                	jmp    800690 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800678:	83 ec 08             	sub    $0x8,%esp
  80067b:	53                   	push   %ebx
  80067c:	6a 20                	push   $0x20
  80067e:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800680:	83 ef 01             	sub    $0x1,%edi
  800683:	83 c4 10             	add    $0x10,%esp
  800686:	eb 08                	jmp    800690 <vprintfmt+0x284>
  800688:	89 df                	mov    %ebx,%edi
  80068a:	8b 75 08             	mov    0x8(%ebp),%esi
  80068d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800690:	85 ff                	test   %edi,%edi
  800692:	7f e4                	jg     800678 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800694:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800697:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80069a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80069d:	e9 90 fd ff ff       	jmp    800432 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006a2:	83 f9 01             	cmp    $0x1,%ecx
  8006a5:	7e 19                	jle    8006c0 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8006a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006aa:	8b 50 04             	mov    0x4(%eax),%edx
  8006ad:	8b 00                	mov    (%eax),%eax
  8006af:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006b2:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b8:	8d 40 08             	lea    0x8(%eax),%eax
  8006bb:	89 45 14             	mov    %eax,0x14(%ebp)
  8006be:	eb 38                	jmp    8006f8 <vprintfmt+0x2ec>
	else if (lflag)
  8006c0:	85 c9                	test   %ecx,%ecx
  8006c2:	74 1b                	je     8006df <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8006c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c7:	8b 00                	mov    (%eax),%eax
  8006c9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006cc:	89 c1                	mov    %eax,%ecx
  8006ce:	c1 f9 1f             	sar    $0x1f,%ecx
  8006d1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d7:	8d 40 04             	lea    0x4(%eax),%eax
  8006da:	89 45 14             	mov    %eax,0x14(%ebp)
  8006dd:	eb 19                	jmp    8006f8 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8006df:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e2:	8b 00                	mov    (%eax),%eax
  8006e4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006e7:	89 c1                	mov    %eax,%ecx
  8006e9:	c1 f9 1f             	sar    $0x1f,%ecx
  8006ec:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f2:	8d 40 04             	lea    0x4(%eax),%eax
  8006f5:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006f8:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006fb:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006fe:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800703:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800707:	0f 89 36 01 00 00    	jns    800843 <vprintfmt+0x437>
				putch('-', putdat);
  80070d:	83 ec 08             	sub    $0x8,%esp
  800710:	53                   	push   %ebx
  800711:	6a 2d                	push   $0x2d
  800713:	ff d6                	call   *%esi
				num = -(long long) num;
  800715:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800718:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80071b:	f7 da                	neg    %edx
  80071d:	83 d1 00             	adc    $0x0,%ecx
  800720:	f7 d9                	neg    %ecx
  800722:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800725:	b8 0a 00 00 00       	mov    $0xa,%eax
  80072a:	e9 14 01 00 00       	jmp    800843 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80072f:	83 f9 01             	cmp    $0x1,%ecx
  800732:	7e 18                	jle    80074c <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800734:	8b 45 14             	mov    0x14(%ebp),%eax
  800737:	8b 10                	mov    (%eax),%edx
  800739:	8b 48 04             	mov    0x4(%eax),%ecx
  80073c:	8d 40 08             	lea    0x8(%eax),%eax
  80073f:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800742:	b8 0a 00 00 00       	mov    $0xa,%eax
  800747:	e9 f7 00 00 00       	jmp    800843 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80074c:	85 c9                	test   %ecx,%ecx
  80074e:	74 1a                	je     80076a <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  800750:	8b 45 14             	mov    0x14(%ebp),%eax
  800753:	8b 10                	mov    (%eax),%edx
  800755:	b9 00 00 00 00       	mov    $0x0,%ecx
  80075a:	8d 40 04             	lea    0x4(%eax),%eax
  80075d:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800760:	b8 0a 00 00 00       	mov    $0xa,%eax
  800765:	e9 d9 00 00 00       	jmp    800843 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80076a:	8b 45 14             	mov    0x14(%ebp),%eax
  80076d:	8b 10                	mov    (%eax),%edx
  80076f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800774:	8d 40 04             	lea    0x4(%eax),%eax
  800777:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80077a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80077f:	e9 bf 00 00 00       	jmp    800843 <vprintfmt+0x437>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800784:	83 f9 01             	cmp    $0x1,%ecx
  800787:	7e 13                	jle    80079c <vprintfmt+0x390>
		return va_arg(*ap, long long);
  800789:	8b 45 14             	mov    0x14(%ebp),%eax
  80078c:	8b 50 04             	mov    0x4(%eax),%edx
  80078f:	8b 00                	mov    (%eax),%eax
  800791:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800794:	8d 49 08             	lea    0x8(%ecx),%ecx
  800797:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80079a:	eb 28                	jmp    8007c4 <vprintfmt+0x3b8>
	else if (lflag)
  80079c:	85 c9                	test   %ecx,%ecx
  80079e:	74 13                	je     8007b3 <vprintfmt+0x3a7>
		return va_arg(*ap, long);
  8007a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a3:	8b 10                	mov    (%eax),%edx
  8007a5:	89 d0                	mov    %edx,%eax
  8007a7:	99                   	cltd   
  8007a8:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8007ab:	8d 49 04             	lea    0x4(%ecx),%ecx
  8007ae:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8007b1:	eb 11                	jmp    8007c4 <vprintfmt+0x3b8>
	else
		return va_arg(*ap, int);
  8007b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b6:	8b 10                	mov    (%eax),%edx
  8007b8:	89 d0                	mov    %edx,%eax
  8007ba:	99                   	cltd   
  8007bb:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8007be:	8d 49 04             	lea    0x4(%ecx),%ecx
  8007c1:	89 4d 14             	mov    %ecx,0x14(%ebp)
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getint(&ap, lflag);
  8007c4:	89 d1                	mov    %edx,%ecx
  8007c6:	89 c2                	mov    %eax,%edx
			base = 8;
  8007c8:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8007cd:	eb 74                	jmp    800843 <vprintfmt+0x437>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8007cf:	83 ec 08             	sub    $0x8,%esp
  8007d2:	53                   	push   %ebx
  8007d3:	6a 30                	push   $0x30
  8007d5:	ff d6                	call   *%esi
			putch('x', putdat);
  8007d7:	83 c4 08             	add    $0x8,%esp
  8007da:	53                   	push   %ebx
  8007db:	6a 78                	push   $0x78
  8007dd:	ff d6                	call   *%esi
			num = (unsigned long long)
  8007df:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e2:	8b 10                	mov    (%eax),%edx
  8007e4:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007e9:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007ec:	8d 40 04             	lea    0x4(%eax),%eax
  8007ef:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007f2:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8007f7:	eb 4a                	jmp    800843 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007f9:	83 f9 01             	cmp    $0x1,%ecx
  8007fc:	7e 15                	jle    800813 <vprintfmt+0x407>
		return va_arg(*ap, unsigned long long);
  8007fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800801:	8b 10                	mov    (%eax),%edx
  800803:	8b 48 04             	mov    0x4(%eax),%ecx
  800806:	8d 40 08             	lea    0x8(%eax),%eax
  800809:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80080c:	b8 10 00 00 00       	mov    $0x10,%eax
  800811:	eb 30                	jmp    800843 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800813:	85 c9                	test   %ecx,%ecx
  800815:	74 17                	je     80082e <vprintfmt+0x422>
		return va_arg(*ap, unsigned long);
  800817:	8b 45 14             	mov    0x14(%ebp),%eax
  80081a:	8b 10                	mov    (%eax),%edx
  80081c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800821:	8d 40 04             	lea    0x4(%eax),%eax
  800824:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800827:	b8 10 00 00 00       	mov    $0x10,%eax
  80082c:	eb 15                	jmp    800843 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80082e:	8b 45 14             	mov    0x14(%ebp),%eax
  800831:	8b 10                	mov    (%eax),%edx
  800833:	b9 00 00 00 00       	mov    $0x0,%ecx
  800838:	8d 40 04             	lea    0x4(%eax),%eax
  80083b:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80083e:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800843:	83 ec 0c             	sub    $0xc,%esp
  800846:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80084a:	57                   	push   %edi
  80084b:	ff 75 e0             	pushl  -0x20(%ebp)
  80084e:	50                   	push   %eax
  80084f:	51                   	push   %ecx
  800850:	52                   	push   %edx
  800851:	89 da                	mov    %ebx,%edx
  800853:	89 f0                	mov    %esi,%eax
  800855:	e8 c9 fa ff ff       	call   800323 <printnum>
			break;
  80085a:	83 c4 20             	add    $0x20,%esp
  80085d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800860:	e9 cd fb ff ff       	jmp    800432 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800865:	83 ec 08             	sub    $0x8,%esp
  800868:	53                   	push   %ebx
  800869:	52                   	push   %edx
  80086a:	ff d6                	call   *%esi
			break;
  80086c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80086f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800872:	e9 bb fb ff ff       	jmp    800432 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800877:	83 ec 08             	sub    $0x8,%esp
  80087a:	53                   	push   %ebx
  80087b:	6a 25                	push   $0x25
  80087d:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80087f:	83 c4 10             	add    $0x10,%esp
  800882:	eb 03                	jmp    800887 <vprintfmt+0x47b>
  800884:	83 ef 01             	sub    $0x1,%edi
  800887:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80088b:	75 f7                	jne    800884 <vprintfmt+0x478>
  80088d:	e9 a0 fb ff ff       	jmp    800432 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800892:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800895:	5b                   	pop    %ebx
  800896:	5e                   	pop    %esi
  800897:	5f                   	pop    %edi
  800898:	5d                   	pop    %ebp
  800899:	c3                   	ret    

0080089a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80089a:	55                   	push   %ebp
  80089b:	89 e5                	mov    %esp,%ebp
  80089d:	83 ec 18             	sub    $0x18,%esp
  8008a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008a6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008a9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008ad:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008b0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008b7:	85 c0                	test   %eax,%eax
  8008b9:	74 26                	je     8008e1 <vsnprintf+0x47>
  8008bb:	85 d2                	test   %edx,%edx
  8008bd:	7e 22                	jle    8008e1 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008bf:	ff 75 14             	pushl  0x14(%ebp)
  8008c2:	ff 75 10             	pushl  0x10(%ebp)
  8008c5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008c8:	50                   	push   %eax
  8008c9:	68 d2 03 80 00       	push   $0x8003d2
  8008ce:	e8 39 fb ff ff       	call   80040c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008d3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008d6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008dc:	83 c4 10             	add    $0x10,%esp
  8008df:	eb 05                	jmp    8008e6 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008e1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008e6:	c9                   	leave  
  8008e7:	c3                   	ret    

008008e8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008e8:	55                   	push   %ebp
  8008e9:	89 e5                	mov    %esp,%ebp
  8008eb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008ee:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008f1:	50                   	push   %eax
  8008f2:	ff 75 10             	pushl  0x10(%ebp)
  8008f5:	ff 75 0c             	pushl  0xc(%ebp)
  8008f8:	ff 75 08             	pushl  0x8(%ebp)
  8008fb:	e8 9a ff ff ff       	call   80089a <vsnprintf>
	va_end(ap);

	return rc;
}
  800900:	c9                   	leave  
  800901:	c3                   	ret    

00800902 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800902:	55                   	push   %ebp
  800903:	89 e5                	mov    %esp,%ebp
  800905:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800908:	b8 00 00 00 00       	mov    $0x0,%eax
  80090d:	eb 03                	jmp    800912 <strlen+0x10>
		n++;
  80090f:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800912:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800916:	75 f7                	jne    80090f <strlen+0xd>
		n++;
	return n;
}
  800918:	5d                   	pop    %ebp
  800919:	c3                   	ret    

0080091a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80091a:	55                   	push   %ebp
  80091b:	89 e5                	mov    %esp,%ebp
  80091d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800920:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800923:	ba 00 00 00 00       	mov    $0x0,%edx
  800928:	eb 03                	jmp    80092d <strnlen+0x13>
		n++;
  80092a:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80092d:	39 c2                	cmp    %eax,%edx
  80092f:	74 08                	je     800939 <strnlen+0x1f>
  800931:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800935:	75 f3                	jne    80092a <strnlen+0x10>
  800937:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800939:	5d                   	pop    %ebp
  80093a:	c3                   	ret    

0080093b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80093b:	55                   	push   %ebp
  80093c:	89 e5                	mov    %esp,%ebp
  80093e:	53                   	push   %ebx
  80093f:	8b 45 08             	mov    0x8(%ebp),%eax
  800942:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800945:	89 c2                	mov    %eax,%edx
  800947:	83 c2 01             	add    $0x1,%edx
  80094a:	83 c1 01             	add    $0x1,%ecx
  80094d:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800951:	88 5a ff             	mov    %bl,-0x1(%edx)
  800954:	84 db                	test   %bl,%bl
  800956:	75 ef                	jne    800947 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800958:	5b                   	pop    %ebx
  800959:	5d                   	pop    %ebp
  80095a:	c3                   	ret    

0080095b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80095b:	55                   	push   %ebp
  80095c:	89 e5                	mov    %esp,%ebp
  80095e:	53                   	push   %ebx
  80095f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800962:	53                   	push   %ebx
  800963:	e8 9a ff ff ff       	call   800902 <strlen>
  800968:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80096b:	ff 75 0c             	pushl  0xc(%ebp)
  80096e:	01 d8                	add    %ebx,%eax
  800970:	50                   	push   %eax
  800971:	e8 c5 ff ff ff       	call   80093b <strcpy>
	return dst;
}
  800976:	89 d8                	mov    %ebx,%eax
  800978:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80097b:	c9                   	leave  
  80097c:	c3                   	ret    

0080097d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80097d:	55                   	push   %ebp
  80097e:	89 e5                	mov    %esp,%ebp
  800980:	56                   	push   %esi
  800981:	53                   	push   %ebx
  800982:	8b 75 08             	mov    0x8(%ebp),%esi
  800985:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800988:	89 f3                	mov    %esi,%ebx
  80098a:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80098d:	89 f2                	mov    %esi,%edx
  80098f:	eb 0f                	jmp    8009a0 <strncpy+0x23>
		*dst++ = *src;
  800991:	83 c2 01             	add    $0x1,%edx
  800994:	0f b6 01             	movzbl (%ecx),%eax
  800997:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80099a:	80 39 01             	cmpb   $0x1,(%ecx)
  80099d:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009a0:	39 da                	cmp    %ebx,%edx
  8009a2:	75 ed                	jne    800991 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009a4:	89 f0                	mov    %esi,%eax
  8009a6:	5b                   	pop    %ebx
  8009a7:	5e                   	pop    %esi
  8009a8:	5d                   	pop    %ebp
  8009a9:	c3                   	ret    

008009aa <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009aa:	55                   	push   %ebp
  8009ab:	89 e5                	mov    %esp,%ebp
  8009ad:	56                   	push   %esi
  8009ae:	53                   	push   %ebx
  8009af:	8b 75 08             	mov    0x8(%ebp),%esi
  8009b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009b5:	8b 55 10             	mov    0x10(%ebp),%edx
  8009b8:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009ba:	85 d2                	test   %edx,%edx
  8009bc:	74 21                	je     8009df <strlcpy+0x35>
  8009be:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8009c2:	89 f2                	mov    %esi,%edx
  8009c4:	eb 09                	jmp    8009cf <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009c6:	83 c2 01             	add    $0x1,%edx
  8009c9:	83 c1 01             	add    $0x1,%ecx
  8009cc:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009cf:	39 c2                	cmp    %eax,%edx
  8009d1:	74 09                	je     8009dc <strlcpy+0x32>
  8009d3:	0f b6 19             	movzbl (%ecx),%ebx
  8009d6:	84 db                	test   %bl,%bl
  8009d8:	75 ec                	jne    8009c6 <strlcpy+0x1c>
  8009da:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8009dc:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009df:	29 f0                	sub    %esi,%eax
}
  8009e1:	5b                   	pop    %ebx
  8009e2:	5e                   	pop    %esi
  8009e3:	5d                   	pop    %ebp
  8009e4:	c3                   	ret    

008009e5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009e5:	55                   	push   %ebp
  8009e6:	89 e5                	mov    %esp,%ebp
  8009e8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009eb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009ee:	eb 06                	jmp    8009f6 <strcmp+0x11>
		p++, q++;
  8009f0:	83 c1 01             	add    $0x1,%ecx
  8009f3:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009f6:	0f b6 01             	movzbl (%ecx),%eax
  8009f9:	84 c0                	test   %al,%al
  8009fb:	74 04                	je     800a01 <strcmp+0x1c>
  8009fd:	3a 02                	cmp    (%edx),%al
  8009ff:	74 ef                	je     8009f0 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a01:	0f b6 c0             	movzbl %al,%eax
  800a04:	0f b6 12             	movzbl (%edx),%edx
  800a07:	29 d0                	sub    %edx,%eax
}
  800a09:	5d                   	pop    %ebp
  800a0a:	c3                   	ret    

00800a0b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a0b:	55                   	push   %ebp
  800a0c:	89 e5                	mov    %esp,%ebp
  800a0e:	53                   	push   %ebx
  800a0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a12:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a15:	89 c3                	mov    %eax,%ebx
  800a17:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a1a:	eb 06                	jmp    800a22 <strncmp+0x17>
		n--, p++, q++;
  800a1c:	83 c0 01             	add    $0x1,%eax
  800a1f:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a22:	39 d8                	cmp    %ebx,%eax
  800a24:	74 15                	je     800a3b <strncmp+0x30>
  800a26:	0f b6 08             	movzbl (%eax),%ecx
  800a29:	84 c9                	test   %cl,%cl
  800a2b:	74 04                	je     800a31 <strncmp+0x26>
  800a2d:	3a 0a                	cmp    (%edx),%cl
  800a2f:	74 eb                	je     800a1c <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a31:	0f b6 00             	movzbl (%eax),%eax
  800a34:	0f b6 12             	movzbl (%edx),%edx
  800a37:	29 d0                	sub    %edx,%eax
  800a39:	eb 05                	jmp    800a40 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a3b:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a40:	5b                   	pop    %ebx
  800a41:	5d                   	pop    %ebp
  800a42:	c3                   	ret    

00800a43 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a43:	55                   	push   %ebp
  800a44:	89 e5                	mov    %esp,%ebp
  800a46:	8b 45 08             	mov    0x8(%ebp),%eax
  800a49:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a4d:	eb 07                	jmp    800a56 <strchr+0x13>
		if (*s == c)
  800a4f:	38 ca                	cmp    %cl,%dl
  800a51:	74 0f                	je     800a62 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a53:	83 c0 01             	add    $0x1,%eax
  800a56:	0f b6 10             	movzbl (%eax),%edx
  800a59:	84 d2                	test   %dl,%dl
  800a5b:	75 f2                	jne    800a4f <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a5d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a62:	5d                   	pop    %ebp
  800a63:	c3                   	ret    

00800a64 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a64:	55                   	push   %ebp
  800a65:	89 e5                	mov    %esp,%ebp
  800a67:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a6e:	eb 03                	jmp    800a73 <strfind+0xf>
  800a70:	83 c0 01             	add    $0x1,%eax
  800a73:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a76:	38 ca                	cmp    %cl,%dl
  800a78:	74 04                	je     800a7e <strfind+0x1a>
  800a7a:	84 d2                	test   %dl,%dl
  800a7c:	75 f2                	jne    800a70 <strfind+0xc>
			break;
	return (char *) s;
}
  800a7e:	5d                   	pop    %ebp
  800a7f:	c3                   	ret    

00800a80 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a80:	55                   	push   %ebp
  800a81:	89 e5                	mov    %esp,%ebp
  800a83:	57                   	push   %edi
  800a84:	56                   	push   %esi
  800a85:	53                   	push   %ebx
  800a86:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a89:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a8c:	85 c9                	test   %ecx,%ecx
  800a8e:	74 36                	je     800ac6 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a90:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a96:	75 28                	jne    800ac0 <memset+0x40>
  800a98:	f6 c1 03             	test   $0x3,%cl
  800a9b:	75 23                	jne    800ac0 <memset+0x40>
		c &= 0xFF;
  800a9d:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800aa1:	89 d3                	mov    %edx,%ebx
  800aa3:	c1 e3 08             	shl    $0x8,%ebx
  800aa6:	89 d6                	mov    %edx,%esi
  800aa8:	c1 e6 18             	shl    $0x18,%esi
  800aab:	89 d0                	mov    %edx,%eax
  800aad:	c1 e0 10             	shl    $0x10,%eax
  800ab0:	09 f0                	or     %esi,%eax
  800ab2:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800ab4:	89 d8                	mov    %ebx,%eax
  800ab6:	09 d0                	or     %edx,%eax
  800ab8:	c1 e9 02             	shr    $0x2,%ecx
  800abb:	fc                   	cld    
  800abc:	f3 ab                	rep stos %eax,%es:(%edi)
  800abe:	eb 06                	jmp    800ac6 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ac0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac3:	fc                   	cld    
  800ac4:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ac6:	89 f8                	mov    %edi,%eax
  800ac8:	5b                   	pop    %ebx
  800ac9:	5e                   	pop    %esi
  800aca:	5f                   	pop    %edi
  800acb:	5d                   	pop    %ebp
  800acc:	c3                   	ret    

00800acd <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800acd:	55                   	push   %ebp
  800ace:	89 e5                	mov    %esp,%ebp
  800ad0:	57                   	push   %edi
  800ad1:	56                   	push   %esi
  800ad2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ad8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800adb:	39 c6                	cmp    %eax,%esi
  800add:	73 35                	jae    800b14 <memmove+0x47>
  800adf:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ae2:	39 d0                	cmp    %edx,%eax
  800ae4:	73 2e                	jae    800b14 <memmove+0x47>
		s += n;
		d += n;
  800ae6:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ae9:	89 d6                	mov    %edx,%esi
  800aeb:	09 fe                	or     %edi,%esi
  800aed:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800af3:	75 13                	jne    800b08 <memmove+0x3b>
  800af5:	f6 c1 03             	test   $0x3,%cl
  800af8:	75 0e                	jne    800b08 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800afa:	83 ef 04             	sub    $0x4,%edi
  800afd:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b00:	c1 e9 02             	shr    $0x2,%ecx
  800b03:	fd                   	std    
  800b04:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b06:	eb 09                	jmp    800b11 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b08:	83 ef 01             	sub    $0x1,%edi
  800b0b:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b0e:	fd                   	std    
  800b0f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b11:	fc                   	cld    
  800b12:	eb 1d                	jmp    800b31 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b14:	89 f2                	mov    %esi,%edx
  800b16:	09 c2                	or     %eax,%edx
  800b18:	f6 c2 03             	test   $0x3,%dl
  800b1b:	75 0f                	jne    800b2c <memmove+0x5f>
  800b1d:	f6 c1 03             	test   $0x3,%cl
  800b20:	75 0a                	jne    800b2c <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b22:	c1 e9 02             	shr    $0x2,%ecx
  800b25:	89 c7                	mov    %eax,%edi
  800b27:	fc                   	cld    
  800b28:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b2a:	eb 05                	jmp    800b31 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b2c:	89 c7                	mov    %eax,%edi
  800b2e:	fc                   	cld    
  800b2f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b31:	5e                   	pop    %esi
  800b32:	5f                   	pop    %edi
  800b33:	5d                   	pop    %ebp
  800b34:	c3                   	ret    

00800b35 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b35:	55                   	push   %ebp
  800b36:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b38:	ff 75 10             	pushl  0x10(%ebp)
  800b3b:	ff 75 0c             	pushl  0xc(%ebp)
  800b3e:	ff 75 08             	pushl  0x8(%ebp)
  800b41:	e8 87 ff ff ff       	call   800acd <memmove>
}
  800b46:	c9                   	leave  
  800b47:	c3                   	ret    

00800b48 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b48:	55                   	push   %ebp
  800b49:	89 e5                	mov    %esp,%ebp
  800b4b:	56                   	push   %esi
  800b4c:	53                   	push   %ebx
  800b4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b50:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b53:	89 c6                	mov    %eax,%esi
  800b55:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b58:	eb 1a                	jmp    800b74 <memcmp+0x2c>
		if (*s1 != *s2)
  800b5a:	0f b6 08             	movzbl (%eax),%ecx
  800b5d:	0f b6 1a             	movzbl (%edx),%ebx
  800b60:	38 d9                	cmp    %bl,%cl
  800b62:	74 0a                	je     800b6e <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b64:	0f b6 c1             	movzbl %cl,%eax
  800b67:	0f b6 db             	movzbl %bl,%ebx
  800b6a:	29 d8                	sub    %ebx,%eax
  800b6c:	eb 0f                	jmp    800b7d <memcmp+0x35>
		s1++, s2++;
  800b6e:	83 c0 01             	add    $0x1,%eax
  800b71:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b74:	39 f0                	cmp    %esi,%eax
  800b76:	75 e2                	jne    800b5a <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b78:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b7d:	5b                   	pop    %ebx
  800b7e:	5e                   	pop    %esi
  800b7f:	5d                   	pop    %ebp
  800b80:	c3                   	ret    

00800b81 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b81:	55                   	push   %ebp
  800b82:	89 e5                	mov    %esp,%ebp
  800b84:	53                   	push   %ebx
  800b85:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b88:	89 c1                	mov    %eax,%ecx
  800b8a:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800b8d:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b91:	eb 0a                	jmp    800b9d <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b93:	0f b6 10             	movzbl (%eax),%edx
  800b96:	39 da                	cmp    %ebx,%edx
  800b98:	74 07                	je     800ba1 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b9a:	83 c0 01             	add    $0x1,%eax
  800b9d:	39 c8                	cmp    %ecx,%eax
  800b9f:	72 f2                	jb     800b93 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ba1:	5b                   	pop    %ebx
  800ba2:	5d                   	pop    %ebp
  800ba3:	c3                   	ret    

00800ba4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ba4:	55                   	push   %ebp
  800ba5:	89 e5                	mov    %esp,%ebp
  800ba7:	57                   	push   %edi
  800ba8:	56                   	push   %esi
  800ba9:	53                   	push   %ebx
  800baa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bad:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bb0:	eb 03                	jmp    800bb5 <strtol+0x11>
		s++;
  800bb2:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bb5:	0f b6 01             	movzbl (%ecx),%eax
  800bb8:	3c 20                	cmp    $0x20,%al
  800bba:	74 f6                	je     800bb2 <strtol+0xe>
  800bbc:	3c 09                	cmp    $0x9,%al
  800bbe:	74 f2                	je     800bb2 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bc0:	3c 2b                	cmp    $0x2b,%al
  800bc2:	75 0a                	jne    800bce <strtol+0x2a>
		s++;
  800bc4:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bc7:	bf 00 00 00 00       	mov    $0x0,%edi
  800bcc:	eb 11                	jmp    800bdf <strtol+0x3b>
  800bce:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800bd3:	3c 2d                	cmp    $0x2d,%al
  800bd5:	75 08                	jne    800bdf <strtol+0x3b>
		s++, neg = 1;
  800bd7:	83 c1 01             	add    $0x1,%ecx
  800bda:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bdf:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800be5:	75 15                	jne    800bfc <strtol+0x58>
  800be7:	80 39 30             	cmpb   $0x30,(%ecx)
  800bea:	75 10                	jne    800bfc <strtol+0x58>
  800bec:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bf0:	75 7c                	jne    800c6e <strtol+0xca>
		s += 2, base = 16;
  800bf2:	83 c1 02             	add    $0x2,%ecx
  800bf5:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bfa:	eb 16                	jmp    800c12 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800bfc:	85 db                	test   %ebx,%ebx
  800bfe:	75 12                	jne    800c12 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c00:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c05:	80 39 30             	cmpb   $0x30,(%ecx)
  800c08:	75 08                	jne    800c12 <strtol+0x6e>
		s++, base = 8;
  800c0a:	83 c1 01             	add    $0x1,%ecx
  800c0d:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c12:	b8 00 00 00 00       	mov    $0x0,%eax
  800c17:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c1a:	0f b6 11             	movzbl (%ecx),%edx
  800c1d:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c20:	89 f3                	mov    %esi,%ebx
  800c22:	80 fb 09             	cmp    $0x9,%bl
  800c25:	77 08                	ja     800c2f <strtol+0x8b>
			dig = *s - '0';
  800c27:	0f be d2             	movsbl %dl,%edx
  800c2a:	83 ea 30             	sub    $0x30,%edx
  800c2d:	eb 22                	jmp    800c51 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c2f:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c32:	89 f3                	mov    %esi,%ebx
  800c34:	80 fb 19             	cmp    $0x19,%bl
  800c37:	77 08                	ja     800c41 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800c39:	0f be d2             	movsbl %dl,%edx
  800c3c:	83 ea 57             	sub    $0x57,%edx
  800c3f:	eb 10                	jmp    800c51 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800c41:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c44:	89 f3                	mov    %esi,%ebx
  800c46:	80 fb 19             	cmp    $0x19,%bl
  800c49:	77 16                	ja     800c61 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c4b:	0f be d2             	movsbl %dl,%edx
  800c4e:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c51:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c54:	7d 0b                	jge    800c61 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800c56:	83 c1 01             	add    $0x1,%ecx
  800c59:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c5d:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c5f:	eb b9                	jmp    800c1a <strtol+0x76>

	if (endptr)
  800c61:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c65:	74 0d                	je     800c74 <strtol+0xd0>
		*endptr = (char *) s;
  800c67:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c6a:	89 0e                	mov    %ecx,(%esi)
  800c6c:	eb 06                	jmp    800c74 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c6e:	85 db                	test   %ebx,%ebx
  800c70:	74 98                	je     800c0a <strtol+0x66>
  800c72:	eb 9e                	jmp    800c12 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800c74:	89 c2                	mov    %eax,%edx
  800c76:	f7 da                	neg    %edx
  800c78:	85 ff                	test   %edi,%edi
  800c7a:	0f 45 c2             	cmovne %edx,%eax
}
  800c7d:	5b                   	pop    %ebx
  800c7e:	5e                   	pop    %esi
  800c7f:	5f                   	pop    %edi
  800c80:	5d                   	pop    %ebp
  800c81:	c3                   	ret    

00800c82 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c82:	55                   	push   %ebp
  800c83:	89 e5                	mov    %esp,%ebp
  800c85:	57                   	push   %edi
  800c86:	56                   	push   %esi
  800c87:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c88:	b8 00 00 00 00       	mov    $0x0,%eax
  800c8d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c90:	8b 55 08             	mov    0x8(%ebp),%edx
  800c93:	89 c3                	mov    %eax,%ebx
  800c95:	89 c7                	mov    %eax,%edi
  800c97:	89 c6                	mov    %eax,%esi
  800c99:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c9b:	5b                   	pop    %ebx
  800c9c:	5e                   	pop    %esi
  800c9d:	5f                   	pop    %edi
  800c9e:	5d                   	pop    %ebp
  800c9f:	c3                   	ret    

00800ca0 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ca0:	55                   	push   %ebp
  800ca1:	89 e5                	mov    %esp,%ebp
  800ca3:	57                   	push   %edi
  800ca4:	56                   	push   %esi
  800ca5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca6:	ba 00 00 00 00       	mov    $0x0,%edx
  800cab:	b8 01 00 00 00       	mov    $0x1,%eax
  800cb0:	89 d1                	mov    %edx,%ecx
  800cb2:	89 d3                	mov    %edx,%ebx
  800cb4:	89 d7                	mov    %edx,%edi
  800cb6:	89 d6                	mov    %edx,%esi
  800cb8:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cba:	5b                   	pop    %ebx
  800cbb:	5e                   	pop    %esi
  800cbc:	5f                   	pop    %edi
  800cbd:	5d                   	pop    %ebp
  800cbe:	c3                   	ret    

00800cbf <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cbf:	55                   	push   %ebp
  800cc0:	89 e5                	mov    %esp,%ebp
  800cc2:	57                   	push   %edi
  800cc3:	56                   	push   %esi
  800cc4:	53                   	push   %ebx
  800cc5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ccd:	b8 03 00 00 00       	mov    $0x3,%eax
  800cd2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd5:	89 cb                	mov    %ecx,%ebx
  800cd7:	89 cf                	mov    %ecx,%edi
  800cd9:	89 ce                	mov    %ecx,%esi
  800cdb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cdd:	85 c0                	test   %eax,%eax
  800cdf:	7e 17                	jle    800cf8 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce1:	83 ec 0c             	sub    $0xc,%esp
  800ce4:	50                   	push   %eax
  800ce5:	6a 03                	push   $0x3
  800ce7:	68 3f 27 80 00       	push   $0x80273f
  800cec:	6a 23                	push   $0x23
  800cee:	68 5c 27 80 00       	push   $0x80275c
  800cf3:	e8 3e f5 ff ff       	call   800236 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cf8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfb:	5b                   	pop    %ebx
  800cfc:	5e                   	pop    %esi
  800cfd:	5f                   	pop    %edi
  800cfe:	5d                   	pop    %ebp
  800cff:	c3                   	ret    

00800d00 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d00:	55                   	push   %ebp
  800d01:	89 e5                	mov    %esp,%ebp
  800d03:	57                   	push   %edi
  800d04:	56                   	push   %esi
  800d05:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d06:	ba 00 00 00 00       	mov    $0x0,%edx
  800d0b:	b8 02 00 00 00       	mov    $0x2,%eax
  800d10:	89 d1                	mov    %edx,%ecx
  800d12:	89 d3                	mov    %edx,%ebx
  800d14:	89 d7                	mov    %edx,%edi
  800d16:	89 d6                	mov    %edx,%esi
  800d18:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d1a:	5b                   	pop    %ebx
  800d1b:	5e                   	pop    %esi
  800d1c:	5f                   	pop    %edi
  800d1d:	5d                   	pop    %ebp
  800d1e:	c3                   	ret    

00800d1f <sys_yield>:

void
sys_yield(void)
{
  800d1f:	55                   	push   %ebp
  800d20:	89 e5                	mov    %esp,%ebp
  800d22:	57                   	push   %edi
  800d23:	56                   	push   %esi
  800d24:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d25:	ba 00 00 00 00       	mov    $0x0,%edx
  800d2a:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d2f:	89 d1                	mov    %edx,%ecx
  800d31:	89 d3                	mov    %edx,%ebx
  800d33:	89 d7                	mov    %edx,%edi
  800d35:	89 d6                	mov    %edx,%esi
  800d37:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d39:	5b                   	pop    %ebx
  800d3a:	5e                   	pop    %esi
  800d3b:	5f                   	pop    %edi
  800d3c:	5d                   	pop    %ebp
  800d3d:	c3                   	ret    

00800d3e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d3e:	55                   	push   %ebp
  800d3f:	89 e5                	mov    %esp,%ebp
  800d41:	57                   	push   %edi
  800d42:	56                   	push   %esi
  800d43:	53                   	push   %ebx
  800d44:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d47:	be 00 00 00 00       	mov    $0x0,%esi
  800d4c:	b8 04 00 00 00       	mov    $0x4,%eax
  800d51:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d54:	8b 55 08             	mov    0x8(%ebp),%edx
  800d57:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d5a:	89 f7                	mov    %esi,%edi
  800d5c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d5e:	85 c0                	test   %eax,%eax
  800d60:	7e 17                	jle    800d79 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d62:	83 ec 0c             	sub    $0xc,%esp
  800d65:	50                   	push   %eax
  800d66:	6a 04                	push   $0x4
  800d68:	68 3f 27 80 00       	push   $0x80273f
  800d6d:	6a 23                	push   $0x23
  800d6f:	68 5c 27 80 00       	push   $0x80275c
  800d74:	e8 bd f4 ff ff       	call   800236 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d79:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d7c:	5b                   	pop    %ebx
  800d7d:	5e                   	pop    %esi
  800d7e:	5f                   	pop    %edi
  800d7f:	5d                   	pop    %ebp
  800d80:	c3                   	ret    

00800d81 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d81:	55                   	push   %ebp
  800d82:	89 e5                	mov    %esp,%ebp
  800d84:	57                   	push   %edi
  800d85:	56                   	push   %esi
  800d86:	53                   	push   %ebx
  800d87:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8a:	b8 05 00 00 00       	mov    $0x5,%eax
  800d8f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d92:	8b 55 08             	mov    0x8(%ebp),%edx
  800d95:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d98:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d9b:	8b 75 18             	mov    0x18(%ebp),%esi
  800d9e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800da0:	85 c0                	test   %eax,%eax
  800da2:	7e 17                	jle    800dbb <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da4:	83 ec 0c             	sub    $0xc,%esp
  800da7:	50                   	push   %eax
  800da8:	6a 05                	push   $0x5
  800daa:	68 3f 27 80 00       	push   $0x80273f
  800daf:	6a 23                	push   $0x23
  800db1:	68 5c 27 80 00       	push   $0x80275c
  800db6:	e8 7b f4 ff ff       	call   800236 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800dbb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dbe:	5b                   	pop    %ebx
  800dbf:	5e                   	pop    %esi
  800dc0:	5f                   	pop    %edi
  800dc1:	5d                   	pop    %ebp
  800dc2:	c3                   	ret    

00800dc3 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800dc3:	55                   	push   %ebp
  800dc4:	89 e5                	mov    %esp,%ebp
  800dc6:	57                   	push   %edi
  800dc7:	56                   	push   %esi
  800dc8:	53                   	push   %ebx
  800dc9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dcc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dd1:	b8 06 00 00 00       	mov    $0x6,%eax
  800dd6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ddc:	89 df                	mov    %ebx,%edi
  800dde:	89 de                	mov    %ebx,%esi
  800de0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800de2:	85 c0                	test   %eax,%eax
  800de4:	7e 17                	jle    800dfd <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de6:	83 ec 0c             	sub    $0xc,%esp
  800de9:	50                   	push   %eax
  800dea:	6a 06                	push   $0x6
  800dec:	68 3f 27 80 00       	push   $0x80273f
  800df1:	6a 23                	push   $0x23
  800df3:	68 5c 27 80 00       	push   $0x80275c
  800df8:	e8 39 f4 ff ff       	call   800236 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800dfd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e00:	5b                   	pop    %ebx
  800e01:	5e                   	pop    %esi
  800e02:	5f                   	pop    %edi
  800e03:	5d                   	pop    %ebp
  800e04:	c3                   	ret    

00800e05 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e05:	55                   	push   %ebp
  800e06:	89 e5                	mov    %esp,%ebp
  800e08:	57                   	push   %edi
  800e09:	56                   	push   %esi
  800e0a:	53                   	push   %ebx
  800e0b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e13:	b8 08 00 00 00       	mov    $0x8,%eax
  800e18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e1b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1e:	89 df                	mov    %ebx,%edi
  800e20:	89 de                	mov    %ebx,%esi
  800e22:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e24:	85 c0                	test   %eax,%eax
  800e26:	7e 17                	jle    800e3f <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e28:	83 ec 0c             	sub    $0xc,%esp
  800e2b:	50                   	push   %eax
  800e2c:	6a 08                	push   $0x8
  800e2e:	68 3f 27 80 00       	push   $0x80273f
  800e33:	6a 23                	push   $0x23
  800e35:	68 5c 27 80 00       	push   $0x80275c
  800e3a:	e8 f7 f3 ff ff       	call   800236 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e42:	5b                   	pop    %ebx
  800e43:	5e                   	pop    %esi
  800e44:	5f                   	pop    %edi
  800e45:	5d                   	pop    %ebp
  800e46:	c3                   	ret    

00800e47 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e47:	55                   	push   %ebp
  800e48:	89 e5                	mov    %esp,%ebp
  800e4a:	57                   	push   %edi
  800e4b:	56                   	push   %esi
  800e4c:	53                   	push   %ebx
  800e4d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e50:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e55:	b8 09 00 00 00       	mov    $0x9,%eax
  800e5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e60:	89 df                	mov    %ebx,%edi
  800e62:	89 de                	mov    %ebx,%esi
  800e64:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e66:	85 c0                	test   %eax,%eax
  800e68:	7e 17                	jle    800e81 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e6a:	83 ec 0c             	sub    $0xc,%esp
  800e6d:	50                   	push   %eax
  800e6e:	6a 09                	push   $0x9
  800e70:	68 3f 27 80 00       	push   $0x80273f
  800e75:	6a 23                	push   $0x23
  800e77:	68 5c 27 80 00       	push   $0x80275c
  800e7c:	e8 b5 f3 ff ff       	call   800236 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e81:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e84:	5b                   	pop    %ebx
  800e85:	5e                   	pop    %esi
  800e86:	5f                   	pop    %edi
  800e87:	5d                   	pop    %ebp
  800e88:	c3                   	ret    

00800e89 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e89:	55                   	push   %ebp
  800e8a:	89 e5                	mov    %esp,%ebp
  800e8c:	57                   	push   %edi
  800e8d:	56                   	push   %esi
  800e8e:	53                   	push   %ebx
  800e8f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e92:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e97:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e9f:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea2:	89 df                	mov    %ebx,%edi
  800ea4:	89 de                	mov    %ebx,%esi
  800ea6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ea8:	85 c0                	test   %eax,%eax
  800eaa:	7e 17                	jle    800ec3 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eac:	83 ec 0c             	sub    $0xc,%esp
  800eaf:	50                   	push   %eax
  800eb0:	6a 0a                	push   $0xa
  800eb2:	68 3f 27 80 00       	push   $0x80273f
  800eb7:	6a 23                	push   $0x23
  800eb9:	68 5c 27 80 00       	push   $0x80275c
  800ebe:	e8 73 f3 ff ff       	call   800236 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ec3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ec6:	5b                   	pop    %ebx
  800ec7:	5e                   	pop    %esi
  800ec8:	5f                   	pop    %edi
  800ec9:	5d                   	pop    %ebp
  800eca:	c3                   	ret    

00800ecb <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ecb:	55                   	push   %ebp
  800ecc:	89 e5                	mov    %esp,%ebp
  800ece:	57                   	push   %edi
  800ecf:	56                   	push   %esi
  800ed0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed1:	be 00 00 00 00       	mov    $0x0,%esi
  800ed6:	b8 0c 00 00 00       	mov    $0xc,%eax
  800edb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ede:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ee4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ee7:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ee9:	5b                   	pop    %ebx
  800eea:	5e                   	pop    %esi
  800eeb:	5f                   	pop    %edi
  800eec:	5d                   	pop    %ebp
  800eed:	c3                   	ret    

00800eee <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800eee:	55                   	push   %ebp
  800eef:	89 e5                	mov    %esp,%ebp
  800ef1:	57                   	push   %edi
  800ef2:	56                   	push   %esi
  800ef3:	53                   	push   %ebx
  800ef4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ef7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800efc:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f01:	8b 55 08             	mov    0x8(%ebp),%edx
  800f04:	89 cb                	mov    %ecx,%ebx
  800f06:	89 cf                	mov    %ecx,%edi
  800f08:	89 ce                	mov    %ecx,%esi
  800f0a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f0c:	85 c0                	test   %eax,%eax
  800f0e:	7e 17                	jle    800f27 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f10:	83 ec 0c             	sub    $0xc,%esp
  800f13:	50                   	push   %eax
  800f14:	6a 0d                	push   $0xd
  800f16:	68 3f 27 80 00       	push   $0x80273f
  800f1b:	6a 23                	push   $0x23
  800f1d:	68 5c 27 80 00       	push   $0x80275c
  800f22:	e8 0f f3 ff ff       	call   800236 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f27:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f2a:	5b                   	pop    %ebx
  800f2b:	5e                   	pop    %esi
  800f2c:	5f                   	pop    %edi
  800f2d:	5d                   	pop    %ebp
  800f2e:	c3                   	ret    

00800f2f <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f2f:	55                   	push   %ebp
  800f30:	89 e5                	mov    %esp,%ebp
  800f32:	53                   	push   %ebx
  800f33:	83 ec 04             	sub    $0x4,%esp
  800f36:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f39:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & 
  800f3b:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f3f:	0f 84 48 01 00 00    	je     80108d <pgfault+0x15e>
  800f45:	89 d8                	mov    %ebx,%eax
  800f47:	c1 e8 16             	shr    $0x16,%eax
  800f4a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f51:	a8 01                	test   $0x1,%al
  800f53:	0f 84 5f 01 00 00    	je     8010b8 <pgfault+0x189>
  800f59:	89 d8                	mov    %ebx,%eax
  800f5b:	c1 e8 0c             	shr    $0xc,%eax
  800f5e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f65:	f6 c2 01             	test   $0x1,%dl
  800f68:	0f 84 4a 01 00 00    	je     8010b8 <pgfault+0x189>
				PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW))) {
  800f6e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & 
  800f75:	f6 c4 08             	test   $0x8,%ah
  800f78:	75 79                	jne    800ff3 <pgfault+0xc4>
  800f7a:	e9 39 01 00 00       	jmp    8010b8 <pgfault+0x189>
				PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW))) {
		cprintf("Fault address = %08x, envid = %08x\n", addr, thisenv->env_id);
		if (!(err & FEC_WR)) cprintf("Not write\n");
		if (!(uvpd[PDX(addr)] & PTE_P)) cprintf("PDE not present\n");
  800f7f:	89 d8                	mov    %ebx,%eax
  800f81:	c1 e8 16             	shr    $0x16,%eax
  800f84:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f8b:	a8 01                	test   $0x1,%al
  800f8d:	75 10                	jne    800f9f <pgfault+0x70>
  800f8f:	83 ec 0c             	sub    $0xc,%esp
  800f92:	68 6a 27 80 00       	push   $0x80276a
  800f97:	e8 73 f3 ff ff       	call   80030f <cprintf>
  800f9c:	83 c4 10             	add    $0x10,%esp
		if (!(uvpt[PTX(addr)] & PTE_P)) cprintf("PTE not present\n");
  800f9f:	c1 eb 0c             	shr    $0xc,%ebx
  800fa2:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  800fa8:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800faf:	a8 01                	test   $0x1,%al
  800fb1:	75 10                	jne    800fc3 <pgfault+0x94>
  800fb3:	83 ec 0c             	sub    $0xc,%esp
  800fb6:	68 7b 27 80 00       	push   $0x80277b
  800fbb:	e8 4f f3 ff ff       	call   80030f <cprintf>
  800fc0:	83 c4 10             	add    $0x10,%esp
		if (!(uvpt[PTX(addr)] & PTE_COW)) cprintf("Not copy-on-write\n");
  800fc3:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800fca:	f6 c4 08             	test   $0x8,%ah
  800fcd:	75 10                	jne    800fdf <pgfault+0xb0>
  800fcf:	83 ec 0c             	sub    $0xc,%esp
  800fd2:	68 8c 27 80 00       	push   $0x80278c
  800fd7:	e8 33 f3 ff ff       	call   80030f <cprintf>
  800fdc:	83 c4 10             	add    $0x10,%esp
		panic("User page fault");
  800fdf:	83 ec 04             	sub    $0x4,%esp
  800fe2:	68 9f 27 80 00       	push   $0x80279f
  800fe7:	6a 23                	push   $0x23
  800fe9:	68 af 27 80 00       	push   $0x8027af
  800fee:	e8 43 f2 ff ff       	call   800236 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// 0 refers to curenv
	if ((r = sys_page_alloc(0, (void*)PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  800ff3:	83 ec 04             	sub    $0x4,%esp
  800ff6:	6a 07                	push   $0x7
  800ff8:	68 00 f0 7f 00       	push   $0x7ff000
  800ffd:	6a 00                	push   $0x0
  800fff:	e8 3a fd ff ff       	call   800d3e <sys_page_alloc>
  801004:	83 c4 10             	add    $0x10,%esp
  801007:	85 c0                	test   %eax,%eax
  801009:	79 12                	jns    80101d <pgfault+0xee>
		panic("sys_page_alloc failed: %e", r);
  80100b:	50                   	push   %eax
  80100c:	68 ba 27 80 00       	push   $0x8027ba
  801011:	6a 2f                	push   $0x2f
  801013:	68 af 27 80 00       	push   $0x8027af
  801018:	e8 19 f2 ff ff       	call   800236 <_panic>
	memcpy((void*)PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  80101d:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  801023:	83 ec 04             	sub    $0x4,%esp
  801026:	68 00 10 00 00       	push   $0x1000
  80102b:	53                   	push   %ebx
  80102c:	68 00 f0 7f 00       	push   $0x7ff000
  801031:	e8 ff fa ff ff       	call   800b35 <memcpy>
	if ((r = sys_page_map(0, (void*)PFTEMP, 0, (void*)ROUNDDOWN(addr, PGSIZE), 
  801036:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  80103d:	53                   	push   %ebx
  80103e:	6a 00                	push   $0x0
  801040:	68 00 f0 7f 00       	push   $0x7ff000
  801045:	6a 00                	push   $0x0
  801047:	e8 35 fd ff ff       	call   800d81 <sys_page_map>
  80104c:	83 c4 20             	add    $0x20,%esp
  80104f:	85 c0                	test   %eax,%eax
  801051:	79 12                	jns    801065 <pgfault+0x136>
					PTE_P | PTE_U | PTE_W)) < 0)
		panic("sys_page_map failed: %e", r);
  801053:	50                   	push   %eax
  801054:	68 d4 27 80 00       	push   $0x8027d4
  801059:	6a 33                	push   $0x33
  80105b:	68 af 27 80 00       	push   $0x8027af
  801060:	e8 d1 f1 ff ff       	call   800236 <_panic>
	if ((r = sys_page_unmap(0, (void*)PFTEMP)) < 0)
  801065:	83 ec 08             	sub    $0x8,%esp
  801068:	68 00 f0 7f 00       	push   $0x7ff000
  80106d:	6a 00                	push   $0x0
  80106f:	e8 4f fd ff ff       	call   800dc3 <sys_page_unmap>
  801074:	83 c4 10             	add    $0x10,%esp
  801077:	85 c0                	test   %eax,%eax
  801079:	79 5c                	jns    8010d7 <pgfault+0x1a8>
		panic("sys_page_unmap failed: %e", r);
  80107b:	50                   	push   %eax
  80107c:	68 ec 27 80 00       	push   $0x8027ec
  801081:	6a 35                	push   $0x35
  801083:	68 af 27 80 00       	push   $0x8027af
  801088:	e8 a9 f1 ff ff       	call   800236 <_panic>
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & 
				PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW))) {
		cprintf("Fault address = %08x, envid = %08x\n", addr, thisenv->env_id);
  80108d:	a1 04 40 80 00       	mov    0x804004,%eax
  801092:	8b 40 48             	mov    0x48(%eax),%eax
  801095:	83 ec 04             	sub    $0x4,%esp
  801098:	50                   	push   %eax
  801099:	53                   	push   %ebx
  80109a:	68 28 28 80 00       	push   $0x802828
  80109f:	e8 6b f2 ff ff       	call   80030f <cprintf>
		if (!(err & FEC_WR)) cprintf("Not write\n");
  8010a4:	c7 04 24 06 28 80 00 	movl   $0x802806,(%esp)
  8010ab:	e8 5f f2 ff ff       	call   80030f <cprintf>
  8010b0:	83 c4 10             	add    $0x10,%esp
  8010b3:	e9 c7 fe ff ff       	jmp    800f7f <pgfault+0x50>
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & 
				PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW))) {
		cprintf("Fault address = %08x, envid = %08x\n", addr, thisenv->env_id);
  8010b8:	a1 04 40 80 00       	mov    0x804004,%eax
  8010bd:	8b 40 48             	mov    0x48(%eax),%eax
  8010c0:	83 ec 04             	sub    $0x4,%esp
  8010c3:	50                   	push   %eax
  8010c4:	53                   	push   %ebx
  8010c5:	68 28 28 80 00       	push   $0x802828
  8010ca:	e8 40 f2 ff ff       	call   80030f <cprintf>
  8010cf:	83 c4 10             	add    $0x10,%esp
  8010d2:	e9 a8 fe ff ff       	jmp    800f7f <pgfault+0x50>
		panic("sys_page_map failed: %e", r);
	if ((r = sys_page_unmap(0, (void*)PFTEMP)) < 0)
		panic("sys_page_unmap failed: %e", r);

	// panic("pgfault not implemented");
}
  8010d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010da:	c9                   	leave  
  8010db:	c3                   	ret    

008010dc <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8010dc:	55                   	push   %ebp
  8010dd:	89 e5                	mov    %esp,%ebp
  8010df:	57                   	push   %edi
  8010e0:	56                   	push   %esi
  8010e1:	53                   	push   %ebx
  8010e2:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	int ret;
	set_pgfault_handler(pgfault);
  8010e5:	68 2f 0f 80 00       	push   $0x800f2f
  8010ea:	e8 08 0e 00 00       	call   801ef7 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8010ef:	b8 07 00 00 00       	mov    $0x7,%eax
  8010f4:	cd 30                	int    $0x30
  8010f6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8010f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	envid_t envid = sys_exofork();

	if (envid < 0) return envid;
  8010fc:	83 c4 10             	add    $0x10,%esp
  8010ff:	85 c0                	test   %eax,%eax
  801101:	0f 88 0d 01 00 00    	js     801214 <fork+0x138>
  801107:	bb 00 00 00 00       	mov    $0x0,%ebx
  80110c:	be 00 00 00 00       	mov    $0x0,%esi
	else if (envid == 0) {
  801111:	85 c0                	test   %eax,%eax
  801113:	75 2f                	jne    801144 <fork+0x68>
		// Child returns
		thisenv = &envs[ENVX(sys_getenvid())];
  801115:	e8 e6 fb ff ff       	call   800d00 <sys_getenvid>
  80111a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80111f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801122:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801127:	a3 04 40 80 00       	mov    %eax,0x804004
		// set_pgfault_handler(pgfault);
		return 0;
  80112c:	b8 00 00 00 00       	mov    $0x0,%eax
  801131:	e9 e1 00 00 00       	jmp    801217 <fork+0x13b>
  801136:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
	}
	else {
		uint32_t pn;
		for (pn = 0; pn * PGSIZE < UTOP; pn++){
			// cprintf("virtual page %08x\n", pn * PGSIZE);
			if (pn * PGSIZE == UXSTACKTOP - PGSIZE) 
  80113c:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801142:	74 77                	je     8011bb <fork+0xdf>
{
	int r;

	// LAB 4: Your code here.
	int perm = PTE_P | PTE_U;
	pde_t pde = uvpd[pn / NPTENTRIES];
  801144:	89 f0                	mov    %esi,%eax
  801146:	c1 e8 0a             	shr    $0xa,%eax
  801149:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
	if (!(pde & PTE_P)) return 0;
  801150:	a8 01                	test   $0x1,%al
  801152:	74 0b                	je     80115f <fork+0x83>
	pte_t pte = uvpt[pn];
  801154:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	if (!(pte & PTE_P)) return 0;
  80115b:	a8 01                	test   $0x1,%al
  80115d:	75 08                	jne    801167 <fork+0x8b>
  80115f:	8d 5e 01             	lea    0x1(%esi),%ebx
  801162:	c1 e3 0c             	shl    $0xc,%ebx
  801165:	eb 56                	jmp    8011bd <fork+0xe1>
	// cprintf("virtual page %08x\n", pn * PGSIZE);

	if ((pte & PTE_W) || (pte & PTE_COW)) perm |= PTE_COW;
  801167:	25 02 08 00 00       	and    $0x802,%eax
  80116c:	83 f8 01             	cmp    $0x1,%eax
  80116f:	19 ff                	sbb    %edi,%edi
  801171:	81 e7 00 f8 ff ff    	and    $0xfffff800,%edi
  801177:	81 c7 05 08 00 00    	add    $0x805,%edi

	if ((r = sys_page_map(thisenv->env_id, (void*)(pn * PGSIZE), envid, 
  80117d:	a1 04 40 80 00       	mov    0x804004,%eax
  801182:	8b 40 48             	mov    0x48(%eax),%eax
  801185:	83 ec 0c             	sub    $0xc,%esp
  801188:	57                   	push   %edi
  801189:	53                   	push   %ebx
  80118a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80118d:	53                   	push   %ebx
  80118e:	50                   	push   %eax
  80118f:	e8 ed fb ff ff       	call   800d81 <sys_page_map>
  801194:	83 c4 20             	add    $0x20,%esp
  801197:	85 c0                	test   %eax,%eax
  801199:	78 7c                	js     801217 <fork+0x13b>
				(void*)(pn * PGSIZE), perm)) < 0) 
		return r;
	r = sys_page_map(envid, (void*)(pn * PGSIZE), thisenv->env_id, 
  80119b:	a1 04 40 80 00       	mov    0x804004,%eax
  8011a0:	8b 40 48             	mov    0x48(%eax),%eax
  8011a3:	83 ec 0c             	sub    $0xc,%esp
  8011a6:	57                   	push   %edi
  8011a7:	53                   	push   %ebx
  8011a8:	50                   	push   %eax
  8011a9:	53                   	push   %ebx
  8011aa:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011ad:	e8 cf fb ff ff       	call   800d81 <sys_page_map>
		uint32_t pn;
		for (pn = 0; pn * PGSIZE < UTOP; pn++){
			// cprintf("virtual page %08x\n", pn * PGSIZE);
			if (pn * PGSIZE == UXSTACKTOP - PGSIZE) 
				continue;
			if ((ret = duppage(envid, pn)) < 0)
  8011b2:	83 c4 20             	add    $0x20,%esp
  8011b5:	85 c0                	test   %eax,%eax
  8011b7:	79 a6                	jns    80115f <fork+0x83>
  8011b9:	eb 5c                	jmp    801217 <fork+0x13b>
  8011bb:	89 c3                	mov    %eax,%ebx
		// set_pgfault_handler(pgfault);
		return 0;
	}
	else {
		uint32_t pn;
		for (pn = 0; pn * PGSIZE < UTOP; pn++){
  8011bd:	83 c6 01             	add    $0x1,%esi
  8011c0:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
  8011c6:	0f 86 6a ff ff ff    	jbe    801136 <fork+0x5a>
				return ret;
		}
		// cprintf("Fork: duppage finished\n");

		// Should be done by parent
		if ((ret = sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P |
  8011cc:	83 ec 04             	sub    $0x4,%esp
  8011cf:	6a 07                	push   $0x7
  8011d1:	68 00 f0 bf ee       	push   $0xeebff000
  8011d6:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8011d9:	57                   	push   %edi
  8011da:	e8 5f fb ff ff       	call   800d3e <sys_page_alloc>
  8011df:	83 c4 10             	add    $0x10,%esp
  8011e2:	85 c0                	test   %eax,%eax
  8011e4:	78 31                	js     801217 <fork+0x13b>
						PTE_U | PTE_W)) < 0)
			return ret;
		if ((ret = sys_env_set_pgfault_upcall(envid, 
						thisenv->env_pgfault_upcall)) < 0)
  8011e6:	a1 04 40 80 00       	mov    0x804004,%eax

		// Should be done by parent
		if ((ret = sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P |
						PTE_U | PTE_W)) < 0)
			return ret;
		if ((ret = sys_env_set_pgfault_upcall(envid, 
  8011eb:	8b 40 64             	mov    0x64(%eax),%eax
  8011ee:	83 ec 08             	sub    $0x8,%esp
  8011f1:	50                   	push   %eax
  8011f2:	57                   	push   %edi
  8011f3:	e8 91 fc ff ff       	call   800e89 <sys_env_set_pgfault_upcall>
  8011f8:	83 c4 10             	add    $0x10,%esp
  8011fb:	85 c0                	test   %eax,%eax
  8011fd:	78 18                	js     801217 <fork+0x13b>
						thisenv->env_pgfault_upcall)) < 0)
			return ret;

		if ((ret = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8011ff:	83 ec 08             	sub    $0x8,%esp
  801202:	6a 02                	push   $0x2
  801204:	57                   	push   %edi
  801205:	e8 fb fb ff ff       	call   800e05 <sys_env_set_status>
  80120a:	83 c4 10             	add    $0x10,%esp
			return ret;
		return envid;
  80120d:	85 c0                	test   %eax,%eax
  80120f:	0f 49 c7             	cmovns %edi,%eax
  801212:	eb 03                	jmp    801217 <fork+0x13b>
	int ret;
	set_pgfault_handler(pgfault);

	envid_t envid = sys_exofork();

	if (envid < 0) return envid;
  801214:	8b 45 e0             	mov    -0x20(%ebp),%eax
			return ret;
		return envid;
	}

	panic("fork not implemented");
}
  801217:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80121a:	5b                   	pop    %ebx
  80121b:	5e                   	pop    %esi
  80121c:	5f                   	pop    %edi
  80121d:	5d                   	pop    %ebp
  80121e:	c3                   	ret    

0080121f <sfork>:

// Challenge!
int
sfork(void)
{
  80121f:	55                   	push   %ebp
  801220:	89 e5                	mov    %esp,%ebp
  801222:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801225:	68 11 28 80 00       	push   $0x802811
  80122a:	68 9f 00 00 00       	push   $0x9f
  80122f:	68 af 27 80 00       	push   $0x8027af
  801234:	e8 fd ef ff ff       	call   800236 <_panic>

00801239 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801239:	55                   	push   %ebp
  80123a:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80123c:	8b 45 08             	mov    0x8(%ebp),%eax
  80123f:	05 00 00 00 30       	add    $0x30000000,%eax
  801244:	c1 e8 0c             	shr    $0xc,%eax
}
  801247:	5d                   	pop    %ebp
  801248:	c3                   	ret    

00801249 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801249:	55                   	push   %ebp
  80124a:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80124c:	8b 45 08             	mov    0x8(%ebp),%eax
  80124f:	05 00 00 00 30       	add    $0x30000000,%eax
  801254:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801259:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80125e:	5d                   	pop    %ebp
  80125f:	c3                   	ret    

00801260 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801260:	55                   	push   %ebp
  801261:	89 e5                	mov    %esp,%ebp
  801263:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801266:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80126b:	89 c2                	mov    %eax,%edx
  80126d:	c1 ea 16             	shr    $0x16,%edx
  801270:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801277:	f6 c2 01             	test   $0x1,%dl
  80127a:	74 11                	je     80128d <fd_alloc+0x2d>
  80127c:	89 c2                	mov    %eax,%edx
  80127e:	c1 ea 0c             	shr    $0xc,%edx
  801281:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801288:	f6 c2 01             	test   $0x1,%dl
  80128b:	75 09                	jne    801296 <fd_alloc+0x36>
			*fd_store = fd;
  80128d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80128f:	b8 00 00 00 00       	mov    $0x0,%eax
  801294:	eb 17                	jmp    8012ad <fd_alloc+0x4d>
  801296:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80129b:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012a0:	75 c9                	jne    80126b <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012a2:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8012a8:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8012ad:	5d                   	pop    %ebp
  8012ae:	c3                   	ret    

008012af <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012af:	55                   	push   %ebp
  8012b0:	89 e5                	mov    %esp,%ebp
  8012b2:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012b5:	83 f8 1f             	cmp    $0x1f,%eax
  8012b8:	77 36                	ja     8012f0 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012ba:	c1 e0 0c             	shl    $0xc,%eax
  8012bd:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012c2:	89 c2                	mov    %eax,%edx
  8012c4:	c1 ea 16             	shr    $0x16,%edx
  8012c7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012ce:	f6 c2 01             	test   $0x1,%dl
  8012d1:	74 24                	je     8012f7 <fd_lookup+0x48>
  8012d3:	89 c2                	mov    %eax,%edx
  8012d5:	c1 ea 0c             	shr    $0xc,%edx
  8012d8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012df:	f6 c2 01             	test   $0x1,%dl
  8012e2:	74 1a                	je     8012fe <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012e7:	89 02                	mov    %eax,(%edx)
	return 0;
  8012e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8012ee:	eb 13                	jmp    801303 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012f0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012f5:	eb 0c                	jmp    801303 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012f7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012fc:	eb 05                	jmp    801303 <fd_lookup+0x54>
  8012fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801303:	5d                   	pop    %ebp
  801304:	c3                   	ret    

00801305 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801305:	55                   	push   %ebp
  801306:	89 e5                	mov    %esp,%ebp
  801308:	83 ec 08             	sub    $0x8,%esp
  80130b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80130e:	ba cc 28 80 00       	mov    $0x8028cc,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801313:	eb 13                	jmp    801328 <dev_lookup+0x23>
  801315:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801318:	39 08                	cmp    %ecx,(%eax)
  80131a:	75 0c                	jne    801328 <dev_lookup+0x23>
			*dev = devtab[i];
  80131c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80131f:	89 01                	mov    %eax,(%ecx)
			return 0;
  801321:	b8 00 00 00 00       	mov    $0x0,%eax
  801326:	eb 2e                	jmp    801356 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801328:	8b 02                	mov    (%edx),%eax
  80132a:	85 c0                	test   %eax,%eax
  80132c:	75 e7                	jne    801315 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80132e:	a1 04 40 80 00       	mov    0x804004,%eax
  801333:	8b 40 48             	mov    0x48(%eax),%eax
  801336:	83 ec 04             	sub    $0x4,%esp
  801339:	51                   	push   %ecx
  80133a:	50                   	push   %eax
  80133b:	68 4c 28 80 00       	push   $0x80284c
  801340:	e8 ca ef ff ff       	call   80030f <cprintf>
	*dev = 0;
  801345:	8b 45 0c             	mov    0xc(%ebp),%eax
  801348:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80134e:	83 c4 10             	add    $0x10,%esp
  801351:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801356:	c9                   	leave  
  801357:	c3                   	ret    

00801358 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801358:	55                   	push   %ebp
  801359:	89 e5                	mov    %esp,%ebp
  80135b:	56                   	push   %esi
  80135c:	53                   	push   %ebx
  80135d:	83 ec 10             	sub    $0x10,%esp
  801360:	8b 75 08             	mov    0x8(%ebp),%esi
  801363:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801366:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801369:	50                   	push   %eax
  80136a:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801370:	c1 e8 0c             	shr    $0xc,%eax
  801373:	50                   	push   %eax
  801374:	e8 36 ff ff ff       	call   8012af <fd_lookup>
  801379:	83 c4 08             	add    $0x8,%esp
  80137c:	85 c0                	test   %eax,%eax
  80137e:	78 05                	js     801385 <fd_close+0x2d>
	    || fd != fd2)
  801380:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801383:	74 0c                	je     801391 <fd_close+0x39>
		return (must_exist ? r : 0);
  801385:	84 db                	test   %bl,%bl
  801387:	ba 00 00 00 00       	mov    $0x0,%edx
  80138c:	0f 44 c2             	cmove  %edx,%eax
  80138f:	eb 41                	jmp    8013d2 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801391:	83 ec 08             	sub    $0x8,%esp
  801394:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801397:	50                   	push   %eax
  801398:	ff 36                	pushl  (%esi)
  80139a:	e8 66 ff ff ff       	call   801305 <dev_lookup>
  80139f:	89 c3                	mov    %eax,%ebx
  8013a1:	83 c4 10             	add    $0x10,%esp
  8013a4:	85 c0                	test   %eax,%eax
  8013a6:	78 1a                	js     8013c2 <fd_close+0x6a>
		if (dev->dev_close)
  8013a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013ab:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8013ae:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8013b3:	85 c0                	test   %eax,%eax
  8013b5:	74 0b                	je     8013c2 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8013b7:	83 ec 0c             	sub    $0xc,%esp
  8013ba:	56                   	push   %esi
  8013bb:	ff d0                	call   *%eax
  8013bd:	89 c3                	mov    %eax,%ebx
  8013bf:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013c2:	83 ec 08             	sub    $0x8,%esp
  8013c5:	56                   	push   %esi
  8013c6:	6a 00                	push   $0x0
  8013c8:	e8 f6 f9 ff ff       	call   800dc3 <sys_page_unmap>
	return r;
  8013cd:	83 c4 10             	add    $0x10,%esp
  8013d0:	89 d8                	mov    %ebx,%eax
}
  8013d2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013d5:	5b                   	pop    %ebx
  8013d6:	5e                   	pop    %esi
  8013d7:	5d                   	pop    %ebp
  8013d8:	c3                   	ret    

008013d9 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8013d9:	55                   	push   %ebp
  8013da:	89 e5                	mov    %esp,%ebp
  8013dc:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013df:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013e2:	50                   	push   %eax
  8013e3:	ff 75 08             	pushl  0x8(%ebp)
  8013e6:	e8 c4 fe ff ff       	call   8012af <fd_lookup>
  8013eb:	83 c4 08             	add    $0x8,%esp
  8013ee:	85 c0                	test   %eax,%eax
  8013f0:	78 10                	js     801402 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8013f2:	83 ec 08             	sub    $0x8,%esp
  8013f5:	6a 01                	push   $0x1
  8013f7:	ff 75 f4             	pushl  -0xc(%ebp)
  8013fa:	e8 59 ff ff ff       	call   801358 <fd_close>
  8013ff:	83 c4 10             	add    $0x10,%esp
}
  801402:	c9                   	leave  
  801403:	c3                   	ret    

00801404 <close_all>:

void
close_all(void)
{
  801404:	55                   	push   %ebp
  801405:	89 e5                	mov    %esp,%ebp
  801407:	53                   	push   %ebx
  801408:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80140b:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801410:	83 ec 0c             	sub    $0xc,%esp
  801413:	53                   	push   %ebx
  801414:	e8 c0 ff ff ff       	call   8013d9 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801419:	83 c3 01             	add    $0x1,%ebx
  80141c:	83 c4 10             	add    $0x10,%esp
  80141f:	83 fb 20             	cmp    $0x20,%ebx
  801422:	75 ec                	jne    801410 <close_all+0xc>
		close(i);
}
  801424:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801427:	c9                   	leave  
  801428:	c3                   	ret    

00801429 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801429:	55                   	push   %ebp
  80142a:	89 e5                	mov    %esp,%ebp
  80142c:	57                   	push   %edi
  80142d:	56                   	push   %esi
  80142e:	53                   	push   %ebx
  80142f:	83 ec 2c             	sub    $0x2c,%esp
  801432:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801435:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801438:	50                   	push   %eax
  801439:	ff 75 08             	pushl  0x8(%ebp)
  80143c:	e8 6e fe ff ff       	call   8012af <fd_lookup>
  801441:	83 c4 08             	add    $0x8,%esp
  801444:	85 c0                	test   %eax,%eax
  801446:	0f 88 c1 00 00 00    	js     80150d <dup+0xe4>
		return r;
	close(newfdnum);
  80144c:	83 ec 0c             	sub    $0xc,%esp
  80144f:	56                   	push   %esi
  801450:	e8 84 ff ff ff       	call   8013d9 <close>

	newfd = INDEX2FD(newfdnum);
  801455:	89 f3                	mov    %esi,%ebx
  801457:	c1 e3 0c             	shl    $0xc,%ebx
  80145a:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801460:	83 c4 04             	add    $0x4,%esp
  801463:	ff 75 e4             	pushl  -0x1c(%ebp)
  801466:	e8 de fd ff ff       	call   801249 <fd2data>
  80146b:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80146d:	89 1c 24             	mov    %ebx,(%esp)
  801470:	e8 d4 fd ff ff       	call   801249 <fd2data>
  801475:	83 c4 10             	add    $0x10,%esp
  801478:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80147b:	89 f8                	mov    %edi,%eax
  80147d:	c1 e8 16             	shr    $0x16,%eax
  801480:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801487:	a8 01                	test   $0x1,%al
  801489:	74 37                	je     8014c2 <dup+0x99>
  80148b:	89 f8                	mov    %edi,%eax
  80148d:	c1 e8 0c             	shr    $0xc,%eax
  801490:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801497:	f6 c2 01             	test   $0x1,%dl
  80149a:	74 26                	je     8014c2 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80149c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014a3:	83 ec 0c             	sub    $0xc,%esp
  8014a6:	25 07 0e 00 00       	and    $0xe07,%eax
  8014ab:	50                   	push   %eax
  8014ac:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014af:	6a 00                	push   $0x0
  8014b1:	57                   	push   %edi
  8014b2:	6a 00                	push   $0x0
  8014b4:	e8 c8 f8 ff ff       	call   800d81 <sys_page_map>
  8014b9:	89 c7                	mov    %eax,%edi
  8014bb:	83 c4 20             	add    $0x20,%esp
  8014be:	85 c0                	test   %eax,%eax
  8014c0:	78 2e                	js     8014f0 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014c2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8014c5:	89 d0                	mov    %edx,%eax
  8014c7:	c1 e8 0c             	shr    $0xc,%eax
  8014ca:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014d1:	83 ec 0c             	sub    $0xc,%esp
  8014d4:	25 07 0e 00 00       	and    $0xe07,%eax
  8014d9:	50                   	push   %eax
  8014da:	53                   	push   %ebx
  8014db:	6a 00                	push   $0x0
  8014dd:	52                   	push   %edx
  8014de:	6a 00                	push   $0x0
  8014e0:	e8 9c f8 ff ff       	call   800d81 <sys_page_map>
  8014e5:	89 c7                	mov    %eax,%edi
  8014e7:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8014ea:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014ec:	85 ff                	test   %edi,%edi
  8014ee:	79 1d                	jns    80150d <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8014f0:	83 ec 08             	sub    $0x8,%esp
  8014f3:	53                   	push   %ebx
  8014f4:	6a 00                	push   $0x0
  8014f6:	e8 c8 f8 ff ff       	call   800dc3 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014fb:	83 c4 08             	add    $0x8,%esp
  8014fe:	ff 75 d4             	pushl  -0x2c(%ebp)
  801501:	6a 00                	push   $0x0
  801503:	e8 bb f8 ff ff       	call   800dc3 <sys_page_unmap>
	return r;
  801508:	83 c4 10             	add    $0x10,%esp
  80150b:	89 f8                	mov    %edi,%eax
}
  80150d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801510:	5b                   	pop    %ebx
  801511:	5e                   	pop    %esi
  801512:	5f                   	pop    %edi
  801513:	5d                   	pop    %ebp
  801514:	c3                   	ret    

00801515 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801515:	55                   	push   %ebp
  801516:	89 e5                	mov    %esp,%ebp
  801518:	53                   	push   %ebx
  801519:	83 ec 14             	sub    $0x14,%esp
  80151c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80151f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801522:	50                   	push   %eax
  801523:	53                   	push   %ebx
  801524:	e8 86 fd ff ff       	call   8012af <fd_lookup>
  801529:	83 c4 08             	add    $0x8,%esp
  80152c:	89 c2                	mov    %eax,%edx
  80152e:	85 c0                	test   %eax,%eax
  801530:	78 6d                	js     80159f <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801532:	83 ec 08             	sub    $0x8,%esp
  801535:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801538:	50                   	push   %eax
  801539:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80153c:	ff 30                	pushl  (%eax)
  80153e:	e8 c2 fd ff ff       	call   801305 <dev_lookup>
  801543:	83 c4 10             	add    $0x10,%esp
  801546:	85 c0                	test   %eax,%eax
  801548:	78 4c                	js     801596 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80154a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80154d:	8b 42 08             	mov    0x8(%edx),%eax
  801550:	83 e0 03             	and    $0x3,%eax
  801553:	83 f8 01             	cmp    $0x1,%eax
  801556:	75 21                	jne    801579 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801558:	a1 04 40 80 00       	mov    0x804004,%eax
  80155d:	8b 40 48             	mov    0x48(%eax),%eax
  801560:	83 ec 04             	sub    $0x4,%esp
  801563:	53                   	push   %ebx
  801564:	50                   	push   %eax
  801565:	68 90 28 80 00       	push   $0x802890
  80156a:	e8 a0 ed ff ff       	call   80030f <cprintf>
		return -E_INVAL;
  80156f:	83 c4 10             	add    $0x10,%esp
  801572:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801577:	eb 26                	jmp    80159f <read+0x8a>
	}
	if (!dev->dev_read)
  801579:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80157c:	8b 40 08             	mov    0x8(%eax),%eax
  80157f:	85 c0                	test   %eax,%eax
  801581:	74 17                	je     80159a <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801583:	83 ec 04             	sub    $0x4,%esp
  801586:	ff 75 10             	pushl  0x10(%ebp)
  801589:	ff 75 0c             	pushl  0xc(%ebp)
  80158c:	52                   	push   %edx
  80158d:	ff d0                	call   *%eax
  80158f:	89 c2                	mov    %eax,%edx
  801591:	83 c4 10             	add    $0x10,%esp
  801594:	eb 09                	jmp    80159f <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801596:	89 c2                	mov    %eax,%edx
  801598:	eb 05                	jmp    80159f <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80159a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80159f:	89 d0                	mov    %edx,%eax
  8015a1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015a4:	c9                   	leave  
  8015a5:	c3                   	ret    

008015a6 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015a6:	55                   	push   %ebp
  8015a7:	89 e5                	mov    %esp,%ebp
  8015a9:	57                   	push   %edi
  8015aa:	56                   	push   %esi
  8015ab:	53                   	push   %ebx
  8015ac:	83 ec 0c             	sub    $0xc,%esp
  8015af:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015b2:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015b5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015ba:	eb 21                	jmp    8015dd <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015bc:	83 ec 04             	sub    $0x4,%esp
  8015bf:	89 f0                	mov    %esi,%eax
  8015c1:	29 d8                	sub    %ebx,%eax
  8015c3:	50                   	push   %eax
  8015c4:	89 d8                	mov    %ebx,%eax
  8015c6:	03 45 0c             	add    0xc(%ebp),%eax
  8015c9:	50                   	push   %eax
  8015ca:	57                   	push   %edi
  8015cb:	e8 45 ff ff ff       	call   801515 <read>
		if (m < 0)
  8015d0:	83 c4 10             	add    $0x10,%esp
  8015d3:	85 c0                	test   %eax,%eax
  8015d5:	78 10                	js     8015e7 <readn+0x41>
			return m;
		if (m == 0)
  8015d7:	85 c0                	test   %eax,%eax
  8015d9:	74 0a                	je     8015e5 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015db:	01 c3                	add    %eax,%ebx
  8015dd:	39 f3                	cmp    %esi,%ebx
  8015df:	72 db                	jb     8015bc <readn+0x16>
  8015e1:	89 d8                	mov    %ebx,%eax
  8015e3:	eb 02                	jmp    8015e7 <readn+0x41>
  8015e5:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8015e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015ea:	5b                   	pop    %ebx
  8015eb:	5e                   	pop    %esi
  8015ec:	5f                   	pop    %edi
  8015ed:	5d                   	pop    %ebp
  8015ee:	c3                   	ret    

008015ef <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015ef:	55                   	push   %ebp
  8015f0:	89 e5                	mov    %esp,%ebp
  8015f2:	53                   	push   %ebx
  8015f3:	83 ec 14             	sub    $0x14,%esp
  8015f6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015f9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015fc:	50                   	push   %eax
  8015fd:	53                   	push   %ebx
  8015fe:	e8 ac fc ff ff       	call   8012af <fd_lookup>
  801603:	83 c4 08             	add    $0x8,%esp
  801606:	89 c2                	mov    %eax,%edx
  801608:	85 c0                	test   %eax,%eax
  80160a:	78 68                	js     801674 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80160c:	83 ec 08             	sub    $0x8,%esp
  80160f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801612:	50                   	push   %eax
  801613:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801616:	ff 30                	pushl  (%eax)
  801618:	e8 e8 fc ff ff       	call   801305 <dev_lookup>
  80161d:	83 c4 10             	add    $0x10,%esp
  801620:	85 c0                	test   %eax,%eax
  801622:	78 47                	js     80166b <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801624:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801627:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80162b:	75 21                	jne    80164e <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80162d:	a1 04 40 80 00       	mov    0x804004,%eax
  801632:	8b 40 48             	mov    0x48(%eax),%eax
  801635:	83 ec 04             	sub    $0x4,%esp
  801638:	53                   	push   %ebx
  801639:	50                   	push   %eax
  80163a:	68 ac 28 80 00       	push   $0x8028ac
  80163f:	e8 cb ec ff ff       	call   80030f <cprintf>
		return -E_INVAL;
  801644:	83 c4 10             	add    $0x10,%esp
  801647:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80164c:	eb 26                	jmp    801674 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80164e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801651:	8b 52 0c             	mov    0xc(%edx),%edx
  801654:	85 d2                	test   %edx,%edx
  801656:	74 17                	je     80166f <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801658:	83 ec 04             	sub    $0x4,%esp
  80165b:	ff 75 10             	pushl  0x10(%ebp)
  80165e:	ff 75 0c             	pushl  0xc(%ebp)
  801661:	50                   	push   %eax
  801662:	ff d2                	call   *%edx
  801664:	89 c2                	mov    %eax,%edx
  801666:	83 c4 10             	add    $0x10,%esp
  801669:	eb 09                	jmp    801674 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80166b:	89 c2                	mov    %eax,%edx
  80166d:	eb 05                	jmp    801674 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80166f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801674:	89 d0                	mov    %edx,%eax
  801676:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801679:	c9                   	leave  
  80167a:	c3                   	ret    

0080167b <seek>:

int
seek(int fdnum, off_t offset)
{
  80167b:	55                   	push   %ebp
  80167c:	89 e5                	mov    %esp,%ebp
  80167e:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801681:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801684:	50                   	push   %eax
  801685:	ff 75 08             	pushl  0x8(%ebp)
  801688:	e8 22 fc ff ff       	call   8012af <fd_lookup>
  80168d:	83 c4 08             	add    $0x8,%esp
  801690:	85 c0                	test   %eax,%eax
  801692:	78 0e                	js     8016a2 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801694:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801697:	8b 55 0c             	mov    0xc(%ebp),%edx
  80169a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80169d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016a2:	c9                   	leave  
  8016a3:	c3                   	ret    

008016a4 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016a4:	55                   	push   %ebp
  8016a5:	89 e5                	mov    %esp,%ebp
  8016a7:	53                   	push   %ebx
  8016a8:	83 ec 14             	sub    $0x14,%esp
  8016ab:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016ae:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016b1:	50                   	push   %eax
  8016b2:	53                   	push   %ebx
  8016b3:	e8 f7 fb ff ff       	call   8012af <fd_lookup>
  8016b8:	83 c4 08             	add    $0x8,%esp
  8016bb:	89 c2                	mov    %eax,%edx
  8016bd:	85 c0                	test   %eax,%eax
  8016bf:	78 65                	js     801726 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016c1:	83 ec 08             	sub    $0x8,%esp
  8016c4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016c7:	50                   	push   %eax
  8016c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016cb:	ff 30                	pushl  (%eax)
  8016cd:	e8 33 fc ff ff       	call   801305 <dev_lookup>
  8016d2:	83 c4 10             	add    $0x10,%esp
  8016d5:	85 c0                	test   %eax,%eax
  8016d7:	78 44                	js     80171d <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016dc:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016e0:	75 21                	jne    801703 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016e2:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016e7:	8b 40 48             	mov    0x48(%eax),%eax
  8016ea:	83 ec 04             	sub    $0x4,%esp
  8016ed:	53                   	push   %ebx
  8016ee:	50                   	push   %eax
  8016ef:	68 6c 28 80 00       	push   $0x80286c
  8016f4:	e8 16 ec ff ff       	call   80030f <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016f9:	83 c4 10             	add    $0x10,%esp
  8016fc:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801701:	eb 23                	jmp    801726 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801703:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801706:	8b 52 18             	mov    0x18(%edx),%edx
  801709:	85 d2                	test   %edx,%edx
  80170b:	74 14                	je     801721 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80170d:	83 ec 08             	sub    $0x8,%esp
  801710:	ff 75 0c             	pushl  0xc(%ebp)
  801713:	50                   	push   %eax
  801714:	ff d2                	call   *%edx
  801716:	89 c2                	mov    %eax,%edx
  801718:	83 c4 10             	add    $0x10,%esp
  80171b:	eb 09                	jmp    801726 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80171d:	89 c2                	mov    %eax,%edx
  80171f:	eb 05                	jmp    801726 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801721:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801726:	89 d0                	mov    %edx,%eax
  801728:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80172b:	c9                   	leave  
  80172c:	c3                   	ret    

0080172d <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80172d:	55                   	push   %ebp
  80172e:	89 e5                	mov    %esp,%ebp
  801730:	53                   	push   %ebx
  801731:	83 ec 14             	sub    $0x14,%esp
  801734:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801737:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80173a:	50                   	push   %eax
  80173b:	ff 75 08             	pushl  0x8(%ebp)
  80173e:	e8 6c fb ff ff       	call   8012af <fd_lookup>
  801743:	83 c4 08             	add    $0x8,%esp
  801746:	89 c2                	mov    %eax,%edx
  801748:	85 c0                	test   %eax,%eax
  80174a:	78 58                	js     8017a4 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80174c:	83 ec 08             	sub    $0x8,%esp
  80174f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801752:	50                   	push   %eax
  801753:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801756:	ff 30                	pushl  (%eax)
  801758:	e8 a8 fb ff ff       	call   801305 <dev_lookup>
  80175d:	83 c4 10             	add    $0x10,%esp
  801760:	85 c0                	test   %eax,%eax
  801762:	78 37                	js     80179b <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801764:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801767:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80176b:	74 32                	je     80179f <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80176d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801770:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801777:	00 00 00 
	stat->st_isdir = 0;
  80177a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801781:	00 00 00 
	stat->st_dev = dev;
  801784:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80178a:	83 ec 08             	sub    $0x8,%esp
  80178d:	53                   	push   %ebx
  80178e:	ff 75 f0             	pushl  -0x10(%ebp)
  801791:	ff 50 14             	call   *0x14(%eax)
  801794:	89 c2                	mov    %eax,%edx
  801796:	83 c4 10             	add    $0x10,%esp
  801799:	eb 09                	jmp    8017a4 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80179b:	89 c2                	mov    %eax,%edx
  80179d:	eb 05                	jmp    8017a4 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80179f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8017a4:	89 d0                	mov    %edx,%eax
  8017a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017a9:	c9                   	leave  
  8017aa:	c3                   	ret    

008017ab <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017ab:	55                   	push   %ebp
  8017ac:	89 e5                	mov    %esp,%ebp
  8017ae:	56                   	push   %esi
  8017af:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017b0:	83 ec 08             	sub    $0x8,%esp
  8017b3:	6a 00                	push   $0x0
  8017b5:	ff 75 08             	pushl  0x8(%ebp)
  8017b8:	e8 b7 01 00 00       	call   801974 <open>
  8017bd:	89 c3                	mov    %eax,%ebx
  8017bf:	83 c4 10             	add    $0x10,%esp
  8017c2:	85 c0                	test   %eax,%eax
  8017c4:	78 1b                	js     8017e1 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8017c6:	83 ec 08             	sub    $0x8,%esp
  8017c9:	ff 75 0c             	pushl  0xc(%ebp)
  8017cc:	50                   	push   %eax
  8017cd:	e8 5b ff ff ff       	call   80172d <fstat>
  8017d2:	89 c6                	mov    %eax,%esi
	close(fd);
  8017d4:	89 1c 24             	mov    %ebx,(%esp)
  8017d7:	e8 fd fb ff ff       	call   8013d9 <close>
	return r;
  8017dc:	83 c4 10             	add    $0x10,%esp
  8017df:	89 f0                	mov    %esi,%eax
}
  8017e1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017e4:	5b                   	pop    %ebx
  8017e5:	5e                   	pop    %esi
  8017e6:	5d                   	pop    %ebp
  8017e7:	c3                   	ret    

008017e8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017e8:	55                   	push   %ebp
  8017e9:	89 e5                	mov    %esp,%ebp
  8017eb:	56                   	push   %esi
  8017ec:	53                   	push   %ebx
  8017ed:	89 c6                	mov    %eax,%esi
  8017ef:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017f1:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017f8:	75 12                	jne    80180c <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017fa:	83 ec 0c             	sub    $0xc,%esp
  8017fd:	6a 01                	push   $0x1
  8017ff:	e8 2c 08 00 00       	call   802030 <ipc_find_env>
  801804:	a3 00 40 80 00       	mov    %eax,0x804000
  801809:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80180c:	6a 07                	push   $0x7
  80180e:	68 00 50 80 00       	push   $0x805000
  801813:	56                   	push   %esi
  801814:	ff 35 00 40 80 00    	pushl  0x804000
  80181a:	e8 bd 07 00 00       	call   801fdc <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80181f:	83 c4 0c             	add    $0xc,%esp
  801822:	6a 00                	push   $0x0
  801824:	53                   	push   %ebx
  801825:	6a 00                	push   $0x0
  801827:	e8 3b 07 00 00       	call   801f67 <ipc_recv>
}
  80182c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80182f:	5b                   	pop    %ebx
  801830:	5e                   	pop    %esi
  801831:	5d                   	pop    %ebp
  801832:	c3                   	ret    

00801833 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801833:	55                   	push   %ebp
  801834:	89 e5                	mov    %esp,%ebp
  801836:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801839:	8b 45 08             	mov    0x8(%ebp),%eax
  80183c:	8b 40 0c             	mov    0xc(%eax),%eax
  80183f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801844:	8b 45 0c             	mov    0xc(%ebp),%eax
  801847:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80184c:	ba 00 00 00 00       	mov    $0x0,%edx
  801851:	b8 02 00 00 00       	mov    $0x2,%eax
  801856:	e8 8d ff ff ff       	call   8017e8 <fsipc>
}
  80185b:	c9                   	leave  
  80185c:	c3                   	ret    

0080185d <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80185d:	55                   	push   %ebp
  80185e:	89 e5                	mov    %esp,%ebp
  801860:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801863:	8b 45 08             	mov    0x8(%ebp),%eax
  801866:	8b 40 0c             	mov    0xc(%eax),%eax
  801869:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80186e:	ba 00 00 00 00       	mov    $0x0,%edx
  801873:	b8 06 00 00 00       	mov    $0x6,%eax
  801878:	e8 6b ff ff ff       	call   8017e8 <fsipc>
}
  80187d:	c9                   	leave  
  80187e:	c3                   	ret    

0080187f <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80187f:	55                   	push   %ebp
  801880:	89 e5                	mov    %esp,%ebp
  801882:	53                   	push   %ebx
  801883:	83 ec 04             	sub    $0x4,%esp
  801886:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801889:	8b 45 08             	mov    0x8(%ebp),%eax
  80188c:	8b 40 0c             	mov    0xc(%eax),%eax
  80188f:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801894:	ba 00 00 00 00       	mov    $0x0,%edx
  801899:	b8 05 00 00 00       	mov    $0x5,%eax
  80189e:	e8 45 ff ff ff       	call   8017e8 <fsipc>
  8018a3:	85 c0                	test   %eax,%eax
  8018a5:	78 2c                	js     8018d3 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018a7:	83 ec 08             	sub    $0x8,%esp
  8018aa:	68 00 50 80 00       	push   $0x805000
  8018af:	53                   	push   %ebx
  8018b0:	e8 86 f0 ff ff       	call   80093b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018b5:	a1 80 50 80 00       	mov    0x805080,%eax
  8018ba:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018c0:	a1 84 50 80 00       	mov    0x805084,%eax
  8018c5:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018cb:	83 c4 10             	add    $0x10,%esp
  8018ce:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018d6:	c9                   	leave  
  8018d7:	c3                   	ret    

008018d8 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8018d8:	55                   	push   %ebp
  8018d9:	89 e5                	mov    %esp,%ebp
  8018db:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  8018de:	68 dc 28 80 00       	push   $0x8028dc
  8018e3:	68 90 00 00 00       	push   $0x90
  8018e8:	68 fa 28 80 00       	push   $0x8028fa
  8018ed:	e8 44 e9 ff ff       	call   800236 <_panic>

008018f2 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018f2:	55                   	push   %ebp
  8018f3:	89 e5                	mov    %esp,%ebp
  8018f5:	56                   	push   %esi
  8018f6:	53                   	push   %ebx
  8018f7:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8018fd:	8b 40 0c             	mov    0xc(%eax),%eax
  801900:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801905:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80190b:	ba 00 00 00 00       	mov    $0x0,%edx
  801910:	b8 03 00 00 00       	mov    $0x3,%eax
  801915:	e8 ce fe ff ff       	call   8017e8 <fsipc>
  80191a:	89 c3                	mov    %eax,%ebx
  80191c:	85 c0                	test   %eax,%eax
  80191e:	78 4b                	js     80196b <devfile_read+0x79>
		return r;
	assert(r <= n);
  801920:	39 c6                	cmp    %eax,%esi
  801922:	73 16                	jae    80193a <devfile_read+0x48>
  801924:	68 05 29 80 00       	push   $0x802905
  801929:	68 0c 29 80 00       	push   $0x80290c
  80192e:	6a 7c                	push   $0x7c
  801930:	68 fa 28 80 00       	push   $0x8028fa
  801935:	e8 fc e8 ff ff       	call   800236 <_panic>
	assert(r <= PGSIZE);
  80193a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80193f:	7e 16                	jle    801957 <devfile_read+0x65>
  801941:	68 21 29 80 00       	push   $0x802921
  801946:	68 0c 29 80 00       	push   $0x80290c
  80194b:	6a 7d                	push   $0x7d
  80194d:	68 fa 28 80 00       	push   $0x8028fa
  801952:	e8 df e8 ff ff       	call   800236 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801957:	83 ec 04             	sub    $0x4,%esp
  80195a:	50                   	push   %eax
  80195b:	68 00 50 80 00       	push   $0x805000
  801960:	ff 75 0c             	pushl  0xc(%ebp)
  801963:	e8 65 f1 ff ff       	call   800acd <memmove>
	return r;
  801968:	83 c4 10             	add    $0x10,%esp
}
  80196b:	89 d8                	mov    %ebx,%eax
  80196d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801970:	5b                   	pop    %ebx
  801971:	5e                   	pop    %esi
  801972:	5d                   	pop    %ebp
  801973:	c3                   	ret    

00801974 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801974:	55                   	push   %ebp
  801975:	89 e5                	mov    %esp,%ebp
  801977:	53                   	push   %ebx
  801978:	83 ec 20             	sub    $0x20,%esp
  80197b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80197e:	53                   	push   %ebx
  80197f:	e8 7e ef ff ff       	call   800902 <strlen>
  801984:	83 c4 10             	add    $0x10,%esp
  801987:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80198c:	7f 67                	jg     8019f5 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80198e:	83 ec 0c             	sub    $0xc,%esp
  801991:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801994:	50                   	push   %eax
  801995:	e8 c6 f8 ff ff       	call   801260 <fd_alloc>
  80199a:	83 c4 10             	add    $0x10,%esp
		return r;
  80199d:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80199f:	85 c0                	test   %eax,%eax
  8019a1:	78 57                	js     8019fa <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8019a3:	83 ec 08             	sub    $0x8,%esp
  8019a6:	53                   	push   %ebx
  8019a7:	68 00 50 80 00       	push   $0x805000
  8019ac:	e8 8a ef ff ff       	call   80093b <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019b4:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019b9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019bc:	b8 01 00 00 00       	mov    $0x1,%eax
  8019c1:	e8 22 fe ff ff       	call   8017e8 <fsipc>
  8019c6:	89 c3                	mov    %eax,%ebx
  8019c8:	83 c4 10             	add    $0x10,%esp
  8019cb:	85 c0                	test   %eax,%eax
  8019cd:	79 14                	jns    8019e3 <open+0x6f>
		fd_close(fd, 0);
  8019cf:	83 ec 08             	sub    $0x8,%esp
  8019d2:	6a 00                	push   $0x0
  8019d4:	ff 75 f4             	pushl  -0xc(%ebp)
  8019d7:	e8 7c f9 ff ff       	call   801358 <fd_close>
		return r;
  8019dc:	83 c4 10             	add    $0x10,%esp
  8019df:	89 da                	mov    %ebx,%edx
  8019e1:	eb 17                	jmp    8019fa <open+0x86>
	}

	return fd2num(fd);
  8019e3:	83 ec 0c             	sub    $0xc,%esp
  8019e6:	ff 75 f4             	pushl  -0xc(%ebp)
  8019e9:	e8 4b f8 ff ff       	call   801239 <fd2num>
  8019ee:	89 c2                	mov    %eax,%edx
  8019f0:	83 c4 10             	add    $0x10,%esp
  8019f3:	eb 05                	jmp    8019fa <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8019f5:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8019fa:	89 d0                	mov    %edx,%eax
  8019fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019ff:	c9                   	leave  
  801a00:	c3                   	ret    

00801a01 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a01:	55                   	push   %ebp
  801a02:	89 e5                	mov    %esp,%ebp
  801a04:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a07:	ba 00 00 00 00       	mov    $0x0,%edx
  801a0c:	b8 08 00 00 00       	mov    $0x8,%eax
  801a11:	e8 d2 fd ff ff       	call   8017e8 <fsipc>
}
  801a16:	c9                   	leave  
  801a17:	c3                   	ret    

00801a18 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a18:	55                   	push   %ebp
  801a19:	89 e5                	mov    %esp,%ebp
  801a1b:	56                   	push   %esi
  801a1c:	53                   	push   %ebx
  801a1d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a20:	83 ec 0c             	sub    $0xc,%esp
  801a23:	ff 75 08             	pushl  0x8(%ebp)
  801a26:	e8 1e f8 ff ff       	call   801249 <fd2data>
  801a2b:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a2d:	83 c4 08             	add    $0x8,%esp
  801a30:	68 2d 29 80 00       	push   $0x80292d
  801a35:	53                   	push   %ebx
  801a36:	e8 00 ef ff ff       	call   80093b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a3b:	8b 46 04             	mov    0x4(%esi),%eax
  801a3e:	2b 06                	sub    (%esi),%eax
  801a40:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a46:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a4d:	00 00 00 
	stat->st_dev = &devpipe;
  801a50:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a57:	30 80 00 
	return 0;
}
  801a5a:	b8 00 00 00 00       	mov    $0x0,%eax
  801a5f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a62:	5b                   	pop    %ebx
  801a63:	5e                   	pop    %esi
  801a64:	5d                   	pop    %ebp
  801a65:	c3                   	ret    

00801a66 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a66:	55                   	push   %ebp
  801a67:	89 e5                	mov    %esp,%ebp
  801a69:	53                   	push   %ebx
  801a6a:	83 ec 0c             	sub    $0xc,%esp
  801a6d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a70:	53                   	push   %ebx
  801a71:	6a 00                	push   $0x0
  801a73:	e8 4b f3 ff ff       	call   800dc3 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a78:	89 1c 24             	mov    %ebx,(%esp)
  801a7b:	e8 c9 f7 ff ff       	call   801249 <fd2data>
  801a80:	83 c4 08             	add    $0x8,%esp
  801a83:	50                   	push   %eax
  801a84:	6a 00                	push   $0x0
  801a86:	e8 38 f3 ff ff       	call   800dc3 <sys_page_unmap>
}
  801a8b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a8e:	c9                   	leave  
  801a8f:	c3                   	ret    

00801a90 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a90:	55                   	push   %ebp
  801a91:	89 e5                	mov    %esp,%ebp
  801a93:	57                   	push   %edi
  801a94:	56                   	push   %esi
  801a95:	53                   	push   %ebx
  801a96:	83 ec 1c             	sub    $0x1c,%esp
  801a99:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a9c:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a9e:	a1 04 40 80 00       	mov    0x804004,%eax
  801aa3:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801aa6:	83 ec 0c             	sub    $0xc,%esp
  801aa9:	ff 75 e0             	pushl  -0x20(%ebp)
  801aac:	e8 b8 05 00 00       	call   802069 <pageref>
  801ab1:	89 c3                	mov    %eax,%ebx
  801ab3:	89 3c 24             	mov    %edi,(%esp)
  801ab6:	e8 ae 05 00 00       	call   802069 <pageref>
  801abb:	83 c4 10             	add    $0x10,%esp
  801abe:	39 c3                	cmp    %eax,%ebx
  801ac0:	0f 94 c1             	sete   %cl
  801ac3:	0f b6 c9             	movzbl %cl,%ecx
  801ac6:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801ac9:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801acf:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ad2:	39 ce                	cmp    %ecx,%esi
  801ad4:	74 1b                	je     801af1 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801ad6:	39 c3                	cmp    %eax,%ebx
  801ad8:	75 c4                	jne    801a9e <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ada:	8b 42 58             	mov    0x58(%edx),%eax
  801add:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ae0:	50                   	push   %eax
  801ae1:	56                   	push   %esi
  801ae2:	68 34 29 80 00       	push   $0x802934
  801ae7:	e8 23 e8 ff ff       	call   80030f <cprintf>
  801aec:	83 c4 10             	add    $0x10,%esp
  801aef:	eb ad                	jmp    801a9e <_pipeisclosed+0xe>
	}
}
  801af1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801af4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801af7:	5b                   	pop    %ebx
  801af8:	5e                   	pop    %esi
  801af9:	5f                   	pop    %edi
  801afa:	5d                   	pop    %ebp
  801afb:	c3                   	ret    

00801afc <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801afc:	55                   	push   %ebp
  801afd:	89 e5                	mov    %esp,%ebp
  801aff:	57                   	push   %edi
  801b00:	56                   	push   %esi
  801b01:	53                   	push   %ebx
  801b02:	83 ec 28             	sub    $0x28,%esp
  801b05:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b08:	56                   	push   %esi
  801b09:	e8 3b f7 ff ff       	call   801249 <fd2data>
  801b0e:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b10:	83 c4 10             	add    $0x10,%esp
  801b13:	bf 00 00 00 00       	mov    $0x0,%edi
  801b18:	eb 4b                	jmp    801b65 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b1a:	89 da                	mov    %ebx,%edx
  801b1c:	89 f0                	mov    %esi,%eax
  801b1e:	e8 6d ff ff ff       	call   801a90 <_pipeisclosed>
  801b23:	85 c0                	test   %eax,%eax
  801b25:	75 48                	jne    801b6f <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b27:	e8 f3 f1 ff ff       	call   800d1f <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b2c:	8b 43 04             	mov    0x4(%ebx),%eax
  801b2f:	8b 0b                	mov    (%ebx),%ecx
  801b31:	8d 51 20             	lea    0x20(%ecx),%edx
  801b34:	39 d0                	cmp    %edx,%eax
  801b36:	73 e2                	jae    801b1a <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b3b:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b3f:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b42:	89 c2                	mov    %eax,%edx
  801b44:	c1 fa 1f             	sar    $0x1f,%edx
  801b47:	89 d1                	mov    %edx,%ecx
  801b49:	c1 e9 1b             	shr    $0x1b,%ecx
  801b4c:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b4f:	83 e2 1f             	and    $0x1f,%edx
  801b52:	29 ca                	sub    %ecx,%edx
  801b54:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b58:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b5c:	83 c0 01             	add    $0x1,%eax
  801b5f:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b62:	83 c7 01             	add    $0x1,%edi
  801b65:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b68:	75 c2                	jne    801b2c <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b6a:	8b 45 10             	mov    0x10(%ebp),%eax
  801b6d:	eb 05                	jmp    801b74 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b6f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b74:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b77:	5b                   	pop    %ebx
  801b78:	5e                   	pop    %esi
  801b79:	5f                   	pop    %edi
  801b7a:	5d                   	pop    %ebp
  801b7b:	c3                   	ret    

00801b7c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b7c:	55                   	push   %ebp
  801b7d:	89 e5                	mov    %esp,%ebp
  801b7f:	57                   	push   %edi
  801b80:	56                   	push   %esi
  801b81:	53                   	push   %ebx
  801b82:	83 ec 18             	sub    $0x18,%esp
  801b85:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b88:	57                   	push   %edi
  801b89:	e8 bb f6 ff ff       	call   801249 <fd2data>
  801b8e:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b90:	83 c4 10             	add    $0x10,%esp
  801b93:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b98:	eb 3d                	jmp    801bd7 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b9a:	85 db                	test   %ebx,%ebx
  801b9c:	74 04                	je     801ba2 <devpipe_read+0x26>
				return i;
  801b9e:	89 d8                	mov    %ebx,%eax
  801ba0:	eb 44                	jmp    801be6 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ba2:	89 f2                	mov    %esi,%edx
  801ba4:	89 f8                	mov    %edi,%eax
  801ba6:	e8 e5 fe ff ff       	call   801a90 <_pipeisclosed>
  801bab:	85 c0                	test   %eax,%eax
  801bad:	75 32                	jne    801be1 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801baf:	e8 6b f1 ff ff       	call   800d1f <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801bb4:	8b 06                	mov    (%esi),%eax
  801bb6:	3b 46 04             	cmp    0x4(%esi),%eax
  801bb9:	74 df                	je     801b9a <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801bbb:	99                   	cltd   
  801bbc:	c1 ea 1b             	shr    $0x1b,%edx
  801bbf:	01 d0                	add    %edx,%eax
  801bc1:	83 e0 1f             	and    $0x1f,%eax
  801bc4:	29 d0                	sub    %edx,%eax
  801bc6:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801bcb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bce:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801bd1:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bd4:	83 c3 01             	add    $0x1,%ebx
  801bd7:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801bda:	75 d8                	jne    801bb4 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801bdc:	8b 45 10             	mov    0x10(%ebp),%eax
  801bdf:	eb 05                	jmp    801be6 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801be1:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801be6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801be9:	5b                   	pop    %ebx
  801bea:	5e                   	pop    %esi
  801beb:	5f                   	pop    %edi
  801bec:	5d                   	pop    %ebp
  801bed:	c3                   	ret    

00801bee <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801bee:	55                   	push   %ebp
  801bef:	89 e5                	mov    %esp,%ebp
  801bf1:	56                   	push   %esi
  801bf2:	53                   	push   %ebx
  801bf3:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801bf6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bf9:	50                   	push   %eax
  801bfa:	e8 61 f6 ff ff       	call   801260 <fd_alloc>
  801bff:	83 c4 10             	add    $0x10,%esp
  801c02:	89 c2                	mov    %eax,%edx
  801c04:	85 c0                	test   %eax,%eax
  801c06:	0f 88 2c 01 00 00    	js     801d38 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c0c:	83 ec 04             	sub    $0x4,%esp
  801c0f:	68 07 04 00 00       	push   $0x407
  801c14:	ff 75 f4             	pushl  -0xc(%ebp)
  801c17:	6a 00                	push   $0x0
  801c19:	e8 20 f1 ff ff       	call   800d3e <sys_page_alloc>
  801c1e:	83 c4 10             	add    $0x10,%esp
  801c21:	89 c2                	mov    %eax,%edx
  801c23:	85 c0                	test   %eax,%eax
  801c25:	0f 88 0d 01 00 00    	js     801d38 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c2b:	83 ec 0c             	sub    $0xc,%esp
  801c2e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c31:	50                   	push   %eax
  801c32:	e8 29 f6 ff ff       	call   801260 <fd_alloc>
  801c37:	89 c3                	mov    %eax,%ebx
  801c39:	83 c4 10             	add    $0x10,%esp
  801c3c:	85 c0                	test   %eax,%eax
  801c3e:	0f 88 e2 00 00 00    	js     801d26 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c44:	83 ec 04             	sub    $0x4,%esp
  801c47:	68 07 04 00 00       	push   $0x407
  801c4c:	ff 75 f0             	pushl  -0x10(%ebp)
  801c4f:	6a 00                	push   $0x0
  801c51:	e8 e8 f0 ff ff       	call   800d3e <sys_page_alloc>
  801c56:	89 c3                	mov    %eax,%ebx
  801c58:	83 c4 10             	add    $0x10,%esp
  801c5b:	85 c0                	test   %eax,%eax
  801c5d:	0f 88 c3 00 00 00    	js     801d26 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c63:	83 ec 0c             	sub    $0xc,%esp
  801c66:	ff 75 f4             	pushl  -0xc(%ebp)
  801c69:	e8 db f5 ff ff       	call   801249 <fd2data>
  801c6e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c70:	83 c4 0c             	add    $0xc,%esp
  801c73:	68 07 04 00 00       	push   $0x407
  801c78:	50                   	push   %eax
  801c79:	6a 00                	push   $0x0
  801c7b:	e8 be f0 ff ff       	call   800d3e <sys_page_alloc>
  801c80:	89 c3                	mov    %eax,%ebx
  801c82:	83 c4 10             	add    $0x10,%esp
  801c85:	85 c0                	test   %eax,%eax
  801c87:	0f 88 89 00 00 00    	js     801d16 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c8d:	83 ec 0c             	sub    $0xc,%esp
  801c90:	ff 75 f0             	pushl  -0x10(%ebp)
  801c93:	e8 b1 f5 ff ff       	call   801249 <fd2data>
  801c98:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c9f:	50                   	push   %eax
  801ca0:	6a 00                	push   $0x0
  801ca2:	56                   	push   %esi
  801ca3:	6a 00                	push   $0x0
  801ca5:	e8 d7 f0 ff ff       	call   800d81 <sys_page_map>
  801caa:	89 c3                	mov    %eax,%ebx
  801cac:	83 c4 20             	add    $0x20,%esp
  801caf:	85 c0                	test   %eax,%eax
  801cb1:	78 55                	js     801d08 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801cb3:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cbc:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801cbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cc1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801cc8:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cce:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cd1:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801cd3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cd6:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801cdd:	83 ec 0c             	sub    $0xc,%esp
  801ce0:	ff 75 f4             	pushl  -0xc(%ebp)
  801ce3:	e8 51 f5 ff ff       	call   801239 <fd2num>
  801ce8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ceb:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801ced:	83 c4 04             	add    $0x4,%esp
  801cf0:	ff 75 f0             	pushl  -0x10(%ebp)
  801cf3:	e8 41 f5 ff ff       	call   801239 <fd2num>
  801cf8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cfb:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801cfe:	83 c4 10             	add    $0x10,%esp
  801d01:	ba 00 00 00 00       	mov    $0x0,%edx
  801d06:	eb 30                	jmp    801d38 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d08:	83 ec 08             	sub    $0x8,%esp
  801d0b:	56                   	push   %esi
  801d0c:	6a 00                	push   $0x0
  801d0e:	e8 b0 f0 ff ff       	call   800dc3 <sys_page_unmap>
  801d13:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d16:	83 ec 08             	sub    $0x8,%esp
  801d19:	ff 75 f0             	pushl  -0x10(%ebp)
  801d1c:	6a 00                	push   $0x0
  801d1e:	e8 a0 f0 ff ff       	call   800dc3 <sys_page_unmap>
  801d23:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d26:	83 ec 08             	sub    $0x8,%esp
  801d29:	ff 75 f4             	pushl  -0xc(%ebp)
  801d2c:	6a 00                	push   $0x0
  801d2e:	e8 90 f0 ff ff       	call   800dc3 <sys_page_unmap>
  801d33:	83 c4 10             	add    $0x10,%esp
  801d36:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d38:	89 d0                	mov    %edx,%eax
  801d3a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d3d:	5b                   	pop    %ebx
  801d3e:	5e                   	pop    %esi
  801d3f:	5d                   	pop    %ebp
  801d40:	c3                   	ret    

00801d41 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d41:	55                   	push   %ebp
  801d42:	89 e5                	mov    %esp,%ebp
  801d44:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d47:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d4a:	50                   	push   %eax
  801d4b:	ff 75 08             	pushl  0x8(%ebp)
  801d4e:	e8 5c f5 ff ff       	call   8012af <fd_lookup>
  801d53:	83 c4 10             	add    $0x10,%esp
  801d56:	85 c0                	test   %eax,%eax
  801d58:	78 18                	js     801d72 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d5a:	83 ec 0c             	sub    $0xc,%esp
  801d5d:	ff 75 f4             	pushl  -0xc(%ebp)
  801d60:	e8 e4 f4 ff ff       	call   801249 <fd2data>
	return _pipeisclosed(fd, p);
  801d65:	89 c2                	mov    %eax,%edx
  801d67:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d6a:	e8 21 fd ff ff       	call   801a90 <_pipeisclosed>
  801d6f:	83 c4 10             	add    $0x10,%esp
}
  801d72:	c9                   	leave  
  801d73:	c3                   	ret    

00801d74 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d74:	55                   	push   %ebp
  801d75:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d77:	b8 00 00 00 00       	mov    $0x0,%eax
  801d7c:	5d                   	pop    %ebp
  801d7d:	c3                   	ret    

00801d7e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d7e:	55                   	push   %ebp
  801d7f:	89 e5                	mov    %esp,%ebp
  801d81:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d84:	68 4c 29 80 00       	push   $0x80294c
  801d89:	ff 75 0c             	pushl  0xc(%ebp)
  801d8c:	e8 aa eb ff ff       	call   80093b <strcpy>
	return 0;
}
  801d91:	b8 00 00 00 00       	mov    $0x0,%eax
  801d96:	c9                   	leave  
  801d97:	c3                   	ret    

00801d98 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d98:	55                   	push   %ebp
  801d99:	89 e5                	mov    %esp,%ebp
  801d9b:	57                   	push   %edi
  801d9c:	56                   	push   %esi
  801d9d:	53                   	push   %ebx
  801d9e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801da4:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801da9:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801daf:	eb 2d                	jmp    801dde <devcons_write+0x46>
		m = n - tot;
  801db1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801db4:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801db6:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801db9:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801dbe:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801dc1:	83 ec 04             	sub    $0x4,%esp
  801dc4:	53                   	push   %ebx
  801dc5:	03 45 0c             	add    0xc(%ebp),%eax
  801dc8:	50                   	push   %eax
  801dc9:	57                   	push   %edi
  801dca:	e8 fe ec ff ff       	call   800acd <memmove>
		sys_cputs(buf, m);
  801dcf:	83 c4 08             	add    $0x8,%esp
  801dd2:	53                   	push   %ebx
  801dd3:	57                   	push   %edi
  801dd4:	e8 a9 ee ff ff       	call   800c82 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dd9:	01 de                	add    %ebx,%esi
  801ddb:	83 c4 10             	add    $0x10,%esp
  801dde:	89 f0                	mov    %esi,%eax
  801de0:	3b 75 10             	cmp    0x10(%ebp),%esi
  801de3:	72 cc                	jb     801db1 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801de5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801de8:	5b                   	pop    %ebx
  801de9:	5e                   	pop    %esi
  801dea:	5f                   	pop    %edi
  801deb:	5d                   	pop    %ebp
  801dec:	c3                   	ret    

00801ded <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ded:	55                   	push   %ebp
  801dee:	89 e5                	mov    %esp,%ebp
  801df0:	83 ec 08             	sub    $0x8,%esp
  801df3:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801df8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801dfc:	74 2a                	je     801e28 <devcons_read+0x3b>
  801dfe:	eb 05                	jmp    801e05 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e00:	e8 1a ef ff ff       	call   800d1f <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e05:	e8 96 ee ff ff       	call   800ca0 <sys_cgetc>
  801e0a:	85 c0                	test   %eax,%eax
  801e0c:	74 f2                	je     801e00 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801e0e:	85 c0                	test   %eax,%eax
  801e10:	78 16                	js     801e28 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e12:	83 f8 04             	cmp    $0x4,%eax
  801e15:	74 0c                	je     801e23 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e17:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e1a:	88 02                	mov    %al,(%edx)
	return 1;
  801e1c:	b8 01 00 00 00       	mov    $0x1,%eax
  801e21:	eb 05                	jmp    801e28 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e23:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e28:	c9                   	leave  
  801e29:	c3                   	ret    

00801e2a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e2a:	55                   	push   %ebp
  801e2b:	89 e5                	mov    %esp,%ebp
  801e2d:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e30:	8b 45 08             	mov    0x8(%ebp),%eax
  801e33:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e36:	6a 01                	push   $0x1
  801e38:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e3b:	50                   	push   %eax
  801e3c:	e8 41 ee ff ff       	call   800c82 <sys_cputs>
}
  801e41:	83 c4 10             	add    $0x10,%esp
  801e44:	c9                   	leave  
  801e45:	c3                   	ret    

00801e46 <getchar>:

int
getchar(void)
{
  801e46:	55                   	push   %ebp
  801e47:	89 e5                	mov    %esp,%ebp
  801e49:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e4c:	6a 01                	push   $0x1
  801e4e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e51:	50                   	push   %eax
  801e52:	6a 00                	push   $0x0
  801e54:	e8 bc f6 ff ff       	call   801515 <read>
	if (r < 0)
  801e59:	83 c4 10             	add    $0x10,%esp
  801e5c:	85 c0                	test   %eax,%eax
  801e5e:	78 0f                	js     801e6f <getchar+0x29>
		return r;
	if (r < 1)
  801e60:	85 c0                	test   %eax,%eax
  801e62:	7e 06                	jle    801e6a <getchar+0x24>
		return -E_EOF;
	return c;
  801e64:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e68:	eb 05                	jmp    801e6f <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e6a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e6f:	c9                   	leave  
  801e70:	c3                   	ret    

00801e71 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e71:	55                   	push   %ebp
  801e72:	89 e5                	mov    %esp,%ebp
  801e74:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e77:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e7a:	50                   	push   %eax
  801e7b:	ff 75 08             	pushl  0x8(%ebp)
  801e7e:	e8 2c f4 ff ff       	call   8012af <fd_lookup>
  801e83:	83 c4 10             	add    $0x10,%esp
  801e86:	85 c0                	test   %eax,%eax
  801e88:	78 11                	js     801e9b <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e8d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e93:	39 10                	cmp    %edx,(%eax)
  801e95:	0f 94 c0             	sete   %al
  801e98:	0f b6 c0             	movzbl %al,%eax
}
  801e9b:	c9                   	leave  
  801e9c:	c3                   	ret    

00801e9d <opencons>:

int
opencons(void)
{
  801e9d:	55                   	push   %ebp
  801e9e:	89 e5                	mov    %esp,%ebp
  801ea0:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ea3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ea6:	50                   	push   %eax
  801ea7:	e8 b4 f3 ff ff       	call   801260 <fd_alloc>
  801eac:	83 c4 10             	add    $0x10,%esp
		return r;
  801eaf:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801eb1:	85 c0                	test   %eax,%eax
  801eb3:	78 3e                	js     801ef3 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801eb5:	83 ec 04             	sub    $0x4,%esp
  801eb8:	68 07 04 00 00       	push   $0x407
  801ebd:	ff 75 f4             	pushl  -0xc(%ebp)
  801ec0:	6a 00                	push   $0x0
  801ec2:	e8 77 ee ff ff       	call   800d3e <sys_page_alloc>
  801ec7:	83 c4 10             	add    $0x10,%esp
		return r;
  801eca:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ecc:	85 c0                	test   %eax,%eax
  801ece:	78 23                	js     801ef3 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ed0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ed6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ed9:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801edb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ede:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ee5:	83 ec 0c             	sub    $0xc,%esp
  801ee8:	50                   	push   %eax
  801ee9:	e8 4b f3 ff ff       	call   801239 <fd2num>
  801eee:	89 c2                	mov    %eax,%edx
  801ef0:	83 c4 10             	add    $0x10,%esp
}
  801ef3:	89 d0                	mov    %edx,%eax
  801ef5:	c9                   	leave  
  801ef6:	c3                   	ret    

00801ef7 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801ef7:	55                   	push   %ebp
  801ef8:	89 e5                	mov    %esp,%ebp
  801efa:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801efd:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f04:	75 31                	jne    801f37 <set_pgfault_handler+0x40>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc(thisenv->env_id, (void*)(UXSTACKTOP - PGSIZE), PTE_P | 
  801f06:	a1 04 40 80 00       	mov    0x804004,%eax
  801f0b:	8b 40 48             	mov    0x48(%eax),%eax
  801f0e:	83 ec 04             	sub    $0x4,%esp
  801f11:	6a 07                	push   $0x7
  801f13:	68 00 f0 bf ee       	push   $0xeebff000
  801f18:	50                   	push   %eax
  801f19:	e8 20 ee ff ff       	call   800d3e <sys_page_alloc>
				PTE_U | PTE_W);
		sys_env_set_pgfault_upcall(thisenv->env_id, (void*)_pgfault_upcall);
  801f1e:	a1 04 40 80 00       	mov    0x804004,%eax
  801f23:	8b 40 48             	mov    0x48(%eax),%eax
  801f26:	83 c4 08             	add    $0x8,%esp
  801f29:	68 41 1f 80 00       	push   $0x801f41
  801f2e:	50                   	push   %eax
  801f2f:	e8 55 ef ff ff       	call   800e89 <sys_env_set_pgfault_upcall>
  801f34:	83 c4 10             	add    $0x10,%esp

		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f37:	8b 45 08             	mov    0x8(%ebp),%eax
  801f3a:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801f3f:	c9                   	leave  
  801f40:	c3                   	ret    

00801f41 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f41:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f42:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f47:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f49:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	addl $8, %esp      // pop utf_fault_va and utf_err
  801f4c:	83 c4 08             	add    $0x8,%esp
	movl 32(%esp), %eax  // eax <- [esp + 32]
  801f4f:	8b 44 24 20          	mov    0x20(%esp),%eax
	movl 40(%esp), %ebx  // ebx <- [esp + 40]
  801f53:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	leal -4(%ebx), %ebx  // ebx <- ebx - 4
  801f57:	8d 5b fc             	lea    -0x4(%ebx),%ebx
	movl %eax, (%ebx)
  801f5a:	89 03                	mov    %eax,(%ebx)
	movl %ebx, 40(%esp)  // push trap eip and decrement trap esp manually
  801f5c:	89 5c 24 28          	mov    %ebx,0x28(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  801f60:	61                   	popa   
	addl $4, %esp        // skip eip
  801f61:	83 c4 04             	add    $0x4,%esp

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	popf
  801f64:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	pop %esp
  801f65:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801f66:	c3                   	ret    

00801f67 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f67:	55                   	push   %ebp
  801f68:	89 e5                	mov    %esp,%ebp
  801f6a:	56                   	push   %esi
  801f6b:	53                   	push   %ebx
  801f6c:	8b 75 08             	mov    0x8(%ebp),%esi
  801f6f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f72:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int ret;
	if (pg) ret = sys_ipc_recv(pg);
  801f75:	85 c0                	test   %eax,%eax
  801f77:	74 0e                	je     801f87 <ipc_recv+0x20>
  801f79:	83 ec 0c             	sub    $0xc,%esp
  801f7c:	50                   	push   %eax
  801f7d:	e8 6c ef ff ff       	call   800eee <sys_ipc_recv>
  801f82:	83 c4 10             	add    $0x10,%esp
  801f85:	eb 10                	jmp    801f97 <ipc_recv+0x30>
	else ret = sys_ipc_recv((void*)UTOP);
  801f87:	83 ec 0c             	sub    $0xc,%esp
  801f8a:	68 00 00 c0 ee       	push   $0xeec00000
  801f8f:	e8 5a ef ff ff       	call   800eee <sys_ipc_recv>
  801f94:	83 c4 10             	add    $0x10,%esp
	if (ret) {
  801f97:	85 c0                	test   %eax,%eax
  801f99:	74 16                	je     801fb1 <ipc_recv+0x4a>
		if (from_env_store) *from_env_store = 0;
  801f9b:	85 f6                	test   %esi,%esi
  801f9d:	74 06                	je     801fa5 <ipc_recv+0x3e>
  801f9f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  801fa5:	85 db                	test   %ebx,%ebx
  801fa7:	74 2c                	je     801fd5 <ipc_recv+0x6e>
  801fa9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801faf:	eb 24                	jmp    801fd5 <ipc_recv+0x6e>
		return ret;
	}
	if (from_env_store) *from_env_store = thisenv->env_ipc_from;
  801fb1:	85 f6                	test   %esi,%esi
  801fb3:	74 0a                	je     801fbf <ipc_recv+0x58>
  801fb5:	a1 04 40 80 00       	mov    0x804004,%eax
  801fba:	8b 40 74             	mov    0x74(%eax),%eax
  801fbd:	89 06                	mov    %eax,(%esi)
	if (perm_store) *perm_store = thisenv->env_ipc_perm;
  801fbf:	85 db                	test   %ebx,%ebx
  801fc1:	74 0a                	je     801fcd <ipc_recv+0x66>
  801fc3:	a1 04 40 80 00       	mov    0x804004,%eax
  801fc8:	8b 40 78             	mov    0x78(%eax),%eax
  801fcb:	89 03                	mov    %eax,(%ebx)

	// panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801fcd:	a1 04 40 80 00       	mov    0x804004,%eax
  801fd2:	8b 40 70             	mov    0x70(%eax),%eax
}
  801fd5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fd8:	5b                   	pop    %ebx
  801fd9:	5e                   	pop    %esi
  801fda:	5d                   	pop    %ebp
  801fdb:	c3                   	ret    

00801fdc <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801fdc:	55                   	push   %ebp
  801fdd:	89 e5                	mov    %esp,%ebp
  801fdf:	57                   	push   %edi
  801fe0:	56                   	push   %esi
  801fe1:	53                   	push   %ebx
  801fe2:	83 ec 0c             	sub    $0xc,%esp
  801fe5:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fe8:	8b 75 0c             	mov    0xc(%ebp),%esi
  801feb:	8b 45 10             	mov    0x10(%ebp),%eax
  801fee:	85 c0                	test   %eax,%eax
  801ff0:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801ff5:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	while (true) {
		void* srcva = (pg)? pg: (void*)UTOP;
		int ret = sys_ipc_try_send(to_env, val, srcva, perm);
  801ff8:	ff 75 14             	pushl  0x14(%ebp)
  801ffb:	53                   	push   %ebx
  801ffc:	56                   	push   %esi
  801ffd:	57                   	push   %edi
  801ffe:	e8 c8 ee ff ff       	call   800ecb <sys_ipc_try_send>
		if (ret == 0) break;
  802003:	83 c4 10             	add    $0x10,%esp
  802006:	85 c0                	test   %eax,%eax
  802008:	74 1e                	je     802028 <ipc_send+0x4c>
		if (ret != -E_IPC_NOT_RECV) panic("ipc_send: %e", ret);
  80200a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80200d:	74 12                	je     802021 <ipc_send+0x45>
  80200f:	50                   	push   %eax
  802010:	68 58 29 80 00       	push   $0x802958
  802015:	6a 39                	push   $0x39
  802017:	68 65 29 80 00       	push   $0x802965
  80201c:	e8 15 e2 ff ff       	call   800236 <_panic>
		sys_yield();
  802021:	e8 f9 ec ff ff       	call   800d1f <sys_yield>
	}
  802026:	eb d0                	jmp    801ff8 <ipc_send+0x1c>
	// panic("ipc_send not implemented");
}
  802028:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80202b:	5b                   	pop    %ebx
  80202c:	5e                   	pop    %esi
  80202d:	5f                   	pop    %edi
  80202e:	5d                   	pop    %ebp
  80202f:	c3                   	ret    

00802030 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802030:	55                   	push   %ebp
  802031:	89 e5                	mov    %esp,%ebp
  802033:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802036:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80203b:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80203e:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802044:	8b 52 50             	mov    0x50(%edx),%edx
  802047:	39 ca                	cmp    %ecx,%edx
  802049:	75 0d                	jne    802058 <ipc_find_env+0x28>
			return envs[i].env_id;
  80204b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80204e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802053:	8b 40 48             	mov    0x48(%eax),%eax
  802056:	eb 0f                	jmp    802067 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802058:	83 c0 01             	add    $0x1,%eax
  80205b:	3d 00 04 00 00       	cmp    $0x400,%eax
  802060:	75 d9                	jne    80203b <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802062:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802067:	5d                   	pop    %ebp
  802068:	c3                   	ret    

00802069 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802069:	55                   	push   %ebp
  80206a:	89 e5                	mov    %esp,%ebp
  80206c:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80206f:	89 d0                	mov    %edx,%eax
  802071:	c1 e8 16             	shr    $0x16,%eax
  802074:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80207b:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802080:	f6 c1 01             	test   $0x1,%cl
  802083:	74 1d                	je     8020a2 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802085:	c1 ea 0c             	shr    $0xc,%edx
  802088:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80208f:	f6 c2 01             	test   $0x1,%dl
  802092:	74 0e                	je     8020a2 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802094:	c1 ea 0c             	shr    $0xc,%edx
  802097:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80209e:	ef 
  80209f:	0f b7 c0             	movzwl %ax,%eax
}
  8020a2:	5d                   	pop    %ebp
  8020a3:	c3                   	ret    
  8020a4:	66 90                	xchg   %ax,%ax
  8020a6:	66 90                	xchg   %ax,%ax
  8020a8:	66 90                	xchg   %ax,%ax
  8020aa:	66 90                	xchg   %ax,%ax
  8020ac:	66 90                	xchg   %ax,%ax
  8020ae:	66 90                	xchg   %ax,%ax

008020b0 <__udivdi3>:
  8020b0:	55                   	push   %ebp
  8020b1:	57                   	push   %edi
  8020b2:	56                   	push   %esi
  8020b3:	53                   	push   %ebx
  8020b4:	83 ec 1c             	sub    $0x1c,%esp
  8020b7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8020bb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8020bf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8020c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020c7:	85 f6                	test   %esi,%esi
  8020c9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020cd:	89 ca                	mov    %ecx,%edx
  8020cf:	89 f8                	mov    %edi,%eax
  8020d1:	75 3d                	jne    802110 <__udivdi3+0x60>
  8020d3:	39 cf                	cmp    %ecx,%edi
  8020d5:	0f 87 c5 00 00 00    	ja     8021a0 <__udivdi3+0xf0>
  8020db:	85 ff                	test   %edi,%edi
  8020dd:	89 fd                	mov    %edi,%ebp
  8020df:	75 0b                	jne    8020ec <__udivdi3+0x3c>
  8020e1:	b8 01 00 00 00       	mov    $0x1,%eax
  8020e6:	31 d2                	xor    %edx,%edx
  8020e8:	f7 f7                	div    %edi
  8020ea:	89 c5                	mov    %eax,%ebp
  8020ec:	89 c8                	mov    %ecx,%eax
  8020ee:	31 d2                	xor    %edx,%edx
  8020f0:	f7 f5                	div    %ebp
  8020f2:	89 c1                	mov    %eax,%ecx
  8020f4:	89 d8                	mov    %ebx,%eax
  8020f6:	89 cf                	mov    %ecx,%edi
  8020f8:	f7 f5                	div    %ebp
  8020fa:	89 c3                	mov    %eax,%ebx
  8020fc:	89 d8                	mov    %ebx,%eax
  8020fe:	89 fa                	mov    %edi,%edx
  802100:	83 c4 1c             	add    $0x1c,%esp
  802103:	5b                   	pop    %ebx
  802104:	5e                   	pop    %esi
  802105:	5f                   	pop    %edi
  802106:	5d                   	pop    %ebp
  802107:	c3                   	ret    
  802108:	90                   	nop
  802109:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802110:	39 ce                	cmp    %ecx,%esi
  802112:	77 74                	ja     802188 <__udivdi3+0xd8>
  802114:	0f bd fe             	bsr    %esi,%edi
  802117:	83 f7 1f             	xor    $0x1f,%edi
  80211a:	0f 84 98 00 00 00    	je     8021b8 <__udivdi3+0x108>
  802120:	bb 20 00 00 00       	mov    $0x20,%ebx
  802125:	89 f9                	mov    %edi,%ecx
  802127:	89 c5                	mov    %eax,%ebp
  802129:	29 fb                	sub    %edi,%ebx
  80212b:	d3 e6                	shl    %cl,%esi
  80212d:	89 d9                	mov    %ebx,%ecx
  80212f:	d3 ed                	shr    %cl,%ebp
  802131:	89 f9                	mov    %edi,%ecx
  802133:	d3 e0                	shl    %cl,%eax
  802135:	09 ee                	or     %ebp,%esi
  802137:	89 d9                	mov    %ebx,%ecx
  802139:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80213d:	89 d5                	mov    %edx,%ebp
  80213f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802143:	d3 ed                	shr    %cl,%ebp
  802145:	89 f9                	mov    %edi,%ecx
  802147:	d3 e2                	shl    %cl,%edx
  802149:	89 d9                	mov    %ebx,%ecx
  80214b:	d3 e8                	shr    %cl,%eax
  80214d:	09 c2                	or     %eax,%edx
  80214f:	89 d0                	mov    %edx,%eax
  802151:	89 ea                	mov    %ebp,%edx
  802153:	f7 f6                	div    %esi
  802155:	89 d5                	mov    %edx,%ebp
  802157:	89 c3                	mov    %eax,%ebx
  802159:	f7 64 24 0c          	mull   0xc(%esp)
  80215d:	39 d5                	cmp    %edx,%ebp
  80215f:	72 10                	jb     802171 <__udivdi3+0xc1>
  802161:	8b 74 24 08          	mov    0x8(%esp),%esi
  802165:	89 f9                	mov    %edi,%ecx
  802167:	d3 e6                	shl    %cl,%esi
  802169:	39 c6                	cmp    %eax,%esi
  80216b:	73 07                	jae    802174 <__udivdi3+0xc4>
  80216d:	39 d5                	cmp    %edx,%ebp
  80216f:	75 03                	jne    802174 <__udivdi3+0xc4>
  802171:	83 eb 01             	sub    $0x1,%ebx
  802174:	31 ff                	xor    %edi,%edi
  802176:	89 d8                	mov    %ebx,%eax
  802178:	89 fa                	mov    %edi,%edx
  80217a:	83 c4 1c             	add    $0x1c,%esp
  80217d:	5b                   	pop    %ebx
  80217e:	5e                   	pop    %esi
  80217f:	5f                   	pop    %edi
  802180:	5d                   	pop    %ebp
  802181:	c3                   	ret    
  802182:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802188:	31 ff                	xor    %edi,%edi
  80218a:	31 db                	xor    %ebx,%ebx
  80218c:	89 d8                	mov    %ebx,%eax
  80218e:	89 fa                	mov    %edi,%edx
  802190:	83 c4 1c             	add    $0x1c,%esp
  802193:	5b                   	pop    %ebx
  802194:	5e                   	pop    %esi
  802195:	5f                   	pop    %edi
  802196:	5d                   	pop    %ebp
  802197:	c3                   	ret    
  802198:	90                   	nop
  802199:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021a0:	89 d8                	mov    %ebx,%eax
  8021a2:	f7 f7                	div    %edi
  8021a4:	31 ff                	xor    %edi,%edi
  8021a6:	89 c3                	mov    %eax,%ebx
  8021a8:	89 d8                	mov    %ebx,%eax
  8021aa:	89 fa                	mov    %edi,%edx
  8021ac:	83 c4 1c             	add    $0x1c,%esp
  8021af:	5b                   	pop    %ebx
  8021b0:	5e                   	pop    %esi
  8021b1:	5f                   	pop    %edi
  8021b2:	5d                   	pop    %ebp
  8021b3:	c3                   	ret    
  8021b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021b8:	39 ce                	cmp    %ecx,%esi
  8021ba:	72 0c                	jb     8021c8 <__udivdi3+0x118>
  8021bc:	31 db                	xor    %ebx,%ebx
  8021be:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8021c2:	0f 87 34 ff ff ff    	ja     8020fc <__udivdi3+0x4c>
  8021c8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8021cd:	e9 2a ff ff ff       	jmp    8020fc <__udivdi3+0x4c>
  8021d2:	66 90                	xchg   %ax,%ax
  8021d4:	66 90                	xchg   %ax,%ax
  8021d6:	66 90                	xchg   %ax,%ax
  8021d8:	66 90                	xchg   %ax,%ax
  8021da:	66 90                	xchg   %ax,%ax
  8021dc:	66 90                	xchg   %ax,%ax
  8021de:	66 90                	xchg   %ax,%ax

008021e0 <__umoddi3>:
  8021e0:	55                   	push   %ebp
  8021e1:	57                   	push   %edi
  8021e2:	56                   	push   %esi
  8021e3:	53                   	push   %ebx
  8021e4:	83 ec 1c             	sub    $0x1c,%esp
  8021e7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8021eb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8021ef:	8b 74 24 34          	mov    0x34(%esp),%esi
  8021f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021f7:	85 d2                	test   %edx,%edx
  8021f9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8021fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802201:	89 f3                	mov    %esi,%ebx
  802203:	89 3c 24             	mov    %edi,(%esp)
  802206:	89 74 24 04          	mov    %esi,0x4(%esp)
  80220a:	75 1c                	jne    802228 <__umoddi3+0x48>
  80220c:	39 f7                	cmp    %esi,%edi
  80220e:	76 50                	jbe    802260 <__umoddi3+0x80>
  802210:	89 c8                	mov    %ecx,%eax
  802212:	89 f2                	mov    %esi,%edx
  802214:	f7 f7                	div    %edi
  802216:	89 d0                	mov    %edx,%eax
  802218:	31 d2                	xor    %edx,%edx
  80221a:	83 c4 1c             	add    $0x1c,%esp
  80221d:	5b                   	pop    %ebx
  80221e:	5e                   	pop    %esi
  80221f:	5f                   	pop    %edi
  802220:	5d                   	pop    %ebp
  802221:	c3                   	ret    
  802222:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802228:	39 f2                	cmp    %esi,%edx
  80222a:	89 d0                	mov    %edx,%eax
  80222c:	77 52                	ja     802280 <__umoddi3+0xa0>
  80222e:	0f bd ea             	bsr    %edx,%ebp
  802231:	83 f5 1f             	xor    $0x1f,%ebp
  802234:	75 5a                	jne    802290 <__umoddi3+0xb0>
  802236:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80223a:	0f 82 e0 00 00 00    	jb     802320 <__umoddi3+0x140>
  802240:	39 0c 24             	cmp    %ecx,(%esp)
  802243:	0f 86 d7 00 00 00    	jbe    802320 <__umoddi3+0x140>
  802249:	8b 44 24 08          	mov    0x8(%esp),%eax
  80224d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802251:	83 c4 1c             	add    $0x1c,%esp
  802254:	5b                   	pop    %ebx
  802255:	5e                   	pop    %esi
  802256:	5f                   	pop    %edi
  802257:	5d                   	pop    %ebp
  802258:	c3                   	ret    
  802259:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802260:	85 ff                	test   %edi,%edi
  802262:	89 fd                	mov    %edi,%ebp
  802264:	75 0b                	jne    802271 <__umoddi3+0x91>
  802266:	b8 01 00 00 00       	mov    $0x1,%eax
  80226b:	31 d2                	xor    %edx,%edx
  80226d:	f7 f7                	div    %edi
  80226f:	89 c5                	mov    %eax,%ebp
  802271:	89 f0                	mov    %esi,%eax
  802273:	31 d2                	xor    %edx,%edx
  802275:	f7 f5                	div    %ebp
  802277:	89 c8                	mov    %ecx,%eax
  802279:	f7 f5                	div    %ebp
  80227b:	89 d0                	mov    %edx,%eax
  80227d:	eb 99                	jmp    802218 <__umoddi3+0x38>
  80227f:	90                   	nop
  802280:	89 c8                	mov    %ecx,%eax
  802282:	89 f2                	mov    %esi,%edx
  802284:	83 c4 1c             	add    $0x1c,%esp
  802287:	5b                   	pop    %ebx
  802288:	5e                   	pop    %esi
  802289:	5f                   	pop    %edi
  80228a:	5d                   	pop    %ebp
  80228b:	c3                   	ret    
  80228c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802290:	8b 34 24             	mov    (%esp),%esi
  802293:	bf 20 00 00 00       	mov    $0x20,%edi
  802298:	89 e9                	mov    %ebp,%ecx
  80229a:	29 ef                	sub    %ebp,%edi
  80229c:	d3 e0                	shl    %cl,%eax
  80229e:	89 f9                	mov    %edi,%ecx
  8022a0:	89 f2                	mov    %esi,%edx
  8022a2:	d3 ea                	shr    %cl,%edx
  8022a4:	89 e9                	mov    %ebp,%ecx
  8022a6:	09 c2                	or     %eax,%edx
  8022a8:	89 d8                	mov    %ebx,%eax
  8022aa:	89 14 24             	mov    %edx,(%esp)
  8022ad:	89 f2                	mov    %esi,%edx
  8022af:	d3 e2                	shl    %cl,%edx
  8022b1:	89 f9                	mov    %edi,%ecx
  8022b3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8022b7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8022bb:	d3 e8                	shr    %cl,%eax
  8022bd:	89 e9                	mov    %ebp,%ecx
  8022bf:	89 c6                	mov    %eax,%esi
  8022c1:	d3 e3                	shl    %cl,%ebx
  8022c3:	89 f9                	mov    %edi,%ecx
  8022c5:	89 d0                	mov    %edx,%eax
  8022c7:	d3 e8                	shr    %cl,%eax
  8022c9:	89 e9                	mov    %ebp,%ecx
  8022cb:	09 d8                	or     %ebx,%eax
  8022cd:	89 d3                	mov    %edx,%ebx
  8022cf:	89 f2                	mov    %esi,%edx
  8022d1:	f7 34 24             	divl   (%esp)
  8022d4:	89 d6                	mov    %edx,%esi
  8022d6:	d3 e3                	shl    %cl,%ebx
  8022d8:	f7 64 24 04          	mull   0x4(%esp)
  8022dc:	39 d6                	cmp    %edx,%esi
  8022de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022e2:	89 d1                	mov    %edx,%ecx
  8022e4:	89 c3                	mov    %eax,%ebx
  8022e6:	72 08                	jb     8022f0 <__umoddi3+0x110>
  8022e8:	75 11                	jne    8022fb <__umoddi3+0x11b>
  8022ea:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8022ee:	73 0b                	jae    8022fb <__umoddi3+0x11b>
  8022f0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8022f4:	1b 14 24             	sbb    (%esp),%edx
  8022f7:	89 d1                	mov    %edx,%ecx
  8022f9:	89 c3                	mov    %eax,%ebx
  8022fb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8022ff:	29 da                	sub    %ebx,%edx
  802301:	19 ce                	sbb    %ecx,%esi
  802303:	89 f9                	mov    %edi,%ecx
  802305:	89 f0                	mov    %esi,%eax
  802307:	d3 e0                	shl    %cl,%eax
  802309:	89 e9                	mov    %ebp,%ecx
  80230b:	d3 ea                	shr    %cl,%edx
  80230d:	89 e9                	mov    %ebp,%ecx
  80230f:	d3 ee                	shr    %cl,%esi
  802311:	09 d0                	or     %edx,%eax
  802313:	89 f2                	mov    %esi,%edx
  802315:	83 c4 1c             	add    $0x1c,%esp
  802318:	5b                   	pop    %ebx
  802319:	5e                   	pop    %esi
  80231a:	5f                   	pop    %edi
  80231b:	5d                   	pop    %ebp
  80231c:	c3                   	ret    
  80231d:	8d 76 00             	lea    0x0(%esi),%esi
  802320:	29 f9                	sub    %edi,%ecx
  802322:	19 d6                	sbb    %edx,%esi
  802324:	89 74 24 04          	mov    %esi,0x4(%esp)
  802328:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80232c:	e9 18 ff ff ff       	jmp    802249 <__umoddi3+0x69>
