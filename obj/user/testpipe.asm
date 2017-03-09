
obj/user/testpipe.debug:     file format elf32-i386


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
  80002c:	e8 81 02 00 00       	call   8002b2 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

char *msg = "Now is the time for all good men to come to the aid of their party.";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 7c             	sub    $0x7c,%esp
	char buf[100];
	int i, pid, p[2];

	binaryname = "pipereadeof";
  80003b:	c7 05 04 30 80 00 60 	movl   $0x802460,0x803004
  800042:	24 80 00 

	if ((i = pipe(p)) < 0)
  800045:	8d 45 8c             	lea    -0x74(%ebp),%eax
  800048:	50                   	push   %eax
  800049:	e8 7c 1c 00 00       	call   801cca <pipe>
  80004e:	89 c6                	mov    %eax,%esi
  800050:	83 c4 10             	add    $0x10,%esp
  800053:	85 c0                	test   %eax,%eax
  800055:	79 12                	jns    800069 <umain+0x36>
		panic("pipe: %e", i);
  800057:	50                   	push   %eax
  800058:	68 6c 24 80 00       	push   $0x80246c
  80005d:	6a 0e                	push   $0xe
  80005f:	68 75 24 80 00       	push   $0x802475
  800064:	e8 a9 02 00 00       	call   800312 <_panic>

	if ((pid = fork()) < 0)
  800069:	e8 4a 11 00 00       	call   8011b8 <fork>
  80006e:	89 c3                	mov    %eax,%ebx
  800070:	85 c0                	test   %eax,%eax
  800072:	79 12                	jns    800086 <umain+0x53>
		panic("fork: %e", i);
  800074:	56                   	push   %esi
  800075:	68 85 24 80 00       	push   $0x802485
  80007a:	6a 11                	push   $0x11
  80007c:	68 75 24 80 00       	push   $0x802475
  800081:	e8 8c 02 00 00       	call   800312 <_panic>

	if (pid == 0) {
  800086:	85 c0                	test   %eax,%eax
  800088:	0f 85 b8 00 00 00    	jne    800146 <umain+0x113>
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[1]);
  80008e:	a1 04 40 80 00       	mov    0x804004,%eax
  800093:	8b 40 48             	mov    0x48(%eax),%eax
  800096:	83 ec 04             	sub    $0x4,%esp
  800099:	ff 75 90             	pushl  -0x70(%ebp)
  80009c:	50                   	push   %eax
  80009d:	68 8e 24 80 00       	push   $0x80248e
  8000a2:	e8 44 03 00 00       	call   8003eb <cprintf>
		close(p[1]);
  8000a7:	83 c4 04             	add    $0x4,%esp
  8000aa:	ff 75 90             	pushl  -0x70(%ebp)
  8000ad:	e8 03 14 00 00       	call   8014b5 <close>
		cprintf("[%08x] pipereadeof readn %d\n", thisenv->env_id, p[0]);
  8000b2:	a1 04 40 80 00       	mov    0x804004,%eax
  8000b7:	8b 40 48             	mov    0x48(%eax),%eax
  8000ba:	83 c4 0c             	add    $0xc,%esp
  8000bd:	ff 75 8c             	pushl  -0x74(%ebp)
  8000c0:	50                   	push   %eax
  8000c1:	68 ab 24 80 00       	push   $0x8024ab
  8000c6:	e8 20 03 00 00       	call   8003eb <cprintf>
		i = readn(p[0], buf, sizeof buf-1);
  8000cb:	83 c4 0c             	add    $0xc,%esp
  8000ce:	6a 63                	push   $0x63
  8000d0:	8d 45 94             	lea    -0x6c(%ebp),%eax
  8000d3:	50                   	push   %eax
  8000d4:	ff 75 8c             	pushl  -0x74(%ebp)
  8000d7:	e8 a6 15 00 00       	call   801682 <readn>
  8000dc:	89 c6                	mov    %eax,%esi
		if (i < 0)
  8000de:	83 c4 10             	add    $0x10,%esp
  8000e1:	85 c0                	test   %eax,%eax
  8000e3:	79 12                	jns    8000f7 <umain+0xc4>
			panic("read: %e", i);
  8000e5:	50                   	push   %eax
  8000e6:	68 c8 24 80 00       	push   $0x8024c8
  8000eb:	6a 19                	push   $0x19
  8000ed:	68 75 24 80 00       	push   $0x802475
  8000f2:	e8 1b 02 00 00       	call   800312 <_panic>
		buf[i] = 0;
  8000f7:	c6 44 05 94 00       	movb   $0x0,-0x6c(%ebp,%eax,1)
		if (strcmp(buf, msg) == 0)
  8000fc:	83 ec 08             	sub    $0x8,%esp
  8000ff:	ff 35 00 30 80 00    	pushl  0x803000
  800105:	8d 45 94             	lea    -0x6c(%ebp),%eax
  800108:	50                   	push   %eax
  800109:	e8 b3 09 00 00       	call   800ac1 <strcmp>
  80010e:	83 c4 10             	add    $0x10,%esp
  800111:	85 c0                	test   %eax,%eax
  800113:	75 12                	jne    800127 <umain+0xf4>
			cprintf("\npipe read closed properly\n");
  800115:	83 ec 0c             	sub    $0xc,%esp
  800118:	68 d1 24 80 00       	push   $0x8024d1
  80011d:	e8 c9 02 00 00       	call   8003eb <cprintf>
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	eb 15                	jmp    80013c <umain+0x109>
		else
			cprintf("\ngot %d bytes: %s\n", i, buf);
  800127:	83 ec 04             	sub    $0x4,%esp
  80012a:	8d 45 94             	lea    -0x6c(%ebp),%eax
  80012d:	50                   	push   %eax
  80012e:	56                   	push   %esi
  80012f:	68 ed 24 80 00       	push   $0x8024ed
  800134:	e8 b2 02 00 00       	call   8003eb <cprintf>
  800139:	83 c4 10             	add    $0x10,%esp
		exit();
  80013c:	e8 b7 01 00 00       	call   8002f8 <exit>
  800141:	e9 94 00 00 00       	jmp    8001da <umain+0x1a7>
	} else {
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[0]);
  800146:	a1 04 40 80 00       	mov    0x804004,%eax
  80014b:	8b 40 48             	mov    0x48(%eax),%eax
  80014e:	83 ec 04             	sub    $0x4,%esp
  800151:	ff 75 8c             	pushl  -0x74(%ebp)
  800154:	50                   	push   %eax
  800155:	68 8e 24 80 00       	push   $0x80248e
  80015a:	e8 8c 02 00 00       	call   8003eb <cprintf>
		close(p[0]);
  80015f:	83 c4 04             	add    $0x4,%esp
  800162:	ff 75 8c             	pushl  -0x74(%ebp)
  800165:	e8 4b 13 00 00       	call   8014b5 <close>
		cprintf("[%08x] pipereadeof write %d\n", thisenv->env_id, p[1]);
  80016a:	a1 04 40 80 00       	mov    0x804004,%eax
  80016f:	8b 40 48             	mov    0x48(%eax),%eax
  800172:	83 c4 0c             	add    $0xc,%esp
  800175:	ff 75 90             	pushl  -0x70(%ebp)
  800178:	50                   	push   %eax
  800179:	68 00 25 80 00       	push   $0x802500
  80017e:	e8 68 02 00 00       	call   8003eb <cprintf>
		if ((i = write(p[1], msg, strlen(msg))) != strlen(msg))
  800183:	83 c4 04             	add    $0x4,%esp
  800186:	ff 35 00 30 80 00    	pushl  0x803000
  80018c:	e8 4d 08 00 00       	call   8009de <strlen>
  800191:	83 c4 0c             	add    $0xc,%esp
  800194:	50                   	push   %eax
  800195:	ff 35 00 30 80 00    	pushl  0x803000
  80019b:	ff 75 90             	pushl  -0x70(%ebp)
  80019e:	e8 28 15 00 00       	call   8016cb <write>
  8001a3:	89 c6                	mov    %eax,%esi
  8001a5:	83 c4 04             	add    $0x4,%esp
  8001a8:	ff 35 00 30 80 00    	pushl  0x803000
  8001ae:	e8 2b 08 00 00       	call   8009de <strlen>
  8001b3:	83 c4 10             	add    $0x10,%esp
  8001b6:	39 c6                	cmp    %eax,%esi
  8001b8:	74 12                	je     8001cc <umain+0x199>
			panic("write: %e", i);
  8001ba:	56                   	push   %esi
  8001bb:	68 1d 25 80 00       	push   $0x80251d
  8001c0:	6a 25                	push   $0x25
  8001c2:	68 75 24 80 00       	push   $0x802475
  8001c7:	e8 46 01 00 00       	call   800312 <_panic>
		close(p[1]);
  8001cc:	83 ec 0c             	sub    $0xc,%esp
  8001cf:	ff 75 90             	pushl  -0x70(%ebp)
  8001d2:	e8 de 12 00 00       	call   8014b5 <close>
  8001d7:	83 c4 10             	add    $0x10,%esp
	}
	wait(pid);
  8001da:	83 ec 0c             	sub    $0xc,%esp
  8001dd:	53                   	push   %ebx
  8001de:	e8 6d 1c 00 00       	call   801e50 <wait>

	binaryname = "pipewriteeof";
  8001e3:	c7 05 04 30 80 00 27 	movl   $0x802527,0x803004
  8001ea:	25 80 00 
	if ((i = pipe(p)) < 0)
  8001ed:	8d 45 8c             	lea    -0x74(%ebp),%eax
  8001f0:	89 04 24             	mov    %eax,(%esp)
  8001f3:	e8 d2 1a 00 00       	call   801cca <pipe>
  8001f8:	89 c6                	mov    %eax,%esi
  8001fa:	83 c4 10             	add    $0x10,%esp
  8001fd:	85 c0                	test   %eax,%eax
  8001ff:	79 12                	jns    800213 <umain+0x1e0>
		panic("pipe: %e", i);
  800201:	50                   	push   %eax
  800202:	68 6c 24 80 00       	push   $0x80246c
  800207:	6a 2c                	push   $0x2c
  800209:	68 75 24 80 00       	push   $0x802475
  80020e:	e8 ff 00 00 00       	call   800312 <_panic>

	if ((pid = fork()) < 0)
  800213:	e8 a0 0f 00 00       	call   8011b8 <fork>
  800218:	89 c3                	mov    %eax,%ebx
  80021a:	85 c0                	test   %eax,%eax
  80021c:	79 12                	jns    800230 <umain+0x1fd>
		panic("fork: %e", i);
  80021e:	56                   	push   %esi
  80021f:	68 85 24 80 00       	push   $0x802485
  800224:	6a 2f                	push   $0x2f
  800226:	68 75 24 80 00       	push   $0x802475
  80022b:	e8 e2 00 00 00       	call   800312 <_panic>

	if (pid == 0) {
  800230:	85 c0                	test   %eax,%eax
  800232:	75 4a                	jne    80027e <umain+0x24b>
		close(p[0]);
  800234:	83 ec 0c             	sub    $0xc,%esp
  800237:	ff 75 8c             	pushl  -0x74(%ebp)
  80023a:	e8 76 12 00 00       	call   8014b5 <close>
  80023f:	83 c4 10             	add    $0x10,%esp
		while (1) {
			cprintf(".");
  800242:	83 ec 0c             	sub    $0xc,%esp
  800245:	68 34 25 80 00       	push   $0x802534
  80024a:	e8 9c 01 00 00       	call   8003eb <cprintf>
			if (write(p[1], "x", 1) != 1)
  80024f:	83 c4 0c             	add    $0xc,%esp
  800252:	6a 01                	push   $0x1
  800254:	68 36 25 80 00       	push   $0x802536
  800259:	ff 75 90             	pushl  -0x70(%ebp)
  80025c:	e8 6a 14 00 00       	call   8016cb <write>
  800261:	83 c4 10             	add    $0x10,%esp
  800264:	83 f8 01             	cmp    $0x1,%eax
  800267:	74 d9                	je     800242 <umain+0x20f>
				break;
		}
		cprintf("\npipe write closed properly\n");
  800269:	83 ec 0c             	sub    $0xc,%esp
  80026c:	68 38 25 80 00       	push   $0x802538
  800271:	e8 75 01 00 00       	call   8003eb <cprintf>
		exit();
  800276:	e8 7d 00 00 00       	call   8002f8 <exit>
  80027b:	83 c4 10             	add    $0x10,%esp
	}
	close(p[0]);
  80027e:	83 ec 0c             	sub    $0xc,%esp
  800281:	ff 75 8c             	pushl  -0x74(%ebp)
  800284:	e8 2c 12 00 00       	call   8014b5 <close>
	close(p[1]);
  800289:	83 c4 04             	add    $0x4,%esp
  80028c:	ff 75 90             	pushl  -0x70(%ebp)
  80028f:	e8 21 12 00 00       	call   8014b5 <close>
	wait(pid);
  800294:	89 1c 24             	mov    %ebx,(%esp)
  800297:	e8 b4 1b 00 00       	call   801e50 <wait>

	cprintf("pipe tests passed\n");
  80029c:	c7 04 24 55 25 80 00 	movl   $0x802555,(%esp)
  8002a3:	e8 43 01 00 00       	call   8003eb <cprintf>
}
  8002a8:	83 c4 10             	add    $0x10,%esp
  8002ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002ae:	5b                   	pop    %ebx
  8002af:	5e                   	pop    %esi
  8002b0:	5d                   	pop    %ebp
  8002b1:	c3                   	ret    

008002b2 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8002b2:	55                   	push   %ebp
  8002b3:	89 e5                	mov    %esp,%ebp
  8002b5:	56                   	push   %esi
  8002b6:	53                   	push   %ebx
  8002b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002ba:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	envid_t envid = sys_getenvid();
  8002bd:	e8 1a 0b 00 00       	call   800ddc <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8002c2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002c7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8002ca:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002cf:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002d4:	85 db                	test   %ebx,%ebx
  8002d6:	7e 07                	jle    8002df <libmain+0x2d>
		binaryname = argv[0];
  8002d8:	8b 06                	mov    (%esi),%eax
  8002da:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  8002df:	83 ec 08             	sub    $0x8,%esp
  8002e2:	56                   	push   %esi
  8002e3:	53                   	push   %ebx
  8002e4:	e8 4a fd ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8002e9:	e8 0a 00 00 00       	call   8002f8 <exit>
}
  8002ee:	83 c4 10             	add    $0x10,%esp
  8002f1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002f4:	5b                   	pop    %ebx
  8002f5:	5e                   	pop    %esi
  8002f6:	5d                   	pop    %ebp
  8002f7:	c3                   	ret    

008002f8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8002f8:	55                   	push   %ebp
  8002f9:	89 e5                	mov    %esp,%ebp
  8002fb:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8002fe:	e8 dd 11 00 00       	call   8014e0 <close_all>
	sys_env_destroy(0);
  800303:	83 ec 0c             	sub    $0xc,%esp
  800306:	6a 00                	push   $0x0
  800308:	e8 8e 0a 00 00       	call   800d9b <sys_env_destroy>
}
  80030d:	83 c4 10             	add    $0x10,%esp
  800310:	c9                   	leave  
  800311:	c3                   	ret    

00800312 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800312:	55                   	push   %ebp
  800313:	89 e5                	mov    %esp,%ebp
  800315:	56                   	push   %esi
  800316:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800317:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80031a:	8b 35 04 30 80 00    	mov    0x803004,%esi
  800320:	e8 b7 0a 00 00       	call   800ddc <sys_getenvid>
  800325:	83 ec 0c             	sub    $0xc,%esp
  800328:	ff 75 0c             	pushl  0xc(%ebp)
  80032b:	ff 75 08             	pushl  0x8(%ebp)
  80032e:	56                   	push   %esi
  80032f:	50                   	push   %eax
  800330:	68 b8 25 80 00       	push   $0x8025b8
  800335:	e8 b1 00 00 00       	call   8003eb <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80033a:	83 c4 18             	add    $0x18,%esp
  80033d:	53                   	push   %ebx
  80033e:	ff 75 10             	pushl  0x10(%ebp)
  800341:	e8 54 00 00 00       	call   80039a <vcprintf>
	cprintf("\n");
  800346:	c7 04 24 a9 24 80 00 	movl   $0x8024a9,(%esp)
  80034d:	e8 99 00 00 00       	call   8003eb <cprintf>
  800352:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800355:	cc                   	int3   
  800356:	eb fd                	jmp    800355 <_panic+0x43>

00800358 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800358:	55                   	push   %ebp
  800359:	89 e5                	mov    %esp,%ebp
  80035b:	53                   	push   %ebx
  80035c:	83 ec 04             	sub    $0x4,%esp
  80035f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800362:	8b 13                	mov    (%ebx),%edx
  800364:	8d 42 01             	lea    0x1(%edx),%eax
  800367:	89 03                	mov    %eax,(%ebx)
  800369:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80036c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800370:	3d ff 00 00 00       	cmp    $0xff,%eax
  800375:	75 1a                	jne    800391 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800377:	83 ec 08             	sub    $0x8,%esp
  80037a:	68 ff 00 00 00       	push   $0xff
  80037f:	8d 43 08             	lea    0x8(%ebx),%eax
  800382:	50                   	push   %eax
  800383:	e8 d6 09 00 00       	call   800d5e <sys_cputs>
		b->idx = 0;
  800388:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80038e:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800391:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800395:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800398:	c9                   	leave  
  800399:	c3                   	ret    

0080039a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80039a:	55                   	push   %ebp
  80039b:	89 e5                	mov    %esp,%ebp
  80039d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003a3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003aa:	00 00 00 
	b.cnt = 0;
  8003ad:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003b4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003b7:	ff 75 0c             	pushl  0xc(%ebp)
  8003ba:	ff 75 08             	pushl  0x8(%ebp)
  8003bd:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003c3:	50                   	push   %eax
  8003c4:	68 58 03 80 00       	push   $0x800358
  8003c9:	e8 1a 01 00 00       	call   8004e8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003ce:	83 c4 08             	add    $0x8,%esp
  8003d1:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003d7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003dd:	50                   	push   %eax
  8003de:	e8 7b 09 00 00       	call   800d5e <sys_cputs>

	return b.cnt;
}
  8003e3:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003e9:	c9                   	leave  
  8003ea:	c3                   	ret    

008003eb <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003eb:	55                   	push   %ebp
  8003ec:	89 e5                	mov    %esp,%ebp
  8003ee:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003f1:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003f4:	50                   	push   %eax
  8003f5:	ff 75 08             	pushl  0x8(%ebp)
  8003f8:	e8 9d ff ff ff       	call   80039a <vcprintf>
	va_end(ap);

	return cnt;
}
  8003fd:	c9                   	leave  
  8003fe:	c3                   	ret    

008003ff <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003ff:	55                   	push   %ebp
  800400:	89 e5                	mov    %esp,%ebp
  800402:	57                   	push   %edi
  800403:	56                   	push   %esi
  800404:	53                   	push   %ebx
  800405:	83 ec 1c             	sub    $0x1c,%esp
  800408:	89 c7                	mov    %eax,%edi
  80040a:	89 d6                	mov    %edx,%esi
  80040c:	8b 45 08             	mov    0x8(%ebp),%eax
  80040f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800412:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800415:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800418:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80041b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800420:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800423:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800426:	39 d3                	cmp    %edx,%ebx
  800428:	72 05                	jb     80042f <printnum+0x30>
  80042a:	39 45 10             	cmp    %eax,0x10(%ebp)
  80042d:	77 45                	ja     800474 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80042f:	83 ec 0c             	sub    $0xc,%esp
  800432:	ff 75 18             	pushl  0x18(%ebp)
  800435:	8b 45 14             	mov    0x14(%ebp),%eax
  800438:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80043b:	53                   	push   %ebx
  80043c:	ff 75 10             	pushl  0x10(%ebp)
  80043f:	83 ec 08             	sub    $0x8,%esp
  800442:	ff 75 e4             	pushl  -0x1c(%ebp)
  800445:	ff 75 e0             	pushl  -0x20(%ebp)
  800448:	ff 75 dc             	pushl  -0x24(%ebp)
  80044b:	ff 75 d8             	pushl  -0x28(%ebp)
  80044e:	e8 7d 1d 00 00       	call   8021d0 <__udivdi3>
  800453:	83 c4 18             	add    $0x18,%esp
  800456:	52                   	push   %edx
  800457:	50                   	push   %eax
  800458:	89 f2                	mov    %esi,%edx
  80045a:	89 f8                	mov    %edi,%eax
  80045c:	e8 9e ff ff ff       	call   8003ff <printnum>
  800461:	83 c4 20             	add    $0x20,%esp
  800464:	eb 18                	jmp    80047e <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800466:	83 ec 08             	sub    $0x8,%esp
  800469:	56                   	push   %esi
  80046a:	ff 75 18             	pushl  0x18(%ebp)
  80046d:	ff d7                	call   *%edi
  80046f:	83 c4 10             	add    $0x10,%esp
  800472:	eb 03                	jmp    800477 <printnum+0x78>
  800474:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800477:	83 eb 01             	sub    $0x1,%ebx
  80047a:	85 db                	test   %ebx,%ebx
  80047c:	7f e8                	jg     800466 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80047e:	83 ec 08             	sub    $0x8,%esp
  800481:	56                   	push   %esi
  800482:	83 ec 04             	sub    $0x4,%esp
  800485:	ff 75 e4             	pushl  -0x1c(%ebp)
  800488:	ff 75 e0             	pushl  -0x20(%ebp)
  80048b:	ff 75 dc             	pushl  -0x24(%ebp)
  80048e:	ff 75 d8             	pushl  -0x28(%ebp)
  800491:	e8 6a 1e 00 00       	call   802300 <__umoddi3>
  800496:	83 c4 14             	add    $0x14,%esp
  800499:	0f be 80 db 25 80 00 	movsbl 0x8025db(%eax),%eax
  8004a0:	50                   	push   %eax
  8004a1:	ff d7                	call   *%edi
}
  8004a3:	83 c4 10             	add    $0x10,%esp
  8004a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004a9:	5b                   	pop    %ebx
  8004aa:	5e                   	pop    %esi
  8004ab:	5f                   	pop    %edi
  8004ac:	5d                   	pop    %ebp
  8004ad:	c3                   	ret    

