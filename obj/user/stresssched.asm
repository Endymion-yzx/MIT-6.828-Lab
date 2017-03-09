
obj/user/stresssched.debug:     file format elf32-i386


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
  80002c:	e8 bc 00 00 00       	call   8000ed <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

volatile int counter;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();
  800038:	e8 da 0b 00 00       	call   800c17 <sys_getenvid>
  80003d:	89 c6                	mov    %eax,%esi

	// Fork several environments
	for (i = 0; i < 20; i++)
  80003f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fork() == 0)
  800044:	e8 aa 0f 00 00       	call   800ff3 <fork>
  800049:	85 c0                	test   %eax,%eax
  80004b:	74 0a                	je     800057 <umain+0x24>
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();

	// Fork several environments
	for (i = 0; i < 20; i++)
  80004d:	83 c3 01             	add    $0x1,%ebx
  800050:	83 fb 14             	cmp    $0x14,%ebx
  800053:	75 ef                	jne    800044 <umain+0x11>
  800055:	eb 05                	jmp    80005c <umain+0x29>
		if (fork() == 0)
			break;
	if (i == 20) {
  800057:	83 fb 14             	cmp    $0x14,%ebx
  80005a:	75 0e                	jne    80006a <umain+0x37>
		sys_yield();
  80005c:	e8 d5 0b 00 00       	call   800c36 <sys_yield>
		return;
  800061:	e9 80 00 00 00       	jmp    8000e6 <umain+0xb3>
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");
  800066:	f3 90                	pause  
  800068:	eb 0f                	jmp    800079 <umain+0x46>
		sys_yield();
		return;
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  80006a:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  800070:	6b d6 7c             	imul   $0x7c,%esi,%edx
  800073:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800079:	8b 42 54             	mov    0x54(%edx),%eax
  80007c:	85 c0                	test   %eax,%eax
  80007e:	75 e6                	jne    800066 <umain+0x33>
  800080:	bb 0a 00 00 00       	mov    $0xa,%ebx
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
  800085:	e8 ac 0b 00 00       	call   800c36 <sys_yield>
  80008a:	ba 10 27 00 00       	mov    $0x2710,%edx
		for (j = 0; j < 10000; j++)
			counter++;
  80008f:	a1 04 40 80 00       	mov    0x804004,%eax
  800094:	83 c0 01             	add    $0x1,%eax
  800097:	a3 04 40 80 00       	mov    %eax,0x804004
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
		for (j = 0; j < 10000; j++)
  80009c:	83 ea 01             	sub    $0x1,%edx
  80009f:	75 ee                	jne    80008f <umain+0x5c>
	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
  8000a1:	83 eb 01             	sub    $0x1,%ebx
  8000a4:	75 df                	jne    800085 <umain+0x52>
		sys_yield();
		for (j = 0; j < 10000; j++)
			counter++;
	}

	if (counter != 10*10000)
  8000a6:	a1 04 40 80 00       	mov    0x804004,%eax
  8000ab:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000b0:	74 17                	je     8000c9 <umain+0x96>
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000b2:	a1 04 40 80 00       	mov    0x804004,%eax
  8000b7:	50                   	push   %eax
  8000b8:	68 60 22 80 00       	push   $0x802260
  8000bd:	6a 21                	push   $0x21
  8000bf:	68 88 22 80 00       	push   $0x802288
  8000c4:	e8 84 00 00 00       	call   80014d <_panic>

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000c9:	a1 08 40 80 00       	mov    0x804008,%eax
  8000ce:	8b 50 5c             	mov    0x5c(%eax),%edx
  8000d1:	8b 40 48             	mov    0x48(%eax),%eax
  8000d4:	83 ec 04             	sub    $0x4,%esp
  8000d7:	52                   	push   %edx
  8000d8:	50                   	push   %eax
  8000d9:	68 9b 22 80 00       	push   $0x80229b
  8000de:	e8 43 01 00 00       	call   800226 <cprintf>
  8000e3:	83 c4 10             	add    $0x10,%esp

}
  8000e6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000e9:	5b                   	pop    %ebx
  8000ea:	5e                   	pop    %esi
  8000eb:	5d                   	pop    %ebp
  8000ec:	c3                   	ret    

008000ed <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000ed:	55                   	push   %ebp
  8000ee:	89 e5                	mov    %esp,%ebp
  8000f0:	56                   	push   %esi
  8000f1:	53                   	push   %ebx
  8000f2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000f5:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	envid_t envid = sys_getenvid();
  8000f8:	e8 1a 0b 00 00       	call   800c17 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8000fd:	25 ff 03 00 00       	and    $0x3ff,%eax
  800102:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800105:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80010a:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80010f:	85 db                	test   %ebx,%ebx
  800111:	7e 07                	jle    80011a <libmain+0x2d>
		binaryname = argv[0];
  800113:	8b 06                	mov    (%esi),%eax
  800115:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80011a:	83 ec 08             	sub    $0x8,%esp
  80011d:	56                   	push   %esi
  80011e:	53                   	push   %ebx
  80011f:	e8 0f ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800124:	e8 0a 00 00 00       	call   800133 <exit>
}
  800129:	83 c4 10             	add    $0x10,%esp
  80012c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80012f:	5b                   	pop    %ebx
  800130:	5e                   	pop    %esi
  800131:	5d                   	pop    %ebp
  800132:	c3                   	ret    

00800133 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800133:	55                   	push   %ebp
  800134:	89 e5                	mov    %esp,%ebp
  800136:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800139:	e8 dd 11 00 00       	call   80131b <close_all>
	sys_env_destroy(0);
  80013e:	83 ec 0c             	sub    $0xc,%esp
  800141:	6a 00                	push   $0x0
  800143:	e8 8e 0a 00 00       	call   800bd6 <sys_env_destroy>
}
  800148:	83 c4 10             	add    $0x10,%esp
  80014b:	c9                   	leave  
  80014c:	c3                   	ret    

0080014d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80014d:	55                   	push   %ebp
  80014e:	89 e5                	mov    %esp,%ebp
  800150:	56                   	push   %esi
  800151:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800152:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800155:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80015b:	e8 b7 0a 00 00       	call   800c17 <sys_getenvid>
  800160:	83 ec 0c             	sub    $0xc,%esp
  800163:	ff 75 0c             	pushl  0xc(%ebp)
  800166:	ff 75 08             	pushl  0x8(%ebp)
  800169:	56                   	push   %esi
  80016a:	50                   	push   %eax
  80016b:	68 c4 22 80 00       	push   $0x8022c4
  800170:	e8 b1 00 00 00       	call   800226 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800175:	83 c4 18             	add    $0x18,%esp
  800178:	53                   	push   %ebx
  800179:	ff 75 10             	pushl  0x10(%ebp)
  80017c:	e8 54 00 00 00       	call   8001d5 <vcprintf>
	cprintf("\n");
  800181:	c7 04 24 b7 22 80 00 	movl   $0x8022b7,(%esp)
  800188:	e8 99 00 00 00       	call   800226 <cprintf>
  80018d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800190:	cc                   	int3   
  800191:	eb fd                	jmp    800190 <_panic+0x43>

00800193 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800193:	55                   	push   %ebp
  800194:	89 e5                	mov    %esp,%ebp
  800196:	53                   	push   %ebx
  800197:	83 ec 04             	sub    $0x4,%esp
  80019a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80019d:	8b 13                	mov    (%ebx),%edx
  80019f:	8d 42 01             	lea    0x1(%edx),%eax
  8001a2:	89 03                	mov    %eax,(%ebx)
  8001a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001a7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001ab:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001b0:	75 1a                	jne    8001cc <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001b2:	83 ec 08             	sub    $0x8,%esp
  8001b5:	68 ff 00 00 00       	push   $0xff
  8001ba:	8d 43 08             	lea    0x8(%ebx),%eax
  8001bd:	50                   	push   %eax
  8001be:	e8 d6 09 00 00       	call   800b99 <sys_cputs>
		b->idx = 0;
  8001c3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001c9:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001cc:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001d3:	c9                   	leave  
  8001d4:	c3                   	ret    

008001d5 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001d5:	55                   	push   %ebp
  8001d6:	89 e5                	mov    %esp,%ebp
  8001d8:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001de:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001e5:	00 00 00 
	b.cnt = 0;
  8001e8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ef:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001f2:	ff 75 0c             	pushl  0xc(%ebp)
  8001f5:	ff 75 08             	pushl  0x8(%ebp)
  8001f8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001fe:	50                   	push   %eax
  8001ff:	68 93 01 80 00       	push   $0x800193
  800204:	e8 1a 01 00 00       	call   800323 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800209:	83 c4 08             	add    $0x8,%esp
  80020c:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800212:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800218:	50                   	push   %eax
  800219:	e8 7b 09 00 00       	call   800b99 <sys_cputs>

	return b.cnt;
}
  80021e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800224:	c9                   	leave  
  800225:	c3                   	ret    

00800226 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800226:	55                   	push   %ebp
  800227:	89 e5                	mov    %esp,%ebp
  800229:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80022c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80022f:	50                   	push   %eax
  800230:	ff 75 08             	pushl  0x8(%ebp)
  800233:	e8 9d ff ff ff       	call   8001d5 <vcprintf>
	va_end(ap);

	return cnt;
}
  800238:	c9                   	leave  
  800239:	c3                   	ret    

0080023a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80023a:	55                   	push   %ebp
  80023b:	89 e5                	mov    %esp,%ebp
  80023d:	57                   	push   %edi
  80023e:	56                   	push   %esi
  80023f:	53                   	push   %ebx
  800240:	83 ec 1c             	sub    $0x1c,%esp
  800243:	89 c7                	mov    %eax,%edi
  800245:	89 d6                	mov    %edx,%esi
  800247:	8b 45 08             	mov    0x8(%ebp),%eax
  80024a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80024d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800250:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800253:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800256:	bb 00 00 00 00       	mov    $0x0,%ebx
  80025b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80025e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800261:	39 d3                	cmp    %edx,%ebx
  800263:	72 05                	jb     80026a <printnum+0x30>
  800265:	39 45 10             	cmp    %eax,0x10(%ebp)
  800268:	77 45                	ja     8002af <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80026a:	83 ec 0c             	sub    $0xc,%esp
  80026d:	ff 75 18             	pushl  0x18(%ebp)
  800270:	8b 45 14             	mov    0x14(%ebp),%eax
  800273:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800276:	53                   	push   %ebx
  800277:	ff 75 10             	pushl  0x10(%ebp)
  80027a:	83 ec 08             	sub    $0x8,%esp
  80027d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800280:	ff 75 e0             	pushl  -0x20(%ebp)
  800283:	ff 75 dc             	pushl  -0x24(%ebp)
  800286:	ff 75 d8             	pushl  -0x28(%ebp)
  800289:	e8 32 1d 00 00       	call   801fc0 <__udivdi3>
  80028e:	83 c4 18             	add    $0x18,%esp
  800291:	52                   	push   %edx
  800292:	50                   	push   %eax
  800293:	89 f2                	mov    %esi,%edx
  800295:	89 f8                	mov    %edi,%eax
  800297:	e8 9e ff ff ff       	call   80023a <printnum>
  80029c:	83 c4 20             	add    $0x20,%esp
  80029f:	eb 18                	jmp    8002b9 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002a1:	83 ec 08             	sub    $0x8,%esp
  8002a4:	56                   	push   %esi
  8002a5:	ff 75 18             	pushl  0x18(%ebp)
  8002a8:	ff d7                	call   *%edi
  8002aa:	83 c4 10             	add    $0x10,%esp
  8002ad:	eb 03                	jmp    8002b2 <printnum+0x78>
  8002af:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002b2:	83 eb 01             	sub    $0x1,%ebx
  8002b5:	85 db                	test   %ebx,%ebx
  8002b7:	7f e8                	jg     8002a1 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002b9:	83 ec 08             	sub    $0x8,%esp
  8002bc:	56                   	push   %esi
  8002bd:	83 ec 04             	sub    $0x4,%esp
  8002c0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002c3:	ff 75 e0             	pushl  -0x20(%ebp)
  8002c6:	ff 75 dc             	pushl  -0x24(%ebp)
  8002c9:	ff 75 d8             	pushl  -0x28(%ebp)
  8002cc:	e8 1f 1e 00 00       	call   8020f0 <__umoddi3>
  8002d1:	83 c4 14             	add    $0x14,%esp
  8002d4:	0f be 80 e7 22 80 00 	movsbl 0x8022e7(%eax),%eax
  8002db:	50                   	push   %eax
  8002dc:	ff d7                	call   *%edi
}
  8002de:	83 c4 10             	add    $0x10,%esp
  8002e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e4:	5b                   	pop    %ebx
  8002e5:	5e                   	pop    %esi
  8002e6:	5f                   	pop    %edi
  8002e7:	5d                   	pop    %ebp
  8002e8:	c3                   	ret    

008002e9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002e9:	55                   	push   %ebp
  8002ea:	89 e5                	mov    %esp,%ebp
  8002ec:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002ef:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002f3:	8b 10                	mov    (%eax),%edx
  8002f5:	3b 50 04             	cmp    0x4(%eax),%edx
  8002f8:	73 0a                	jae    800304 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002fa:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002fd:	89 08                	mov    %ecx,(%eax)
  8002ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800302:	88 02                	mov    %al,(%edx)
}
  800304:	5d                   	pop    %ebp
  800305:	c3                   	ret    

00800306 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800306:	55                   	push   %ebp
  800307:	89 e5                	mov    %esp,%ebp
  800309:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80030c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80030f:	50                   	push   %eax
  800310:	ff 75 10             	pushl  0x10(%ebp)
  800313:	ff 75 0c             	pushl  0xc(%ebp)
  800316:	ff 75 08             	pushl  0x8(%ebp)
  800319:	e8 05 00 00 00       	call   800323 <vprintfmt>
	va_end(ap);
}
  80031e:	83 c4 10             	add    $0x10,%esp
  800321:	c9                   	leave  
  800322:	c3                   	ret    

