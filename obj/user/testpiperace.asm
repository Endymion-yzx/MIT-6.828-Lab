
obj/user/testpiperace.debug:     file format elf32-i386


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
  80002c:	e8 b3 01 00 00       	call   8001e4 <libmain>
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
  800038:	83 ec 1c             	sub    $0x1c,%esp
	int p[2], r, pid, i, max;
	void *va;
	struct Fd *fd;
	const volatile struct Env *kid;

	cprintf("testing for dup race...\n");
  80003b:	68 60 23 80 00       	push   $0x802360
  800040:	e8 d8 02 00 00       	call   80031d <cprintf>
	if ((r = pipe(p)) < 0)
  800045:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800048:	89 04 24             	mov    %eax,(%esp)
  80004b:	e8 e9 1c 00 00       	call   801d39 <pipe>
  800050:	83 c4 10             	add    $0x10,%esp
  800053:	85 c0                	test   %eax,%eax
  800055:	79 12                	jns    800069 <umain+0x36>
		panic("pipe: %e", r);
  800057:	50                   	push   %eax
  800058:	68 79 23 80 00       	push   $0x802379
  80005d:	6a 0d                	push   $0xd
  80005f:	68 82 23 80 00       	push   $0x802382
  800064:	e8 db 01 00 00       	call   800244 <_panic>
	max = 200;
	if ((r = fork()) < 0)
  800069:	e8 7c 10 00 00       	call   8010ea <fork>
  80006e:	89 c6                	mov    %eax,%esi
  800070:	85 c0                	test   %eax,%eax
  800072:	79 12                	jns    800086 <umain+0x53>
		panic("fork: %e", r);
  800074:	50                   	push   %eax
  800075:	68 96 23 80 00       	push   $0x802396
  80007a:	6a 10                	push   $0x10
  80007c:	68 82 23 80 00       	push   $0x802382
  800081:	e8 be 01 00 00       	call   800244 <_panic>
	if (r == 0) {
  800086:	85 c0                	test   %eax,%eax
  800088:	75 55                	jne    8000df <umain+0xac>
		close(p[1]);
  80008a:	83 ec 0c             	sub    $0xc,%esp
  80008d:	ff 75 f4             	pushl  -0xc(%ebp)
  800090:	e8 54 14 00 00       	call   8014e9 <close>
  800095:	83 c4 10             	add    $0x10,%esp
  800098:	bb c8 00 00 00       	mov    $0xc8,%ebx
		// If a clock interrupt catches dup between mapping the
		// fd and mapping the pipe structure, we'll have the same
		// ref counts, still a no-no.
		//
		for (i=0; i<max; i++) {
			if(pipeisclosed(p[0])){
  80009d:	83 ec 0c             	sub    $0xc,%esp
  8000a0:	ff 75 f0             	pushl  -0x10(%ebp)
  8000a3:	e8 e4 1d 00 00       	call   801e8c <pipeisclosed>
  8000a8:	83 c4 10             	add    $0x10,%esp
  8000ab:	85 c0                	test   %eax,%eax
  8000ad:	74 15                	je     8000c4 <umain+0x91>
				cprintf("RACE: pipe appears closed\n");
  8000af:	83 ec 0c             	sub    $0xc,%esp
  8000b2:	68 9f 23 80 00       	push   $0x80239f
  8000b7:	e8 61 02 00 00       	call   80031d <cprintf>
				exit();
  8000bc:	e8 69 01 00 00       	call   80022a <exit>
  8000c1:	83 c4 10             	add    $0x10,%esp
			}
			sys_yield();
  8000c4:	e8 64 0c 00 00       	call   800d2d <sys_yield>
		//
		// If a clock interrupt catches dup between mapping the
		// fd and mapping the pipe structure, we'll have the same
		// ref counts, still a no-no.
		//
		for (i=0; i<max; i++) {
  8000c9:	83 eb 01             	sub    $0x1,%ebx
  8000cc:	75 cf                	jne    80009d <umain+0x6a>
				exit();
			}
			sys_yield();
		}
		// do something to be not runnable besides exiting
		ipc_recv(0,0,0);
  8000ce:	83 ec 04             	sub    $0x4,%esp
  8000d1:	6a 00                	push   $0x0
  8000d3:	6a 00                	push   $0x0
  8000d5:	6a 00                	push   $0x0
  8000d7:	e8 6b 11 00 00       	call   801247 <ipc_recv>
  8000dc:	83 c4 10             	add    $0x10,%esp
	}
	pid = r;
	cprintf("pid is %d\n", pid);
  8000df:	83 ec 08             	sub    $0x8,%esp
  8000e2:	56                   	push   %esi
  8000e3:	68 ba 23 80 00       	push   $0x8023ba
  8000e8:	e8 30 02 00 00       	call   80031d <cprintf>
	va = 0;
	kid = &envs[ENVX(pid)];
  8000ed:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	cprintf("kid is %d\n", kid-envs);
  8000f3:	83 c4 08             	add    $0x8,%esp
  8000f6:	6b c6 7c             	imul   $0x7c,%esi,%eax
  8000f9:	c1 f8 02             	sar    $0x2,%eax
  8000fc:	69 c0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%eax
  800102:	50                   	push   %eax
  800103:	68 c5 23 80 00       	push   $0x8023c5
  800108:	e8 10 02 00 00       	call   80031d <cprintf>
	dup(p[0], 10);
  80010d:	83 c4 08             	add    $0x8,%esp
  800110:	6a 0a                	push   $0xa
  800112:	ff 75 f0             	pushl  -0x10(%ebp)
  800115:	e8 1f 14 00 00       	call   801539 <dup>
	while (kid->env_status == ENV_RUNNABLE)
  80011a:	83 c4 10             	add    $0x10,%esp
  80011d:	6b de 7c             	imul   $0x7c,%esi,%ebx
  800120:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  800126:	eb 10                	jmp    800138 <umain+0x105>
		dup(p[0], 10);
  800128:	83 ec 08             	sub    $0x8,%esp
  80012b:	6a 0a                	push   $0xa
  80012d:	ff 75 f0             	pushl  -0x10(%ebp)
  800130:	e8 04 14 00 00       	call   801539 <dup>
  800135:	83 c4 10             	add    $0x10,%esp
	cprintf("pid is %d\n", pid);
	va = 0;
	kid = &envs[ENVX(pid)];
	cprintf("kid is %d\n", kid-envs);
	dup(p[0], 10);
	while (kid->env_status == ENV_RUNNABLE)
  800138:	8b 53 54             	mov    0x54(%ebx),%edx
  80013b:	83 fa 02             	cmp    $0x2,%edx
  80013e:	74 e8                	je     800128 <umain+0xf5>
		dup(p[0], 10);

	cprintf("child done with loop\n");
  800140:	83 ec 0c             	sub    $0xc,%esp
  800143:	68 d0 23 80 00       	push   $0x8023d0
  800148:	e8 d0 01 00 00       	call   80031d <cprintf>
	if (pipeisclosed(p[0]))
  80014d:	83 c4 04             	add    $0x4,%esp
  800150:	ff 75 f0             	pushl  -0x10(%ebp)
  800153:	e8 34 1d 00 00       	call   801e8c <pipeisclosed>
  800158:	83 c4 10             	add    $0x10,%esp
  80015b:	85 c0                	test   %eax,%eax
  80015d:	74 14                	je     800173 <umain+0x140>
		panic("somehow the other end of p[0] got closed!");
  80015f:	83 ec 04             	sub    $0x4,%esp
  800162:	68 2c 24 80 00       	push   $0x80242c
  800167:	6a 3a                	push   $0x3a
  800169:	68 82 23 80 00       	push   $0x802382
  80016e:	e8 d1 00 00 00       	call   800244 <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  800173:	83 ec 08             	sub    $0x8,%esp
  800176:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800179:	50                   	push   %eax
  80017a:	ff 75 f0             	pushl  -0x10(%ebp)
  80017d:	e8 3d 12 00 00       	call   8013bf <fd_lookup>
  800182:	83 c4 10             	add    $0x10,%esp
  800185:	85 c0                	test   %eax,%eax
  800187:	79 12                	jns    80019b <umain+0x168>
		panic("cannot look up p[0]: %e", r);
  800189:	50                   	push   %eax
  80018a:	68 e6 23 80 00       	push   $0x8023e6
  80018f:	6a 3c                	push   $0x3c
  800191:	68 82 23 80 00       	push   $0x802382
  800196:	e8 a9 00 00 00       	call   800244 <_panic>
	va = fd2data(fd);
  80019b:	83 ec 0c             	sub    $0xc,%esp
  80019e:	ff 75 ec             	pushl  -0x14(%ebp)
  8001a1:	e8 b3 11 00 00       	call   801359 <fd2data>
	if (pageref(va) != 3+1)
  8001a6:	89 04 24             	mov    %eax,(%esp)
  8001a9:	e8 7a 19 00 00       	call   801b28 <pageref>
  8001ae:	83 c4 10             	add    $0x10,%esp
  8001b1:	83 f8 04             	cmp    $0x4,%eax
  8001b4:	74 12                	je     8001c8 <umain+0x195>
		cprintf("\nchild detected race\n");
  8001b6:	83 ec 0c             	sub    $0xc,%esp
  8001b9:	68 fe 23 80 00       	push   $0x8023fe
  8001be:	e8 5a 01 00 00       	call   80031d <cprintf>
  8001c3:	83 c4 10             	add    $0x10,%esp
  8001c6:	eb 15                	jmp    8001dd <umain+0x1aa>
	else
		cprintf("\nrace didn't happen\n", max);
  8001c8:	83 ec 08             	sub    $0x8,%esp
  8001cb:	68 c8 00 00 00       	push   $0xc8
  8001d0:	68 14 24 80 00       	push   $0x802414
  8001d5:	e8 43 01 00 00       	call   80031d <cprintf>
  8001da:	83 c4 10             	add    $0x10,%esp
}
  8001dd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001e0:	5b                   	pop    %ebx
  8001e1:	5e                   	pop    %esi
  8001e2:	5d                   	pop    %ebp
  8001e3:	c3                   	ret    

008001e4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001e4:	55                   	push   %ebp
  8001e5:	89 e5                	mov    %esp,%ebp
  8001e7:	56                   	push   %esi
  8001e8:	53                   	push   %ebx
  8001e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001ec:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	envid_t envid = sys_getenvid();
  8001ef:	e8 1a 0b 00 00       	call   800d0e <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8001f4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001f9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001fc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800201:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800206:	85 db                	test   %ebx,%ebx
  800208:	7e 07                	jle    800211 <libmain+0x2d>
		binaryname = argv[0];
  80020a:	8b 06                	mov    (%esi),%eax
  80020c:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800211:	83 ec 08             	sub    $0x8,%esp
  800214:	56                   	push   %esi
  800215:	53                   	push   %ebx
  800216:	e8 18 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80021b:	e8 0a 00 00 00       	call   80022a <exit>
}
  800220:	83 c4 10             	add    $0x10,%esp
  800223:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800226:	5b                   	pop    %ebx
  800227:	5e                   	pop    %esi
  800228:	5d                   	pop    %ebp
  800229:	c3                   	ret    

0080022a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80022a:	55                   	push   %ebp
  80022b:	89 e5                	mov    %esp,%ebp
  80022d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800230:	e8 df 12 00 00       	call   801514 <close_all>
	sys_env_destroy(0);
  800235:	83 ec 0c             	sub    $0xc,%esp
  800238:	6a 00                	push   $0x0
  80023a:	e8 8e 0a 00 00       	call   800ccd <sys_env_destroy>
}
  80023f:	83 c4 10             	add    $0x10,%esp
  800242:	c9                   	leave  
  800243:	c3                   	ret    

00800244 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800244:	55                   	push   %ebp
  800245:	89 e5                	mov    %esp,%ebp
  800247:	56                   	push   %esi
  800248:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800249:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80024c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800252:	e8 b7 0a 00 00       	call   800d0e <sys_getenvid>
  800257:	83 ec 0c             	sub    $0xc,%esp
  80025a:	ff 75 0c             	pushl  0xc(%ebp)
  80025d:	ff 75 08             	pushl  0x8(%ebp)
  800260:	56                   	push   %esi
  800261:	50                   	push   %eax
  800262:	68 60 24 80 00       	push   $0x802460
  800267:	e8 b1 00 00 00       	call   80031d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80026c:	83 c4 18             	add    $0x18,%esp
  80026f:	53                   	push   %ebx
  800270:	ff 75 10             	pushl  0x10(%ebp)
  800273:	e8 54 00 00 00       	call   8002cc <vcprintf>
	cprintf("\n");
  800278:	c7 04 24 77 23 80 00 	movl   $0x802377,(%esp)
  80027f:	e8 99 00 00 00       	call   80031d <cprintf>
  800284:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800287:	cc                   	int3   
  800288:	eb fd                	jmp    800287 <_panic+0x43>

0080028a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	53                   	push   %ebx
  80028e:	83 ec 04             	sub    $0x4,%esp
  800291:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800294:	8b 13                	mov    (%ebx),%edx
  800296:	8d 42 01             	lea    0x1(%edx),%eax
  800299:	89 03                	mov    %eax,(%ebx)
  80029b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80029e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002a2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002a7:	75 1a                	jne    8002c3 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8002a9:	83 ec 08             	sub    $0x8,%esp
  8002ac:	68 ff 00 00 00       	push   $0xff
  8002b1:	8d 43 08             	lea    0x8(%ebx),%eax
  8002b4:	50                   	push   %eax
  8002b5:	e8 d6 09 00 00       	call   800c90 <sys_cputs>
		b->idx = 0;
  8002ba:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002c0:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002c3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002ca:	c9                   	leave  
  8002cb:	c3                   	ret    

008002cc <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002d5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002dc:	00 00 00 
	b.cnt = 0;
  8002df:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002e6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002e9:	ff 75 0c             	pushl  0xc(%ebp)
  8002ec:	ff 75 08             	pushl  0x8(%ebp)
  8002ef:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002f5:	50                   	push   %eax
  8002f6:	68 8a 02 80 00       	push   $0x80028a
  8002fb:	e8 1a 01 00 00       	call   80041a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800300:	83 c4 08             	add    $0x8,%esp
  800303:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800309:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80030f:	50                   	push   %eax
  800310:	e8 7b 09 00 00       	call   800c90 <sys_cputs>

	return b.cnt;
}
  800315:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80031b:	c9                   	leave  
  80031c:	c3                   	ret    

0080031d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80031d:	55                   	push   %ebp
  80031e:	89 e5                	mov    %esp,%ebp
  800320:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800323:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800326:	50                   	push   %eax
  800327:	ff 75 08             	pushl  0x8(%ebp)
  80032a:	e8 9d ff ff ff       	call   8002cc <vcprintf>
	va_end(ap);

	return cnt;
}
  80032f:	c9                   	leave  
  800330:	c3                   	ret    

00800331 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800331:	55                   	push   %ebp
  800332:	89 e5                	mov    %esp,%ebp
  800334:	57                   	push   %edi
  800335:	56                   	push   %esi
  800336:	53                   	push   %ebx
  800337:	83 ec 1c             	sub    $0x1c,%esp
  80033a:	89 c7                	mov    %eax,%edi
  80033c:	89 d6                	mov    %edx,%esi
  80033e:	8b 45 08             	mov    0x8(%ebp),%eax
  800341:	8b 55 0c             	mov    0xc(%ebp),%edx
  800344:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800347:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80034a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80034d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800352:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800355:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800358:	39 d3                	cmp    %edx,%ebx
  80035a:	72 05                	jb     800361 <printnum+0x30>
  80035c:	39 45 10             	cmp    %eax,0x10(%ebp)
  80035f:	77 45                	ja     8003a6 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800361:	83 ec 0c             	sub    $0xc,%esp
  800364:	ff 75 18             	pushl  0x18(%ebp)
  800367:	8b 45 14             	mov    0x14(%ebp),%eax
  80036a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80036d:	53                   	push   %ebx
  80036e:	ff 75 10             	pushl  0x10(%ebp)
  800371:	83 ec 08             	sub    $0x8,%esp
  800374:	ff 75 e4             	pushl  -0x1c(%ebp)
  800377:	ff 75 e0             	pushl  -0x20(%ebp)
  80037a:	ff 75 dc             	pushl  -0x24(%ebp)
  80037d:	ff 75 d8             	pushl  -0x28(%ebp)
  800380:	e8 3b 1d 00 00       	call   8020c0 <__udivdi3>
  800385:	83 c4 18             	add    $0x18,%esp
  800388:	52                   	push   %edx
  800389:	50                   	push   %eax
  80038a:	89 f2                	mov    %esi,%edx
  80038c:	89 f8                	mov    %edi,%eax
  80038e:	e8 9e ff ff ff       	call   800331 <printnum>
  800393:	83 c4 20             	add    $0x20,%esp
  800396:	eb 18                	jmp    8003b0 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800398:	83 ec 08             	sub    $0x8,%esp
  80039b:	56                   	push   %esi
  80039c:	ff 75 18             	pushl  0x18(%ebp)
  80039f:	ff d7                	call   *%edi
  8003a1:	83 c4 10             	add    $0x10,%esp
  8003a4:	eb 03                	jmp    8003a9 <printnum+0x78>
  8003a6:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003a9:	83 eb 01             	sub    $0x1,%ebx
  8003ac:	85 db                	test   %ebx,%ebx
  8003ae:	7f e8                	jg     800398 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003b0:	83 ec 08             	sub    $0x8,%esp
  8003b3:	56                   	push   %esi
  8003b4:	83 ec 04             	sub    $0x4,%esp
  8003b7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003ba:	ff 75 e0             	pushl  -0x20(%ebp)
  8003bd:	ff 75 dc             	pushl  -0x24(%ebp)
  8003c0:	ff 75 d8             	pushl  -0x28(%ebp)
  8003c3:	e8 28 1e 00 00       	call   8021f0 <__umoddi3>
  8003c8:	83 c4 14             	add    $0x14,%esp
  8003cb:	0f be 80 83 24 80 00 	movsbl 0x802483(%eax),%eax
  8003d2:	50                   	push   %eax
  8003d3:	ff d7                	call   *%edi
}
  8003d5:	83 c4 10             	add    $0x10,%esp
  8003d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003db:	5b                   	pop    %ebx
  8003dc:	5e                   	pop    %esi
  8003dd:	5f                   	pop    %edi
  8003de:	5d                   	pop    %ebp
  8003df:	c3                   	ret    

008003e0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003e0:	55                   	push   %ebp
  8003e1:	89 e5                	mov    %esp,%ebp
  8003e3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003e6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003ea:	8b 10                	mov    (%eax),%edx
  8003ec:	3b 50 04             	cmp    0x4(%eax),%edx
  8003ef:	73 0a                	jae    8003fb <sprintputch+0x1b>
		*b->buf++ = ch;
  8003f1:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003f4:	89 08                	mov    %ecx,(%eax)
  8003f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f9:	88 02                	mov    %al,(%edx)
}
  8003fb:	5d                   	pop    %ebp
  8003fc:	c3                   	ret    

008003fd <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003fd:	55                   	push   %ebp
  8003fe:	89 e5                	mov    %esp,%ebp
  800400:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800403:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800406:	50                   	push   %eax
  800407:	ff 75 10             	pushl  0x10(%ebp)
  80040a:	ff 75 0c             	pushl  0xc(%ebp)
  80040d:	ff 75 08             	pushl  0x8(%ebp)
  800410:	e8 05 00 00 00       	call   80041a <vprintfmt>
	va_end(ap);
}
  800415:	83 c4 10             	add    $0x10,%esp
  800418:	c9                   	leave  
  800419:	c3                   	ret    