008004ae <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004ae:	55                   	push   %ebp
  8004af:	89 e5                	mov    %esp,%ebp
  8004b1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004b4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004b8:	8b 10                	mov    (%eax),%edx
  8004ba:	3b 50 04             	cmp    0x4(%eax),%edx
  8004bd:	73 0a                	jae    8004c9 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004bf:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004c2:	89 08                	mov    %ecx,(%eax)
  8004c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8004c7:	88 02                	mov    %al,(%edx)
}
  8004c9:	5d                   	pop    %ebp
  8004ca:	c3                   	ret    

008004cb <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004cb:	55                   	push   %ebp
  8004cc:	89 e5                	mov    %esp,%ebp
  8004ce:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004d1:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004d4:	50                   	push   %eax
  8004d5:	ff 75 10             	pushl  0x10(%ebp)
  8004d8:	ff 75 0c             	pushl  0xc(%ebp)
  8004db:	ff 75 08             	pushl  0x8(%ebp)
  8004de:	e8 05 00 00 00       	call   8004e8 <vprintfmt>
	va_end(ap);
}
  8004e3:	83 c4 10             	add    $0x10,%esp
  8004e6:	c9                   	leave  
  8004e7:	c3                   	ret    

008004e8 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004e8:	55                   	push   %ebp
  8004e9:	89 e5                	mov    %esp,%ebp
  8004eb:	57                   	push   %edi
  8004ec:	56                   	push   %esi
  8004ed:	53                   	push   %ebx
  8004ee:	83 ec 2c             	sub    $0x2c,%esp
  8004f1:	8b 75 08             	mov    0x8(%ebp),%esi
  8004f4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004f7:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004fa:	eb 12                	jmp    80050e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004fc:	85 c0                	test   %eax,%eax
  8004fe:	0f 84 6a 04 00 00    	je     80096e <vprintfmt+0x486>
				return;
			putch(ch, putdat);
  800504:	83 ec 08             	sub    $0x8,%esp
  800507:	53                   	push   %ebx
  800508:	50                   	push   %eax
  800509:	ff d6                	call   *%esi
  80050b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80050e:	83 c7 01             	add    $0x1,%edi
  800511:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800515:	83 f8 25             	cmp    $0x25,%eax
  800518:	75 e2                	jne    8004fc <vprintfmt+0x14>
  80051a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80051e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800525:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80052c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800533:	b9 00 00 00 00       	mov    $0x0,%ecx
  800538:	eb 07                	jmp    800541 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053a:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80053d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800541:	8d 47 01             	lea    0x1(%edi),%eax
  800544:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800547:	0f b6 07             	movzbl (%edi),%eax
  80054a:	0f b6 d0             	movzbl %al,%edx
  80054d:	83 e8 23             	sub    $0x23,%eax
  800550:	3c 55                	cmp    $0x55,%al
  800552:	0f 87 fb 03 00 00    	ja     800953 <vprintfmt+0x46b>
  800558:	0f b6 c0             	movzbl %al,%eax
  80055b:	ff 24 85 20 27 80 00 	jmp    *0x802720(,%eax,4)
  800562:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800565:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800569:	eb d6                	jmp    800541 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80056e:	b8 00 00 00 00       	mov    $0x0,%eax
  800573:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800576:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800579:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80057d:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800580:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800583:	83 f9 09             	cmp    $0x9,%ecx
  800586:	77 3f                	ja     8005c7 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800588:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80058b:	eb e9                	jmp    800576 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80058d:	8b 45 14             	mov    0x14(%ebp),%eax
  800590:	8b 00                	mov    (%eax),%eax
  800592:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800595:	8b 45 14             	mov    0x14(%ebp),%eax
  800598:	8d 40 04             	lea    0x4(%eax),%eax
  80059b:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005a1:	eb 2a                	jmp    8005cd <vprintfmt+0xe5>
  8005a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005a6:	85 c0                	test   %eax,%eax
  8005a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8005ad:	0f 49 d0             	cmovns %eax,%edx
  8005b0:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005b6:	eb 89                	jmp    800541 <vprintfmt+0x59>
  8005b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005bb:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005c2:	e9 7a ff ff ff       	jmp    800541 <vprintfmt+0x59>
  8005c7:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005ca:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8005cd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005d1:	0f 89 6a ff ff ff    	jns    800541 <vprintfmt+0x59>
				width = precision, precision = -1;
  8005d7:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005da:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005dd:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005e4:	e9 58 ff ff ff       	jmp    800541 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005e9:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005ef:	e9 4d ff ff ff       	jmp    800541 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f7:	8d 78 04             	lea    0x4(%eax),%edi
  8005fa:	83 ec 08             	sub    $0x8,%esp
  8005fd:	53                   	push   %ebx
  8005fe:	ff 30                	pushl  (%eax)
  800600:	ff d6                	call   *%esi
			break;
  800602:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800605:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800608:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80060b:	e9 fe fe ff ff       	jmp    80050e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800610:	8b 45 14             	mov    0x14(%ebp),%eax
  800613:	8d 78 04             	lea    0x4(%eax),%edi
  800616:	8b 00                	mov    (%eax),%eax
  800618:	99                   	cltd   
  800619:	31 d0                	xor    %edx,%eax
  80061b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80061d:	83 f8 0f             	cmp    $0xf,%eax
  800620:	7f 0b                	jg     80062d <vprintfmt+0x145>
  800622:	8b 14 85 80 28 80 00 	mov    0x802880(,%eax,4),%edx
  800629:	85 d2                	test   %edx,%edx
  80062b:	75 1b                	jne    800648 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  80062d:	50                   	push   %eax
  80062e:	68 f3 25 80 00       	push   $0x8025f3
  800633:	53                   	push   %ebx
  800634:	56                   	push   %esi
  800635:	e8 91 fe ff ff       	call   8004cb <printfmt>
  80063a:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80063d:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800640:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800643:	e9 c6 fe ff ff       	jmp    80050e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800648:	52                   	push   %edx
  800649:	68 be 2a 80 00       	push   $0x802abe
  80064e:	53                   	push   %ebx
  80064f:	56                   	push   %esi
  800650:	e8 76 fe ff ff       	call   8004cb <printfmt>
  800655:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800658:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80065b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80065e:	e9 ab fe ff ff       	jmp    80050e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800663:	8b 45 14             	mov    0x14(%ebp),%eax
  800666:	83 c0 04             	add    $0x4,%eax
  800669:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80066c:	8b 45 14             	mov    0x14(%ebp),%eax
  80066f:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800671:	85 ff                	test   %edi,%edi
  800673:	b8 ec 25 80 00       	mov    $0x8025ec,%eax
  800678:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80067b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80067f:	0f 8e 94 00 00 00    	jle    800719 <vprintfmt+0x231>
  800685:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800689:	0f 84 98 00 00 00    	je     800727 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  80068f:	83 ec 08             	sub    $0x8,%esp
  800692:	ff 75 d0             	pushl  -0x30(%ebp)
  800695:	57                   	push   %edi
  800696:	e8 5b 03 00 00       	call   8009f6 <strnlen>
  80069b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80069e:	29 c1                	sub    %eax,%ecx
  8006a0:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8006a3:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006a6:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006aa:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006ad:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006b0:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006b2:	eb 0f                	jmp    8006c3 <vprintfmt+0x1db>
					putch(padc, putdat);
  8006b4:	83 ec 08             	sub    $0x8,%esp
  8006b7:	53                   	push   %ebx
  8006b8:	ff 75 e0             	pushl  -0x20(%ebp)
  8006bb:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006bd:	83 ef 01             	sub    $0x1,%edi
  8006c0:	83 c4 10             	add    $0x10,%esp
  8006c3:	85 ff                	test   %edi,%edi
  8006c5:	7f ed                	jg     8006b4 <vprintfmt+0x1cc>
  8006c7:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006ca:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006cd:	85 c9                	test   %ecx,%ecx
  8006cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8006d4:	0f 49 c1             	cmovns %ecx,%eax
  8006d7:	29 c1                	sub    %eax,%ecx
  8006d9:	89 75 08             	mov    %esi,0x8(%ebp)
  8006dc:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006df:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006e2:	89 cb                	mov    %ecx,%ebx
  8006e4:	eb 4d                	jmp    800733 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006e6:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006ea:	74 1b                	je     800707 <vprintfmt+0x21f>
  8006ec:	0f be c0             	movsbl %al,%eax
  8006ef:	83 e8 20             	sub    $0x20,%eax
  8006f2:	83 f8 5e             	cmp    $0x5e,%eax
  8006f5:	76 10                	jbe    800707 <vprintfmt+0x21f>
					putch('?', putdat);
  8006f7:	83 ec 08             	sub    $0x8,%esp
  8006fa:	ff 75 0c             	pushl  0xc(%ebp)
  8006fd:	6a 3f                	push   $0x3f
  8006ff:	ff 55 08             	call   *0x8(%ebp)
  800702:	83 c4 10             	add    $0x10,%esp
  800705:	eb 0d                	jmp    800714 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  800707:	83 ec 08             	sub    $0x8,%esp
  80070a:	ff 75 0c             	pushl  0xc(%ebp)
  80070d:	52                   	push   %edx
  80070e:	ff 55 08             	call   *0x8(%ebp)
  800711:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800714:	83 eb 01             	sub    $0x1,%ebx
  800717:	eb 1a                	jmp    800733 <vprintfmt+0x24b>
  800719:	89 75 08             	mov    %esi,0x8(%ebp)
  80071c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80071f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800722:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800725:	eb 0c                	jmp    800733 <vprintfmt+0x24b>
  800727:	89 75 08             	mov    %esi,0x8(%ebp)
  80072a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80072d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800730:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800733:	83 c7 01             	add    $0x1,%edi
  800736:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80073a:	0f be d0             	movsbl %al,%edx
  80073d:	85 d2                	test   %edx,%edx
  80073f:	74 23                	je     800764 <vprintfmt+0x27c>
  800741:	85 f6                	test   %esi,%esi
  800743:	78 a1                	js     8006e6 <vprintfmt+0x1fe>
  800745:	83 ee 01             	sub    $0x1,%esi
  800748:	79 9c                	jns    8006e6 <vprintfmt+0x1fe>
  80074a:	89 df                	mov    %ebx,%edi
  80074c:	8b 75 08             	mov    0x8(%ebp),%esi
  80074f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800752:	eb 18                	jmp    80076c <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800754:	83 ec 08             	sub    $0x8,%esp
  800757:	53                   	push   %ebx
  800758:	6a 20                	push   $0x20
  80075a:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80075c:	83 ef 01             	sub    $0x1,%edi
  80075f:	83 c4 10             	add    $0x10,%esp
  800762:	eb 08                	jmp    80076c <vprintfmt+0x284>
  800764:	89 df                	mov    %ebx,%edi
  800766:	8b 75 08             	mov    0x8(%ebp),%esi
  800769:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80076c:	85 ff                	test   %edi,%edi
  80076e:	7f e4                	jg     800754 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800770:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800773:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800776:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800779:	e9 90 fd ff ff       	jmp    80050e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80077e:	83 f9 01             	cmp    $0x1,%ecx
  800781:	7e 19                	jle    80079c <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800783:	8b 45 14             	mov    0x14(%ebp),%eax
  800786:	8b 50 04             	mov    0x4(%eax),%edx
  800789:	8b 00                	mov    (%eax),%eax
  80078b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80078e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800791:	8b 45 14             	mov    0x14(%ebp),%eax
  800794:	8d 40 08             	lea    0x8(%eax),%eax
  800797:	89 45 14             	mov    %eax,0x14(%ebp)
  80079a:	eb 38                	jmp    8007d4 <vprintfmt+0x2ec>
	else if (lflag)
  80079c:	85 c9                	test   %ecx,%ecx
  80079e:	74 1b                	je     8007bb <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8007a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a3:	8b 00                	mov    (%eax),%eax
  8007a5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007a8:	89 c1                	mov    %eax,%ecx
  8007aa:	c1 f9 1f             	sar    $0x1f,%ecx
  8007ad:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b3:	8d 40 04             	lea    0x4(%eax),%eax
  8007b6:	89 45 14             	mov    %eax,0x14(%ebp)
  8007b9:	eb 19                	jmp    8007d4 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8007bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8007be:	8b 00                	mov    (%eax),%eax
  8007c0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007c3:	89 c1                	mov    %eax,%ecx
  8007c5:	c1 f9 1f             	sar    $0x1f,%ecx
  8007c8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ce:	8d 40 04             	lea    0x4(%eax),%eax
  8007d1:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007d4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007d7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007da:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007df:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007e3:	0f 89 36 01 00 00    	jns    80091f <vprintfmt+0x437>
				putch('-', putdat);
  8007e9:	83 ec 08             	sub    $0x8,%esp
  8007ec:	53                   	push   %ebx
  8007ed:	6a 2d                	push   $0x2d
  8007ef:	ff d6                	call   *%esi
				num = -(long long) num;
  8007f1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007f4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8007f7:	f7 da                	neg    %edx
  8007f9:	83 d1 00             	adc    $0x0,%ecx
  8007fc:	f7 d9                	neg    %ecx
  8007fe:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800801:	b8 0a 00 00 00       	mov    $0xa,%eax
  800806:	e9 14 01 00 00       	jmp    80091f <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80080b:	83 f9 01             	cmp    $0x1,%ecx
  80080e:	7e 18                	jle    800828 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800810:	8b 45 14             	mov    0x14(%ebp),%eax
  800813:	8b 10                	mov    (%eax),%edx
  800815:	8b 48 04             	mov    0x4(%eax),%ecx
  800818:	8d 40 08             	lea    0x8(%eax),%eax
  80081b:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80081e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800823:	e9 f7 00 00 00       	jmp    80091f <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800828:	85 c9                	test   %ecx,%ecx
  80082a:	74 1a                	je     800846 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  80082c:	8b 45 14             	mov    0x14(%ebp),%eax
  80082f:	8b 10                	mov    (%eax),%edx
  800831:	b9 00 00 00 00       	mov    $0x0,%ecx
  800836:	8d 40 04             	lea    0x4(%eax),%eax
  800839:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80083c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800841:	e9 d9 00 00 00       	jmp    80091f <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800846:	8b 45 14             	mov    0x14(%ebp),%eax
  800849:	8b 10                	mov    (%eax),%edx
  80084b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800850:	8d 40 04             	lea    0x4(%eax),%eax
  800853:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800856:	b8 0a 00 00 00       	mov    $0xa,%eax
  80085b:	e9 bf 00 00 00       	jmp    80091f <vprintfmt+0x437>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800860:	83 f9 01             	cmp    $0x1,%ecx
  800863:	7e 13                	jle    800878 <vprintfmt+0x390>
		return va_arg(*ap, long long);
  800865:	8b 45 14             	mov    0x14(%ebp),%eax
  800868:	8b 50 04             	mov    0x4(%eax),%edx
  80086b:	8b 00                	mov    (%eax),%eax
  80086d:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800870:	8d 49 08             	lea    0x8(%ecx),%ecx
  800873:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800876:	eb 28                	jmp    8008a0 <vprintfmt+0x3b8>
	else if (lflag)
  800878:	85 c9                	test   %ecx,%ecx
  80087a:	74 13                	je     80088f <vprintfmt+0x3a7>
		return va_arg(*ap, long);
  80087c:	8b 45 14             	mov    0x14(%ebp),%eax
  80087f:	8b 10                	mov    (%eax),%edx
  800881:	89 d0                	mov    %edx,%eax
  800883:	99                   	cltd   
  800884:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800887:	8d 49 04             	lea    0x4(%ecx),%ecx
  80088a:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80088d:	eb 11                	jmp    8008a0 <vprintfmt+0x3b8>
	else
		return va_arg(*ap, int);
  80088f:	8b 45 14             	mov    0x14(%ebp),%eax
  800892:	8b 10                	mov    (%eax),%edx
  800894:	89 d0                	mov    %edx,%eax
  800896:	99                   	cltd   
  800897:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80089a:	8d 49 04             	lea    0x4(%ecx),%ecx
  80089d:	89 4d 14             	mov    %ecx,0x14(%ebp)
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getint(&ap, lflag);
  8008a0:	89 d1                	mov    %edx,%ecx
  8008a2:	89 c2                	mov    %eax,%edx
			base = 8;
  8008a4:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8008a9:	eb 74                	jmp    80091f <vprintfmt+0x437>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8008ab:	83 ec 08             	sub    $0x8,%esp
  8008ae:	53                   	push   %ebx
  8008af:	6a 30                	push   $0x30
  8008b1:	ff d6                	call   *%esi
			putch('x', putdat);
  8008b3:	83 c4 08             	add    $0x8,%esp
  8008b6:	53                   	push   %ebx
  8008b7:	6a 78                	push   $0x78
  8008b9:	ff d6                	call   *%esi
			num = (unsigned long long)
  8008bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8008be:	8b 10                	mov    (%eax),%edx
  8008c0:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8008c5:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8008c8:	8d 40 04             	lea    0x4(%eax),%eax
  8008cb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008ce:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8008d3:	eb 4a                	jmp    80091f <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8008d5:	83 f9 01             	cmp    $0x1,%ecx
  8008d8:	7e 15                	jle    8008ef <vprintfmt+0x407>
		return va_arg(*ap, unsigned long long);
  8008da:	8b 45 14             	mov    0x14(%ebp),%eax
  8008dd:	8b 10                	mov    (%eax),%edx
  8008df:	8b 48 04             	mov    0x4(%eax),%ecx
  8008e2:	8d 40 08             	lea    0x8(%eax),%eax
  8008e5:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8008e8:	b8 10 00 00 00       	mov    $0x10,%eax
  8008ed:	eb 30                	jmp    80091f <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8008ef:	85 c9                	test   %ecx,%ecx
  8008f1:	74 17                	je     80090a <vprintfmt+0x422>
		return va_arg(*ap, unsigned long);
  8008f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f6:	8b 10                	mov    (%eax),%edx
  8008f8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008fd:	8d 40 04             	lea    0x4(%eax),%eax
  800900:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800903:	b8 10 00 00 00       	mov    $0x10,%eax
  800908:	eb 15                	jmp    80091f <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80090a:	8b 45 14             	mov    0x14(%ebp),%eax
  80090d:	8b 10                	mov    (%eax),%edx
  80090f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800914:	8d 40 04             	lea    0x4(%eax),%eax
  800917:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80091a:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80091f:	83 ec 0c             	sub    $0xc,%esp
  800922:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800926:	57                   	push   %edi
  800927:	ff 75 e0             	pushl  -0x20(%ebp)
  80092a:	50                   	push   %eax
  80092b:	51                   	push   %ecx
  80092c:	52                   	push   %edx
  80092d:	89 da                	mov    %ebx,%edx
  80092f:	89 f0                	mov    %esi,%eax
  800931:	e8 c9 fa ff ff       	call   8003ff <printnum>
			break;
  800936:	83 c4 20             	add    $0x20,%esp
  800939:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80093c:	e9 cd fb ff ff       	jmp    80050e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800941:	83 ec 08             	sub    $0x8,%esp
  800944:	53                   	push   %ebx
  800945:	52                   	push   %edx
  800946:	ff d6                	call   *%esi
			break;
  800948:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80094b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80094e:	e9 bb fb ff ff       	jmp    80050e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800953:	83 ec 08             	sub    $0x8,%esp
  800956:	53                   	push   %ebx
  800957:	6a 25                	push   $0x25
  800959:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80095b:	83 c4 10             	add    $0x10,%esp
  80095e:	eb 03                	jmp    800963 <vprintfmt+0x47b>
  800960:	83 ef 01             	sub    $0x1,%edi
  800963:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800967:	75 f7                	jne    800960 <vprintfmt+0x478>
  800969:	e9 a0 fb ff ff       	jmp    80050e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80096e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800971:	5b                   	pop    %ebx
  800972:	5e                   	pop    %esi
  800973:	5f                   	pop    %edi
  800974:	5d                   	pop    %ebp
  800975:	c3                   	ret    