00800323 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800323:	55                   	push   %ebp
  800324:	89 e5                	mov    %esp,%ebp
  800326:	57                   	push   %edi
  800327:	56                   	push   %esi
  800328:	53                   	push   %ebx
  800329:	83 ec 2c             	sub    $0x2c,%esp
  80032c:	8b 75 08             	mov    0x8(%ebp),%esi
  80032f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800332:	8b 7d 10             	mov    0x10(%ebp),%edi
  800335:	eb 12                	jmp    800349 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800337:	85 c0                	test   %eax,%eax
  800339:	0f 84 6a 04 00 00    	je     8007a9 <vprintfmt+0x486>
				return;
			putch(ch, putdat);
  80033f:	83 ec 08             	sub    $0x8,%esp
  800342:	53                   	push   %ebx
  800343:	50                   	push   %eax
  800344:	ff d6                	call   *%esi
  800346:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800349:	83 c7 01             	add    $0x1,%edi
  80034c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800350:	83 f8 25             	cmp    $0x25,%eax
  800353:	75 e2                	jne    800337 <vprintfmt+0x14>
  800355:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800359:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800360:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800367:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80036e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800373:	eb 07                	jmp    80037c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800375:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800378:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037c:	8d 47 01             	lea    0x1(%edi),%eax
  80037f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800382:	0f b6 07             	movzbl (%edi),%eax
  800385:	0f b6 d0             	movzbl %al,%edx
  800388:	83 e8 23             	sub    $0x23,%eax
  80038b:	3c 55                	cmp    $0x55,%al
  80038d:	0f 87 fb 03 00 00    	ja     80078e <vprintfmt+0x46b>
  800393:	0f b6 c0             	movzbl %al,%eax
  800396:	ff 24 85 20 24 80 00 	jmp    *0x802420(,%eax,4)
  80039d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003a0:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003a4:	eb d6                	jmp    80037c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8003ae:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003b1:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003b4:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003b8:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003bb:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003be:	83 f9 09             	cmp    $0x9,%ecx
  8003c1:	77 3f                	ja     800402 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003c3:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003c6:	eb e9                	jmp    8003b1 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cb:	8b 00                	mov    (%eax),%eax
  8003cd:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d3:	8d 40 04             	lea    0x4(%eax),%eax
  8003d6:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003dc:	eb 2a                	jmp    800408 <vprintfmt+0xe5>
  8003de:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003e1:	85 c0                	test   %eax,%eax
  8003e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8003e8:	0f 49 d0             	cmovns %eax,%edx
  8003eb:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003f1:	eb 89                	jmp    80037c <vprintfmt+0x59>
  8003f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003f6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003fd:	e9 7a ff ff ff       	jmp    80037c <vprintfmt+0x59>
  800402:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800405:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800408:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80040c:	0f 89 6a ff ff ff    	jns    80037c <vprintfmt+0x59>
				width = precision, precision = -1;
  800412:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800415:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800418:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80041f:	e9 58 ff ff ff       	jmp    80037c <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800424:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800427:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80042a:	e9 4d ff ff ff       	jmp    80037c <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80042f:	8b 45 14             	mov    0x14(%ebp),%eax
  800432:	8d 78 04             	lea    0x4(%eax),%edi
  800435:	83 ec 08             	sub    $0x8,%esp
  800438:	53                   	push   %ebx
  800439:	ff 30                	pushl  (%eax)
  80043b:	ff d6                	call   *%esi
			break;
  80043d:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800440:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800443:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800446:	e9 fe fe ff ff       	jmp    800349 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80044b:	8b 45 14             	mov    0x14(%ebp),%eax
  80044e:	8d 78 04             	lea    0x4(%eax),%edi
  800451:	8b 00                	mov    (%eax),%eax
  800453:	99                   	cltd   
  800454:	31 d0                	xor    %edx,%eax
  800456:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800458:	83 f8 0f             	cmp    $0xf,%eax
  80045b:	7f 0b                	jg     800468 <vprintfmt+0x145>
  80045d:	8b 14 85 80 25 80 00 	mov    0x802580(,%eax,4),%edx
  800464:	85 d2                	test   %edx,%edx
  800466:	75 1b                	jne    800483 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800468:	50                   	push   %eax
  800469:	68 ff 22 80 00       	push   $0x8022ff
  80046e:	53                   	push   %ebx
  80046f:	56                   	push   %esi
  800470:	e8 91 fe ff ff       	call   800306 <printfmt>
  800475:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800478:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80047e:	e9 c6 fe ff ff       	jmp    800349 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800483:	52                   	push   %edx
  800484:	68 be 27 80 00       	push   $0x8027be
  800489:	53                   	push   %ebx
  80048a:	56                   	push   %esi
  80048b:	e8 76 fe ff ff       	call   800306 <printfmt>
  800490:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800493:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800496:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800499:	e9 ab fe ff ff       	jmp    800349 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80049e:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a1:	83 c0 04             	add    $0x4,%eax
  8004a4:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8004a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004aa:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004ac:	85 ff                	test   %edi,%edi
  8004ae:	b8 f8 22 80 00       	mov    $0x8022f8,%eax
  8004b3:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004b6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004ba:	0f 8e 94 00 00 00    	jle    800554 <vprintfmt+0x231>
  8004c0:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004c4:	0f 84 98 00 00 00    	je     800562 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ca:	83 ec 08             	sub    $0x8,%esp
  8004cd:	ff 75 d0             	pushl  -0x30(%ebp)
  8004d0:	57                   	push   %edi
  8004d1:	e8 5b 03 00 00       	call   800831 <strnlen>
  8004d6:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004d9:	29 c1                	sub    %eax,%ecx
  8004db:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8004de:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004e1:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004e5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004e8:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004eb:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ed:	eb 0f                	jmp    8004fe <vprintfmt+0x1db>
					putch(padc, putdat);
  8004ef:	83 ec 08             	sub    $0x8,%esp
  8004f2:	53                   	push   %ebx
  8004f3:	ff 75 e0             	pushl  -0x20(%ebp)
  8004f6:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f8:	83 ef 01             	sub    $0x1,%edi
  8004fb:	83 c4 10             	add    $0x10,%esp
  8004fe:	85 ff                	test   %edi,%edi
  800500:	7f ed                	jg     8004ef <vprintfmt+0x1cc>
  800502:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800505:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800508:	85 c9                	test   %ecx,%ecx
  80050a:	b8 00 00 00 00       	mov    $0x0,%eax
  80050f:	0f 49 c1             	cmovns %ecx,%eax
  800512:	29 c1                	sub    %eax,%ecx
  800514:	89 75 08             	mov    %esi,0x8(%ebp)
  800517:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80051a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80051d:	89 cb                	mov    %ecx,%ebx
  80051f:	eb 4d                	jmp    80056e <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800521:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800525:	74 1b                	je     800542 <vprintfmt+0x21f>
  800527:	0f be c0             	movsbl %al,%eax
  80052a:	83 e8 20             	sub    $0x20,%eax
  80052d:	83 f8 5e             	cmp    $0x5e,%eax
  800530:	76 10                	jbe    800542 <vprintfmt+0x21f>
					putch('?', putdat);
  800532:	83 ec 08             	sub    $0x8,%esp
  800535:	ff 75 0c             	pushl  0xc(%ebp)
  800538:	6a 3f                	push   $0x3f
  80053a:	ff 55 08             	call   *0x8(%ebp)
  80053d:	83 c4 10             	add    $0x10,%esp
  800540:	eb 0d                	jmp    80054f <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  800542:	83 ec 08             	sub    $0x8,%esp
  800545:	ff 75 0c             	pushl  0xc(%ebp)
  800548:	52                   	push   %edx
  800549:	ff 55 08             	call   *0x8(%ebp)
  80054c:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80054f:	83 eb 01             	sub    $0x1,%ebx
  800552:	eb 1a                	jmp    80056e <vprintfmt+0x24b>
  800554:	89 75 08             	mov    %esi,0x8(%ebp)
  800557:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80055a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80055d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800560:	eb 0c                	jmp    80056e <vprintfmt+0x24b>
  800562:	89 75 08             	mov    %esi,0x8(%ebp)
  800565:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800568:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80056b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80056e:	83 c7 01             	add    $0x1,%edi
  800571:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800575:	0f be d0             	movsbl %al,%edx
  800578:	85 d2                	test   %edx,%edx
  80057a:	74 23                	je     80059f <vprintfmt+0x27c>
  80057c:	85 f6                	test   %esi,%esi
  80057e:	78 a1                	js     800521 <vprintfmt+0x1fe>
  800580:	83 ee 01             	sub    $0x1,%esi
  800583:	79 9c                	jns    800521 <vprintfmt+0x1fe>
  800585:	89 df                	mov    %ebx,%edi
  800587:	8b 75 08             	mov    0x8(%ebp),%esi
  80058a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80058d:	eb 18                	jmp    8005a7 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80058f:	83 ec 08             	sub    $0x8,%esp
  800592:	53                   	push   %ebx
  800593:	6a 20                	push   $0x20
  800595:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800597:	83 ef 01             	sub    $0x1,%edi
  80059a:	83 c4 10             	add    $0x10,%esp
  80059d:	eb 08                	jmp    8005a7 <vprintfmt+0x284>
  80059f:	89 df                	mov    %ebx,%edi
  8005a1:	8b 75 08             	mov    0x8(%ebp),%esi
  8005a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005a7:	85 ff                	test   %edi,%edi
  8005a9:	7f e4                	jg     80058f <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005ab:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8005ae:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005b4:	e9 90 fd ff ff       	jmp    800349 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005b9:	83 f9 01             	cmp    $0x1,%ecx
  8005bc:	7e 19                	jle    8005d7 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8005be:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c1:	8b 50 04             	mov    0x4(%eax),%edx
  8005c4:	8b 00                	mov    (%eax),%eax
  8005c6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cf:	8d 40 08             	lea    0x8(%eax),%eax
  8005d2:	89 45 14             	mov    %eax,0x14(%ebp)
  8005d5:	eb 38                	jmp    80060f <vprintfmt+0x2ec>
	else if (lflag)
  8005d7:	85 c9                	test   %ecx,%ecx
  8005d9:	74 1b                	je     8005f6 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8005db:	8b 45 14             	mov    0x14(%ebp),%eax
  8005de:	8b 00                	mov    (%eax),%eax
  8005e0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e3:	89 c1                	mov    %eax,%ecx
  8005e5:	c1 f9 1f             	sar    $0x1f,%ecx
  8005e8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ee:	8d 40 04             	lea    0x4(%eax),%eax
  8005f1:	89 45 14             	mov    %eax,0x14(%ebp)
  8005f4:	eb 19                	jmp    80060f <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8005f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f9:	8b 00                	mov    (%eax),%eax
  8005fb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005fe:	89 c1                	mov    %eax,%ecx
  800600:	c1 f9 1f             	sar    $0x1f,%ecx
  800603:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800606:	8b 45 14             	mov    0x14(%ebp),%eax
  800609:	8d 40 04             	lea    0x4(%eax),%eax
  80060c:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80060f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800612:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800615:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80061a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80061e:	0f 89 36 01 00 00    	jns    80075a <vprintfmt+0x437>
				putch('-', putdat);
  800624:	83 ec 08             	sub    $0x8,%esp
  800627:	53                   	push   %ebx
  800628:	6a 2d                	push   $0x2d
  80062a:	ff d6                	call   *%esi
				num = -(long long) num;
  80062c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80062f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800632:	f7 da                	neg    %edx
  800634:	83 d1 00             	adc    $0x0,%ecx
  800637:	f7 d9                	neg    %ecx
  800639:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80063c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800641:	e9 14 01 00 00       	jmp    80075a <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800646:	83 f9 01             	cmp    $0x1,%ecx
  800649:	7e 18                	jle    800663 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  80064b:	8b 45 14             	mov    0x14(%ebp),%eax
  80064e:	8b 10                	mov    (%eax),%edx
  800650:	8b 48 04             	mov    0x4(%eax),%ecx
  800653:	8d 40 08             	lea    0x8(%eax),%eax
  800656:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800659:	b8 0a 00 00 00       	mov    $0xa,%eax
  80065e:	e9 f7 00 00 00       	jmp    80075a <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800663:	85 c9                	test   %ecx,%ecx
  800665:	74 1a                	je     800681 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  800667:	8b 45 14             	mov    0x14(%ebp),%eax
  80066a:	8b 10                	mov    (%eax),%edx
  80066c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800671:	8d 40 04             	lea    0x4(%eax),%eax
  800674:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800677:	b8 0a 00 00 00       	mov    $0xa,%eax
  80067c:	e9 d9 00 00 00       	jmp    80075a <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800681:	8b 45 14             	mov    0x14(%ebp),%eax
  800684:	8b 10                	mov    (%eax),%edx
  800686:	b9 00 00 00 00       	mov    $0x0,%ecx
  80068b:	8d 40 04             	lea    0x4(%eax),%eax
  80068e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800691:	b8 0a 00 00 00       	mov    $0xa,%eax
  800696:	e9 bf 00 00 00       	jmp    80075a <vprintfmt+0x437>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80069b:	83 f9 01             	cmp    $0x1,%ecx
  80069e:	7e 13                	jle    8006b3 <vprintfmt+0x390>
		return va_arg(*ap, long long);
  8006a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a3:	8b 50 04             	mov    0x4(%eax),%edx
  8006a6:	8b 00                	mov    (%eax),%eax
  8006a8:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8006ab:	8d 49 08             	lea    0x8(%ecx),%ecx
  8006ae:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006b1:	eb 28                	jmp    8006db <vprintfmt+0x3b8>
	else if (lflag)
  8006b3:	85 c9                	test   %ecx,%ecx
  8006b5:	74 13                	je     8006ca <vprintfmt+0x3a7>
		return va_arg(*ap, long);
  8006b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ba:	8b 10                	mov    (%eax),%edx
  8006bc:	89 d0                	mov    %edx,%eax
  8006be:	99                   	cltd   
  8006bf:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8006c2:	8d 49 04             	lea    0x4(%ecx),%ecx
  8006c5:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006c8:	eb 11                	jmp    8006db <vprintfmt+0x3b8>
	else
		return va_arg(*ap, int);
  8006ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cd:	8b 10                	mov    (%eax),%edx
  8006cf:	89 d0                	mov    %edx,%eax
  8006d1:	99                   	cltd   
  8006d2:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8006d5:	8d 49 04             	lea    0x4(%ecx),%ecx
  8006d8:	89 4d 14             	mov    %ecx,0x14(%ebp)
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getint(&ap, lflag);
  8006db:	89 d1                	mov    %edx,%ecx
  8006dd:	89 c2                	mov    %eax,%edx
			base = 8;
  8006df:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8006e4:	eb 74                	jmp    80075a <vprintfmt+0x437>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8006e6:	83 ec 08             	sub    $0x8,%esp
  8006e9:	53                   	push   %ebx
  8006ea:	6a 30                	push   $0x30
  8006ec:	ff d6                	call   *%esi
			putch('x', putdat);
  8006ee:	83 c4 08             	add    $0x8,%esp
  8006f1:	53                   	push   %ebx
  8006f2:	6a 78                	push   $0x78
  8006f4:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f9:	8b 10                	mov    (%eax),%edx
  8006fb:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800700:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800703:	8d 40 04             	lea    0x4(%eax),%eax
  800706:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800709:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80070e:	eb 4a                	jmp    80075a <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800710:	83 f9 01             	cmp    $0x1,%ecx
  800713:	7e 15                	jle    80072a <vprintfmt+0x407>
		return va_arg(*ap, unsigned long long);
  800715:	8b 45 14             	mov    0x14(%ebp),%eax
  800718:	8b 10                	mov    (%eax),%edx
  80071a:	8b 48 04             	mov    0x4(%eax),%ecx
  80071d:	8d 40 08             	lea    0x8(%eax),%eax
  800720:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800723:	b8 10 00 00 00       	mov    $0x10,%eax
  800728:	eb 30                	jmp    80075a <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80072a:	85 c9                	test   %ecx,%ecx
  80072c:	74 17                	je     800745 <vprintfmt+0x422>
		return va_arg(*ap, unsigned long);
  80072e:	8b 45 14             	mov    0x14(%ebp),%eax
  800731:	8b 10                	mov    (%eax),%edx
  800733:	b9 00 00 00 00       	mov    $0x0,%ecx
  800738:	8d 40 04             	lea    0x4(%eax),%eax
  80073b:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80073e:	b8 10 00 00 00       	mov    $0x10,%eax
  800743:	eb 15                	jmp    80075a <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800745:	8b 45 14             	mov    0x14(%ebp),%eax
  800748:	8b 10                	mov    (%eax),%edx
  80074a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80074f:	8d 40 04             	lea    0x4(%eax),%eax
  800752:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800755:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80075a:	83 ec 0c             	sub    $0xc,%esp
  80075d:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800761:	57                   	push   %edi
  800762:	ff 75 e0             	pushl  -0x20(%ebp)
  800765:	50                   	push   %eax
  800766:	51                   	push   %ecx
  800767:	52                   	push   %edx
  800768:	89 da                	mov    %ebx,%edx
  80076a:	89 f0                	mov    %esi,%eax
  80076c:	e8 c9 fa ff ff       	call   80023a <printnum>
			break;
  800771:	83 c4 20             	add    $0x20,%esp
  800774:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800777:	e9 cd fb ff ff       	jmp    800349 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80077c:	83 ec 08             	sub    $0x8,%esp
  80077f:	53                   	push   %ebx
  800780:	52                   	push   %edx
  800781:	ff d6                	call   *%esi
			break;
  800783:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800786:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800789:	e9 bb fb ff ff       	jmp    800349 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80078e:	83 ec 08             	sub    $0x8,%esp
  800791:	53                   	push   %ebx
  800792:	6a 25                	push   $0x25
  800794:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800796:	83 c4 10             	add    $0x10,%esp
  800799:	eb 03                	jmp    80079e <vprintfmt+0x47b>
  80079b:	83 ef 01             	sub    $0x1,%edi
  80079e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007a2:	75 f7                	jne    80079b <vprintfmt+0x478>
  8007a4:	e9 a0 fb ff ff       	jmp    800349 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007ac:	5b                   	pop    %ebx
  8007ad:	5e                   	pop    %esi
  8007ae:	5f                   	pop    %edi
  8007af:	5d                   	pop    %ebp
  8007b0:	c3                   	ret    

008007b1 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007b1:	55                   	push   %ebp
  8007b2:	89 e5                	mov    %esp,%ebp
  8007b4:	83 ec 18             	sub    $0x18,%esp
  8007b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ba:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007bd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007c0:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007c4:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007c7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007ce:	85 c0                	test   %eax,%eax
  8007d0:	74 26                	je     8007f8 <vsnprintf+0x47>
  8007d2:	85 d2                	test   %edx,%edx
  8007d4:	7e 22                	jle    8007f8 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007d6:	ff 75 14             	pushl  0x14(%ebp)
  8007d9:	ff 75 10             	pushl  0x10(%ebp)
  8007dc:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007df:	50                   	push   %eax
  8007e0:	68 e9 02 80 00       	push   $0x8002e9
  8007e5:	e8 39 fb ff ff       	call   800323 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007ea:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007ed:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007f3:	83 c4 10             	add    $0x10,%esp
  8007f6:	eb 05                	jmp    8007fd <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007f8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007fd:	c9                   	leave  
  8007fe:	c3                   	ret    

008007ff <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007ff:	55                   	push   %ebp
  800800:	89 e5                	mov    %esp,%ebp
  800802:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800805:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800808:	50                   	push   %eax
  800809:	ff 75 10             	pushl  0x10(%ebp)
  80080c:	ff 75 0c             	pushl  0xc(%ebp)
  80080f:	ff 75 08             	pushl  0x8(%ebp)
  800812:	e8 9a ff ff ff       	call   8007b1 <vsnprintf>
	va_end(ap);

	return rc;
}
  800817:	c9                   	leave  
  800818:	c3                   	ret    

00800819 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800819:	55                   	push   %ebp
  80081a:	89 e5                	mov    %esp,%ebp
  80081c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80081f:	b8 00 00 00 00       	mov    $0x0,%eax
  800824:	eb 03                	jmp    800829 <strlen+0x10>
		n++;
  800826:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800829:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80082d:	75 f7                	jne    800826 <strlen+0xd>
		n++;
	return n;
}
  80082f:	5d                   	pop    %ebp
  800830:	c3                   	ret    

00800831 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800831:	55                   	push   %ebp
  800832:	89 e5                	mov    %esp,%ebp
  800834:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800837:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80083a:	ba 00 00 00 00       	mov    $0x0,%edx
  80083f:	eb 03                	jmp    800844 <strnlen+0x13>
		n++;
  800841:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800844:	39 c2                	cmp    %eax,%edx
  800846:	74 08                	je     800850 <strnlen+0x1f>
  800848:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80084c:	75 f3                	jne    800841 <strnlen+0x10>
  80084e:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800850:	5d                   	pop    %ebp
  800851:	c3                   	ret    

00800852 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800852:	55                   	push   %ebp
  800853:	89 e5                	mov    %esp,%ebp
  800855:	53                   	push   %ebx
  800856:	8b 45 08             	mov    0x8(%ebp),%eax
  800859:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80085c:	89 c2                	mov    %eax,%edx
  80085e:	83 c2 01             	add    $0x1,%edx
  800861:	83 c1 01             	add    $0x1,%ecx
  800864:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800868:	88 5a ff             	mov    %bl,-0x1(%edx)
  80086b:	84 db                	test   %bl,%bl
  80086d:	75 ef                	jne    80085e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80086f:	5b                   	pop    %ebx
  800870:	5d                   	pop    %ebp
  800871:	c3                   	ret    

00800872 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800872:	55                   	push   %ebp
  800873:	89 e5                	mov    %esp,%ebp
  800875:	53                   	push   %ebx
  800876:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800879:	53                   	push   %ebx
  80087a:	e8 9a ff ff ff       	call   800819 <strlen>
  80087f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800882:	ff 75 0c             	pushl  0xc(%ebp)
  800885:	01 d8                	add    %ebx,%eax
  800887:	50                   	push   %eax
  800888:	e8 c5 ff ff ff       	call   800852 <strcpy>
	return dst;
}
  80088d:	89 d8                	mov    %ebx,%eax
  80088f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800892:	c9                   	leave  
  800893:	c3                   	ret    

00800894 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800894:	55                   	push   %ebp
  800895:	89 e5                	mov    %esp,%ebp
  800897:	56                   	push   %esi
  800898:	53                   	push   %ebx
  800899:	8b 75 08             	mov    0x8(%ebp),%esi
  80089c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80089f:	89 f3                	mov    %esi,%ebx
  8008a1:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008a4:	89 f2                	mov    %esi,%edx
  8008a6:	eb 0f                	jmp    8008b7 <strncpy+0x23>
		*dst++ = *src;
  8008a8:	83 c2 01             	add    $0x1,%edx
  8008ab:	0f b6 01             	movzbl (%ecx),%eax
  8008ae:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008b1:	80 39 01             	cmpb   $0x1,(%ecx)
  8008b4:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008b7:	39 da                	cmp    %ebx,%edx
  8008b9:	75 ed                	jne    8008a8 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008bb:	89 f0                	mov    %esi,%eax
  8008bd:	5b                   	pop    %ebx
  8008be:	5e                   	pop    %esi
  8008bf:	5d                   	pop    %ebp
  8008c0:	c3                   	ret    

008008c1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008c1:	55                   	push   %ebp
  8008c2:	89 e5                	mov    %esp,%ebp
  8008c4:	56                   	push   %esi
  8008c5:	53                   	push   %ebx
  8008c6:	8b 75 08             	mov    0x8(%ebp),%esi
  8008c9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008cc:	8b 55 10             	mov    0x10(%ebp),%edx
  8008cf:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008d1:	85 d2                	test   %edx,%edx
  8008d3:	74 21                	je     8008f6 <strlcpy+0x35>
  8008d5:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008d9:	89 f2                	mov    %esi,%edx
  8008db:	eb 09                	jmp    8008e6 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008dd:	83 c2 01             	add    $0x1,%edx
  8008e0:	83 c1 01             	add    $0x1,%ecx
  8008e3:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008e6:	39 c2                	cmp    %eax,%edx
  8008e8:	74 09                	je     8008f3 <strlcpy+0x32>
  8008ea:	0f b6 19             	movzbl (%ecx),%ebx
  8008ed:	84 db                	test   %bl,%bl
  8008ef:	75 ec                	jne    8008dd <strlcpy+0x1c>
  8008f1:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008f3:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008f6:	29 f0                	sub    %esi,%eax
}
  8008f8:	5b                   	pop    %ebx
  8008f9:	5e                   	pop    %esi
  8008fa:	5d                   	pop    %ebp
  8008fb:	c3                   	ret    

008008fc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008fc:	55                   	push   %ebp
  8008fd:	89 e5                	mov    %esp,%ebp
  8008ff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800902:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800905:	eb 06                	jmp    80090d <strcmp+0x11>
		p++, q++;
  800907:	83 c1 01             	add    $0x1,%ecx
  80090a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80090d:	0f b6 01             	movzbl (%ecx),%eax
  800910:	84 c0                	test   %al,%al
  800912:	74 04                	je     800918 <strcmp+0x1c>
  800914:	3a 02                	cmp    (%edx),%al
  800916:	74 ef                	je     800907 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800918:	0f b6 c0             	movzbl %al,%eax
  80091b:	0f b6 12             	movzbl (%edx),%edx
  80091e:	29 d0                	sub    %edx,%eax
}
  800920:	5d                   	pop    %ebp
  800921:	c3                   	ret    

00800922 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800922:	55                   	push   %ebp
  800923:	89 e5                	mov    %esp,%ebp
  800925:	53                   	push   %ebx
  800926:	8b 45 08             	mov    0x8(%ebp),%eax
  800929:	8b 55 0c             	mov    0xc(%ebp),%edx
  80092c:	89 c3                	mov    %eax,%ebx
  80092e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800931:	eb 06                	jmp    800939 <strncmp+0x17>
		n--, p++, q++;
  800933:	83 c0 01             	add    $0x1,%eax
  800936:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800939:	39 d8                	cmp    %ebx,%eax
  80093b:	74 15                	je     800952 <strncmp+0x30>
  80093d:	0f b6 08             	movzbl (%eax),%ecx
  800940:	84 c9                	test   %cl,%cl
  800942:	74 04                	je     800948 <strncmp+0x26>
  800944:	3a 0a                	cmp    (%edx),%cl
  800946:	74 eb                	je     800933 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800948:	0f b6 00             	movzbl (%eax),%eax
  80094b:	0f b6 12             	movzbl (%edx),%edx
  80094e:	29 d0                	sub    %edx,%eax
  800950:	eb 05                	jmp    800957 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800952:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800957:	5b                   	pop    %ebx
  800958:	5d                   	pop    %ebp
  800959:	c3                   	ret    

0080095a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80095a:	55                   	push   %ebp
  80095b:	89 e5                	mov    %esp,%ebp
  80095d:	8b 45 08             	mov    0x8(%ebp),%eax
  800960:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800964:	eb 07                	jmp    80096d <strchr+0x13>
		if (*s == c)
  800966:	38 ca                	cmp    %cl,%dl
  800968:	74 0f                	je     800979 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80096a:	83 c0 01             	add    $0x1,%eax
  80096d:	0f b6 10             	movzbl (%eax),%edx
  800970:	84 d2                	test   %dl,%dl
  800972:	75 f2                	jne    800966 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800974:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800979:	5d                   	pop    %ebp
  80097a:	c3                   	ret    