0080041a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80041a:	55                   	push   %ebp
  80041b:	89 e5                	mov    %esp,%ebp
  80041d:	57                   	push   %edi
  80041e:	56                   	push   %esi
  80041f:	53                   	push   %ebx
  800420:	83 ec 2c             	sub    $0x2c,%esp
  800423:	8b 75 08             	mov    0x8(%ebp),%esi
  800426:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800429:	8b 7d 10             	mov    0x10(%ebp),%edi
  80042c:	eb 12                	jmp    800440 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80042e:	85 c0                	test   %eax,%eax
  800430:	0f 84 6a 04 00 00    	je     8008a0 <vprintfmt+0x486>
				return;
			putch(ch, putdat);
  800436:	83 ec 08             	sub    $0x8,%esp
  800439:	53                   	push   %ebx
  80043a:	50                   	push   %eax
  80043b:	ff d6                	call   *%esi
  80043d:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800440:	83 c7 01             	add    $0x1,%edi
  800443:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800447:	83 f8 25             	cmp    $0x25,%eax
  80044a:	75 e2                	jne    80042e <vprintfmt+0x14>
  80044c:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800450:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800457:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80045e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800465:	b9 00 00 00 00       	mov    $0x0,%ecx
  80046a:	eb 07                	jmp    800473 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046c:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80046f:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800473:	8d 47 01             	lea    0x1(%edi),%eax
  800476:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800479:	0f b6 07             	movzbl (%edi),%eax
  80047c:	0f b6 d0             	movzbl %al,%edx
  80047f:	83 e8 23             	sub    $0x23,%eax
  800482:	3c 55                	cmp    $0x55,%al
  800484:	0f 87 fb 03 00 00    	ja     800885 <vprintfmt+0x46b>
  80048a:	0f b6 c0             	movzbl %al,%eax
  80048d:	ff 24 85 c0 25 80 00 	jmp    *0x8025c0(,%eax,4)
  800494:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800497:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80049b:	eb d6                	jmp    800473 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a5:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004a8:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004ab:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8004af:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8004b2:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8004b5:	83 f9 09             	cmp    $0x9,%ecx
  8004b8:	77 3f                	ja     8004f9 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004ba:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004bd:	eb e9                	jmp    8004a8 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c2:	8b 00                	mov    (%eax),%eax
  8004c4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ca:	8d 40 04             	lea    0x4(%eax),%eax
  8004cd:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004d3:	eb 2a                	jmp    8004ff <vprintfmt+0xe5>
  8004d5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004d8:	85 c0                	test   %eax,%eax
  8004da:	ba 00 00 00 00       	mov    $0x0,%edx
  8004df:	0f 49 d0             	cmovns %eax,%edx
  8004e2:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004e8:	eb 89                	jmp    800473 <vprintfmt+0x59>
  8004ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004ed:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004f4:	e9 7a ff ff ff       	jmp    800473 <vprintfmt+0x59>
  8004f9:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8004fc:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8004ff:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800503:	0f 89 6a ff ff ff    	jns    800473 <vprintfmt+0x59>
				width = precision, precision = -1;
  800509:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80050c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80050f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800516:	e9 58 ff ff ff       	jmp    800473 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80051b:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800521:	e9 4d ff ff ff       	jmp    800473 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800526:	8b 45 14             	mov    0x14(%ebp),%eax
  800529:	8d 78 04             	lea    0x4(%eax),%edi
  80052c:	83 ec 08             	sub    $0x8,%esp
  80052f:	53                   	push   %ebx
  800530:	ff 30                	pushl  (%eax)
  800532:	ff d6                	call   *%esi
			break;
  800534:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800537:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80053d:	e9 fe fe ff ff       	jmp    800440 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800542:	8b 45 14             	mov    0x14(%ebp),%eax
  800545:	8d 78 04             	lea    0x4(%eax),%edi
  800548:	8b 00                	mov    (%eax),%eax
  80054a:	99                   	cltd   
  80054b:	31 d0                	xor    %edx,%eax
  80054d:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80054f:	83 f8 0f             	cmp    $0xf,%eax
  800552:	7f 0b                	jg     80055f <vprintfmt+0x145>
  800554:	8b 14 85 20 27 80 00 	mov    0x802720(,%eax,4),%edx
  80055b:	85 d2                	test   %edx,%edx
  80055d:	75 1b                	jne    80057a <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  80055f:	50                   	push   %eax
  800560:	68 9b 24 80 00       	push   $0x80249b
  800565:	53                   	push   %ebx
  800566:	56                   	push   %esi
  800567:	e8 91 fe ff ff       	call   8003fd <printfmt>
  80056c:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80056f:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800572:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800575:	e9 c6 fe ff ff       	jmp    800440 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80057a:	52                   	push   %edx
  80057b:	68 76 29 80 00       	push   $0x802976
  800580:	53                   	push   %ebx
  800581:	56                   	push   %esi
  800582:	e8 76 fe ff ff       	call   8003fd <printfmt>
  800587:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80058a:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800590:	e9 ab fe ff ff       	jmp    800440 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800595:	8b 45 14             	mov    0x14(%ebp),%eax
  800598:	83 c0 04             	add    $0x4,%eax
  80059b:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80059e:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a1:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005a3:	85 ff                	test   %edi,%edi
  8005a5:	b8 94 24 80 00       	mov    $0x802494,%eax
  8005aa:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005ad:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005b1:	0f 8e 94 00 00 00    	jle    80064b <vprintfmt+0x231>
  8005b7:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005bb:	0f 84 98 00 00 00    	je     800659 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005c1:	83 ec 08             	sub    $0x8,%esp
  8005c4:	ff 75 d0             	pushl  -0x30(%ebp)
  8005c7:	57                   	push   %edi
  8005c8:	e8 5b 03 00 00       	call   800928 <strnlen>
  8005cd:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005d0:	29 c1                	sub    %eax,%ecx
  8005d2:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8005d5:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005d8:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005dc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005df:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005e2:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e4:	eb 0f                	jmp    8005f5 <vprintfmt+0x1db>
					putch(padc, putdat);
  8005e6:	83 ec 08             	sub    $0x8,%esp
  8005e9:	53                   	push   %ebx
  8005ea:	ff 75 e0             	pushl  -0x20(%ebp)
  8005ed:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005ef:	83 ef 01             	sub    $0x1,%edi
  8005f2:	83 c4 10             	add    $0x10,%esp
  8005f5:	85 ff                	test   %edi,%edi
  8005f7:	7f ed                	jg     8005e6 <vprintfmt+0x1cc>
  8005f9:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005fc:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8005ff:	85 c9                	test   %ecx,%ecx
  800601:	b8 00 00 00 00       	mov    $0x0,%eax
  800606:	0f 49 c1             	cmovns %ecx,%eax
  800609:	29 c1                	sub    %eax,%ecx
  80060b:	89 75 08             	mov    %esi,0x8(%ebp)
  80060e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800611:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800614:	89 cb                	mov    %ecx,%ebx
  800616:	eb 4d                	jmp    800665 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800618:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80061c:	74 1b                	je     800639 <vprintfmt+0x21f>
  80061e:	0f be c0             	movsbl %al,%eax
  800621:	83 e8 20             	sub    $0x20,%eax
  800624:	83 f8 5e             	cmp    $0x5e,%eax
  800627:	76 10                	jbe    800639 <vprintfmt+0x21f>
					putch('?', putdat);
  800629:	83 ec 08             	sub    $0x8,%esp
  80062c:	ff 75 0c             	pushl  0xc(%ebp)
  80062f:	6a 3f                	push   $0x3f
  800631:	ff 55 08             	call   *0x8(%ebp)
  800634:	83 c4 10             	add    $0x10,%esp
  800637:	eb 0d                	jmp    800646 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  800639:	83 ec 08             	sub    $0x8,%esp
  80063c:	ff 75 0c             	pushl  0xc(%ebp)
  80063f:	52                   	push   %edx
  800640:	ff 55 08             	call   *0x8(%ebp)
  800643:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800646:	83 eb 01             	sub    $0x1,%ebx
  800649:	eb 1a                	jmp    800665 <vprintfmt+0x24b>
  80064b:	89 75 08             	mov    %esi,0x8(%ebp)
  80064e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800651:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800654:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800657:	eb 0c                	jmp    800665 <vprintfmt+0x24b>
  800659:	89 75 08             	mov    %esi,0x8(%ebp)
  80065c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80065f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800662:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800665:	83 c7 01             	add    $0x1,%edi
  800668:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80066c:	0f be d0             	movsbl %al,%edx
  80066f:	85 d2                	test   %edx,%edx
  800671:	74 23                	je     800696 <vprintfmt+0x27c>
  800673:	85 f6                	test   %esi,%esi
  800675:	78 a1                	js     800618 <vprintfmt+0x1fe>
  800677:	83 ee 01             	sub    $0x1,%esi
  80067a:	79 9c                	jns    800618 <vprintfmt+0x1fe>
  80067c:	89 df                	mov    %ebx,%edi
  80067e:	8b 75 08             	mov    0x8(%ebp),%esi
  800681:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800684:	eb 18                	jmp    80069e <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800686:	83 ec 08             	sub    $0x8,%esp
  800689:	53                   	push   %ebx
  80068a:	6a 20                	push   $0x20
  80068c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80068e:	83 ef 01             	sub    $0x1,%edi
  800691:	83 c4 10             	add    $0x10,%esp
  800694:	eb 08                	jmp    80069e <vprintfmt+0x284>
  800696:	89 df                	mov    %ebx,%edi
  800698:	8b 75 08             	mov    0x8(%ebp),%esi
  80069b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80069e:	85 ff                	test   %edi,%edi
  8006a0:	7f e4                	jg     800686 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006a2:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8006a5:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006ab:	e9 90 fd ff ff       	jmp    800440 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006b0:	83 f9 01             	cmp    $0x1,%ecx
  8006b3:	7e 19                	jle    8006ce <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8006b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b8:	8b 50 04             	mov    0x4(%eax),%edx
  8006bb:	8b 00                	mov    (%eax),%eax
  8006bd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006c0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c6:	8d 40 08             	lea    0x8(%eax),%eax
  8006c9:	89 45 14             	mov    %eax,0x14(%ebp)
  8006cc:	eb 38                	jmp    800706 <vprintfmt+0x2ec>
	else if (lflag)
  8006ce:	85 c9                	test   %ecx,%ecx
  8006d0:	74 1b                	je     8006ed <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8006d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d5:	8b 00                	mov    (%eax),%eax
  8006d7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006da:	89 c1                	mov    %eax,%ecx
  8006dc:	c1 f9 1f             	sar    $0x1f,%ecx
  8006df:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e5:	8d 40 04             	lea    0x4(%eax),%eax
  8006e8:	89 45 14             	mov    %eax,0x14(%ebp)
  8006eb:	eb 19                	jmp    800706 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8006ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f0:	8b 00                	mov    (%eax),%eax
  8006f2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006f5:	89 c1                	mov    %eax,%ecx
  8006f7:	c1 f9 1f             	sar    $0x1f,%ecx
  8006fa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800700:	8d 40 04             	lea    0x4(%eax),%eax
  800703:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800706:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800709:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80070c:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800711:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800715:	0f 89 36 01 00 00    	jns    800851 <vprintfmt+0x437>
				putch('-', putdat);
  80071b:	83 ec 08             	sub    $0x8,%esp
  80071e:	53                   	push   %ebx
  80071f:	6a 2d                	push   $0x2d
  800721:	ff d6                	call   *%esi
				num = -(long long) num;
  800723:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800726:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800729:	f7 da                	neg    %edx
  80072b:	83 d1 00             	adc    $0x0,%ecx
  80072e:	f7 d9                	neg    %ecx
  800730:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800733:	b8 0a 00 00 00       	mov    $0xa,%eax
  800738:	e9 14 01 00 00       	jmp    800851 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80073d:	83 f9 01             	cmp    $0x1,%ecx
  800740:	7e 18                	jle    80075a <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800742:	8b 45 14             	mov    0x14(%ebp),%eax
  800745:	8b 10                	mov    (%eax),%edx
  800747:	8b 48 04             	mov    0x4(%eax),%ecx
  80074a:	8d 40 08             	lea    0x8(%eax),%eax
  80074d:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800750:	b8 0a 00 00 00       	mov    $0xa,%eax
  800755:	e9 f7 00 00 00       	jmp    800851 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80075a:	85 c9                	test   %ecx,%ecx
  80075c:	74 1a                	je     800778 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  80075e:	8b 45 14             	mov    0x14(%ebp),%eax
  800761:	8b 10                	mov    (%eax),%edx
  800763:	b9 00 00 00 00       	mov    $0x0,%ecx
  800768:	8d 40 04             	lea    0x4(%eax),%eax
  80076b:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80076e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800773:	e9 d9 00 00 00       	jmp    800851 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800778:	8b 45 14             	mov    0x14(%ebp),%eax
  80077b:	8b 10                	mov    (%eax),%edx
  80077d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800782:	8d 40 04             	lea    0x4(%eax),%eax
  800785:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800788:	b8 0a 00 00 00       	mov    $0xa,%eax
  80078d:	e9 bf 00 00 00       	jmp    800851 <vprintfmt+0x437>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800792:	83 f9 01             	cmp    $0x1,%ecx
  800795:	7e 13                	jle    8007aa <vprintfmt+0x390>
		return va_arg(*ap, long long);
  800797:	8b 45 14             	mov    0x14(%ebp),%eax
  80079a:	8b 50 04             	mov    0x4(%eax),%edx
  80079d:	8b 00                	mov    (%eax),%eax
  80079f:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8007a2:	8d 49 08             	lea    0x8(%ecx),%ecx
  8007a5:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8007a8:	eb 28                	jmp    8007d2 <vprintfmt+0x3b8>
	else if (lflag)
  8007aa:	85 c9                	test   %ecx,%ecx
  8007ac:	74 13                	je     8007c1 <vprintfmt+0x3a7>
		return va_arg(*ap, long);
  8007ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b1:	8b 10                	mov    (%eax),%edx
  8007b3:	89 d0                	mov    %edx,%eax
  8007b5:	99                   	cltd   
  8007b6:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8007b9:	8d 49 04             	lea    0x4(%ecx),%ecx
  8007bc:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8007bf:	eb 11                	jmp    8007d2 <vprintfmt+0x3b8>
	else
		return va_arg(*ap, int);
  8007c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c4:	8b 10                	mov    (%eax),%edx
  8007c6:	89 d0                	mov    %edx,%eax
  8007c8:	99                   	cltd   
  8007c9:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8007cc:	8d 49 04             	lea    0x4(%ecx),%ecx
  8007cf:	89 4d 14             	mov    %ecx,0x14(%ebp)
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getint(&ap, lflag);
  8007d2:	89 d1                	mov    %edx,%ecx
  8007d4:	89 c2                	mov    %eax,%edx
			base = 8;
  8007d6:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8007db:	eb 74                	jmp    800851 <vprintfmt+0x437>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8007dd:	83 ec 08             	sub    $0x8,%esp
  8007e0:	53                   	push   %ebx
  8007e1:	6a 30                	push   $0x30
  8007e3:	ff d6                	call   *%esi
			putch('x', putdat);
  8007e5:	83 c4 08             	add    $0x8,%esp
  8007e8:	53                   	push   %ebx
  8007e9:	6a 78                	push   $0x78
  8007eb:	ff d6                	call   *%esi
			num = (unsigned long long)
  8007ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f0:	8b 10                	mov    (%eax),%edx
  8007f2:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007f7:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007fa:	8d 40 04             	lea    0x4(%eax),%eax
  8007fd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800800:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800805:	eb 4a                	jmp    800851 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800807:	83 f9 01             	cmp    $0x1,%ecx
  80080a:	7e 15                	jle    800821 <vprintfmt+0x407>
		return va_arg(*ap, unsigned long long);
  80080c:	8b 45 14             	mov    0x14(%ebp),%eax
  80080f:	8b 10                	mov    (%eax),%edx
  800811:	8b 48 04             	mov    0x4(%eax),%ecx
  800814:	8d 40 08             	lea    0x8(%eax),%eax
  800817:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80081a:	b8 10 00 00 00       	mov    $0x10,%eax
  80081f:	eb 30                	jmp    800851 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800821:	85 c9                	test   %ecx,%ecx
  800823:	74 17                	je     80083c <vprintfmt+0x422>
		return va_arg(*ap, unsigned long);
  800825:	8b 45 14             	mov    0x14(%ebp),%eax
  800828:	8b 10                	mov    (%eax),%edx
  80082a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80082f:	8d 40 04             	lea    0x4(%eax),%eax
  800832:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800835:	b8 10 00 00 00       	mov    $0x10,%eax
  80083a:	eb 15                	jmp    800851 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80083c:	8b 45 14             	mov    0x14(%ebp),%eax
  80083f:	8b 10                	mov    (%eax),%edx
  800841:	b9 00 00 00 00       	mov    $0x0,%ecx
  800846:	8d 40 04             	lea    0x4(%eax),%eax
  800849:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80084c:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800851:	83 ec 0c             	sub    $0xc,%esp
  800854:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800858:	57                   	push   %edi
  800859:	ff 75 e0             	pushl  -0x20(%ebp)
  80085c:	50                   	push   %eax
  80085d:	51                   	push   %ecx
  80085e:	52                   	push   %edx
  80085f:	89 da                	mov    %ebx,%edx
  800861:	89 f0                	mov    %esi,%eax
  800863:	e8 c9 fa ff ff       	call   800331 <printnum>
			break;
  800868:	83 c4 20             	add    $0x20,%esp
  80086b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80086e:	e9 cd fb ff ff       	jmp    800440 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800873:	83 ec 08             	sub    $0x8,%esp
  800876:	53                   	push   %ebx
  800877:	52                   	push   %edx
  800878:	ff d6                	call   *%esi
			break;
  80087a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80087d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800880:	e9 bb fb ff ff       	jmp    800440 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800885:	83 ec 08             	sub    $0x8,%esp
  800888:	53                   	push   %ebx
  800889:	6a 25                	push   $0x25
  80088b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80088d:	83 c4 10             	add    $0x10,%esp
  800890:	eb 03                	jmp    800895 <vprintfmt+0x47b>
  800892:	83 ef 01             	sub    $0x1,%edi
  800895:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800899:	75 f7                	jne    800892 <vprintfmt+0x478>
  80089b:	e9 a0 fb ff ff       	jmp    800440 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8008a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008a3:	5b                   	pop    %ebx
  8008a4:	5e                   	pop    %esi
  8008a5:	5f                   	pop    %edi
  8008a6:	5d                   	pop    %ebp
  8008a7:	c3                   	ret    

008008a8 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008a8:	55                   	push   %ebp
  8008a9:	89 e5                	mov    %esp,%ebp
  8008ab:	83 ec 18             	sub    $0x18,%esp
  8008ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b1:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008b4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008b7:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008bb:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008be:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008c5:	85 c0                	test   %eax,%eax
  8008c7:	74 26                	je     8008ef <vsnprintf+0x47>
  8008c9:	85 d2                	test   %edx,%edx
  8008cb:	7e 22                	jle    8008ef <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008cd:	ff 75 14             	pushl  0x14(%ebp)
  8008d0:	ff 75 10             	pushl  0x10(%ebp)
  8008d3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008d6:	50                   	push   %eax
  8008d7:	68 e0 03 80 00       	push   $0x8003e0
  8008dc:	e8 39 fb ff ff       	call   80041a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008e1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008e4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008ea:	83 c4 10             	add    $0x10,%esp
  8008ed:	eb 05                	jmp    8008f4 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008ef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008f4:	c9                   	leave  
  8008f5:	c3                   	ret    

008008f6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008f6:	55                   	push   %ebp
  8008f7:	89 e5                	mov    %esp,%ebp
  8008f9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008fc:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008ff:	50                   	push   %eax
  800900:	ff 75 10             	pushl  0x10(%ebp)
  800903:	ff 75 0c             	pushl  0xc(%ebp)
  800906:	ff 75 08             	pushl  0x8(%ebp)
  800909:	e8 9a ff ff ff       	call   8008a8 <vsnprintf>
	va_end(ap);

	return rc;
}
  80090e:	c9                   	leave  
  80090f:	c3                   	ret    

00800910 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800910:	55                   	push   %ebp
  800911:	89 e5                	mov    %esp,%ebp
  800913:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800916:	b8 00 00 00 00       	mov    $0x0,%eax
  80091b:	eb 03                	jmp    800920 <strlen+0x10>
		n++;
  80091d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800920:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800924:	75 f7                	jne    80091d <strlen+0xd>
		n++;
	return n;
}
  800926:	5d                   	pop    %ebp
  800927:	c3                   	ret    

00800928 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800928:	55                   	push   %ebp
  800929:	89 e5                	mov    %esp,%ebp
  80092b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80092e:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800931:	ba 00 00 00 00       	mov    $0x0,%edx
  800936:	eb 03                	jmp    80093b <strnlen+0x13>
		n++;
  800938:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80093b:	39 c2                	cmp    %eax,%edx
  80093d:	74 08                	je     800947 <strnlen+0x1f>
  80093f:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800943:	75 f3                	jne    800938 <strnlen+0x10>
  800945:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800947:	5d                   	pop    %ebp
  800948:	c3                   	ret    

00800949 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800949:	55                   	push   %ebp
  80094a:	89 e5                	mov    %esp,%ebp
  80094c:	53                   	push   %ebx
  80094d:	8b 45 08             	mov    0x8(%ebp),%eax
  800950:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800953:	89 c2                	mov    %eax,%edx
  800955:	83 c2 01             	add    $0x1,%edx
  800958:	83 c1 01             	add    $0x1,%ecx
  80095b:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80095f:	88 5a ff             	mov    %bl,-0x1(%edx)
  800962:	84 db                	test   %bl,%bl
  800964:	75 ef                	jne    800955 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800966:	5b                   	pop    %ebx
  800967:	5d                   	pop    %ebp
  800968:	c3                   	ret    

00800969 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800969:	55                   	push   %ebp
  80096a:	89 e5                	mov    %esp,%ebp
  80096c:	53                   	push   %ebx
  80096d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800970:	53                   	push   %ebx
  800971:	e8 9a ff ff ff       	call   800910 <strlen>
  800976:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800979:	ff 75 0c             	pushl  0xc(%ebp)
  80097c:	01 d8                	add    %ebx,%eax
  80097e:	50                   	push   %eax
  80097f:	e8 c5 ff ff ff       	call   800949 <strcpy>
	return dst;
}
  800984:	89 d8                	mov    %ebx,%eax
  800986:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800989:	c9                   	leave  
  80098a:	c3                   	ret    

0080098b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80098b:	55                   	push   %ebp
  80098c:	89 e5                	mov    %esp,%ebp
  80098e:	56                   	push   %esi
  80098f:	53                   	push   %ebx
  800990:	8b 75 08             	mov    0x8(%ebp),%esi
  800993:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800996:	89 f3                	mov    %esi,%ebx
  800998:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80099b:	89 f2                	mov    %esi,%edx
  80099d:	eb 0f                	jmp    8009ae <strncpy+0x23>
		*dst++ = *src;
  80099f:	83 c2 01             	add    $0x1,%edx
  8009a2:	0f b6 01             	movzbl (%ecx),%eax
  8009a5:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009a8:	80 39 01             	cmpb   $0x1,(%ecx)
  8009ab:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009ae:	39 da                	cmp    %ebx,%edx
  8009b0:	75 ed                	jne    80099f <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009b2:	89 f0                	mov    %esi,%eax
  8009b4:	5b                   	pop    %ebx
  8009b5:	5e                   	pop    %esi
  8009b6:	5d                   	pop    %ebp
  8009b7:	c3                   	ret    