00800976 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800976:	55                   	push   %ebp
  800977:	89 e5                	mov    %esp,%ebp
  800979:	83 ec 18             	sub    $0x18,%esp
  80097c:	8b 45 08             	mov    0x8(%ebp),%eax
  80097f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800982:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800985:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800989:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80098c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800993:	85 c0                	test   %eax,%eax
  800995:	74 26                	je     8009bd <vsnprintf+0x47>
  800997:	85 d2                	test   %edx,%edx
  800999:	7e 22                	jle    8009bd <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80099b:	ff 75 14             	pushl  0x14(%ebp)
  80099e:	ff 75 10             	pushl  0x10(%ebp)
  8009a1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009a4:	50                   	push   %eax
  8009a5:	68 ae 04 80 00       	push   $0x8004ae
  8009aa:	e8 39 fb ff ff       	call   8004e8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009af:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009b2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009b8:	83 c4 10             	add    $0x10,%esp
  8009bb:	eb 05                	jmp    8009c2 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8009bd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8009c2:	c9                   	leave  
  8009c3:	c3                   	ret    

008009c4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009c4:	55                   	push   %ebp
  8009c5:	89 e5                	mov    %esp,%ebp
  8009c7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009ca:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009cd:	50                   	push   %eax
  8009ce:	ff 75 10             	pushl  0x10(%ebp)
  8009d1:	ff 75 0c             	pushl  0xc(%ebp)
  8009d4:	ff 75 08             	pushl  0x8(%ebp)
  8009d7:	e8 9a ff ff ff       	call   800976 <vsnprintf>
	va_end(ap);

	return rc;
}
  8009dc:	c9                   	leave  
  8009dd:	c3                   	ret    

008009de <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009de:	55                   	push   %ebp
  8009df:	89 e5                	mov    %esp,%ebp
  8009e1:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009e4:	b8 00 00 00 00       	mov    $0x0,%eax
  8009e9:	eb 03                	jmp    8009ee <strlen+0x10>
		n++;
  8009eb:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009ee:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009f2:	75 f7                	jne    8009eb <strlen+0xd>
		n++;
	return n;
}
  8009f4:	5d                   	pop    %ebp
  8009f5:	c3                   	ret    

008009f6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009f6:	55                   	push   %ebp
  8009f7:	89 e5                	mov    %esp,%ebp
  8009f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009fc:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009ff:	ba 00 00 00 00       	mov    $0x0,%edx
  800a04:	eb 03                	jmp    800a09 <strnlen+0x13>
		n++;
  800a06:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a09:	39 c2                	cmp    %eax,%edx
  800a0b:	74 08                	je     800a15 <strnlen+0x1f>
  800a0d:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800a11:	75 f3                	jne    800a06 <strnlen+0x10>
  800a13:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800a15:	5d                   	pop    %ebp
  800a16:	c3                   	ret    

00800a17 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a17:	55                   	push   %ebp
  800a18:	89 e5                	mov    %esp,%ebp
  800a1a:	53                   	push   %ebx
  800a1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a21:	89 c2                	mov    %eax,%edx
  800a23:	83 c2 01             	add    $0x1,%edx
  800a26:	83 c1 01             	add    $0x1,%ecx
  800a29:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a2d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a30:	84 db                	test   %bl,%bl
  800a32:	75 ef                	jne    800a23 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a34:	5b                   	pop    %ebx
  800a35:	5d                   	pop    %ebp
  800a36:	c3                   	ret    

00800a37 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a37:	55                   	push   %ebp
  800a38:	89 e5                	mov    %esp,%ebp
  800a3a:	53                   	push   %ebx
  800a3b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a3e:	53                   	push   %ebx
  800a3f:	e8 9a ff ff ff       	call   8009de <strlen>
  800a44:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a47:	ff 75 0c             	pushl  0xc(%ebp)
  800a4a:	01 d8                	add    %ebx,%eax
  800a4c:	50                   	push   %eax
  800a4d:	e8 c5 ff ff ff       	call   800a17 <strcpy>
	return dst;
}
  800a52:	89 d8                	mov    %ebx,%eax
  800a54:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a57:	c9                   	leave  
  800a58:	c3                   	ret    

00800a59 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a59:	55                   	push   %ebp
  800a5a:	89 e5                	mov    %esp,%ebp
  800a5c:	56                   	push   %esi
  800a5d:	53                   	push   %ebx
  800a5e:	8b 75 08             	mov    0x8(%ebp),%esi
  800a61:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a64:	89 f3                	mov    %esi,%ebx
  800a66:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a69:	89 f2                	mov    %esi,%edx
  800a6b:	eb 0f                	jmp    800a7c <strncpy+0x23>
		*dst++ = *src;
  800a6d:	83 c2 01             	add    $0x1,%edx
  800a70:	0f b6 01             	movzbl (%ecx),%eax
  800a73:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a76:	80 39 01             	cmpb   $0x1,(%ecx)
  800a79:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a7c:	39 da                	cmp    %ebx,%edx
  800a7e:	75 ed                	jne    800a6d <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a80:	89 f0                	mov    %esi,%eax
  800a82:	5b                   	pop    %ebx
  800a83:	5e                   	pop    %esi
  800a84:	5d                   	pop    %ebp
  800a85:	c3                   	ret    

00800a86 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a86:	55                   	push   %ebp
  800a87:	89 e5                	mov    %esp,%ebp
  800a89:	56                   	push   %esi
  800a8a:	53                   	push   %ebx
  800a8b:	8b 75 08             	mov    0x8(%ebp),%esi
  800a8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a91:	8b 55 10             	mov    0x10(%ebp),%edx
  800a94:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a96:	85 d2                	test   %edx,%edx
  800a98:	74 21                	je     800abb <strlcpy+0x35>
  800a9a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a9e:	89 f2                	mov    %esi,%edx
  800aa0:	eb 09                	jmp    800aab <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800aa2:	83 c2 01             	add    $0x1,%edx
  800aa5:	83 c1 01             	add    $0x1,%ecx
  800aa8:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800aab:	39 c2                	cmp    %eax,%edx
  800aad:	74 09                	je     800ab8 <strlcpy+0x32>
  800aaf:	0f b6 19             	movzbl (%ecx),%ebx
  800ab2:	84 db                	test   %bl,%bl
  800ab4:	75 ec                	jne    800aa2 <strlcpy+0x1c>
  800ab6:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800ab8:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800abb:	29 f0                	sub    %esi,%eax
}
  800abd:	5b                   	pop    %ebx
  800abe:	5e                   	pop    %esi
  800abf:	5d                   	pop    %ebp
  800ac0:	c3                   	ret    

00800ac1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ac1:	55                   	push   %ebp
  800ac2:	89 e5                	mov    %esp,%ebp
  800ac4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ac7:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800aca:	eb 06                	jmp    800ad2 <strcmp+0x11>
		p++, q++;
  800acc:	83 c1 01             	add    $0x1,%ecx
  800acf:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800ad2:	0f b6 01             	movzbl (%ecx),%eax
  800ad5:	84 c0                	test   %al,%al
  800ad7:	74 04                	je     800add <strcmp+0x1c>
  800ad9:	3a 02                	cmp    (%edx),%al
  800adb:	74 ef                	je     800acc <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800add:	0f b6 c0             	movzbl %al,%eax
  800ae0:	0f b6 12             	movzbl (%edx),%edx
  800ae3:	29 d0                	sub    %edx,%eax
}
  800ae5:	5d                   	pop    %ebp
  800ae6:	c3                   	ret    

00800ae7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ae7:	55                   	push   %ebp
  800ae8:	89 e5                	mov    %esp,%ebp
  800aea:	53                   	push   %ebx
  800aeb:	8b 45 08             	mov    0x8(%ebp),%eax
  800aee:	8b 55 0c             	mov    0xc(%ebp),%edx
  800af1:	89 c3                	mov    %eax,%ebx
  800af3:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800af6:	eb 06                	jmp    800afe <strncmp+0x17>
		n--, p++, q++;
  800af8:	83 c0 01             	add    $0x1,%eax
  800afb:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800afe:	39 d8                	cmp    %ebx,%eax
  800b00:	74 15                	je     800b17 <strncmp+0x30>
  800b02:	0f b6 08             	movzbl (%eax),%ecx
  800b05:	84 c9                	test   %cl,%cl
  800b07:	74 04                	je     800b0d <strncmp+0x26>
  800b09:	3a 0a                	cmp    (%edx),%cl
  800b0b:	74 eb                	je     800af8 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b0d:	0f b6 00             	movzbl (%eax),%eax
  800b10:	0f b6 12             	movzbl (%edx),%edx
  800b13:	29 d0                	sub    %edx,%eax
  800b15:	eb 05                	jmp    800b1c <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b17:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b1c:	5b                   	pop    %ebx
  800b1d:	5d                   	pop    %ebp
  800b1e:	c3                   	ret    

00800b1f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b1f:	55                   	push   %ebp
  800b20:	89 e5                	mov    %esp,%ebp
  800b22:	8b 45 08             	mov    0x8(%ebp),%eax
  800b25:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b29:	eb 07                	jmp    800b32 <strchr+0x13>
		if (*s == c)
  800b2b:	38 ca                	cmp    %cl,%dl
  800b2d:	74 0f                	je     800b3e <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b2f:	83 c0 01             	add    $0x1,%eax
  800b32:	0f b6 10             	movzbl (%eax),%edx
  800b35:	84 d2                	test   %dl,%dl
  800b37:	75 f2                	jne    800b2b <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800b39:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b3e:	5d                   	pop    %ebp
  800b3f:	c3                   	ret    

00800b40 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b40:	55                   	push   %ebp
  800b41:	89 e5                	mov    %esp,%ebp
  800b43:	8b 45 08             	mov    0x8(%ebp),%eax
  800b46:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b4a:	eb 03                	jmp    800b4f <strfind+0xf>
  800b4c:	83 c0 01             	add    $0x1,%eax
  800b4f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b52:	38 ca                	cmp    %cl,%dl
  800b54:	74 04                	je     800b5a <strfind+0x1a>
  800b56:	84 d2                	test   %dl,%dl
  800b58:	75 f2                	jne    800b4c <strfind+0xc>
			break;
	return (char *) s;
}
  800b5a:	5d                   	pop    %ebp
  800b5b:	c3                   	ret    

00800b5c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b5c:	55                   	push   %ebp
  800b5d:	89 e5                	mov    %esp,%ebp
  800b5f:	57                   	push   %edi
  800b60:	56                   	push   %esi
  800b61:	53                   	push   %ebx
  800b62:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b65:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b68:	85 c9                	test   %ecx,%ecx
  800b6a:	74 36                	je     800ba2 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b6c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b72:	75 28                	jne    800b9c <memset+0x40>
  800b74:	f6 c1 03             	test   $0x3,%cl
  800b77:	75 23                	jne    800b9c <memset+0x40>
		c &= 0xFF;
  800b79:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b7d:	89 d3                	mov    %edx,%ebx
  800b7f:	c1 e3 08             	shl    $0x8,%ebx
  800b82:	89 d6                	mov    %edx,%esi
  800b84:	c1 e6 18             	shl    $0x18,%esi
  800b87:	89 d0                	mov    %edx,%eax
  800b89:	c1 e0 10             	shl    $0x10,%eax
  800b8c:	09 f0                	or     %esi,%eax
  800b8e:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b90:	89 d8                	mov    %ebx,%eax
  800b92:	09 d0                	or     %edx,%eax
  800b94:	c1 e9 02             	shr    $0x2,%ecx
  800b97:	fc                   	cld    
  800b98:	f3 ab                	rep stos %eax,%es:(%edi)
  800b9a:	eb 06                	jmp    800ba2 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b9c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b9f:	fc                   	cld    
  800ba0:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ba2:	89 f8                	mov    %edi,%eax
  800ba4:	5b                   	pop    %ebx
  800ba5:	5e                   	pop    %esi
  800ba6:	5f                   	pop    %edi
  800ba7:	5d                   	pop    %ebp
  800ba8:	c3                   	ret    

00800ba9 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ba9:	55                   	push   %ebp
  800baa:	89 e5                	mov    %esp,%ebp
  800bac:	57                   	push   %edi
  800bad:	56                   	push   %esi
  800bae:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb1:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bb4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bb7:	39 c6                	cmp    %eax,%esi
  800bb9:	73 35                	jae    800bf0 <memmove+0x47>
  800bbb:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bbe:	39 d0                	cmp    %edx,%eax
  800bc0:	73 2e                	jae    800bf0 <memmove+0x47>
		s += n;
		d += n;
  800bc2:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bc5:	89 d6                	mov    %edx,%esi
  800bc7:	09 fe                	or     %edi,%esi
  800bc9:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800bcf:	75 13                	jne    800be4 <memmove+0x3b>
  800bd1:	f6 c1 03             	test   $0x3,%cl
  800bd4:	75 0e                	jne    800be4 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800bd6:	83 ef 04             	sub    $0x4,%edi
  800bd9:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bdc:	c1 e9 02             	shr    $0x2,%ecx
  800bdf:	fd                   	std    
  800be0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800be2:	eb 09                	jmp    800bed <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800be4:	83 ef 01             	sub    $0x1,%edi
  800be7:	8d 72 ff             	lea    -0x1(%edx),%esi
  800bea:	fd                   	std    
  800beb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bed:	fc                   	cld    
  800bee:	eb 1d                	jmp    800c0d <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bf0:	89 f2                	mov    %esi,%edx
  800bf2:	09 c2                	or     %eax,%edx
  800bf4:	f6 c2 03             	test   $0x3,%dl
  800bf7:	75 0f                	jne    800c08 <memmove+0x5f>
  800bf9:	f6 c1 03             	test   $0x3,%cl
  800bfc:	75 0a                	jne    800c08 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800bfe:	c1 e9 02             	shr    $0x2,%ecx
  800c01:	89 c7                	mov    %eax,%edi
  800c03:	fc                   	cld    
  800c04:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c06:	eb 05                	jmp    800c0d <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c08:	89 c7                	mov    %eax,%edi
  800c0a:	fc                   	cld    
  800c0b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c0d:	5e                   	pop    %esi
  800c0e:	5f                   	pop    %edi
  800c0f:	5d                   	pop    %ebp
  800c10:	c3                   	ret    

00800c11 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c11:	55                   	push   %ebp
  800c12:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800c14:	ff 75 10             	pushl  0x10(%ebp)
  800c17:	ff 75 0c             	pushl  0xc(%ebp)
  800c1a:	ff 75 08             	pushl  0x8(%ebp)
  800c1d:	e8 87 ff ff ff       	call   800ba9 <memmove>
}
  800c22:	c9                   	leave  
  800c23:	c3                   	ret    

00800c24 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c24:	55                   	push   %ebp
  800c25:	89 e5                	mov    %esp,%ebp
  800c27:	56                   	push   %esi
  800c28:	53                   	push   %ebx
  800c29:	8b 45 08             	mov    0x8(%ebp),%eax
  800c2c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c2f:	89 c6                	mov    %eax,%esi
  800c31:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c34:	eb 1a                	jmp    800c50 <memcmp+0x2c>
		if (*s1 != *s2)
  800c36:	0f b6 08             	movzbl (%eax),%ecx
  800c39:	0f b6 1a             	movzbl (%edx),%ebx
  800c3c:	38 d9                	cmp    %bl,%cl
  800c3e:	74 0a                	je     800c4a <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800c40:	0f b6 c1             	movzbl %cl,%eax
  800c43:	0f b6 db             	movzbl %bl,%ebx
  800c46:	29 d8                	sub    %ebx,%eax
  800c48:	eb 0f                	jmp    800c59 <memcmp+0x35>
		s1++, s2++;
  800c4a:	83 c0 01             	add    $0x1,%eax
  800c4d:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c50:	39 f0                	cmp    %esi,%eax
  800c52:	75 e2                	jne    800c36 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c54:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c59:	5b                   	pop    %ebx
  800c5a:	5e                   	pop    %esi
  800c5b:	5d                   	pop    %ebp
  800c5c:	c3                   	ret    

00800c5d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c5d:	55                   	push   %ebp
  800c5e:	89 e5                	mov    %esp,%ebp
  800c60:	53                   	push   %ebx
  800c61:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c64:	89 c1                	mov    %eax,%ecx
  800c66:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800c69:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c6d:	eb 0a                	jmp    800c79 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c6f:	0f b6 10             	movzbl (%eax),%edx
  800c72:	39 da                	cmp    %ebx,%edx
  800c74:	74 07                	je     800c7d <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c76:	83 c0 01             	add    $0x1,%eax
  800c79:	39 c8                	cmp    %ecx,%eax
  800c7b:	72 f2                	jb     800c6f <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c7d:	5b                   	pop    %ebx
  800c7e:	5d                   	pop    %ebp
  800c7f:	c3                   	ret    

00800c80 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c80:	55                   	push   %ebp
  800c81:	89 e5                	mov    %esp,%ebp
  800c83:	57                   	push   %edi
  800c84:	56                   	push   %esi
  800c85:	53                   	push   %ebx
  800c86:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c89:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c8c:	eb 03                	jmp    800c91 <strtol+0x11>
		s++;
  800c8e:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c91:	0f b6 01             	movzbl (%ecx),%eax
  800c94:	3c 20                	cmp    $0x20,%al
  800c96:	74 f6                	je     800c8e <strtol+0xe>
  800c98:	3c 09                	cmp    $0x9,%al
  800c9a:	74 f2                	je     800c8e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c9c:	3c 2b                	cmp    $0x2b,%al
  800c9e:	75 0a                	jne    800caa <strtol+0x2a>
		s++;
  800ca0:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ca3:	bf 00 00 00 00       	mov    $0x0,%edi
  800ca8:	eb 11                	jmp    800cbb <strtol+0x3b>
  800caa:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800caf:	3c 2d                	cmp    $0x2d,%al
  800cb1:	75 08                	jne    800cbb <strtol+0x3b>
		s++, neg = 1;
  800cb3:	83 c1 01             	add    $0x1,%ecx
  800cb6:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cbb:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800cc1:	75 15                	jne    800cd8 <strtol+0x58>
  800cc3:	80 39 30             	cmpb   $0x30,(%ecx)
  800cc6:	75 10                	jne    800cd8 <strtol+0x58>
  800cc8:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ccc:	75 7c                	jne    800d4a <strtol+0xca>
		s += 2, base = 16;
  800cce:	83 c1 02             	add    $0x2,%ecx
  800cd1:	bb 10 00 00 00       	mov    $0x10,%ebx
  800cd6:	eb 16                	jmp    800cee <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800cd8:	85 db                	test   %ebx,%ebx
  800cda:	75 12                	jne    800cee <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800cdc:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ce1:	80 39 30             	cmpb   $0x30,(%ecx)
  800ce4:	75 08                	jne    800cee <strtol+0x6e>
		s++, base = 8;
  800ce6:	83 c1 01             	add    $0x1,%ecx
  800ce9:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800cee:	b8 00 00 00 00       	mov    $0x0,%eax
  800cf3:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cf6:	0f b6 11             	movzbl (%ecx),%edx
  800cf9:	8d 72 d0             	lea    -0x30(%edx),%esi
  800cfc:	89 f3                	mov    %esi,%ebx
  800cfe:	80 fb 09             	cmp    $0x9,%bl
  800d01:	77 08                	ja     800d0b <strtol+0x8b>
			dig = *s - '0';
  800d03:	0f be d2             	movsbl %dl,%edx
  800d06:	83 ea 30             	sub    $0x30,%edx
  800d09:	eb 22                	jmp    800d2d <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800d0b:	8d 72 9f             	lea    -0x61(%edx),%esi
  800d0e:	89 f3                	mov    %esi,%ebx
  800d10:	80 fb 19             	cmp    $0x19,%bl
  800d13:	77 08                	ja     800d1d <strtol+0x9d>
			dig = *s - 'a' + 10;
  800d15:	0f be d2             	movsbl %dl,%edx
  800d18:	83 ea 57             	sub    $0x57,%edx
  800d1b:	eb 10                	jmp    800d2d <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800d1d:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d20:	89 f3                	mov    %esi,%ebx
  800d22:	80 fb 19             	cmp    $0x19,%bl
  800d25:	77 16                	ja     800d3d <strtol+0xbd>
			dig = *s - 'A' + 10;
  800d27:	0f be d2             	movsbl %dl,%edx
  800d2a:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800d2d:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d30:	7d 0b                	jge    800d3d <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800d32:	83 c1 01             	add    $0x1,%ecx
  800d35:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d39:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800d3b:	eb b9                	jmp    800cf6 <strtol+0x76>

	if (endptr)
  800d3d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d41:	74 0d                	je     800d50 <strtol+0xd0>
		*endptr = (char *) s;
  800d43:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d46:	89 0e                	mov    %ecx,(%esi)
  800d48:	eb 06                	jmp    800d50 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d4a:	85 db                	test   %ebx,%ebx
  800d4c:	74 98                	je     800ce6 <strtol+0x66>
  800d4e:	eb 9e                	jmp    800cee <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800d50:	89 c2                	mov    %eax,%edx
  800d52:	f7 da                	neg    %edx
  800d54:	85 ff                	test   %edi,%edi
  800d56:	0f 45 c2             	cmovne %edx,%eax
}
  800d59:	5b                   	pop    %ebx
  800d5a:	5e                   	pop    %esi
  800d5b:	5f                   	pop    %edi
  800d5c:	5d                   	pop    %ebp
  800d5d:	c3                   	ret    