0080097b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	8b 45 08             	mov    0x8(%ebp),%eax
  800981:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800985:	eb 03                	jmp    80098a <strfind+0xf>
  800987:	83 c0 01             	add    $0x1,%eax
  80098a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80098d:	38 ca                	cmp    %cl,%dl
  80098f:	74 04                	je     800995 <strfind+0x1a>
  800991:	84 d2                	test   %dl,%dl
  800993:	75 f2                	jne    800987 <strfind+0xc>
			break;
	return (char *) s;
}
  800995:	5d                   	pop    %ebp
  800996:	c3                   	ret    

00800997 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800997:	55                   	push   %ebp
  800998:	89 e5                	mov    %esp,%ebp
  80099a:	57                   	push   %edi
  80099b:	56                   	push   %esi
  80099c:	53                   	push   %ebx
  80099d:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009a0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009a3:	85 c9                	test   %ecx,%ecx
  8009a5:	74 36                	je     8009dd <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009a7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009ad:	75 28                	jne    8009d7 <memset+0x40>
  8009af:	f6 c1 03             	test   $0x3,%cl
  8009b2:	75 23                	jne    8009d7 <memset+0x40>
		c &= 0xFF;
  8009b4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009b8:	89 d3                	mov    %edx,%ebx
  8009ba:	c1 e3 08             	shl    $0x8,%ebx
  8009bd:	89 d6                	mov    %edx,%esi
  8009bf:	c1 e6 18             	shl    $0x18,%esi
  8009c2:	89 d0                	mov    %edx,%eax
  8009c4:	c1 e0 10             	shl    $0x10,%eax
  8009c7:	09 f0                	or     %esi,%eax
  8009c9:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8009cb:	89 d8                	mov    %ebx,%eax
  8009cd:	09 d0                	or     %edx,%eax
  8009cf:	c1 e9 02             	shr    $0x2,%ecx
  8009d2:	fc                   	cld    
  8009d3:	f3 ab                	rep stos %eax,%es:(%edi)
  8009d5:	eb 06                	jmp    8009dd <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009da:	fc                   	cld    
  8009db:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009dd:	89 f8                	mov    %edi,%eax
  8009df:	5b                   	pop    %ebx
  8009e0:	5e                   	pop    %esi
  8009e1:	5f                   	pop    %edi
  8009e2:	5d                   	pop    %ebp
  8009e3:	c3                   	ret    

008009e4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009e4:	55                   	push   %ebp
  8009e5:	89 e5                	mov    %esp,%ebp
  8009e7:	57                   	push   %edi
  8009e8:	56                   	push   %esi
  8009e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ec:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009ef:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009f2:	39 c6                	cmp    %eax,%esi
  8009f4:	73 35                	jae    800a2b <memmove+0x47>
  8009f6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009f9:	39 d0                	cmp    %edx,%eax
  8009fb:	73 2e                	jae    800a2b <memmove+0x47>
		s += n;
		d += n;
  8009fd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a00:	89 d6                	mov    %edx,%esi
  800a02:	09 fe                	or     %edi,%esi
  800a04:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a0a:	75 13                	jne    800a1f <memmove+0x3b>
  800a0c:	f6 c1 03             	test   $0x3,%cl
  800a0f:	75 0e                	jne    800a1f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a11:	83 ef 04             	sub    $0x4,%edi
  800a14:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a17:	c1 e9 02             	shr    $0x2,%ecx
  800a1a:	fd                   	std    
  800a1b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a1d:	eb 09                	jmp    800a28 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a1f:	83 ef 01             	sub    $0x1,%edi
  800a22:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a25:	fd                   	std    
  800a26:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a28:	fc                   	cld    
  800a29:	eb 1d                	jmp    800a48 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a2b:	89 f2                	mov    %esi,%edx
  800a2d:	09 c2                	or     %eax,%edx
  800a2f:	f6 c2 03             	test   $0x3,%dl
  800a32:	75 0f                	jne    800a43 <memmove+0x5f>
  800a34:	f6 c1 03             	test   $0x3,%cl
  800a37:	75 0a                	jne    800a43 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a39:	c1 e9 02             	shr    $0x2,%ecx
  800a3c:	89 c7                	mov    %eax,%edi
  800a3e:	fc                   	cld    
  800a3f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a41:	eb 05                	jmp    800a48 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a43:	89 c7                	mov    %eax,%edi
  800a45:	fc                   	cld    
  800a46:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a48:	5e                   	pop    %esi
  800a49:	5f                   	pop    %edi
  800a4a:	5d                   	pop    %ebp
  800a4b:	c3                   	ret    

00800a4c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a4c:	55                   	push   %ebp
  800a4d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a4f:	ff 75 10             	pushl  0x10(%ebp)
  800a52:	ff 75 0c             	pushl  0xc(%ebp)
  800a55:	ff 75 08             	pushl  0x8(%ebp)
  800a58:	e8 87 ff ff ff       	call   8009e4 <memmove>
}
  800a5d:	c9                   	leave  
  800a5e:	c3                   	ret    

00800a5f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a5f:	55                   	push   %ebp
  800a60:	89 e5                	mov    %esp,%ebp
  800a62:	56                   	push   %esi
  800a63:	53                   	push   %ebx
  800a64:	8b 45 08             	mov    0x8(%ebp),%eax
  800a67:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a6a:	89 c6                	mov    %eax,%esi
  800a6c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a6f:	eb 1a                	jmp    800a8b <memcmp+0x2c>
		if (*s1 != *s2)
  800a71:	0f b6 08             	movzbl (%eax),%ecx
  800a74:	0f b6 1a             	movzbl (%edx),%ebx
  800a77:	38 d9                	cmp    %bl,%cl
  800a79:	74 0a                	je     800a85 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a7b:	0f b6 c1             	movzbl %cl,%eax
  800a7e:	0f b6 db             	movzbl %bl,%ebx
  800a81:	29 d8                	sub    %ebx,%eax
  800a83:	eb 0f                	jmp    800a94 <memcmp+0x35>
		s1++, s2++;
  800a85:	83 c0 01             	add    $0x1,%eax
  800a88:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a8b:	39 f0                	cmp    %esi,%eax
  800a8d:	75 e2                	jne    800a71 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a8f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a94:	5b                   	pop    %ebx
  800a95:	5e                   	pop    %esi
  800a96:	5d                   	pop    %ebp
  800a97:	c3                   	ret    

00800a98 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a98:	55                   	push   %ebp
  800a99:	89 e5                	mov    %esp,%ebp
  800a9b:	53                   	push   %ebx
  800a9c:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a9f:	89 c1                	mov    %eax,%ecx
  800aa1:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800aa4:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800aa8:	eb 0a                	jmp    800ab4 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800aaa:	0f b6 10             	movzbl (%eax),%edx
  800aad:	39 da                	cmp    %ebx,%edx
  800aaf:	74 07                	je     800ab8 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ab1:	83 c0 01             	add    $0x1,%eax
  800ab4:	39 c8                	cmp    %ecx,%eax
  800ab6:	72 f2                	jb     800aaa <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ab8:	5b                   	pop    %ebx
  800ab9:	5d                   	pop    %ebp
  800aba:	c3                   	ret    

00800abb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800abb:	55                   	push   %ebp
  800abc:	89 e5                	mov    %esp,%ebp
  800abe:	57                   	push   %edi
  800abf:	56                   	push   %esi
  800ac0:	53                   	push   %ebx
  800ac1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ac4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ac7:	eb 03                	jmp    800acc <strtol+0x11>
		s++;
  800ac9:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800acc:	0f b6 01             	movzbl (%ecx),%eax
  800acf:	3c 20                	cmp    $0x20,%al
  800ad1:	74 f6                	je     800ac9 <strtol+0xe>
  800ad3:	3c 09                	cmp    $0x9,%al
  800ad5:	74 f2                	je     800ac9 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ad7:	3c 2b                	cmp    $0x2b,%al
  800ad9:	75 0a                	jne    800ae5 <strtol+0x2a>
		s++;
  800adb:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ade:	bf 00 00 00 00       	mov    $0x0,%edi
  800ae3:	eb 11                	jmp    800af6 <strtol+0x3b>
  800ae5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800aea:	3c 2d                	cmp    $0x2d,%al
  800aec:	75 08                	jne    800af6 <strtol+0x3b>
		s++, neg = 1;
  800aee:	83 c1 01             	add    $0x1,%ecx
  800af1:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800af6:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800afc:	75 15                	jne    800b13 <strtol+0x58>
  800afe:	80 39 30             	cmpb   $0x30,(%ecx)
  800b01:	75 10                	jne    800b13 <strtol+0x58>
  800b03:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b07:	75 7c                	jne    800b85 <strtol+0xca>
		s += 2, base = 16;
  800b09:	83 c1 02             	add    $0x2,%ecx
  800b0c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b11:	eb 16                	jmp    800b29 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b13:	85 db                	test   %ebx,%ebx
  800b15:	75 12                	jne    800b29 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b17:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b1c:	80 39 30             	cmpb   $0x30,(%ecx)
  800b1f:	75 08                	jne    800b29 <strtol+0x6e>
		s++, base = 8;
  800b21:	83 c1 01             	add    $0x1,%ecx
  800b24:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b29:	b8 00 00 00 00       	mov    $0x0,%eax
  800b2e:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b31:	0f b6 11             	movzbl (%ecx),%edx
  800b34:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b37:	89 f3                	mov    %esi,%ebx
  800b39:	80 fb 09             	cmp    $0x9,%bl
  800b3c:	77 08                	ja     800b46 <strtol+0x8b>
			dig = *s - '0';
  800b3e:	0f be d2             	movsbl %dl,%edx
  800b41:	83 ea 30             	sub    $0x30,%edx
  800b44:	eb 22                	jmp    800b68 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b46:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b49:	89 f3                	mov    %esi,%ebx
  800b4b:	80 fb 19             	cmp    $0x19,%bl
  800b4e:	77 08                	ja     800b58 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b50:	0f be d2             	movsbl %dl,%edx
  800b53:	83 ea 57             	sub    $0x57,%edx
  800b56:	eb 10                	jmp    800b68 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b58:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b5b:	89 f3                	mov    %esi,%ebx
  800b5d:	80 fb 19             	cmp    $0x19,%bl
  800b60:	77 16                	ja     800b78 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b62:	0f be d2             	movsbl %dl,%edx
  800b65:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b68:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b6b:	7d 0b                	jge    800b78 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b6d:	83 c1 01             	add    $0x1,%ecx
  800b70:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b74:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b76:	eb b9                	jmp    800b31 <strtol+0x76>

	if (endptr)
  800b78:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b7c:	74 0d                	je     800b8b <strtol+0xd0>
		*endptr = (char *) s;
  800b7e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b81:	89 0e                	mov    %ecx,(%esi)
  800b83:	eb 06                	jmp    800b8b <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b85:	85 db                	test   %ebx,%ebx
  800b87:	74 98                	je     800b21 <strtol+0x66>
  800b89:	eb 9e                	jmp    800b29 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b8b:	89 c2                	mov    %eax,%edx
  800b8d:	f7 da                	neg    %edx
  800b8f:	85 ff                	test   %edi,%edi
  800b91:	0f 45 c2             	cmovne %edx,%eax
}
  800b94:	5b                   	pop    %ebx
  800b95:	5e                   	pop    %esi
  800b96:	5f                   	pop    %edi
  800b97:	5d                   	pop    %ebp
  800b98:	c3                   	ret    

00800b99 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b99:	55                   	push   %ebp
  800b9a:	89 e5                	mov    %esp,%ebp
  800b9c:	57                   	push   %edi
  800b9d:	56                   	push   %esi
  800b9e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b9f:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba7:	8b 55 08             	mov    0x8(%ebp),%edx
  800baa:	89 c3                	mov    %eax,%ebx
  800bac:	89 c7                	mov    %eax,%edi
  800bae:	89 c6                	mov    %eax,%esi
  800bb0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bb2:	5b                   	pop    %ebx
  800bb3:	5e                   	pop    %esi
  800bb4:	5f                   	pop    %edi
  800bb5:	5d                   	pop    %ebp
  800bb6:	c3                   	ret    

00800bb7 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bb7:	55                   	push   %ebp
  800bb8:	89 e5                	mov    %esp,%ebp
  800bba:	57                   	push   %edi
  800bbb:	56                   	push   %esi
  800bbc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bbd:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc2:	b8 01 00 00 00       	mov    $0x1,%eax
  800bc7:	89 d1                	mov    %edx,%ecx
  800bc9:	89 d3                	mov    %edx,%ebx
  800bcb:	89 d7                	mov    %edx,%edi
  800bcd:	89 d6                	mov    %edx,%esi
  800bcf:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bd1:	5b                   	pop    %ebx
  800bd2:	5e                   	pop    %esi
  800bd3:	5f                   	pop    %edi
  800bd4:	5d                   	pop    %ebp
  800bd5:	c3                   	ret    

00800bd6 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bd6:	55                   	push   %ebp
  800bd7:	89 e5                	mov    %esp,%ebp
  800bd9:	57                   	push   %edi
  800bda:	56                   	push   %esi
  800bdb:	53                   	push   %ebx
  800bdc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bdf:	b9 00 00 00 00       	mov    $0x0,%ecx
  800be4:	b8 03 00 00 00       	mov    $0x3,%eax
  800be9:	8b 55 08             	mov    0x8(%ebp),%edx
  800bec:	89 cb                	mov    %ecx,%ebx
  800bee:	89 cf                	mov    %ecx,%edi
  800bf0:	89 ce                	mov    %ecx,%esi
  800bf2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bf4:	85 c0                	test   %eax,%eax
  800bf6:	7e 17                	jle    800c0f <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf8:	83 ec 0c             	sub    $0xc,%esp
  800bfb:	50                   	push   %eax
  800bfc:	6a 03                	push   $0x3
  800bfe:	68 df 25 80 00       	push   $0x8025df
  800c03:	6a 23                	push   $0x23
  800c05:	68 fc 25 80 00       	push   $0x8025fc
  800c0a:	e8 3e f5 ff ff       	call   80014d <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c0f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c12:	5b                   	pop    %ebx
  800c13:	5e                   	pop    %esi
  800c14:	5f                   	pop    %edi
  800c15:	5d                   	pop    %ebp
  800c16:	c3                   	ret    

00800c17 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c17:	55                   	push   %ebp
  800c18:	89 e5                	mov    %esp,%ebp
  800c1a:	57                   	push   %edi
  800c1b:	56                   	push   %esi
  800c1c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c22:	b8 02 00 00 00       	mov    $0x2,%eax
  800c27:	89 d1                	mov    %edx,%ecx
  800c29:	89 d3                	mov    %edx,%ebx
  800c2b:	89 d7                	mov    %edx,%edi
  800c2d:	89 d6                	mov    %edx,%esi
  800c2f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c31:	5b                   	pop    %ebx
  800c32:	5e                   	pop    %esi
  800c33:	5f                   	pop    %edi
  800c34:	5d                   	pop    %ebp
  800c35:	c3                   	ret    

00800c36 <sys_yield>:

void
sys_yield(void)
{
  800c36:	55                   	push   %ebp
  800c37:	89 e5                	mov    %esp,%ebp
  800c39:	57                   	push   %edi
  800c3a:	56                   	push   %esi
  800c3b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c41:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c46:	89 d1                	mov    %edx,%ecx
  800c48:	89 d3                	mov    %edx,%ebx
  800c4a:	89 d7                	mov    %edx,%edi
  800c4c:	89 d6                	mov    %edx,%esi
  800c4e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c50:	5b                   	pop    %ebx
  800c51:	5e                   	pop    %esi
  800c52:	5f                   	pop    %edi
  800c53:	5d                   	pop    %ebp
  800c54:	c3                   	ret    

00800c55 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c55:	55                   	push   %ebp
  800c56:	89 e5                	mov    %esp,%ebp
  800c58:	57                   	push   %edi
  800c59:	56                   	push   %esi
  800c5a:	53                   	push   %ebx
  800c5b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5e:	be 00 00 00 00       	mov    $0x0,%esi
  800c63:	b8 04 00 00 00       	mov    $0x4,%eax
  800c68:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c71:	89 f7                	mov    %esi,%edi
  800c73:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c75:	85 c0                	test   %eax,%eax
  800c77:	7e 17                	jle    800c90 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c79:	83 ec 0c             	sub    $0xc,%esp
  800c7c:	50                   	push   %eax
  800c7d:	6a 04                	push   $0x4
  800c7f:	68 df 25 80 00       	push   $0x8025df
  800c84:	6a 23                	push   $0x23
  800c86:	68 fc 25 80 00       	push   $0x8025fc
  800c8b:	e8 bd f4 ff ff       	call   80014d <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c90:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c93:	5b                   	pop    %ebx
  800c94:	5e                   	pop    %esi
  800c95:	5f                   	pop    %edi
  800c96:	5d                   	pop    %ebp
  800c97:	c3                   	ret    

00800c98 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c98:	55                   	push   %ebp
  800c99:	89 e5                	mov    %esp,%ebp
  800c9b:	57                   	push   %edi
  800c9c:	56                   	push   %esi
  800c9d:	53                   	push   %ebx
  800c9e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca1:	b8 05 00 00 00       	mov    $0x5,%eax
  800ca6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800caf:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cb2:	8b 75 18             	mov    0x18(%ebp),%esi
  800cb5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cb7:	85 c0                	test   %eax,%eax
  800cb9:	7e 17                	jle    800cd2 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbb:	83 ec 0c             	sub    $0xc,%esp
  800cbe:	50                   	push   %eax
  800cbf:	6a 05                	push   $0x5
  800cc1:	68 df 25 80 00       	push   $0x8025df
  800cc6:	6a 23                	push   $0x23
  800cc8:	68 fc 25 80 00       	push   $0x8025fc
  800ccd:	e8 7b f4 ff ff       	call   80014d <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cd2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd5:	5b                   	pop    %ebx
  800cd6:	5e                   	pop    %esi
  800cd7:	5f                   	pop    %edi
  800cd8:	5d                   	pop    %ebp
  800cd9:	c3                   	ret    

00800cda <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cda:	55                   	push   %ebp
  800cdb:	89 e5                	mov    %esp,%ebp
  800cdd:	57                   	push   %edi
  800cde:	56                   	push   %esi
  800cdf:	53                   	push   %ebx
  800ce0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce8:	b8 06 00 00 00       	mov    $0x6,%eax
  800ced:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf3:	89 df                	mov    %ebx,%edi
  800cf5:	89 de                	mov    %ebx,%esi
  800cf7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cf9:	85 c0                	test   %eax,%eax
  800cfb:	7e 17                	jle    800d14 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfd:	83 ec 0c             	sub    $0xc,%esp
  800d00:	50                   	push   %eax
  800d01:	6a 06                	push   $0x6
  800d03:	68 df 25 80 00       	push   $0x8025df
  800d08:	6a 23                	push   $0x23
  800d0a:	68 fc 25 80 00       	push   $0x8025fc
  800d0f:	e8 39 f4 ff ff       	call   80014d <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d14:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d17:	5b                   	pop    %ebx
  800d18:	5e                   	pop    %esi
  800d19:	5f                   	pop    %edi
  800d1a:	5d                   	pop    %ebp
  800d1b:	c3                   	ret    

00800d1c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d1c:	55                   	push   %ebp
  800d1d:	89 e5                	mov    %esp,%ebp
  800d1f:	57                   	push   %edi
  800d20:	56                   	push   %esi
  800d21:	53                   	push   %ebx
  800d22:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d25:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d2a:	b8 08 00 00 00       	mov    $0x8,%eax
  800d2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d32:	8b 55 08             	mov    0x8(%ebp),%edx
  800d35:	89 df                	mov    %ebx,%edi
  800d37:	89 de                	mov    %ebx,%esi
  800d39:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d3b:	85 c0                	test   %eax,%eax
  800d3d:	7e 17                	jle    800d56 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3f:	83 ec 0c             	sub    $0xc,%esp
  800d42:	50                   	push   %eax
  800d43:	6a 08                	push   $0x8
  800d45:	68 df 25 80 00       	push   $0x8025df
  800d4a:	6a 23                	push   $0x23
  800d4c:	68 fc 25 80 00       	push   $0x8025fc
  800d51:	e8 f7 f3 ff ff       	call   80014d <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d59:	5b                   	pop    %ebx
  800d5a:	5e                   	pop    %esi
  800d5b:	5f                   	pop    %edi
  800d5c:	5d                   	pop    %ebp
  800d5d:	c3                   	ret    

00800d5e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d5e:	55                   	push   %ebp
  800d5f:	89 e5                	mov    %esp,%ebp
  800d61:	57                   	push   %edi
  800d62:	56                   	push   %esi
  800d63:	53                   	push   %ebx
  800d64:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d67:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d6c:	b8 09 00 00 00       	mov    $0x9,%eax
  800d71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d74:	8b 55 08             	mov    0x8(%ebp),%edx
  800d77:	89 df                	mov    %ebx,%edi
  800d79:	89 de                	mov    %ebx,%esi
  800d7b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d7d:	85 c0                	test   %eax,%eax
  800d7f:	7e 17                	jle    800d98 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d81:	83 ec 0c             	sub    $0xc,%esp
  800d84:	50                   	push   %eax
  800d85:	6a 09                	push   $0x9
  800d87:	68 df 25 80 00       	push   $0x8025df
  800d8c:	6a 23                	push   $0x23
  800d8e:	68 fc 25 80 00       	push   $0x8025fc
  800d93:	e8 b5 f3 ff ff       	call   80014d <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d98:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d9b:	5b                   	pop    %ebx
  800d9c:	5e                   	pop    %esi
  800d9d:	5f                   	pop    %edi
  800d9e:	5d                   	pop    %ebp
  800d9f:	c3                   	ret    

00800da0 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800da0:	55                   	push   %ebp
  800da1:	89 e5                	mov    %esp,%ebp
  800da3:	57                   	push   %edi
  800da4:	56                   	push   %esi
  800da5:	53                   	push   %ebx
  800da6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dae:	b8 0a 00 00 00       	mov    $0xa,%eax
  800db3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db6:	8b 55 08             	mov    0x8(%ebp),%edx
  800db9:	89 df                	mov    %ebx,%edi
  800dbb:	89 de                	mov    %ebx,%esi
  800dbd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dbf:	85 c0                	test   %eax,%eax
  800dc1:	7e 17                	jle    800dda <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc3:	83 ec 0c             	sub    $0xc,%esp
  800dc6:	50                   	push   %eax
  800dc7:	6a 0a                	push   $0xa
  800dc9:	68 df 25 80 00       	push   $0x8025df
  800dce:	6a 23                	push   $0x23
  800dd0:	68 fc 25 80 00       	push   $0x8025fc
  800dd5:	e8 73 f3 ff ff       	call   80014d <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dda:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ddd:	5b                   	pop    %ebx
  800dde:	5e                   	pop    %esi
  800ddf:	5f                   	pop    %edi
  800de0:	5d                   	pop    %ebp
  800de1:	c3                   	ret    

00800de2 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800de2:	55                   	push   %ebp
  800de3:	89 e5                	mov    %esp,%ebp
  800de5:	57                   	push   %edi
  800de6:	56                   	push   %esi
  800de7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de8:	be 00 00 00 00       	mov    $0x0,%esi
  800ded:	b8 0c 00 00 00       	mov    $0xc,%eax
  800df2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df5:	8b 55 08             	mov    0x8(%ebp),%edx
  800df8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dfb:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dfe:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e00:	5b                   	pop    %ebx
  800e01:	5e                   	pop    %esi
  800e02:	5f                   	pop    %edi
  800e03:	5d                   	pop    %ebp
  800e04:	c3                   	ret    

00800e05 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
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
  800e0e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e13:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e18:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1b:	89 cb                	mov    %ecx,%ebx
  800e1d:	89 cf                	mov    %ecx,%edi
  800e1f:	89 ce                	mov    %ecx,%esi
  800e21:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e23:	85 c0                	test   %eax,%eax
  800e25:	7e 17                	jle    800e3e <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e27:	83 ec 0c             	sub    $0xc,%esp
  800e2a:	50                   	push   %eax
  800e2b:	6a 0d                	push   $0xd
  800e2d:	68 df 25 80 00       	push   $0x8025df
  800e32:	6a 23                	push   $0x23
  800e34:	68 fc 25 80 00       	push   $0x8025fc
  800e39:	e8 0f f3 ff ff       	call   80014d <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e41:	5b                   	pop    %ebx
  800e42:	5e                   	pop    %esi
  800e43:	5f                   	pop    %edi
  800e44:	5d                   	pop    %ebp
  800e45:	c3                   	ret    

00800e46 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e46:	55                   	push   %ebp
  800e47:	89 e5                	mov    %esp,%ebp
  800e49:	53                   	push   %ebx
  800e4a:	83 ec 04             	sub    $0x4,%esp
  800e4d:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e50:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & 
  800e52:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e56:	0f 84 48 01 00 00    	je     800fa4 <pgfault+0x15e>
  800e5c:	89 d8                	mov    %ebx,%eax
  800e5e:	c1 e8 16             	shr    $0x16,%eax
  800e61:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e68:	a8 01                	test   $0x1,%al
  800e6a:	0f 84 5f 01 00 00    	je     800fcf <pgfault+0x189>
  800e70:	89 d8                	mov    %ebx,%eax
  800e72:	c1 e8 0c             	shr    $0xc,%eax
  800e75:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800e7c:	f6 c2 01             	test   $0x1,%dl
  800e7f:	0f 84 4a 01 00 00    	je     800fcf <pgfault+0x189>
				PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW))) {
  800e85:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & 
  800e8c:	f6 c4 08             	test   $0x8,%ah
  800e8f:	75 79                	jne    800f0a <pgfault+0xc4>
  800e91:	e9 39 01 00 00       	jmp    800fcf <pgfault+0x189>
				PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW))) {
		cprintf("Fault address = %08x, envid = %08x\n", addr, thisenv->env_id);
		if (!(err & FEC_WR)) cprintf("Not write\n");
		if (!(uvpd[PDX(addr)] & PTE_P)) cprintf("PDE not present\n");
  800e96:	89 d8                	mov    %ebx,%eax
  800e98:	c1 e8 16             	shr    $0x16,%eax
  800e9b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ea2:	a8 01                	test   $0x1,%al
  800ea4:	75 10                	jne    800eb6 <pgfault+0x70>
  800ea6:	83 ec 0c             	sub    $0xc,%esp
  800ea9:	68 0a 26 80 00       	push   $0x80260a
  800eae:	e8 73 f3 ff ff       	call   800226 <cprintf>
  800eb3:	83 c4 10             	add    $0x10,%esp
		if (!(uvpt[PTX(addr)] & PTE_P)) cprintf("PTE not present\n");
  800eb6:	c1 eb 0c             	shr    $0xc,%ebx
  800eb9:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  800ebf:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800ec6:	a8 01                	test   $0x1,%al
  800ec8:	75 10                	jne    800eda <pgfault+0x94>
  800eca:	83 ec 0c             	sub    $0xc,%esp
  800ecd:	68 1b 26 80 00       	push   $0x80261b
  800ed2:	e8 4f f3 ff ff       	call   800226 <cprintf>
  800ed7:	83 c4 10             	add    $0x10,%esp
		if (!(uvpt[PTX(addr)] & PTE_COW)) cprintf("Not copy-on-write\n");
  800eda:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800ee1:	f6 c4 08             	test   $0x8,%ah
  800ee4:	75 10                	jne    800ef6 <pgfault+0xb0>
  800ee6:	83 ec 0c             	sub    $0xc,%esp
  800ee9:	68 2c 26 80 00       	push   $0x80262c
  800eee:	e8 33 f3 ff ff       	call   800226 <cprintf>
  800ef3:	83 c4 10             	add    $0x10,%esp
		panic("User page fault");
  800ef6:	83 ec 04             	sub    $0x4,%esp
  800ef9:	68 3f 26 80 00       	push   $0x80263f
  800efe:	6a 23                	push   $0x23
  800f00:	68 4f 26 80 00       	push   $0x80264f
  800f05:	e8 43 f2 ff ff       	call   80014d <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// 0 refers to curenv
	if ((r = sys_page_alloc(0, (void*)PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  800f0a:	83 ec 04             	sub    $0x4,%esp
  800f0d:	6a 07                	push   $0x7
  800f0f:	68 00 f0 7f 00       	push   $0x7ff000
  800f14:	6a 00                	push   $0x0
  800f16:	e8 3a fd ff ff       	call   800c55 <sys_page_alloc>
  800f1b:	83 c4 10             	add    $0x10,%esp
  800f1e:	85 c0                	test   %eax,%eax
  800f20:	79 12                	jns    800f34 <pgfault+0xee>
		panic("sys_page_alloc failed: %e", r);
  800f22:	50                   	push   %eax
  800f23:	68 5a 26 80 00       	push   $0x80265a
  800f28:	6a 2f                	push   $0x2f
  800f2a:	68 4f 26 80 00       	push   $0x80264f
  800f2f:	e8 19 f2 ff ff       	call   80014d <_panic>
	memcpy((void*)PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  800f34:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800f3a:	83 ec 04             	sub    $0x4,%esp
  800f3d:	68 00 10 00 00       	push   $0x1000
  800f42:	53                   	push   %ebx
  800f43:	68 00 f0 7f 00       	push   $0x7ff000
  800f48:	e8 ff fa ff ff       	call   800a4c <memcpy>
	if ((r = sys_page_map(0, (void*)PFTEMP, 0, (void*)ROUNDDOWN(addr, PGSIZE), 
  800f4d:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f54:	53                   	push   %ebx
  800f55:	6a 00                	push   $0x0
  800f57:	68 00 f0 7f 00       	push   $0x7ff000
  800f5c:	6a 00                	push   $0x0
  800f5e:	e8 35 fd ff ff       	call   800c98 <sys_page_map>
  800f63:	83 c4 20             	add    $0x20,%esp
  800f66:	85 c0                	test   %eax,%eax
  800f68:	79 12                	jns    800f7c <pgfault+0x136>
					PTE_P | PTE_U | PTE_W)) < 0)
		panic("sys_page_map failed: %e", r);
  800f6a:	50                   	push   %eax
  800f6b:	68 74 26 80 00       	push   $0x802674
  800f70:	6a 33                	push   $0x33
  800f72:	68 4f 26 80 00       	push   $0x80264f
  800f77:	e8 d1 f1 ff ff       	call   80014d <_panic>
	if ((r = sys_page_unmap(0, (void*)PFTEMP)) < 0)
  800f7c:	83 ec 08             	sub    $0x8,%esp
  800f7f:	68 00 f0 7f 00       	push   $0x7ff000
  800f84:	6a 00                	push   $0x0
  800f86:	e8 4f fd ff ff       	call   800cda <sys_page_unmap>
  800f8b:	83 c4 10             	add    $0x10,%esp
  800f8e:	85 c0                	test   %eax,%eax
  800f90:	79 5c                	jns    800fee <pgfault+0x1a8>
		panic("sys_page_unmap failed: %e", r);
  800f92:	50                   	push   %eax
  800f93:	68 8c 26 80 00       	push   $0x80268c
  800f98:	6a 35                	push   $0x35
  800f9a:	68 4f 26 80 00       	push   $0x80264f
  800f9f:	e8 a9 f1 ff ff       	call   80014d <_panic>
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & 
				PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW))) {
		cprintf("Fault address = %08x, envid = %08x\n", addr, thisenv->env_id);
  800fa4:	a1 08 40 80 00       	mov    0x804008,%eax
  800fa9:	8b 40 48             	mov    0x48(%eax),%eax
  800fac:	83 ec 04             	sub    $0x4,%esp
  800faf:	50                   	push   %eax
  800fb0:	53                   	push   %ebx
  800fb1:	68 c8 26 80 00       	push   $0x8026c8
  800fb6:	e8 6b f2 ff ff       	call   800226 <cprintf>
		if (!(err & FEC_WR)) cprintf("Not write\n");
  800fbb:	c7 04 24 a6 26 80 00 	movl   $0x8026a6,(%esp)
  800fc2:	e8 5f f2 ff ff       	call   800226 <cprintf>
  800fc7:	83 c4 10             	add    $0x10,%esp
  800fca:	e9 c7 fe ff ff       	jmp    800e96 <pgfault+0x50>
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & 
				PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW))) {
		cprintf("Fault address = %08x, envid = %08x\n", addr, thisenv->env_id);
  800fcf:	a1 08 40 80 00       	mov    0x804008,%eax
  800fd4:	8b 40 48             	mov    0x48(%eax),%eax
  800fd7:	83 ec 04             	sub    $0x4,%esp
  800fda:	50                   	push   %eax
  800fdb:	53                   	push   %ebx
  800fdc:	68 c8 26 80 00       	push   $0x8026c8
  800fe1:	e8 40 f2 ff ff       	call   800226 <cprintf>
  800fe6:	83 c4 10             	add    $0x10,%esp
  800fe9:	e9 a8 fe ff ff       	jmp    800e96 <pgfault+0x50>
		panic("sys_page_map failed: %e", r);
	if ((r = sys_page_unmap(0, (void*)PFTEMP)) < 0)
		panic("sys_page_unmap failed: %e", r);

	// panic("pgfault not implemented");
}
  800fee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ff1:	c9                   	leave  
  800ff2:	c3                   	ret    