008009b8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009b8:	55                   	push   %ebp
  8009b9:	89 e5                	mov    %esp,%ebp
  8009bb:	56                   	push   %esi
  8009bc:	53                   	push   %ebx
  8009bd:	8b 75 08             	mov    0x8(%ebp),%esi
  8009c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009c3:	8b 55 10             	mov    0x10(%ebp),%edx
  8009c6:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009c8:	85 d2                	test   %edx,%edx
  8009ca:	74 21                	je     8009ed <strlcpy+0x35>
  8009cc:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8009d0:	89 f2                	mov    %esi,%edx
  8009d2:	eb 09                	jmp    8009dd <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009d4:	83 c2 01             	add    $0x1,%edx
  8009d7:	83 c1 01             	add    $0x1,%ecx
  8009da:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009dd:	39 c2                	cmp    %eax,%edx
  8009df:	74 09                	je     8009ea <strlcpy+0x32>
  8009e1:	0f b6 19             	movzbl (%ecx),%ebx
  8009e4:	84 db                	test   %bl,%bl
  8009e6:	75 ec                	jne    8009d4 <strlcpy+0x1c>
  8009e8:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8009ea:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009ed:	29 f0                	sub    %esi,%eax
}
  8009ef:	5b                   	pop    %ebx
  8009f0:	5e                   	pop    %esi
  8009f1:	5d                   	pop    %ebp
  8009f2:	c3                   	ret    

008009f3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009f3:	55                   	push   %ebp
  8009f4:	89 e5                	mov    %esp,%ebp
  8009f6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009f9:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009fc:	eb 06                	jmp    800a04 <strcmp+0x11>
		p++, q++;
  8009fe:	83 c1 01             	add    $0x1,%ecx
  800a01:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a04:	0f b6 01             	movzbl (%ecx),%eax
  800a07:	84 c0                	test   %al,%al
  800a09:	74 04                	je     800a0f <strcmp+0x1c>
  800a0b:	3a 02                	cmp    (%edx),%al
  800a0d:	74 ef                	je     8009fe <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a0f:	0f b6 c0             	movzbl %al,%eax
  800a12:	0f b6 12             	movzbl (%edx),%edx
  800a15:	29 d0                	sub    %edx,%eax
}
  800a17:	5d                   	pop    %ebp
  800a18:	c3                   	ret    

00800a19 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a19:	55                   	push   %ebp
  800a1a:	89 e5                	mov    %esp,%ebp
  800a1c:	53                   	push   %ebx
  800a1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a20:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a23:	89 c3                	mov    %eax,%ebx
  800a25:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a28:	eb 06                	jmp    800a30 <strncmp+0x17>
		n--, p++, q++;
  800a2a:	83 c0 01             	add    $0x1,%eax
  800a2d:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a30:	39 d8                	cmp    %ebx,%eax
  800a32:	74 15                	je     800a49 <strncmp+0x30>
  800a34:	0f b6 08             	movzbl (%eax),%ecx
  800a37:	84 c9                	test   %cl,%cl
  800a39:	74 04                	je     800a3f <strncmp+0x26>
  800a3b:	3a 0a                	cmp    (%edx),%cl
  800a3d:	74 eb                	je     800a2a <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a3f:	0f b6 00             	movzbl (%eax),%eax
  800a42:	0f b6 12             	movzbl (%edx),%edx
  800a45:	29 d0                	sub    %edx,%eax
  800a47:	eb 05                	jmp    800a4e <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a49:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a4e:	5b                   	pop    %ebx
  800a4f:	5d                   	pop    %ebp
  800a50:	c3                   	ret    

00800a51 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a51:	55                   	push   %ebp
  800a52:	89 e5                	mov    %esp,%ebp
  800a54:	8b 45 08             	mov    0x8(%ebp),%eax
  800a57:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a5b:	eb 07                	jmp    800a64 <strchr+0x13>
		if (*s == c)
  800a5d:	38 ca                	cmp    %cl,%dl
  800a5f:	74 0f                	je     800a70 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a61:	83 c0 01             	add    $0x1,%eax
  800a64:	0f b6 10             	movzbl (%eax),%edx
  800a67:	84 d2                	test   %dl,%dl
  800a69:	75 f2                	jne    800a5d <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a6b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a70:	5d                   	pop    %ebp
  800a71:	c3                   	ret    

00800a72 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a72:	55                   	push   %ebp
  800a73:	89 e5                	mov    %esp,%ebp
  800a75:	8b 45 08             	mov    0x8(%ebp),%eax
  800a78:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a7c:	eb 03                	jmp    800a81 <strfind+0xf>
  800a7e:	83 c0 01             	add    $0x1,%eax
  800a81:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a84:	38 ca                	cmp    %cl,%dl
  800a86:	74 04                	je     800a8c <strfind+0x1a>
  800a88:	84 d2                	test   %dl,%dl
  800a8a:	75 f2                	jne    800a7e <strfind+0xc>
			break;
	return (char *) s;
}
  800a8c:	5d                   	pop    %ebp
  800a8d:	c3                   	ret    

00800a8e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a8e:	55                   	push   %ebp
  800a8f:	89 e5                	mov    %esp,%ebp
  800a91:	57                   	push   %edi
  800a92:	56                   	push   %esi
  800a93:	53                   	push   %ebx
  800a94:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a97:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a9a:	85 c9                	test   %ecx,%ecx
  800a9c:	74 36                	je     800ad4 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a9e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800aa4:	75 28                	jne    800ace <memset+0x40>
  800aa6:	f6 c1 03             	test   $0x3,%cl
  800aa9:	75 23                	jne    800ace <memset+0x40>
		c &= 0xFF;
  800aab:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800aaf:	89 d3                	mov    %edx,%ebx
  800ab1:	c1 e3 08             	shl    $0x8,%ebx
  800ab4:	89 d6                	mov    %edx,%esi
  800ab6:	c1 e6 18             	shl    $0x18,%esi
  800ab9:	89 d0                	mov    %edx,%eax
  800abb:	c1 e0 10             	shl    $0x10,%eax
  800abe:	09 f0                	or     %esi,%eax
  800ac0:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800ac2:	89 d8                	mov    %ebx,%eax
  800ac4:	09 d0                	or     %edx,%eax
  800ac6:	c1 e9 02             	shr    $0x2,%ecx
  800ac9:	fc                   	cld    
  800aca:	f3 ab                	rep stos %eax,%es:(%edi)
  800acc:	eb 06                	jmp    800ad4 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ace:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ad1:	fc                   	cld    
  800ad2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ad4:	89 f8                	mov    %edi,%eax
  800ad6:	5b                   	pop    %ebx
  800ad7:	5e                   	pop    %esi
  800ad8:	5f                   	pop    %edi
  800ad9:	5d                   	pop    %ebp
  800ada:	c3                   	ret    

00800adb <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800adb:	55                   	push   %ebp
  800adc:	89 e5                	mov    %esp,%ebp
  800ade:	57                   	push   %edi
  800adf:	56                   	push   %esi
  800ae0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae3:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ae6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ae9:	39 c6                	cmp    %eax,%esi
  800aeb:	73 35                	jae    800b22 <memmove+0x47>
  800aed:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800af0:	39 d0                	cmp    %edx,%eax
  800af2:	73 2e                	jae    800b22 <memmove+0x47>
		s += n;
		d += n;
  800af4:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800af7:	89 d6                	mov    %edx,%esi
  800af9:	09 fe                	or     %edi,%esi
  800afb:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b01:	75 13                	jne    800b16 <memmove+0x3b>
  800b03:	f6 c1 03             	test   $0x3,%cl
  800b06:	75 0e                	jne    800b16 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b08:	83 ef 04             	sub    $0x4,%edi
  800b0b:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b0e:	c1 e9 02             	shr    $0x2,%ecx
  800b11:	fd                   	std    
  800b12:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b14:	eb 09                	jmp    800b1f <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b16:	83 ef 01             	sub    $0x1,%edi
  800b19:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b1c:	fd                   	std    
  800b1d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b1f:	fc                   	cld    
  800b20:	eb 1d                	jmp    800b3f <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b22:	89 f2                	mov    %esi,%edx
  800b24:	09 c2                	or     %eax,%edx
  800b26:	f6 c2 03             	test   $0x3,%dl
  800b29:	75 0f                	jne    800b3a <memmove+0x5f>
  800b2b:	f6 c1 03             	test   $0x3,%cl
  800b2e:	75 0a                	jne    800b3a <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b30:	c1 e9 02             	shr    $0x2,%ecx
  800b33:	89 c7                	mov    %eax,%edi
  800b35:	fc                   	cld    
  800b36:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b38:	eb 05                	jmp    800b3f <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b3a:	89 c7                	mov    %eax,%edi
  800b3c:	fc                   	cld    
  800b3d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b3f:	5e                   	pop    %esi
  800b40:	5f                   	pop    %edi
  800b41:	5d                   	pop    %ebp
  800b42:	c3                   	ret    

00800b43 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b43:	55                   	push   %ebp
  800b44:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b46:	ff 75 10             	pushl  0x10(%ebp)
  800b49:	ff 75 0c             	pushl  0xc(%ebp)
  800b4c:	ff 75 08             	pushl  0x8(%ebp)
  800b4f:	e8 87 ff ff ff       	call   800adb <memmove>
}
  800b54:	c9                   	leave  
  800b55:	c3                   	ret    

00800b56 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b56:	55                   	push   %ebp
  800b57:	89 e5                	mov    %esp,%ebp
  800b59:	56                   	push   %esi
  800b5a:	53                   	push   %ebx
  800b5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b61:	89 c6                	mov    %eax,%esi
  800b63:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b66:	eb 1a                	jmp    800b82 <memcmp+0x2c>
		if (*s1 != *s2)
  800b68:	0f b6 08             	movzbl (%eax),%ecx
  800b6b:	0f b6 1a             	movzbl (%edx),%ebx
  800b6e:	38 d9                	cmp    %bl,%cl
  800b70:	74 0a                	je     800b7c <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b72:	0f b6 c1             	movzbl %cl,%eax
  800b75:	0f b6 db             	movzbl %bl,%ebx
  800b78:	29 d8                	sub    %ebx,%eax
  800b7a:	eb 0f                	jmp    800b8b <memcmp+0x35>
		s1++, s2++;
  800b7c:	83 c0 01             	add    $0x1,%eax
  800b7f:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b82:	39 f0                	cmp    %esi,%eax
  800b84:	75 e2                	jne    800b68 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b86:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b8b:	5b                   	pop    %ebx
  800b8c:	5e                   	pop    %esi
  800b8d:	5d                   	pop    %ebp
  800b8e:	c3                   	ret    

00800b8f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b8f:	55                   	push   %ebp
  800b90:	89 e5                	mov    %esp,%ebp
  800b92:	53                   	push   %ebx
  800b93:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b96:	89 c1                	mov    %eax,%ecx
  800b98:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800b9b:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b9f:	eb 0a                	jmp    800bab <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ba1:	0f b6 10             	movzbl (%eax),%edx
  800ba4:	39 da                	cmp    %ebx,%edx
  800ba6:	74 07                	je     800baf <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ba8:	83 c0 01             	add    $0x1,%eax
  800bab:	39 c8                	cmp    %ecx,%eax
  800bad:	72 f2                	jb     800ba1 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800baf:	5b                   	pop    %ebx
  800bb0:	5d                   	pop    %ebp
  800bb1:	c3                   	ret    

00800bb2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bb2:	55                   	push   %ebp
  800bb3:	89 e5                	mov    %esp,%ebp
  800bb5:	57                   	push   %edi
  800bb6:	56                   	push   %esi
  800bb7:	53                   	push   %ebx
  800bb8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bbb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bbe:	eb 03                	jmp    800bc3 <strtol+0x11>
		s++;
  800bc0:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bc3:	0f b6 01             	movzbl (%ecx),%eax
  800bc6:	3c 20                	cmp    $0x20,%al
  800bc8:	74 f6                	je     800bc0 <strtol+0xe>
  800bca:	3c 09                	cmp    $0x9,%al
  800bcc:	74 f2                	je     800bc0 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bce:	3c 2b                	cmp    $0x2b,%al
  800bd0:	75 0a                	jne    800bdc <strtol+0x2a>
		s++;
  800bd2:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bd5:	bf 00 00 00 00       	mov    $0x0,%edi
  800bda:	eb 11                	jmp    800bed <strtol+0x3b>
  800bdc:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800be1:	3c 2d                	cmp    $0x2d,%al
  800be3:	75 08                	jne    800bed <strtol+0x3b>
		s++, neg = 1;
  800be5:	83 c1 01             	add    $0x1,%ecx
  800be8:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bed:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800bf3:	75 15                	jne    800c0a <strtol+0x58>
  800bf5:	80 39 30             	cmpb   $0x30,(%ecx)
  800bf8:	75 10                	jne    800c0a <strtol+0x58>
  800bfa:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bfe:	75 7c                	jne    800c7c <strtol+0xca>
		s += 2, base = 16;
  800c00:	83 c1 02             	add    $0x2,%ecx
  800c03:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c08:	eb 16                	jmp    800c20 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c0a:	85 db                	test   %ebx,%ebx
  800c0c:	75 12                	jne    800c20 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c0e:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c13:	80 39 30             	cmpb   $0x30,(%ecx)
  800c16:	75 08                	jne    800c20 <strtol+0x6e>
		s++, base = 8;
  800c18:	83 c1 01             	add    $0x1,%ecx
  800c1b:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c20:	b8 00 00 00 00       	mov    $0x0,%eax
  800c25:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c28:	0f b6 11             	movzbl (%ecx),%edx
  800c2b:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c2e:	89 f3                	mov    %esi,%ebx
  800c30:	80 fb 09             	cmp    $0x9,%bl
  800c33:	77 08                	ja     800c3d <strtol+0x8b>
			dig = *s - '0';
  800c35:	0f be d2             	movsbl %dl,%edx
  800c38:	83 ea 30             	sub    $0x30,%edx
  800c3b:	eb 22                	jmp    800c5f <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c3d:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c40:	89 f3                	mov    %esi,%ebx
  800c42:	80 fb 19             	cmp    $0x19,%bl
  800c45:	77 08                	ja     800c4f <strtol+0x9d>
			dig = *s - 'a' + 10;
  800c47:	0f be d2             	movsbl %dl,%edx
  800c4a:	83 ea 57             	sub    $0x57,%edx
  800c4d:	eb 10                	jmp    800c5f <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800c4f:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c52:	89 f3                	mov    %esi,%ebx
  800c54:	80 fb 19             	cmp    $0x19,%bl
  800c57:	77 16                	ja     800c6f <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c59:	0f be d2             	movsbl %dl,%edx
  800c5c:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c5f:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c62:	7d 0b                	jge    800c6f <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800c64:	83 c1 01             	add    $0x1,%ecx
  800c67:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c6b:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c6d:	eb b9                	jmp    800c28 <strtol+0x76>

	if (endptr)
  800c6f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c73:	74 0d                	je     800c82 <strtol+0xd0>
		*endptr = (char *) s;
  800c75:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c78:	89 0e                	mov    %ecx,(%esi)
  800c7a:	eb 06                	jmp    800c82 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c7c:	85 db                	test   %ebx,%ebx
  800c7e:	74 98                	je     800c18 <strtol+0x66>
  800c80:	eb 9e                	jmp    800c20 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800c82:	89 c2                	mov    %eax,%edx
  800c84:	f7 da                	neg    %edx
  800c86:	85 ff                	test   %edi,%edi
  800c88:	0f 45 c2             	cmovne %edx,%eax
}
  800c8b:	5b                   	pop    %ebx
  800c8c:	5e                   	pop    %esi
  800c8d:	5f                   	pop    %edi
  800c8e:	5d                   	pop    %ebp
  800c8f:	c3                   	ret    

00800c90 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c90:	55                   	push   %ebp
  800c91:	89 e5                	mov    %esp,%ebp
  800c93:	57                   	push   %edi
  800c94:	56                   	push   %esi
  800c95:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c96:	b8 00 00 00 00       	mov    $0x0,%eax
  800c9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca1:	89 c3                	mov    %eax,%ebx
  800ca3:	89 c7                	mov    %eax,%edi
  800ca5:	89 c6                	mov    %eax,%esi
  800ca7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ca9:	5b                   	pop    %ebx
  800caa:	5e                   	pop    %esi
  800cab:	5f                   	pop    %edi
  800cac:	5d                   	pop    %ebp
  800cad:	c3                   	ret    

00800cae <sys_cgetc>:

int
sys_cgetc(void)
{
  800cae:	55                   	push   %ebp
  800caf:	89 e5                	mov    %esp,%ebp
  800cb1:	57                   	push   %edi
  800cb2:	56                   	push   %esi
  800cb3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb4:	ba 00 00 00 00       	mov    $0x0,%edx
  800cb9:	b8 01 00 00 00       	mov    $0x1,%eax
  800cbe:	89 d1                	mov    %edx,%ecx
  800cc0:	89 d3                	mov    %edx,%ebx
  800cc2:	89 d7                	mov    %edx,%edi
  800cc4:	89 d6                	mov    %edx,%esi
  800cc6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cc8:	5b                   	pop    %ebx
  800cc9:	5e                   	pop    %esi
  800cca:	5f                   	pop    %edi
  800ccb:	5d                   	pop    %ebp
  800ccc:	c3                   	ret    

00800ccd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ccd:	55                   	push   %ebp
  800cce:	89 e5                	mov    %esp,%ebp
  800cd0:	57                   	push   %edi
  800cd1:	56                   	push   %esi
  800cd2:	53                   	push   %ebx
  800cd3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cdb:	b8 03 00 00 00       	mov    $0x3,%eax
  800ce0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce3:	89 cb                	mov    %ecx,%ebx
  800ce5:	89 cf                	mov    %ecx,%edi
  800ce7:	89 ce                	mov    %ecx,%esi
  800ce9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ceb:	85 c0                	test   %eax,%eax
  800ced:	7e 17                	jle    800d06 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cef:	83 ec 0c             	sub    $0xc,%esp
  800cf2:	50                   	push   %eax
  800cf3:	6a 03                	push   $0x3
  800cf5:	68 7f 27 80 00       	push   $0x80277f
  800cfa:	6a 23                	push   $0x23
  800cfc:	68 9c 27 80 00       	push   $0x80279c
  800d01:	e8 3e f5 ff ff       	call   800244 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d06:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d09:	5b                   	pop    %ebx
  800d0a:	5e                   	pop    %esi
  800d0b:	5f                   	pop    %edi
  800d0c:	5d                   	pop    %ebp
  800d0d:	c3                   	ret    

00800d0e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d0e:	55                   	push   %ebp
  800d0f:	89 e5                	mov    %esp,%ebp
  800d11:	57                   	push   %edi
  800d12:	56                   	push   %esi
  800d13:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d14:	ba 00 00 00 00       	mov    $0x0,%edx
  800d19:	b8 02 00 00 00       	mov    $0x2,%eax
  800d1e:	89 d1                	mov    %edx,%ecx
  800d20:	89 d3                	mov    %edx,%ebx
  800d22:	89 d7                	mov    %edx,%edi
  800d24:	89 d6                	mov    %edx,%esi
  800d26:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d28:	5b                   	pop    %ebx
  800d29:	5e                   	pop    %esi
  800d2a:	5f                   	pop    %edi
  800d2b:	5d                   	pop    %ebp
  800d2c:	c3                   	ret    

00800d2d <sys_yield>:

void
sys_yield(void)
{
  800d2d:	55                   	push   %ebp
  800d2e:	89 e5                	mov    %esp,%ebp
  800d30:	57                   	push   %edi
  800d31:	56                   	push   %esi
  800d32:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d33:	ba 00 00 00 00       	mov    $0x0,%edx
  800d38:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d3d:	89 d1                	mov    %edx,%ecx
  800d3f:	89 d3                	mov    %edx,%ebx
  800d41:	89 d7                	mov    %edx,%edi
  800d43:	89 d6                	mov    %edx,%esi
  800d45:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d47:	5b                   	pop    %ebx
  800d48:	5e                   	pop    %esi
  800d49:	5f                   	pop    %edi
  800d4a:	5d                   	pop    %ebp
  800d4b:	c3                   	ret    

00800d4c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d4c:	55                   	push   %ebp
  800d4d:	89 e5                	mov    %esp,%ebp
  800d4f:	57                   	push   %edi
  800d50:	56                   	push   %esi
  800d51:	53                   	push   %ebx
  800d52:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d55:	be 00 00 00 00       	mov    $0x0,%esi
  800d5a:	b8 04 00 00 00       	mov    $0x4,%eax
  800d5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d62:	8b 55 08             	mov    0x8(%ebp),%edx
  800d65:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d68:	89 f7                	mov    %esi,%edi
  800d6a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d6c:	85 c0                	test   %eax,%eax
  800d6e:	7e 17                	jle    800d87 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d70:	83 ec 0c             	sub    $0xc,%esp
  800d73:	50                   	push   %eax
  800d74:	6a 04                	push   $0x4
  800d76:	68 7f 27 80 00       	push   $0x80277f
  800d7b:	6a 23                	push   $0x23
  800d7d:	68 9c 27 80 00       	push   $0x80279c
  800d82:	e8 bd f4 ff ff       	call   800244 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d87:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d8a:	5b                   	pop    %ebx
  800d8b:	5e                   	pop    %esi
  800d8c:	5f                   	pop    %edi
  800d8d:	5d                   	pop    %ebp
  800d8e:	c3                   	ret    

00800d8f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d8f:	55                   	push   %ebp
  800d90:	89 e5                	mov    %esp,%ebp
  800d92:	57                   	push   %edi
  800d93:	56                   	push   %esi
  800d94:	53                   	push   %ebx
  800d95:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d98:	b8 05 00 00 00       	mov    $0x5,%eax
  800d9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da0:	8b 55 08             	mov    0x8(%ebp),%edx
  800da3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800da6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800da9:	8b 75 18             	mov    0x18(%ebp),%esi
  800dac:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dae:	85 c0                	test   %eax,%eax
  800db0:	7e 17                	jle    800dc9 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800db2:	83 ec 0c             	sub    $0xc,%esp
  800db5:	50                   	push   %eax
  800db6:	6a 05                	push   $0x5
  800db8:	68 7f 27 80 00       	push   $0x80277f
  800dbd:	6a 23                	push   $0x23
  800dbf:	68 9c 27 80 00       	push   $0x80279c
  800dc4:	e8 7b f4 ff ff       	call   800244 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800dc9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dcc:	5b                   	pop    %ebx
  800dcd:	5e                   	pop    %esi
  800dce:	5f                   	pop    %edi
  800dcf:	5d                   	pop    %ebp
  800dd0:	c3                   	ret    

00800dd1 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800dd1:	55                   	push   %ebp
  800dd2:	89 e5                	mov    %esp,%ebp
  800dd4:	57                   	push   %edi
  800dd5:	56                   	push   %esi
  800dd6:	53                   	push   %ebx
  800dd7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dda:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ddf:	b8 06 00 00 00       	mov    $0x6,%eax
  800de4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de7:	8b 55 08             	mov    0x8(%ebp),%edx
  800dea:	89 df                	mov    %ebx,%edi
  800dec:	89 de                	mov    %ebx,%esi
  800dee:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800df0:	85 c0                	test   %eax,%eax
  800df2:	7e 17                	jle    800e0b <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800df4:	83 ec 0c             	sub    $0xc,%esp
  800df7:	50                   	push   %eax
  800df8:	6a 06                	push   $0x6
  800dfa:	68 7f 27 80 00       	push   $0x80277f
  800dff:	6a 23                	push   $0x23
  800e01:	68 9c 27 80 00       	push   $0x80279c
  800e06:	e8 39 f4 ff ff       	call   800244 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e0e:	5b                   	pop    %ebx
  800e0f:	5e                   	pop    %esi
  800e10:	5f                   	pop    %edi
  800e11:	5d                   	pop    %ebp
  800e12:	c3                   	ret    

00800e13 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e13:	55                   	push   %ebp
  800e14:	89 e5                	mov    %esp,%ebp
  800e16:	57                   	push   %edi
  800e17:	56                   	push   %esi
  800e18:	53                   	push   %ebx
  800e19:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e1c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e21:	b8 08 00 00 00       	mov    $0x8,%eax
  800e26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e29:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2c:	89 df                	mov    %ebx,%edi
  800e2e:	89 de                	mov    %ebx,%esi
  800e30:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e32:	85 c0                	test   %eax,%eax
  800e34:	7e 17                	jle    800e4d <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e36:	83 ec 0c             	sub    $0xc,%esp
  800e39:	50                   	push   %eax
  800e3a:	6a 08                	push   $0x8
  800e3c:	68 7f 27 80 00       	push   $0x80277f
  800e41:	6a 23                	push   $0x23
  800e43:	68 9c 27 80 00       	push   $0x80279c
  800e48:	e8 f7 f3 ff ff       	call   800244 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e4d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e50:	5b                   	pop    %ebx
  800e51:	5e                   	pop    %esi
  800e52:	5f                   	pop    %edi
  800e53:	5d                   	pop    %ebp
  800e54:	c3                   	ret    

00800e55 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e55:	55                   	push   %ebp
  800e56:	89 e5                	mov    %esp,%ebp
  800e58:	57                   	push   %edi
  800e59:	56                   	push   %esi
  800e5a:	53                   	push   %ebx
  800e5b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e5e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e63:	b8 09 00 00 00       	mov    $0x9,%eax
  800e68:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e6b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6e:	89 df                	mov    %ebx,%edi
  800e70:	89 de                	mov    %ebx,%esi
  800e72:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e74:	85 c0                	test   %eax,%eax
  800e76:	7e 17                	jle    800e8f <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e78:	83 ec 0c             	sub    $0xc,%esp
  800e7b:	50                   	push   %eax
  800e7c:	6a 09                	push   $0x9
  800e7e:	68 7f 27 80 00       	push   $0x80277f
  800e83:	6a 23                	push   $0x23
  800e85:	68 9c 27 80 00       	push   $0x80279c
  800e8a:	e8 b5 f3 ff ff       	call   800244 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e92:	5b                   	pop    %ebx
  800e93:	5e                   	pop    %esi
  800e94:	5f                   	pop    %edi
  800e95:	5d                   	pop    %ebp
  800e96:	c3                   	ret    

00800e97 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e97:	55                   	push   %ebp
  800e98:	89 e5                	mov    %esp,%ebp
  800e9a:	57                   	push   %edi
  800e9b:	56                   	push   %esi
  800e9c:	53                   	push   %ebx
  800e9d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ea0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ea5:	b8 0a 00 00 00       	mov    $0xa,%eax
  800eaa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ead:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb0:	89 df                	mov    %ebx,%edi
  800eb2:	89 de                	mov    %ebx,%esi
  800eb4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800eb6:	85 c0                	test   %eax,%eax
  800eb8:	7e 17                	jle    800ed1 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eba:	83 ec 0c             	sub    $0xc,%esp
  800ebd:	50                   	push   %eax
  800ebe:	6a 0a                	push   $0xa
  800ec0:	68 7f 27 80 00       	push   $0x80277f
  800ec5:	6a 23                	push   $0x23
  800ec7:	68 9c 27 80 00       	push   $0x80279c
  800ecc:	e8 73 f3 ff ff       	call   800244 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ed1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ed4:	5b                   	pop    %ebx
  800ed5:	5e                   	pop    %esi
  800ed6:	5f                   	pop    %edi
  800ed7:	5d                   	pop    %ebp
  800ed8:	c3                   	ret    

00800ed9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ed9:	55                   	push   %ebp
  800eda:	89 e5                	mov    %esp,%ebp
  800edc:	57                   	push   %edi
  800edd:	56                   	push   %esi
  800ede:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800edf:	be 00 00 00 00       	mov    $0x0,%esi
  800ee4:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ee9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eec:	8b 55 08             	mov    0x8(%ebp),%edx
  800eef:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ef2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ef5:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ef7:	5b                   	pop    %ebx
  800ef8:	5e                   	pop    %esi
  800ef9:	5f                   	pop    %edi
  800efa:	5d                   	pop    %ebp
  800efb:	c3                   	ret    

00800efc <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800efc:	55                   	push   %ebp
  800efd:	89 e5                	mov    %esp,%ebp
  800eff:	57                   	push   %edi
  800f00:	56                   	push   %esi
  800f01:	53                   	push   %ebx
  800f02:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f05:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f0a:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800f12:	89 cb                	mov    %ecx,%ebx
  800f14:	89 cf                	mov    %ecx,%edi
  800f16:	89 ce                	mov    %ecx,%esi
  800f18:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f1a:	85 c0                	test   %eax,%eax
  800f1c:	7e 17                	jle    800f35 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f1e:	83 ec 0c             	sub    $0xc,%esp
  800f21:	50                   	push   %eax
  800f22:	6a 0d                	push   $0xd
  800f24:	68 7f 27 80 00       	push   $0x80277f
  800f29:	6a 23                	push   $0x23
  800f2b:	68 9c 27 80 00       	push   $0x80279c
  800f30:	e8 0f f3 ff ff       	call   800244 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f35:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f38:	5b                   	pop    %ebx
  800f39:	5e                   	pop    %esi
  800f3a:	5f                   	pop    %edi
  800f3b:	5d                   	pop    %ebp
  800f3c:	c3                   	ret    

00800f3d <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f3d:	55                   	push   %ebp
  800f3e:	89 e5                	mov    %esp,%ebp
  800f40:	53                   	push   %ebx
  800f41:	83 ec 04             	sub    $0x4,%esp
  800f44:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f47:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & 
  800f49:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f4d:	0f 84 48 01 00 00    	je     80109b <pgfault+0x15e>
  800f53:	89 d8                	mov    %ebx,%eax
  800f55:	c1 e8 16             	shr    $0x16,%eax
  800f58:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f5f:	a8 01                	test   $0x1,%al
  800f61:	0f 84 5f 01 00 00    	je     8010c6 <pgfault+0x189>
  800f67:	89 d8                	mov    %ebx,%eax
  800f69:	c1 e8 0c             	shr    $0xc,%eax
  800f6c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f73:	f6 c2 01             	test   $0x1,%dl
  800f76:	0f 84 4a 01 00 00    	je     8010c6 <pgfault+0x189>
				PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW))) {
  800f7c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & 
  800f83:	f6 c4 08             	test   $0x8,%ah
  800f86:	75 79                	jne    801001 <pgfault+0xc4>
  800f88:	e9 39 01 00 00       	jmp    8010c6 <pgfault+0x189>
				PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW))) {
		cprintf("Fault address = %08x, envid = %08x\n", addr, thisenv->env_id);
		if (!(err & FEC_WR)) cprintf("Not write\n");
		if (!(uvpd[PDX(addr)] & PTE_P)) cprintf("PDE not present\n");
  800f8d:	89 d8                	mov    %ebx,%eax
  800f8f:	c1 e8 16             	shr    $0x16,%eax
  800f92:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f99:	a8 01                	test   $0x1,%al
  800f9b:	75 10                	jne    800fad <pgfault+0x70>
  800f9d:	83 ec 0c             	sub    $0xc,%esp
  800fa0:	68 aa 27 80 00       	push   $0x8027aa
  800fa5:	e8 73 f3 ff ff       	call   80031d <cprintf>
  800faa:	83 c4 10             	add    $0x10,%esp
		if (!(uvpt[PTX(addr)] & PTE_P)) cprintf("PTE not present\n");
  800fad:	c1 eb 0c             	shr    $0xc,%ebx
  800fb0:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  800fb6:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800fbd:	a8 01                	test   $0x1,%al
  800fbf:	75 10                	jne    800fd1 <pgfault+0x94>
  800fc1:	83 ec 0c             	sub    $0xc,%esp
  800fc4:	68 bb 27 80 00       	push   $0x8027bb
  800fc9:	e8 4f f3 ff ff       	call   80031d <cprintf>
  800fce:	83 c4 10             	add    $0x10,%esp
		if (!(uvpt[PTX(addr)] & PTE_COW)) cprintf("Not copy-on-write\n");
  800fd1:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800fd8:	f6 c4 08             	test   $0x8,%ah
  800fdb:	75 10                	jne    800fed <pgfault+0xb0>
  800fdd:	83 ec 0c             	sub    $0xc,%esp
  800fe0:	68 cc 27 80 00       	push   $0x8027cc
  800fe5:	e8 33 f3 ff ff       	call   80031d <cprintf>
  800fea:	83 c4 10             	add    $0x10,%esp
		panic("User page fault");
  800fed:	83 ec 04             	sub    $0x4,%esp
  800ff0:	68 df 27 80 00       	push   $0x8027df
  800ff5:	6a 23                	push   $0x23
  800ff7:	68 ef 27 80 00       	push   $0x8027ef
  800ffc:	e8 43 f2 ff ff       	call   800244 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// 0 refers to curenv
	if ((r = sys_page_alloc(0, (void*)PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  801001:	83 ec 04             	sub    $0x4,%esp
  801004:	6a 07                	push   $0x7
  801006:	68 00 f0 7f 00       	push   $0x7ff000
  80100b:	6a 00                	push   $0x0
  80100d:	e8 3a fd ff ff       	call   800d4c <sys_page_alloc>
  801012:	83 c4 10             	add    $0x10,%esp
  801015:	85 c0                	test   %eax,%eax
  801017:	79 12                	jns    80102b <pgfault+0xee>
		panic("sys_page_alloc failed: %e", r);
  801019:	50                   	push   %eax
  80101a:	68 fa 27 80 00       	push   $0x8027fa
  80101f:	6a 2f                	push   $0x2f
  801021:	68 ef 27 80 00       	push   $0x8027ef
  801026:	e8 19 f2 ff ff       	call   800244 <_panic>
	memcpy((void*)PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  80102b:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  801031:	83 ec 04             	sub    $0x4,%esp
  801034:	68 00 10 00 00       	push   $0x1000
  801039:	53                   	push   %ebx
  80103a:	68 00 f0 7f 00       	push   $0x7ff000
  80103f:	e8 ff fa ff ff       	call   800b43 <memcpy>
	if ((r = sys_page_map(0, (void*)PFTEMP, 0, (void*)ROUNDDOWN(addr, PGSIZE), 
  801044:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  80104b:	53                   	push   %ebx
  80104c:	6a 00                	push   $0x0
  80104e:	68 00 f0 7f 00       	push   $0x7ff000
  801053:	6a 00                	push   $0x0
  801055:	e8 35 fd ff ff       	call   800d8f <sys_page_map>
  80105a:	83 c4 20             	add    $0x20,%esp
  80105d:	85 c0                	test   %eax,%eax
  80105f:	79 12                	jns    801073 <pgfault+0x136>
					PTE_P | PTE_U | PTE_W)) < 0)
		panic("sys_page_map failed: %e", r);
  801061:	50                   	push   %eax
  801062:	68 14 28 80 00       	push   $0x802814
  801067:	6a 33                	push   $0x33
  801069:	68 ef 27 80 00       	push   $0x8027ef
  80106e:	e8 d1 f1 ff ff       	call   800244 <_panic>
	if ((r = sys_page_unmap(0, (void*)PFTEMP)) < 0)
  801073:	83 ec 08             	sub    $0x8,%esp
  801076:	68 00 f0 7f 00       	push   $0x7ff000
  80107b:	6a 00                	push   $0x0
  80107d:	e8 4f fd ff ff       	call   800dd1 <sys_page_unmap>
  801082:	83 c4 10             	add    $0x10,%esp
  801085:	85 c0                	test   %eax,%eax
  801087:	79 5c                	jns    8010e5 <pgfault+0x1a8>
		panic("sys_page_unmap failed: %e", r);
  801089:	50                   	push   %eax
  80108a:	68 2c 28 80 00       	push   $0x80282c
  80108f:	6a 35                	push   $0x35
  801091:	68 ef 27 80 00       	push   $0x8027ef
  801096:	e8 a9 f1 ff ff       	call   800244 <_panic>
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & 
				PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW))) {
		cprintf("Fault address = %08x, envid = %08x\n", addr, thisenv->env_id);
  80109b:	a1 04 40 80 00       	mov    0x804004,%eax
  8010a0:	8b 40 48             	mov    0x48(%eax),%eax
  8010a3:	83 ec 04             	sub    $0x4,%esp
  8010a6:	50                   	push   %eax
  8010a7:	53                   	push   %ebx
  8010a8:	68 68 28 80 00       	push   $0x802868
  8010ad:	e8 6b f2 ff ff       	call   80031d <cprintf>
		if (!(err & FEC_WR)) cprintf("Not write\n");
  8010b2:	c7 04 24 46 28 80 00 	movl   $0x802846,(%esp)
  8010b9:	e8 5f f2 ff ff       	call   80031d <cprintf>
  8010be:	83 c4 10             	add    $0x10,%esp
  8010c1:	e9 c7 fe ff ff       	jmp    800f8d <pgfault+0x50>
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & 
				PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW))) {
		cprintf("Fault address = %08x, envid = %08x\n", addr, thisenv->env_id);
  8010c6:	a1 04 40 80 00       	mov    0x804004,%eax
  8010cb:	8b 40 48             	mov    0x48(%eax),%eax
  8010ce:	83 ec 04             	sub    $0x4,%esp
  8010d1:	50                   	push   %eax
  8010d2:	53                   	push   %ebx
  8010d3:	68 68 28 80 00       	push   $0x802868
  8010d8:	e8 40 f2 ff ff       	call   80031d <cprintf>
  8010dd:	83 c4 10             	add    $0x10,%esp
  8010e0:	e9 a8 fe ff ff       	jmp    800f8d <pgfault+0x50>
		panic("sys_page_map failed: %e", r);
	if ((r = sys_page_unmap(0, (void*)PFTEMP)) < 0)
		panic("sys_page_unmap failed: %e", r);

	// panic("pgfault not implemented");
}
  8010e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010e8:	c9                   	leave  
  8010e9:	c3                   	ret    