00800d5e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d5e:	55                   	push   %ebp
  800d5f:	89 e5                	mov    %esp,%ebp
  800d61:	57                   	push   %edi
  800d62:	56                   	push   %esi
  800d63:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d64:	b8 00 00 00 00       	mov    $0x0,%eax
  800d69:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6f:	89 c3                	mov    %eax,%ebx
  800d71:	89 c7                	mov    %eax,%edi
  800d73:	89 c6                	mov    %eax,%esi
  800d75:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d77:	5b                   	pop    %ebx
  800d78:	5e                   	pop    %esi
  800d79:	5f                   	pop    %edi
  800d7a:	5d                   	pop    %ebp
  800d7b:	c3                   	ret    

00800d7c <sys_cgetc>:

int
sys_cgetc(void)
{
  800d7c:	55                   	push   %ebp
  800d7d:	89 e5                	mov    %esp,%ebp
  800d7f:	57                   	push   %edi
  800d80:	56                   	push   %esi
  800d81:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d82:	ba 00 00 00 00       	mov    $0x0,%edx
  800d87:	b8 01 00 00 00       	mov    $0x1,%eax
  800d8c:	89 d1                	mov    %edx,%ecx
  800d8e:	89 d3                	mov    %edx,%ebx
  800d90:	89 d7                	mov    %edx,%edi
  800d92:	89 d6                	mov    %edx,%esi
  800d94:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d96:	5b                   	pop    %ebx
  800d97:	5e                   	pop    %esi
  800d98:	5f                   	pop    %edi
  800d99:	5d                   	pop    %ebp
  800d9a:	c3                   	ret    

00800d9b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d9b:	55                   	push   %ebp
  800d9c:	89 e5                	mov    %esp,%ebp
  800d9e:	57                   	push   %edi
  800d9f:	56                   	push   %esi
  800da0:	53                   	push   %ebx
  800da1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800da9:	b8 03 00 00 00       	mov    $0x3,%eax
  800dae:	8b 55 08             	mov    0x8(%ebp),%edx
  800db1:	89 cb                	mov    %ecx,%ebx
  800db3:	89 cf                	mov    %ecx,%edi
  800db5:	89 ce                	mov    %ecx,%esi
  800db7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800db9:	85 c0                	test   %eax,%eax
  800dbb:	7e 17                	jle    800dd4 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dbd:	83 ec 0c             	sub    $0xc,%esp
  800dc0:	50                   	push   %eax
  800dc1:	6a 03                	push   $0x3
  800dc3:	68 df 28 80 00       	push   $0x8028df
  800dc8:	6a 23                	push   $0x23
  800dca:	68 fc 28 80 00       	push   $0x8028fc
  800dcf:	e8 3e f5 ff ff       	call   800312 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800dd4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dd7:	5b                   	pop    %ebx
  800dd8:	5e                   	pop    %esi
  800dd9:	5f                   	pop    %edi
  800dda:	5d                   	pop    %ebp
  800ddb:	c3                   	ret    

00800ddc <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ddc:	55                   	push   %ebp
  800ddd:	89 e5                	mov    %esp,%ebp
  800ddf:	57                   	push   %edi
  800de0:	56                   	push   %esi
  800de1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de2:	ba 00 00 00 00       	mov    $0x0,%edx
  800de7:	b8 02 00 00 00       	mov    $0x2,%eax
  800dec:	89 d1                	mov    %edx,%ecx
  800dee:	89 d3                	mov    %edx,%ebx
  800df0:	89 d7                	mov    %edx,%edi
  800df2:	89 d6                	mov    %edx,%esi
  800df4:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800df6:	5b                   	pop    %ebx
  800df7:	5e                   	pop    %esi
  800df8:	5f                   	pop    %edi
  800df9:	5d                   	pop    %ebp
  800dfa:	c3                   	ret    

00800dfb <sys_yield>:

void
sys_yield(void)
{
  800dfb:	55                   	push   %ebp
  800dfc:	89 e5                	mov    %esp,%ebp
  800dfe:	57                   	push   %edi
  800dff:	56                   	push   %esi
  800e00:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e01:	ba 00 00 00 00       	mov    $0x0,%edx
  800e06:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e0b:	89 d1                	mov    %edx,%ecx
  800e0d:	89 d3                	mov    %edx,%ebx
  800e0f:	89 d7                	mov    %edx,%edi
  800e11:	89 d6                	mov    %edx,%esi
  800e13:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e15:	5b                   	pop    %ebx
  800e16:	5e                   	pop    %esi
  800e17:	5f                   	pop    %edi
  800e18:	5d                   	pop    %ebp
  800e19:	c3                   	ret    

00800e1a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e1a:	55                   	push   %ebp
  800e1b:	89 e5                	mov    %esp,%ebp
  800e1d:	57                   	push   %edi
  800e1e:	56                   	push   %esi
  800e1f:	53                   	push   %ebx
  800e20:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e23:	be 00 00 00 00       	mov    $0x0,%esi
  800e28:	b8 04 00 00 00       	mov    $0x4,%eax
  800e2d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e30:	8b 55 08             	mov    0x8(%ebp),%edx
  800e33:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e36:	89 f7                	mov    %esi,%edi
  800e38:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e3a:	85 c0                	test   %eax,%eax
  800e3c:	7e 17                	jle    800e55 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e3e:	83 ec 0c             	sub    $0xc,%esp
  800e41:	50                   	push   %eax
  800e42:	6a 04                	push   $0x4
  800e44:	68 df 28 80 00       	push   $0x8028df
  800e49:	6a 23                	push   $0x23
  800e4b:	68 fc 28 80 00       	push   $0x8028fc
  800e50:	e8 bd f4 ff ff       	call   800312 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e55:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e58:	5b                   	pop    %ebx
  800e59:	5e                   	pop    %esi
  800e5a:	5f                   	pop    %edi
  800e5b:	5d                   	pop    %ebp
  800e5c:	c3                   	ret    

00800e5d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e5d:	55                   	push   %ebp
  800e5e:	89 e5                	mov    %esp,%ebp
  800e60:	57                   	push   %edi
  800e61:	56                   	push   %esi
  800e62:	53                   	push   %ebx
  800e63:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e66:	b8 05 00 00 00       	mov    $0x5,%eax
  800e6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e6e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e71:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e74:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e77:	8b 75 18             	mov    0x18(%ebp),%esi
  800e7a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e7c:	85 c0                	test   %eax,%eax
  800e7e:	7e 17                	jle    800e97 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e80:	83 ec 0c             	sub    $0xc,%esp
  800e83:	50                   	push   %eax
  800e84:	6a 05                	push   $0x5
  800e86:	68 df 28 80 00       	push   $0x8028df
  800e8b:	6a 23                	push   $0x23
  800e8d:	68 fc 28 80 00       	push   $0x8028fc
  800e92:	e8 7b f4 ff ff       	call   800312 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e97:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e9a:	5b                   	pop    %ebx
  800e9b:	5e                   	pop    %esi
  800e9c:	5f                   	pop    %edi
  800e9d:	5d                   	pop    %ebp
  800e9e:	c3                   	ret    

00800e9f <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e9f:	55                   	push   %ebp
  800ea0:	89 e5                	mov    %esp,%ebp
  800ea2:	57                   	push   %edi
  800ea3:	56                   	push   %esi
  800ea4:	53                   	push   %ebx
  800ea5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ea8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ead:	b8 06 00 00 00       	mov    $0x6,%eax
  800eb2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb5:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb8:	89 df                	mov    %ebx,%edi
  800eba:	89 de                	mov    %ebx,%esi
  800ebc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ebe:	85 c0                	test   %eax,%eax
  800ec0:	7e 17                	jle    800ed9 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ec2:	83 ec 0c             	sub    $0xc,%esp
  800ec5:	50                   	push   %eax
  800ec6:	6a 06                	push   $0x6
  800ec8:	68 df 28 80 00       	push   $0x8028df
  800ecd:	6a 23                	push   $0x23
  800ecf:	68 fc 28 80 00       	push   $0x8028fc
  800ed4:	e8 39 f4 ff ff       	call   800312 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ed9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800edc:	5b                   	pop    %ebx
  800edd:	5e                   	pop    %esi
  800ede:	5f                   	pop    %edi
  800edf:	5d                   	pop    %ebp
  800ee0:	c3                   	ret    

00800ee1 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ee1:	55                   	push   %ebp
  800ee2:	89 e5                	mov    %esp,%ebp
  800ee4:	57                   	push   %edi
  800ee5:	56                   	push   %esi
  800ee6:	53                   	push   %ebx
  800ee7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eea:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eef:	b8 08 00 00 00       	mov    $0x8,%eax
  800ef4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef7:	8b 55 08             	mov    0x8(%ebp),%edx
  800efa:	89 df                	mov    %ebx,%edi
  800efc:	89 de                	mov    %ebx,%esi
  800efe:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f00:	85 c0                	test   %eax,%eax
  800f02:	7e 17                	jle    800f1b <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f04:	83 ec 0c             	sub    $0xc,%esp
  800f07:	50                   	push   %eax
  800f08:	6a 08                	push   $0x8
  800f0a:	68 df 28 80 00       	push   $0x8028df
  800f0f:	6a 23                	push   $0x23
  800f11:	68 fc 28 80 00       	push   $0x8028fc
  800f16:	e8 f7 f3 ff ff       	call   800312 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f1b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f1e:	5b                   	pop    %ebx
  800f1f:	5e                   	pop    %esi
  800f20:	5f                   	pop    %edi
  800f21:	5d                   	pop    %ebp
  800f22:	c3                   	ret    

00800f23 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f23:	55                   	push   %ebp
  800f24:	89 e5                	mov    %esp,%ebp
  800f26:	57                   	push   %edi
  800f27:	56                   	push   %esi
  800f28:	53                   	push   %ebx
  800f29:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f2c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f31:	b8 09 00 00 00       	mov    $0x9,%eax
  800f36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f39:	8b 55 08             	mov    0x8(%ebp),%edx
  800f3c:	89 df                	mov    %ebx,%edi
  800f3e:	89 de                	mov    %ebx,%esi
  800f40:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f42:	85 c0                	test   %eax,%eax
  800f44:	7e 17                	jle    800f5d <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f46:	83 ec 0c             	sub    $0xc,%esp
  800f49:	50                   	push   %eax
  800f4a:	6a 09                	push   $0x9
  800f4c:	68 df 28 80 00       	push   $0x8028df
  800f51:	6a 23                	push   $0x23
  800f53:	68 fc 28 80 00       	push   $0x8028fc
  800f58:	e8 b5 f3 ff ff       	call   800312 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800f5d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f60:	5b                   	pop    %ebx
  800f61:	5e                   	pop    %esi
  800f62:	5f                   	pop    %edi
  800f63:	5d                   	pop    %ebp
  800f64:	c3                   	ret    

00800f65 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f65:	55                   	push   %ebp
  800f66:	89 e5                	mov    %esp,%ebp
  800f68:	57                   	push   %edi
  800f69:	56                   	push   %esi
  800f6a:	53                   	push   %ebx
  800f6b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f6e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f73:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f7e:	89 df                	mov    %ebx,%edi
  800f80:	89 de                	mov    %ebx,%esi
  800f82:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f84:	85 c0                	test   %eax,%eax
  800f86:	7e 17                	jle    800f9f <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f88:	83 ec 0c             	sub    $0xc,%esp
  800f8b:	50                   	push   %eax
  800f8c:	6a 0a                	push   $0xa
  800f8e:	68 df 28 80 00       	push   $0x8028df
  800f93:	6a 23                	push   $0x23
  800f95:	68 fc 28 80 00       	push   $0x8028fc
  800f9a:	e8 73 f3 ff ff       	call   800312 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f9f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fa2:	5b                   	pop    %ebx
  800fa3:	5e                   	pop    %esi
  800fa4:	5f                   	pop    %edi
  800fa5:	5d                   	pop    %ebp
  800fa6:	c3                   	ret    

00800fa7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800fa7:	55                   	push   %ebp
  800fa8:	89 e5                	mov    %esp,%ebp
  800faa:	57                   	push   %edi
  800fab:	56                   	push   %esi
  800fac:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fad:	be 00 00 00 00       	mov    $0x0,%esi
  800fb2:	b8 0c 00 00 00       	mov    $0xc,%eax
  800fb7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fba:	8b 55 08             	mov    0x8(%ebp),%edx
  800fbd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fc0:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fc3:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800fc5:	5b                   	pop    %ebx
  800fc6:	5e                   	pop    %esi
  800fc7:	5f                   	pop    %edi
  800fc8:	5d                   	pop    %ebp
  800fc9:	c3                   	ret    

00800fca <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800fca:	55                   	push   %ebp
  800fcb:	89 e5                	mov    %esp,%ebp
  800fcd:	57                   	push   %edi
  800fce:	56                   	push   %esi
  800fcf:	53                   	push   %ebx
  800fd0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fd3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fd8:	b8 0d 00 00 00       	mov    $0xd,%eax
  800fdd:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe0:	89 cb                	mov    %ecx,%ebx
  800fe2:	89 cf                	mov    %ecx,%edi
  800fe4:	89 ce                	mov    %ecx,%esi
  800fe6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fe8:	85 c0                	test   %eax,%eax
  800fea:	7e 17                	jle    801003 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fec:	83 ec 0c             	sub    $0xc,%esp
  800fef:	50                   	push   %eax
  800ff0:	6a 0d                	push   $0xd
  800ff2:	68 df 28 80 00       	push   $0x8028df
  800ff7:	6a 23                	push   $0x23
  800ff9:	68 fc 28 80 00       	push   $0x8028fc
  800ffe:	e8 0f f3 ff ff       	call   800312 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801003:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801006:	5b                   	pop    %ebx
  801007:	5e                   	pop    %esi
  801008:	5f                   	pop    %edi
  801009:	5d                   	pop    %ebp
  80100a:	c3                   	ret    

0080100b <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  80100b:	55                   	push   %ebp
  80100c:	89 e5                	mov    %esp,%ebp
  80100e:	53                   	push   %ebx
  80100f:	83 ec 04             	sub    $0x4,%esp
  801012:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  801015:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & 
  801017:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  80101b:	0f 84 48 01 00 00    	je     801169 <pgfault+0x15e>
  801021:	89 d8                	mov    %ebx,%eax
  801023:	c1 e8 16             	shr    $0x16,%eax
  801026:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80102d:	a8 01                	test   $0x1,%al
  80102f:	0f 84 5f 01 00 00    	je     801194 <pgfault+0x189>
  801035:	89 d8                	mov    %ebx,%eax
  801037:	c1 e8 0c             	shr    $0xc,%eax
  80103a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801041:	f6 c2 01             	test   $0x1,%dl
  801044:	0f 84 4a 01 00 00    	je     801194 <pgfault+0x189>
				PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW))) {
  80104a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & 
  801051:	f6 c4 08             	test   $0x8,%ah
  801054:	75 79                	jne    8010cf <pgfault+0xc4>
  801056:	e9 39 01 00 00       	jmp    801194 <pgfault+0x189>
				PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW))) {
		cprintf("Fault address = %08x, envid = %08x\n", addr, thisenv->env_id);
		if (!(err & FEC_WR)) cprintf("Not write\n");
		if (!(uvpd[PDX(addr)] & PTE_P)) cprintf("PDE not present\n");
  80105b:	89 d8                	mov    %ebx,%eax
  80105d:	c1 e8 16             	shr    $0x16,%eax
  801060:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801067:	a8 01                	test   $0x1,%al
  801069:	75 10                	jne    80107b <pgfault+0x70>
  80106b:	83 ec 0c             	sub    $0xc,%esp
  80106e:	68 0a 29 80 00       	push   $0x80290a
  801073:	e8 73 f3 ff ff       	call   8003eb <cprintf>
  801078:	83 c4 10             	add    $0x10,%esp
		if (!(uvpt[PTX(addr)] & PTE_P)) cprintf("PTE not present\n");
  80107b:	c1 eb 0c             	shr    $0xc,%ebx
  80107e:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  801084:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  80108b:	a8 01                	test   $0x1,%al
  80108d:	75 10                	jne    80109f <pgfault+0x94>
  80108f:	83 ec 0c             	sub    $0xc,%esp
  801092:	68 1b 29 80 00       	push   $0x80291b
  801097:	e8 4f f3 ff ff       	call   8003eb <cprintf>
  80109c:	83 c4 10             	add    $0x10,%esp
		if (!(uvpt[PTX(addr)] & PTE_COW)) cprintf("Not copy-on-write\n");
  80109f:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  8010a6:	f6 c4 08             	test   $0x8,%ah
  8010a9:	75 10                	jne    8010bb <pgfault+0xb0>
  8010ab:	83 ec 0c             	sub    $0xc,%esp
  8010ae:	68 2c 29 80 00       	push   $0x80292c
  8010b3:	e8 33 f3 ff ff       	call   8003eb <cprintf>
  8010b8:	83 c4 10             	add    $0x10,%esp
		panic("User page fault");
  8010bb:	83 ec 04             	sub    $0x4,%esp
  8010be:	68 3f 29 80 00       	push   $0x80293f
  8010c3:	6a 23                	push   $0x23
  8010c5:	68 4f 29 80 00       	push   $0x80294f
  8010ca:	e8 43 f2 ff ff       	call   800312 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// 0 refers to curenv
	if ((r = sys_page_alloc(0, (void*)PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  8010cf:	83 ec 04             	sub    $0x4,%esp
  8010d2:	6a 07                	push   $0x7
  8010d4:	68 00 f0 7f 00       	push   $0x7ff000
  8010d9:	6a 00                	push   $0x0
  8010db:	e8 3a fd ff ff       	call   800e1a <sys_page_alloc>
  8010e0:	83 c4 10             	add    $0x10,%esp
  8010e3:	85 c0                	test   %eax,%eax
  8010e5:	79 12                	jns    8010f9 <pgfault+0xee>
		panic("sys_page_alloc failed: %e", r);
  8010e7:	50                   	push   %eax
  8010e8:	68 5a 29 80 00       	push   $0x80295a
  8010ed:	6a 2f                	push   $0x2f
  8010ef:	68 4f 29 80 00       	push   $0x80294f
  8010f4:	e8 19 f2 ff ff       	call   800312 <_panic>
	memcpy((void*)PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  8010f9:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  8010ff:	83 ec 04             	sub    $0x4,%esp
  801102:	68 00 10 00 00       	push   $0x1000
  801107:	53                   	push   %ebx
  801108:	68 00 f0 7f 00       	push   $0x7ff000
  80110d:	e8 ff fa ff ff       	call   800c11 <memcpy>
	if ((r = sys_page_map(0, (void*)PFTEMP, 0, (void*)ROUNDDOWN(addr, PGSIZE), 
  801112:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  801119:	53                   	push   %ebx
  80111a:	6a 00                	push   $0x0
  80111c:	68 00 f0 7f 00       	push   $0x7ff000
  801121:	6a 00                	push   $0x0
  801123:	e8 35 fd ff ff       	call   800e5d <sys_page_map>
  801128:	83 c4 20             	add    $0x20,%esp
  80112b:	85 c0                	test   %eax,%eax
  80112d:	79 12                	jns    801141 <pgfault+0x136>
					PTE_P | PTE_U | PTE_W)) < 0)
		panic("sys_page_map failed: %e", r);
  80112f:	50                   	push   %eax
  801130:	68 74 29 80 00       	push   $0x802974
  801135:	6a 33                	push   $0x33
  801137:	68 4f 29 80 00       	push   $0x80294f
  80113c:	e8 d1 f1 ff ff       	call   800312 <_panic>
	if ((r = sys_page_unmap(0, (void*)PFTEMP)) < 0)
  801141:	83 ec 08             	sub    $0x8,%esp
  801144:	68 00 f0 7f 00       	push   $0x7ff000
  801149:	6a 00                	push   $0x0
  80114b:	e8 4f fd ff ff       	call   800e9f <sys_page_unmap>
  801150:	83 c4 10             	add    $0x10,%esp
  801153:	85 c0                	test   %eax,%eax
  801155:	79 5c                	jns    8011b3 <pgfault+0x1a8>
		panic("sys_page_unmap failed: %e", r);
  801157:	50                   	push   %eax
  801158:	68 8c 29 80 00       	push   $0x80298c
  80115d:	6a 35                	push   $0x35
  80115f:	68 4f 29 80 00       	push   $0x80294f
  801164:	e8 a9 f1 ff ff       	call   800312 <_panic>
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & 
				PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW))) {
		cprintf("Fault address = %08x, envid = %08x\n", addr, thisenv->env_id);
  801169:	a1 04 40 80 00       	mov    0x804004,%eax
  80116e:	8b 40 48             	mov    0x48(%eax),%eax
  801171:	83 ec 04             	sub    $0x4,%esp
  801174:	50                   	push   %eax
  801175:	53                   	push   %ebx
  801176:	68 c8 29 80 00       	push   $0x8029c8
  80117b:	e8 6b f2 ff ff       	call   8003eb <cprintf>
		if (!(err & FEC_WR)) cprintf("Not write\n");
  801180:	c7 04 24 a6 29 80 00 	movl   $0x8029a6,(%esp)
  801187:	e8 5f f2 ff ff       	call   8003eb <cprintf>
  80118c:	83 c4 10             	add    $0x10,%esp
  80118f:	e9 c7 fe ff ff       	jmp    80105b <pgfault+0x50>
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & 
				PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW))) {
		cprintf("Fault address = %08x, envid = %08x\n", addr, thisenv->env_id);
  801194:	a1 04 40 80 00       	mov    0x804004,%eax
  801199:	8b 40 48             	mov    0x48(%eax),%eax
  80119c:	83 ec 04             	sub    $0x4,%esp
  80119f:	50                   	push   %eax
  8011a0:	53                   	push   %ebx
  8011a1:	68 c8 29 80 00       	push   $0x8029c8
  8011a6:	e8 40 f2 ff ff       	call   8003eb <cprintf>
  8011ab:	83 c4 10             	add    $0x10,%esp
  8011ae:	e9 a8 fe ff ff       	jmp    80105b <pgfault+0x50>
		panic("sys_page_map failed: %e", r);
	if ((r = sys_page_unmap(0, (void*)PFTEMP)) < 0)
		panic("sys_page_unmap failed: %e", r);

	// panic("pgfault not implemented");
}
  8011b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011b6:	c9                   	leave  
  8011b7:	c3                   	ret    