00800ff3 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ff3:	55                   	push   %ebp
  800ff4:	89 e5                	mov    %esp,%ebp
  800ff6:	57                   	push   %edi
  800ff7:	56                   	push   %esi
  800ff8:	53                   	push   %ebx
  800ff9:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	int ret;
	set_pgfault_handler(pgfault);
  800ffc:	68 46 0e 80 00       	push   $0x800e46
  801001:	e8 08 0e 00 00       	call   801e0e <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801006:	b8 07 00 00 00       	mov    $0x7,%eax
  80100b:	cd 30                	int    $0x30
  80100d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801010:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	envid_t envid = sys_exofork();

	if (envid < 0) return envid;
  801013:	83 c4 10             	add    $0x10,%esp
  801016:	85 c0                	test   %eax,%eax
  801018:	0f 88 0d 01 00 00    	js     80112b <fork+0x138>
  80101e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801023:	be 00 00 00 00       	mov    $0x0,%esi
	else if (envid == 0) {
  801028:	85 c0                	test   %eax,%eax
  80102a:	75 2f                	jne    80105b <fork+0x68>
		// Child returns
		thisenv = &envs[ENVX(sys_getenvid())];
  80102c:	e8 e6 fb ff ff       	call   800c17 <sys_getenvid>
  801031:	25 ff 03 00 00       	and    $0x3ff,%eax
  801036:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801039:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80103e:	a3 08 40 80 00       	mov    %eax,0x804008
		// set_pgfault_handler(pgfault);
		return 0;
  801043:	b8 00 00 00 00       	mov    $0x0,%eax
  801048:	e9 e1 00 00 00       	jmp    80112e <fork+0x13b>
  80104d:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
	}
	else {
		uint32_t pn;
		for (pn = 0; pn * PGSIZE < UTOP; pn++){
			// cprintf("virtual page %08x\n", pn * PGSIZE);
			if (pn * PGSIZE == UXSTACKTOP - PGSIZE) 
  801053:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801059:	74 77                	je     8010d2 <fork+0xdf>
{
	int r;

	// LAB 4: Your code here.
	int perm = PTE_P | PTE_U;
	pde_t pde = uvpd[pn / NPTENTRIES];
  80105b:	89 f0                	mov    %esi,%eax
  80105d:	c1 e8 0a             	shr    $0xa,%eax
  801060:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
	if (!(pde & PTE_P)) return 0;
  801067:	a8 01                	test   $0x1,%al
  801069:	74 0b                	je     801076 <fork+0x83>
	pte_t pte = uvpt[pn];
  80106b:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	if (!(pte & PTE_P)) return 0;
  801072:	a8 01                	test   $0x1,%al
  801074:	75 08                	jne    80107e <fork+0x8b>
  801076:	8d 5e 01             	lea    0x1(%esi),%ebx
  801079:	c1 e3 0c             	shl    $0xc,%ebx
  80107c:	eb 56                	jmp    8010d4 <fork+0xe1>
	// cprintf("virtual page %08x\n", pn * PGSIZE);

	if ((pte & PTE_W) || (pte & PTE_COW)) perm |= PTE_COW;
  80107e:	25 02 08 00 00       	and    $0x802,%eax
  801083:	83 f8 01             	cmp    $0x1,%eax
  801086:	19 ff                	sbb    %edi,%edi
  801088:	81 e7 00 f8 ff ff    	and    $0xfffff800,%edi
  80108e:	81 c7 05 08 00 00    	add    $0x805,%edi

	if ((r = sys_page_map(thisenv->env_id, (void*)(pn * PGSIZE), envid, 
  801094:	a1 08 40 80 00       	mov    0x804008,%eax
  801099:	8b 40 48             	mov    0x48(%eax),%eax
  80109c:	83 ec 0c             	sub    $0xc,%esp
  80109f:	57                   	push   %edi
  8010a0:	53                   	push   %ebx
  8010a1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010a4:	53                   	push   %ebx
  8010a5:	50                   	push   %eax
  8010a6:	e8 ed fb ff ff       	call   800c98 <sys_page_map>
  8010ab:	83 c4 20             	add    $0x20,%esp
  8010ae:	85 c0                	test   %eax,%eax
  8010b0:	78 7c                	js     80112e <fork+0x13b>
				(void*)(pn * PGSIZE), perm)) < 0) 
		return r;
	r = sys_page_map(envid, (void*)(pn * PGSIZE), thisenv->env_id, 
  8010b2:	a1 08 40 80 00       	mov    0x804008,%eax
  8010b7:	8b 40 48             	mov    0x48(%eax),%eax
  8010ba:	83 ec 0c             	sub    $0xc,%esp
  8010bd:	57                   	push   %edi
  8010be:	53                   	push   %ebx
  8010bf:	50                   	push   %eax
  8010c0:	53                   	push   %ebx
  8010c1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010c4:	e8 cf fb ff ff       	call   800c98 <sys_page_map>
		uint32_t pn;
		for (pn = 0; pn * PGSIZE < UTOP; pn++){
			// cprintf("virtual page %08x\n", pn * PGSIZE);
			if (pn * PGSIZE == UXSTACKTOP - PGSIZE) 
				continue;
			if ((ret = duppage(envid, pn)) < 0)
  8010c9:	83 c4 20             	add    $0x20,%esp
  8010cc:	85 c0                	test   %eax,%eax
  8010ce:	79 a6                	jns    801076 <fork+0x83>
  8010d0:	eb 5c                	jmp    80112e <fork+0x13b>
  8010d2:	89 c3                	mov    %eax,%ebx
		// set_pgfault_handler(pgfault);
		return 0;
	}
	else {
		uint32_t pn;
		for (pn = 0; pn * PGSIZE < UTOP; pn++){
  8010d4:	83 c6 01             	add    $0x1,%esi
  8010d7:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
  8010dd:	0f 86 6a ff ff ff    	jbe    80104d <fork+0x5a>
				return ret;
		}
		// cprintf("Fork: duppage finished\n");

		// Should be done by parent
		if ((ret = sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P |
  8010e3:	83 ec 04             	sub    $0x4,%esp
  8010e6:	6a 07                	push   $0x7
  8010e8:	68 00 f0 bf ee       	push   $0xeebff000
  8010ed:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8010f0:	57                   	push   %edi
  8010f1:	e8 5f fb ff ff       	call   800c55 <sys_page_alloc>
  8010f6:	83 c4 10             	add    $0x10,%esp
  8010f9:	85 c0                	test   %eax,%eax
  8010fb:	78 31                	js     80112e <fork+0x13b>
						PTE_U | PTE_W)) < 0)
			return ret;
		if ((ret = sys_env_set_pgfault_upcall(envid, 
						thisenv->env_pgfault_upcall)) < 0)
  8010fd:	a1 08 40 80 00       	mov    0x804008,%eax

		// Should be done by parent
		if ((ret = sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P |
						PTE_U | PTE_W)) < 0)
			return ret;
		if ((ret = sys_env_set_pgfault_upcall(envid, 
  801102:	8b 40 64             	mov    0x64(%eax),%eax
  801105:	83 ec 08             	sub    $0x8,%esp
  801108:	50                   	push   %eax
  801109:	57                   	push   %edi
  80110a:	e8 91 fc ff ff       	call   800da0 <sys_env_set_pgfault_upcall>
  80110f:	83 c4 10             	add    $0x10,%esp
  801112:	85 c0                	test   %eax,%eax
  801114:	78 18                	js     80112e <fork+0x13b>
						thisenv->env_pgfault_upcall)) < 0)
			return ret;

		if ((ret = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  801116:	83 ec 08             	sub    $0x8,%esp
  801119:	6a 02                	push   $0x2
  80111b:	57                   	push   %edi
  80111c:	e8 fb fb ff ff       	call   800d1c <sys_env_set_status>
  801121:	83 c4 10             	add    $0x10,%esp
			return ret;
		return envid;
  801124:	85 c0                	test   %eax,%eax
  801126:	0f 49 c7             	cmovns %edi,%eax
  801129:	eb 03                	jmp    80112e <fork+0x13b>
	int ret;
	set_pgfault_handler(pgfault);

	envid_t envid = sys_exofork();

	if (envid < 0) return envid;
  80112b:	8b 45 e0             	mov    -0x20(%ebp),%eax
			return ret;
		return envid;
	}

	panic("fork not implemented");
}
  80112e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801131:	5b                   	pop    %ebx
  801132:	5e                   	pop    %esi
  801133:	5f                   	pop    %edi
  801134:	5d                   	pop    %ebp
  801135:	c3                   	ret    

00801136 <sfork>:

// Challenge!
int
sfork(void)
{
  801136:	55                   	push   %ebp
  801137:	89 e5                	mov    %esp,%ebp
  801139:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80113c:	68 b1 26 80 00       	push   $0x8026b1
  801141:	68 9f 00 00 00       	push   $0x9f
  801146:	68 4f 26 80 00       	push   $0x80264f
  80114b:	e8 fd ef ff ff       	call   80014d <_panic>

00801150 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801150:	55                   	push   %ebp
  801151:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801153:	8b 45 08             	mov    0x8(%ebp),%eax
  801156:	05 00 00 00 30       	add    $0x30000000,%eax
  80115b:	c1 e8 0c             	shr    $0xc,%eax
}
  80115e:	5d                   	pop    %ebp
  80115f:	c3                   	ret    

00801160 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801160:	55                   	push   %ebp
  801161:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801163:	8b 45 08             	mov    0x8(%ebp),%eax
  801166:	05 00 00 00 30       	add    $0x30000000,%eax
  80116b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801170:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801175:	5d                   	pop    %ebp
  801176:	c3                   	ret    

00801177 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801177:	55                   	push   %ebp
  801178:	89 e5                	mov    %esp,%ebp
  80117a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80117d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801182:	89 c2                	mov    %eax,%edx
  801184:	c1 ea 16             	shr    $0x16,%edx
  801187:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80118e:	f6 c2 01             	test   $0x1,%dl
  801191:	74 11                	je     8011a4 <fd_alloc+0x2d>
  801193:	89 c2                	mov    %eax,%edx
  801195:	c1 ea 0c             	shr    $0xc,%edx
  801198:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80119f:	f6 c2 01             	test   $0x1,%dl
  8011a2:	75 09                	jne    8011ad <fd_alloc+0x36>
			*fd_store = fd;
  8011a4:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8011ab:	eb 17                	jmp    8011c4 <fd_alloc+0x4d>
  8011ad:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011b2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011b7:	75 c9                	jne    801182 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011b9:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011bf:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011c4:	5d                   	pop    %ebp
  8011c5:	c3                   	ret    

008011c6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011c6:	55                   	push   %ebp
  8011c7:	89 e5                	mov    %esp,%ebp
  8011c9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011cc:	83 f8 1f             	cmp    $0x1f,%eax
  8011cf:	77 36                	ja     801207 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011d1:	c1 e0 0c             	shl    $0xc,%eax
  8011d4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011d9:	89 c2                	mov    %eax,%edx
  8011db:	c1 ea 16             	shr    $0x16,%edx
  8011de:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011e5:	f6 c2 01             	test   $0x1,%dl
  8011e8:	74 24                	je     80120e <fd_lookup+0x48>
  8011ea:	89 c2                	mov    %eax,%edx
  8011ec:	c1 ea 0c             	shr    $0xc,%edx
  8011ef:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011f6:	f6 c2 01             	test   $0x1,%dl
  8011f9:	74 1a                	je     801215 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011fb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011fe:	89 02                	mov    %eax,(%edx)
	return 0;
  801200:	b8 00 00 00 00       	mov    $0x0,%eax
  801205:	eb 13                	jmp    80121a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801207:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80120c:	eb 0c                	jmp    80121a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80120e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801213:	eb 05                	jmp    80121a <fd_lookup+0x54>
  801215:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80121a:	5d                   	pop    %ebp
  80121b:	c3                   	ret    

0080121c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80121c:	55                   	push   %ebp
  80121d:	89 e5                	mov    %esp,%ebp
  80121f:	83 ec 08             	sub    $0x8,%esp
  801222:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801225:	ba 6c 27 80 00       	mov    $0x80276c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80122a:	eb 13                	jmp    80123f <dev_lookup+0x23>
  80122c:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80122f:	39 08                	cmp    %ecx,(%eax)
  801231:	75 0c                	jne    80123f <dev_lookup+0x23>
			*dev = devtab[i];
  801233:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801236:	89 01                	mov    %eax,(%ecx)
			return 0;
  801238:	b8 00 00 00 00       	mov    $0x0,%eax
  80123d:	eb 2e                	jmp    80126d <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80123f:	8b 02                	mov    (%edx),%eax
  801241:	85 c0                	test   %eax,%eax
  801243:	75 e7                	jne    80122c <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801245:	a1 08 40 80 00       	mov    0x804008,%eax
  80124a:	8b 40 48             	mov    0x48(%eax),%eax
  80124d:	83 ec 04             	sub    $0x4,%esp
  801250:	51                   	push   %ecx
  801251:	50                   	push   %eax
  801252:	68 ec 26 80 00       	push   $0x8026ec
  801257:	e8 ca ef ff ff       	call   800226 <cprintf>
	*dev = 0;
  80125c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80125f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801265:	83 c4 10             	add    $0x10,%esp
  801268:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80126d:	c9                   	leave  
  80126e:	c3                   	ret    

0080126f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80126f:	55                   	push   %ebp
  801270:	89 e5                	mov    %esp,%ebp
  801272:	56                   	push   %esi
  801273:	53                   	push   %ebx
  801274:	83 ec 10             	sub    $0x10,%esp
  801277:	8b 75 08             	mov    0x8(%ebp),%esi
  80127a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80127d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801280:	50                   	push   %eax
  801281:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801287:	c1 e8 0c             	shr    $0xc,%eax
  80128a:	50                   	push   %eax
  80128b:	e8 36 ff ff ff       	call   8011c6 <fd_lookup>
  801290:	83 c4 08             	add    $0x8,%esp
  801293:	85 c0                	test   %eax,%eax
  801295:	78 05                	js     80129c <fd_close+0x2d>
	    || fd != fd2)
  801297:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80129a:	74 0c                	je     8012a8 <fd_close+0x39>
		return (must_exist ? r : 0);
  80129c:	84 db                	test   %bl,%bl
  80129e:	ba 00 00 00 00       	mov    $0x0,%edx
  8012a3:	0f 44 c2             	cmove  %edx,%eax
  8012a6:	eb 41                	jmp    8012e9 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012a8:	83 ec 08             	sub    $0x8,%esp
  8012ab:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012ae:	50                   	push   %eax
  8012af:	ff 36                	pushl  (%esi)
  8012b1:	e8 66 ff ff ff       	call   80121c <dev_lookup>
  8012b6:	89 c3                	mov    %eax,%ebx
  8012b8:	83 c4 10             	add    $0x10,%esp
  8012bb:	85 c0                	test   %eax,%eax
  8012bd:	78 1a                	js     8012d9 <fd_close+0x6a>
		if (dev->dev_close)
  8012bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012c2:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8012c5:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8012ca:	85 c0                	test   %eax,%eax
  8012cc:	74 0b                	je     8012d9 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012ce:	83 ec 0c             	sub    $0xc,%esp
  8012d1:	56                   	push   %esi
  8012d2:	ff d0                	call   *%eax
  8012d4:	89 c3                	mov    %eax,%ebx
  8012d6:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012d9:	83 ec 08             	sub    $0x8,%esp
  8012dc:	56                   	push   %esi
  8012dd:	6a 00                	push   $0x0
  8012df:	e8 f6 f9 ff ff       	call   800cda <sys_page_unmap>
	return r;
  8012e4:	83 c4 10             	add    $0x10,%esp
  8012e7:	89 d8                	mov    %ebx,%eax
}
  8012e9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012ec:	5b                   	pop    %ebx
  8012ed:	5e                   	pop    %esi
  8012ee:	5d                   	pop    %ebp
  8012ef:	c3                   	ret    

008012f0 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012f0:	55                   	push   %ebp
  8012f1:	89 e5                	mov    %esp,%ebp
  8012f3:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012f9:	50                   	push   %eax
  8012fa:	ff 75 08             	pushl  0x8(%ebp)
  8012fd:	e8 c4 fe ff ff       	call   8011c6 <fd_lookup>
  801302:	83 c4 08             	add    $0x8,%esp
  801305:	85 c0                	test   %eax,%eax
  801307:	78 10                	js     801319 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801309:	83 ec 08             	sub    $0x8,%esp
  80130c:	6a 01                	push   $0x1
  80130e:	ff 75 f4             	pushl  -0xc(%ebp)
  801311:	e8 59 ff ff ff       	call   80126f <fd_close>
  801316:	83 c4 10             	add    $0x10,%esp
}
  801319:	c9                   	leave  
  80131a:	c3                   	ret    

0080131b <close_all>:

void
close_all(void)
{
  80131b:	55                   	push   %ebp
  80131c:	89 e5                	mov    %esp,%ebp
  80131e:	53                   	push   %ebx
  80131f:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801322:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801327:	83 ec 0c             	sub    $0xc,%esp
  80132a:	53                   	push   %ebx
  80132b:	e8 c0 ff ff ff       	call   8012f0 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801330:	83 c3 01             	add    $0x1,%ebx
  801333:	83 c4 10             	add    $0x10,%esp
  801336:	83 fb 20             	cmp    $0x20,%ebx
  801339:	75 ec                	jne    801327 <close_all+0xc>
		close(i);
}
  80133b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80133e:	c9                   	leave  
  80133f:	c3                   	ret    

00801340 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801340:	55                   	push   %ebp
  801341:	89 e5                	mov    %esp,%ebp
  801343:	57                   	push   %edi
  801344:	56                   	push   %esi
  801345:	53                   	push   %ebx
  801346:	83 ec 2c             	sub    $0x2c,%esp
  801349:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80134c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80134f:	50                   	push   %eax
  801350:	ff 75 08             	pushl  0x8(%ebp)
  801353:	e8 6e fe ff ff       	call   8011c6 <fd_lookup>
  801358:	83 c4 08             	add    $0x8,%esp
  80135b:	85 c0                	test   %eax,%eax
  80135d:	0f 88 c1 00 00 00    	js     801424 <dup+0xe4>
		return r;
	close(newfdnum);
  801363:	83 ec 0c             	sub    $0xc,%esp
  801366:	56                   	push   %esi
  801367:	e8 84 ff ff ff       	call   8012f0 <close>

	newfd = INDEX2FD(newfdnum);
  80136c:	89 f3                	mov    %esi,%ebx
  80136e:	c1 e3 0c             	shl    $0xc,%ebx
  801371:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801377:	83 c4 04             	add    $0x4,%esp
  80137a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80137d:	e8 de fd ff ff       	call   801160 <fd2data>
  801382:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801384:	89 1c 24             	mov    %ebx,(%esp)
  801387:	e8 d4 fd ff ff       	call   801160 <fd2data>
  80138c:	83 c4 10             	add    $0x10,%esp
  80138f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801392:	89 f8                	mov    %edi,%eax
  801394:	c1 e8 16             	shr    $0x16,%eax
  801397:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80139e:	a8 01                	test   $0x1,%al
  8013a0:	74 37                	je     8013d9 <dup+0x99>
  8013a2:	89 f8                	mov    %edi,%eax
  8013a4:	c1 e8 0c             	shr    $0xc,%eax
  8013a7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013ae:	f6 c2 01             	test   $0x1,%dl
  8013b1:	74 26                	je     8013d9 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013b3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013ba:	83 ec 0c             	sub    $0xc,%esp
  8013bd:	25 07 0e 00 00       	and    $0xe07,%eax
  8013c2:	50                   	push   %eax
  8013c3:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013c6:	6a 00                	push   $0x0
  8013c8:	57                   	push   %edi
  8013c9:	6a 00                	push   $0x0
  8013cb:	e8 c8 f8 ff ff       	call   800c98 <sys_page_map>
  8013d0:	89 c7                	mov    %eax,%edi
  8013d2:	83 c4 20             	add    $0x20,%esp
  8013d5:	85 c0                	test   %eax,%eax
  8013d7:	78 2e                	js     801407 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013d9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8013dc:	89 d0                	mov    %edx,%eax
  8013de:	c1 e8 0c             	shr    $0xc,%eax
  8013e1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013e8:	83 ec 0c             	sub    $0xc,%esp
  8013eb:	25 07 0e 00 00       	and    $0xe07,%eax
  8013f0:	50                   	push   %eax
  8013f1:	53                   	push   %ebx
  8013f2:	6a 00                	push   $0x0
  8013f4:	52                   	push   %edx
  8013f5:	6a 00                	push   $0x0
  8013f7:	e8 9c f8 ff ff       	call   800c98 <sys_page_map>
  8013fc:	89 c7                	mov    %eax,%edi
  8013fe:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801401:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801403:	85 ff                	test   %edi,%edi
  801405:	79 1d                	jns    801424 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801407:	83 ec 08             	sub    $0x8,%esp
  80140a:	53                   	push   %ebx
  80140b:	6a 00                	push   $0x0
  80140d:	e8 c8 f8 ff ff       	call   800cda <sys_page_unmap>
	sys_page_unmap(0, nva);
  801412:	83 c4 08             	add    $0x8,%esp
  801415:	ff 75 d4             	pushl  -0x2c(%ebp)
  801418:	6a 00                	push   $0x0
  80141a:	e8 bb f8 ff ff       	call   800cda <sys_page_unmap>
	return r;
  80141f:	83 c4 10             	add    $0x10,%esp
  801422:	89 f8                	mov    %edi,%eax
}
  801424:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801427:	5b                   	pop    %ebx
  801428:	5e                   	pop    %esi
  801429:	5f                   	pop    %edi
  80142a:	5d                   	pop    %ebp
  80142b:	c3                   	ret    

0080142c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80142c:	55                   	push   %ebp
  80142d:	89 e5                	mov    %esp,%ebp
  80142f:	53                   	push   %ebx
  801430:	83 ec 14             	sub    $0x14,%esp
  801433:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801436:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801439:	50                   	push   %eax
  80143a:	53                   	push   %ebx
  80143b:	e8 86 fd ff ff       	call   8011c6 <fd_lookup>
  801440:	83 c4 08             	add    $0x8,%esp
  801443:	89 c2                	mov    %eax,%edx
  801445:	85 c0                	test   %eax,%eax
  801447:	78 6d                	js     8014b6 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801449:	83 ec 08             	sub    $0x8,%esp
  80144c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80144f:	50                   	push   %eax
  801450:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801453:	ff 30                	pushl  (%eax)
  801455:	e8 c2 fd ff ff       	call   80121c <dev_lookup>
  80145a:	83 c4 10             	add    $0x10,%esp
  80145d:	85 c0                	test   %eax,%eax
  80145f:	78 4c                	js     8014ad <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801461:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801464:	8b 42 08             	mov    0x8(%edx),%eax
  801467:	83 e0 03             	and    $0x3,%eax
  80146a:	83 f8 01             	cmp    $0x1,%eax
  80146d:	75 21                	jne    801490 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80146f:	a1 08 40 80 00       	mov    0x804008,%eax
  801474:	8b 40 48             	mov    0x48(%eax),%eax
  801477:	83 ec 04             	sub    $0x4,%esp
  80147a:	53                   	push   %ebx
  80147b:	50                   	push   %eax
  80147c:	68 30 27 80 00       	push   $0x802730
  801481:	e8 a0 ed ff ff       	call   800226 <cprintf>
		return -E_INVAL;
  801486:	83 c4 10             	add    $0x10,%esp
  801489:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80148e:	eb 26                	jmp    8014b6 <read+0x8a>
	}
	if (!dev->dev_read)
  801490:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801493:	8b 40 08             	mov    0x8(%eax),%eax
  801496:	85 c0                	test   %eax,%eax
  801498:	74 17                	je     8014b1 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80149a:	83 ec 04             	sub    $0x4,%esp
  80149d:	ff 75 10             	pushl  0x10(%ebp)
  8014a0:	ff 75 0c             	pushl  0xc(%ebp)
  8014a3:	52                   	push   %edx
  8014a4:	ff d0                	call   *%eax
  8014a6:	89 c2                	mov    %eax,%edx
  8014a8:	83 c4 10             	add    $0x10,%esp
  8014ab:	eb 09                	jmp    8014b6 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014ad:	89 c2                	mov    %eax,%edx
  8014af:	eb 05                	jmp    8014b6 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014b1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8014b6:	89 d0                	mov    %edx,%eax
  8014b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014bb:	c9                   	leave  
  8014bc:	c3                   	ret    

008014bd <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014bd:	55                   	push   %ebp
  8014be:	89 e5                	mov    %esp,%ebp
  8014c0:	57                   	push   %edi
  8014c1:	56                   	push   %esi
  8014c2:	53                   	push   %ebx
  8014c3:	83 ec 0c             	sub    $0xc,%esp
  8014c6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014c9:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014cc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014d1:	eb 21                	jmp    8014f4 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014d3:	83 ec 04             	sub    $0x4,%esp
  8014d6:	89 f0                	mov    %esi,%eax
  8014d8:	29 d8                	sub    %ebx,%eax
  8014da:	50                   	push   %eax
  8014db:	89 d8                	mov    %ebx,%eax
  8014dd:	03 45 0c             	add    0xc(%ebp),%eax
  8014e0:	50                   	push   %eax
  8014e1:	57                   	push   %edi
  8014e2:	e8 45 ff ff ff       	call   80142c <read>
		if (m < 0)
  8014e7:	83 c4 10             	add    $0x10,%esp
  8014ea:	85 c0                	test   %eax,%eax
  8014ec:	78 10                	js     8014fe <readn+0x41>
			return m;
		if (m == 0)
  8014ee:	85 c0                	test   %eax,%eax
  8014f0:	74 0a                	je     8014fc <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014f2:	01 c3                	add    %eax,%ebx
  8014f4:	39 f3                	cmp    %esi,%ebx
  8014f6:	72 db                	jb     8014d3 <readn+0x16>
  8014f8:	89 d8                	mov    %ebx,%eax
  8014fa:	eb 02                	jmp    8014fe <readn+0x41>
  8014fc:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8014fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801501:	5b                   	pop    %ebx
  801502:	5e                   	pop    %esi
  801503:	5f                   	pop    %edi
  801504:	5d                   	pop    %ebp
  801505:	c3                   	ret    

00801506 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801506:	55                   	push   %ebp
  801507:	89 e5                	mov    %esp,%ebp
  801509:	53                   	push   %ebx
  80150a:	83 ec 14             	sub    $0x14,%esp
  80150d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801510:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801513:	50                   	push   %eax
  801514:	53                   	push   %ebx
  801515:	e8 ac fc ff ff       	call   8011c6 <fd_lookup>
  80151a:	83 c4 08             	add    $0x8,%esp
  80151d:	89 c2                	mov    %eax,%edx
  80151f:	85 c0                	test   %eax,%eax
  801521:	78 68                	js     80158b <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801523:	83 ec 08             	sub    $0x8,%esp
  801526:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801529:	50                   	push   %eax
  80152a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80152d:	ff 30                	pushl  (%eax)
  80152f:	e8 e8 fc ff ff       	call   80121c <dev_lookup>
  801534:	83 c4 10             	add    $0x10,%esp
  801537:	85 c0                	test   %eax,%eax
  801539:	78 47                	js     801582 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80153b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80153e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801542:	75 21                	jne    801565 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801544:	a1 08 40 80 00       	mov    0x804008,%eax
  801549:	8b 40 48             	mov    0x48(%eax),%eax
  80154c:	83 ec 04             	sub    $0x4,%esp
  80154f:	53                   	push   %ebx
  801550:	50                   	push   %eax
  801551:	68 4c 27 80 00       	push   $0x80274c
  801556:	e8 cb ec ff ff       	call   800226 <cprintf>
		return -E_INVAL;
  80155b:	83 c4 10             	add    $0x10,%esp
  80155e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801563:	eb 26                	jmp    80158b <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801565:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801568:	8b 52 0c             	mov    0xc(%edx),%edx
  80156b:	85 d2                	test   %edx,%edx
  80156d:	74 17                	je     801586 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80156f:	83 ec 04             	sub    $0x4,%esp
  801572:	ff 75 10             	pushl  0x10(%ebp)
  801575:	ff 75 0c             	pushl  0xc(%ebp)
  801578:	50                   	push   %eax
  801579:	ff d2                	call   *%edx
  80157b:	89 c2                	mov    %eax,%edx
  80157d:	83 c4 10             	add    $0x10,%esp
  801580:	eb 09                	jmp    80158b <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801582:	89 c2                	mov    %eax,%edx
  801584:	eb 05                	jmp    80158b <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801586:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80158b:	89 d0                	mov    %edx,%eax
  80158d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801590:	c9                   	leave  
  801591:	c3                   	ret    