008010ea <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8010ea:	55                   	push   %ebp
  8010eb:	89 e5                	mov    %esp,%ebp
  8010ed:	57                   	push   %edi
  8010ee:	56                   	push   %esi
  8010ef:	53                   	push   %ebx
  8010f0:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	int ret;
	set_pgfault_handler(pgfault);
  8010f3:	68 3d 0f 80 00       	push   $0x800f3d
  8010f8:	e8 45 0f 00 00       	call   802042 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8010fd:	b8 07 00 00 00       	mov    $0x7,%eax
  801102:	cd 30                	int    $0x30
  801104:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801107:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	envid_t envid = sys_exofork();

	if (envid < 0) return envid;
  80110a:	83 c4 10             	add    $0x10,%esp
  80110d:	85 c0                	test   %eax,%eax
  80110f:	0f 88 0d 01 00 00    	js     801222 <fork+0x138>
  801115:	bb 00 00 00 00       	mov    $0x0,%ebx
  80111a:	be 00 00 00 00       	mov    $0x0,%esi
	else if (envid == 0) {
  80111f:	85 c0                	test   %eax,%eax
  801121:	75 2f                	jne    801152 <fork+0x68>
		// Child returns
		thisenv = &envs[ENVX(sys_getenvid())];
  801123:	e8 e6 fb ff ff       	call   800d0e <sys_getenvid>
  801128:	25 ff 03 00 00       	and    $0x3ff,%eax
  80112d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801130:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801135:	a3 04 40 80 00       	mov    %eax,0x804004
		// set_pgfault_handler(pgfault);
		return 0;
  80113a:	b8 00 00 00 00       	mov    $0x0,%eax
  80113f:	e9 e1 00 00 00       	jmp    801225 <fork+0x13b>
  801144:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
	}
	else {
		uint32_t pn;
		for (pn = 0; pn * PGSIZE < UTOP; pn++){
			// cprintf("virtual page %08x\n", pn * PGSIZE);
			if (pn * PGSIZE == UXSTACKTOP - PGSIZE) 
  80114a:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801150:	74 77                	je     8011c9 <fork+0xdf>
{
	int r;

	// LAB 4: Your code here.
	int perm = PTE_P | PTE_U;
	pde_t pde = uvpd[pn / NPTENTRIES];
  801152:	89 f0                	mov    %esi,%eax
  801154:	c1 e8 0a             	shr    $0xa,%eax
  801157:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
	if (!(pde & PTE_P)) return 0;
  80115e:	a8 01                	test   $0x1,%al
  801160:	74 0b                	je     80116d <fork+0x83>
	pte_t pte = uvpt[pn];
  801162:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	if (!(pte & PTE_P)) return 0;
  801169:	a8 01                	test   $0x1,%al
  80116b:	75 08                	jne    801175 <fork+0x8b>
  80116d:	8d 5e 01             	lea    0x1(%esi),%ebx
  801170:	c1 e3 0c             	shl    $0xc,%ebx
  801173:	eb 56                	jmp    8011cb <fork+0xe1>
	// cprintf("virtual page %08x\n", pn * PGSIZE);

	if ((pte & PTE_W) || (pte & PTE_COW)) perm |= PTE_COW;
  801175:	25 02 08 00 00       	and    $0x802,%eax
  80117a:	83 f8 01             	cmp    $0x1,%eax
  80117d:	19 ff                	sbb    %edi,%edi
  80117f:	81 e7 00 f8 ff ff    	and    $0xfffff800,%edi
  801185:	81 c7 05 08 00 00    	add    $0x805,%edi

	if ((r = sys_page_map(thisenv->env_id, (void*)(pn * PGSIZE), envid, 
  80118b:	a1 04 40 80 00       	mov    0x804004,%eax
  801190:	8b 40 48             	mov    0x48(%eax),%eax
  801193:	83 ec 0c             	sub    $0xc,%esp
  801196:	57                   	push   %edi
  801197:	53                   	push   %ebx
  801198:	ff 75 e4             	pushl  -0x1c(%ebp)
  80119b:	53                   	push   %ebx
  80119c:	50                   	push   %eax
  80119d:	e8 ed fb ff ff       	call   800d8f <sys_page_map>
  8011a2:	83 c4 20             	add    $0x20,%esp
  8011a5:	85 c0                	test   %eax,%eax
  8011a7:	78 7c                	js     801225 <fork+0x13b>
				(void*)(pn * PGSIZE), perm)) < 0) 
		return r;
	r = sys_page_map(envid, (void*)(pn * PGSIZE), thisenv->env_id, 
  8011a9:	a1 04 40 80 00       	mov    0x804004,%eax
  8011ae:	8b 40 48             	mov    0x48(%eax),%eax
  8011b1:	83 ec 0c             	sub    $0xc,%esp
  8011b4:	57                   	push   %edi
  8011b5:	53                   	push   %ebx
  8011b6:	50                   	push   %eax
  8011b7:	53                   	push   %ebx
  8011b8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011bb:	e8 cf fb ff ff       	call   800d8f <sys_page_map>
		uint32_t pn;
		for (pn = 0; pn * PGSIZE < UTOP; pn++){
			// cprintf("virtual page %08x\n", pn * PGSIZE);
			if (pn * PGSIZE == UXSTACKTOP - PGSIZE) 
				continue;
			if ((ret = duppage(envid, pn)) < 0)
  8011c0:	83 c4 20             	add    $0x20,%esp
  8011c3:	85 c0                	test   %eax,%eax
  8011c5:	79 a6                	jns    80116d <fork+0x83>
  8011c7:	eb 5c                	jmp    801225 <fork+0x13b>
  8011c9:	89 c3                	mov    %eax,%ebx
		// set_pgfault_handler(pgfault);
		return 0;
	}
	else {
		uint32_t pn;
		for (pn = 0; pn * PGSIZE < UTOP; pn++){
  8011cb:	83 c6 01             	add    $0x1,%esi
  8011ce:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
  8011d4:	0f 86 6a ff ff ff    	jbe    801144 <fork+0x5a>
				return ret;
		}
		// cprintf("Fork: duppage finished\n");

		// Should be done by parent
		if ((ret = sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P |
  8011da:	83 ec 04             	sub    $0x4,%esp
  8011dd:	6a 07                	push   $0x7
  8011df:	68 00 f0 bf ee       	push   $0xeebff000
  8011e4:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8011e7:	57                   	push   %edi
  8011e8:	e8 5f fb ff ff       	call   800d4c <sys_page_alloc>
  8011ed:	83 c4 10             	add    $0x10,%esp
  8011f0:	85 c0                	test   %eax,%eax
  8011f2:	78 31                	js     801225 <fork+0x13b>
						PTE_U | PTE_W)) < 0)
			return ret;
		if ((ret = sys_env_set_pgfault_upcall(envid, 
						thisenv->env_pgfault_upcall)) < 0)
  8011f4:	a1 04 40 80 00       	mov    0x804004,%eax

		// Should be done by parent
		if ((ret = sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P |
						PTE_U | PTE_W)) < 0)
			return ret;
		if ((ret = sys_env_set_pgfault_upcall(envid, 
  8011f9:	8b 40 64             	mov    0x64(%eax),%eax
  8011fc:	83 ec 08             	sub    $0x8,%esp
  8011ff:	50                   	push   %eax
  801200:	57                   	push   %edi
  801201:	e8 91 fc ff ff       	call   800e97 <sys_env_set_pgfault_upcall>
  801206:	83 c4 10             	add    $0x10,%esp
  801209:	85 c0                	test   %eax,%eax
  80120b:	78 18                	js     801225 <fork+0x13b>
						thisenv->env_pgfault_upcall)) < 0)
			return ret;

		if ((ret = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  80120d:	83 ec 08             	sub    $0x8,%esp
  801210:	6a 02                	push   $0x2
  801212:	57                   	push   %edi
  801213:	e8 fb fb ff ff       	call   800e13 <sys_env_set_status>
  801218:	83 c4 10             	add    $0x10,%esp
			return ret;
		return envid;
  80121b:	85 c0                	test   %eax,%eax
  80121d:	0f 49 c7             	cmovns %edi,%eax
  801220:	eb 03                	jmp    801225 <fork+0x13b>
	int ret;
	set_pgfault_handler(pgfault);

	envid_t envid = sys_exofork();

	if (envid < 0) return envid;
  801222:	8b 45 e0             	mov    -0x20(%ebp),%eax
			return ret;
		return envid;
	}

	panic("fork not implemented");
}
  801225:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801228:	5b                   	pop    %ebx
  801229:	5e                   	pop    %esi
  80122a:	5f                   	pop    %edi
  80122b:	5d                   	pop    %ebp
  80122c:	c3                   	ret    

0080122d <sfork>:

// Challenge!
int
sfork(void)
{
  80122d:	55                   	push   %ebp
  80122e:	89 e5                	mov    %esp,%ebp
  801230:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801233:	68 51 28 80 00       	push   $0x802851
  801238:	68 9f 00 00 00       	push   $0x9f
  80123d:	68 ef 27 80 00       	push   $0x8027ef
  801242:	e8 fd ef ff ff       	call   800244 <_panic>

00801247 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801247:	55                   	push   %ebp
  801248:	89 e5                	mov    %esp,%ebp
  80124a:	56                   	push   %esi
  80124b:	53                   	push   %ebx
  80124c:	8b 75 08             	mov    0x8(%ebp),%esi
  80124f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801252:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int ret;
	if (pg) ret = sys_ipc_recv(pg);
  801255:	85 c0                	test   %eax,%eax
  801257:	74 0e                	je     801267 <ipc_recv+0x20>
  801259:	83 ec 0c             	sub    $0xc,%esp
  80125c:	50                   	push   %eax
  80125d:	e8 9a fc ff ff       	call   800efc <sys_ipc_recv>
  801262:	83 c4 10             	add    $0x10,%esp
  801265:	eb 10                	jmp    801277 <ipc_recv+0x30>
	else ret = sys_ipc_recv((void*)UTOP);
  801267:	83 ec 0c             	sub    $0xc,%esp
  80126a:	68 00 00 c0 ee       	push   $0xeec00000
  80126f:	e8 88 fc ff ff       	call   800efc <sys_ipc_recv>
  801274:	83 c4 10             	add    $0x10,%esp
	if (ret) {
  801277:	85 c0                	test   %eax,%eax
  801279:	74 16                	je     801291 <ipc_recv+0x4a>
		if (from_env_store) *from_env_store = 0;
  80127b:	85 f6                	test   %esi,%esi
  80127d:	74 06                	je     801285 <ipc_recv+0x3e>
  80127f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  801285:	85 db                	test   %ebx,%ebx
  801287:	74 2c                	je     8012b5 <ipc_recv+0x6e>
  801289:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80128f:	eb 24                	jmp    8012b5 <ipc_recv+0x6e>
		return ret;
	}
	if (from_env_store) *from_env_store = thisenv->env_ipc_from;
  801291:	85 f6                	test   %esi,%esi
  801293:	74 0a                	je     80129f <ipc_recv+0x58>
  801295:	a1 04 40 80 00       	mov    0x804004,%eax
  80129a:	8b 40 74             	mov    0x74(%eax),%eax
  80129d:	89 06                	mov    %eax,(%esi)
	if (perm_store) *perm_store = thisenv->env_ipc_perm;
  80129f:	85 db                	test   %ebx,%ebx
  8012a1:	74 0a                	je     8012ad <ipc_recv+0x66>
  8012a3:	a1 04 40 80 00       	mov    0x804004,%eax
  8012a8:	8b 40 78             	mov    0x78(%eax),%eax
  8012ab:	89 03                	mov    %eax,(%ebx)

	// panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8012ad:	a1 04 40 80 00       	mov    0x804004,%eax
  8012b2:	8b 40 70             	mov    0x70(%eax),%eax
}
  8012b5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012b8:	5b                   	pop    %ebx
  8012b9:	5e                   	pop    %esi
  8012ba:	5d                   	pop    %ebp
  8012bb:	c3                   	ret    

008012bc <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8012bc:	55                   	push   %ebp
  8012bd:	89 e5                	mov    %esp,%ebp
  8012bf:	57                   	push   %edi
  8012c0:	56                   	push   %esi
  8012c1:	53                   	push   %ebx
  8012c2:	83 ec 0c             	sub    $0xc,%esp
  8012c5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012c8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8012cb:	8b 45 10             	mov    0x10(%ebp),%eax
  8012ce:	85 c0                	test   %eax,%eax
  8012d0:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  8012d5:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	while (true) {
		void* srcva = (pg)? pg: (void*)UTOP;
		int ret = sys_ipc_try_send(to_env, val, srcva, perm);
  8012d8:	ff 75 14             	pushl  0x14(%ebp)
  8012db:	53                   	push   %ebx
  8012dc:	56                   	push   %esi
  8012dd:	57                   	push   %edi
  8012de:	e8 f6 fb ff ff       	call   800ed9 <sys_ipc_try_send>
		if (ret == 0) break;
  8012e3:	83 c4 10             	add    $0x10,%esp
  8012e6:	85 c0                	test   %eax,%eax
  8012e8:	74 1e                	je     801308 <ipc_send+0x4c>
		if (ret != -E_IPC_NOT_RECV) panic("ipc_send: %e", ret);
  8012ea:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8012ed:	74 12                	je     801301 <ipc_send+0x45>
  8012ef:	50                   	push   %eax
  8012f0:	68 8c 28 80 00       	push   $0x80288c
  8012f5:	6a 39                	push   $0x39
  8012f7:	68 99 28 80 00       	push   $0x802899
  8012fc:	e8 43 ef ff ff       	call   800244 <_panic>
		sys_yield();
  801301:	e8 27 fa ff ff       	call   800d2d <sys_yield>
	}
  801306:	eb d0                	jmp    8012d8 <ipc_send+0x1c>
	// panic("ipc_send not implemented");
}
  801308:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80130b:	5b                   	pop    %ebx
  80130c:	5e                   	pop    %esi
  80130d:	5f                   	pop    %edi
  80130e:	5d                   	pop    %ebp
  80130f:	c3                   	ret    

00801310 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801310:	55                   	push   %ebp
  801311:	89 e5                	mov    %esp,%ebp
  801313:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801316:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80131b:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80131e:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801324:	8b 52 50             	mov    0x50(%edx),%edx
  801327:	39 ca                	cmp    %ecx,%edx
  801329:	75 0d                	jne    801338 <ipc_find_env+0x28>
			return envs[i].env_id;
  80132b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80132e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801333:	8b 40 48             	mov    0x48(%eax),%eax
  801336:	eb 0f                	jmp    801347 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801338:	83 c0 01             	add    $0x1,%eax
  80133b:	3d 00 04 00 00       	cmp    $0x400,%eax
  801340:	75 d9                	jne    80131b <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801342:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801347:	5d                   	pop    %ebp
  801348:	c3                   	ret    

00801349 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801349:	55                   	push   %ebp
  80134a:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80134c:	8b 45 08             	mov    0x8(%ebp),%eax
  80134f:	05 00 00 00 30       	add    $0x30000000,%eax
  801354:	c1 e8 0c             	shr    $0xc,%eax
}
  801357:	5d                   	pop    %ebp
  801358:	c3                   	ret    

00801359 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801359:	55                   	push   %ebp
  80135a:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80135c:	8b 45 08             	mov    0x8(%ebp),%eax
  80135f:	05 00 00 00 30       	add    $0x30000000,%eax
  801364:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801369:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80136e:	5d                   	pop    %ebp
  80136f:	c3                   	ret    

00801370 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801370:	55                   	push   %ebp
  801371:	89 e5                	mov    %esp,%ebp
  801373:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801376:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80137b:	89 c2                	mov    %eax,%edx
  80137d:	c1 ea 16             	shr    $0x16,%edx
  801380:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801387:	f6 c2 01             	test   $0x1,%dl
  80138a:	74 11                	je     80139d <fd_alloc+0x2d>
  80138c:	89 c2                	mov    %eax,%edx
  80138e:	c1 ea 0c             	shr    $0xc,%edx
  801391:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801398:	f6 c2 01             	test   $0x1,%dl
  80139b:	75 09                	jne    8013a6 <fd_alloc+0x36>
			*fd_store = fd;
  80139d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80139f:	b8 00 00 00 00       	mov    $0x0,%eax
  8013a4:	eb 17                	jmp    8013bd <fd_alloc+0x4d>
  8013a6:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8013ab:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8013b0:	75 c9                	jne    80137b <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8013b2:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8013b8:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8013bd:	5d                   	pop    %ebp
  8013be:	c3                   	ret    

008013bf <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8013bf:	55                   	push   %ebp
  8013c0:	89 e5                	mov    %esp,%ebp
  8013c2:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8013c5:	83 f8 1f             	cmp    $0x1f,%eax
  8013c8:	77 36                	ja     801400 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8013ca:	c1 e0 0c             	shl    $0xc,%eax
  8013cd:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8013d2:	89 c2                	mov    %eax,%edx
  8013d4:	c1 ea 16             	shr    $0x16,%edx
  8013d7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013de:	f6 c2 01             	test   $0x1,%dl
  8013e1:	74 24                	je     801407 <fd_lookup+0x48>
  8013e3:	89 c2                	mov    %eax,%edx
  8013e5:	c1 ea 0c             	shr    $0xc,%edx
  8013e8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013ef:	f6 c2 01             	test   $0x1,%dl
  8013f2:	74 1a                	je     80140e <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8013f4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013f7:	89 02                	mov    %eax,(%edx)
	return 0;
  8013f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8013fe:	eb 13                	jmp    801413 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801400:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801405:	eb 0c                	jmp    801413 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801407:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80140c:	eb 05                	jmp    801413 <fd_lookup+0x54>
  80140e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801413:	5d                   	pop    %ebp
  801414:	c3                   	ret    

00801415 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801415:	55                   	push   %ebp
  801416:	89 e5                	mov    %esp,%ebp
  801418:	83 ec 08             	sub    $0x8,%esp
  80141b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80141e:	ba 24 29 80 00       	mov    $0x802924,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801423:	eb 13                	jmp    801438 <dev_lookup+0x23>
  801425:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801428:	39 08                	cmp    %ecx,(%eax)
  80142a:	75 0c                	jne    801438 <dev_lookup+0x23>
			*dev = devtab[i];
  80142c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80142f:	89 01                	mov    %eax,(%ecx)
			return 0;
  801431:	b8 00 00 00 00       	mov    $0x0,%eax
  801436:	eb 2e                	jmp    801466 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801438:	8b 02                	mov    (%edx),%eax
  80143a:	85 c0                	test   %eax,%eax
  80143c:	75 e7                	jne    801425 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80143e:	a1 04 40 80 00       	mov    0x804004,%eax
  801443:	8b 40 48             	mov    0x48(%eax),%eax
  801446:	83 ec 04             	sub    $0x4,%esp
  801449:	51                   	push   %ecx
  80144a:	50                   	push   %eax
  80144b:	68 a4 28 80 00       	push   $0x8028a4
  801450:	e8 c8 ee ff ff       	call   80031d <cprintf>
	*dev = 0;
  801455:	8b 45 0c             	mov    0xc(%ebp),%eax
  801458:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80145e:	83 c4 10             	add    $0x10,%esp
  801461:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801466:	c9                   	leave  
  801467:	c3                   	ret    

00801468 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801468:	55                   	push   %ebp
  801469:	89 e5                	mov    %esp,%ebp
  80146b:	56                   	push   %esi
  80146c:	53                   	push   %ebx
  80146d:	83 ec 10             	sub    $0x10,%esp
  801470:	8b 75 08             	mov    0x8(%ebp),%esi
  801473:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801476:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801479:	50                   	push   %eax
  80147a:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801480:	c1 e8 0c             	shr    $0xc,%eax
  801483:	50                   	push   %eax
  801484:	e8 36 ff ff ff       	call   8013bf <fd_lookup>
  801489:	83 c4 08             	add    $0x8,%esp
  80148c:	85 c0                	test   %eax,%eax
  80148e:	78 05                	js     801495 <fd_close+0x2d>
	    || fd != fd2)
  801490:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801493:	74 0c                	je     8014a1 <fd_close+0x39>
		return (must_exist ? r : 0);
  801495:	84 db                	test   %bl,%bl
  801497:	ba 00 00 00 00       	mov    $0x0,%edx
  80149c:	0f 44 c2             	cmove  %edx,%eax
  80149f:	eb 41                	jmp    8014e2 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8014a1:	83 ec 08             	sub    $0x8,%esp
  8014a4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014a7:	50                   	push   %eax
  8014a8:	ff 36                	pushl  (%esi)
  8014aa:	e8 66 ff ff ff       	call   801415 <dev_lookup>
  8014af:	89 c3                	mov    %eax,%ebx
  8014b1:	83 c4 10             	add    $0x10,%esp
  8014b4:	85 c0                	test   %eax,%eax
  8014b6:	78 1a                	js     8014d2 <fd_close+0x6a>
		if (dev->dev_close)
  8014b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014bb:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8014be:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8014c3:	85 c0                	test   %eax,%eax
  8014c5:	74 0b                	je     8014d2 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8014c7:	83 ec 0c             	sub    $0xc,%esp
  8014ca:	56                   	push   %esi
  8014cb:	ff d0                	call   *%eax
  8014cd:	89 c3                	mov    %eax,%ebx
  8014cf:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8014d2:	83 ec 08             	sub    $0x8,%esp
  8014d5:	56                   	push   %esi
  8014d6:	6a 00                	push   $0x0
  8014d8:	e8 f4 f8 ff ff       	call   800dd1 <sys_page_unmap>
	return r;
  8014dd:	83 c4 10             	add    $0x10,%esp
  8014e0:	89 d8                	mov    %ebx,%eax
}
  8014e2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014e5:	5b                   	pop    %ebx
  8014e6:	5e                   	pop    %esi
  8014e7:	5d                   	pop    %ebp
  8014e8:	c3                   	ret    

008014e9 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8014e9:	55                   	push   %ebp
  8014ea:	89 e5                	mov    %esp,%ebp
  8014ec:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014ef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014f2:	50                   	push   %eax
  8014f3:	ff 75 08             	pushl  0x8(%ebp)
  8014f6:	e8 c4 fe ff ff       	call   8013bf <fd_lookup>
  8014fb:	83 c4 08             	add    $0x8,%esp
  8014fe:	85 c0                	test   %eax,%eax
  801500:	78 10                	js     801512 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801502:	83 ec 08             	sub    $0x8,%esp
  801505:	6a 01                	push   $0x1
  801507:	ff 75 f4             	pushl  -0xc(%ebp)
  80150a:	e8 59 ff ff ff       	call   801468 <fd_close>
  80150f:	83 c4 10             	add    $0x10,%esp
}
  801512:	c9                   	leave  
  801513:	c3                   	ret    

00801514 <close_all>:

void
close_all(void)
{
  801514:	55                   	push   %ebp
  801515:	89 e5                	mov    %esp,%ebp
  801517:	53                   	push   %ebx
  801518:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80151b:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801520:	83 ec 0c             	sub    $0xc,%esp
  801523:	53                   	push   %ebx
  801524:	e8 c0 ff ff ff       	call   8014e9 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801529:	83 c3 01             	add    $0x1,%ebx
  80152c:	83 c4 10             	add    $0x10,%esp
  80152f:	83 fb 20             	cmp    $0x20,%ebx
  801532:	75 ec                	jne    801520 <close_all+0xc>
		close(i);
}
  801534:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801537:	c9                   	leave  
  801538:	c3                   	ret    

00801539 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801539:	55                   	push   %ebp
  80153a:	89 e5                	mov    %esp,%ebp
  80153c:	57                   	push   %edi
  80153d:	56                   	push   %esi
  80153e:	53                   	push   %ebx
  80153f:	83 ec 2c             	sub    $0x2c,%esp
  801542:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801545:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801548:	50                   	push   %eax
  801549:	ff 75 08             	pushl  0x8(%ebp)
  80154c:	e8 6e fe ff ff       	call   8013bf <fd_lookup>
  801551:	83 c4 08             	add    $0x8,%esp
  801554:	85 c0                	test   %eax,%eax
  801556:	0f 88 c1 00 00 00    	js     80161d <dup+0xe4>
		return r;
	close(newfdnum);
  80155c:	83 ec 0c             	sub    $0xc,%esp
  80155f:	56                   	push   %esi
  801560:	e8 84 ff ff ff       	call   8014e9 <close>

	newfd = INDEX2FD(newfdnum);
  801565:	89 f3                	mov    %esi,%ebx
  801567:	c1 e3 0c             	shl    $0xc,%ebx
  80156a:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801570:	83 c4 04             	add    $0x4,%esp
  801573:	ff 75 e4             	pushl  -0x1c(%ebp)
  801576:	e8 de fd ff ff       	call   801359 <fd2data>
  80157b:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80157d:	89 1c 24             	mov    %ebx,(%esp)
  801580:	e8 d4 fd ff ff       	call   801359 <fd2data>
  801585:	83 c4 10             	add    $0x10,%esp
  801588:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80158b:	89 f8                	mov    %edi,%eax
  80158d:	c1 e8 16             	shr    $0x16,%eax
  801590:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801597:	a8 01                	test   $0x1,%al
  801599:	74 37                	je     8015d2 <dup+0x99>
  80159b:	89 f8                	mov    %edi,%eax
  80159d:	c1 e8 0c             	shr    $0xc,%eax
  8015a0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8015a7:	f6 c2 01             	test   $0x1,%dl
  8015aa:	74 26                	je     8015d2 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8015ac:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015b3:	83 ec 0c             	sub    $0xc,%esp
  8015b6:	25 07 0e 00 00       	and    $0xe07,%eax
  8015bb:	50                   	push   %eax
  8015bc:	ff 75 d4             	pushl  -0x2c(%ebp)
  8015bf:	6a 00                	push   $0x0
  8015c1:	57                   	push   %edi
  8015c2:	6a 00                	push   $0x0
  8015c4:	e8 c6 f7 ff ff       	call   800d8f <sys_page_map>
  8015c9:	89 c7                	mov    %eax,%edi
  8015cb:	83 c4 20             	add    $0x20,%esp
  8015ce:	85 c0                	test   %eax,%eax
  8015d0:	78 2e                	js     801600 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015d2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8015d5:	89 d0                	mov    %edx,%eax
  8015d7:	c1 e8 0c             	shr    $0xc,%eax
  8015da:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015e1:	83 ec 0c             	sub    $0xc,%esp
  8015e4:	25 07 0e 00 00       	and    $0xe07,%eax
  8015e9:	50                   	push   %eax
  8015ea:	53                   	push   %ebx
  8015eb:	6a 00                	push   $0x0
  8015ed:	52                   	push   %edx
  8015ee:	6a 00                	push   $0x0
  8015f0:	e8 9a f7 ff ff       	call   800d8f <sys_page_map>
  8015f5:	89 c7                	mov    %eax,%edi
  8015f7:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8015fa:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015fc:	85 ff                	test   %edi,%edi
  8015fe:	79 1d                	jns    80161d <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801600:	83 ec 08             	sub    $0x8,%esp
  801603:	53                   	push   %ebx
  801604:	6a 00                	push   $0x0
  801606:	e8 c6 f7 ff ff       	call   800dd1 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80160b:	83 c4 08             	add    $0x8,%esp
  80160e:	ff 75 d4             	pushl  -0x2c(%ebp)
  801611:	6a 00                	push   $0x0
  801613:	e8 b9 f7 ff ff       	call   800dd1 <sys_page_unmap>
	return r;
  801618:	83 c4 10             	add    $0x10,%esp
  80161b:	89 f8                	mov    %edi,%eax
}
  80161d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801620:	5b                   	pop    %ebx
  801621:	5e                   	pop    %esi
  801622:	5f                   	pop    %edi
  801623:	5d                   	pop    %ebp
  801624:	c3                   	ret    