008011b8 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8011b8:	55                   	push   %ebp
  8011b9:	89 e5                	mov    %esp,%ebp
  8011bb:	57                   	push   %edi
  8011bc:	56                   	push   %esi
  8011bd:	53                   	push   %ebx
  8011be:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	int ret;
	set_pgfault_handler(pgfault);
  8011c1:	68 0b 10 80 00       	push   $0x80100b
  8011c6:	e8 57 0e 00 00       	call   802022 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8011cb:	b8 07 00 00 00       	mov    $0x7,%eax
  8011d0:	cd 30                	int    $0x30
  8011d2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8011d5:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	envid_t envid = sys_exofork();

	if (envid < 0) return envid;
  8011d8:	83 c4 10             	add    $0x10,%esp
  8011db:	85 c0                	test   %eax,%eax
  8011dd:	0f 88 0d 01 00 00    	js     8012f0 <fork+0x138>
  8011e3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011e8:	be 00 00 00 00       	mov    $0x0,%esi
	else if (envid == 0) {
  8011ed:	85 c0                	test   %eax,%eax
  8011ef:	75 2f                	jne    801220 <fork+0x68>
		// Child returns
		thisenv = &envs[ENVX(sys_getenvid())];
  8011f1:	e8 e6 fb ff ff       	call   800ddc <sys_getenvid>
  8011f6:	25 ff 03 00 00       	and    $0x3ff,%eax
  8011fb:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8011fe:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801203:	a3 04 40 80 00       	mov    %eax,0x804004
		// set_pgfault_handler(pgfault);
		return 0;
  801208:	b8 00 00 00 00       	mov    $0x0,%eax
  80120d:	e9 e1 00 00 00       	jmp    8012f3 <fork+0x13b>
  801212:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
	}
	else {
		uint32_t pn;
		for (pn = 0; pn * PGSIZE < UTOP; pn++){
			// cprintf("virtual page %08x\n", pn * PGSIZE);
			if (pn * PGSIZE == UXSTACKTOP - PGSIZE) 
  801218:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  80121e:	74 77                	je     801297 <fork+0xdf>
{
	int r;

	// LAB 4: Your code here.
	int perm = PTE_P | PTE_U;
	pde_t pde = uvpd[pn / NPTENTRIES];
  801220:	89 f0                	mov    %esi,%eax
  801222:	c1 e8 0a             	shr    $0xa,%eax
  801225:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
	if (!(pde & PTE_P)) return 0;
  80122c:	a8 01                	test   $0x1,%al
  80122e:	74 0b                	je     80123b <fork+0x83>
	pte_t pte = uvpt[pn];
  801230:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	if (!(pte & PTE_P)) return 0;
  801237:	a8 01                	test   $0x1,%al
  801239:	75 08                	jne    801243 <fork+0x8b>
  80123b:	8d 5e 01             	lea    0x1(%esi),%ebx
  80123e:	c1 e3 0c             	shl    $0xc,%ebx
  801241:	eb 56                	jmp    801299 <fork+0xe1>
	// cprintf("virtual page %08x\n", pn * PGSIZE);

	if ((pte & PTE_W) || (pte & PTE_COW)) perm |= PTE_COW;
  801243:	25 02 08 00 00       	and    $0x802,%eax
  801248:	83 f8 01             	cmp    $0x1,%eax
  80124b:	19 ff                	sbb    %edi,%edi
  80124d:	81 e7 00 f8 ff ff    	and    $0xfffff800,%edi
  801253:	81 c7 05 08 00 00    	add    $0x805,%edi

	if ((r = sys_page_map(thisenv->env_id, (void*)(pn * PGSIZE), envid, 
  801259:	a1 04 40 80 00       	mov    0x804004,%eax
  80125e:	8b 40 48             	mov    0x48(%eax),%eax
  801261:	83 ec 0c             	sub    $0xc,%esp
  801264:	57                   	push   %edi
  801265:	53                   	push   %ebx
  801266:	ff 75 e4             	pushl  -0x1c(%ebp)
  801269:	53                   	push   %ebx
  80126a:	50                   	push   %eax
  80126b:	e8 ed fb ff ff       	call   800e5d <sys_page_map>
  801270:	83 c4 20             	add    $0x20,%esp
  801273:	85 c0                	test   %eax,%eax
  801275:	78 7c                	js     8012f3 <fork+0x13b>
				(void*)(pn * PGSIZE), perm)) < 0) 
		return r;
	r = sys_page_map(envid, (void*)(pn * PGSIZE), thisenv->env_id, 
  801277:	a1 04 40 80 00       	mov    0x804004,%eax
  80127c:	8b 40 48             	mov    0x48(%eax),%eax
  80127f:	83 ec 0c             	sub    $0xc,%esp
  801282:	57                   	push   %edi
  801283:	53                   	push   %ebx
  801284:	50                   	push   %eax
  801285:	53                   	push   %ebx
  801286:	ff 75 e4             	pushl  -0x1c(%ebp)
  801289:	e8 cf fb ff ff       	call   800e5d <sys_page_map>
		uint32_t pn;
		for (pn = 0; pn * PGSIZE < UTOP; pn++){
			// cprintf("virtual page %08x\n", pn * PGSIZE);
			if (pn * PGSIZE == UXSTACKTOP - PGSIZE) 
				continue;
			if ((ret = duppage(envid, pn)) < 0)
  80128e:	83 c4 20             	add    $0x20,%esp
  801291:	85 c0                	test   %eax,%eax
  801293:	79 a6                	jns    80123b <fork+0x83>
  801295:	eb 5c                	jmp    8012f3 <fork+0x13b>
  801297:	89 c3                	mov    %eax,%ebx
		// set_pgfault_handler(pgfault);
		return 0;
	}
	else {
		uint32_t pn;
		for (pn = 0; pn * PGSIZE < UTOP; pn++){
  801299:	83 c6 01             	add    $0x1,%esi
  80129c:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
  8012a2:	0f 86 6a ff ff ff    	jbe    801212 <fork+0x5a>
				return ret;
		}
		// cprintf("Fork: duppage finished\n");

		// Should be done by parent
		if ((ret = sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P |
  8012a8:	83 ec 04             	sub    $0x4,%esp
  8012ab:	6a 07                	push   $0x7
  8012ad:	68 00 f0 bf ee       	push   $0xeebff000
  8012b2:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8012b5:	57                   	push   %edi
  8012b6:	e8 5f fb ff ff       	call   800e1a <sys_page_alloc>
  8012bb:	83 c4 10             	add    $0x10,%esp
  8012be:	85 c0                	test   %eax,%eax
  8012c0:	78 31                	js     8012f3 <fork+0x13b>
						PTE_U | PTE_W)) < 0)
			return ret;
		if ((ret = sys_env_set_pgfault_upcall(envid, 
						thisenv->env_pgfault_upcall)) < 0)
  8012c2:	a1 04 40 80 00       	mov    0x804004,%eax

		// Should be done by parent
		if ((ret = sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P |
						PTE_U | PTE_W)) < 0)
			return ret;
		if ((ret = sys_env_set_pgfault_upcall(envid, 
  8012c7:	8b 40 64             	mov    0x64(%eax),%eax
  8012ca:	83 ec 08             	sub    $0x8,%esp
  8012cd:	50                   	push   %eax
  8012ce:	57                   	push   %edi
  8012cf:	e8 91 fc ff ff       	call   800f65 <sys_env_set_pgfault_upcall>
  8012d4:	83 c4 10             	add    $0x10,%esp
  8012d7:	85 c0                	test   %eax,%eax
  8012d9:	78 18                	js     8012f3 <fork+0x13b>
						thisenv->env_pgfault_upcall)) < 0)
			return ret;

		if ((ret = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8012db:	83 ec 08             	sub    $0x8,%esp
  8012de:	6a 02                	push   $0x2
  8012e0:	57                   	push   %edi
  8012e1:	e8 fb fb ff ff       	call   800ee1 <sys_env_set_status>
  8012e6:	83 c4 10             	add    $0x10,%esp
			return ret;
		return envid;
  8012e9:	85 c0                	test   %eax,%eax
  8012eb:	0f 49 c7             	cmovns %edi,%eax
  8012ee:	eb 03                	jmp    8012f3 <fork+0x13b>
	int ret;
	set_pgfault_handler(pgfault);

	envid_t envid = sys_exofork();

	if (envid < 0) return envid;
  8012f0:	8b 45 e0             	mov    -0x20(%ebp),%eax
			return ret;
		return envid;
	}

	panic("fork not implemented");
}
  8012f3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012f6:	5b                   	pop    %ebx
  8012f7:	5e                   	pop    %esi
  8012f8:	5f                   	pop    %edi
  8012f9:	5d                   	pop    %ebp
  8012fa:	c3                   	ret    

008012fb <sfork>:

// Challenge!
int
sfork(void)
{
  8012fb:	55                   	push   %ebp
  8012fc:	89 e5                	mov    %esp,%ebp
  8012fe:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801301:	68 b1 29 80 00       	push   $0x8029b1
  801306:	68 9f 00 00 00       	push   $0x9f
  80130b:	68 4f 29 80 00       	push   $0x80294f
  801310:	e8 fd ef ff ff       	call   800312 <_panic>

00801315 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801315:	55                   	push   %ebp
  801316:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801318:	8b 45 08             	mov    0x8(%ebp),%eax
  80131b:	05 00 00 00 30       	add    $0x30000000,%eax
  801320:	c1 e8 0c             	shr    $0xc,%eax
}
  801323:	5d                   	pop    %ebp
  801324:	c3                   	ret    

00801325 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801325:	55                   	push   %ebp
  801326:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801328:	8b 45 08             	mov    0x8(%ebp),%eax
  80132b:	05 00 00 00 30       	add    $0x30000000,%eax
  801330:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801335:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80133a:	5d                   	pop    %ebp
  80133b:	c3                   	ret    

0080133c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80133c:	55                   	push   %ebp
  80133d:	89 e5                	mov    %esp,%ebp
  80133f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801342:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801347:	89 c2                	mov    %eax,%edx
  801349:	c1 ea 16             	shr    $0x16,%edx
  80134c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801353:	f6 c2 01             	test   $0x1,%dl
  801356:	74 11                	je     801369 <fd_alloc+0x2d>
  801358:	89 c2                	mov    %eax,%edx
  80135a:	c1 ea 0c             	shr    $0xc,%edx
  80135d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801364:	f6 c2 01             	test   $0x1,%dl
  801367:	75 09                	jne    801372 <fd_alloc+0x36>
			*fd_store = fd;
  801369:	89 01                	mov    %eax,(%ecx)
			return 0;
  80136b:	b8 00 00 00 00       	mov    $0x0,%eax
  801370:	eb 17                	jmp    801389 <fd_alloc+0x4d>
  801372:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801377:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80137c:	75 c9                	jne    801347 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80137e:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801384:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801389:	5d                   	pop    %ebp
  80138a:	c3                   	ret    

0080138b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80138b:	55                   	push   %ebp
  80138c:	89 e5                	mov    %esp,%ebp
  80138e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801391:	83 f8 1f             	cmp    $0x1f,%eax
  801394:	77 36                	ja     8013cc <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801396:	c1 e0 0c             	shl    $0xc,%eax
  801399:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80139e:	89 c2                	mov    %eax,%edx
  8013a0:	c1 ea 16             	shr    $0x16,%edx
  8013a3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013aa:	f6 c2 01             	test   $0x1,%dl
  8013ad:	74 24                	je     8013d3 <fd_lookup+0x48>
  8013af:	89 c2                	mov    %eax,%edx
  8013b1:	c1 ea 0c             	shr    $0xc,%edx
  8013b4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013bb:	f6 c2 01             	test   $0x1,%dl
  8013be:	74 1a                	je     8013da <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8013c0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013c3:	89 02                	mov    %eax,(%edx)
	return 0;
  8013c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8013ca:	eb 13                	jmp    8013df <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8013cc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013d1:	eb 0c                	jmp    8013df <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8013d3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013d8:	eb 05                	jmp    8013df <fd_lookup+0x54>
  8013da:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8013df:	5d                   	pop    %ebp
  8013e0:	c3                   	ret    

008013e1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8013e1:	55                   	push   %ebp
  8013e2:	89 e5                	mov    %esp,%ebp
  8013e4:	83 ec 08             	sub    $0x8,%esp
  8013e7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013ea:	ba 6c 2a 80 00       	mov    $0x802a6c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8013ef:	eb 13                	jmp    801404 <dev_lookup+0x23>
  8013f1:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8013f4:	39 08                	cmp    %ecx,(%eax)
  8013f6:	75 0c                	jne    801404 <dev_lookup+0x23>
			*dev = devtab[i];
  8013f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013fb:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013fd:	b8 00 00 00 00       	mov    $0x0,%eax
  801402:	eb 2e                	jmp    801432 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801404:	8b 02                	mov    (%edx),%eax
  801406:	85 c0                	test   %eax,%eax
  801408:	75 e7                	jne    8013f1 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80140a:	a1 04 40 80 00       	mov    0x804004,%eax
  80140f:	8b 40 48             	mov    0x48(%eax),%eax
  801412:	83 ec 04             	sub    $0x4,%esp
  801415:	51                   	push   %ecx
  801416:	50                   	push   %eax
  801417:	68 ec 29 80 00       	push   $0x8029ec
  80141c:	e8 ca ef ff ff       	call   8003eb <cprintf>
	*dev = 0;
  801421:	8b 45 0c             	mov    0xc(%ebp),%eax
  801424:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80142a:	83 c4 10             	add    $0x10,%esp
  80142d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801432:	c9                   	leave  
  801433:	c3                   	ret    

00801434 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801434:	55                   	push   %ebp
  801435:	89 e5                	mov    %esp,%ebp
  801437:	56                   	push   %esi
  801438:	53                   	push   %ebx
  801439:	83 ec 10             	sub    $0x10,%esp
  80143c:	8b 75 08             	mov    0x8(%ebp),%esi
  80143f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801442:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801445:	50                   	push   %eax
  801446:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80144c:	c1 e8 0c             	shr    $0xc,%eax
  80144f:	50                   	push   %eax
  801450:	e8 36 ff ff ff       	call   80138b <fd_lookup>
  801455:	83 c4 08             	add    $0x8,%esp
  801458:	85 c0                	test   %eax,%eax
  80145a:	78 05                	js     801461 <fd_close+0x2d>
	    || fd != fd2)
  80145c:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80145f:	74 0c                	je     80146d <fd_close+0x39>
		return (must_exist ? r : 0);
  801461:	84 db                	test   %bl,%bl
  801463:	ba 00 00 00 00       	mov    $0x0,%edx
  801468:	0f 44 c2             	cmove  %edx,%eax
  80146b:	eb 41                	jmp    8014ae <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80146d:	83 ec 08             	sub    $0x8,%esp
  801470:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801473:	50                   	push   %eax
  801474:	ff 36                	pushl  (%esi)
  801476:	e8 66 ff ff ff       	call   8013e1 <dev_lookup>
  80147b:	89 c3                	mov    %eax,%ebx
  80147d:	83 c4 10             	add    $0x10,%esp
  801480:	85 c0                	test   %eax,%eax
  801482:	78 1a                	js     80149e <fd_close+0x6a>
		if (dev->dev_close)
  801484:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801487:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80148a:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80148f:	85 c0                	test   %eax,%eax
  801491:	74 0b                	je     80149e <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801493:	83 ec 0c             	sub    $0xc,%esp
  801496:	56                   	push   %esi
  801497:	ff d0                	call   *%eax
  801499:	89 c3                	mov    %eax,%ebx
  80149b:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80149e:	83 ec 08             	sub    $0x8,%esp
  8014a1:	56                   	push   %esi
  8014a2:	6a 00                	push   $0x0
  8014a4:	e8 f6 f9 ff ff       	call   800e9f <sys_page_unmap>
	return r;
  8014a9:	83 c4 10             	add    $0x10,%esp
  8014ac:	89 d8                	mov    %ebx,%eax
}
  8014ae:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014b1:	5b                   	pop    %ebx
  8014b2:	5e                   	pop    %esi
  8014b3:	5d                   	pop    %ebp
  8014b4:	c3                   	ret    

008014b5 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8014b5:	55                   	push   %ebp
  8014b6:	89 e5                	mov    %esp,%ebp
  8014b8:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014be:	50                   	push   %eax
  8014bf:	ff 75 08             	pushl  0x8(%ebp)
  8014c2:	e8 c4 fe ff ff       	call   80138b <fd_lookup>
  8014c7:	83 c4 08             	add    $0x8,%esp
  8014ca:	85 c0                	test   %eax,%eax
  8014cc:	78 10                	js     8014de <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8014ce:	83 ec 08             	sub    $0x8,%esp
  8014d1:	6a 01                	push   $0x1
  8014d3:	ff 75 f4             	pushl  -0xc(%ebp)
  8014d6:	e8 59 ff ff ff       	call   801434 <fd_close>
  8014db:	83 c4 10             	add    $0x10,%esp
}
  8014de:	c9                   	leave  
  8014df:	c3                   	ret    