00801592 <seek>:

int
seek(int fdnum, off_t offset)
{
  801592:	55                   	push   %ebp
  801593:	89 e5                	mov    %esp,%ebp
  801595:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801598:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80159b:	50                   	push   %eax
  80159c:	ff 75 08             	pushl  0x8(%ebp)
  80159f:	e8 22 fc ff ff       	call   8011c6 <fd_lookup>
  8015a4:	83 c4 08             	add    $0x8,%esp
  8015a7:	85 c0                	test   %eax,%eax
  8015a9:	78 0e                	js     8015b9 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015ab:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015b1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015b9:	c9                   	leave  
  8015ba:	c3                   	ret    

008015bb <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015bb:	55                   	push   %ebp
  8015bc:	89 e5                	mov    %esp,%ebp
  8015be:	53                   	push   %ebx
  8015bf:	83 ec 14             	sub    $0x14,%esp
  8015c2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015c5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015c8:	50                   	push   %eax
  8015c9:	53                   	push   %ebx
  8015ca:	e8 f7 fb ff ff       	call   8011c6 <fd_lookup>
  8015cf:	83 c4 08             	add    $0x8,%esp
  8015d2:	89 c2                	mov    %eax,%edx
  8015d4:	85 c0                	test   %eax,%eax
  8015d6:	78 65                	js     80163d <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015d8:	83 ec 08             	sub    $0x8,%esp
  8015db:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015de:	50                   	push   %eax
  8015df:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015e2:	ff 30                	pushl  (%eax)
  8015e4:	e8 33 fc ff ff       	call   80121c <dev_lookup>
  8015e9:	83 c4 10             	add    $0x10,%esp
  8015ec:	85 c0                	test   %eax,%eax
  8015ee:	78 44                	js     801634 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015f3:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015f7:	75 21                	jne    80161a <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015f9:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015fe:	8b 40 48             	mov    0x48(%eax),%eax
  801601:	83 ec 04             	sub    $0x4,%esp
  801604:	53                   	push   %ebx
  801605:	50                   	push   %eax
  801606:	68 0c 27 80 00       	push   $0x80270c
  80160b:	e8 16 ec ff ff       	call   800226 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801610:	83 c4 10             	add    $0x10,%esp
  801613:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801618:	eb 23                	jmp    80163d <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80161a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80161d:	8b 52 18             	mov    0x18(%edx),%edx
  801620:	85 d2                	test   %edx,%edx
  801622:	74 14                	je     801638 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801624:	83 ec 08             	sub    $0x8,%esp
  801627:	ff 75 0c             	pushl  0xc(%ebp)
  80162a:	50                   	push   %eax
  80162b:	ff d2                	call   *%edx
  80162d:	89 c2                	mov    %eax,%edx
  80162f:	83 c4 10             	add    $0x10,%esp
  801632:	eb 09                	jmp    80163d <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801634:	89 c2                	mov    %eax,%edx
  801636:	eb 05                	jmp    80163d <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801638:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80163d:	89 d0                	mov    %edx,%eax
  80163f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801642:	c9                   	leave  
  801643:	c3                   	ret    

00801644 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801644:	55                   	push   %ebp
  801645:	89 e5                	mov    %esp,%ebp
  801647:	53                   	push   %ebx
  801648:	83 ec 14             	sub    $0x14,%esp
  80164b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80164e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801651:	50                   	push   %eax
  801652:	ff 75 08             	pushl  0x8(%ebp)
  801655:	e8 6c fb ff ff       	call   8011c6 <fd_lookup>
  80165a:	83 c4 08             	add    $0x8,%esp
  80165d:	89 c2                	mov    %eax,%edx
  80165f:	85 c0                	test   %eax,%eax
  801661:	78 58                	js     8016bb <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801663:	83 ec 08             	sub    $0x8,%esp
  801666:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801669:	50                   	push   %eax
  80166a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80166d:	ff 30                	pushl  (%eax)
  80166f:	e8 a8 fb ff ff       	call   80121c <dev_lookup>
  801674:	83 c4 10             	add    $0x10,%esp
  801677:	85 c0                	test   %eax,%eax
  801679:	78 37                	js     8016b2 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80167b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80167e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801682:	74 32                	je     8016b6 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801684:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801687:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80168e:	00 00 00 
	stat->st_isdir = 0;
  801691:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801698:	00 00 00 
	stat->st_dev = dev;
  80169b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016a1:	83 ec 08             	sub    $0x8,%esp
  8016a4:	53                   	push   %ebx
  8016a5:	ff 75 f0             	pushl  -0x10(%ebp)
  8016a8:	ff 50 14             	call   *0x14(%eax)
  8016ab:	89 c2                	mov    %eax,%edx
  8016ad:	83 c4 10             	add    $0x10,%esp
  8016b0:	eb 09                	jmp    8016bb <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016b2:	89 c2                	mov    %eax,%edx
  8016b4:	eb 05                	jmp    8016bb <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016b6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016bb:	89 d0                	mov    %edx,%eax
  8016bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016c0:	c9                   	leave  
  8016c1:	c3                   	ret    

008016c2 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016c2:	55                   	push   %ebp
  8016c3:	89 e5                	mov    %esp,%ebp
  8016c5:	56                   	push   %esi
  8016c6:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016c7:	83 ec 08             	sub    $0x8,%esp
  8016ca:	6a 00                	push   $0x0
  8016cc:	ff 75 08             	pushl  0x8(%ebp)
  8016cf:	e8 b7 01 00 00       	call   80188b <open>
  8016d4:	89 c3                	mov    %eax,%ebx
  8016d6:	83 c4 10             	add    $0x10,%esp
  8016d9:	85 c0                	test   %eax,%eax
  8016db:	78 1b                	js     8016f8 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016dd:	83 ec 08             	sub    $0x8,%esp
  8016e0:	ff 75 0c             	pushl  0xc(%ebp)
  8016e3:	50                   	push   %eax
  8016e4:	e8 5b ff ff ff       	call   801644 <fstat>
  8016e9:	89 c6                	mov    %eax,%esi
	close(fd);
  8016eb:	89 1c 24             	mov    %ebx,(%esp)
  8016ee:	e8 fd fb ff ff       	call   8012f0 <close>
	return r;
  8016f3:	83 c4 10             	add    $0x10,%esp
  8016f6:	89 f0                	mov    %esi,%eax
}
  8016f8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016fb:	5b                   	pop    %ebx
  8016fc:	5e                   	pop    %esi
  8016fd:	5d                   	pop    %ebp
  8016fe:	c3                   	ret    

008016ff <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016ff:	55                   	push   %ebp
  801700:	89 e5                	mov    %esp,%ebp
  801702:	56                   	push   %esi
  801703:	53                   	push   %ebx
  801704:	89 c6                	mov    %eax,%esi
  801706:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801708:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80170f:	75 12                	jne    801723 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801711:	83 ec 0c             	sub    $0xc,%esp
  801714:	6a 01                	push   $0x1
  801716:	e8 2c 08 00 00       	call   801f47 <ipc_find_env>
  80171b:	a3 00 40 80 00       	mov    %eax,0x804000
  801720:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801723:	6a 07                	push   $0x7
  801725:	68 00 50 80 00       	push   $0x805000
  80172a:	56                   	push   %esi
  80172b:	ff 35 00 40 80 00    	pushl  0x804000
  801731:	e8 bd 07 00 00       	call   801ef3 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801736:	83 c4 0c             	add    $0xc,%esp
  801739:	6a 00                	push   $0x0
  80173b:	53                   	push   %ebx
  80173c:	6a 00                	push   $0x0
  80173e:	e8 3b 07 00 00       	call   801e7e <ipc_recv>
}
  801743:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801746:	5b                   	pop    %ebx
  801747:	5e                   	pop    %esi
  801748:	5d                   	pop    %ebp
  801749:	c3                   	ret    

0080174a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80174a:	55                   	push   %ebp
  80174b:	89 e5                	mov    %esp,%ebp
  80174d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801750:	8b 45 08             	mov    0x8(%ebp),%eax
  801753:	8b 40 0c             	mov    0xc(%eax),%eax
  801756:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80175b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80175e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801763:	ba 00 00 00 00       	mov    $0x0,%edx
  801768:	b8 02 00 00 00       	mov    $0x2,%eax
  80176d:	e8 8d ff ff ff       	call   8016ff <fsipc>
}
  801772:	c9                   	leave  
  801773:	c3                   	ret    

00801774 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801774:	55                   	push   %ebp
  801775:	89 e5                	mov    %esp,%ebp
  801777:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80177a:	8b 45 08             	mov    0x8(%ebp),%eax
  80177d:	8b 40 0c             	mov    0xc(%eax),%eax
  801780:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801785:	ba 00 00 00 00       	mov    $0x0,%edx
  80178a:	b8 06 00 00 00       	mov    $0x6,%eax
  80178f:	e8 6b ff ff ff       	call   8016ff <fsipc>
}
  801794:	c9                   	leave  
  801795:	c3                   	ret    

00801796 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801796:	55                   	push   %ebp
  801797:	89 e5                	mov    %esp,%ebp
  801799:	53                   	push   %ebx
  80179a:	83 ec 04             	sub    $0x4,%esp
  80179d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a3:	8b 40 0c             	mov    0xc(%eax),%eax
  8017a6:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8017b0:	b8 05 00 00 00       	mov    $0x5,%eax
  8017b5:	e8 45 ff ff ff       	call   8016ff <fsipc>
  8017ba:	85 c0                	test   %eax,%eax
  8017bc:	78 2c                	js     8017ea <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017be:	83 ec 08             	sub    $0x8,%esp
  8017c1:	68 00 50 80 00       	push   $0x805000
  8017c6:	53                   	push   %ebx
  8017c7:	e8 86 f0 ff ff       	call   800852 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017cc:	a1 80 50 80 00       	mov    0x805080,%eax
  8017d1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017d7:	a1 84 50 80 00       	mov    0x805084,%eax
  8017dc:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017e2:	83 c4 10             	add    $0x10,%esp
  8017e5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017ed:	c9                   	leave  
  8017ee:	c3                   	ret    

008017ef <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8017ef:	55                   	push   %ebp
  8017f0:	89 e5                	mov    %esp,%ebp
  8017f2:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  8017f5:	68 7c 27 80 00       	push   $0x80277c
  8017fa:	68 90 00 00 00       	push   $0x90
  8017ff:	68 9a 27 80 00       	push   $0x80279a
  801804:	e8 44 e9 ff ff       	call   80014d <_panic>

00801809 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801809:	55                   	push   %ebp
  80180a:	89 e5                	mov    %esp,%ebp
  80180c:	56                   	push   %esi
  80180d:	53                   	push   %ebx
  80180e:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801811:	8b 45 08             	mov    0x8(%ebp),%eax
  801814:	8b 40 0c             	mov    0xc(%eax),%eax
  801817:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80181c:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801822:	ba 00 00 00 00       	mov    $0x0,%edx
  801827:	b8 03 00 00 00       	mov    $0x3,%eax
  80182c:	e8 ce fe ff ff       	call   8016ff <fsipc>
  801831:	89 c3                	mov    %eax,%ebx
  801833:	85 c0                	test   %eax,%eax
  801835:	78 4b                	js     801882 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801837:	39 c6                	cmp    %eax,%esi
  801839:	73 16                	jae    801851 <devfile_read+0x48>
  80183b:	68 a5 27 80 00       	push   $0x8027a5
  801840:	68 ac 27 80 00       	push   $0x8027ac
  801845:	6a 7c                	push   $0x7c
  801847:	68 9a 27 80 00       	push   $0x80279a
  80184c:	e8 fc e8 ff ff       	call   80014d <_panic>
	assert(r <= PGSIZE);
  801851:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801856:	7e 16                	jle    80186e <devfile_read+0x65>
  801858:	68 c1 27 80 00       	push   $0x8027c1
  80185d:	68 ac 27 80 00       	push   $0x8027ac
  801862:	6a 7d                	push   $0x7d
  801864:	68 9a 27 80 00       	push   $0x80279a
  801869:	e8 df e8 ff ff       	call   80014d <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80186e:	83 ec 04             	sub    $0x4,%esp
  801871:	50                   	push   %eax
  801872:	68 00 50 80 00       	push   $0x805000
  801877:	ff 75 0c             	pushl  0xc(%ebp)
  80187a:	e8 65 f1 ff ff       	call   8009e4 <memmove>
	return r;
  80187f:	83 c4 10             	add    $0x10,%esp
}
  801882:	89 d8                	mov    %ebx,%eax
  801884:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801887:	5b                   	pop    %ebx
  801888:	5e                   	pop    %esi
  801889:	5d                   	pop    %ebp
  80188a:	c3                   	ret    

0080188b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80188b:	55                   	push   %ebp
  80188c:	89 e5                	mov    %esp,%ebp
  80188e:	53                   	push   %ebx
  80188f:	83 ec 20             	sub    $0x20,%esp
  801892:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801895:	53                   	push   %ebx
  801896:	e8 7e ef ff ff       	call   800819 <strlen>
  80189b:	83 c4 10             	add    $0x10,%esp
  80189e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018a3:	7f 67                	jg     80190c <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018a5:	83 ec 0c             	sub    $0xc,%esp
  8018a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018ab:	50                   	push   %eax
  8018ac:	e8 c6 f8 ff ff       	call   801177 <fd_alloc>
  8018b1:	83 c4 10             	add    $0x10,%esp
		return r;
  8018b4:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018b6:	85 c0                	test   %eax,%eax
  8018b8:	78 57                	js     801911 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018ba:	83 ec 08             	sub    $0x8,%esp
  8018bd:	53                   	push   %ebx
  8018be:	68 00 50 80 00       	push   $0x805000
  8018c3:	e8 8a ef ff ff       	call   800852 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018cb:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018d3:	b8 01 00 00 00       	mov    $0x1,%eax
  8018d8:	e8 22 fe ff ff       	call   8016ff <fsipc>
  8018dd:	89 c3                	mov    %eax,%ebx
  8018df:	83 c4 10             	add    $0x10,%esp
  8018e2:	85 c0                	test   %eax,%eax
  8018e4:	79 14                	jns    8018fa <open+0x6f>
		fd_close(fd, 0);
  8018e6:	83 ec 08             	sub    $0x8,%esp
  8018e9:	6a 00                	push   $0x0
  8018eb:	ff 75 f4             	pushl  -0xc(%ebp)
  8018ee:	e8 7c f9 ff ff       	call   80126f <fd_close>
		return r;
  8018f3:	83 c4 10             	add    $0x10,%esp
  8018f6:	89 da                	mov    %ebx,%edx
  8018f8:	eb 17                	jmp    801911 <open+0x86>
	}

	return fd2num(fd);
  8018fa:	83 ec 0c             	sub    $0xc,%esp
  8018fd:	ff 75 f4             	pushl  -0xc(%ebp)
  801900:	e8 4b f8 ff ff       	call   801150 <fd2num>
  801905:	89 c2                	mov    %eax,%edx
  801907:	83 c4 10             	add    $0x10,%esp
  80190a:	eb 05                	jmp    801911 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80190c:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801911:	89 d0                	mov    %edx,%eax
  801913:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801916:	c9                   	leave  
  801917:	c3                   	ret    

00801918 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801918:	55                   	push   %ebp
  801919:	89 e5                	mov    %esp,%ebp
  80191b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80191e:	ba 00 00 00 00       	mov    $0x0,%edx
  801923:	b8 08 00 00 00       	mov    $0x8,%eax
  801928:	e8 d2 fd ff ff       	call   8016ff <fsipc>
}
  80192d:	c9                   	leave  
  80192e:	c3                   	ret    

0080192f <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80192f:	55                   	push   %ebp
  801930:	89 e5                	mov    %esp,%ebp
  801932:	56                   	push   %esi
  801933:	53                   	push   %ebx
  801934:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801937:	83 ec 0c             	sub    $0xc,%esp
  80193a:	ff 75 08             	pushl  0x8(%ebp)
  80193d:	e8 1e f8 ff ff       	call   801160 <fd2data>
  801942:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801944:	83 c4 08             	add    $0x8,%esp
  801947:	68 cd 27 80 00       	push   $0x8027cd
  80194c:	53                   	push   %ebx
  80194d:	e8 00 ef ff ff       	call   800852 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801952:	8b 46 04             	mov    0x4(%esi),%eax
  801955:	2b 06                	sub    (%esi),%eax
  801957:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80195d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801964:	00 00 00 
	stat->st_dev = &devpipe;
  801967:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80196e:	30 80 00 
	return 0;
}
  801971:	b8 00 00 00 00       	mov    $0x0,%eax
  801976:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801979:	5b                   	pop    %ebx
  80197a:	5e                   	pop    %esi
  80197b:	5d                   	pop    %ebp
  80197c:	c3                   	ret    

0080197d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80197d:	55                   	push   %ebp
  80197e:	89 e5                	mov    %esp,%ebp
  801980:	53                   	push   %ebx
  801981:	83 ec 0c             	sub    $0xc,%esp
  801984:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801987:	53                   	push   %ebx
  801988:	6a 00                	push   $0x0
  80198a:	e8 4b f3 ff ff       	call   800cda <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80198f:	89 1c 24             	mov    %ebx,(%esp)
  801992:	e8 c9 f7 ff ff       	call   801160 <fd2data>
  801997:	83 c4 08             	add    $0x8,%esp
  80199a:	50                   	push   %eax
  80199b:	6a 00                	push   $0x0
  80199d:	e8 38 f3 ff ff       	call   800cda <sys_page_unmap>
}
  8019a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019a5:	c9                   	leave  
  8019a6:	c3                   	ret    

008019a7 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8019a7:	55                   	push   %ebp
  8019a8:	89 e5                	mov    %esp,%ebp
  8019aa:	57                   	push   %edi
  8019ab:	56                   	push   %esi
  8019ac:	53                   	push   %ebx
  8019ad:	83 ec 1c             	sub    $0x1c,%esp
  8019b0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8019b3:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8019b5:	a1 08 40 80 00       	mov    0x804008,%eax
  8019ba:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8019bd:	83 ec 0c             	sub    $0xc,%esp
  8019c0:	ff 75 e0             	pushl  -0x20(%ebp)
  8019c3:	e8 b8 05 00 00       	call   801f80 <pageref>
  8019c8:	89 c3                	mov    %eax,%ebx
  8019ca:	89 3c 24             	mov    %edi,(%esp)
  8019cd:	e8 ae 05 00 00       	call   801f80 <pageref>
  8019d2:	83 c4 10             	add    $0x10,%esp
  8019d5:	39 c3                	cmp    %eax,%ebx
  8019d7:	0f 94 c1             	sete   %cl
  8019da:	0f b6 c9             	movzbl %cl,%ecx
  8019dd:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8019e0:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8019e6:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8019e9:	39 ce                	cmp    %ecx,%esi
  8019eb:	74 1b                	je     801a08 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8019ed:	39 c3                	cmp    %eax,%ebx
  8019ef:	75 c4                	jne    8019b5 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8019f1:	8b 42 58             	mov    0x58(%edx),%eax
  8019f4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8019f7:	50                   	push   %eax
  8019f8:	56                   	push   %esi
  8019f9:	68 d4 27 80 00       	push   $0x8027d4
  8019fe:	e8 23 e8 ff ff       	call   800226 <cprintf>
  801a03:	83 c4 10             	add    $0x10,%esp
  801a06:	eb ad                	jmp    8019b5 <_pipeisclosed+0xe>
	}
}
  801a08:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a0e:	5b                   	pop    %ebx
  801a0f:	5e                   	pop    %esi
  801a10:	5f                   	pop    %edi
  801a11:	5d                   	pop    %ebp
  801a12:	c3                   	ret    