00801625 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801625:	55                   	push   %ebp
  801626:	89 e5                	mov    %esp,%ebp
  801628:	53                   	push   %ebx
  801629:	83 ec 14             	sub    $0x14,%esp
  80162c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80162f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801632:	50                   	push   %eax
  801633:	53                   	push   %ebx
  801634:	e8 86 fd ff ff       	call   8013bf <fd_lookup>
  801639:	83 c4 08             	add    $0x8,%esp
  80163c:	89 c2                	mov    %eax,%edx
  80163e:	85 c0                	test   %eax,%eax
  801640:	78 6d                	js     8016af <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801642:	83 ec 08             	sub    $0x8,%esp
  801645:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801648:	50                   	push   %eax
  801649:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80164c:	ff 30                	pushl  (%eax)
  80164e:	e8 c2 fd ff ff       	call   801415 <dev_lookup>
  801653:	83 c4 10             	add    $0x10,%esp
  801656:	85 c0                	test   %eax,%eax
  801658:	78 4c                	js     8016a6 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80165a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80165d:	8b 42 08             	mov    0x8(%edx),%eax
  801660:	83 e0 03             	and    $0x3,%eax
  801663:	83 f8 01             	cmp    $0x1,%eax
  801666:	75 21                	jne    801689 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801668:	a1 04 40 80 00       	mov    0x804004,%eax
  80166d:	8b 40 48             	mov    0x48(%eax),%eax
  801670:	83 ec 04             	sub    $0x4,%esp
  801673:	53                   	push   %ebx
  801674:	50                   	push   %eax
  801675:	68 e8 28 80 00       	push   $0x8028e8
  80167a:	e8 9e ec ff ff       	call   80031d <cprintf>
		return -E_INVAL;
  80167f:	83 c4 10             	add    $0x10,%esp
  801682:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801687:	eb 26                	jmp    8016af <read+0x8a>
	}
	if (!dev->dev_read)
  801689:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80168c:	8b 40 08             	mov    0x8(%eax),%eax
  80168f:	85 c0                	test   %eax,%eax
  801691:	74 17                	je     8016aa <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801693:	83 ec 04             	sub    $0x4,%esp
  801696:	ff 75 10             	pushl  0x10(%ebp)
  801699:	ff 75 0c             	pushl  0xc(%ebp)
  80169c:	52                   	push   %edx
  80169d:	ff d0                	call   *%eax
  80169f:	89 c2                	mov    %eax,%edx
  8016a1:	83 c4 10             	add    $0x10,%esp
  8016a4:	eb 09                	jmp    8016af <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a6:	89 c2                	mov    %eax,%edx
  8016a8:	eb 05                	jmp    8016af <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8016aa:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8016af:	89 d0                	mov    %edx,%eax
  8016b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016b4:	c9                   	leave  
  8016b5:	c3                   	ret    

008016b6 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8016b6:	55                   	push   %ebp
  8016b7:	89 e5                	mov    %esp,%ebp
  8016b9:	57                   	push   %edi
  8016ba:	56                   	push   %esi
  8016bb:	53                   	push   %ebx
  8016bc:	83 ec 0c             	sub    $0xc,%esp
  8016bf:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016c2:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016c5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016ca:	eb 21                	jmp    8016ed <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8016cc:	83 ec 04             	sub    $0x4,%esp
  8016cf:	89 f0                	mov    %esi,%eax
  8016d1:	29 d8                	sub    %ebx,%eax
  8016d3:	50                   	push   %eax
  8016d4:	89 d8                	mov    %ebx,%eax
  8016d6:	03 45 0c             	add    0xc(%ebp),%eax
  8016d9:	50                   	push   %eax
  8016da:	57                   	push   %edi
  8016db:	e8 45 ff ff ff       	call   801625 <read>
		if (m < 0)
  8016e0:	83 c4 10             	add    $0x10,%esp
  8016e3:	85 c0                	test   %eax,%eax
  8016e5:	78 10                	js     8016f7 <readn+0x41>
			return m;
		if (m == 0)
  8016e7:	85 c0                	test   %eax,%eax
  8016e9:	74 0a                	je     8016f5 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016eb:	01 c3                	add    %eax,%ebx
  8016ed:	39 f3                	cmp    %esi,%ebx
  8016ef:	72 db                	jb     8016cc <readn+0x16>
  8016f1:	89 d8                	mov    %ebx,%eax
  8016f3:	eb 02                	jmp    8016f7 <readn+0x41>
  8016f5:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8016f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016fa:	5b                   	pop    %ebx
  8016fb:	5e                   	pop    %esi
  8016fc:	5f                   	pop    %edi
  8016fd:	5d                   	pop    %ebp
  8016fe:	c3                   	ret    

008016ff <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8016ff:	55                   	push   %ebp
  801700:	89 e5                	mov    %esp,%ebp
  801702:	53                   	push   %ebx
  801703:	83 ec 14             	sub    $0x14,%esp
  801706:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801709:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80170c:	50                   	push   %eax
  80170d:	53                   	push   %ebx
  80170e:	e8 ac fc ff ff       	call   8013bf <fd_lookup>
  801713:	83 c4 08             	add    $0x8,%esp
  801716:	89 c2                	mov    %eax,%edx
  801718:	85 c0                	test   %eax,%eax
  80171a:	78 68                	js     801784 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80171c:	83 ec 08             	sub    $0x8,%esp
  80171f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801722:	50                   	push   %eax
  801723:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801726:	ff 30                	pushl  (%eax)
  801728:	e8 e8 fc ff ff       	call   801415 <dev_lookup>
  80172d:	83 c4 10             	add    $0x10,%esp
  801730:	85 c0                	test   %eax,%eax
  801732:	78 47                	js     80177b <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801734:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801737:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80173b:	75 21                	jne    80175e <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80173d:	a1 04 40 80 00       	mov    0x804004,%eax
  801742:	8b 40 48             	mov    0x48(%eax),%eax
  801745:	83 ec 04             	sub    $0x4,%esp
  801748:	53                   	push   %ebx
  801749:	50                   	push   %eax
  80174a:	68 04 29 80 00       	push   $0x802904
  80174f:	e8 c9 eb ff ff       	call   80031d <cprintf>
		return -E_INVAL;
  801754:	83 c4 10             	add    $0x10,%esp
  801757:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80175c:	eb 26                	jmp    801784 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80175e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801761:	8b 52 0c             	mov    0xc(%edx),%edx
  801764:	85 d2                	test   %edx,%edx
  801766:	74 17                	je     80177f <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801768:	83 ec 04             	sub    $0x4,%esp
  80176b:	ff 75 10             	pushl  0x10(%ebp)
  80176e:	ff 75 0c             	pushl  0xc(%ebp)
  801771:	50                   	push   %eax
  801772:	ff d2                	call   *%edx
  801774:	89 c2                	mov    %eax,%edx
  801776:	83 c4 10             	add    $0x10,%esp
  801779:	eb 09                	jmp    801784 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80177b:	89 c2                	mov    %eax,%edx
  80177d:	eb 05                	jmp    801784 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80177f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801784:	89 d0                	mov    %edx,%eax
  801786:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801789:	c9                   	leave  
  80178a:	c3                   	ret    

0080178b <seek>:

int
seek(int fdnum, off_t offset)
{
  80178b:	55                   	push   %ebp
  80178c:	89 e5                	mov    %esp,%ebp
  80178e:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801791:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801794:	50                   	push   %eax
  801795:	ff 75 08             	pushl  0x8(%ebp)
  801798:	e8 22 fc ff ff       	call   8013bf <fd_lookup>
  80179d:	83 c4 08             	add    $0x8,%esp
  8017a0:	85 c0                	test   %eax,%eax
  8017a2:	78 0e                	js     8017b2 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8017a4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8017a7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017aa:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8017ad:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017b2:	c9                   	leave  
  8017b3:	c3                   	ret    

008017b4 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8017b4:	55                   	push   %ebp
  8017b5:	89 e5                	mov    %esp,%ebp
  8017b7:	53                   	push   %ebx
  8017b8:	83 ec 14             	sub    $0x14,%esp
  8017bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017be:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017c1:	50                   	push   %eax
  8017c2:	53                   	push   %ebx
  8017c3:	e8 f7 fb ff ff       	call   8013bf <fd_lookup>
  8017c8:	83 c4 08             	add    $0x8,%esp
  8017cb:	89 c2                	mov    %eax,%edx
  8017cd:	85 c0                	test   %eax,%eax
  8017cf:	78 65                	js     801836 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017d1:	83 ec 08             	sub    $0x8,%esp
  8017d4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017d7:	50                   	push   %eax
  8017d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017db:	ff 30                	pushl  (%eax)
  8017dd:	e8 33 fc ff ff       	call   801415 <dev_lookup>
  8017e2:	83 c4 10             	add    $0x10,%esp
  8017e5:	85 c0                	test   %eax,%eax
  8017e7:	78 44                	js     80182d <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017ec:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017f0:	75 21                	jne    801813 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8017f2:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8017f7:	8b 40 48             	mov    0x48(%eax),%eax
  8017fa:	83 ec 04             	sub    $0x4,%esp
  8017fd:	53                   	push   %ebx
  8017fe:	50                   	push   %eax
  8017ff:	68 c4 28 80 00       	push   $0x8028c4
  801804:	e8 14 eb ff ff       	call   80031d <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801809:	83 c4 10             	add    $0x10,%esp
  80180c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801811:	eb 23                	jmp    801836 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801813:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801816:	8b 52 18             	mov    0x18(%edx),%edx
  801819:	85 d2                	test   %edx,%edx
  80181b:	74 14                	je     801831 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80181d:	83 ec 08             	sub    $0x8,%esp
  801820:	ff 75 0c             	pushl  0xc(%ebp)
  801823:	50                   	push   %eax
  801824:	ff d2                	call   *%edx
  801826:	89 c2                	mov    %eax,%edx
  801828:	83 c4 10             	add    $0x10,%esp
  80182b:	eb 09                	jmp    801836 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80182d:	89 c2                	mov    %eax,%edx
  80182f:	eb 05                	jmp    801836 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801831:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801836:	89 d0                	mov    %edx,%eax
  801838:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80183b:	c9                   	leave  
  80183c:	c3                   	ret    

0080183d <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80183d:	55                   	push   %ebp
  80183e:	89 e5                	mov    %esp,%ebp
  801840:	53                   	push   %ebx
  801841:	83 ec 14             	sub    $0x14,%esp
  801844:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801847:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80184a:	50                   	push   %eax
  80184b:	ff 75 08             	pushl  0x8(%ebp)
  80184e:	e8 6c fb ff ff       	call   8013bf <fd_lookup>
  801853:	83 c4 08             	add    $0x8,%esp
  801856:	89 c2                	mov    %eax,%edx
  801858:	85 c0                	test   %eax,%eax
  80185a:	78 58                	js     8018b4 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80185c:	83 ec 08             	sub    $0x8,%esp
  80185f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801862:	50                   	push   %eax
  801863:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801866:	ff 30                	pushl  (%eax)
  801868:	e8 a8 fb ff ff       	call   801415 <dev_lookup>
  80186d:	83 c4 10             	add    $0x10,%esp
  801870:	85 c0                	test   %eax,%eax
  801872:	78 37                	js     8018ab <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801874:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801877:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80187b:	74 32                	je     8018af <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80187d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801880:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801887:	00 00 00 
	stat->st_isdir = 0;
  80188a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801891:	00 00 00 
	stat->st_dev = dev;
  801894:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80189a:	83 ec 08             	sub    $0x8,%esp
  80189d:	53                   	push   %ebx
  80189e:	ff 75 f0             	pushl  -0x10(%ebp)
  8018a1:	ff 50 14             	call   *0x14(%eax)
  8018a4:	89 c2                	mov    %eax,%edx
  8018a6:	83 c4 10             	add    $0x10,%esp
  8018a9:	eb 09                	jmp    8018b4 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018ab:	89 c2                	mov    %eax,%edx
  8018ad:	eb 05                	jmp    8018b4 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8018af:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8018b4:	89 d0                	mov    %edx,%eax
  8018b6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018b9:	c9                   	leave  
  8018ba:	c3                   	ret    

008018bb <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8018bb:	55                   	push   %ebp
  8018bc:	89 e5                	mov    %esp,%ebp
  8018be:	56                   	push   %esi
  8018bf:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8018c0:	83 ec 08             	sub    $0x8,%esp
  8018c3:	6a 00                	push   $0x0
  8018c5:	ff 75 08             	pushl  0x8(%ebp)
  8018c8:	e8 b7 01 00 00       	call   801a84 <open>
  8018cd:	89 c3                	mov    %eax,%ebx
  8018cf:	83 c4 10             	add    $0x10,%esp
  8018d2:	85 c0                	test   %eax,%eax
  8018d4:	78 1b                	js     8018f1 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8018d6:	83 ec 08             	sub    $0x8,%esp
  8018d9:	ff 75 0c             	pushl  0xc(%ebp)
  8018dc:	50                   	push   %eax
  8018dd:	e8 5b ff ff ff       	call   80183d <fstat>
  8018e2:	89 c6                	mov    %eax,%esi
	close(fd);
  8018e4:	89 1c 24             	mov    %ebx,(%esp)
  8018e7:	e8 fd fb ff ff       	call   8014e9 <close>
	return r;
  8018ec:	83 c4 10             	add    $0x10,%esp
  8018ef:	89 f0                	mov    %esi,%eax
}
  8018f1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018f4:	5b                   	pop    %ebx
  8018f5:	5e                   	pop    %esi
  8018f6:	5d                   	pop    %ebp
  8018f7:	c3                   	ret    

008018f8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8018f8:	55                   	push   %ebp
  8018f9:	89 e5                	mov    %esp,%ebp
  8018fb:	56                   	push   %esi
  8018fc:	53                   	push   %ebx
  8018fd:	89 c6                	mov    %eax,%esi
  8018ff:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801901:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801908:	75 12                	jne    80191c <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80190a:	83 ec 0c             	sub    $0xc,%esp
  80190d:	6a 01                	push   $0x1
  80190f:	e8 fc f9 ff ff       	call   801310 <ipc_find_env>
  801914:	a3 00 40 80 00       	mov    %eax,0x804000
  801919:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80191c:	6a 07                	push   $0x7
  80191e:	68 00 50 80 00       	push   $0x805000
  801923:	56                   	push   %esi
  801924:	ff 35 00 40 80 00    	pushl  0x804000
  80192a:	e8 8d f9 ff ff       	call   8012bc <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80192f:	83 c4 0c             	add    $0xc,%esp
  801932:	6a 00                	push   $0x0
  801934:	53                   	push   %ebx
  801935:	6a 00                	push   $0x0
  801937:	e8 0b f9 ff ff       	call   801247 <ipc_recv>
}
  80193c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80193f:	5b                   	pop    %ebx
  801940:	5e                   	pop    %esi
  801941:	5d                   	pop    %ebp
  801942:	c3                   	ret    

00801943 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801943:	55                   	push   %ebp
  801944:	89 e5                	mov    %esp,%ebp
  801946:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801949:	8b 45 08             	mov    0x8(%ebp),%eax
  80194c:	8b 40 0c             	mov    0xc(%eax),%eax
  80194f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801954:	8b 45 0c             	mov    0xc(%ebp),%eax
  801957:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80195c:	ba 00 00 00 00       	mov    $0x0,%edx
  801961:	b8 02 00 00 00       	mov    $0x2,%eax
  801966:	e8 8d ff ff ff       	call   8018f8 <fsipc>
}
  80196b:	c9                   	leave  
  80196c:	c3                   	ret    

0080196d <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80196d:	55                   	push   %ebp
  80196e:	89 e5                	mov    %esp,%ebp
  801970:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801973:	8b 45 08             	mov    0x8(%ebp),%eax
  801976:	8b 40 0c             	mov    0xc(%eax),%eax
  801979:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80197e:	ba 00 00 00 00       	mov    $0x0,%edx
  801983:	b8 06 00 00 00       	mov    $0x6,%eax
  801988:	e8 6b ff ff ff       	call   8018f8 <fsipc>
}
  80198d:	c9                   	leave  
  80198e:	c3                   	ret    

0080198f <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80198f:	55                   	push   %ebp
  801990:	89 e5                	mov    %esp,%ebp
  801992:	53                   	push   %ebx
  801993:	83 ec 04             	sub    $0x4,%esp
  801996:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801999:	8b 45 08             	mov    0x8(%ebp),%eax
  80199c:	8b 40 0c             	mov    0xc(%eax),%eax
  80199f:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8019a4:	ba 00 00 00 00       	mov    $0x0,%edx
  8019a9:	b8 05 00 00 00       	mov    $0x5,%eax
  8019ae:	e8 45 ff ff ff       	call   8018f8 <fsipc>
  8019b3:	85 c0                	test   %eax,%eax
  8019b5:	78 2c                	js     8019e3 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8019b7:	83 ec 08             	sub    $0x8,%esp
  8019ba:	68 00 50 80 00       	push   $0x805000
  8019bf:	53                   	push   %ebx
  8019c0:	e8 84 ef ff ff       	call   800949 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8019c5:	a1 80 50 80 00       	mov    0x805080,%eax
  8019ca:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8019d0:	a1 84 50 80 00       	mov    0x805084,%eax
  8019d5:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8019db:	83 c4 10             	add    $0x10,%esp
  8019de:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019e6:	c9                   	leave  
  8019e7:	c3                   	ret    

008019e8 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8019e8:	55                   	push   %ebp
  8019e9:	89 e5                	mov    %esp,%ebp
  8019eb:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  8019ee:	68 34 29 80 00       	push   $0x802934
  8019f3:	68 90 00 00 00       	push   $0x90
  8019f8:	68 52 29 80 00       	push   $0x802952
  8019fd:	e8 42 e8 ff ff       	call   800244 <_panic>

00801a02 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801a02:	55                   	push   %ebp
  801a03:	89 e5                	mov    %esp,%ebp
  801a05:	56                   	push   %esi
  801a06:	53                   	push   %ebx
  801a07:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a0a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a0d:	8b 40 0c             	mov    0xc(%eax),%eax
  801a10:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801a15:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a1b:	ba 00 00 00 00       	mov    $0x0,%edx
  801a20:	b8 03 00 00 00       	mov    $0x3,%eax
  801a25:	e8 ce fe ff ff       	call   8018f8 <fsipc>
  801a2a:	89 c3                	mov    %eax,%ebx
  801a2c:	85 c0                	test   %eax,%eax
  801a2e:	78 4b                	js     801a7b <devfile_read+0x79>
		return r;
	assert(r <= n);
  801a30:	39 c6                	cmp    %eax,%esi
  801a32:	73 16                	jae    801a4a <devfile_read+0x48>
  801a34:	68 5d 29 80 00       	push   $0x80295d
  801a39:	68 64 29 80 00       	push   $0x802964
  801a3e:	6a 7c                	push   $0x7c
  801a40:	68 52 29 80 00       	push   $0x802952
  801a45:	e8 fa e7 ff ff       	call   800244 <_panic>
	assert(r <= PGSIZE);
  801a4a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a4f:	7e 16                	jle    801a67 <devfile_read+0x65>
  801a51:	68 79 29 80 00       	push   $0x802979
  801a56:	68 64 29 80 00       	push   $0x802964
  801a5b:	6a 7d                	push   $0x7d
  801a5d:	68 52 29 80 00       	push   $0x802952
  801a62:	e8 dd e7 ff ff       	call   800244 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a67:	83 ec 04             	sub    $0x4,%esp
  801a6a:	50                   	push   %eax
  801a6b:	68 00 50 80 00       	push   $0x805000
  801a70:	ff 75 0c             	pushl  0xc(%ebp)
  801a73:	e8 63 f0 ff ff       	call   800adb <memmove>
	return r;
  801a78:	83 c4 10             	add    $0x10,%esp
}
  801a7b:	89 d8                	mov    %ebx,%eax
  801a7d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a80:	5b                   	pop    %ebx
  801a81:	5e                   	pop    %esi
  801a82:	5d                   	pop    %ebp
  801a83:	c3                   	ret    