008014e0 <close_all>:

void
close_all(void)
{
  8014e0:	55                   	push   %ebp
  8014e1:	89 e5                	mov    %esp,%ebp
  8014e3:	53                   	push   %ebx
  8014e4:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8014e7:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8014ec:	83 ec 0c             	sub    $0xc,%esp
  8014ef:	53                   	push   %ebx
  8014f0:	e8 c0 ff ff ff       	call   8014b5 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8014f5:	83 c3 01             	add    $0x1,%ebx
  8014f8:	83 c4 10             	add    $0x10,%esp
  8014fb:	83 fb 20             	cmp    $0x20,%ebx
  8014fe:	75 ec                	jne    8014ec <close_all+0xc>
		close(i);
}
  801500:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801503:	c9                   	leave  
  801504:	c3                   	ret    

00801505 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801505:	55                   	push   %ebp
  801506:	89 e5                	mov    %esp,%ebp
  801508:	57                   	push   %edi
  801509:	56                   	push   %esi
  80150a:	53                   	push   %ebx
  80150b:	83 ec 2c             	sub    $0x2c,%esp
  80150e:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801511:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801514:	50                   	push   %eax
  801515:	ff 75 08             	pushl  0x8(%ebp)
  801518:	e8 6e fe ff ff       	call   80138b <fd_lookup>
  80151d:	83 c4 08             	add    $0x8,%esp
  801520:	85 c0                	test   %eax,%eax
  801522:	0f 88 c1 00 00 00    	js     8015e9 <dup+0xe4>
		return r;
	close(newfdnum);
  801528:	83 ec 0c             	sub    $0xc,%esp
  80152b:	56                   	push   %esi
  80152c:	e8 84 ff ff ff       	call   8014b5 <close>

	newfd = INDEX2FD(newfdnum);
  801531:	89 f3                	mov    %esi,%ebx
  801533:	c1 e3 0c             	shl    $0xc,%ebx
  801536:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80153c:	83 c4 04             	add    $0x4,%esp
  80153f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801542:	e8 de fd ff ff       	call   801325 <fd2data>
  801547:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801549:	89 1c 24             	mov    %ebx,(%esp)
  80154c:	e8 d4 fd ff ff       	call   801325 <fd2data>
  801551:	83 c4 10             	add    $0x10,%esp
  801554:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801557:	89 f8                	mov    %edi,%eax
  801559:	c1 e8 16             	shr    $0x16,%eax
  80155c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801563:	a8 01                	test   $0x1,%al
  801565:	74 37                	je     80159e <dup+0x99>
  801567:	89 f8                	mov    %edi,%eax
  801569:	c1 e8 0c             	shr    $0xc,%eax
  80156c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801573:	f6 c2 01             	test   $0x1,%dl
  801576:	74 26                	je     80159e <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801578:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80157f:	83 ec 0c             	sub    $0xc,%esp
  801582:	25 07 0e 00 00       	and    $0xe07,%eax
  801587:	50                   	push   %eax
  801588:	ff 75 d4             	pushl  -0x2c(%ebp)
  80158b:	6a 00                	push   $0x0
  80158d:	57                   	push   %edi
  80158e:	6a 00                	push   $0x0
  801590:	e8 c8 f8 ff ff       	call   800e5d <sys_page_map>
  801595:	89 c7                	mov    %eax,%edi
  801597:	83 c4 20             	add    $0x20,%esp
  80159a:	85 c0                	test   %eax,%eax
  80159c:	78 2e                	js     8015cc <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80159e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8015a1:	89 d0                	mov    %edx,%eax
  8015a3:	c1 e8 0c             	shr    $0xc,%eax
  8015a6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015ad:	83 ec 0c             	sub    $0xc,%esp
  8015b0:	25 07 0e 00 00       	and    $0xe07,%eax
  8015b5:	50                   	push   %eax
  8015b6:	53                   	push   %ebx
  8015b7:	6a 00                	push   $0x0
  8015b9:	52                   	push   %edx
  8015ba:	6a 00                	push   $0x0
  8015bc:	e8 9c f8 ff ff       	call   800e5d <sys_page_map>
  8015c1:	89 c7                	mov    %eax,%edi
  8015c3:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8015c6:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015c8:	85 ff                	test   %edi,%edi
  8015ca:	79 1d                	jns    8015e9 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8015cc:	83 ec 08             	sub    $0x8,%esp
  8015cf:	53                   	push   %ebx
  8015d0:	6a 00                	push   $0x0
  8015d2:	e8 c8 f8 ff ff       	call   800e9f <sys_page_unmap>
	sys_page_unmap(0, nva);
  8015d7:	83 c4 08             	add    $0x8,%esp
  8015da:	ff 75 d4             	pushl  -0x2c(%ebp)
  8015dd:	6a 00                	push   $0x0
  8015df:	e8 bb f8 ff ff       	call   800e9f <sys_page_unmap>
	return r;
  8015e4:	83 c4 10             	add    $0x10,%esp
  8015e7:	89 f8                	mov    %edi,%eax
}
  8015e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015ec:	5b                   	pop    %ebx
  8015ed:	5e                   	pop    %esi
  8015ee:	5f                   	pop    %edi
  8015ef:	5d                   	pop    %ebp
  8015f0:	c3                   	ret    

008015f1 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8015f1:	55                   	push   %ebp
  8015f2:	89 e5                	mov    %esp,%ebp
  8015f4:	53                   	push   %ebx
  8015f5:	83 ec 14             	sub    $0x14,%esp
  8015f8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015fb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015fe:	50                   	push   %eax
  8015ff:	53                   	push   %ebx
  801600:	e8 86 fd ff ff       	call   80138b <fd_lookup>
  801605:	83 c4 08             	add    $0x8,%esp
  801608:	89 c2                	mov    %eax,%edx
  80160a:	85 c0                	test   %eax,%eax
  80160c:	78 6d                	js     80167b <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80160e:	83 ec 08             	sub    $0x8,%esp
  801611:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801614:	50                   	push   %eax
  801615:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801618:	ff 30                	pushl  (%eax)
  80161a:	e8 c2 fd ff ff       	call   8013e1 <dev_lookup>
  80161f:	83 c4 10             	add    $0x10,%esp
  801622:	85 c0                	test   %eax,%eax
  801624:	78 4c                	js     801672 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801626:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801629:	8b 42 08             	mov    0x8(%edx),%eax
  80162c:	83 e0 03             	and    $0x3,%eax
  80162f:	83 f8 01             	cmp    $0x1,%eax
  801632:	75 21                	jne    801655 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801634:	a1 04 40 80 00       	mov    0x804004,%eax
  801639:	8b 40 48             	mov    0x48(%eax),%eax
  80163c:	83 ec 04             	sub    $0x4,%esp
  80163f:	53                   	push   %ebx
  801640:	50                   	push   %eax
  801641:	68 30 2a 80 00       	push   $0x802a30
  801646:	e8 a0 ed ff ff       	call   8003eb <cprintf>
		return -E_INVAL;
  80164b:	83 c4 10             	add    $0x10,%esp
  80164e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801653:	eb 26                	jmp    80167b <read+0x8a>
	}
	if (!dev->dev_read)
  801655:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801658:	8b 40 08             	mov    0x8(%eax),%eax
  80165b:	85 c0                	test   %eax,%eax
  80165d:	74 17                	je     801676 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80165f:	83 ec 04             	sub    $0x4,%esp
  801662:	ff 75 10             	pushl  0x10(%ebp)
  801665:	ff 75 0c             	pushl  0xc(%ebp)
  801668:	52                   	push   %edx
  801669:	ff d0                	call   *%eax
  80166b:	89 c2                	mov    %eax,%edx
  80166d:	83 c4 10             	add    $0x10,%esp
  801670:	eb 09                	jmp    80167b <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801672:	89 c2                	mov    %eax,%edx
  801674:	eb 05                	jmp    80167b <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801676:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80167b:	89 d0                	mov    %edx,%eax
  80167d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801680:	c9                   	leave  
  801681:	c3                   	ret    

00801682 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801682:	55                   	push   %ebp
  801683:	89 e5                	mov    %esp,%ebp
  801685:	57                   	push   %edi
  801686:	56                   	push   %esi
  801687:	53                   	push   %ebx
  801688:	83 ec 0c             	sub    $0xc,%esp
  80168b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80168e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801691:	bb 00 00 00 00       	mov    $0x0,%ebx
  801696:	eb 21                	jmp    8016b9 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801698:	83 ec 04             	sub    $0x4,%esp
  80169b:	89 f0                	mov    %esi,%eax
  80169d:	29 d8                	sub    %ebx,%eax
  80169f:	50                   	push   %eax
  8016a0:	89 d8                	mov    %ebx,%eax
  8016a2:	03 45 0c             	add    0xc(%ebp),%eax
  8016a5:	50                   	push   %eax
  8016a6:	57                   	push   %edi
  8016a7:	e8 45 ff ff ff       	call   8015f1 <read>
		if (m < 0)
  8016ac:	83 c4 10             	add    $0x10,%esp
  8016af:	85 c0                	test   %eax,%eax
  8016b1:	78 10                	js     8016c3 <readn+0x41>
			return m;
		if (m == 0)
  8016b3:	85 c0                	test   %eax,%eax
  8016b5:	74 0a                	je     8016c1 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016b7:	01 c3                	add    %eax,%ebx
  8016b9:	39 f3                	cmp    %esi,%ebx
  8016bb:	72 db                	jb     801698 <readn+0x16>
  8016bd:	89 d8                	mov    %ebx,%eax
  8016bf:	eb 02                	jmp    8016c3 <readn+0x41>
  8016c1:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8016c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016c6:	5b                   	pop    %ebx
  8016c7:	5e                   	pop    %esi
  8016c8:	5f                   	pop    %edi
  8016c9:	5d                   	pop    %ebp
  8016ca:	c3                   	ret    

008016cb <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8016cb:	55                   	push   %ebp
  8016cc:	89 e5                	mov    %esp,%ebp
  8016ce:	53                   	push   %ebx
  8016cf:	83 ec 14             	sub    $0x14,%esp
  8016d2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016d5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016d8:	50                   	push   %eax
  8016d9:	53                   	push   %ebx
  8016da:	e8 ac fc ff ff       	call   80138b <fd_lookup>
  8016df:	83 c4 08             	add    $0x8,%esp
  8016e2:	89 c2                	mov    %eax,%edx
  8016e4:	85 c0                	test   %eax,%eax
  8016e6:	78 68                	js     801750 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016e8:	83 ec 08             	sub    $0x8,%esp
  8016eb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016ee:	50                   	push   %eax
  8016ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016f2:	ff 30                	pushl  (%eax)
  8016f4:	e8 e8 fc ff ff       	call   8013e1 <dev_lookup>
  8016f9:	83 c4 10             	add    $0x10,%esp
  8016fc:	85 c0                	test   %eax,%eax
  8016fe:	78 47                	js     801747 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801700:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801703:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801707:	75 21                	jne    80172a <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801709:	a1 04 40 80 00       	mov    0x804004,%eax
  80170e:	8b 40 48             	mov    0x48(%eax),%eax
  801711:	83 ec 04             	sub    $0x4,%esp
  801714:	53                   	push   %ebx
  801715:	50                   	push   %eax
  801716:	68 4c 2a 80 00       	push   $0x802a4c
  80171b:	e8 cb ec ff ff       	call   8003eb <cprintf>
		return -E_INVAL;
  801720:	83 c4 10             	add    $0x10,%esp
  801723:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801728:	eb 26                	jmp    801750 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80172a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80172d:	8b 52 0c             	mov    0xc(%edx),%edx
  801730:	85 d2                	test   %edx,%edx
  801732:	74 17                	je     80174b <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801734:	83 ec 04             	sub    $0x4,%esp
  801737:	ff 75 10             	pushl  0x10(%ebp)
  80173a:	ff 75 0c             	pushl  0xc(%ebp)
  80173d:	50                   	push   %eax
  80173e:	ff d2                	call   *%edx
  801740:	89 c2                	mov    %eax,%edx
  801742:	83 c4 10             	add    $0x10,%esp
  801745:	eb 09                	jmp    801750 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801747:	89 c2                	mov    %eax,%edx
  801749:	eb 05                	jmp    801750 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80174b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801750:	89 d0                	mov    %edx,%eax
  801752:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801755:	c9                   	leave  
  801756:	c3                   	ret    

00801757 <seek>:

int
seek(int fdnum, off_t offset)
{
  801757:	55                   	push   %ebp
  801758:	89 e5                	mov    %esp,%ebp
  80175a:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80175d:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801760:	50                   	push   %eax
  801761:	ff 75 08             	pushl  0x8(%ebp)
  801764:	e8 22 fc ff ff       	call   80138b <fd_lookup>
  801769:	83 c4 08             	add    $0x8,%esp
  80176c:	85 c0                	test   %eax,%eax
  80176e:	78 0e                	js     80177e <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801770:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801773:	8b 55 0c             	mov    0xc(%ebp),%edx
  801776:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801779:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80177e:	c9                   	leave  
  80177f:	c3                   	ret    

00801780 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801780:	55                   	push   %ebp
  801781:	89 e5                	mov    %esp,%ebp
  801783:	53                   	push   %ebx
  801784:	83 ec 14             	sub    $0x14,%esp
  801787:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80178a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80178d:	50                   	push   %eax
  80178e:	53                   	push   %ebx
  80178f:	e8 f7 fb ff ff       	call   80138b <fd_lookup>
  801794:	83 c4 08             	add    $0x8,%esp
  801797:	89 c2                	mov    %eax,%edx
  801799:	85 c0                	test   %eax,%eax
  80179b:	78 65                	js     801802 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80179d:	83 ec 08             	sub    $0x8,%esp
  8017a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017a3:	50                   	push   %eax
  8017a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017a7:	ff 30                	pushl  (%eax)
  8017a9:	e8 33 fc ff ff       	call   8013e1 <dev_lookup>
  8017ae:	83 c4 10             	add    $0x10,%esp
  8017b1:	85 c0                	test   %eax,%eax
  8017b3:	78 44                	js     8017f9 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017b8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017bc:	75 21                	jne    8017df <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8017be:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8017c3:	8b 40 48             	mov    0x48(%eax),%eax
  8017c6:	83 ec 04             	sub    $0x4,%esp
  8017c9:	53                   	push   %ebx
  8017ca:	50                   	push   %eax
  8017cb:	68 0c 2a 80 00       	push   $0x802a0c
  8017d0:	e8 16 ec ff ff       	call   8003eb <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8017d5:	83 c4 10             	add    $0x10,%esp
  8017d8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8017dd:	eb 23                	jmp    801802 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8017df:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017e2:	8b 52 18             	mov    0x18(%edx),%edx
  8017e5:	85 d2                	test   %edx,%edx
  8017e7:	74 14                	je     8017fd <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017e9:	83 ec 08             	sub    $0x8,%esp
  8017ec:	ff 75 0c             	pushl  0xc(%ebp)
  8017ef:	50                   	push   %eax
  8017f0:	ff d2                	call   *%edx
  8017f2:	89 c2                	mov    %eax,%edx
  8017f4:	83 c4 10             	add    $0x10,%esp
  8017f7:	eb 09                	jmp    801802 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017f9:	89 c2                	mov    %eax,%edx
  8017fb:	eb 05                	jmp    801802 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8017fd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801802:	89 d0                	mov    %edx,%eax
  801804:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801807:	c9                   	leave  
  801808:	c3                   	ret    

00801809 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801809:	55                   	push   %ebp
  80180a:	89 e5                	mov    %esp,%ebp
  80180c:	53                   	push   %ebx
  80180d:	83 ec 14             	sub    $0x14,%esp
  801810:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801813:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801816:	50                   	push   %eax
  801817:	ff 75 08             	pushl  0x8(%ebp)
  80181a:	e8 6c fb ff ff       	call   80138b <fd_lookup>
  80181f:	83 c4 08             	add    $0x8,%esp
  801822:	89 c2                	mov    %eax,%edx
  801824:	85 c0                	test   %eax,%eax
  801826:	78 58                	js     801880 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801828:	83 ec 08             	sub    $0x8,%esp
  80182b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80182e:	50                   	push   %eax
  80182f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801832:	ff 30                	pushl  (%eax)
  801834:	e8 a8 fb ff ff       	call   8013e1 <dev_lookup>
  801839:	83 c4 10             	add    $0x10,%esp
  80183c:	85 c0                	test   %eax,%eax
  80183e:	78 37                	js     801877 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801840:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801843:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801847:	74 32                	je     80187b <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801849:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80184c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801853:	00 00 00 
	stat->st_isdir = 0;
  801856:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80185d:	00 00 00 
	stat->st_dev = dev;
  801860:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801866:	83 ec 08             	sub    $0x8,%esp
  801869:	53                   	push   %ebx
  80186a:	ff 75 f0             	pushl  -0x10(%ebp)
  80186d:	ff 50 14             	call   *0x14(%eax)
  801870:	89 c2                	mov    %eax,%edx
  801872:	83 c4 10             	add    $0x10,%esp
  801875:	eb 09                	jmp    801880 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801877:	89 c2                	mov    %eax,%edx
  801879:	eb 05                	jmp    801880 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80187b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801880:	89 d0                	mov    %edx,%eax
  801882:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801885:	c9                   	leave  
  801886:	c3                   	ret    

00801887 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801887:	55                   	push   %ebp
  801888:	89 e5                	mov    %esp,%ebp
  80188a:	56                   	push   %esi
  80188b:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80188c:	83 ec 08             	sub    $0x8,%esp
  80188f:	6a 00                	push   $0x0
  801891:	ff 75 08             	pushl  0x8(%ebp)
  801894:	e8 b7 01 00 00       	call   801a50 <open>
  801899:	89 c3                	mov    %eax,%ebx
  80189b:	83 c4 10             	add    $0x10,%esp
  80189e:	85 c0                	test   %eax,%eax
  8018a0:	78 1b                	js     8018bd <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8018a2:	83 ec 08             	sub    $0x8,%esp
  8018a5:	ff 75 0c             	pushl  0xc(%ebp)
  8018a8:	50                   	push   %eax
  8018a9:	e8 5b ff ff ff       	call   801809 <fstat>
  8018ae:	89 c6                	mov    %eax,%esi
	close(fd);
  8018b0:	89 1c 24             	mov    %ebx,(%esp)
  8018b3:	e8 fd fb ff ff       	call   8014b5 <close>
	return r;
  8018b8:	83 c4 10             	add    $0x10,%esp
  8018bb:	89 f0                	mov    %esi,%eax
}
  8018bd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018c0:	5b                   	pop    %ebx
  8018c1:	5e                   	pop    %esi
  8018c2:	5d                   	pop    %ebp
  8018c3:	c3                   	ret    

008018c4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8018c4:	55                   	push   %ebp
  8018c5:	89 e5                	mov    %esp,%ebp
  8018c7:	56                   	push   %esi
  8018c8:	53                   	push   %ebx
  8018c9:	89 c6                	mov    %eax,%esi
  8018cb:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8018cd:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8018d4:	75 12                	jne    8018e8 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8018d6:	83 ec 0c             	sub    $0xc,%esp
  8018d9:	6a 01                	push   $0x1
  8018db:	e8 7b 08 00 00       	call   80215b <ipc_find_env>
  8018e0:	a3 00 40 80 00       	mov    %eax,0x804000
  8018e5:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8018e8:	6a 07                	push   $0x7
  8018ea:	68 00 50 80 00       	push   $0x805000
  8018ef:	56                   	push   %esi
  8018f0:	ff 35 00 40 80 00    	pushl  0x804000
  8018f6:	e8 0c 08 00 00       	call   802107 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8018fb:	83 c4 0c             	add    $0xc,%esp
  8018fe:	6a 00                	push   $0x0
  801900:	53                   	push   %ebx
  801901:	6a 00                	push   $0x0
  801903:	e8 8a 07 00 00       	call   802092 <ipc_recv>
}
  801908:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80190b:	5b                   	pop    %ebx
  80190c:	5e                   	pop    %esi
  80190d:	5d                   	pop    %ebp
  80190e:	c3                   	ret    

0080190f <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80190f:	55                   	push   %ebp
  801910:	89 e5                	mov    %esp,%ebp
  801912:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801915:	8b 45 08             	mov    0x8(%ebp),%eax
  801918:	8b 40 0c             	mov    0xc(%eax),%eax
  80191b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801920:	8b 45 0c             	mov    0xc(%ebp),%eax
  801923:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801928:	ba 00 00 00 00       	mov    $0x0,%edx
  80192d:	b8 02 00 00 00       	mov    $0x2,%eax
  801932:	e8 8d ff ff ff       	call   8018c4 <fsipc>
}
  801937:	c9                   	leave  
  801938:	c3                   	ret    