00801a13 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a13:	55                   	push   %ebp
  801a14:	89 e5                	mov    %esp,%ebp
  801a16:	57                   	push   %edi
  801a17:	56                   	push   %esi
  801a18:	53                   	push   %ebx
  801a19:	83 ec 28             	sub    $0x28,%esp
  801a1c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a1f:	56                   	push   %esi
  801a20:	e8 3b f7 ff ff       	call   801160 <fd2data>
  801a25:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a27:	83 c4 10             	add    $0x10,%esp
  801a2a:	bf 00 00 00 00       	mov    $0x0,%edi
  801a2f:	eb 4b                	jmp    801a7c <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a31:	89 da                	mov    %ebx,%edx
  801a33:	89 f0                	mov    %esi,%eax
  801a35:	e8 6d ff ff ff       	call   8019a7 <_pipeisclosed>
  801a3a:	85 c0                	test   %eax,%eax
  801a3c:	75 48                	jne    801a86 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a3e:	e8 f3 f1 ff ff       	call   800c36 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a43:	8b 43 04             	mov    0x4(%ebx),%eax
  801a46:	8b 0b                	mov    (%ebx),%ecx
  801a48:	8d 51 20             	lea    0x20(%ecx),%edx
  801a4b:	39 d0                	cmp    %edx,%eax
  801a4d:	73 e2                	jae    801a31 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a4f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a52:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a56:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a59:	89 c2                	mov    %eax,%edx
  801a5b:	c1 fa 1f             	sar    $0x1f,%edx
  801a5e:	89 d1                	mov    %edx,%ecx
  801a60:	c1 e9 1b             	shr    $0x1b,%ecx
  801a63:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801a66:	83 e2 1f             	and    $0x1f,%edx
  801a69:	29 ca                	sub    %ecx,%edx
  801a6b:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801a6f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a73:	83 c0 01             	add    $0x1,%eax
  801a76:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a79:	83 c7 01             	add    $0x1,%edi
  801a7c:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a7f:	75 c2                	jne    801a43 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801a81:	8b 45 10             	mov    0x10(%ebp),%eax
  801a84:	eb 05                	jmp    801a8b <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a86:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801a8b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a8e:	5b                   	pop    %ebx
  801a8f:	5e                   	pop    %esi
  801a90:	5f                   	pop    %edi
  801a91:	5d                   	pop    %ebp
  801a92:	c3                   	ret    

00801a93 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a93:	55                   	push   %ebp
  801a94:	89 e5                	mov    %esp,%ebp
  801a96:	57                   	push   %edi
  801a97:	56                   	push   %esi
  801a98:	53                   	push   %ebx
  801a99:	83 ec 18             	sub    $0x18,%esp
  801a9c:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801a9f:	57                   	push   %edi
  801aa0:	e8 bb f6 ff ff       	call   801160 <fd2data>
  801aa5:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801aa7:	83 c4 10             	add    $0x10,%esp
  801aaa:	bb 00 00 00 00       	mov    $0x0,%ebx
  801aaf:	eb 3d                	jmp    801aee <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801ab1:	85 db                	test   %ebx,%ebx
  801ab3:	74 04                	je     801ab9 <devpipe_read+0x26>
				return i;
  801ab5:	89 d8                	mov    %ebx,%eax
  801ab7:	eb 44                	jmp    801afd <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ab9:	89 f2                	mov    %esi,%edx
  801abb:	89 f8                	mov    %edi,%eax
  801abd:	e8 e5 fe ff ff       	call   8019a7 <_pipeisclosed>
  801ac2:	85 c0                	test   %eax,%eax
  801ac4:	75 32                	jne    801af8 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801ac6:	e8 6b f1 ff ff       	call   800c36 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801acb:	8b 06                	mov    (%esi),%eax
  801acd:	3b 46 04             	cmp    0x4(%esi),%eax
  801ad0:	74 df                	je     801ab1 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801ad2:	99                   	cltd   
  801ad3:	c1 ea 1b             	shr    $0x1b,%edx
  801ad6:	01 d0                	add    %edx,%eax
  801ad8:	83 e0 1f             	and    $0x1f,%eax
  801adb:	29 d0                	sub    %edx,%eax
  801add:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801ae2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ae5:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801ae8:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801aeb:	83 c3 01             	add    $0x1,%ebx
  801aee:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801af1:	75 d8                	jne    801acb <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801af3:	8b 45 10             	mov    0x10(%ebp),%eax
  801af6:	eb 05                	jmp    801afd <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801af8:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801afd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b00:	5b                   	pop    %ebx
  801b01:	5e                   	pop    %esi
  801b02:	5f                   	pop    %edi
  801b03:	5d                   	pop    %ebp
  801b04:	c3                   	ret    

00801b05 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b05:	55                   	push   %ebp
  801b06:	89 e5                	mov    %esp,%ebp
  801b08:	56                   	push   %esi
  801b09:	53                   	push   %ebx
  801b0a:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b0d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b10:	50                   	push   %eax
  801b11:	e8 61 f6 ff ff       	call   801177 <fd_alloc>
  801b16:	83 c4 10             	add    $0x10,%esp
  801b19:	89 c2                	mov    %eax,%edx
  801b1b:	85 c0                	test   %eax,%eax
  801b1d:	0f 88 2c 01 00 00    	js     801c4f <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b23:	83 ec 04             	sub    $0x4,%esp
  801b26:	68 07 04 00 00       	push   $0x407
  801b2b:	ff 75 f4             	pushl  -0xc(%ebp)
  801b2e:	6a 00                	push   $0x0
  801b30:	e8 20 f1 ff ff       	call   800c55 <sys_page_alloc>
  801b35:	83 c4 10             	add    $0x10,%esp
  801b38:	89 c2                	mov    %eax,%edx
  801b3a:	85 c0                	test   %eax,%eax
  801b3c:	0f 88 0d 01 00 00    	js     801c4f <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b42:	83 ec 0c             	sub    $0xc,%esp
  801b45:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b48:	50                   	push   %eax
  801b49:	e8 29 f6 ff ff       	call   801177 <fd_alloc>
  801b4e:	89 c3                	mov    %eax,%ebx
  801b50:	83 c4 10             	add    $0x10,%esp
  801b53:	85 c0                	test   %eax,%eax
  801b55:	0f 88 e2 00 00 00    	js     801c3d <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b5b:	83 ec 04             	sub    $0x4,%esp
  801b5e:	68 07 04 00 00       	push   $0x407
  801b63:	ff 75 f0             	pushl  -0x10(%ebp)
  801b66:	6a 00                	push   $0x0
  801b68:	e8 e8 f0 ff ff       	call   800c55 <sys_page_alloc>
  801b6d:	89 c3                	mov    %eax,%ebx
  801b6f:	83 c4 10             	add    $0x10,%esp
  801b72:	85 c0                	test   %eax,%eax
  801b74:	0f 88 c3 00 00 00    	js     801c3d <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801b7a:	83 ec 0c             	sub    $0xc,%esp
  801b7d:	ff 75 f4             	pushl  -0xc(%ebp)
  801b80:	e8 db f5 ff ff       	call   801160 <fd2data>
  801b85:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b87:	83 c4 0c             	add    $0xc,%esp
  801b8a:	68 07 04 00 00       	push   $0x407
  801b8f:	50                   	push   %eax
  801b90:	6a 00                	push   $0x0
  801b92:	e8 be f0 ff ff       	call   800c55 <sys_page_alloc>
  801b97:	89 c3                	mov    %eax,%ebx
  801b99:	83 c4 10             	add    $0x10,%esp
  801b9c:	85 c0                	test   %eax,%eax
  801b9e:	0f 88 89 00 00 00    	js     801c2d <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ba4:	83 ec 0c             	sub    $0xc,%esp
  801ba7:	ff 75 f0             	pushl  -0x10(%ebp)
  801baa:	e8 b1 f5 ff ff       	call   801160 <fd2data>
  801baf:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801bb6:	50                   	push   %eax
  801bb7:	6a 00                	push   $0x0
  801bb9:	56                   	push   %esi
  801bba:	6a 00                	push   $0x0
  801bbc:	e8 d7 f0 ff ff       	call   800c98 <sys_page_map>
  801bc1:	89 c3                	mov    %eax,%ebx
  801bc3:	83 c4 20             	add    $0x20,%esp
  801bc6:	85 c0                	test   %eax,%eax
  801bc8:	78 55                	js     801c1f <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801bca:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bd3:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801bd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bd8:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801bdf:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801be5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801be8:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801bea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bed:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801bf4:	83 ec 0c             	sub    $0xc,%esp
  801bf7:	ff 75 f4             	pushl  -0xc(%ebp)
  801bfa:	e8 51 f5 ff ff       	call   801150 <fd2num>
  801bff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c02:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c04:	83 c4 04             	add    $0x4,%esp
  801c07:	ff 75 f0             	pushl  -0x10(%ebp)
  801c0a:	e8 41 f5 ff ff       	call   801150 <fd2num>
  801c0f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c12:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c15:	83 c4 10             	add    $0x10,%esp
  801c18:	ba 00 00 00 00       	mov    $0x0,%edx
  801c1d:	eb 30                	jmp    801c4f <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801c1f:	83 ec 08             	sub    $0x8,%esp
  801c22:	56                   	push   %esi
  801c23:	6a 00                	push   $0x0
  801c25:	e8 b0 f0 ff ff       	call   800cda <sys_page_unmap>
  801c2a:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c2d:	83 ec 08             	sub    $0x8,%esp
  801c30:	ff 75 f0             	pushl  -0x10(%ebp)
  801c33:	6a 00                	push   $0x0
  801c35:	e8 a0 f0 ff ff       	call   800cda <sys_page_unmap>
  801c3a:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c3d:	83 ec 08             	sub    $0x8,%esp
  801c40:	ff 75 f4             	pushl  -0xc(%ebp)
  801c43:	6a 00                	push   $0x0
  801c45:	e8 90 f0 ff ff       	call   800cda <sys_page_unmap>
  801c4a:	83 c4 10             	add    $0x10,%esp
  801c4d:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801c4f:	89 d0                	mov    %edx,%eax
  801c51:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c54:	5b                   	pop    %ebx
  801c55:	5e                   	pop    %esi
  801c56:	5d                   	pop    %ebp
  801c57:	c3                   	ret    

00801c58 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c58:	55                   	push   %ebp
  801c59:	89 e5                	mov    %esp,%ebp
  801c5b:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c5e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c61:	50                   	push   %eax
  801c62:	ff 75 08             	pushl  0x8(%ebp)
  801c65:	e8 5c f5 ff ff       	call   8011c6 <fd_lookup>
  801c6a:	83 c4 10             	add    $0x10,%esp
  801c6d:	85 c0                	test   %eax,%eax
  801c6f:	78 18                	js     801c89 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801c71:	83 ec 0c             	sub    $0xc,%esp
  801c74:	ff 75 f4             	pushl  -0xc(%ebp)
  801c77:	e8 e4 f4 ff ff       	call   801160 <fd2data>
	return _pipeisclosed(fd, p);
  801c7c:	89 c2                	mov    %eax,%edx
  801c7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c81:	e8 21 fd ff ff       	call   8019a7 <_pipeisclosed>
  801c86:	83 c4 10             	add    $0x10,%esp
}
  801c89:	c9                   	leave  
  801c8a:	c3                   	ret    

00801c8b <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c8b:	55                   	push   %ebp
  801c8c:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801c8e:	b8 00 00 00 00       	mov    $0x0,%eax
  801c93:	5d                   	pop    %ebp
  801c94:	c3                   	ret    

00801c95 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c95:	55                   	push   %ebp
  801c96:	89 e5                	mov    %esp,%ebp
  801c98:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801c9b:	68 ec 27 80 00       	push   $0x8027ec
  801ca0:	ff 75 0c             	pushl  0xc(%ebp)
  801ca3:	e8 aa eb ff ff       	call   800852 <strcpy>
	return 0;
}
  801ca8:	b8 00 00 00 00       	mov    $0x0,%eax
  801cad:	c9                   	leave  
  801cae:	c3                   	ret    

00801caf <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801caf:	55                   	push   %ebp
  801cb0:	89 e5                	mov    %esp,%ebp
  801cb2:	57                   	push   %edi
  801cb3:	56                   	push   %esi
  801cb4:	53                   	push   %ebx
  801cb5:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801cbb:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801cc0:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801cc6:	eb 2d                	jmp    801cf5 <devcons_write+0x46>
		m = n - tot;
  801cc8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ccb:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801ccd:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801cd0:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801cd5:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801cd8:	83 ec 04             	sub    $0x4,%esp
  801cdb:	53                   	push   %ebx
  801cdc:	03 45 0c             	add    0xc(%ebp),%eax
  801cdf:	50                   	push   %eax
  801ce0:	57                   	push   %edi
  801ce1:	e8 fe ec ff ff       	call   8009e4 <memmove>
		sys_cputs(buf, m);
  801ce6:	83 c4 08             	add    $0x8,%esp
  801ce9:	53                   	push   %ebx
  801cea:	57                   	push   %edi
  801ceb:	e8 a9 ee ff ff       	call   800b99 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801cf0:	01 de                	add    %ebx,%esi
  801cf2:	83 c4 10             	add    $0x10,%esp
  801cf5:	89 f0                	mov    %esi,%eax
  801cf7:	3b 75 10             	cmp    0x10(%ebp),%esi
  801cfa:	72 cc                	jb     801cc8 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801cfc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cff:	5b                   	pop    %ebx
  801d00:	5e                   	pop    %esi
  801d01:	5f                   	pop    %edi
  801d02:	5d                   	pop    %ebp
  801d03:	c3                   	ret    

00801d04 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d04:	55                   	push   %ebp
  801d05:	89 e5                	mov    %esp,%ebp
  801d07:	83 ec 08             	sub    $0x8,%esp
  801d0a:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801d0f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d13:	74 2a                	je     801d3f <devcons_read+0x3b>
  801d15:	eb 05                	jmp    801d1c <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d17:	e8 1a ef ff ff       	call   800c36 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d1c:	e8 96 ee ff ff       	call   800bb7 <sys_cgetc>
  801d21:	85 c0                	test   %eax,%eax
  801d23:	74 f2                	je     801d17 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801d25:	85 c0                	test   %eax,%eax
  801d27:	78 16                	js     801d3f <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d29:	83 f8 04             	cmp    $0x4,%eax
  801d2c:	74 0c                	je     801d3a <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801d2e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d31:	88 02                	mov    %al,(%edx)
	return 1;
  801d33:	b8 01 00 00 00       	mov    $0x1,%eax
  801d38:	eb 05                	jmp    801d3f <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801d3a:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801d3f:	c9                   	leave  
  801d40:	c3                   	ret    

00801d41 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801d41:	55                   	push   %ebp
  801d42:	89 e5                	mov    %esp,%ebp
  801d44:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801d47:	8b 45 08             	mov    0x8(%ebp),%eax
  801d4a:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801d4d:	6a 01                	push   $0x1
  801d4f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d52:	50                   	push   %eax
  801d53:	e8 41 ee ff ff       	call   800b99 <sys_cputs>
}
  801d58:	83 c4 10             	add    $0x10,%esp
  801d5b:	c9                   	leave  
  801d5c:	c3                   	ret    

00801d5d <getchar>:

int
getchar(void)
{
  801d5d:	55                   	push   %ebp
  801d5e:	89 e5                	mov    %esp,%ebp
  801d60:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801d63:	6a 01                	push   $0x1
  801d65:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d68:	50                   	push   %eax
  801d69:	6a 00                	push   $0x0
  801d6b:	e8 bc f6 ff ff       	call   80142c <read>
	if (r < 0)
  801d70:	83 c4 10             	add    $0x10,%esp
  801d73:	85 c0                	test   %eax,%eax
  801d75:	78 0f                	js     801d86 <getchar+0x29>
		return r;
	if (r < 1)
  801d77:	85 c0                	test   %eax,%eax
  801d79:	7e 06                	jle    801d81 <getchar+0x24>
		return -E_EOF;
	return c;
  801d7b:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801d7f:	eb 05                	jmp    801d86 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801d81:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801d86:	c9                   	leave  
  801d87:	c3                   	ret    

00801d88 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801d88:	55                   	push   %ebp
  801d89:	89 e5                	mov    %esp,%ebp
  801d8b:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d8e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d91:	50                   	push   %eax
  801d92:	ff 75 08             	pushl  0x8(%ebp)
  801d95:	e8 2c f4 ff ff       	call   8011c6 <fd_lookup>
  801d9a:	83 c4 10             	add    $0x10,%esp
  801d9d:	85 c0                	test   %eax,%eax
  801d9f:	78 11                	js     801db2 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801da1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801da4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801daa:	39 10                	cmp    %edx,(%eax)
  801dac:	0f 94 c0             	sete   %al
  801daf:	0f b6 c0             	movzbl %al,%eax
}
  801db2:	c9                   	leave  
  801db3:	c3                   	ret    

00801db4 <opencons>:

int
opencons(void)
{
  801db4:	55                   	push   %ebp
  801db5:	89 e5                	mov    %esp,%ebp
  801db7:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801dba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dbd:	50                   	push   %eax
  801dbe:	e8 b4 f3 ff ff       	call   801177 <fd_alloc>
  801dc3:	83 c4 10             	add    $0x10,%esp
		return r;
  801dc6:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801dc8:	85 c0                	test   %eax,%eax
  801dca:	78 3e                	js     801e0a <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801dcc:	83 ec 04             	sub    $0x4,%esp
  801dcf:	68 07 04 00 00       	push   $0x407
  801dd4:	ff 75 f4             	pushl  -0xc(%ebp)
  801dd7:	6a 00                	push   $0x0
  801dd9:	e8 77 ee ff ff       	call   800c55 <sys_page_alloc>
  801dde:	83 c4 10             	add    $0x10,%esp
		return r;
  801de1:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801de3:	85 c0                	test   %eax,%eax
  801de5:	78 23                	js     801e0a <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801de7:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ded:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801df0:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801df2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801df5:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801dfc:	83 ec 0c             	sub    $0xc,%esp
  801dff:	50                   	push   %eax
  801e00:	e8 4b f3 ff ff       	call   801150 <fd2num>
  801e05:	89 c2                	mov    %eax,%edx
  801e07:	83 c4 10             	add    $0x10,%esp
}
  801e0a:	89 d0                	mov    %edx,%eax
  801e0c:	c9                   	leave  
  801e0d:	c3                   	ret    

00801e0e <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801e0e:	55                   	push   %ebp
  801e0f:	89 e5                	mov    %esp,%ebp
  801e11:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801e14:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801e1b:	75 31                	jne    801e4e <set_pgfault_handler+0x40>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc(thisenv->env_id, (void*)(UXSTACKTOP - PGSIZE), PTE_P | 
  801e1d:	a1 08 40 80 00       	mov    0x804008,%eax
  801e22:	8b 40 48             	mov    0x48(%eax),%eax
  801e25:	83 ec 04             	sub    $0x4,%esp
  801e28:	6a 07                	push   $0x7
  801e2a:	68 00 f0 bf ee       	push   $0xeebff000
  801e2f:	50                   	push   %eax
  801e30:	e8 20 ee ff ff       	call   800c55 <sys_page_alloc>
				PTE_U | PTE_W);
		sys_env_set_pgfault_upcall(thisenv->env_id, (void*)_pgfault_upcall);
  801e35:	a1 08 40 80 00       	mov    0x804008,%eax
  801e3a:	8b 40 48             	mov    0x48(%eax),%eax
  801e3d:	83 c4 08             	add    $0x8,%esp
  801e40:	68 58 1e 80 00       	push   $0x801e58
  801e45:	50                   	push   %eax
  801e46:	e8 55 ef ff ff       	call   800da0 <sys_env_set_pgfault_upcall>
  801e4b:	83 c4 10             	add    $0x10,%esp

		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801e4e:	8b 45 08             	mov    0x8(%ebp),%eax
  801e51:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801e56:	c9                   	leave  
  801e57:	c3                   	ret    