00801a84 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a84:	55                   	push   %ebp
  801a85:	89 e5                	mov    %esp,%ebp
  801a87:	53                   	push   %ebx
  801a88:	83 ec 20             	sub    $0x20,%esp
  801a8b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a8e:	53                   	push   %ebx
  801a8f:	e8 7c ee ff ff       	call   800910 <strlen>
  801a94:	83 c4 10             	add    $0x10,%esp
  801a97:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a9c:	7f 67                	jg     801b05 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a9e:	83 ec 0c             	sub    $0xc,%esp
  801aa1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aa4:	50                   	push   %eax
  801aa5:	e8 c6 f8 ff ff       	call   801370 <fd_alloc>
  801aaa:	83 c4 10             	add    $0x10,%esp
		return r;
  801aad:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801aaf:	85 c0                	test   %eax,%eax
  801ab1:	78 57                	js     801b0a <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801ab3:	83 ec 08             	sub    $0x8,%esp
  801ab6:	53                   	push   %ebx
  801ab7:	68 00 50 80 00       	push   $0x805000
  801abc:	e8 88 ee ff ff       	call   800949 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801ac1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ac4:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801ac9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801acc:	b8 01 00 00 00       	mov    $0x1,%eax
  801ad1:	e8 22 fe ff ff       	call   8018f8 <fsipc>
  801ad6:	89 c3                	mov    %eax,%ebx
  801ad8:	83 c4 10             	add    $0x10,%esp
  801adb:	85 c0                	test   %eax,%eax
  801add:	79 14                	jns    801af3 <open+0x6f>
		fd_close(fd, 0);
  801adf:	83 ec 08             	sub    $0x8,%esp
  801ae2:	6a 00                	push   $0x0
  801ae4:	ff 75 f4             	pushl  -0xc(%ebp)
  801ae7:	e8 7c f9 ff ff       	call   801468 <fd_close>
		return r;
  801aec:	83 c4 10             	add    $0x10,%esp
  801aef:	89 da                	mov    %ebx,%edx
  801af1:	eb 17                	jmp    801b0a <open+0x86>
	}

	return fd2num(fd);
  801af3:	83 ec 0c             	sub    $0xc,%esp
  801af6:	ff 75 f4             	pushl  -0xc(%ebp)
  801af9:	e8 4b f8 ff ff       	call   801349 <fd2num>
  801afe:	89 c2                	mov    %eax,%edx
  801b00:	83 c4 10             	add    $0x10,%esp
  801b03:	eb 05                	jmp    801b0a <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801b05:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801b0a:	89 d0                	mov    %edx,%eax
  801b0c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b0f:	c9                   	leave  
  801b10:	c3                   	ret    

00801b11 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b11:	55                   	push   %ebp
  801b12:	89 e5                	mov    %esp,%ebp
  801b14:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b17:	ba 00 00 00 00       	mov    $0x0,%edx
  801b1c:	b8 08 00 00 00       	mov    $0x8,%eax
  801b21:	e8 d2 fd ff ff       	call   8018f8 <fsipc>
}
  801b26:	c9                   	leave  
  801b27:	c3                   	ret    

00801b28 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b28:	55                   	push   %ebp
  801b29:	89 e5                	mov    %esp,%ebp
  801b2b:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b2e:	89 d0                	mov    %edx,%eax
  801b30:	c1 e8 16             	shr    $0x16,%eax
  801b33:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b3a:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b3f:	f6 c1 01             	test   $0x1,%cl
  801b42:	74 1d                	je     801b61 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b44:	c1 ea 0c             	shr    $0xc,%edx
  801b47:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b4e:	f6 c2 01             	test   $0x1,%dl
  801b51:	74 0e                	je     801b61 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b53:	c1 ea 0c             	shr    $0xc,%edx
  801b56:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b5d:	ef 
  801b5e:	0f b7 c0             	movzwl %ax,%eax
}
  801b61:	5d                   	pop    %ebp
  801b62:	c3                   	ret    

00801b63 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b63:	55                   	push   %ebp
  801b64:	89 e5                	mov    %esp,%ebp
  801b66:	56                   	push   %esi
  801b67:	53                   	push   %ebx
  801b68:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b6b:	83 ec 0c             	sub    $0xc,%esp
  801b6e:	ff 75 08             	pushl  0x8(%ebp)
  801b71:	e8 e3 f7 ff ff       	call   801359 <fd2data>
  801b76:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b78:	83 c4 08             	add    $0x8,%esp
  801b7b:	68 85 29 80 00       	push   $0x802985
  801b80:	53                   	push   %ebx
  801b81:	e8 c3 ed ff ff       	call   800949 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b86:	8b 46 04             	mov    0x4(%esi),%eax
  801b89:	2b 06                	sub    (%esi),%eax
  801b8b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b91:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b98:	00 00 00 
	stat->st_dev = &devpipe;
  801b9b:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801ba2:	30 80 00 
	return 0;
}
  801ba5:	b8 00 00 00 00       	mov    $0x0,%eax
  801baa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bad:	5b                   	pop    %ebx
  801bae:	5e                   	pop    %esi
  801baf:	5d                   	pop    %ebp
  801bb0:	c3                   	ret    

00801bb1 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801bb1:	55                   	push   %ebp
  801bb2:	89 e5                	mov    %esp,%ebp
  801bb4:	53                   	push   %ebx
  801bb5:	83 ec 0c             	sub    $0xc,%esp
  801bb8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801bbb:	53                   	push   %ebx
  801bbc:	6a 00                	push   $0x0
  801bbe:	e8 0e f2 ff ff       	call   800dd1 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801bc3:	89 1c 24             	mov    %ebx,(%esp)
  801bc6:	e8 8e f7 ff ff       	call   801359 <fd2data>
  801bcb:	83 c4 08             	add    $0x8,%esp
  801bce:	50                   	push   %eax
  801bcf:	6a 00                	push   $0x0
  801bd1:	e8 fb f1 ff ff       	call   800dd1 <sys_page_unmap>
}
  801bd6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bd9:	c9                   	leave  
  801bda:	c3                   	ret    

00801bdb <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801bdb:	55                   	push   %ebp
  801bdc:	89 e5                	mov    %esp,%ebp
  801bde:	57                   	push   %edi
  801bdf:	56                   	push   %esi
  801be0:	53                   	push   %ebx
  801be1:	83 ec 1c             	sub    $0x1c,%esp
  801be4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801be7:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801be9:	a1 04 40 80 00       	mov    0x804004,%eax
  801bee:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801bf1:	83 ec 0c             	sub    $0xc,%esp
  801bf4:	ff 75 e0             	pushl  -0x20(%ebp)
  801bf7:	e8 2c ff ff ff       	call   801b28 <pageref>
  801bfc:	89 c3                	mov    %eax,%ebx
  801bfe:	89 3c 24             	mov    %edi,(%esp)
  801c01:	e8 22 ff ff ff       	call   801b28 <pageref>
  801c06:	83 c4 10             	add    $0x10,%esp
  801c09:	39 c3                	cmp    %eax,%ebx
  801c0b:	0f 94 c1             	sete   %cl
  801c0e:	0f b6 c9             	movzbl %cl,%ecx
  801c11:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801c14:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801c1a:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801c1d:	39 ce                	cmp    %ecx,%esi
  801c1f:	74 1b                	je     801c3c <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801c21:	39 c3                	cmp    %eax,%ebx
  801c23:	75 c4                	jne    801be9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c25:	8b 42 58             	mov    0x58(%edx),%eax
  801c28:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c2b:	50                   	push   %eax
  801c2c:	56                   	push   %esi
  801c2d:	68 8c 29 80 00       	push   $0x80298c
  801c32:	e8 e6 e6 ff ff       	call   80031d <cprintf>
  801c37:	83 c4 10             	add    $0x10,%esp
  801c3a:	eb ad                	jmp    801be9 <_pipeisclosed+0xe>
	}
}
  801c3c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c42:	5b                   	pop    %ebx
  801c43:	5e                   	pop    %esi
  801c44:	5f                   	pop    %edi
  801c45:	5d                   	pop    %ebp
  801c46:	c3                   	ret    

00801c47 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c47:	55                   	push   %ebp
  801c48:	89 e5                	mov    %esp,%ebp
  801c4a:	57                   	push   %edi
  801c4b:	56                   	push   %esi
  801c4c:	53                   	push   %ebx
  801c4d:	83 ec 28             	sub    $0x28,%esp
  801c50:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801c53:	56                   	push   %esi
  801c54:	e8 00 f7 ff ff       	call   801359 <fd2data>
  801c59:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c5b:	83 c4 10             	add    $0x10,%esp
  801c5e:	bf 00 00 00 00       	mov    $0x0,%edi
  801c63:	eb 4b                	jmp    801cb0 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c65:	89 da                	mov    %ebx,%edx
  801c67:	89 f0                	mov    %esi,%eax
  801c69:	e8 6d ff ff ff       	call   801bdb <_pipeisclosed>
  801c6e:	85 c0                	test   %eax,%eax
  801c70:	75 48                	jne    801cba <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801c72:	e8 b6 f0 ff ff       	call   800d2d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c77:	8b 43 04             	mov    0x4(%ebx),%eax
  801c7a:	8b 0b                	mov    (%ebx),%ecx
  801c7c:	8d 51 20             	lea    0x20(%ecx),%edx
  801c7f:	39 d0                	cmp    %edx,%eax
  801c81:	73 e2                	jae    801c65 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c86:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c8a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c8d:	89 c2                	mov    %eax,%edx
  801c8f:	c1 fa 1f             	sar    $0x1f,%edx
  801c92:	89 d1                	mov    %edx,%ecx
  801c94:	c1 e9 1b             	shr    $0x1b,%ecx
  801c97:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c9a:	83 e2 1f             	and    $0x1f,%edx
  801c9d:	29 ca                	sub    %ecx,%edx
  801c9f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801ca3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ca7:	83 c0 01             	add    $0x1,%eax
  801caa:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cad:	83 c7 01             	add    $0x1,%edi
  801cb0:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801cb3:	75 c2                	jne    801c77 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801cb5:	8b 45 10             	mov    0x10(%ebp),%eax
  801cb8:	eb 05                	jmp    801cbf <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801cba:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801cbf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cc2:	5b                   	pop    %ebx
  801cc3:	5e                   	pop    %esi
  801cc4:	5f                   	pop    %edi
  801cc5:	5d                   	pop    %ebp
  801cc6:	c3                   	ret    

00801cc7 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801cc7:	55                   	push   %ebp
  801cc8:	89 e5                	mov    %esp,%ebp
  801cca:	57                   	push   %edi
  801ccb:	56                   	push   %esi
  801ccc:	53                   	push   %ebx
  801ccd:	83 ec 18             	sub    $0x18,%esp
  801cd0:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801cd3:	57                   	push   %edi
  801cd4:	e8 80 f6 ff ff       	call   801359 <fd2data>
  801cd9:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cdb:	83 c4 10             	add    $0x10,%esp
  801cde:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ce3:	eb 3d                	jmp    801d22 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801ce5:	85 db                	test   %ebx,%ebx
  801ce7:	74 04                	je     801ced <devpipe_read+0x26>
				return i;
  801ce9:	89 d8                	mov    %ebx,%eax
  801ceb:	eb 44                	jmp    801d31 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ced:	89 f2                	mov    %esi,%edx
  801cef:	89 f8                	mov    %edi,%eax
  801cf1:	e8 e5 fe ff ff       	call   801bdb <_pipeisclosed>
  801cf6:	85 c0                	test   %eax,%eax
  801cf8:	75 32                	jne    801d2c <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801cfa:	e8 2e f0 ff ff       	call   800d2d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801cff:	8b 06                	mov    (%esi),%eax
  801d01:	3b 46 04             	cmp    0x4(%esi),%eax
  801d04:	74 df                	je     801ce5 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d06:	99                   	cltd   
  801d07:	c1 ea 1b             	shr    $0x1b,%edx
  801d0a:	01 d0                	add    %edx,%eax
  801d0c:	83 e0 1f             	and    $0x1f,%eax
  801d0f:	29 d0                	sub    %edx,%eax
  801d11:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801d16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d19:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801d1c:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d1f:	83 c3 01             	add    $0x1,%ebx
  801d22:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801d25:	75 d8                	jne    801cff <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801d27:	8b 45 10             	mov    0x10(%ebp),%eax
  801d2a:	eb 05                	jmp    801d31 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d2c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801d31:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d34:	5b                   	pop    %ebx
  801d35:	5e                   	pop    %esi
  801d36:	5f                   	pop    %edi
  801d37:	5d                   	pop    %ebp
  801d38:	c3                   	ret    

00801d39 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801d39:	55                   	push   %ebp
  801d3a:	89 e5                	mov    %esp,%ebp
  801d3c:	56                   	push   %esi
  801d3d:	53                   	push   %ebx
  801d3e:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801d41:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d44:	50                   	push   %eax
  801d45:	e8 26 f6 ff ff       	call   801370 <fd_alloc>
  801d4a:	83 c4 10             	add    $0x10,%esp
  801d4d:	89 c2                	mov    %eax,%edx
  801d4f:	85 c0                	test   %eax,%eax
  801d51:	0f 88 2c 01 00 00    	js     801e83 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d57:	83 ec 04             	sub    $0x4,%esp
  801d5a:	68 07 04 00 00       	push   $0x407
  801d5f:	ff 75 f4             	pushl  -0xc(%ebp)
  801d62:	6a 00                	push   $0x0
  801d64:	e8 e3 ef ff ff       	call   800d4c <sys_page_alloc>
  801d69:	83 c4 10             	add    $0x10,%esp
  801d6c:	89 c2                	mov    %eax,%edx
  801d6e:	85 c0                	test   %eax,%eax
  801d70:	0f 88 0d 01 00 00    	js     801e83 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d76:	83 ec 0c             	sub    $0xc,%esp
  801d79:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d7c:	50                   	push   %eax
  801d7d:	e8 ee f5 ff ff       	call   801370 <fd_alloc>
  801d82:	89 c3                	mov    %eax,%ebx
  801d84:	83 c4 10             	add    $0x10,%esp
  801d87:	85 c0                	test   %eax,%eax
  801d89:	0f 88 e2 00 00 00    	js     801e71 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d8f:	83 ec 04             	sub    $0x4,%esp
  801d92:	68 07 04 00 00       	push   $0x407
  801d97:	ff 75 f0             	pushl  -0x10(%ebp)
  801d9a:	6a 00                	push   $0x0
  801d9c:	e8 ab ef ff ff       	call   800d4c <sys_page_alloc>
  801da1:	89 c3                	mov    %eax,%ebx
  801da3:	83 c4 10             	add    $0x10,%esp
  801da6:	85 c0                	test   %eax,%eax
  801da8:	0f 88 c3 00 00 00    	js     801e71 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801dae:	83 ec 0c             	sub    $0xc,%esp
  801db1:	ff 75 f4             	pushl  -0xc(%ebp)
  801db4:	e8 a0 f5 ff ff       	call   801359 <fd2data>
  801db9:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dbb:	83 c4 0c             	add    $0xc,%esp
  801dbe:	68 07 04 00 00       	push   $0x407
  801dc3:	50                   	push   %eax
  801dc4:	6a 00                	push   $0x0
  801dc6:	e8 81 ef ff ff       	call   800d4c <sys_page_alloc>
  801dcb:	89 c3                	mov    %eax,%ebx
  801dcd:	83 c4 10             	add    $0x10,%esp
  801dd0:	85 c0                	test   %eax,%eax
  801dd2:	0f 88 89 00 00 00    	js     801e61 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dd8:	83 ec 0c             	sub    $0xc,%esp
  801ddb:	ff 75 f0             	pushl  -0x10(%ebp)
  801dde:	e8 76 f5 ff ff       	call   801359 <fd2data>
  801de3:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801dea:	50                   	push   %eax
  801deb:	6a 00                	push   $0x0
  801ded:	56                   	push   %esi
  801dee:	6a 00                	push   $0x0
  801df0:	e8 9a ef ff ff       	call   800d8f <sys_page_map>
  801df5:	89 c3                	mov    %eax,%ebx
  801df7:	83 c4 20             	add    $0x20,%esp
  801dfa:	85 c0                	test   %eax,%eax
  801dfc:	78 55                	js     801e53 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801dfe:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e04:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e07:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801e09:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e0c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801e13:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e19:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e1c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e21:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801e28:	83 ec 0c             	sub    $0xc,%esp
  801e2b:	ff 75 f4             	pushl  -0xc(%ebp)
  801e2e:	e8 16 f5 ff ff       	call   801349 <fd2num>
  801e33:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e36:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e38:	83 c4 04             	add    $0x4,%esp
  801e3b:	ff 75 f0             	pushl  -0x10(%ebp)
  801e3e:	e8 06 f5 ff ff       	call   801349 <fd2num>
  801e43:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e46:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801e49:	83 c4 10             	add    $0x10,%esp
  801e4c:	ba 00 00 00 00       	mov    $0x0,%edx
  801e51:	eb 30                	jmp    801e83 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801e53:	83 ec 08             	sub    $0x8,%esp
  801e56:	56                   	push   %esi
  801e57:	6a 00                	push   $0x0
  801e59:	e8 73 ef ff ff       	call   800dd1 <sys_page_unmap>
  801e5e:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801e61:	83 ec 08             	sub    $0x8,%esp
  801e64:	ff 75 f0             	pushl  -0x10(%ebp)
  801e67:	6a 00                	push   $0x0
  801e69:	e8 63 ef ff ff       	call   800dd1 <sys_page_unmap>
  801e6e:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801e71:	83 ec 08             	sub    $0x8,%esp
  801e74:	ff 75 f4             	pushl  -0xc(%ebp)
  801e77:	6a 00                	push   $0x0
  801e79:	e8 53 ef ff ff       	call   800dd1 <sys_page_unmap>
  801e7e:	83 c4 10             	add    $0x10,%esp
  801e81:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801e83:	89 d0                	mov    %edx,%eax
  801e85:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e88:	5b                   	pop    %ebx
  801e89:	5e                   	pop    %esi
  801e8a:	5d                   	pop    %ebp
  801e8b:	c3                   	ret    

00801e8c <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e8c:	55                   	push   %ebp
  801e8d:	89 e5                	mov    %esp,%ebp
  801e8f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e92:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e95:	50                   	push   %eax
  801e96:	ff 75 08             	pushl  0x8(%ebp)
  801e99:	e8 21 f5 ff ff       	call   8013bf <fd_lookup>
  801e9e:	83 c4 10             	add    $0x10,%esp
  801ea1:	85 c0                	test   %eax,%eax
  801ea3:	78 18                	js     801ebd <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801ea5:	83 ec 0c             	sub    $0xc,%esp
  801ea8:	ff 75 f4             	pushl  -0xc(%ebp)
  801eab:	e8 a9 f4 ff ff       	call   801359 <fd2data>
	return _pipeisclosed(fd, p);
  801eb0:	89 c2                	mov    %eax,%edx
  801eb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eb5:	e8 21 fd ff ff       	call   801bdb <_pipeisclosed>
  801eba:	83 c4 10             	add    $0x10,%esp
}
  801ebd:	c9                   	leave  
  801ebe:	c3                   	ret    

00801ebf <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ebf:	55                   	push   %ebp
  801ec0:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ec2:	b8 00 00 00 00       	mov    $0x0,%eax
  801ec7:	5d                   	pop    %ebp
  801ec8:	c3                   	ret    

00801ec9 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ec9:	55                   	push   %ebp
  801eca:	89 e5                	mov    %esp,%ebp
  801ecc:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801ecf:	68 a4 29 80 00       	push   $0x8029a4
  801ed4:	ff 75 0c             	pushl  0xc(%ebp)
  801ed7:	e8 6d ea ff ff       	call   800949 <strcpy>
	return 0;
}
  801edc:	b8 00 00 00 00       	mov    $0x0,%eax
  801ee1:	c9                   	leave  
  801ee2:	c3                   	ret    

00801ee3 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ee3:	55                   	push   %ebp
  801ee4:	89 e5                	mov    %esp,%ebp
  801ee6:	57                   	push   %edi
  801ee7:	56                   	push   %esi
  801ee8:	53                   	push   %ebx
  801ee9:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801eef:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ef4:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801efa:	eb 2d                	jmp    801f29 <devcons_write+0x46>
		m = n - tot;
  801efc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801eff:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801f01:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801f04:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801f09:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f0c:	83 ec 04             	sub    $0x4,%esp
  801f0f:	53                   	push   %ebx
  801f10:	03 45 0c             	add    0xc(%ebp),%eax
  801f13:	50                   	push   %eax
  801f14:	57                   	push   %edi
  801f15:	e8 c1 eb ff ff       	call   800adb <memmove>
		sys_cputs(buf, m);
  801f1a:	83 c4 08             	add    $0x8,%esp
  801f1d:	53                   	push   %ebx
  801f1e:	57                   	push   %edi
  801f1f:	e8 6c ed ff ff       	call   800c90 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f24:	01 de                	add    %ebx,%esi
  801f26:	83 c4 10             	add    $0x10,%esp
  801f29:	89 f0                	mov    %esi,%eax
  801f2b:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f2e:	72 cc                	jb     801efc <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801f30:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f33:	5b                   	pop    %ebx
  801f34:	5e                   	pop    %esi
  801f35:	5f                   	pop    %edi
  801f36:	5d                   	pop    %ebp
  801f37:	c3                   	ret    

00801f38 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f38:	55                   	push   %ebp
  801f39:	89 e5                	mov    %esp,%ebp
  801f3b:	83 ec 08             	sub    $0x8,%esp
  801f3e:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801f43:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f47:	74 2a                	je     801f73 <devcons_read+0x3b>
  801f49:	eb 05                	jmp    801f50 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f4b:	e8 dd ed ff ff       	call   800d2d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f50:	e8 59 ed ff ff       	call   800cae <sys_cgetc>
  801f55:	85 c0                	test   %eax,%eax
  801f57:	74 f2                	je     801f4b <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801f59:	85 c0                	test   %eax,%eax
  801f5b:	78 16                	js     801f73 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f5d:	83 f8 04             	cmp    $0x4,%eax
  801f60:	74 0c                	je     801f6e <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801f62:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f65:	88 02                	mov    %al,(%edx)
	return 1;
  801f67:	b8 01 00 00 00       	mov    $0x1,%eax
  801f6c:	eb 05                	jmp    801f73 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801f6e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801f73:	c9                   	leave  
  801f74:	c3                   	ret    