00801939 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801939:	55                   	push   %ebp
  80193a:	89 e5                	mov    %esp,%ebp
  80193c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80193f:	8b 45 08             	mov    0x8(%ebp),%eax
  801942:	8b 40 0c             	mov    0xc(%eax),%eax
  801945:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80194a:	ba 00 00 00 00       	mov    $0x0,%edx
  80194f:	b8 06 00 00 00       	mov    $0x6,%eax
  801954:	e8 6b ff ff ff       	call   8018c4 <fsipc>
}
  801959:	c9                   	leave  
  80195a:	c3                   	ret    

0080195b <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80195b:	55                   	push   %ebp
  80195c:	89 e5                	mov    %esp,%ebp
  80195e:	53                   	push   %ebx
  80195f:	83 ec 04             	sub    $0x4,%esp
  801962:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801965:	8b 45 08             	mov    0x8(%ebp),%eax
  801968:	8b 40 0c             	mov    0xc(%eax),%eax
  80196b:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801970:	ba 00 00 00 00       	mov    $0x0,%edx
  801975:	b8 05 00 00 00       	mov    $0x5,%eax
  80197a:	e8 45 ff ff ff       	call   8018c4 <fsipc>
  80197f:	85 c0                	test   %eax,%eax
  801981:	78 2c                	js     8019af <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801983:	83 ec 08             	sub    $0x8,%esp
  801986:	68 00 50 80 00       	push   $0x805000
  80198b:	53                   	push   %ebx
  80198c:	e8 86 f0 ff ff       	call   800a17 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801991:	a1 80 50 80 00       	mov    0x805080,%eax
  801996:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80199c:	a1 84 50 80 00       	mov    0x805084,%eax
  8019a1:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8019a7:	83 c4 10             	add    $0x10,%esp
  8019aa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019b2:	c9                   	leave  
  8019b3:	c3                   	ret    

008019b4 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8019b4:	55                   	push   %ebp
  8019b5:	89 e5                	mov    %esp,%ebp
  8019b7:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  8019ba:	68 7c 2a 80 00       	push   $0x802a7c
  8019bf:	68 90 00 00 00       	push   $0x90
  8019c4:	68 9a 2a 80 00       	push   $0x802a9a
  8019c9:	e8 44 e9 ff ff       	call   800312 <_panic>

008019ce <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8019ce:	55                   	push   %ebp
  8019cf:	89 e5                	mov    %esp,%ebp
  8019d1:	56                   	push   %esi
  8019d2:	53                   	push   %ebx
  8019d3:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8019d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d9:	8b 40 0c             	mov    0xc(%eax),%eax
  8019dc:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8019e1:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8019e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8019ec:	b8 03 00 00 00       	mov    $0x3,%eax
  8019f1:	e8 ce fe ff ff       	call   8018c4 <fsipc>
  8019f6:	89 c3                	mov    %eax,%ebx
  8019f8:	85 c0                	test   %eax,%eax
  8019fa:	78 4b                	js     801a47 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8019fc:	39 c6                	cmp    %eax,%esi
  8019fe:	73 16                	jae    801a16 <devfile_read+0x48>
  801a00:	68 a5 2a 80 00       	push   $0x802aa5
  801a05:	68 ac 2a 80 00       	push   $0x802aac
  801a0a:	6a 7c                	push   $0x7c
  801a0c:	68 9a 2a 80 00       	push   $0x802a9a
  801a11:	e8 fc e8 ff ff       	call   800312 <_panic>
	assert(r <= PGSIZE);
  801a16:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a1b:	7e 16                	jle    801a33 <devfile_read+0x65>
  801a1d:	68 c1 2a 80 00       	push   $0x802ac1
  801a22:	68 ac 2a 80 00       	push   $0x802aac
  801a27:	6a 7d                	push   $0x7d
  801a29:	68 9a 2a 80 00       	push   $0x802a9a
  801a2e:	e8 df e8 ff ff       	call   800312 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a33:	83 ec 04             	sub    $0x4,%esp
  801a36:	50                   	push   %eax
  801a37:	68 00 50 80 00       	push   $0x805000
  801a3c:	ff 75 0c             	pushl  0xc(%ebp)
  801a3f:	e8 65 f1 ff ff       	call   800ba9 <memmove>
	return r;
  801a44:	83 c4 10             	add    $0x10,%esp
}
  801a47:	89 d8                	mov    %ebx,%eax
  801a49:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a4c:	5b                   	pop    %ebx
  801a4d:	5e                   	pop    %esi
  801a4e:	5d                   	pop    %ebp
  801a4f:	c3                   	ret    

00801a50 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a50:	55                   	push   %ebp
  801a51:	89 e5                	mov    %esp,%ebp
  801a53:	53                   	push   %ebx
  801a54:	83 ec 20             	sub    $0x20,%esp
  801a57:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a5a:	53                   	push   %ebx
  801a5b:	e8 7e ef ff ff       	call   8009de <strlen>
  801a60:	83 c4 10             	add    $0x10,%esp
  801a63:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a68:	7f 67                	jg     801ad1 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a6a:	83 ec 0c             	sub    $0xc,%esp
  801a6d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a70:	50                   	push   %eax
  801a71:	e8 c6 f8 ff ff       	call   80133c <fd_alloc>
  801a76:	83 c4 10             	add    $0x10,%esp
		return r;
  801a79:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a7b:	85 c0                	test   %eax,%eax
  801a7d:	78 57                	js     801ad6 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a7f:	83 ec 08             	sub    $0x8,%esp
  801a82:	53                   	push   %ebx
  801a83:	68 00 50 80 00       	push   $0x805000
  801a88:	e8 8a ef ff ff       	call   800a17 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a8d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a90:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a95:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a98:	b8 01 00 00 00       	mov    $0x1,%eax
  801a9d:	e8 22 fe ff ff       	call   8018c4 <fsipc>
  801aa2:	89 c3                	mov    %eax,%ebx
  801aa4:	83 c4 10             	add    $0x10,%esp
  801aa7:	85 c0                	test   %eax,%eax
  801aa9:	79 14                	jns    801abf <open+0x6f>
		fd_close(fd, 0);
  801aab:	83 ec 08             	sub    $0x8,%esp
  801aae:	6a 00                	push   $0x0
  801ab0:	ff 75 f4             	pushl  -0xc(%ebp)
  801ab3:	e8 7c f9 ff ff       	call   801434 <fd_close>
		return r;
  801ab8:	83 c4 10             	add    $0x10,%esp
  801abb:	89 da                	mov    %ebx,%edx
  801abd:	eb 17                	jmp    801ad6 <open+0x86>
	}

	return fd2num(fd);
  801abf:	83 ec 0c             	sub    $0xc,%esp
  801ac2:	ff 75 f4             	pushl  -0xc(%ebp)
  801ac5:	e8 4b f8 ff ff       	call   801315 <fd2num>
  801aca:	89 c2                	mov    %eax,%edx
  801acc:	83 c4 10             	add    $0x10,%esp
  801acf:	eb 05                	jmp    801ad6 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801ad1:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801ad6:	89 d0                	mov    %edx,%eax
  801ad8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801adb:	c9                   	leave  
  801adc:	c3                   	ret    

00801add <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801add:	55                   	push   %ebp
  801ade:	89 e5                	mov    %esp,%ebp
  801ae0:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801ae3:	ba 00 00 00 00       	mov    $0x0,%edx
  801ae8:	b8 08 00 00 00       	mov    $0x8,%eax
  801aed:	e8 d2 fd ff ff       	call   8018c4 <fsipc>
}
  801af2:	c9                   	leave  
  801af3:	c3                   	ret    

00801af4 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801af4:	55                   	push   %ebp
  801af5:	89 e5                	mov    %esp,%ebp
  801af7:	56                   	push   %esi
  801af8:	53                   	push   %ebx
  801af9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801afc:	83 ec 0c             	sub    $0xc,%esp
  801aff:	ff 75 08             	pushl  0x8(%ebp)
  801b02:	e8 1e f8 ff ff       	call   801325 <fd2data>
  801b07:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b09:	83 c4 08             	add    $0x8,%esp
  801b0c:	68 cd 2a 80 00       	push   $0x802acd
  801b11:	53                   	push   %ebx
  801b12:	e8 00 ef ff ff       	call   800a17 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b17:	8b 46 04             	mov    0x4(%esi),%eax
  801b1a:	2b 06                	sub    (%esi),%eax
  801b1c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b22:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b29:	00 00 00 
	stat->st_dev = &devpipe;
  801b2c:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  801b33:	30 80 00 
	return 0;
}
  801b36:	b8 00 00 00 00       	mov    $0x0,%eax
  801b3b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b3e:	5b                   	pop    %ebx
  801b3f:	5e                   	pop    %esi
  801b40:	5d                   	pop    %ebp
  801b41:	c3                   	ret    

00801b42 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b42:	55                   	push   %ebp
  801b43:	89 e5                	mov    %esp,%ebp
  801b45:	53                   	push   %ebx
  801b46:	83 ec 0c             	sub    $0xc,%esp
  801b49:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b4c:	53                   	push   %ebx
  801b4d:	6a 00                	push   $0x0
  801b4f:	e8 4b f3 ff ff       	call   800e9f <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b54:	89 1c 24             	mov    %ebx,(%esp)
  801b57:	e8 c9 f7 ff ff       	call   801325 <fd2data>
  801b5c:	83 c4 08             	add    $0x8,%esp
  801b5f:	50                   	push   %eax
  801b60:	6a 00                	push   $0x0
  801b62:	e8 38 f3 ff ff       	call   800e9f <sys_page_unmap>
}
  801b67:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b6a:	c9                   	leave  
  801b6b:	c3                   	ret    

00801b6c <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b6c:	55                   	push   %ebp
  801b6d:	89 e5                	mov    %esp,%ebp
  801b6f:	57                   	push   %edi
  801b70:	56                   	push   %esi
  801b71:	53                   	push   %ebx
  801b72:	83 ec 1c             	sub    $0x1c,%esp
  801b75:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801b78:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b7a:	a1 04 40 80 00       	mov    0x804004,%eax
  801b7f:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801b82:	83 ec 0c             	sub    $0xc,%esp
  801b85:	ff 75 e0             	pushl  -0x20(%ebp)
  801b88:	e8 07 06 00 00       	call   802194 <pageref>
  801b8d:	89 c3                	mov    %eax,%ebx
  801b8f:	89 3c 24             	mov    %edi,(%esp)
  801b92:	e8 fd 05 00 00       	call   802194 <pageref>
  801b97:	83 c4 10             	add    $0x10,%esp
  801b9a:	39 c3                	cmp    %eax,%ebx
  801b9c:	0f 94 c1             	sete   %cl
  801b9f:	0f b6 c9             	movzbl %cl,%ecx
  801ba2:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801ba5:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801bab:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801bae:	39 ce                	cmp    %ecx,%esi
  801bb0:	74 1b                	je     801bcd <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801bb2:	39 c3                	cmp    %eax,%ebx
  801bb4:	75 c4                	jne    801b7a <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801bb6:	8b 42 58             	mov    0x58(%edx),%eax
  801bb9:	ff 75 e4             	pushl  -0x1c(%ebp)
  801bbc:	50                   	push   %eax
  801bbd:	56                   	push   %esi
  801bbe:	68 d4 2a 80 00       	push   $0x802ad4
  801bc3:	e8 23 e8 ff ff       	call   8003eb <cprintf>
  801bc8:	83 c4 10             	add    $0x10,%esp
  801bcb:	eb ad                	jmp    801b7a <_pipeisclosed+0xe>
	}
}
  801bcd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bd0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bd3:	5b                   	pop    %ebx
  801bd4:	5e                   	pop    %esi
  801bd5:	5f                   	pop    %edi
  801bd6:	5d                   	pop    %ebp
  801bd7:	c3                   	ret    

00801bd8 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801bd8:	55                   	push   %ebp
  801bd9:	89 e5                	mov    %esp,%ebp
  801bdb:	57                   	push   %edi
  801bdc:	56                   	push   %esi
  801bdd:	53                   	push   %ebx
  801bde:	83 ec 28             	sub    $0x28,%esp
  801be1:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801be4:	56                   	push   %esi
  801be5:	e8 3b f7 ff ff       	call   801325 <fd2data>
  801bea:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bec:	83 c4 10             	add    $0x10,%esp
  801bef:	bf 00 00 00 00       	mov    $0x0,%edi
  801bf4:	eb 4b                	jmp    801c41 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801bf6:	89 da                	mov    %ebx,%edx
  801bf8:	89 f0                	mov    %esi,%eax
  801bfa:	e8 6d ff ff ff       	call   801b6c <_pipeisclosed>
  801bff:	85 c0                	test   %eax,%eax
  801c01:	75 48                	jne    801c4b <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801c03:	e8 f3 f1 ff ff       	call   800dfb <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c08:	8b 43 04             	mov    0x4(%ebx),%eax
  801c0b:	8b 0b                	mov    (%ebx),%ecx
  801c0d:	8d 51 20             	lea    0x20(%ecx),%edx
  801c10:	39 d0                	cmp    %edx,%eax
  801c12:	73 e2                	jae    801bf6 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c17:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c1b:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c1e:	89 c2                	mov    %eax,%edx
  801c20:	c1 fa 1f             	sar    $0x1f,%edx
  801c23:	89 d1                	mov    %edx,%ecx
  801c25:	c1 e9 1b             	shr    $0x1b,%ecx
  801c28:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c2b:	83 e2 1f             	and    $0x1f,%edx
  801c2e:	29 ca                	sub    %ecx,%edx
  801c30:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c34:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c38:	83 c0 01             	add    $0x1,%eax
  801c3b:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c3e:	83 c7 01             	add    $0x1,%edi
  801c41:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c44:	75 c2                	jne    801c08 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c46:	8b 45 10             	mov    0x10(%ebp),%eax
  801c49:	eb 05                	jmp    801c50 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c4b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c50:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c53:	5b                   	pop    %ebx
  801c54:	5e                   	pop    %esi
  801c55:	5f                   	pop    %edi
  801c56:	5d                   	pop    %ebp
  801c57:	c3                   	ret    

00801c58 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c58:	55                   	push   %ebp
  801c59:	89 e5                	mov    %esp,%ebp
  801c5b:	57                   	push   %edi
  801c5c:	56                   	push   %esi
  801c5d:	53                   	push   %ebx
  801c5e:	83 ec 18             	sub    $0x18,%esp
  801c61:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c64:	57                   	push   %edi
  801c65:	e8 bb f6 ff ff       	call   801325 <fd2data>
  801c6a:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c6c:	83 c4 10             	add    $0x10,%esp
  801c6f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c74:	eb 3d                	jmp    801cb3 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c76:	85 db                	test   %ebx,%ebx
  801c78:	74 04                	je     801c7e <devpipe_read+0x26>
				return i;
  801c7a:	89 d8                	mov    %ebx,%eax
  801c7c:	eb 44                	jmp    801cc2 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c7e:	89 f2                	mov    %esi,%edx
  801c80:	89 f8                	mov    %edi,%eax
  801c82:	e8 e5 fe ff ff       	call   801b6c <_pipeisclosed>
  801c87:	85 c0                	test   %eax,%eax
  801c89:	75 32                	jne    801cbd <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c8b:	e8 6b f1 ff ff       	call   800dfb <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c90:	8b 06                	mov    (%esi),%eax
  801c92:	3b 46 04             	cmp    0x4(%esi),%eax
  801c95:	74 df                	je     801c76 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c97:	99                   	cltd   
  801c98:	c1 ea 1b             	shr    $0x1b,%edx
  801c9b:	01 d0                	add    %edx,%eax
  801c9d:	83 e0 1f             	and    $0x1f,%eax
  801ca0:	29 d0                	sub    %edx,%eax
  801ca2:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801ca7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801caa:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801cad:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cb0:	83 c3 01             	add    $0x1,%ebx
  801cb3:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801cb6:	75 d8                	jne    801c90 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801cb8:	8b 45 10             	mov    0x10(%ebp),%eax
  801cbb:	eb 05                	jmp    801cc2 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801cbd:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801cc2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cc5:	5b                   	pop    %ebx
  801cc6:	5e                   	pop    %esi
  801cc7:	5f                   	pop    %edi
  801cc8:	5d                   	pop    %ebp
  801cc9:	c3                   	ret    

00801cca <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801cca:	55                   	push   %ebp
  801ccb:	89 e5                	mov    %esp,%ebp
  801ccd:	56                   	push   %esi
  801cce:	53                   	push   %ebx
  801ccf:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801cd2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cd5:	50                   	push   %eax
  801cd6:	e8 61 f6 ff ff       	call   80133c <fd_alloc>
  801cdb:	83 c4 10             	add    $0x10,%esp
  801cde:	89 c2                	mov    %eax,%edx
  801ce0:	85 c0                	test   %eax,%eax
  801ce2:	0f 88 2c 01 00 00    	js     801e14 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ce8:	83 ec 04             	sub    $0x4,%esp
  801ceb:	68 07 04 00 00       	push   $0x407
  801cf0:	ff 75 f4             	pushl  -0xc(%ebp)
  801cf3:	6a 00                	push   $0x0
  801cf5:	e8 20 f1 ff ff       	call   800e1a <sys_page_alloc>
  801cfa:	83 c4 10             	add    $0x10,%esp
  801cfd:	89 c2                	mov    %eax,%edx
  801cff:	85 c0                	test   %eax,%eax
  801d01:	0f 88 0d 01 00 00    	js     801e14 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d07:	83 ec 0c             	sub    $0xc,%esp
  801d0a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d0d:	50                   	push   %eax
  801d0e:	e8 29 f6 ff ff       	call   80133c <fd_alloc>
  801d13:	89 c3                	mov    %eax,%ebx
  801d15:	83 c4 10             	add    $0x10,%esp
  801d18:	85 c0                	test   %eax,%eax
  801d1a:	0f 88 e2 00 00 00    	js     801e02 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d20:	83 ec 04             	sub    $0x4,%esp
  801d23:	68 07 04 00 00       	push   $0x407
  801d28:	ff 75 f0             	pushl  -0x10(%ebp)
  801d2b:	6a 00                	push   $0x0
  801d2d:	e8 e8 f0 ff ff       	call   800e1a <sys_page_alloc>
  801d32:	89 c3                	mov    %eax,%ebx
  801d34:	83 c4 10             	add    $0x10,%esp
  801d37:	85 c0                	test   %eax,%eax
  801d39:	0f 88 c3 00 00 00    	js     801e02 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d3f:	83 ec 0c             	sub    $0xc,%esp
  801d42:	ff 75 f4             	pushl  -0xc(%ebp)
  801d45:	e8 db f5 ff ff       	call   801325 <fd2data>
  801d4a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d4c:	83 c4 0c             	add    $0xc,%esp
  801d4f:	68 07 04 00 00       	push   $0x407
  801d54:	50                   	push   %eax
  801d55:	6a 00                	push   $0x0
  801d57:	e8 be f0 ff ff       	call   800e1a <sys_page_alloc>
  801d5c:	89 c3                	mov    %eax,%ebx
  801d5e:	83 c4 10             	add    $0x10,%esp
  801d61:	85 c0                	test   %eax,%eax
  801d63:	0f 88 89 00 00 00    	js     801df2 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d69:	83 ec 0c             	sub    $0xc,%esp
  801d6c:	ff 75 f0             	pushl  -0x10(%ebp)
  801d6f:	e8 b1 f5 ff ff       	call   801325 <fd2data>
  801d74:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d7b:	50                   	push   %eax
  801d7c:	6a 00                	push   $0x0
  801d7e:	56                   	push   %esi
  801d7f:	6a 00                	push   $0x0
  801d81:	e8 d7 f0 ff ff       	call   800e5d <sys_page_map>
  801d86:	89 c3                	mov    %eax,%ebx
  801d88:	83 c4 20             	add    $0x20,%esp
  801d8b:	85 c0                	test   %eax,%eax
  801d8d:	78 55                	js     801de4 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d8f:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801d95:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d98:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d9d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801da4:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801daa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dad:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801daf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801db2:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801db9:	83 ec 0c             	sub    $0xc,%esp
  801dbc:	ff 75 f4             	pushl  -0xc(%ebp)
  801dbf:	e8 51 f5 ff ff       	call   801315 <fd2num>
  801dc4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dc7:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801dc9:	83 c4 04             	add    $0x4,%esp
  801dcc:	ff 75 f0             	pushl  -0x10(%ebp)
  801dcf:	e8 41 f5 ff ff       	call   801315 <fd2num>
  801dd4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dd7:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801dda:	83 c4 10             	add    $0x10,%esp
  801ddd:	ba 00 00 00 00       	mov    $0x0,%edx
  801de2:	eb 30                	jmp    801e14 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801de4:	83 ec 08             	sub    $0x8,%esp
  801de7:	56                   	push   %esi
  801de8:	6a 00                	push   $0x0
  801dea:	e8 b0 f0 ff ff       	call   800e9f <sys_page_unmap>
  801def:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801df2:	83 ec 08             	sub    $0x8,%esp
  801df5:	ff 75 f0             	pushl  -0x10(%ebp)
  801df8:	6a 00                	push   $0x0
  801dfa:	e8 a0 f0 ff ff       	call   800e9f <sys_page_unmap>
  801dff:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801e02:	83 ec 08             	sub    $0x8,%esp
  801e05:	ff 75 f4             	pushl  -0xc(%ebp)
  801e08:	6a 00                	push   $0x0
  801e0a:	e8 90 f0 ff ff       	call   800e9f <sys_page_unmap>
  801e0f:	83 c4 10             	add    $0x10,%esp
  801e12:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801e14:	89 d0                	mov    %edx,%eax
  801e16:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e19:	5b                   	pop    %ebx
  801e1a:	5e                   	pop    %esi
  801e1b:	5d                   	pop    %ebp
  801e1c:	c3                   	ret    