00801e58 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e58:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e59:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e5e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e60:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	addl $8, %esp      // pop utf_fault_va and utf_err
  801e63:	83 c4 08             	add    $0x8,%esp
	movl 32(%esp), %eax  // eax <- [esp + 32]
  801e66:	8b 44 24 20          	mov    0x20(%esp),%eax
	movl 40(%esp), %ebx  // ebx <- [esp + 40]
  801e6a:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	leal -4(%ebx), %ebx  // ebx <- ebx - 4
  801e6e:	8d 5b fc             	lea    -0x4(%ebx),%ebx
	movl %eax, (%ebx)
  801e71:	89 03                	mov    %eax,(%ebx)
	movl %ebx, 40(%esp)  // push trap eip and decrement trap esp manually
  801e73:	89 5c 24 28          	mov    %ebx,0x28(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  801e77:	61                   	popa   
	addl $4, %esp        // skip eip
  801e78:	83 c4 04             	add    $0x4,%esp

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	popf
  801e7b:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	pop %esp
  801e7c:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801e7d:	c3                   	ret    

00801e7e <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e7e:	55                   	push   %ebp
  801e7f:	89 e5                	mov    %esp,%ebp
  801e81:	56                   	push   %esi
  801e82:	53                   	push   %ebx
  801e83:	8b 75 08             	mov    0x8(%ebp),%esi
  801e86:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e89:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int ret;
	if (pg) ret = sys_ipc_recv(pg);
  801e8c:	85 c0                	test   %eax,%eax
  801e8e:	74 0e                	je     801e9e <ipc_recv+0x20>
  801e90:	83 ec 0c             	sub    $0xc,%esp
  801e93:	50                   	push   %eax
  801e94:	e8 6c ef ff ff       	call   800e05 <sys_ipc_recv>
  801e99:	83 c4 10             	add    $0x10,%esp
  801e9c:	eb 10                	jmp    801eae <ipc_recv+0x30>
	else ret = sys_ipc_recv((void*)UTOP);
  801e9e:	83 ec 0c             	sub    $0xc,%esp
  801ea1:	68 00 00 c0 ee       	push   $0xeec00000
  801ea6:	e8 5a ef ff ff       	call   800e05 <sys_ipc_recv>
  801eab:	83 c4 10             	add    $0x10,%esp
	if (ret) {
  801eae:	85 c0                	test   %eax,%eax
  801eb0:	74 16                	je     801ec8 <ipc_recv+0x4a>
		if (from_env_store) *from_env_store = 0;
  801eb2:	85 f6                	test   %esi,%esi
  801eb4:	74 06                	je     801ebc <ipc_recv+0x3e>
  801eb6:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  801ebc:	85 db                	test   %ebx,%ebx
  801ebe:	74 2c                	je     801eec <ipc_recv+0x6e>
  801ec0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801ec6:	eb 24                	jmp    801eec <ipc_recv+0x6e>
		return ret;
	}
	if (from_env_store) *from_env_store = thisenv->env_ipc_from;
  801ec8:	85 f6                	test   %esi,%esi
  801eca:	74 0a                	je     801ed6 <ipc_recv+0x58>
  801ecc:	a1 08 40 80 00       	mov    0x804008,%eax
  801ed1:	8b 40 74             	mov    0x74(%eax),%eax
  801ed4:	89 06                	mov    %eax,(%esi)
	if (perm_store) *perm_store = thisenv->env_ipc_perm;
  801ed6:	85 db                	test   %ebx,%ebx
  801ed8:	74 0a                	je     801ee4 <ipc_recv+0x66>
  801eda:	a1 08 40 80 00       	mov    0x804008,%eax
  801edf:	8b 40 78             	mov    0x78(%eax),%eax
  801ee2:	89 03                	mov    %eax,(%ebx)

	// panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801ee4:	a1 08 40 80 00       	mov    0x804008,%eax
  801ee9:	8b 40 70             	mov    0x70(%eax),%eax
}
  801eec:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801eef:	5b                   	pop    %ebx
  801ef0:	5e                   	pop    %esi
  801ef1:	5d                   	pop    %ebp
  801ef2:	c3                   	ret    

00801ef3 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ef3:	55                   	push   %ebp
  801ef4:	89 e5                	mov    %esp,%ebp
  801ef6:	57                   	push   %edi
  801ef7:	56                   	push   %esi
  801ef8:	53                   	push   %ebx
  801ef9:	83 ec 0c             	sub    $0xc,%esp
  801efc:	8b 7d 08             	mov    0x8(%ebp),%edi
  801eff:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f02:	8b 45 10             	mov    0x10(%ebp),%eax
  801f05:	85 c0                	test   %eax,%eax
  801f07:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801f0c:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	while (true) {
		void* srcva = (pg)? pg: (void*)UTOP;
		int ret = sys_ipc_try_send(to_env, val, srcva, perm);
  801f0f:	ff 75 14             	pushl  0x14(%ebp)
  801f12:	53                   	push   %ebx
  801f13:	56                   	push   %esi
  801f14:	57                   	push   %edi
  801f15:	e8 c8 ee ff ff       	call   800de2 <sys_ipc_try_send>
		if (ret == 0) break;
  801f1a:	83 c4 10             	add    $0x10,%esp
  801f1d:	85 c0                	test   %eax,%eax
  801f1f:	74 1e                	je     801f3f <ipc_send+0x4c>
		if (ret != -E_IPC_NOT_RECV) panic("ipc_send: %e", ret);
  801f21:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f24:	74 12                	je     801f38 <ipc_send+0x45>
  801f26:	50                   	push   %eax
  801f27:	68 f8 27 80 00       	push   $0x8027f8
  801f2c:	6a 39                	push   $0x39
  801f2e:	68 05 28 80 00       	push   $0x802805
  801f33:	e8 15 e2 ff ff       	call   80014d <_panic>
		sys_yield();
  801f38:	e8 f9 ec ff ff       	call   800c36 <sys_yield>
	}
  801f3d:	eb d0                	jmp    801f0f <ipc_send+0x1c>
	// panic("ipc_send not implemented");
}
  801f3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f42:	5b                   	pop    %ebx
  801f43:	5e                   	pop    %esi
  801f44:	5f                   	pop    %edi
  801f45:	5d                   	pop    %ebp
  801f46:	c3                   	ret    

00801f47 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f47:	55                   	push   %ebp
  801f48:	89 e5                	mov    %esp,%ebp
  801f4a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f4d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f52:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f55:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f5b:	8b 52 50             	mov    0x50(%edx),%edx
  801f5e:	39 ca                	cmp    %ecx,%edx
  801f60:	75 0d                	jne    801f6f <ipc_find_env+0x28>
			return envs[i].env_id;
  801f62:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f65:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f6a:	8b 40 48             	mov    0x48(%eax),%eax
  801f6d:	eb 0f                	jmp    801f7e <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f6f:	83 c0 01             	add    $0x1,%eax
  801f72:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f77:	75 d9                	jne    801f52 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f79:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f7e:	5d                   	pop    %ebp
  801f7f:	c3                   	ret    

00801f80 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f80:	55                   	push   %ebp
  801f81:	89 e5                	mov    %esp,%ebp
  801f83:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f86:	89 d0                	mov    %edx,%eax
  801f88:	c1 e8 16             	shr    $0x16,%eax
  801f8b:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f92:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f97:	f6 c1 01             	test   $0x1,%cl
  801f9a:	74 1d                	je     801fb9 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f9c:	c1 ea 0c             	shr    $0xc,%edx
  801f9f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fa6:	f6 c2 01             	test   $0x1,%dl
  801fa9:	74 0e                	je     801fb9 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fab:	c1 ea 0c             	shr    $0xc,%edx
  801fae:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fb5:	ef 
  801fb6:	0f b7 c0             	movzwl %ax,%eax
}
  801fb9:	5d                   	pop    %ebp
  801fba:	c3                   	ret    
  801fbb:	66 90                	xchg   %ax,%ax
  801fbd:	66 90                	xchg   %ax,%ax
  801fbf:	90                   	nop

00801fc0 <__udivdi3>:
  801fc0:	55                   	push   %ebp
  801fc1:	57                   	push   %edi
  801fc2:	56                   	push   %esi
  801fc3:	53                   	push   %ebx
  801fc4:	83 ec 1c             	sub    $0x1c,%esp
  801fc7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801fcb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801fcf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801fd3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801fd7:	85 f6                	test   %esi,%esi
  801fd9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fdd:	89 ca                	mov    %ecx,%edx
  801fdf:	89 f8                	mov    %edi,%eax
  801fe1:	75 3d                	jne    802020 <__udivdi3+0x60>
  801fe3:	39 cf                	cmp    %ecx,%edi
  801fe5:	0f 87 c5 00 00 00    	ja     8020b0 <__udivdi3+0xf0>
  801feb:	85 ff                	test   %edi,%edi
  801fed:	89 fd                	mov    %edi,%ebp
  801fef:	75 0b                	jne    801ffc <__udivdi3+0x3c>
  801ff1:	b8 01 00 00 00       	mov    $0x1,%eax
  801ff6:	31 d2                	xor    %edx,%edx
  801ff8:	f7 f7                	div    %edi
  801ffa:	89 c5                	mov    %eax,%ebp
  801ffc:	89 c8                	mov    %ecx,%eax
  801ffe:	31 d2                	xor    %edx,%edx
  802000:	f7 f5                	div    %ebp
  802002:	89 c1                	mov    %eax,%ecx
  802004:	89 d8                	mov    %ebx,%eax
  802006:	89 cf                	mov    %ecx,%edi
  802008:	f7 f5                	div    %ebp
  80200a:	89 c3                	mov    %eax,%ebx
  80200c:	89 d8                	mov    %ebx,%eax
  80200e:	89 fa                	mov    %edi,%edx
  802010:	83 c4 1c             	add    $0x1c,%esp
  802013:	5b                   	pop    %ebx
  802014:	5e                   	pop    %esi
  802015:	5f                   	pop    %edi
  802016:	5d                   	pop    %ebp
  802017:	c3                   	ret    
  802018:	90                   	nop
  802019:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802020:	39 ce                	cmp    %ecx,%esi
  802022:	77 74                	ja     802098 <__udivdi3+0xd8>
  802024:	0f bd fe             	bsr    %esi,%edi
  802027:	83 f7 1f             	xor    $0x1f,%edi
  80202a:	0f 84 98 00 00 00    	je     8020c8 <__udivdi3+0x108>
  802030:	bb 20 00 00 00       	mov    $0x20,%ebx
  802035:	89 f9                	mov    %edi,%ecx
  802037:	89 c5                	mov    %eax,%ebp
  802039:	29 fb                	sub    %edi,%ebx
  80203b:	d3 e6                	shl    %cl,%esi
  80203d:	89 d9                	mov    %ebx,%ecx
  80203f:	d3 ed                	shr    %cl,%ebp
  802041:	89 f9                	mov    %edi,%ecx
  802043:	d3 e0                	shl    %cl,%eax
  802045:	09 ee                	or     %ebp,%esi
  802047:	89 d9                	mov    %ebx,%ecx
  802049:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80204d:	89 d5                	mov    %edx,%ebp
  80204f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802053:	d3 ed                	shr    %cl,%ebp
  802055:	89 f9                	mov    %edi,%ecx
  802057:	d3 e2                	shl    %cl,%edx
  802059:	89 d9                	mov    %ebx,%ecx
  80205b:	d3 e8                	shr    %cl,%eax
  80205d:	09 c2                	or     %eax,%edx
  80205f:	89 d0                	mov    %edx,%eax
  802061:	89 ea                	mov    %ebp,%edx
  802063:	f7 f6                	div    %esi
  802065:	89 d5                	mov    %edx,%ebp
  802067:	89 c3                	mov    %eax,%ebx
  802069:	f7 64 24 0c          	mull   0xc(%esp)
  80206d:	39 d5                	cmp    %edx,%ebp
  80206f:	72 10                	jb     802081 <__udivdi3+0xc1>
  802071:	8b 74 24 08          	mov    0x8(%esp),%esi
  802075:	89 f9                	mov    %edi,%ecx
  802077:	d3 e6                	shl    %cl,%esi
  802079:	39 c6                	cmp    %eax,%esi
  80207b:	73 07                	jae    802084 <__udivdi3+0xc4>
  80207d:	39 d5                	cmp    %edx,%ebp
  80207f:	75 03                	jne    802084 <__udivdi3+0xc4>
  802081:	83 eb 01             	sub    $0x1,%ebx
  802084:	31 ff                	xor    %edi,%edi
  802086:	89 d8                	mov    %ebx,%eax
  802088:	89 fa                	mov    %edi,%edx
  80208a:	83 c4 1c             	add    $0x1c,%esp
  80208d:	5b                   	pop    %ebx
  80208e:	5e                   	pop    %esi
  80208f:	5f                   	pop    %edi
  802090:	5d                   	pop    %ebp
  802091:	c3                   	ret    
  802092:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802098:	31 ff                	xor    %edi,%edi
  80209a:	31 db                	xor    %ebx,%ebx
  80209c:	89 d8                	mov    %ebx,%eax
  80209e:	89 fa                	mov    %edi,%edx
  8020a0:	83 c4 1c             	add    $0x1c,%esp
  8020a3:	5b                   	pop    %ebx
  8020a4:	5e                   	pop    %esi
  8020a5:	5f                   	pop    %edi
  8020a6:	5d                   	pop    %ebp
  8020a7:	c3                   	ret    
  8020a8:	90                   	nop
  8020a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020b0:	89 d8                	mov    %ebx,%eax
  8020b2:	f7 f7                	div    %edi
  8020b4:	31 ff                	xor    %edi,%edi
  8020b6:	89 c3                	mov    %eax,%ebx
  8020b8:	89 d8                	mov    %ebx,%eax
  8020ba:	89 fa                	mov    %edi,%edx
  8020bc:	83 c4 1c             	add    $0x1c,%esp
  8020bf:	5b                   	pop    %ebx
  8020c0:	5e                   	pop    %esi
  8020c1:	5f                   	pop    %edi
  8020c2:	5d                   	pop    %ebp
  8020c3:	c3                   	ret    
  8020c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020c8:	39 ce                	cmp    %ecx,%esi
  8020ca:	72 0c                	jb     8020d8 <__udivdi3+0x118>
  8020cc:	31 db                	xor    %ebx,%ebx
  8020ce:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8020d2:	0f 87 34 ff ff ff    	ja     80200c <__udivdi3+0x4c>
  8020d8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8020dd:	e9 2a ff ff ff       	jmp    80200c <__udivdi3+0x4c>
  8020e2:	66 90                	xchg   %ax,%ax
  8020e4:	66 90                	xchg   %ax,%ax
  8020e6:	66 90                	xchg   %ax,%ax
  8020e8:	66 90                	xchg   %ax,%ax
  8020ea:	66 90                	xchg   %ax,%ax
  8020ec:	66 90                	xchg   %ax,%ax
  8020ee:	66 90                	xchg   %ax,%ax

008020f0 <__umoddi3>:
  8020f0:	55                   	push   %ebp
  8020f1:	57                   	push   %edi
  8020f2:	56                   	push   %esi
  8020f3:	53                   	push   %ebx
  8020f4:	83 ec 1c             	sub    $0x1c,%esp
  8020f7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8020fb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8020ff:	8b 74 24 34          	mov    0x34(%esp),%esi
  802103:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802107:	85 d2                	test   %edx,%edx
  802109:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80210d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802111:	89 f3                	mov    %esi,%ebx
  802113:	89 3c 24             	mov    %edi,(%esp)
  802116:	89 74 24 04          	mov    %esi,0x4(%esp)
  80211a:	75 1c                	jne    802138 <__umoddi3+0x48>
  80211c:	39 f7                	cmp    %esi,%edi
  80211e:	76 50                	jbe    802170 <__umoddi3+0x80>
  802120:	89 c8                	mov    %ecx,%eax
  802122:	89 f2                	mov    %esi,%edx
  802124:	f7 f7                	div    %edi
  802126:	89 d0                	mov    %edx,%eax
  802128:	31 d2                	xor    %edx,%edx
  80212a:	83 c4 1c             	add    $0x1c,%esp
  80212d:	5b                   	pop    %ebx
  80212e:	5e                   	pop    %esi
  80212f:	5f                   	pop    %edi
  802130:	5d                   	pop    %ebp
  802131:	c3                   	ret    
  802132:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802138:	39 f2                	cmp    %esi,%edx
  80213a:	89 d0                	mov    %edx,%eax
  80213c:	77 52                	ja     802190 <__umoddi3+0xa0>
  80213e:	0f bd ea             	bsr    %edx,%ebp
  802141:	83 f5 1f             	xor    $0x1f,%ebp
  802144:	75 5a                	jne    8021a0 <__umoddi3+0xb0>
  802146:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80214a:	0f 82 e0 00 00 00    	jb     802230 <__umoddi3+0x140>
  802150:	39 0c 24             	cmp    %ecx,(%esp)
  802153:	0f 86 d7 00 00 00    	jbe    802230 <__umoddi3+0x140>
  802159:	8b 44 24 08          	mov    0x8(%esp),%eax
  80215d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802161:	83 c4 1c             	add    $0x1c,%esp
  802164:	5b                   	pop    %ebx
  802165:	5e                   	pop    %esi
  802166:	5f                   	pop    %edi
  802167:	5d                   	pop    %ebp
  802168:	c3                   	ret    
  802169:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802170:	85 ff                	test   %edi,%edi
  802172:	89 fd                	mov    %edi,%ebp
  802174:	75 0b                	jne    802181 <__umoddi3+0x91>
  802176:	b8 01 00 00 00       	mov    $0x1,%eax
  80217b:	31 d2                	xor    %edx,%edx
  80217d:	f7 f7                	div    %edi
  80217f:	89 c5                	mov    %eax,%ebp
  802181:	89 f0                	mov    %esi,%eax
  802183:	31 d2                	xor    %edx,%edx
  802185:	f7 f5                	div    %ebp
  802187:	89 c8                	mov    %ecx,%eax
  802189:	f7 f5                	div    %ebp
  80218b:	89 d0                	mov    %edx,%eax
  80218d:	eb 99                	jmp    802128 <__umoddi3+0x38>
  80218f:	90                   	nop
  802190:	89 c8                	mov    %ecx,%eax
  802192:	89 f2                	mov    %esi,%edx
  802194:	83 c4 1c             	add    $0x1c,%esp
  802197:	5b                   	pop    %ebx
  802198:	5e                   	pop    %esi
  802199:	5f                   	pop    %edi
  80219a:	5d                   	pop    %ebp
  80219b:	c3                   	ret    
  80219c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021a0:	8b 34 24             	mov    (%esp),%esi
  8021a3:	bf 20 00 00 00       	mov    $0x20,%edi
  8021a8:	89 e9                	mov    %ebp,%ecx
  8021aa:	29 ef                	sub    %ebp,%edi
  8021ac:	d3 e0                	shl    %cl,%eax
  8021ae:	89 f9                	mov    %edi,%ecx
  8021b0:	89 f2                	mov    %esi,%edx
  8021b2:	d3 ea                	shr    %cl,%edx
  8021b4:	89 e9                	mov    %ebp,%ecx
  8021b6:	09 c2                	or     %eax,%edx
  8021b8:	89 d8                	mov    %ebx,%eax
  8021ba:	89 14 24             	mov    %edx,(%esp)
  8021bd:	89 f2                	mov    %esi,%edx
  8021bf:	d3 e2                	shl    %cl,%edx
  8021c1:	89 f9                	mov    %edi,%ecx
  8021c3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021c7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8021cb:	d3 e8                	shr    %cl,%eax
  8021cd:	89 e9                	mov    %ebp,%ecx
  8021cf:	89 c6                	mov    %eax,%esi
  8021d1:	d3 e3                	shl    %cl,%ebx
  8021d3:	89 f9                	mov    %edi,%ecx
  8021d5:	89 d0                	mov    %edx,%eax
  8021d7:	d3 e8                	shr    %cl,%eax
  8021d9:	89 e9                	mov    %ebp,%ecx
  8021db:	09 d8                	or     %ebx,%eax
  8021dd:	89 d3                	mov    %edx,%ebx
  8021df:	89 f2                	mov    %esi,%edx
  8021e1:	f7 34 24             	divl   (%esp)
  8021e4:	89 d6                	mov    %edx,%esi
  8021e6:	d3 e3                	shl    %cl,%ebx
  8021e8:	f7 64 24 04          	mull   0x4(%esp)
  8021ec:	39 d6                	cmp    %edx,%esi
  8021ee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021f2:	89 d1                	mov    %edx,%ecx
  8021f4:	89 c3                	mov    %eax,%ebx
  8021f6:	72 08                	jb     802200 <__umoddi3+0x110>
  8021f8:	75 11                	jne    80220b <__umoddi3+0x11b>
  8021fa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8021fe:	73 0b                	jae    80220b <__umoddi3+0x11b>
  802200:	2b 44 24 04          	sub    0x4(%esp),%eax
  802204:	1b 14 24             	sbb    (%esp),%edx
  802207:	89 d1                	mov    %edx,%ecx
  802209:	89 c3                	mov    %eax,%ebx
  80220b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80220f:	29 da                	sub    %ebx,%edx
  802211:	19 ce                	sbb    %ecx,%esi
  802213:	89 f9                	mov    %edi,%ecx
  802215:	89 f0                	mov    %esi,%eax
  802217:	d3 e0                	shl    %cl,%eax
  802219:	89 e9                	mov    %ebp,%ecx
  80221b:	d3 ea                	shr    %cl,%edx
  80221d:	89 e9                	mov    %ebp,%ecx
  80221f:	d3 ee                	shr    %cl,%esi
  802221:	09 d0                	or     %edx,%eax
  802223:	89 f2                	mov    %esi,%edx
  802225:	83 c4 1c             	add    $0x1c,%esp
  802228:	5b                   	pop    %ebx
  802229:	5e                   	pop    %esi
  80222a:	5f                   	pop    %edi
  80222b:	5d                   	pop    %ebp
  80222c:	c3                   	ret    
  80222d:	8d 76 00             	lea    0x0(%esi),%esi
  802230:	29 f9                	sub    %edi,%ecx
  802232:	19 d6                	sbb    %edx,%esi
  802234:	89 74 24 04          	mov    %esi,0x4(%esp)
  802238:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80223c:	e9 18 ff ff ff       	jmp    802159 <__umoddi3+0x69>