00801f75 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f75:	55                   	push   %ebp
  801f76:	89 e5                	mov    %esp,%ebp
  801f78:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f7b:	8b 45 08             	mov    0x8(%ebp),%eax
  801f7e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f81:	6a 01                	push   $0x1
  801f83:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f86:	50                   	push   %eax
  801f87:	e8 04 ed ff ff       	call   800c90 <sys_cputs>
}
  801f8c:	83 c4 10             	add    $0x10,%esp
  801f8f:	c9                   	leave  
  801f90:	c3                   	ret    

00801f91 <getchar>:

int
getchar(void)
{
  801f91:	55                   	push   %ebp
  801f92:	89 e5                	mov    %esp,%ebp
  801f94:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f97:	6a 01                	push   $0x1
  801f99:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f9c:	50                   	push   %eax
  801f9d:	6a 00                	push   $0x0
  801f9f:	e8 81 f6 ff ff       	call   801625 <read>
	if (r < 0)
  801fa4:	83 c4 10             	add    $0x10,%esp
  801fa7:	85 c0                	test   %eax,%eax
  801fa9:	78 0f                	js     801fba <getchar+0x29>
		return r;
	if (r < 1)
  801fab:	85 c0                	test   %eax,%eax
  801fad:	7e 06                	jle    801fb5 <getchar+0x24>
		return -E_EOF;
	return c;
  801faf:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801fb3:	eb 05                	jmp    801fba <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801fb5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801fba:	c9                   	leave  
  801fbb:	c3                   	ret    

00801fbc <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801fbc:	55                   	push   %ebp
  801fbd:	89 e5                	mov    %esp,%ebp
  801fbf:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fc2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fc5:	50                   	push   %eax
  801fc6:	ff 75 08             	pushl  0x8(%ebp)
  801fc9:	e8 f1 f3 ff ff       	call   8013bf <fd_lookup>
  801fce:	83 c4 10             	add    $0x10,%esp
  801fd1:	85 c0                	test   %eax,%eax
  801fd3:	78 11                	js     801fe6 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801fd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fd8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fde:	39 10                	cmp    %edx,(%eax)
  801fe0:	0f 94 c0             	sete   %al
  801fe3:	0f b6 c0             	movzbl %al,%eax
}
  801fe6:	c9                   	leave  
  801fe7:	c3                   	ret    

00801fe8 <opencons>:

int
opencons(void)
{
  801fe8:	55                   	push   %ebp
  801fe9:	89 e5                	mov    %esp,%ebp
  801feb:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ff1:	50                   	push   %eax
  801ff2:	e8 79 f3 ff ff       	call   801370 <fd_alloc>
  801ff7:	83 c4 10             	add    $0x10,%esp
		return r;
  801ffa:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ffc:	85 c0                	test   %eax,%eax
  801ffe:	78 3e                	js     80203e <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802000:	83 ec 04             	sub    $0x4,%esp
  802003:	68 07 04 00 00       	push   $0x407
  802008:	ff 75 f4             	pushl  -0xc(%ebp)
  80200b:	6a 00                	push   $0x0
  80200d:	e8 3a ed ff ff       	call   800d4c <sys_page_alloc>
  802012:	83 c4 10             	add    $0x10,%esp
		return r;
  802015:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802017:	85 c0                	test   %eax,%eax
  802019:	78 23                	js     80203e <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80201b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802021:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802024:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802026:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802029:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802030:	83 ec 0c             	sub    $0xc,%esp
  802033:	50                   	push   %eax
  802034:	e8 10 f3 ff ff       	call   801349 <fd2num>
  802039:	89 c2                	mov    %eax,%edx
  80203b:	83 c4 10             	add    $0x10,%esp
}
  80203e:	89 d0                	mov    %edx,%eax
  802040:	c9                   	leave  
  802041:	c3                   	ret    

00802042 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802042:	55                   	push   %ebp
  802043:	89 e5                	mov    %esp,%ebp
  802045:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802048:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80204f:	75 31                	jne    802082 <set_pgfault_handler+0x40>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc(thisenv->env_id, (void*)(UXSTACKTOP - PGSIZE), PTE_P | 
  802051:	a1 04 40 80 00       	mov    0x804004,%eax
  802056:	8b 40 48             	mov    0x48(%eax),%eax
  802059:	83 ec 04             	sub    $0x4,%esp
  80205c:	6a 07                	push   $0x7
  80205e:	68 00 f0 bf ee       	push   $0xeebff000
  802063:	50                   	push   %eax
  802064:	e8 e3 ec ff ff       	call   800d4c <sys_page_alloc>
				PTE_U | PTE_W);
		sys_env_set_pgfault_upcall(thisenv->env_id, (void*)_pgfault_upcall);
  802069:	a1 04 40 80 00       	mov    0x804004,%eax
  80206e:	8b 40 48             	mov    0x48(%eax),%eax
  802071:	83 c4 08             	add    $0x8,%esp
  802074:	68 8c 20 80 00       	push   $0x80208c
  802079:	50                   	push   %eax
  80207a:	e8 18 ee ff ff       	call   800e97 <sys_env_set_pgfault_upcall>
  80207f:	83 c4 10             	add    $0x10,%esp

		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802082:	8b 45 08             	mov    0x8(%ebp),%eax
  802085:	a3 00 60 80 00       	mov    %eax,0x806000
}
  80208a:	c9                   	leave  
  80208b:	c3                   	ret    

0080208c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80208c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80208d:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802092:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802094:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	addl $8, %esp      // pop utf_fault_va and utf_err
  802097:	83 c4 08             	add    $0x8,%esp
	movl 32(%esp), %eax  // eax <- [esp + 32]
  80209a:	8b 44 24 20          	mov    0x20(%esp),%eax
	movl 40(%esp), %ebx  // ebx <- [esp + 40]
  80209e:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	leal -4(%ebx), %ebx  // ebx <- ebx - 4
  8020a2:	8d 5b fc             	lea    -0x4(%ebx),%ebx
	movl %eax, (%ebx)
  8020a5:	89 03                	mov    %eax,(%ebx)
	movl %ebx, 40(%esp)  // push trap eip and decrement trap esp manually
  8020a7:	89 5c 24 28          	mov    %ebx,0x28(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  8020ab:	61                   	popa   
	addl $4, %esp        // skip eip
  8020ac:	83 c4 04             	add    $0x4,%esp

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	popf
  8020af:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	pop %esp
  8020b0:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8020b1:	c3                   	ret    
  8020b2:	66 90                	xchg   %ax,%ax
  8020b4:	66 90                	xchg   %ax,%ax
  8020b6:	66 90                	xchg   %ax,%ax
  8020b8:	66 90                	xchg   %ax,%ax
  8020ba:	66 90                	xchg   %ax,%ax
  8020bc:	66 90                	xchg   %ax,%ax
  8020be:	66 90                	xchg   %ax,%ax

008020c0 <__udivdi3>:
  8020c0:	55                   	push   %ebp
  8020c1:	57                   	push   %edi
  8020c2:	56                   	push   %esi
  8020c3:	53                   	push   %ebx
  8020c4:	83 ec 1c             	sub    $0x1c,%esp
  8020c7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8020cb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8020cf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8020d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020d7:	85 f6                	test   %esi,%esi
  8020d9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020dd:	89 ca                	mov    %ecx,%edx
  8020df:	89 f8                	mov    %edi,%eax
  8020e1:	75 3d                	jne    802120 <__udivdi3+0x60>
  8020e3:	39 cf                	cmp    %ecx,%edi
  8020e5:	0f 87 c5 00 00 00    	ja     8021b0 <__udivdi3+0xf0>
  8020eb:	85 ff                	test   %edi,%edi
  8020ed:	89 fd                	mov    %edi,%ebp
  8020ef:	75 0b                	jne    8020fc <__udivdi3+0x3c>
  8020f1:	b8 01 00 00 00       	mov    $0x1,%eax
  8020f6:	31 d2                	xor    %edx,%edx
  8020f8:	f7 f7                	div    %edi
  8020fa:	89 c5                	mov    %eax,%ebp
  8020fc:	89 c8                	mov    %ecx,%eax
  8020fe:	31 d2                	xor    %edx,%edx
  802100:	f7 f5                	div    %ebp
  802102:	89 c1                	mov    %eax,%ecx
  802104:	89 d8                	mov    %ebx,%eax
  802106:	89 cf                	mov    %ecx,%edi
  802108:	f7 f5                	div    %ebp
  80210a:	89 c3                	mov    %eax,%ebx
  80210c:	89 d8                	mov    %ebx,%eax
  80210e:	89 fa                	mov    %edi,%edx
  802110:	83 c4 1c             	add    $0x1c,%esp
  802113:	5b                   	pop    %ebx
  802114:	5e                   	pop    %esi
  802115:	5f                   	pop    %edi
  802116:	5d                   	pop    %ebp
  802117:	c3                   	ret    
  802118:	90                   	nop
  802119:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802120:	39 ce                	cmp    %ecx,%esi
  802122:	77 74                	ja     802198 <__udivdi3+0xd8>
  802124:	0f bd fe             	bsr    %esi,%edi
  802127:	83 f7 1f             	xor    $0x1f,%edi
  80212a:	0f 84 98 00 00 00    	je     8021c8 <__udivdi3+0x108>
  802130:	bb 20 00 00 00       	mov    $0x20,%ebx
  802135:	89 f9                	mov    %edi,%ecx
  802137:	89 c5                	mov    %eax,%ebp
  802139:	29 fb                	sub    %edi,%ebx
  80213b:	d3 e6                	shl    %cl,%esi
  80213d:	89 d9                	mov    %ebx,%ecx
  80213f:	d3 ed                	shr    %cl,%ebp
  802141:	89 f9                	mov    %edi,%ecx
  802143:	d3 e0                	shl    %cl,%eax
  802145:	09 ee                	or     %ebp,%esi
  802147:	89 d9                	mov    %ebx,%ecx
  802149:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80214d:	89 d5                	mov    %edx,%ebp
  80214f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802153:	d3 ed                	shr    %cl,%ebp
  802155:	89 f9                	mov    %edi,%ecx
  802157:	d3 e2                	shl    %cl,%edx
  802159:	89 d9                	mov    %ebx,%ecx
  80215b:	d3 e8                	shr    %cl,%eax
  80215d:	09 c2                	or     %eax,%edx
  80215f:	89 d0                	mov    %edx,%eax
  802161:	89 ea                	mov    %ebp,%edx
  802163:	f7 f6                	div    %esi
  802165:	89 d5                	mov    %edx,%ebp
  802167:	89 c3                	mov    %eax,%ebx
  802169:	f7 64 24 0c          	mull   0xc(%esp)
  80216d:	39 d5                	cmp    %edx,%ebp
  80216f:	72 10                	jb     802181 <__udivdi3+0xc1>
  802171:	8b 74 24 08          	mov    0x8(%esp),%esi
  802175:	89 f9                	mov    %edi,%ecx
  802177:	d3 e6                	shl    %cl,%esi
  802179:	39 c6                	cmp    %eax,%esi
  80217b:	73 07                	jae    802184 <__udivdi3+0xc4>
  80217d:	39 d5                	cmp    %edx,%ebp
  80217f:	75 03                	jne    802184 <__udivdi3+0xc4>
  802181:	83 eb 01             	sub    $0x1,%ebx
  802184:	31 ff                	xor    %edi,%edi
  802186:	89 d8                	mov    %ebx,%eax
  802188:	89 fa                	mov    %edi,%edx
  80218a:	83 c4 1c             	add    $0x1c,%esp
  80218d:	5b                   	pop    %ebx
  80218e:	5e                   	pop    %esi
  80218f:	5f                   	pop    %edi
  802190:	5d                   	pop    %ebp
  802191:	c3                   	ret    
  802192:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802198:	31 ff                	xor    %edi,%edi
  80219a:	31 db                	xor    %ebx,%ebx
  80219c:	89 d8                	mov    %ebx,%eax
  80219e:	89 fa                	mov    %edi,%edx
  8021a0:	83 c4 1c             	add    $0x1c,%esp
  8021a3:	5b                   	pop    %ebx
  8021a4:	5e                   	pop    %esi
  8021a5:	5f                   	pop    %edi
  8021a6:	5d                   	pop    %ebp
  8021a7:	c3                   	ret    
  8021a8:	90                   	nop
  8021a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021b0:	89 d8                	mov    %ebx,%eax
  8021b2:	f7 f7                	div    %edi
  8021b4:	31 ff                	xor    %edi,%edi
  8021b6:	89 c3                	mov    %eax,%ebx
  8021b8:	89 d8                	mov    %ebx,%eax
  8021ba:	89 fa                	mov    %edi,%edx
  8021bc:	83 c4 1c             	add    $0x1c,%esp
  8021bf:	5b                   	pop    %ebx
  8021c0:	5e                   	pop    %esi
  8021c1:	5f                   	pop    %edi
  8021c2:	5d                   	pop    %ebp
  8021c3:	c3                   	ret    
  8021c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021c8:	39 ce                	cmp    %ecx,%esi
  8021ca:	72 0c                	jb     8021d8 <__udivdi3+0x118>
  8021cc:	31 db                	xor    %ebx,%ebx
  8021ce:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8021d2:	0f 87 34 ff ff ff    	ja     80210c <__udivdi3+0x4c>
  8021d8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8021dd:	e9 2a ff ff ff       	jmp    80210c <__udivdi3+0x4c>
  8021e2:	66 90                	xchg   %ax,%ax
  8021e4:	66 90                	xchg   %ax,%ax
  8021e6:	66 90                	xchg   %ax,%ax
  8021e8:	66 90                	xchg   %ax,%ax
  8021ea:	66 90                	xchg   %ax,%ax
  8021ec:	66 90                	xchg   %ax,%ax
  8021ee:	66 90                	xchg   %ax,%ax

008021f0 <__umoddi3>:
  8021f0:	55                   	push   %ebp
  8021f1:	57                   	push   %edi
  8021f2:	56                   	push   %esi
  8021f3:	53                   	push   %ebx
  8021f4:	83 ec 1c             	sub    $0x1c,%esp
  8021f7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8021fb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8021ff:	8b 74 24 34          	mov    0x34(%esp),%esi
  802203:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802207:	85 d2                	test   %edx,%edx
  802209:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80220d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802211:	89 f3                	mov    %esi,%ebx
  802213:	89 3c 24             	mov    %edi,(%esp)
  802216:	89 74 24 04          	mov    %esi,0x4(%esp)
  80221a:	75 1c                	jne    802238 <__umoddi3+0x48>
  80221c:	39 f7                	cmp    %esi,%edi
  80221e:	76 50                	jbe    802270 <__umoddi3+0x80>
  802220:	89 c8                	mov    %ecx,%eax
  802222:	89 f2                	mov    %esi,%edx
  802224:	f7 f7                	div    %edi
  802226:	89 d0                	mov    %edx,%eax
  802228:	31 d2                	xor    %edx,%edx
  80222a:	83 c4 1c             	add    $0x1c,%esp
  80222d:	5b                   	pop    %ebx
  80222e:	5e                   	pop    %esi
  80222f:	5f                   	pop    %edi
  802230:	5d                   	pop    %ebp
  802231:	c3                   	ret    
  802232:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802238:	39 f2                	cmp    %esi,%edx
  80223a:	89 d0                	mov    %edx,%eax
  80223c:	77 52                	ja     802290 <__umoddi3+0xa0>
  80223e:	0f bd ea             	bsr    %edx,%ebp
  802241:	83 f5 1f             	xor    $0x1f,%ebp
  802244:	75 5a                	jne    8022a0 <__umoddi3+0xb0>
  802246:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80224a:	0f 82 e0 00 00 00    	jb     802330 <__umoddi3+0x140>
  802250:	39 0c 24             	cmp    %ecx,(%esp)
  802253:	0f 86 d7 00 00 00    	jbe    802330 <__umoddi3+0x140>
  802259:	8b 44 24 08          	mov    0x8(%esp),%eax
  80225d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802261:	83 c4 1c             	add    $0x1c,%esp
  802264:	5b                   	pop    %ebx
  802265:	5e                   	pop    %esi
  802266:	5f                   	pop    %edi
  802267:	5d                   	pop    %ebp
  802268:	c3                   	ret    
  802269:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802270:	85 ff                	test   %edi,%edi
  802272:	89 fd                	mov    %edi,%ebp
  802274:	75 0b                	jne    802281 <__umoddi3+0x91>
  802276:	b8 01 00 00 00       	mov    $0x1,%eax
  80227b:	31 d2                	xor    %edx,%edx
  80227d:	f7 f7                	div    %edi
  80227f:	89 c5                	mov    %eax,%ebp
  802281:	89 f0                	mov    %esi,%eax
  802283:	31 d2                	xor    %edx,%edx
  802285:	f7 f5                	div    %ebp
  802287:	89 c8                	mov    %ecx,%eax
  802289:	f7 f5                	div    %ebp
  80228b:	89 d0                	mov    %edx,%eax
  80228d:	eb 99                	jmp    802228 <__umoddi3+0x38>
  80228f:	90                   	nop
  802290:	89 c8                	mov    %ecx,%eax
  802292:	89 f2                	mov    %esi,%edx
  802294:	83 c4 1c             	add    $0x1c,%esp
  802297:	5b                   	pop    %ebx
  802298:	5e                   	pop    %esi
  802299:	5f                   	pop    %edi
  80229a:	5d                   	pop    %ebp
  80229b:	c3                   	ret    
  80229c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022a0:	8b 34 24             	mov    (%esp),%esi
  8022a3:	bf 20 00 00 00       	mov    $0x20,%edi
  8022a8:	89 e9                	mov    %ebp,%ecx
  8022aa:	29 ef                	sub    %ebp,%edi
  8022ac:	d3 e0                	shl    %cl,%eax
  8022ae:	89 f9                	mov    %edi,%ecx
  8022b0:	89 f2                	mov    %esi,%edx
  8022b2:	d3 ea                	shr    %cl,%edx
  8022b4:	89 e9                	mov    %ebp,%ecx
  8022b6:	09 c2                	or     %eax,%edx
  8022b8:	89 d8                	mov    %ebx,%eax
  8022ba:	89 14 24             	mov    %edx,(%esp)
  8022bd:	89 f2                	mov    %esi,%edx
  8022bf:	d3 e2                	shl    %cl,%edx
  8022c1:	89 f9                	mov    %edi,%ecx
  8022c3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8022c7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8022cb:	d3 e8                	shr    %cl,%eax
  8022cd:	89 e9                	mov    %ebp,%ecx
  8022cf:	89 c6                	mov    %eax,%esi
  8022d1:	d3 e3                	shl    %cl,%ebx
  8022d3:	89 f9                	mov    %edi,%ecx
  8022d5:	89 d0                	mov    %edx,%eax
  8022d7:	d3 e8                	shr    %cl,%eax
  8022d9:	89 e9                	mov    %ebp,%ecx
  8022db:	09 d8                	or     %ebx,%eax
  8022dd:	89 d3                	mov    %edx,%ebx
  8022df:	89 f2                	mov    %esi,%edx
  8022e1:	f7 34 24             	divl   (%esp)
  8022e4:	89 d6                	mov    %edx,%esi
  8022e6:	d3 e3                	shl    %cl,%ebx
  8022e8:	f7 64 24 04          	mull   0x4(%esp)
  8022ec:	39 d6                	cmp    %edx,%esi
  8022ee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022f2:	89 d1                	mov    %edx,%ecx
  8022f4:	89 c3                	mov    %eax,%ebx
  8022f6:	72 08                	jb     802300 <__umoddi3+0x110>
  8022f8:	75 11                	jne    80230b <__umoddi3+0x11b>
  8022fa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8022fe:	73 0b                	jae    80230b <__umoddi3+0x11b>
  802300:	2b 44 24 04          	sub    0x4(%esp),%eax
  802304:	1b 14 24             	sbb    (%esp),%edx
  802307:	89 d1                	mov    %edx,%ecx
  802309:	89 c3                	mov    %eax,%ebx
  80230b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80230f:	29 da                	sub    %ebx,%edx
  802311:	19 ce                	sbb    %ecx,%esi
  802313:	89 f9                	mov    %edi,%ecx
  802315:	89 f0                	mov    %esi,%eax
  802317:	d3 e0                	shl    %cl,%eax
  802319:	89 e9                	mov    %ebp,%ecx
  80231b:	d3 ea                	shr    %cl,%edx
  80231d:	89 e9                	mov    %ebp,%ecx
  80231f:	d3 ee                	shr    %cl,%esi
  802321:	09 d0                	or     %edx,%eax
  802323:	89 f2                	mov    %esi,%edx
  802325:	83 c4 1c             	add    $0x1c,%esp
  802328:	5b                   	pop    %ebx
  802329:	5e                   	pop    %esi
  80232a:	5f                   	pop    %edi
  80232b:	5d                   	pop    %ebp
  80232c:	c3                   	ret    
  80232d:	8d 76 00             	lea    0x0(%esi),%esi
  802330:	29 f9                	sub    %edi,%ecx
  802332:	19 d6                	sbb    %edx,%esi
  802334:	89 74 24 04          	mov    %esi,0x4(%esp)
  802338:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80233c:	e9 18 ff ff ff       	jmp    802259 <__umoddi3+0x69>