00801e1d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e1d:	55                   	push   %ebp
  801e1e:	89 e5                	mov    %esp,%ebp
  801e20:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e23:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e26:	50                   	push   %eax
  801e27:	ff 75 08             	pushl  0x8(%ebp)
  801e2a:	e8 5c f5 ff ff       	call   80138b <fd_lookup>
  801e2f:	83 c4 10             	add    $0x10,%esp
  801e32:	85 c0                	test   %eax,%eax
  801e34:	78 18                	js     801e4e <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e36:	83 ec 0c             	sub    $0xc,%esp
  801e39:	ff 75 f4             	pushl  -0xc(%ebp)
  801e3c:	e8 e4 f4 ff ff       	call   801325 <fd2data>
	return _pipeisclosed(fd, p);
  801e41:	89 c2                	mov    %eax,%edx
  801e43:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e46:	e8 21 fd ff ff       	call   801b6c <_pipeisclosed>
  801e4b:	83 c4 10             	add    $0x10,%esp
}
  801e4e:	c9                   	leave  
  801e4f:	c3                   	ret    

00801e50 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  801e50:	55                   	push   %ebp
  801e51:	89 e5                	mov    %esp,%ebp
  801e53:	56                   	push   %esi
  801e54:	53                   	push   %ebx
  801e55:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  801e58:	85 f6                	test   %esi,%esi
  801e5a:	75 16                	jne    801e72 <wait+0x22>
  801e5c:	68 ec 2a 80 00       	push   $0x802aec
  801e61:	68 ac 2a 80 00       	push   $0x802aac
  801e66:	6a 09                	push   $0x9
  801e68:	68 f7 2a 80 00       	push   $0x802af7
  801e6d:	e8 a0 e4 ff ff       	call   800312 <_panic>
	e = &envs[ENVX(envid)];
  801e72:	89 f3                	mov    %esi,%ebx
  801e74:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801e7a:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  801e7d:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  801e83:	eb 05                	jmp    801e8a <wait+0x3a>
		sys_yield();
  801e85:	e8 71 ef ff ff       	call   800dfb <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801e8a:	8b 43 48             	mov    0x48(%ebx),%eax
  801e8d:	39 c6                	cmp    %eax,%esi
  801e8f:	75 07                	jne    801e98 <wait+0x48>
  801e91:	8b 43 54             	mov    0x54(%ebx),%eax
  801e94:	85 c0                	test   %eax,%eax
  801e96:	75 ed                	jne    801e85 <wait+0x35>
		sys_yield();
}
  801e98:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e9b:	5b                   	pop    %ebx
  801e9c:	5e                   	pop    %esi
  801e9d:	5d                   	pop    %ebp
  801e9e:	c3                   	ret    

00801e9f <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e9f:	55                   	push   %ebp
  801ea0:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ea2:	b8 00 00 00 00       	mov    $0x0,%eax
  801ea7:	5d                   	pop    %ebp
  801ea8:	c3                   	ret    

00801ea9 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ea9:	55                   	push   %ebp
  801eaa:	89 e5                	mov    %esp,%ebp
  801eac:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801eaf:	68 02 2b 80 00       	push   $0x802b02
  801eb4:	ff 75 0c             	pushl  0xc(%ebp)
  801eb7:	e8 5b eb ff ff       	call   800a17 <strcpy>
	return 0;
}
  801ebc:	b8 00 00 00 00       	mov    $0x0,%eax
  801ec1:	c9                   	leave  
  801ec2:	c3                   	ret    

00801ec3 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ec3:	55                   	push   %ebp
  801ec4:	89 e5                	mov    %esp,%ebp
  801ec6:	57                   	push   %edi
  801ec7:	56                   	push   %esi
  801ec8:	53                   	push   %ebx
  801ec9:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ecf:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ed4:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801eda:	eb 2d                	jmp    801f09 <devcons_write+0x46>
		m = n - tot;
  801edc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801edf:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801ee1:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801ee4:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801ee9:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801eec:	83 ec 04             	sub    $0x4,%esp
  801eef:	53                   	push   %ebx
  801ef0:	03 45 0c             	add    0xc(%ebp),%eax
  801ef3:	50                   	push   %eax
  801ef4:	57                   	push   %edi
  801ef5:	e8 af ec ff ff       	call   800ba9 <memmove>
		sys_cputs(buf, m);
  801efa:	83 c4 08             	add    $0x8,%esp
  801efd:	53                   	push   %ebx
  801efe:	57                   	push   %edi
  801eff:	e8 5a ee ff ff       	call   800d5e <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f04:	01 de                	add    %ebx,%esi
  801f06:	83 c4 10             	add    $0x10,%esp
  801f09:	89 f0                	mov    %esi,%eax
  801f0b:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f0e:	72 cc                	jb     801edc <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801f10:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f13:	5b                   	pop    %ebx
  801f14:	5e                   	pop    %esi
  801f15:	5f                   	pop    %edi
  801f16:	5d                   	pop    %ebp
  801f17:	c3                   	ret    

00801f18 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f18:	55                   	push   %ebp
  801f19:	89 e5                	mov    %esp,%ebp
  801f1b:	83 ec 08             	sub    $0x8,%esp
  801f1e:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801f23:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f27:	74 2a                	je     801f53 <devcons_read+0x3b>
  801f29:	eb 05                	jmp    801f30 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f2b:	e8 cb ee ff ff       	call   800dfb <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f30:	e8 47 ee ff ff       	call   800d7c <sys_cgetc>
  801f35:	85 c0                	test   %eax,%eax
  801f37:	74 f2                	je     801f2b <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801f39:	85 c0                	test   %eax,%eax
  801f3b:	78 16                	js     801f53 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f3d:	83 f8 04             	cmp    $0x4,%eax
  801f40:	74 0c                	je     801f4e <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801f42:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f45:	88 02                	mov    %al,(%edx)
	return 1;
  801f47:	b8 01 00 00 00       	mov    $0x1,%eax
  801f4c:	eb 05                	jmp    801f53 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801f4e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801f53:	c9                   	leave  
  801f54:	c3                   	ret    

00801f55 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f55:	55                   	push   %ebp
  801f56:	89 e5                	mov    %esp,%ebp
  801f58:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f5b:	8b 45 08             	mov    0x8(%ebp),%eax
  801f5e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f61:	6a 01                	push   $0x1
  801f63:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f66:	50                   	push   %eax
  801f67:	e8 f2 ed ff ff       	call   800d5e <sys_cputs>
}
  801f6c:	83 c4 10             	add    $0x10,%esp
  801f6f:	c9                   	leave  
  801f70:	c3                   	ret    

00801f71 <getchar>:

int
getchar(void)
{
  801f71:	55                   	push   %ebp
  801f72:	89 e5                	mov    %esp,%ebp
  801f74:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f77:	6a 01                	push   $0x1
  801f79:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f7c:	50                   	push   %eax
  801f7d:	6a 00                	push   $0x0
  801f7f:	e8 6d f6 ff ff       	call   8015f1 <read>
	if (r < 0)
  801f84:	83 c4 10             	add    $0x10,%esp
  801f87:	85 c0                	test   %eax,%eax
  801f89:	78 0f                	js     801f9a <getchar+0x29>
		return r;
	if (r < 1)
  801f8b:	85 c0                	test   %eax,%eax
  801f8d:	7e 06                	jle    801f95 <getchar+0x24>
		return -E_EOF;
	return c;
  801f8f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f93:	eb 05                	jmp    801f9a <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f95:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f9a:	c9                   	leave  
  801f9b:	c3                   	ret    

00801f9c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f9c:	55                   	push   %ebp
  801f9d:	89 e5                	mov    %esp,%ebp
  801f9f:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fa2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fa5:	50                   	push   %eax
  801fa6:	ff 75 08             	pushl  0x8(%ebp)
  801fa9:	e8 dd f3 ff ff       	call   80138b <fd_lookup>
  801fae:	83 c4 10             	add    $0x10,%esp
  801fb1:	85 c0                	test   %eax,%eax
  801fb3:	78 11                	js     801fc6 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801fb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fb8:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801fbe:	39 10                	cmp    %edx,(%eax)
  801fc0:	0f 94 c0             	sete   %al
  801fc3:	0f b6 c0             	movzbl %al,%eax
}
  801fc6:	c9                   	leave  
  801fc7:	c3                   	ret    

00801fc8 <opencons>:

int
opencons(void)
{
  801fc8:	55                   	push   %ebp
  801fc9:	89 e5                	mov    %esp,%ebp
  801fcb:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fce:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fd1:	50                   	push   %eax
  801fd2:	e8 65 f3 ff ff       	call   80133c <fd_alloc>
  801fd7:	83 c4 10             	add    $0x10,%esp
		return r;
  801fda:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fdc:	85 c0                	test   %eax,%eax
  801fde:	78 3e                	js     80201e <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fe0:	83 ec 04             	sub    $0x4,%esp
  801fe3:	68 07 04 00 00       	push   $0x407
  801fe8:	ff 75 f4             	pushl  -0xc(%ebp)
  801feb:	6a 00                	push   $0x0
  801fed:	e8 28 ee ff ff       	call   800e1a <sys_page_alloc>
  801ff2:	83 c4 10             	add    $0x10,%esp
		return r;
  801ff5:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ff7:	85 c0                	test   %eax,%eax
  801ff9:	78 23                	js     80201e <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ffb:	8b 15 40 30 80 00    	mov    0x803040,%edx
  802001:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802004:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802006:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802009:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802010:	83 ec 0c             	sub    $0xc,%esp
  802013:	50                   	push   %eax
  802014:	e8 fc f2 ff ff       	call   801315 <fd2num>
  802019:	89 c2                	mov    %eax,%edx
  80201b:	83 c4 10             	add    $0x10,%esp
}
  80201e:	89 d0                	mov    %edx,%eax
  802020:	c9                   	leave  
  802021:	c3                   	ret    

00802022 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802022:	55                   	push   %ebp
  802023:	89 e5                	mov    %esp,%ebp
  802025:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802028:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80202f:	75 31                	jne    802062 <set_pgfault_handler+0x40>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc(thisenv->env_id, (void*)(UXSTACKTOP - PGSIZE), PTE_P | 
  802031:	a1 04 40 80 00       	mov    0x804004,%eax
  802036:	8b 40 48             	mov    0x48(%eax),%eax
  802039:	83 ec 04             	sub    $0x4,%esp
  80203c:	6a 07                	push   $0x7
  80203e:	68 00 f0 bf ee       	push   $0xeebff000
  802043:	50                   	push   %eax
  802044:	e8 d1 ed ff ff       	call   800e1a <sys_page_alloc>
				PTE_U | PTE_W);
		sys_env_set_pgfault_upcall(thisenv->env_id, (void*)_pgfault_upcall);
  802049:	a1 04 40 80 00       	mov    0x804004,%eax
  80204e:	8b 40 48             	mov    0x48(%eax),%eax
  802051:	83 c4 08             	add    $0x8,%esp
  802054:	68 6c 20 80 00       	push   $0x80206c
  802059:	50                   	push   %eax
  80205a:	e8 06 ef ff ff       	call   800f65 <sys_env_set_pgfault_upcall>
  80205f:	83 c4 10             	add    $0x10,%esp

		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802062:	8b 45 08             	mov    0x8(%ebp),%eax
  802065:	a3 00 60 80 00       	mov    %eax,0x806000
}
  80206a:	c9                   	leave  
  80206b:	c3                   	ret    

0080206c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80206c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80206d:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802072:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802074:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	addl $8, %esp      // pop utf_fault_va and utf_err
  802077:	83 c4 08             	add    $0x8,%esp
	movl 32(%esp), %eax  // eax <- [esp + 32]
  80207a:	8b 44 24 20          	mov    0x20(%esp),%eax
	movl 40(%esp), %ebx  // ebx <- [esp + 40]
  80207e:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	leal -4(%ebx), %ebx  // ebx <- ebx - 4
  802082:	8d 5b fc             	lea    -0x4(%ebx),%ebx
	movl %eax, (%ebx)
  802085:	89 03                	mov    %eax,(%ebx)
	movl %ebx, 40(%esp)  // push trap eip and decrement trap esp manually
  802087:	89 5c 24 28          	mov    %ebx,0x28(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  80208b:	61                   	popa   
	addl $4, %esp        // skip eip
  80208c:	83 c4 04             	add    $0x4,%esp

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	popf
  80208f:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	pop %esp
  802090:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802091:	c3                   	ret    

00802092 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802092:	55                   	push   %ebp
  802093:	89 e5                	mov    %esp,%ebp
  802095:	56                   	push   %esi
  802096:	53                   	push   %ebx
  802097:	8b 75 08             	mov    0x8(%ebp),%esi
  80209a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80209d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int ret;
	if (pg) ret = sys_ipc_recv(pg);
  8020a0:	85 c0                	test   %eax,%eax
  8020a2:	74 0e                	je     8020b2 <ipc_recv+0x20>
  8020a4:	83 ec 0c             	sub    $0xc,%esp
  8020a7:	50                   	push   %eax
  8020a8:	e8 1d ef ff ff       	call   800fca <sys_ipc_recv>
  8020ad:	83 c4 10             	add    $0x10,%esp
  8020b0:	eb 10                	jmp    8020c2 <ipc_recv+0x30>
	else ret = sys_ipc_recv((void*)UTOP);
  8020b2:	83 ec 0c             	sub    $0xc,%esp
  8020b5:	68 00 00 c0 ee       	push   $0xeec00000
  8020ba:	e8 0b ef ff ff       	call   800fca <sys_ipc_recv>
  8020bf:	83 c4 10             	add    $0x10,%esp
	if (ret) {
  8020c2:	85 c0                	test   %eax,%eax
  8020c4:	74 16                	je     8020dc <ipc_recv+0x4a>
		if (from_env_store) *from_env_store = 0;
  8020c6:	85 f6                	test   %esi,%esi
  8020c8:	74 06                	je     8020d0 <ipc_recv+0x3e>
  8020ca:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  8020d0:	85 db                	test   %ebx,%ebx
  8020d2:	74 2c                	je     802100 <ipc_recv+0x6e>
  8020d4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8020da:	eb 24                	jmp    802100 <ipc_recv+0x6e>
		return ret;
	}
	if (from_env_store) *from_env_store = thisenv->env_ipc_from;
  8020dc:	85 f6                	test   %esi,%esi
  8020de:	74 0a                	je     8020ea <ipc_recv+0x58>
  8020e0:	a1 04 40 80 00       	mov    0x804004,%eax
  8020e5:	8b 40 74             	mov    0x74(%eax),%eax
  8020e8:	89 06                	mov    %eax,(%esi)
	if (perm_store) *perm_store = thisenv->env_ipc_perm;
  8020ea:	85 db                	test   %ebx,%ebx
  8020ec:	74 0a                	je     8020f8 <ipc_recv+0x66>
  8020ee:	a1 04 40 80 00       	mov    0x804004,%eax
  8020f3:	8b 40 78             	mov    0x78(%eax),%eax
  8020f6:	89 03                	mov    %eax,(%ebx)

	// panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8020f8:	a1 04 40 80 00       	mov    0x804004,%eax
  8020fd:	8b 40 70             	mov    0x70(%eax),%eax
}
  802100:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802103:	5b                   	pop    %ebx
  802104:	5e                   	pop    %esi
  802105:	5d                   	pop    %ebp
  802106:	c3                   	ret    

00802107 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802107:	55                   	push   %ebp
  802108:	89 e5                	mov    %esp,%ebp
  80210a:	57                   	push   %edi
  80210b:	56                   	push   %esi
  80210c:	53                   	push   %ebx
  80210d:	83 ec 0c             	sub    $0xc,%esp
  802110:	8b 7d 08             	mov    0x8(%ebp),%edi
  802113:	8b 75 0c             	mov    0xc(%ebp),%esi
  802116:	8b 45 10             	mov    0x10(%ebp),%eax
  802119:	85 c0                	test   %eax,%eax
  80211b:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  802120:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	while (true) {
		void* srcva = (pg)? pg: (void*)UTOP;
		int ret = sys_ipc_try_send(to_env, val, srcva, perm);
  802123:	ff 75 14             	pushl  0x14(%ebp)
  802126:	53                   	push   %ebx
  802127:	56                   	push   %esi
  802128:	57                   	push   %edi
  802129:	e8 79 ee ff ff       	call   800fa7 <sys_ipc_try_send>
		if (ret == 0) break;
  80212e:	83 c4 10             	add    $0x10,%esp
  802131:	85 c0                	test   %eax,%eax
  802133:	74 1e                	je     802153 <ipc_send+0x4c>
		if (ret != -E_IPC_NOT_RECV) panic("ipc_send: %e", ret);
  802135:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802138:	74 12                	je     80214c <ipc_send+0x45>
  80213a:	50                   	push   %eax
  80213b:	68 0e 2b 80 00       	push   $0x802b0e
  802140:	6a 39                	push   $0x39
  802142:	68 1b 2b 80 00       	push   $0x802b1b
  802147:	e8 c6 e1 ff ff       	call   800312 <_panic>
		sys_yield();
  80214c:	e8 aa ec ff ff       	call   800dfb <sys_yield>
	}
  802151:	eb d0                	jmp    802123 <ipc_send+0x1c>
	// panic("ipc_send not implemented");
}
  802153:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802156:	5b                   	pop    %ebx
  802157:	5e                   	pop    %esi
  802158:	5f                   	pop    %edi
  802159:	5d                   	pop    %ebp
  80215a:	c3                   	ret    

0080215b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80215b:	55                   	push   %ebp
  80215c:	89 e5                	mov    %esp,%ebp
  80215e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802161:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802166:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802169:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80216f:	8b 52 50             	mov    0x50(%edx),%edx
  802172:	39 ca                	cmp    %ecx,%edx
  802174:	75 0d                	jne    802183 <ipc_find_env+0x28>
			return envs[i].env_id;
  802176:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802179:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80217e:	8b 40 48             	mov    0x48(%eax),%eax
  802181:	eb 0f                	jmp    802192 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802183:	83 c0 01             	add    $0x1,%eax
  802186:	3d 00 04 00 00       	cmp    $0x400,%eax
  80218b:	75 d9                	jne    802166 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80218d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802192:	5d                   	pop    %ebp
  802193:	c3                   	ret    

00802194 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802194:	55                   	push   %ebp
  802195:	89 e5                	mov    %esp,%ebp
  802197:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80219a:	89 d0                	mov    %edx,%eax
  80219c:	c1 e8 16             	shr    $0x16,%eax
  80219f:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8021a6:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021ab:	f6 c1 01             	test   $0x1,%cl
  8021ae:	74 1d                	je     8021cd <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8021b0:	c1 ea 0c             	shr    $0xc,%edx
  8021b3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8021ba:	f6 c2 01             	test   $0x1,%dl
  8021bd:	74 0e                	je     8021cd <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8021bf:	c1 ea 0c             	shr    $0xc,%edx
  8021c2:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8021c9:	ef 
  8021ca:	0f b7 c0             	movzwl %ax,%eax
}
  8021cd:	5d                   	pop    %ebp
  8021ce:	c3                   	ret    
  8021cf:	90                   	nop

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
