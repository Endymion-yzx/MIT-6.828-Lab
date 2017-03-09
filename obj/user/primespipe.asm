
obj/user/primespipe.debug:     file format elf32-i386


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
  80002c:	e8 07 02 00 00       	call   800238 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(int fd)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
  80003c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i, id, p, pfd[2], wfd, r;

	// fetch a prime from our left neighbor
top:
	if ((r = readn(fd, &p, 4)) != 4)
  80003f:	8d 75 e0             	lea    -0x20(%ebp),%esi
		panic("primeproc could not read initial prime: %d, %e", r, r >= 0 ? 0 : r);

	cprintf("%d\n", p);

	// fork a right neighbor to continue the chain
	if ((i=pipe(pfd)) < 0)
  800042:	8d 7d d8             	lea    -0x28(%ebp),%edi
{
	int i, id, p, pfd[2], wfd, r;

	// fetch a prime from our left neighbor
top:
	if ((r = readn(fd, &p, 4)) != 4)
  800045:	83 ec 04             	sub    $0x4,%esp
  800048:	6a 04                	push   $0x4
  80004a:	56                   	push   %esi
  80004b:	53                   	push   %ebx
  80004c:	e8 b7 15 00 00       	call   801608 <readn>
  800051:	83 c4 10             	add    $0x10,%esp
  800054:	83 f8 04             	cmp    $0x4,%eax
  800057:	74 20                	je     800079 <primeproc+0x46>
		panic("primeproc could not read initial prime: %d, %e", r, r >= 0 ? 0 : r);
  800059:	83 ec 0c             	sub    $0xc,%esp
  80005c:	85 c0                	test   %eax,%eax
  80005e:	ba 00 00 00 00       	mov    $0x0,%edx
  800063:	0f 4e d0             	cmovle %eax,%edx
  800066:	52                   	push   %edx
  800067:	50                   	push   %eax
  800068:	68 a0 23 80 00       	push   $0x8023a0
  80006d:	6a 15                	push   $0x15
  80006f:	68 cf 23 80 00       	push   $0x8023cf
  800074:	e8 1f 02 00 00       	call   800298 <_panic>

	cprintf("%d\n", p);
  800079:	83 ec 08             	sub    $0x8,%esp
  80007c:	ff 75 e0             	pushl  -0x20(%ebp)
  80007f:	68 e1 23 80 00       	push   $0x8023e1
  800084:	e8 e8 02 00 00       	call   800371 <cprintf>

	// fork a right neighbor to continue the chain
	if ((i=pipe(pfd)) < 0)
  800089:	89 3c 24             	mov    %edi,(%esp)
  80008c:	e8 bf 1b 00 00       	call   801c50 <pipe>
  800091:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800094:	83 c4 10             	add    $0x10,%esp
  800097:	85 c0                	test   %eax,%eax
  800099:	79 12                	jns    8000ad <primeproc+0x7a>
		panic("pipe: %e", i);
  80009b:	50                   	push   %eax
  80009c:	68 e5 23 80 00       	push   $0x8023e5
  8000a1:	6a 1b                	push   $0x1b
  8000a3:	68 cf 23 80 00       	push   $0x8023cf
  8000a8:	e8 eb 01 00 00       	call   800298 <_panic>
	if ((id = fork()) < 0)
  8000ad:	e8 8c 10 00 00       	call   80113e <fork>
  8000b2:	85 c0                	test   %eax,%eax
  8000b4:	79 12                	jns    8000c8 <primeproc+0x95>
		panic("fork: %e", id);
  8000b6:	50                   	push   %eax
  8000b7:	68 ee 23 80 00       	push   $0x8023ee
  8000bc:	6a 1d                	push   $0x1d
  8000be:	68 cf 23 80 00       	push   $0x8023cf
  8000c3:	e8 d0 01 00 00       	call   800298 <_panic>
	if (id == 0) {
  8000c8:	85 c0                	test   %eax,%eax
  8000ca:	75 1f                	jne    8000eb <primeproc+0xb8>
		close(fd);
  8000cc:	83 ec 0c             	sub    $0xc,%esp
  8000cf:	53                   	push   %ebx
  8000d0:	e8 66 13 00 00       	call   80143b <close>
		close(pfd[1]);
  8000d5:	83 c4 04             	add    $0x4,%esp
  8000d8:	ff 75 dc             	pushl  -0x24(%ebp)
  8000db:	e8 5b 13 00 00       	call   80143b <close>
		fd = pfd[0];
  8000e0:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		goto top;
  8000e3:	83 c4 10             	add    $0x10,%esp
  8000e6:	e9 5a ff ff ff       	jmp    800045 <primeproc+0x12>
	}

	close(pfd[0]);
  8000eb:	83 ec 0c             	sub    $0xc,%esp
  8000ee:	ff 75 d8             	pushl  -0x28(%ebp)
  8000f1:	e8 45 13 00 00       	call   80143b <close>
	wfd = pfd[1];
  8000f6:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8000f9:	83 c4 10             	add    $0x10,%esp

	// filter out multiples of our prime
	for (;;) {
		if ((r=readn(fd, &i, 4)) != 4)
  8000fc:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  8000ff:	83 ec 04             	sub    $0x4,%esp
  800102:	6a 04                	push   $0x4
  800104:	56                   	push   %esi
  800105:	53                   	push   %ebx
  800106:	e8 fd 14 00 00       	call   801608 <readn>
  80010b:	83 c4 10             	add    $0x10,%esp
  80010e:	83 f8 04             	cmp    $0x4,%eax
  800111:	74 24                	je     800137 <primeproc+0x104>
			panic("primeproc %d readn %d %d %e", p, fd, r, r >= 0 ? 0 : r);
  800113:	83 ec 04             	sub    $0x4,%esp
  800116:	85 c0                	test   %eax,%eax
  800118:	ba 00 00 00 00       	mov    $0x0,%edx
  80011d:	0f 4e d0             	cmovle %eax,%edx
  800120:	52                   	push   %edx
  800121:	50                   	push   %eax
  800122:	53                   	push   %ebx
  800123:	ff 75 e0             	pushl  -0x20(%ebp)
  800126:	68 f7 23 80 00       	push   $0x8023f7
  80012b:	6a 2b                	push   $0x2b
  80012d:	68 cf 23 80 00       	push   $0x8023cf
  800132:	e8 61 01 00 00       	call   800298 <_panic>
		if (i%p)
  800137:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80013a:	99                   	cltd   
  80013b:	f7 7d e0             	idivl  -0x20(%ebp)
  80013e:	85 d2                	test   %edx,%edx
  800140:	74 bd                	je     8000ff <primeproc+0xcc>
			if ((r=write(wfd, &i, 4)) != 4)
  800142:	83 ec 04             	sub    $0x4,%esp
  800145:	6a 04                	push   $0x4
  800147:	56                   	push   %esi
  800148:	57                   	push   %edi
  800149:	e8 03 15 00 00       	call   801651 <write>
  80014e:	83 c4 10             	add    $0x10,%esp
  800151:	83 f8 04             	cmp    $0x4,%eax
  800154:	74 a9                	je     8000ff <primeproc+0xcc>
				panic("primeproc %d write: %d %e", p, r, r >= 0 ? 0 : r);
  800156:	83 ec 08             	sub    $0x8,%esp
  800159:	85 c0                	test   %eax,%eax
  80015b:	ba 00 00 00 00       	mov    $0x0,%edx
  800160:	0f 4e d0             	cmovle %eax,%edx
  800163:	52                   	push   %edx
  800164:	50                   	push   %eax
  800165:	ff 75 e0             	pushl  -0x20(%ebp)
  800168:	68 13 24 80 00       	push   $0x802413
  80016d:	6a 2e                	push   $0x2e
  80016f:	68 cf 23 80 00       	push   $0x8023cf
  800174:	e8 1f 01 00 00       	call   800298 <_panic>

00800179 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  800179:	55                   	push   %ebp
  80017a:	89 e5                	mov    %esp,%ebp
  80017c:	53                   	push   %ebx
  80017d:	83 ec 20             	sub    $0x20,%esp
	int i, id, p[2], r;

	binaryname = "primespipe";
  800180:	c7 05 00 30 80 00 2d 	movl   $0x80242d,0x803000
  800187:	24 80 00 

	if ((i=pipe(p)) < 0)
  80018a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80018d:	50                   	push   %eax
  80018e:	e8 bd 1a 00 00       	call   801c50 <pipe>
  800193:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800196:	83 c4 10             	add    $0x10,%esp
  800199:	85 c0                	test   %eax,%eax
  80019b:	79 12                	jns    8001af <umain+0x36>
		panic("pipe: %e", i);
  80019d:	50                   	push   %eax
  80019e:	68 e5 23 80 00       	push   $0x8023e5
  8001a3:	6a 3a                	push   $0x3a
  8001a5:	68 cf 23 80 00       	push   $0x8023cf
  8001aa:	e8 e9 00 00 00       	call   800298 <_panic>

	// fork the first prime process in the chain
	if ((id=fork()) < 0)
  8001af:	e8 8a 0f 00 00       	call   80113e <fork>
  8001b4:	85 c0                	test   %eax,%eax
  8001b6:	79 12                	jns    8001ca <umain+0x51>
		panic("fork: %e", id);
  8001b8:	50                   	push   %eax
  8001b9:	68 ee 23 80 00       	push   $0x8023ee
  8001be:	6a 3e                	push   $0x3e
  8001c0:	68 cf 23 80 00       	push   $0x8023cf
  8001c5:	e8 ce 00 00 00       	call   800298 <_panic>

	if (id == 0) {
  8001ca:	85 c0                	test   %eax,%eax
  8001cc:	75 16                	jne    8001e4 <umain+0x6b>
		close(p[1]);
  8001ce:	83 ec 0c             	sub    $0xc,%esp
  8001d1:	ff 75 f0             	pushl  -0x10(%ebp)
  8001d4:	e8 62 12 00 00       	call   80143b <close>
		primeproc(p[0]);
  8001d9:	83 c4 04             	add    $0x4,%esp
  8001dc:	ff 75 ec             	pushl  -0x14(%ebp)
  8001df:	e8 4f fe ff ff       	call   800033 <primeproc>
	}

	close(p[0]);
  8001e4:	83 ec 0c             	sub    $0xc,%esp
  8001e7:	ff 75 ec             	pushl  -0x14(%ebp)
  8001ea:	e8 4c 12 00 00       	call   80143b <close>

	// feed all the integers through
	for (i=2;; i++)
  8001ef:	c7 45 f4 02 00 00 00 	movl   $0x2,-0xc(%ebp)
  8001f6:	83 c4 10             	add    $0x10,%esp
		if ((r=write(p[1], &i, 4)) != 4)
  8001f9:	8d 5d f4             	lea    -0xc(%ebp),%ebx
  8001fc:	83 ec 04             	sub    $0x4,%esp
  8001ff:	6a 04                	push   $0x4
  800201:	53                   	push   %ebx
  800202:	ff 75 f0             	pushl  -0x10(%ebp)
  800205:	e8 47 14 00 00       	call   801651 <write>
  80020a:	83 c4 10             	add    $0x10,%esp
  80020d:	83 f8 04             	cmp    $0x4,%eax
  800210:	74 20                	je     800232 <umain+0xb9>
			panic("generator write: %d, %e", r, r >= 0 ? 0 : r);
  800212:	83 ec 0c             	sub    $0xc,%esp
  800215:	85 c0                	test   %eax,%eax
  800217:	ba 00 00 00 00       	mov    $0x0,%edx
  80021c:	0f 4e d0             	cmovle %eax,%edx
  80021f:	52                   	push   %edx
  800220:	50                   	push   %eax
  800221:	68 38 24 80 00       	push   $0x802438
  800226:	6a 4a                	push   $0x4a
  800228:	68 cf 23 80 00       	push   $0x8023cf
  80022d:	e8 66 00 00 00       	call   800298 <_panic>
	}

	close(p[0]);

	// feed all the integers through
	for (i=2;; i++)
  800232:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
		if ((r=write(p[1], &i, 4)) != 4)
			panic("generator write: %d, %e", r, r >= 0 ? 0 : r);
}
  800236:	eb c4                	jmp    8001fc <umain+0x83>

00800238 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800238:	55                   	push   %ebp
  800239:	89 e5                	mov    %esp,%ebp
  80023b:	56                   	push   %esi
  80023c:	53                   	push   %ebx
  80023d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800240:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	envid_t envid = sys_getenvid();
  800243:	e8 1a 0b 00 00       	call   800d62 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  800248:	25 ff 03 00 00       	and    $0x3ff,%eax
  80024d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800250:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800255:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80025a:	85 db                	test   %ebx,%ebx
  80025c:	7e 07                	jle    800265 <libmain+0x2d>
		binaryname = argv[0];
  80025e:	8b 06                	mov    (%esi),%eax
  800260:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800265:	83 ec 08             	sub    $0x8,%esp
  800268:	56                   	push   %esi
  800269:	53                   	push   %ebx
  80026a:	e8 0a ff ff ff       	call   800179 <umain>

	// exit gracefully
	exit();
  80026f:	e8 0a 00 00 00       	call   80027e <exit>
}
  800274:	83 c4 10             	add    $0x10,%esp
  800277:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80027a:	5b                   	pop    %ebx
  80027b:	5e                   	pop    %esi
  80027c:	5d                   	pop    %ebp
  80027d:	c3                   	ret    

0080027e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80027e:	55                   	push   %ebp
  80027f:	89 e5                	mov    %esp,%ebp
  800281:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800284:	e8 dd 11 00 00       	call   801466 <close_all>
	sys_env_destroy(0);
  800289:	83 ec 0c             	sub    $0xc,%esp
  80028c:	6a 00                	push   $0x0
  80028e:	e8 8e 0a 00 00       	call   800d21 <sys_env_destroy>
}
  800293:	83 c4 10             	add    $0x10,%esp
  800296:	c9                   	leave  
  800297:	c3                   	ret    

00800298 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800298:	55                   	push   %ebp
  800299:	89 e5                	mov    %esp,%ebp
  80029b:	56                   	push   %esi
  80029c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80029d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002a0:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8002a6:	e8 b7 0a 00 00       	call   800d62 <sys_getenvid>
  8002ab:	83 ec 0c             	sub    $0xc,%esp
  8002ae:	ff 75 0c             	pushl  0xc(%ebp)
  8002b1:	ff 75 08             	pushl  0x8(%ebp)
  8002b4:	56                   	push   %esi
  8002b5:	50                   	push   %eax
  8002b6:	68 5c 24 80 00       	push   $0x80245c
  8002bb:	e8 b1 00 00 00       	call   800371 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002c0:	83 c4 18             	add    $0x18,%esp
  8002c3:	53                   	push   %ebx
  8002c4:	ff 75 10             	pushl  0x10(%ebp)
  8002c7:	e8 54 00 00 00       	call   800320 <vcprintf>
	cprintf("\n");
  8002cc:	c7 04 24 e3 23 80 00 	movl   $0x8023e3,(%esp)
  8002d3:	e8 99 00 00 00       	call   800371 <cprintf>
  8002d8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002db:	cc                   	int3   
  8002dc:	eb fd                	jmp    8002db <_panic+0x43>

008002de <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002de:	55                   	push   %ebp
  8002df:	89 e5                	mov    %esp,%ebp
  8002e1:	53                   	push   %ebx
  8002e2:	83 ec 04             	sub    $0x4,%esp
  8002e5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002e8:	8b 13                	mov    (%ebx),%edx
  8002ea:	8d 42 01             	lea    0x1(%edx),%eax
  8002ed:	89 03                	mov    %eax,(%ebx)
  8002ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002f2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002f6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002fb:	75 1a                	jne    800317 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8002fd:	83 ec 08             	sub    $0x8,%esp
  800300:	68 ff 00 00 00       	push   $0xff
  800305:	8d 43 08             	lea    0x8(%ebx),%eax
  800308:	50                   	push   %eax
  800309:	e8 d6 09 00 00       	call   800ce4 <sys_cputs>
		b->idx = 0;
  80030e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800314:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800317:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80031b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80031e:	c9                   	leave  
  80031f:	c3                   	ret    

00800320 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800329:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800330:	00 00 00 
	b.cnt = 0;
  800333:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80033a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80033d:	ff 75 0c             	pushl  0xc(%ebp)
  800340:	ff 75 08             	pushl  0x8(%ebp)
  800343:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800349:	50                   	push   %eax
  80034a:	68 de 02 80 00       	push   $0x8002de
  80034f:	e8 1a 01 00 00       	call   80046e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800354:	83 c4 08             	add    $0x8,%esp
  800357:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80035d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800363:	50                   	push   %eax
  800364:	e8 7b 09 00 00       	call   800ce4 <sys_cputs>

	return b.cnt;
}
  800369:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80036f:	c9                   	leave  
  800370:	c3                   	ret    

00800371 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800371:	55                   	push   %ebp
  800372:	89 e5                	mov    %esp,%ebp
  800374:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800377:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80037a:	50                   	push   %eax
  80037b:	ff 75 08             	pushl  0x8(%ebp)
  80037e:	e8 9d ff ff ff       	call   800320 <vcprintf>
	va_end(ap);

	return cnt;
}
  800383:	c9                   	leave  
  800384:	c3                   	ret    

00800385 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800385:	55                   	push   %ebp
  800386:	89 e5                	mov    %esp,%ebp
  800388:	57                   	push   %edi
  800389:	56                   	push   %esi
  80038a:	53                   	push   %ebx
  80038b:	83 ec 1c             	sub    $0x1c,%esp
  80038e:	89 c7                	mov    %eax,%edi
  800390:	89 d6                	mov    %edx,%esi
  800392:	8b 45 08             	mov    0x8(%ebp),%eax
  800395:	8b 55 0c             	mov    0xc(%ebp),%edx
  800398:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80039b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80039e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8003a1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003a6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8003a9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8003ac:	39 d3                	cmp    %edx,%ebx
  8003ae:	72 05                	jb     8003b5 <printnum+0x30>
  8003b0:	39 45 10             	cmp    %eax,0x10(%ebp)
  8003b3:	77 45                	ja     8003fa <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003b5:	83 ec 0c             	sub    $0xc,%esp
  8003b8:	ff 75 18             	pushl  0x18(%ebp)
  8003bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8003be:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8003c1:	53                   	push   %ebx
  8003c2:	ff 75 10             	pushl  0x10(%ebp)
  8003c5:	83 ec 08             	sub    $0x8,%esp
  8003c8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003cb:	ff 75 e0             	pushl  -0x20(%ebp)
  8003ce:	ff 75 dc             	pushl  -0x24(%ebp)
  8003d1:	ff 75 d8             	pushl  -0x28(%ebp)
  8003d4:	e8 37 1d 00 00       	call   802110 <__udivdi3>
  8003d9:	83 c4 18             	add    $0x18,%esp
  8003dc:	52                   	push   %edx
  8003dd:	50                   	push   %eax
  8003de:	89 f2                	mov    %esi,%edx
  8003e0:	89 f8                	mov    %edi,%eax
  8003e2:	e8 9e ff ff ff       	call   800385 <printnum>
  8003e7:	83 c4 20             	add    $0x20,%esp
  8003ea:	eb 18                	jmp    800404 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003ec:	83 ec 08             	sub    $0x8,%esp
  8003ef:	56                   	push   %esi
  8003f0:	ff 75 18             	pushl  0x18(%ebp)
  8003f3:	ff d7                	call   *%edi
  8003f5:	83 c4 10             	add    $0x10,%esp
  8003f8:	eb 03                	jmp    8003fd <printnum+0x78>
  8003fa:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003fd:	83 eb 01             	sub    $0x1,%ebx
  800400:	85 db                	test   %ebx,%ebx
  800402:	7f e8                	jg     8003ec <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800404:	83 ec 08             	sub    $0x8,%esp
  800407:	56                   	push   %esi
  800408:	83 ec 04             	sub    $0x4,%esp
  80040b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80040e:	ff 75 e0             	pushl  -0x20(%ebp)
  800411:	ff 75 dc             	pushl  -0x24(%ebp)
  800414:	ff 75 d8             	pushl  -0x28(%ebp)
  800417:	e8 24 1e 00 00       	call   802240 <__umoddi3>
  80041c:	83 c4 14             	add    $0x14,%esp
  80041f:	0f be 80 7f 24 80 00 	movsbl 0x80247f(%eax),%eax
  800426:	50                   	push   %eax
  800427:	ff d7                	call   *%edi
}
  800429:	83 c4 10             	add    $0x10,%esp
  80042c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80042f:	5b                   	pop    %ebx
  800430:	5e                   	pop    %esi
  800431:	5f                   	pop    %edi
  800432:	5d                   	pop    %ebp
  800433:	c3                   	ret    

00800434 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800434:	55                   	push   %ebp
  800435:	89 e5                	mov    %esp,%ebp
  800437:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80043a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80043e:	8b 10                	mov    (%eax),%edx
  800440:	3b 50 04             	cmp    0x4(%eax),%edx
  800443:	73 0a                	jae    80044f <sprintputch+0x1b>
		*b->buf++ = ch;
  800445:	8d 4a 01             	lea    0x1(%edx),%ecx
  800448:	89 08                	mov    %ecx,(%eax)
  80044a:	8b 45 08             	mov    0x8(%ebp),%eax
  80044d:	88 02                	mov    %al,(%edx)
}
  80044f:	5d                   	pop    %ebp
  800450:	c3                   	ret    

00800451 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800451:	55                   	push   %ebp
  800452:	89 e5                	mov    %esp,%ebp
  800454:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800457:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80045a:	50                   	push   %eax
  80045b:	ff 75 10             	pushl  0x10(%ebp)
  80045e:	ff 75 0c             	pushl  0xc(%ebp)
  800461:	ff 75 08             	pushl  0x8(%ebp)
  800464:	e8 05 00 00 00       	call   80046e <vprintfmt>
	va_end(ap);
}
  800469:	83 c4 10             	add    $0x10,%esp
  80046c:	c9                   	leave  
  80046d:	c3                   	ret    

0080046e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80046e:	55                   	push   %ebp
  80046f:	89 e5                	mov    %esp,%ebp
  800471:	57                   	push   %edi
  800472:	56                   	push   %esi
  800473:	53                   	push   %ebx
  800474:	83 ec 2c             	sub    $0x2c,%esp
  800477:	8b 75 08             	mov    0x8(%ebp),%esi
  80047a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80047d:	8b 7d 10             	mov    0x10(%ebp),%edi
  800480:	eb 12                	jmp    800494 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800482:	85 c0                	test   %eax,%eax
  800484:	0f 84 6a 04 00 00    	je     8008f4 <vprintfmt+0x486>
				return;
			putch(ch, putdat);
  80048a:	83 ec 08             	sub    $0x8,%esp
  80048d:	53                   	push   %ebx
  80048e:	50                   	push   %eax
  80048f:	ff d6                	call   *%esi
  800491:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800494:	83 c7 01             	add    $0x1,%edi
  800497:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80049b:	83 f8 25             	cmp    $0x25,%eax
  80049e:	75 e2                	jne    800482 <vprintfmt+0x14>
  8004a0:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8004a4:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8004ab:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004b2:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8004b9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004be:	eb 07                	jmp    8004c7 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004c3:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c7:	8d 47 01             	lea    0x1(%edi),%eax
  8004ca:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004cd:	0f b6 07             	movzbl (%edi),%eax
  8004d0:	0f b6 d0             	movzbl %al,%edx
  8004d3:	83 e8 23             	sub    $0x23,%eax
  8004d6:	3c 55                	cmp    $0x55,%al
  8004d8:	0f 87 fb 03 00 00    	ja     8008d9 <vprintfmt+0x46b>
  8004de:	0f b6 c0             	movzbl %al,%eax
  8004e1:	ff 24 85 c0 25 80 00 	jmp    *0x8025c0(,%eax,4)
  8004e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004eb:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004ef:	eb d6                	jmp    8004c7 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8004f9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004fc:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004ff:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800503:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800506:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800509:	83 f9 09             	cmp    $0x9,%ecx
  80050c:	77 3f                	ja     80054d <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80050e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800511:	eb e9                	jmp    8004fc <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800513:	8b 45 14             	mov    0x14(%ebp),%eax
  800516:	8b 00                	mov    (%eax),%eax
  800518:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80051b:	8b 45 14             	mov    0x14(%ebp),%eax
  80051e:	8d 40 04             	lea    0x4(%eax),%eax
  800521:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800524:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800527:	eb 2a                	jmp    800553 <vprintfmt+0xe5>
  800529:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80052c:	85 c0                	test   %eax,%eax
  80052e:	ba 00 00 00 00       	mov    $0x0,%edx
  800533:	0f 49 d0             	cmovns %eax,%edx
  800536:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800539:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80053c:	eb 89                	jmp    8004c7 <vprintfmt+0x59>
  80053e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800541:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800548:	e9 7a ff ff ff       	jmp    8004c7 <vprintfmt+0x59>
  80054d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800550:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800553:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800557:	0f 89 6a ff ff ff    	jns    8004c7 <vprintfmt+0x59>
				width = precision, precision = -1;
  80055d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800560:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800563:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80056a:	e9 58 ff ff ff       	jmp    8004c7 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80056f:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800572:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800575:	e9 4d ff ff ff       	jmp    8004c7 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80057a:	8b 45 14             	mov    0x14(%ebp),%eax
  80057d:	8d 78 04             	lea    0x4(%eax),%edi
  800580:	83 ec 08             	sub    $0x8,%esp
  800583:	53                   	push   %ebx
  800584:	ff 30                	pushl  (%eax)
  800586:	ff d6                	call   *%esi
			break;
  800588:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80058b:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800591:	e9 fe fe ff ff       	jmp    800494 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800596:	8b 45 14             	mov    0x14(%ebp),%eax
  800599:	8d 78 04             	lea    0x4(%eax),%edi
  80059c:	8b 00                	mov    (%eax),%eax
  80059e:	99                   	cltd   
  80059f:	31 d0                	xor    %edx,%eax
  8005a1:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005a3:	83 f8 0f             	cmp    $0xf,%eax
  8005a6:	7f 0b                	jg     8005b3 <vprintfmt+0x145>
  8005a8:	8b 14 85 20 27 80 00 	mov    0x802720(,%eax,4),%edx
  8005af:	85 d2                	test   %edx,%edx
  8005b1:	75 1b                	jne    8005ce <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  8005b3:	50                   	push   %eax
  8005b4:	68 97 24 80 00       	push   $0x802497
  8005b9:	53                   	push   %ebx
  8005ba:	56                   	push   %esi
  8005bb:	e8 91 fe ff ff       	call   800451 <printfmt>
  8005c0:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005c3:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005c9:	e9 c6 fe ff ff       	jmp    800494 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8005ce:	52                   	push   %edx
  8005cf:	68 5e 29 80 00       	push   $0x80295e
  8005d4:	53                   	push   %ebx
  8005d5:	56                   	push   %esi
  8005d6:	e8 76 fe ff ff       	call   800451 <printfmt>
  8005db:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005de:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005e4:	e9 ab fe ff ff       	jmp    800494 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ec:	83 c0 04             	add    $0x4,%eax
  8005ef:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8005f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f5:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005f7:	85 ff                	test   %edi,%edi
  8005f9:	b8 90 24 80 00       	mov    $0x802490,%eax
  8005fe:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800601:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800605:	0f 8e 94 00 00 00    	jle    80069f <vprintfmt+0x231>
  80060b:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80060f:	0f 84 98 00 00 00    	je     8006ad <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800615:	83 ec 08             	sub    $0x8,%esp
  800618:	ff 75 d0             	pushl  -0x30(%ebp)
  80061b:	57                   	push   %edi
  80061c:	e8 5b 03 00 00       	call   80097c <strnlen>
  800621:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800624:	29 c1                	sub    %eax,%ecx
  800626:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800629:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80062c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800630:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800633:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800636:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800638:	eb 0f                	jmp    800649 <vprintfmt+0x1db>
					putch(padc, putdat);
  80063a:	83 ec 08             	sub    $0x8,%esp
  80063d:	53                   	push   %ebx
  80063e:	ff 75 e0             	pushl  -0x20(%ebp)
  800641:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800643:	83 ef 01             	sub    $0x1,%edi
  800646:	83 c4 10             	add    $0x10,%esp
  800649:	85 ff                	test   %edi,%edi
  80064b:	7f ed                	jg     80063a <vprintfmt+0x1cc>
  80064d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800650:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800653:	85 c9                	test   %ecx,%ecx
  800655:	b8 00 00 00 00       	mov    $0x0,%eax
  80065a:	0f 49 c1             	cmovns %ecx,%eax
  80065d:	29 c1                	sub    %eax,%ecx
  80065f:	89 75 08             	mov    %esi,0x8(%ebp)
  800662:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800665:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800668:	89 cb                	mov    %ecx,%ebx
  80066a:	eb 4d                	jmp    8006b9 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80066c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800670:	74 1b                	je     80068d <vprintfmt+0x21f>
  800672:	0f be c0             	movsbl %al,%eax
  800675:	83 e8 20             	sub    $0x20,%eax
  800678:	83 f8 5e             	cmp    $0x5e,%eax
  80067b:	76 10                	jbe    80068d <vprintfmt+0x21f>
					putch('?', putdat);
  80067d:	83 ec 08             	sub    $0x8,%esp
  800680:	ff 75 0c             	pushl  0xc(%ebp)
  800683:	6a 3f                	push   $0x3f
  800685:	ff 55 08             	call   *0x8(%ebp)
  800688:	83 c4 10             	add    $0x10,%esp
  80068b:	eb 0d                	jmp    80069a <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  80068d:	83 ec 08             	sub    $0x8,%esp
  800690:	ff 75 0c             	pushl  0xc(%ebp)
  800693:	52                   	push   %edx
  800694:	ff 55 08             	call   *0x8(%ebp)
  800697:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80069a:	83 eb 01             	sub    $0x1,%ebx
  80069d:	eb 1a                	jmp    8006b9 <vprintfmt+0x24b>
  80069f:	89 75 08             	mov    %esi,0x8(%ebp)
  8006a2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006a5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006a8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006ab:	eb 0c                	jmp    8006b9 <vprintfmt+0x24b>
  8006ad:	89 75 08             	mov    %esi,0x8(%ebp)
  8006b0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006b3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006b6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006b9:	83 c7 01             	add    $0x1,%edi
  8006bc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006c0:	0f be d0             	movsbl %al,%edx
  8006c3:	85 d2                	test   %edx,%edx
  8006c5:	74 23                	je     8006ea <vprintfmt+0x27c>
  8006c7:	85 f6                	test   %esi,%esi
  8006c9:	78 a1                	js     80066c <vprintfmt+0x1fe>
  8006cb:	83 ee 01             	sub    $0x1,%esi
  8006ce:	79 9c                	jns    80066c <vprintfmt+0x1fe>
  8006d0:	89 df                	mov    %ebx,%edi
  8006d2:	8b 75 08             	mov    0x8(%ebp),%esi
  8006d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006d8:	eb 18                	jmp    8006f2 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006da:	83 ec 08             	sub    $0x8,%esp
  8006dd:	53                   	push   %ebx
  8006de:	6a 20                	push   $0x20
  8006e0:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006e2:	83 ef 01             	sub    $0x1,%edi
  8006e5:	83 c4 10             	add    $0x10,%esp
  8006e8:	eb 08                	jmp    8006f2 <vprintfmt+0x284>
  8006ea:	89 df                	mov    %ebx,%edi
  8006ec:	8b 75 08             	mov    0x8(%ebp),%esi
  8006ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006f2:	85 ff                	test   %edi,%edi
  8006f4:	7f e4                	jg     8006da <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006f6:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8006f9:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006ff:	e9 90 fd ff ff       	jmp    800494 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800704:	83 f9 01             	cmp    $0x1,%ecx
  800707:	7e 19                	jle    800722 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800709:	8b 45 14             	mov    0x14(%ebp),%eax
  80070c:	8b 50 04             	mov    0x4(%eax),%edx
  80070f:	8b 00                	mov    (%eax),%eax
  800711:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800714:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800717:	8b 45 14             	mov    0x14(%ebp),%eax
  80071a:	8d 40 08             	lea    0x8(%eax),%eax
  80071d:	89 45 14             	mov    %eax,0x14(%ebp)
  800720:	eb 38                	jmp    80075a <vprintfmt+0x2ec>
	else if (lflag)
  800722:	85 c9                	test   %ecx,%ecx
  800724:	74 1b                	je     800741 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800726:	8b 45 14             	mov    0x14(%ebp),%eax
  800729:	8b 00                	mov    (%eax),%eax
  80072b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80072e:	89 c1                	mov    %eax,%ecx
  800730:	c1 f9 1f             	sar    $0x1f,%ecx
  800733:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800736:	8b 45 14             	mov    0x14(%ebp),%eax
  800739:	8d 40 04             	lea    0x4(%eax),%eax
  80073c:	89 45 14             	mov    %eax,0x14(%ebp)
  80073f:	eb 19                	jmp    80075a <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800741:	8b 45 14             	mov    0x14(%ebp),%eax
  800744:	8b 00                	mov    (%eax),%eax
  800746:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800749:	89 c1                	mov    %eax,%ecx
  80074b:	c1 f9 1f             	sar    $0x1f,%ecx
  80074e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800751:	8b 45 14             	mov    0x14(%ebp),%eax
  800754:	8d 40 04             	lea    0x4(%eax),%eax
  800757:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80075a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80075d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800760:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800765:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800769:	0f 89 36 01 00 00    	jns    8008a5 <vprintfmt+0x437>
				putch('-', putdat);
  80076f:	83 ec 08             	sub    $0x8,%esp
  800772:	53                   	push   %ebx
  800773:	6a 2d                	push   $0x2d
  800775:	ff d6                	call   *%esi
				num = -(long long) num;
  800777:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80077a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80077d:	f7 da                	neg    %edx
  80077f:	83 d1 00             	adc    $0x0,%ecx
  800782:	f7 d9                	neg    %ecx
  800784:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800787:	b8 0a 00 00 00       	mov    $0xa,%eax
  80078c:	e9 14 01 00 00       	jmp    8008a5 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800791:	83 f9 01             	cmp    $0x1,%ecx
  800794:	7e 18                	jle    8007ae <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800796:	8b 45 14             	mov    0x14(%ebp),%eax
  800799:	8b 10                	mov    (%eax),%edx
  80079b:	8b 48 04             	mov    0x4(%eax),%ecx
  80079e:	8d 40 08             	lea    0x8(%eax),%eax
  8007a1:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8007a4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007a9:	e9 f7 00 00 00       	jmp    8008a5 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8007ae:	85 c9                	test   %ecx,%ecx
  8007b0:	74 1a                	je     8007cc <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  8007b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b5:	8b 10                	mov    (%eax),%edx
  8007b7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007bc:	8d 40 04             	lea    0x4(%eax),%eax
  8007bf:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8007c2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007c7:	e9 d9 00 00 00       	jmp    8008a5 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8007cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8007cf:	8b 10                	mov    (%eax),%edx
  8007d1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007d6:	8d 40 04             	lea    0x4(%eax),%eax
  8007d9:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8007dc:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007e1:	e9 bf 00 00 00       	jmp    8008a5 <vprintfmt+0x437>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007e6:	83 f9 01             	cmp    $0x1,%ecx
  8007e9:	7e 13                	jle    8007fe <vprintfmt+0x390>
		return va_arg(*ap, long long);
  8007eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ee:	8b 50 04             	mov    0x4(%eax),%edx
  8007f1:	8b 00                	mov    (%eax),%eax
  8007f3:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8007f6:	8d 49 08             	lea    0x8(%ecx),%ecx
  8007f9:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8007fc:	eb 28                	jmp    800826 <vprintfmt+0x3b8>
	else if (lflag)
  8007fe:	85 c9                	test   %ecx,%ecx
  800800:	74 13                	je     800815 <vprintfmt+0x3a7>
		return va_arg(*ap, long);
  800802:	8b 45 14             	mov    0x14(%ebp),%eax
  800805:	8b 10                	mov    (%eax),%edx
  800807:	89 d0                	mov    %edx,%eax
  800809:	99                   	cltd   
  80080a:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80080d:	8d 49 04             	lea    0x4(%ecx),%ecx
  800810:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800813:	eb 11                	jmp    800826 <vprintfmt+0x3b8>
	else
		return va_arg(*ap, int);
  800815:	8b 45 14             	mov    0x14(%ebp),%eax
  800818:	8b 10                	mov    (%eax),%edx
  80081a:	89 d0                	mov    %edx,%eax
  80081c:	99                   	cltd   
  80081d:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800820:	8d 49 04             	lea    0x4(%ecx),%ecx
  800823:	89 4d 14             	mov    %ecx,0x14(%ebp)
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getint(&ap, lflag);
  800826:	89 d1                	mov    %edx,%ecx
  800828:	89 c2                	mov    %eax,%edx
			base = 8;
  80082a:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  80082f:	eb 74                	jmp    8008a5 <vprintfmt+0x437>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800831:	83 ec 08             	sub    $0x8,%esp
  800834:	53                   	push   %ebx
  800835:	6a 30                	push   $0x30
  800837:	ff d6                	call   *%esi
			putch('x', putdat);
  800839:	83 c4 08             	add    $0x8,%esp
  80083c:	53                   	push   %ebx
  80083d:	6a 78                	push   $0x78
  80083f:	ff d6                	call   *%esi
			num = (unsigned long long)
  800841:	8b 45 14             	mov    0x14(%ebp),%eax
  800844:	8b 10                	mov    (%eax),%edx
  800846:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80084b:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80084e:	8d 40 04             	lea    0x4(%eax),%eax
  800851:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800854:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800859:	eb 4a                	jmp    8008a5 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80085b:	83 f9 01             	cmp    $0x1,%ecx
  80085e:	7e 15                	jle    800875 <vprintfmt+0x407>
		return va_arg(*ap, unsigned long long);
  800860:	8b 45 14             	mov    0x14(%ebp),%eax
  800863:	8b 10                	mov    (%eax),%edx
  800865:	8b 48 04             	mov    0x4(%eax),%ecx
  800868:	8d 40 08             	lea    0x8(%eax),%eax
  80086b:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80086e:	b8 10 00 00 00       	mov    $0x10,%eax
  800873:	eb 30                	jmp    8008a5 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800875:	85 c9                	test   %ecx,%ecx
  800877:	74 17                	je     800890 <vprintfmt+0x422>
		return va_arg(*ap, unsigned long);
  800879:	8b 45 14             	mov    0x14(%ebp),%eax
  80087c:	8b 10                	mov    (%eax),%edx
  80087e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800883:	8d 40 04             	lea    0x4(%eax),%eax
  800886:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800889:	b8 10 00 00 00       	mov    $0x10,%eax
  80088e:	eb 15                	jmp    8008a5 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800890:	8b 45 14             	mov    0x14(%ebp),%eax
  800893:	8b 10                	mov    (%eax),%edx
  800895:	b9 00 00 00 00       	mov    $0x0,%ecx
  80089a:	8d 40 04             	lea    0x4(%eax),%eax
  80089d:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8008a0:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008a5:	83 ec 0c             	sub    $0xc,%esp
  8008a8:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8008ac:	57                   	push   %edi
  8008ad:	ff 75 e0             	pushl  -0x20(%ebp)
  8008b0:	50                   	push   %eax
  8008b1:	51                   	push   %ecx
  8008b2:	52                   	push   %edx
  8008b3:	89 da                	mov    %ebx,%edx
  8008b5:	89 f0                	mov    %esi,%eax
  8008b7:	e8 c9 fa ff ff       	call   800385 <printnum>
			break;
  8008bc:	83 c4 20             	add    $0x20,%esp
  8008bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008c2:	e9 cd fb ff ff       	jmp    800494 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008c7:	83 ec 08             	sub    $0x8,%esp
  8008ca:	53                   	push   %ebx
  8008cb:	52                   	push   %edx
  8008cc:	ff d6                	call   *%esi
			break;
  8008ce:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008d4:	e9 bb fb ff ff       	jmp    800494 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008d9:	83 ec 08             	sub    $0x8,%esp
  8008dc:	53                   	push   %ebx
  8008dd:	6a 25                	push   $0x25
  8008df:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008e1:	83 c4 10             	add    $0x10,%esp
  8008e4:	eb 03                	jmp    8008e9 <vprintfmt+0x47b>
  8008e6:	83 ef 01             	sub    $0x1,%edi
  8008e9:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8008ed:	75 f7                	jne    8008e6 <vprintfmt+0x478>
  8008ef:	e9 a0 fb ff ff       	jmp    800494 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8008f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008f7:	5b                   	pop    %ebx
  8008f8:	5e                   	pop    %esi
  8008f9:	5f                   	pop    %edi
  8008fa:	5d                   	pop    %ebp
  8008fb:	c3                   	ret    

008008fc <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008fc:	55                   	push   %ebp
  8008fd:	89 e5                	mov    %esp,%ebp
  8008ff:	83 ec 18             	sub    $0x18,%esp
  800902:	8b 45 08             	mov    0x8(%ebp),%eax
  800905:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800908:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80090b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80090f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800912:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800919:	85 c0                	test   %eax,%eax
  80091b:	74 26                	je     800943 <vsnprintf+0x47>
  80091d:	85 d2                	test   %edx,%edx
  80091f:	7e 22                	jle    800943 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800921:	ff 75 14             	pushl  0x14(%ebp)
  800924:	ff 75 10             	pushl  0x10(%ebp)
  800927:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80092a:	50                   	push   %eax
  80092b:	68 34 04 80 00       	push   $0x800434
  800930:	e8 39 fb ff ff       	call   80046e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800935:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800938:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80093b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80093e:	83 c4 10             	add    $0x10,%esp
  800941:	eb 05                	jmp    800948 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800943:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800948:	c9                   	leave  
  800949:	c3                   	ret    

0080094a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80094a:	55                   	push   %ebp
  80094b:	89 e5                	mov    %esp,%ebp
  80094d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800950:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800953:	50                   	push   %eax
  800954:	ff 75 10             	pushl  0x10(%ebp)
  800957:	ff 75 0c             	pushl  0xc(%ebp)
  80095a:	ff 75 08             	pushl  0x8(%ebp)
  80095d:	e8 9a ff ff ff       	call   8008fc <vsnprintf>
	va_end(ap);

	return rc;
}
  800962:	c9                   	leave  
  800963:	c3                   	ret    

00800964 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800964:	55                   	push   %ebp
  800965:	89 e5                	mov    %esp,%ebp
  800967:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80096a:	b8 00 00 00 00       	mov    $0x0,%eax
  80096f:	eb 03                	jmp    800974 <strlen+0x10>
		n++;
  800971:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800974:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800978:	75 f7                	jne    800971 <strlen+0xd>
		n++;
	return n;
}
  80097a:	5d                   	pop    %ebp
  80097b:	c3                   	ret    

0080097c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80097c:	55                   	push   %ebp
  80097d:	89 e5                	mov    %esp,%ebp
  80097f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800982:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800985:	ba 00 00 00 00       	mov    $0x0,%edx
  80098a:	eb 03                	jmp    80098f <strnlen+0x13>
		n++;
  80098c:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80098f:	39 c2                	cmp    %eax,%edx
  800991:	74 08                	je     80099b <strnlen+0x1f>
  800993:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800997:	75 f3                	jne    80098c <strnlen+0x10>
  800999:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80099b:	5d                   	pop    %ebp
  80099c:	c3                   	ret    

0080099d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80099d:	55                   	push   %ebp
  80099e:	89 e5                	mov    %esp,%ebp
  8009a0:	53                   	push   %ebx
  8009a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009a7:	89 c2                	mov    %eax,%edx
  8009a9:	83 c2 01             	add    $0x1,%edx
  8009ac:	83 c1 01             	add    $0x1,%ecx
  8009af:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009b3:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009b6:	84 db                	test   %bl,%bl
  8009b8:	75 ef                	jne    8009a9 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009ba:	5b                   	pop    %ebx
  8009bb:	5d                   	pop    %ebp
  8009bc:	c3                   	ret    

008009bd <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009bd:	55                   	push   %ebp
  8009be:	89 e5                	mov    %esp,%ebp
  8009c0:	53                   	push   %ebx
  8009c1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009c4:	53                   	push   %ebx
  8009c5:	e8 9a ff ff ff       	call   800964 <strlen>
  8009ca:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009cd:	ff 75 0c             	pushl  0xc(%ebp)
  8009d0:	01 d8                	add    %ebx,%eax
  8009d2:	50                   	push   %eax
  8009d3:	e8 c5 ff ff ff       	call   80099d <strcpy>
	return dst;
}
  8009d8:	89 d8                	mov    %ebx,%eax
  8009da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009dd:	c9                   	leave  
  8009de:	c3                   	ret    

008009df <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009df:	55                   	push   %ebp
  8009e0:	89 e5                	mov    %esp,%ebp
  8009e2:	56                   	push   %esi
  8009e3:	53                   	push   %ebx
  8009e4:	8b 75 08             	mov    0x8(%ebp),%esi
  8009e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009ea:	89 f3                	mov    %esi,%ebx
  8009ec:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009ef:	89 f2                	mov    %esi,%edx
  8009f1:	eb 0f                	jmp    800a02 <strncpy+0x23>
		*dst++ = *src;
  8009f3:	83 c2 01             	add    $0x1,%edx
  8009f6:	0f b6 01             	movzbl (%ecx),%eax
  8009f9:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009fc:	80 39 01             	cmpb   $0x1,(%ecx)
  8009ff:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a02:	39 da                	cmp    %ebx,%edx
  800a04:	75 ed                	jne    8009f3 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a06:	89 f0                	mov    %esi,%eax
  800a08:	5b                   	pop    %ebx
  800a09:	5e                   	pop    %esi
  800a0a:	5d                   	pop    %ebp
  800a0b:	c3                   	ret    

00800a0c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a0c:	55                   	push   %ebp
  800a0d:	89 e5                	mov    %esp,%ebp
  800a0f:	56                   	push   %esi
  800a10:	53                   	push   %ebx
  800a11:	8b 75 08             	mov    0x8(%ebp),%esi
  800a14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a17:	8b 55 10             	mov    0x10(%ebp),%edx
  800a1a:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a1c:	85 d2                	test   %edx,%edx
  800a1e:	74 21                	je     800a41 <strlcpy+0x35>
  800a20:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a24:	89 f2                	mov    %esi,%edx
  800a26:	eb 09                	jmp    800a31 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a28:	83 c2 01             	add    $0x1,%edx
  800a2b:	83 c1 01             	add    $0x1,%ecx
  800a2e:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a31:	39 c2                	cmp    %eax,%edx
  800a33:	74 09                	je     800a3e <strlcpy+0x32>
  800a35:	0f b6 19             	movzbl (%ecx),%ebx
  800a38:	84 db                	test   %bl,%bl
  800a3a:	75 ec                	jne    800a28 <strlcpy+0x1c>
  800a3c:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a3e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a41:	29 f0                	sub    %esi,%eax
}
  800a43:	5b                   	pop    %ebx
  800a44:	5e                   	pop    %esi
  800a45:	5d                   	pop    %ebp
  800a46:	c3                   	ret    

00800a47 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a47:	55                   	push   %ebp
  800a48:	89 e5                	mov    %esp,%ebp
  800a4a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a4d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a50:	eb 06                	jmp    800a58 <strcmp+0x11>
		p++, q++;
  800a52:	83 c1 01             	add    $0x1,%ecx
  800a55:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a58:	0f b6 01             	movzbl (%ecx),%eax
  800a5b:	84 c0                	test   %al,%al
  800a5d:	74 04                	je     800a63 <strcmp+0x1c>
  800a5f:	3a 02                	cmp    (%edx),%al
  800a61:	74 ef                	je     800a52 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a63:	0f b6 c0             	movzbl %al,%eax
  800a66:	0f b6 12             	movzbl (%edx),%edx
  800a69:	29 d0                	sub    %edx,%eax
}
  800a6b:	5d                   	pop    %ebp
  800a6c:	c3                   	ret    

00800a6d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a6d:	55                   	push   %ebp
  800a6e:	89 e5                	mov    %esp,%ebp
  800a70:	53                   	push   %ebx
  800a71:	8b 45 08             	mov    0x8(%ebp),%eax
  800a74:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a77:	89 c3                	mov    %eax,%ebx
  800a79:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a7c:	eb 06                	jmp    800a84 <strncmp+0x17>
		n--, p++, q++;
  800a7e:	83 c0 01             	add    $0x1,%eax
  800a81:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a84:	39 d8                	cmp    %ebx,%eax
  800a86:	74 15                	je     800a9d <strncmp+0x30>
  800a88:	0f b6 08             	movzbl (%eax),%ecx
  800a8b:	84 c9                	test   %cl,%cl
  800a8d:	74 04                	je     800a93 <strncmp+0x26>
  800a8f:	3a 0a                	cmp    (%edx),%cl
  800a91:	74 eb                	je     800a7e <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a93:	0f b6 00             	movzbl (%eax),%eax
  800a96:	0f b6 12             	movzbl (%edx),%edx
  800a99:	29 d0                	sub    %edx,%eax
  800a9b:	eb 05                	jmp    800aa2 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a9d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800aa2:	5b                   	pop    %ebx
  800aa3:	5d                   	pop    %ebp
  800aa4:	c3                   	ret    

00800aa5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800aa5:	55                   	push   %ebp
  800aa6:	89 e5                	mov    %esp,%ebp
  800aa8:	8b 45 08             	mov    0x8(%ebp),%eax
  800aab:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800aaf:	eb 07                	jmp    800ab8 <strchr+0x13>
		if (*s == c)
  800ab1:	38 ca                	cmp    %cl,%dl
  800ab3:	74 0f                	je     800ac4 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ab5:	83 c0 01             	add    $0x1,%eax
  800ab8:	0f b6 10             	movzbl (%eax),%edx
  800abb:	84 d2                	test   %dl,%dl
  800abd:	75 f2                	jne    800ab1 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800abf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ac4:	5d                   	pop    %ebp
  800ac5:	c3                   	ret    

00800ac6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ac6:	55                   	push   %ebp
  800ac7:	89 e5                	mov    %esp,%ebp
  800ac9:	8b 45 08             	mov    0x8(%ebp),%eax
  800acc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ad0:	eb 03                	jmp    800ad5 <strfind+0xf>
  800ad2:	83 c0 01             	add    $0x1,%eax
  800ad5:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800ad8:	38 ca                	cmp    %cl,%dl
  800ada:	74 04                	je     800ae0 <strfind+0x1a>
  800adc:	84 d2                	test   %dl,%dl
  800ade:	75 f2                	jne    800ad2 <strfind+0xc>
			break;
	return (char *) s;
}
  800ae0:	5d                   	pop    %ebp
  800ae1:	c3                   	ret    

00800ae2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ae2:	55                   	push   %ebp
  800ae3:	89 e5                	mov    %esp,%ebp
  800ae5:	57                   	push   %edi
  800ae6:	56                   	push   %esi
  800ae7:	53                   	push   %ebx
  800ae8:	8b 7d 08             	mov    0x8(%ebp),%edi
  800aeb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800aee:	85 c9                	test   %ecx,%ecx
  800af0:	74 36                	je     800b28 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800af2:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800af8:	75 28                	jne    800b22 <memset+0x40>
  800afa:	f6 c1 03             	test   $0x3,%cl
  800afd:	75 23                	jne    800b22 <memset+0x40>
		c &= 0xFF;
  800aff:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b03:	89 d3                	mov    %edx,%ebx
  800b05:	c1 e3 08             	shl    $0x8,%ebx
  800b08:	89 d6                	mov    %edx,%esi
  800b0a:	c1 e6 18             	shl    $0x18,%esi
  800b0d:	89 d0                	mov    %edx,%eax
  800b0f:	c1 e0 10             	shl    $0x10,%eax
  800b12:	09 f0                	or     %esi,%eax
  800b14:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b16:	89 d8                	mov    %ebx,%eax
  800b18:	09 d0                	or     %edx,%eax
  800b1a:	c1 e9 02             	shr    $0x2,%ecx
  800b1d:	fc                   	cld    
  800b1e:	f3 ab                	rep stos %eax,%es:(%edi)
  800b20:	eb 06                	jmp    800b28 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b22:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b25:	fc                   	cld    
  800b26:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b28:	89 f8                	mov    %edi,%eax
  800b2a:	5b                   	pop    %ebx
  800b2b:	5e                   	pop    %esi
  800b2c:	5f                   	pop    %edi
  800b2d:	5d                   	pop    %ebp
  800b2e:	c3                   	ret    

00800b2f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b2f:	55                   	push   %ebp
  800b30:	89 e5                	mov    %esp,%ebp
  800b32:	57                   	push   %edi
  800b33:	56                   	push   %esi
  800b34:	8b 45 08             	mov    0x8(%ebp),%eax
  800b37:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b3a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b3d:	39 c6                	cmp    %eax,%esi
  800b3f:	73 35                	jae    800b76 <memmove+0x47>
  800b41:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b44:	39 d0                	cmp    %edx,%eax
  800b46:	73 2e                	jae    800b76 <memmove+0x47>
		s += n;
		d += n;
  800b48:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b4b:	89 d6                	mov    %edx,%esi
  800b4d:	09 fe                	or     %edi,%esi
  800b4f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b55:	75 13                	jne    800b6a <memmove+0x3b>
  800b57:	f6 c1 03             	test   $0x3,%cl
  800b5a:	75 0e                	jne    800b6a <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b5c:	83 ef 04             	sub    $0x4,%edi
  800b5f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b62:	c1 e9 02             	shr    $0x2,%ecx
  800b65:	fd                   	std    
  800b66:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b68:	eb 09                	jmp    800b73 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b6a:	83 ef 01             	sub    $0x1,%edi
  800b6d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b70:	fd                   	std    
  800b71:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b73:	fc                   	cld    
  800b74:	eb 1d                	jmp    800b93 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b76:	89 f2                	mov    %esi,%edx
  800b78:	09 c2                	or     %eax,%edx
  800b7a:	f6 c2 03             	test   $0x3,%dl
  800b7d:	75 0f                	jne    800b8e <memmove+0x5f>
  800b7f:	f6 c1 03             	test   $0x3,%cl
  800b82:	75 0a                	jne    800b8e <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b84:	c1 e9 02             	shr    $0x2,%ecx
  800b87:	89 c7                	mov    %eax,%edi
  800b89:	fc                   	cld    
  800b8a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b8c:	eb 05                	jmp    800b93 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b8e:	89 c7                	mov    %eax,%edi
  800b90:	fc                   	cld    
  800b91:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b93:	5e                   	pop    %esi
  800b94:	5f                   	pop    %edi
  800b95:	5d                   	pop    %ebp
  800b96:	c3                   	ret    

00800b97 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b97:	55                   	push   %ebp
  800b98:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b9a:	ff 75 10             	pushl  0x10(%ebp)
  800b9d:	ff 75 0c             	pushl  0xc(%ebp)
  800ba0:	ff 75 08             	pushl  0x8(%ebp)
  800ba3:	e8 87 ff ff ff       	call   800b2f <memmove>
}
  800ba8:	c9                   	leave  
  800ba9:	c3                   	ret    

00800baa <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800baa:	55                   	push   %ebp
  800bab:	89 e5                	mov    %esp,%ebp
  800bad:	56                   	push   %esi
  800bae:	53                   	push   %ebx
  800baf:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bb5:	89 c6                	mov    %eax,%esi
  800bb7:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bba:	eb 1a                	jmp    800bd6 <memcmp+0x2c>
		if (*s1 != *s2)
  800bbc:	0f b6 08             	movzbl (%eax),%ecx
  800bbf:	0f b6 1a             	movzbl (%edx),%ebx
  800bc2:	38 d9                	cmp    %bl,%cl
  800bc4:	74 0a                	je     800bd0 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800bc6:	0f b6 c1             	movzbl %cl,%eax
  800bc9:	0f b6 db             	movzbl %bl,%ebx
  800bcc:	29 d8                	sub    %ebx,%eax
  800bce:	eb 0f                	jmp    800bdf <memcmp+0x35>
		s1++, s2++;
  800bd0:	83 c0 01             	add    $0x1,%eax
  800bd3:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bd6:	39 f0                	cmp    %esi,%eax
  800bd8:	75 e2                	jne    800bbc <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bda:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bdf:	5b                   	pop    %ebx
  800be0:	5e                   	pop    %esi
  800be1:	5d                   	pop    %ebp
  800be2:	c3                   	ret    

00800be3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800be3:	55                   	push   %ebp
  800be4:	89 e5                	mov    %esp,%ebp
  800be6:	53                   	push   %ebx
  800be7:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800bea:	89 c1                	mov    %eax,%ecx
  800bec:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800bef:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bf3:	eb 0a                	jmp    800bff <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bf5:	0f b6 10             	movzbl (%eax),%edx
  800bf8:	39 da                	cmp    %ebx,%edx
  800bfa:	74 07                	je     800c03 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bfc:	83 c0 01             	add    $0x1,%eax
  800bff:	39 c8                	cmp    %ecx,%eax
  800c01:	72 f2                	jb     800bf5 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c03:	5b                   	pop    %ebx
  800c04:	5d                   	pop    %ebp
  800c05:	c3                   	ret    

00800c06 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c06:	55                   	push   %ebp
  800c07:	89 e5                	mov    %esp,%ebp
  800c09:	57                   	push   %edi
  800c0a:	56                   	push   %esi
  800c0b:	53                   	push   %ebx
  800c0c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c0f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c12:	eb 03                	jmp    800c17 <strtol+0x11>
		s++;
  800c14:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c17:	0f b6 01             	movzbl (%ecx),%eax
  800c1a:	3c 20                	cmp    $0x20,%al
  800c1c:	74 f6                	je     800c14 <strtol+0xe>
  800c1e:	3c 09                	cmp    $0x9,%al
  800c20:	74 f2                	je     800c14 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c22:	3c 2b                	cmp    $0x2b,%al
  800c24:	75 0a                	jne    800c30 <strtol+0x2a>
		s++;
  800c26:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c29:	bf 00 00 00 00       	mov    $0x0,%edi
  800c2e:	eb 11                	jmp    800c41 <strtol+0x3b>
  800c30:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c35:	3c 2d                	cmp    $0x2d,%al
  800c37:	75 08                	jne    800c41 <strtol+0x3b>
		s++, neg = 1;
  800c39:	83 c1 01             	add    $0x1,%ecx
  800c3c:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c41:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c47:	75 15                	jne    800c5e <strtol+0x58>
  800c49:	80 39 30             	cmpb   $0x30,(%ecx)
  800c4c:	75 10                	jne    800c5e <strtol+0x58>
  800c4e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c52:	75 7c                	jne    800cd0 <strtol+0xca>
		s += 2, base = 16;
  800c54:	83 c1 02             	add    $0x2,%ecx
  800c57:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c5c:	eb 16                	jmp    800c74 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c5e:	85 db                	test   %ebx,%ebx
  800c60:	75 12                	jne    800c74 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c62:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c67:	80 39 30             	cmpb   $0x30,(%ecx)
  800c6a:	75 08                	jne    800c74 <strtol+0x6e>
		s++, base = 8;
  800c6c:	83 c1 01             	add    $0x1,%ecx
  800c6f:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c74:	b8 00 00 00 00       	mov    $0x0,%eax
  800c79:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c7c:	0f b6 11             	movzbl (%ecx),%edx
  800c7f:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c82:	89 f3                	mov    %esi,%ebx
  800c84:	80 fb 09             	cmp    $0x9,%bl
  800c87:	77 08                	ja     800c91 <strtol+0x8b>
			dig = *s - '0';
  800c89:	0f be d2             	movsbl %dl,%edx
  800c8c:	83 ea 30             	sub    $0x30,%edx
  800c8f:	eb 22                	jmp    800cb3 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c91:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c94:	89 f3                	mov    %esi,%ebx
  800c96:	80 fb 19             	cmp    $0x19,%bl
  800c99:	77 08                	ja     800ca3 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800c9b:	0f be d2             	movsbl %dl,%edx
  800c9e:	83 ea 57             	sub    $0x57,%edx
  800ca1:	eb 10                	jmp    800cb3 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ca3:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ca6:	89 f3                	mov    %esi,%ebx
  800ca8:	80 fb 19             	cmp    $0x19,%bl
  800cab:	77 16                	ja     800cc3 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800cad:	0f be d2             	movsbl %dl,%edx
  800cb0:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800cb3:	3b 55 10             	cmp    0x10(%ebp),%edx
  800cb6:	7d 0b                	jge    800cc3 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800cb8:	83 c1 01             	add    $0x1,%ecx
  800cbb:	0f af 45 10          	imul   0x10(%ebp),%eax
  800cbf:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800cc1:	eb b9                	jmp    800c7c <strtol+0x76>

	if (endptr)
  800cc3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cc7:	74 0d                	je     800cd6 <strtol+0xd0>
		*endptr = (char *) s;
  800cc9:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ccc:	89 0e                	mov    %ecx,(%esi)
  800cce:	eb 06                	jmp    800cd6 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cd0:	85 db                	test   %ebx,%ebx
  800cd2:	74 98                	je     800c6c <strtol+0x66>
  800cd4:	eb 9e                	jmp    800c74 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800cd6:	89 c2                	mov    %eax,%edx
  800cd8:	f7 da                	neg    %edx
  800cda:	85 ff                	test   %edi,%edi
  800cdc:	0f 45 c2             	cmovne %edx,%eax
}
  800cdf:	5b                   	pop    %ebx
  800ce0:	5e                   	pop    %esi
  800ce1:	5f                   	pop    %edi
  800ce2:	5d                   	pop    %ebp
  800ce3:	c3                   	ret    

00800ce4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ce4:	55                   	push   %ebp
  800ce5:	89 e5                	mov    %esp,%ebp
  800ce7:	57                   	push   %edi
  800ce8:	56                   	push   %esi
  800ce9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cea:	b8 00 00 00 00       	mov    $0x0,%eax
  800cef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf5:	89 c3                	mov    %eax,%ebx
  800cf7:	89 c7                	mov    %eax,%edi
  800cf9:	89 c6                	mov    %eax,%esi
  800cfb:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800cfd:	5b                   	pop    %ebx
  800cfe:	5e                   	pop    %esi
  800cff:	5f                   	pop    %edi
  800d00:	5d                   	pop    %ebp
  800d01:	c3                   	ret    

00800d02 <sys_cgetc>:

int
sys_cgetc(void)
{
  800d02:	55                   	push   %ebp
  800d03:	89 e5                	mov    %esp,%ebp
  800d05:	57                   	push   %edi
  800d06:	56                   	push   %esi
  800d07:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d08:	ba 00 00 00 00       	mov    $0x0,%edx
  800d0d:	b8 01 00 00 00       	mov    $0x1,%eax
  800d12:	89 d1                	mov    %edx,%ecx
  800d14:	89 d3                	mov    %edx,%ebx
  800d16:	89 d7                	mov    %edx,%edi
  800d18:	89 d6                	mov    %edx,%esi
  800d1a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d1c:	5b                   	pop    %ebx
  800d1d:	5e                   	pop    %esi
  800d1e:	5f                   	pop    %edi
  800d1f:	5d                   	pop    %ebp
  800d20:	c3                   	ret    

00800d21 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
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
  800d2a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d2f:	b8 03 00 00 00       	mov    $0x3,%eax
  800d34:	8b 55 08             	mov    0x8(%ebp),%edx
  800d37:	89 cb                	mov    %ecx,%ebx
  800d39:	89 cf                	mov    %ecx,%edi
  800d3b:	89 ce                	mov    %ecx,%esi
  800d3d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d3f:	85 c0                	test   %eax,%eax
  800d41:	7e 17                	jle    800d5a <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d43:	83 ec 0c             	sub    $0xc,%esp
  800d46:	50                   	push   %eax
  800d47:	6a 03                	push   $0x3
  800d49:	68 7f 27 80 00       	push   $0x80277f
  800d4e:	6a 23                	push   $0x23
  800d50:	68 9c 27 80 00       	push   $0x80279c
  800d55:	e8 3e f5 ff ff       	call   800298 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d5a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d5d:	5b                   	pop    %ebx
  800d5e:	5e                   	pop    %esi
  800d5f:	5f                   	pop    %edi
  800d60:	5d                   	pop    %ebp
  800d61:	c3                   	ret    

00800d62 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d62:	55                   	push   %ebp
  800d63:	89 e5                	mov    %esp,%ebp
  800d65:	57                   	push   %edi
  800d66:	56                   	push   %esi
  800d67:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d68:	ba 00 00 00 00       	mov    $0x0,%edx
  800d6d:	b8 02 00 00 00       	mov    $0x2,%eax
  800d72:	89 d1                	mov    %edx,%ecx
  800d74:	89 d3                	mov    %edx,%ebx
  800d76:	89 d7                	mov    %edx,%edi
  800d78:	89 d6                	mov    %edx,%esi
  800d7a:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d7c:	5b                   	pop    %ebx
  800d7d:	5e                   	pop    %esi
  800d7e:	5f                   	pop    %edi
  800d7f:	5d                   	pop    %ebp
  800d80:	c3                   	ret    

00800d81 <sys_yield>:

void
sys_yield(void)
{
  800d81:	55                   	push   %ebp
  800d82:	89 e5                	mov    %esp,%ebp
  800d84:	57                   	push   %edi
  800d85:	56                   	push   %esi
  800d86:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d87:	ba 00 00 00 00       	mov    $0x0,%edx
  800d8c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d91:	89 d1                	mov    %edx,%ecx
  800d93:	89 d3                	mov    %edx,%ebx
  800d95:	89 d7                	mov    %edx,%edi
  800d97:	89 d6                	mov    %edx,%esi
  800d99:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d9b:	5b                   	pop    %ebx
  800d9c:	5e                   	pop    %esi
  800d9d:	5f                   	pop    %edi
  800d9e:	5d                   	pop    %ebp
  800d9f:	c3                   	ret    

00800da0 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800da9:	be 00 00 00 00       	mov    $0x0,%esi
  800dae:	b8 04 00 00 00       	mov    $0x4,%eax
  800db3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db6:	8b 55 08             	mov    0x8(%ebp),%edx
  800db9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dbc:	89 f7                	mov    %esi,%edi
  800dbe:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dc0:	85 c0                	test   %eax,%eax
  800dc2:	7e 17                	jle    800ddb <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc4:	83 ec 0c             	sub    $0xc,%esp
  800dc7:	50                   	push   %eax
  800dc8:	6a 04                	push   $0x4
  800dca:	68 7f 27 80 00       	push   $0x80277f
  800dcf:	6a 23                	push   $0x23
  800dd1:	68 9c 27 80 00       	push   $0x80279c
  800dd6:	e8 bd f4 ff ff       	call   800298 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ddb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dde:	5b                   	pop    %ebx
  800ddf:	5e                   	pop    %esi
  800de0:	5f                   	pop    %edi
  800de1:	5d                   	pop    %ebp
  800de2:	c3                   	ret    

00800de3 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800de3:	55                   	push   %ebp
  800de4:	89 e5                	mov    %esp,%ebp
  800de6:	57                   	push   %edi
  800de7:	56                   	push   %esi
  800de8:	53                   	push   %ebx
  800de9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dec:	b8 05 00 00 00       	mov    $0x5,%eax
  800df1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df4:	8b 55 08             	mov    0x8(%ebp),%edx
  800df7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dfa:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dfd:	8b 75 18             	mov    0x18(%ebp),%esi
  800e00:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e02:	85 c0                	test   %eax,%eax
  800e04:	7e 17                	jle    800e1d <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e06:	83 ec 0c             	sub    $0xc,%esp
  800e09:	50                   	push   %eax
  800e0a:	6a 05                	push   $0x5
  800e0c:	68 7f 27 80 00       	push   $0x80277f
  800e11:	6a 23                	push   $0x23
  800e13:	68 9c 27 80 00       	push   $0x80279c
  800e18:	e8 7b f4 ff ff       	call   800298 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e1d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e20:	5b                   	pop    %ebx
  800e21:	5e                   	pop    %esi
  800e22:	5f                   	pop    %edi
  800e23:	5d                   	pop    %ebp
  800e24:	c3                   	ret    

00800e25 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e25:	55                   	push   %ebp
  800e26:	89 e5                	mov    %esp,%ebp
  800e28:	57                   	push   %edi
  800e29:	56                   	push   %esi
  800e2a:	53                   	push   %ebx
  800e2b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e33:	b8 06 00 00 00       	mov    $0x6,%eax
  800e38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3e:	89 df                	mov    %ebx,%edi
  800e40:	89 de                	mov    %ebx,%esi
  800e42:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e44:	85 c0                	test   %eax,%eax
  800e46:	7e 17                	jle    800e5f <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e48:	83 ec 0c             	sub    $0xc,%esp
  800e4b:	50                   	push   %eax
  800e4c:	6a 06                	push   $0x6
  800e4e:	68 7f 27 80 00       	push   $0x80277f
  800e53:	6a 23                	push   $0x23
  800e55:	68 9c 27 80 00       	push   $0x80279c
  800e5a:	e8 39 f4 ff ff       	call   800298 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e62:	5b                   	pop    %ebx
  800e63:	5e                   	pop    %esi
  800e64:	5f                   	pop    %edi
  800e65:	5d                   	pop    %ebp
  800e66:	c3                   	ret    

00800e67 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e67:	55                   	push   %ebp
  800e68:	89 e5                	mov    %esp,%ebp
  800e6a:	57                   	push   %edi
  800e6b:	56                   	push   %esi
  800e6c:	53                   	push   %ebx
  800e6d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e70:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e75:	b8 08 00 00 00       	mov    $0x8,%eax
  800e7a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e7d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e80:	89 df                	mov    %ebx,%edi
  800e82:	89 de                	mov    %ebx,%esi
  800e84:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e86:	85 c0                	test   %eax,%eax
  800e88:	7e 17                	jle    800ea1 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e8a:	83 ec 0c             	sub    $0xc,%esp
  800e8d:	50                   	push   %eax
  800e8e:	6a 08                	push   $0x8
  800e90:	68 7f 27 80 00       	push   $0x80277f
  800e95:	6a 23                	push   $0x23
  800e97:	68 9c 27 80 00       	push   $0x80279c
  800e9c:	e8 f7 f3 ff ff       	call   800298 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ea1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ea4:	5b                   	pop    %ebx
  800ea5:	5e                   	pop    %esi
  800ea6:	5f                   	pop    %edi
  800ea7:	5d                   	pop    %ebp
  800ea8:	c3                   	ret    

00800ea9 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ea9:	55                   	push   %ebp
  800eaa:	89 e5                	mov    %esp,%ebp
  800eac:	57                   	push   %edi
  800ead:	56                   	push   %esi
  800eae:	53                   	push   %ebx
  800eaf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eb2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eb7:	b8 09 00 00 00       	mov    $0x9,%eax
  800ebc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ebf:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec2:	89 df                	mov    %ebx,%edi
  800ec4:	89 de                	mov    %ebx,%esi
  800ec6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ec8:	85 c0                	test   %eax,%eax
  800eca:	7e 17                	jle    800ee3 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ecc:	83 ec 0c             	sub    $0xc,%esp
  800ecf:	50                   	push   %eax
  800ed0:	6a 09                	push   $0x9
  800ed2:	68 7f 27 80 00       	push   $0x80277f
  800ed7:	6a 23                	push   $0x23
  800ed9:	68 9c 27 80 00       	push   $0x80279c
  800ede:	e8 b5 f3 ff ff       	call   800298 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ee3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ee6:	5b                   	pop    %ebx
  800ee7:	5e                   	pop    %esi
  800ee8:	5f                   	pop    %edi
  800ee9:	5d                   	pop    %ebp
  800eea:	c3                   	ret    

00800eeb <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800eeb:	55                   	push   %ebp
  800eec:	89 e5                	mov    %esp,%ebp
  800eee:	57                   	push   %edi
  800eef:	56                   	push   %esi
  800ef0:	53                   	push   %ebx
  800ef1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ef4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ef9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800efe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f01:	8b 55 08             	mov    0x8(%ebp),%edx
  800f04:	89 df                	mov    %ebx,%edi
  800f06:	89 de                	mov    %ebx,%esi
  800f08:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f0a:	85 c0                	test   %eax,%eax
  800f0c:	7e 17                	jle    800f25 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f0e:	83 ec 0c             	sub    $0xc,%esp
  800f11:	50                   	push   %eax
  800f12:	6a 0a                	push   $0xa
  800f14:	68 7f 27 80 00       	push   $0x80277f
  800f19:	6a 23                	push   $0x23
  800f1b:	68 9c 27 80 00       	push   $0x80279c
  800f20:	e8 73 f3 ff ff       	call   800298 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f25:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f28:	5b                   	pop    %ebx
  800f29:	5e                   	pop    %esi
  800f2a:	5f                   	pop    %edi
  800f2b:	5d                   	pop    %ebp
  800f2c:	c3                   	ret    

00800f2d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f2d:	55                   	push   %ebp
  800f2e:	89 e5                	mov    %esp,%ebp
  800f30:	57                   	push   %edi
  800f31:	56                   	push   %esi
  800f32:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f33:	be 00 00 00 00       	mov    $0x0,%esi
  800f38:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f40:	8b 55 08             	mov    0x8(%ebp),%edx
  800f43:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f46:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f49:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f4b:	5b                   	pop    %ebx
  800f4c:	5e                   	pop    %esi
  800f4d:	5f                   	pop    %edi
  800f4e:	5d                   	pop    %ebp
  800f4f:	c3                   	ret    

00800f50 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f50:	55                   	push   %ebp
  800f51:	89 e5                	mov    %esp,%ebp
  800f53:	57                   	push   %edi
  800f54:	56                   	push   %esi
  800f55:	53                   	push   %ebx
  800f56:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f59:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f5e:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f63:	8b 55 08             	mov    0x8(%ebp),%edx
  800f66:	89 cb                	mov    %ecx,%ebx
  800f68:	89 cf                	mov    %ecx,%edi
  800f6a:	89 ce                	mov    %ecx,%esi
  800f6c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f6e:	85 c0                	test   %eax,%eax
  800f70:	7e 17                	jle    800f89 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f72:	83 ec 0c             	sub    $0xc,%esp
  800f75:	50                   	push   %eax
  800f76:	6a 0d                	push   $0xd
  800f78:	68 7f 27 80 00       	push   $0x80277f
  800f7d:	6a 23                	push   $0x23
  800f7f:	68 9c 27 80 00       	push   $0x80279c
  800f84:	e8 0f f3 ff ff       	call   800298 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f89:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f8c:	5b                   	pop    %ebx
  800f8d:	5e                   	pop    %esi
  800f8e:	5f                   	pop    %edi
  800f8f:	5d                   	pop    %ebp
  800f90:	c3                   	ret    

00800f91 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f91:	55                   	push   %ebp
  800f92:	89 e5                	mov    %esp,%ebp
  800f94:	53                   	push   %ebx
  800f95:	83 ec 04             	sub    $0x4,%esp
  800f98:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f9b:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & 
  800f9d:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800fa1:	0f 84 48 01 00 00    	je     8010ef <pgfault+0x15e>
  800fa7:	89 d8                	mov    %ebx,%eax
  800fa9:	c1 e8 16             	shr    $0x16,%eax
  800fac:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fb3:	a8 01                	test   $0x1,%al
  800fb5:	0f 84 5f 01 00 00    	je     80111a <pgfault+0x189>
  800fbb:	89 d8                	mov    %ebx,%eax
  800fbd:	c1 e8 0c             	shr    $0xc,%eax
  800fc0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fc7:	f6 c2 01             	test   $0x1,%dl
  800fca:	0f 84 4a 01 00 00    	je     80111a <pgfault+0x189>
				PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW))) {
  800fd0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & 
  800fd7:	f6 c4 08             	test   $0x8,%ah
  800fda:	75 79                	jne    801055 <pgfault+0xc4>
  800fdc:	e9 39 01 00 00       	jmp    80111a <pgfault+0x189>
				PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW))) {
		cprintf("Fault address = %08x, envid = %08x\n", addr, thisenv->env_id);
		if (!(err & FEC_WR)) cprintf("Not write\n");
		if (!(uvpd[PDX(addr)] & PTE_P)) cprintf("PDE not present\n");
  800fe1:	89 d8                	mov    %ebx,%eax
  800fe3:	c1 e8 16             	shr    $0x16,%eax
  800fe6:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fed:	a8 01                	test   $0x1,%al
  800fef:	75 10                	jne    801001 <pgfault+0x70>
  800ff1:	83 ec 0c             	sub    $0xc,%esp
  800ff4:	68 aa 27 80 00       	push   $0x8027aa
  800ff9:	e8 73 f3 ff ff       	call   800371 <cprintf>
  800ffe:	83 c4 10             	add    $0x10,%esp
		if (!(uvpt[PTX(addr)] & PTE_P)) cprintf("PTE not present\n");
  801001:	c1 eb 0c             	shr    $0xc,%ebx
  801004:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  80100a:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801011:	a8 01                	test   $0x1,%al
  801013:	75 10                	jne    801025 <pgfault+0x94>
  801015:	83 ec 0c             	sub    $0xc,%esp
  801018:	68 bb 27 80 00       	push   $0x8027bb
  80101d:	e8 4f f3 ff ff       	call   800371 <cprintf>
  801022:	83 c4 10             	add    $0x10,%esp
		if (!(uvpt[PTX(addr)] & PTE_COW)) cprintf("Not copy-on-write\n");
  801025:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  80102c:	f6 c4 08             	test   $0x8,%ah
  80102f:	75 10                	jne    801041 <pgfault+0xb0>
  801031:	83 ec 0c             	sub    $0xc,%esp
  801034:	68 cc 27 80 00       	push   $0x8027cc
  801039:	e8 33 f3 ff ff       	call   800371 <cprintf>
  80103e:	83 c4 10             	add    $0x10,%esp
		panic("User page fault");
  801041:	83 ec 04             	sub    $0x4,%esp
  801044:	68 df 27 80 00       	push   $0x8027df
  801049:	6a 23                	push   $0x23
  80104b:	68 ef 27 80 00       	push   $0x8027ef
  801050:	e8 43 f2 ff ff       	call   800298 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// 0 refers to curenv
	if ((r = sys_page_alloc(0, (void*)PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  801055:	83 ec 04             	sub    $0x4,%esp
  801058:	6a 07                	push   $0x7
  80105a:	68 00 f0 7f 00       	push   $0x7ff000
  80105f:	6a 00                	push   $0x0
  801061:	e8 3a fd ff ff       	call   800da0 <sys_page_alloc>
  801066:	83 c4 10             	add    $0x10,%esp
  801069:	85 c0                	test   %eax,%eax
  80106b:	79 12                	jns    80107f <pgfault+0xee>
		panic("sys_page_alloc failed: %e", r);
  80106d:	50                   	push   %eax
  80106e:	68 fa 27 80 00       	push   $0x8027fa
  801073:	6a 2f                	push   $0x2f
  801075:	68 ef 27 80 00       	push   $0x8027ef
  80107a:	e8 19 f2 ff ff       	call   800298 <_panic>
	memcpy((void*)PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  80107f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  801085:	83 ec 04             	sub    $0x4,%esp
  801088:	68 00 10 00 00       	push   $0x1000
  80108d:	53                   	push   %ebx
  80108e:	68 00 f0 7f 00       	push   $0x7ff000
  801093:	e8 ff fa ff ff       	call   800b97 <memcpy>
	if ((r = sys_page_map(0, (void*)PFTEMP, 0, (void*)ROUNDDOWN(addr, PGSIZE), 
  801098:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  80109f:	53                   	push   %ebx
  8010a0:	6a 00                	push   $0x0
  8010a2:	68 00 f0 7f 00       	push   $0x7ff000
  8010a7:	6a 00                	push   $0x0
  8010a9:	e8 35 fd ff ff       	call   800de3 <sys_page_map>
  8010ae:	83 c4 20             	add    $0x20,%esp
  8010b1:	85 c0                	test   %eax,%eax
  8010b3:	79 12                	jns    8010c7 <pgfault+0x136>
					PTE_P | PTE_U | PTE_W)) < 0)
		panic("sys_page_map failed: %e", r);
  8010b5:	50                   	push   %eax
  8010b6:	68 14 28 80 00       	push   $0x802814
  8010bb:	6a 33                	push   $0x33
  8010bd:	68 ef 27 80 00       	push   $0x8027ef
  8010c2:	e8 d1 f1 ff ff       	call   800298 <_panic>
	if ((r = sys_page_unmap(0, (void*)PFTEMP)) < 0)
  8010c7:	83 ec 08             	sub    $0x8,%esp
  8010ca:	68 00 f0 7f 00       	push   $0x7ff000
  8010cf:	6a 00                	push   $0x0
  8010d1:	e8 4f fd ff ff       	call   800e25 <sys_page_unmap>
  8010d6:	83 c4 10             	add    $0x10,%esp
  8010d9:	85 c0                	test   %eax,%eax
  8010db:	79 5c                	jns    801139 <pgfault+0x1a8>
		panic("sys_page_unmap failed: %e", r);
  8010dd:	50                   	push   %eax
  8010de:	68 2c 28 80 00       	push   $0x80282c
  8010e3:	6a 35                	push   $0x35
  8010e5:	68 ef 27 80 00       	push   $0x8027ef
  8010ea:	e8 a9 f1 ff ff       	call   800298 <_panic>
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & 
				PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW))) {
		cprintf("Fault address = %08x, envid = %08x\n", addr, thisenv->env_id);
  8010ef:	a1 04 40 80 00       	mov    0x804004,%eax
  8010f4:	8b 40 48             	mov    0x48(%eax),%eax
  8010f7:	83 ec 04             	sub    $0x4,%esp
  8010fa:	50                   	push   %eax
  8010fb:	53                   	push   %ebx
  8010fc:	68 68 28 80 00       	push   $0x802868
  801101:	e8 6b f2 ff ff       	call   800371 <cprintf>
		if (!(err & FEC_WR)) cprintf("Not write\n");
  801106:	c7 04 24 46 28 80 00 	movl   $0x802846,(%esp)
  80110d:	e8 5f f2 ff ff       	call   800371 <cprintf>
  801112:	83 c4 10             	add    $0x10,%esp
  801115:	e9 c7 fe ff ff       	jmp    800fe1 <pgfault+0x50>
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & 
				PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW))) {
		cprintf("Fault address = %08x, envid = %08x\n", addr, thisenv->env_id);
  80111a:	a1 04 40 80 00       	mov    0x804004,%eax
  80111f:	8b 40 48             	mov    0x48(%eax),%eax
  801122:	83 ec 04             	sub    $0x4,%esp
  801125:	50                   	push   %eax
  801126:	53                   	push   %ebx
  801127:	68 68 28 80 00       	push   $0x802868
  80112c:	e8 40 f2 ff ff       	call   800371 <cprintf>
  801131:	83 c4 10             	add    $0x10,%esp
  801134:	e9 a8 fe ff ff       	jmp    800fe1 <pgfault+0x50>
		panic("sys_page_map failed: %e", r);
	if ((r = sys_page_unmap(0, (void*)PFTEMP)) < 0)
		panic("sys_page_unmap failed: %e", r);

	// panic("pgfault not implemented");
}
  801139:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80113c:	c9                   	leave  
  80113d:	c3                   	ret    

0080113e <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80113e:	55                   	push   %ebp
  80113f:	89 e5                	mov    %esp,%ebp
  801141:	57                   	push   %edi
  801142:	56                   	push   %esi
  801143:	53                   	push   %ebx
  801144:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	int ret;
	set_pgfault_handler(pgfault);
  801147:	68 91 0f 80 00       	push   $0x800f91
  80114c:	e8 08 0e 00 00       	call   801f59 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801151:	b8 07 00 00 00       	mov    $0x7,%eax
  801156:	cd 30                	int    $0x30
  801158:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80115b:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	envid_t envid = sys_exofork();

	if (envid < 0) return envid;
  80115e:	83 c4 10             	add    $0x10,%esp
  801161:	85 c0                	test   %eax,%eax
  801163:	0f 88 0d 01 00 00    	js     801276 <fork+0x138>
  801169:	bb 00 00 00 00       	mov    $0x0,%ebx
  80116e:	be 00 00 00 00       	mov    $0x0,%esi
	else if (envid == 0) {
  801173:	85 c0                	test   %eax,%eax
  801175:	75 2f                	jne    8011a6 <fork+0x68>
		// Child returns
		thisenv = &envs[ENVX(sys_getenvid())];
  801177:	e8 e6 fb ff ff       	call   800d62 <sys_getenvid>
  80117c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801181:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801184:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801189:	a3 04 40 80 00       	mov    %eax,0x804004
		// set_pgfault_handler(pgfault);
		return 0;
  80118e:	b8 00 00 00 00       	mov    $0x0,%eax
  801193:	e9 e1 00 00 00       	jmp    801279 <fork+0x13b>
  801198:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
	}
	else {
		uint32_t pn;
		for (pn = 0; pn * PGSIZE < UTOP; pn++){
			// cprintf("virtual page %08x\n", pn * PGSIZE);
			if (pn * PGSIZE == UXSTACKTOP - PGSIZE) 
  80119e:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  8011a4:	74 77                	je     80121d <fork+0xdf>
{
	int r;

	// LAB 4: Your code here.
	int perm = PTE_P | PTE_U;
	pde_t pde = uvpd[pn / NPTENTRIES];
  8011a6:	89 f0                	mov    %esi,%eax
  8011a8:	c1 e8 0a             	shr    $0xa,%eax
  8011ab:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
	if (!(pde & PTE_P)) return 0;
  8011b2:	a8 01                	test   $0x1,%al
  8011b4:	74 0b                	je     8011c1 <fork+0x83>
	pte_t pte = uvpt[pn];
  8011b6:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	if (!(pte & PTE_P)) return 0;
  8011bd:	a8 01                	test   $0x1,%al
  8011bf:	75 08                	jne    8011c9 <fork+0x8b>
  8011c1:	8d 5e 01             	lea    0x1(%esi),%ebx
  8011c4:	c1 e3 0c             	shl    $0xc,%ebx
  8011c7:	eb 56                	jmp    80121f <fork+0xe1>
	// cprintf("virtual page %08x\n", pn * PGSIZE);

	if ((pte & PTE_W) || (pte & PTE_COW)) perm |= PTE_COW;
  8011c9:	25 02 08 00 00       	and    $0x802,%eax
  8011ce:	83 f8 01             	cmp    $0x1,%eax
  8011d1:	19 ff                	sbb    %edi,%edi
  8011d3:	81 e7 00 f8 ff ff    	and    $0xfffff800,%edi
  8011d9:	81 c7 05 08 00 00    	add    $0x805,%edi

	if ((r = sys_page_map(thisenv->env_id, (void*)(pn * PGSIZE), envid, 
  8011df:	a1 04 40 80 00       	mov    0x804004,%eax
  8011e4:	8b 40 48             	mov    0x48(%eax),%eax
  8011e7:	83 ec 0c             	sub    $0xc,%esp
  8011ea:	57                   	push   %edi
  8011eb:	53                   	push   %ebx
  8011ec:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011ef:	53                   	push   %ebx
  8011f0:	50                   	push   %eax
  8011f1:	e8 ed fb ff ff       	call   800de3 <sys_page_map>
  8011f6:	83 c4 20             	add    $0x20,%esp
  8011f9:	85 c0                	test   %eax,%eax
  8011fb:	78 7c                	js     801279 <fork+0x13b>
				(void*)(pn * PGSIZE), perm)) < 0) 
		return r;
	r = sys_page_map(envid, (void*)(pn * PGSIZE), thisenv->env_id, 
  8011fd:	a1 04 40 80 00       	mov    0x804004,%eax
  801202:	8b 40 48             	mov    0x48(%eax),%eax
  801205:	83 ec 0c             	sub    $0xc,%esp
  801208:	57                   	push   %edi
  801209:	53                   	push   %ebx
  80120a:	50                   	push   %eax
  80120b:	53                   	push   %ebx
  80120c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80120f:	e8 cf fb ff ff       	call   800de3 <sys_page_map>
		uint32_t pn;
		for (pn = 0; pn * PGSIZE < UTOP; pn++){
			// cprintf("virtual page %08x\n", pn * PGSIZE);
			if (pn * PGSIZE == UXSTACKTOP - PGSIZE) 
				continue;
			if ((ret = duppage(envid, pn)) < 0)
  801214:	83 c4 20             	add    $0x20,%esp
  801217:	85 c0                	test   %eax,%eax
  801219:	79 a6                	jns    8011c1 <fork+0x83>
  80121b:	eb 5c                	jmp    801279 <fork+0x13b>
  80121d:	89 c3                	mov    %eax,%ebx
		// set_pgfault_handler(pgfault);
		return 0;
	}
	else {
		uint32_t pn;
		for (pn = 0; pn * PGSIZE < UTOP; pn++){
  80121f:	83 c6 01             	add    $0x1,%esi
  801222:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
  801228:	0f 86 6a ff ff ff    	jbe    801198 <fork+0x5a>
				return ret;
		}
		// cprintf("Fork: duppage finished\n");

		// Should be done by parent
		if ((ret = sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P |
  80122e:	83 ec 04             	sub    $0x4,%esp
  801231:	6a 07                	push   $0x7
  801233:	68 00 f0 bf ee       	push   $0xeebff000
  801238:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80123b:	57                   	push   %edi
  80123c:	e8 5f fb ff ff       	call   800da0 <sys_page_alloc>
  801241:	83 c4 10             	add    $0x10,%esp
  801244:	85 c0                	test   %eax,%eax
  801246:	78 31                	js     801279 <fork+0x13b>
						PTE_U | PTE_W)) < 0)
			return ret;
		if ((ret = sys_env_set_pgfault_upcall(envid, 
						thisenv->env_pgfault_upcall)) < 0)
  801248:	a1 04 40 80 00       	mov    0x804004,%eax

		// Should be done by parent
		if ((ret = sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P |
						PTE_U | PTE_W)) < 0)
			return ret;
		if ((ret = sys_env_set_pgfault_upcall(envid, 
  80124d:	8b 40 64             	mov    0x64(%eax),%eax
  801250:	83 ec 08             	sub    $0x8,%esp
  801253:	50                   	push   %eax
  801254:	57                   	push   %edi
  801255:	e8 91 fc ff ff       	call   800eeb <sys_env_set_pgfault_upcall>
  80125a:	83 c4 10             	add    $0x10,%esp
  80125d:	85 c0                	test   %eax,%eax
  80125f:	78 18                	js     801279 <fork+0x13b>
						thisenv->env_pgfault_upcall)) < 0)
			return ret;

		if ((ret = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  801261:	83 ec 08             	sub    $0x8,%esp
  801264:	6a 02                	push   $0x2
  801266:	57                   	push   %edi
  801267:	e8 fb fb ff ff       	call   800e67 <sys_env_set_status>
  80126c:	83 c4 10             	add    $0x10,%esp
			return ret;
		return envid;
  80126f:	85 c0                	test   %eax,%eax
  801271:	0f 49 c7             	cmovns %edi,%eax
  801274:	eb 03                	jmp    801279 <fork+0x13b>
	int ret;
	set_pgfault_handler(pgfault);

	envid_t envid = sys_exofork();

	if (envid < 0) return envid;
  801276:	8b 45 e0             	mov    -0x20(%ebp),%eax
			return ret;
		return envid;
	}

	panic("fork not implemented");
}
  801279:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80127c:	5b                   	pop    %ebx
  80127d:	5e                   	pop    %esi
  80127e:	5f                   	pop    %edi
  80127f:	5d                   	pop    %ebp
  801280:	c3                   	ret    

00801281 <sfork>:

// Challenge!
int
sfork(void)
{
  801281:	55                   	push   %ebp
  801282:	89 e5                	mov    %esp,%ebp
  801284:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801287:	68 51 28 80 00       	push   $0x802851
  80128c:	68 9f 00 00 00       	push   $0x9f
  801291:	68 ef 27 80 00       	push   $0x8027ef
  801296:	e8 fd ef ff ff       	call   800298 <_panic>

0080129b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80129b:	55                   	push   %ebp
  80129c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80129e:	8b 45 08             	mov    0x8(%ebp),%eax
  8012a1:	05 00 00 00 30       	add    $0x30000000,%eax
  8012a6:	c1 e8 0c             	shr    $0xc,%eax
}
  8012a9:	5d                   	pop    %ebp
  8012aa:	c3                   	ret    

008012ab <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8012ab:	55                   	push   %ebp
  8012ac:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8012ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8012b1:	05 00 00 00 30       	add    $0x30000000,%eax
  8012b6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8012bb:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8012c0:	5d                   	pop    %ebp
  8012c1:	c3                   	ret    

008012c2 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8012c2:	55                   	push   %ebp
  8012c3:	89 e5                	mov    %esp,%ebp
  8012c5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012c8:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8012cd:	89 c2                	mov    %eax,%edx
  8012cf:	c1 ea 16             	shr    $0x16,%edx
  8012d2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012d9:	f6 c2 01             	test   $0x1,%dl
  8012dc:	74 11                	je     8012ef <fd_alloc+0x2d>
  8012de:	89 c2                	mov    %eax,%edx
  8012e0:	c1 ea 0c             	shr    $0xc,%edx
  8012e3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012ea:	f6 c2 01             	test   $0x1,%dl
  8012ed:	75 09                	jne    8012f8 <fd_alloc+0x36>
			*fd_store = fd;
  8012ef:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8012f6:	eb 17                	jmp    80130f <fd_alloc+0x4d>
  8012f8:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8012fd:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801302:	75 c9                	jne    8012cd <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801304:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80130a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80130f:	5d                   	pop    %ebp
  801310:	c3                   	ret    

00801311 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801311:	55                   	push   %ebp
  801312:	89 e5                	mov    %esp,%ebp
  801314:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801317:	83 f8 1f             	cmp    $0x1f,%eax
  80131a:	77 36                	ja     801352 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80131c:	c1 e0 0c             	shl    $0xc,%eax
  80131f:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801324:	89 c2                	mov    %eax,%edx
  801326:	c1 ea 16             	shr    $0x16,%edx
  801329:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801330:	f6 c2 01             	test   $0x1,%dl
  801333:	74 24                	je     801359 <fd_lookup+0x48>
  801335:	89 c2                	mov    %eax,%edx
  801337:	c1 ea 0c             	shr    $0xc,%edx
  80133a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801341:	f6 c2 01             	test   $0x1,%dl
  801344:	74 1a                	je     801360 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801346:	8b 55 0c             	mov    0xc(%ebp),%edx
  801349:	89 02                	mov    %eax,(%edx)
	return 0;
  80134b:	b8 00 00 00 00       	mov    $0x0,%eax
  801350:	eb 13                	jmp    801365 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801352:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801357:	eb 0c                	jmp    801365 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801359:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80135e:	eb 05                	jmp    801365 <fd_lookup+0x54>
  801360:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801365:	5d                   	pop    %ebp
  801366:	c3                   	ret    

00801367 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801367:	55                   	push   %ebp
  801368:	89 e5                	mov    %esp,%ebp
  80136a:	83 ec 08             	sub    $0x8,%esp
  80136d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801370:	ba 0c 29 80 00       	mov    $0x80290c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801375:	eb 13                	jmp    80138a <dev_lookup+0x23>
  801377:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80137a:	39 08                	cmp    %ecx,(%eax)
  80137c:	75 0c                	jne    80138a <dev_lookup+0x23>
			*dev = devtab[i];
  80137e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801381:	89 01                	mov    %eax,(%ecx)
			return 0;
  801383:	b8 00 00 00 00       	mov    $0x0,%eax
  801388:	eb 2e                	jmp    8013b8 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80138a:	8b 02                	mov    (%edx),%eax
  80138c:	85 c0                	test   %eax,%eax
  80138e:	75 e7                	jne    801377 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801390:	a1 04 40 80 00       	mov    0x804004,%eax
  801395:	8b 40 48             	mov    0x48(%eax),%eax
  801398:	83 ec 04             	sub    $0x4,%esp
  80139b:	51                   	push   %ecx
  80139c:	50                   	push   %eax
  80139d:	68 8c 28 80 00       	push   $0x80288c
  8013a2:	e8 ca ef ff ff       	call   800371 <cprintf>
	*dev = 0;
  8013a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013aa:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8013b0:	83 c4 10             	add    $0x10,%esp
  8013b3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013b8:	c9                   	leave  
  8013b9:	c3                   	ret    

008013ba <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8013ba:	55                   	push   %ebp
  8013bb:	89 e5                	mov    %esp,%ebp
  8013bd:	56                   	push   %esi
  8013be:	53                   	push   %ebx
  8013bf:	83 ec 10             	sub    $0x10,%esp
  8013c2:	8b 75 08             	mov    0x8(%ebp),%esi
  8013c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013cb:	50                   	push   %eax
  8013cc:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8013d2:	c1 e8 0c             	shr    $0xc,%eax
  8013d5:	50                   	push   %eax
  8013d6:	e8 36 ff ff ff       	call   801311 <fd_lookup>
  8013db:	83 c4 08             	add    $0x8,%esp
  8013de:	85 c0                	test   %eax,%eax
  8013e0:	78 05                	js     8013e7 <fd_close+0x2d>
	    || fd != fd2)
  8013e2:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8013e5:	74 0c                	je     8013f3 <fd_close+0x39>
		return (must_exist ? r : 0);
  8013e7:	84 db                	test   %bl,%bl
  8013e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8013ee:	0f 44 c2             	cmove  %edx,%eax
  8013f1:	eb 41                	jmp    801434 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013f3:	83 ec 08             	sub    $0x8,%esp
  8013f6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013f9:	50                   	push   %eax
  8013fa:	ff 36                	pushl  (%esi)
  8013fc:	e8 66 ff ff ff       	call   801367 <dev_lookup>
  801401:	89 c3                	mov    %eax,%ebx
  801403:	83 c4 10             	add    $0x10,%esp
  801406:	85 c0                	test   %eax,%eax
  801408:	78 1a                	js     801424 <fd_close+0x6a>
		if (dev->dev_close)
  80140a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80140d:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801410:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801415:	85 c0                	test   %eax,%eax
  801417:	74 0b                	je     801424 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801419:	83 ec 0c             	sub    $0xc,%esp
  80141c:	56                   	push   %esi
  80141d:	ff d0                	call   *%eax
  80141f:	89 c3                	mov    %eax,%ebx
  801421:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801424:	83 ec 08             	sub    $0x8,%esp
  801427:	56                   	push   %esi
  801428:	6a 00                	push   $0x0
  80142a:	e8 f6 f9 ff ff       	call   800e25 <sys_page_unmap>
	return r;
  80142f:	83 c4 10             	add    $0x10,%esp
  801432:	89 d8                	mov    %ebx,%eax
}
  801434:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801437:	5b                   	pop    %ebx
  801438:	5e                   	pop    %esi
  801439:	5d                   	pop    %ebp
  80143a:	c3                   	ret    

0080143b <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80143b:	55                   	push   %ebp
  80143c:	89 e5                	mov    %esp,%ebp
  80143e:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801441:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801444:	50                   	push   %eax
  801445:	ff 75 08             	pushl  0x8(%ebp)
  801448:	e8 c4 fe ff ff       	call   801311 <fd_lookup>
  80144d:	83 c4 08             	add    $0x8,%esp
  801450:	85 c0                	test   %eax,%eax
  801452:	78 10                	js     801464 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801454:	83 ec 08             	sub    $0x8,%esp
  801457:	6a 01                	push   $0x1
  801459:	ff 75 f4             	pushl  -0xc(%ebp)
  80145c:	e8 59 ff ff ff       	call   8013ba <fd_close>
  801461:	83 c4 10             	add    $0x10,%esp
}
  801464:	c9                   	leave  
  801465:	c3                   	ret    

00801466 <close_all>:

void
close_all(void)
{
  801466:	55                   	push   %ebp
  801467:	89 e5                	mov    %esp,%ebp
  801469:	53                   	push   %ebx
  80146a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80146d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801472:	83 ec 0c             	sub    $0xc,%esp
  801475:	53                   	push   %ebx
  801476:	e8 c0 ff ff ff       	call   80143b <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80147b:	83 c3 01             	add    $0x1,%ebx
  80147e:	83 c4 10             	add    $0x10,%esp
  801481:	83 fb 20             	cmp    $0x20,%ebx
  801484:	75 ec                	jne    801472 <close_all+0xc>
		close(i);
}
  801486:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801489:	c9                   	leave  
  80148a:	c3                   	ret    

0080148b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80148b:	55                   	push   %ebp
  80148c:	89 e5                	mov    %esp,%ebp
  80148e:	57                   	push   %edi
  80148f:	56                   	push   %esi
  801490:	53                   	push   %ebx
  801491:	83 ec 2c             	sub    $0x2c,%esp
  801494:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801497:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80149a:	50                   	push   %eax
  80149b:	ff 75 08             	pushl  0x8(%ebp)
  80149e:	e8 6e fe ff ff       	call   801311 <fd_lookup>
  8014a3:	83 c4 08             	add    $0x8,%esp
  8014a6:	85 c0                	test   %eax,%eax
  8014a8:	0f 88 c1 00 00 00    	js     80156f <dup+0xe4>
		return r;
	close(newfdnum);
  8014ae:	83 ec 0c             	sub    $0xc,%esp
  8014b1:	56                   	push   %esi
  8014b2:	e8 84 ff ff ff       	call   80143b <close>

	newfd = INDEX2FD(newfdnum);
  8014b7:	89 f3                	mov    %esi,%ebx
  8014b9:	c1 e3 0c             	shl    $0xc,%ebx
  8014bc:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8014c2:	83 c4 04             	add    $0x4,%esp
  8014c5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014c8:	e8 de fd ff ff       	call   8012ab <fd2data>
  8014cd:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8014cf:	89 1c 24             	mov    %ebx,(%esp)
  8014d2:	e8 d4 fd ff ff       	call   8012ab <fd2data>
  8014d7:	83 c4 10             	add    $0x10,%esp
  8014da:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014dd:	89 f8                	mov    %edi,%eax
  8014df:	c1 e8 16             	shr    $0x16,%eax
  8014e2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014e9:	a8 01                	test   $0x1,%al
  8014eb:	74 37                	je     801524 <dup+0x99>
  8014ed:	89 f8                	mov    %edi,%eax
  8014ef:	c1 e8 0c             	shr    $0xc,%eax
  8014f2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014f9:	f6 c2 01             	test   $0x1,%dl
  8014fc:	74 26                	je     801524 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014fe:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801505:	83 ec 0c             	sub    $0xc,%esp
  801508:	25 07 0e 00 00       	and    $0xe07,%eax
  80150d:	50                   	push   %eax
  80150e:	ff 75 d4             	pushl  -0x2c(%ebp)
  801511:	6a 00                	push   $0x0
  801513:	57                   	push   %edi
  801514:	6a 00                	push   $0x0
  801516:	e8 c8 f8 ff ff       	call   800de3 <sys_page_map>
  80151b:	89 c7                	mov    %eax,%edi
  80151d:	83 c4 20             	add    $0x20,%esp
  801520:	85 c0                	test   %eax,%eax
  801522:	78 2e                	js     801552 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801524:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801527:	89 d0                	mov    %edx,%eax
  801529:	c1 e8 0c             	shr    $0xc,%eax
  80152c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801533:	83 ec 0c             	sub    $0xc,%esp
  801536:	25 07 0e 00 00       	and    $0xe07,%eax
  80153b:	50                   	push   %eax
  80153c:	53                   	push   %ebx
  80153d:	6a 00                	push   $0x0
  80153f:	52                   	push   %edx
  801540:	6a 00                	push   $0x0
  801542:	e8 9c f8 ff ff       	call   800de3 <sys_page_map>
  801547:	89 c7                	mov    %eax,%edi
  801549:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80154c:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80154e:	85 ff                	test   %edi,%edi
  801550:	79 1d                	jns    80156f <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801552:	83 ec 08             	sub    $0x8,%esp
  801555:	53                   	push   %ebx
  801556:	6a 00                	push   $0x0
  801558:	e8 c8 f8 ff ff       	call   800e25 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80155d:	83 c4 08             	add    $0x8,%esp
  801560:	ff 75 d4             	pushl  -0x2c(%ebp)
  801563:	6a 00                	push   $0x0
  801565:	e8 bb f8 ff ff       	call   800e25 <sys_page_unmap>
	return r;
  80156a:	83 c4 10             	add    $0x10,%esp
  80156d:	89 f8                	mov    %edi,%eax
}
  80156f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801572:	5b                   	pop    %ebx
  801573:	5e                   	pop    %esi
  801574:	5f                   	pop    %edi
  801575:	5d                   	pop    %ebp
  801576:	c3                   	ret    

00801577 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801577:	55                   	push   %ebp
  801578:	89 e5                	mov    %esp,%ebp
  80157a:	53                   	push   %ebx
  80157b:	83 ec 14             	sub    $0x14,%esp
  80157e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801581:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801584:	50                   	push   %eax
  801585:	53                   	push   %ebx
  801586:	e8 86 fd ff ff       	call   801311 <fd_lookup>
  80158b:	83 c4 08             	add    $0x8,%esp
  80158e:	89 c2                	mov    %eax,%edx
  801590:	85 c0                	test   %eax,%eax
  801592:	78 6d                	js     801601 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801594:	83 ec 08             	sub    $0x8,%esp
  801597:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80159a:	50                   	push   %eax
  80159b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80159e:	ff 30                	pushl  (%eax)
  8015a0:	e8 c2 fd ff ff       	call   801367 <dev_lookup>
  8015a5:	83 c4 10             	add    $0x10,%esp
  8015a8:	85 c0                	test   %eax,%eax
  8015aa:	78 4c                	js     8015f8 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8015ac:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015af:	8b 42 08             	mov    0x8(%edx),%eax
  8015b2:	83 e0 03             	and    $0x3,%eax
  8015b5:	83 f8 01             	cmp    $0x1,%eax
  8015b8:	75 21                	jne    8015db <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015ba:	a1 04 40 80 00       	mov    0x804004,%eax
  8015bf:	8b 40 48             	mov    0x48(%eax),%eax
  8015c2:	83 ec 04             	sub    $0x4,%esp
  8015c5:	53                   	push   %ebx
  8015c6:	50                   	push   %eax
  8015c7:	68 d0 28 80 00       	push   $0x8028d0
  8015cc:	e8 a0 ed ff ff       	call   800371 <cprintf>
		return -E_INVAL;
  8015d1:	83 c4 10             	add    $0x10,%esp
  8015d4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015d9:	eb 26                	jmp    801601 <read+0x8a>
	}
	if (!dev->dev_read)
  8015db:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015de:	8b 40 08             	mov    0x8(%eax),%eax
  8015e1:	85 c0                	test   %eax,%eax
  8015e3:	74 17                	je     8015fc <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8015e5:	83 ec 04             	sub    $0x4,%esp
  8015e8:	ff 75 10             	pushl  0x10(%ebp)
  8015eb:	ff 75 0c             	pushl  0xc(%ebp)
  8015ee:	52                   	push   %edx
  8015ef:	ff d0                	call   *%eax
  8015f1:	89 c2                	mov    %eax,%edx
  8015f3:	83 c4 10             	add    $0x10,%esp
  8015f6:	eb 09                	jmp    801601 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015f8:	89 c2                	mov    %eax,%edx
  8015fa:	eb 05                	jmp    801601 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8015fc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801601:	89 d0                	mov    %edx,%eax
  801603:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801606:	c9                   	leave  
  801607:	c3                   	ret    

00801608 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801608:	55                   	push   %ebp
  801609:	89 e5                	mov    %esp,%ebp
  80160b:	57                   	push   %edi
  80160c:	56                   	push   %esi
  80160d:	53                   	push   %ebx
  80160e:	83 ec 0c             	sub    $0xc,%esp
  801611:	8b 7d 08             	mov    0x8(%ebp),%edi
  801614:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801617:	bb 00 00 00 00       	mov    $0x0,%ebx
  80161c:	eb 21                	jmp    80163f <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80161e:	83 ec 04             	sub    $0x4,%esp
  801621:	89 f0                	mov    %esi,%eax
  801623:	29 d8                	sub    %ebx,%eax
  801625:	50                   	push   %eax
  801626:	89 d8                	mov    %ebx,%eax
  801628:	03 45 0c             	add    0xc(%ebp),%eax
  80162b:	50                   	push   %eax
  80162c:	57                   	push   %edi
  80162d:	e8 45 ff ff ff       	call   801577 <read>
		if (m < 0)
  801632:	83 c4 10             	add    $0x10,%esp
  801635:	85 c0                	test   %eax,%eax
  801637:	78 10                	js     801649 <readn+0x41>
			return m;
		if (m == 0)
  801639:	85 c0                	test   %eax,%eax
  80163b:	74 0a                	je     801647 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80163d:	01 c3                	add    %eax,%ebx
  80163f:	39 f3                	cmp    %esi,%ebx
  801641:	72 db                	jb     80161e <readn+0x16>
  801643:	89 d8                	mov    %ebx,%eax
  801645:	eb 02                	jmp    801649 <readn+0x41>
  801647:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801649:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80164c:	5b                   	pop    %ebx
  80164d:	5e                   	pop    %esi
  80164e:	5f                   	pop    %edi
  80164f:	5d                   	pop    %ebp
  801650:	c3                   	ret    

00801651 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801651:	55                   	push   %ebp
  801652:	89 e5                	mov    %esp,%ebp
  801654:	53                   	push   %ebx
  801655:	83 ec 14             	sub    $0x14,%esp
  801658:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80165b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80165e:	50                   	push   %eax
  80165f:	53                   	push   %ebx
  801660:	e8 ac fc ff ff       	call   801311 <fd_lookup>
  801665:	83 c4 08             	add    $0x8,%esp
  801668:	89 c2                	mov    %eax,%edx
  80166a:	85 c0                	test   %eax,%eax
  80166c:	78 68                	js     8016d6 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80166e:	83 ec 08             	sub    $0x8,%esp
  801671:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801674:	50                   	push   %eax
  801675:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801678:	ff 30                	pushl  (%eax)
  80167a:	e8 e8 fc ff ff       	call   801367 <dev_lookup>
  80167f:	83 c4 10             	add    $0x10,%esp
  801682:	85 c0                	test   %eax,%eax
  801684:	78 47                	js     8016cd <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801686:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801689:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80168d:	75 21                	jne    8016b0 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80168f:	a1 04 40 80 00       	mov    0x804004,%eax
  801694:	8b 40 48             	mov    0x48(%eax),%eax
  801697:	83 ec 04             	sub    $0x4,%esp
  80169a:	53                   	push   %ebx
  80169b:	50                   	push   %eax
  80169c:	68 ec 28 80 00       	push   $0x8028ec
  8016a1:	e8 cb ec ff ff       	call   800371 <cprintf>
		return -E_INVAL;
  8016a6:	83 c4 10             	add    $0x10,%esp
  8016a9:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016ae:	eb 26                	jmp    8016d6 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8016b0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016b3:	8b 52 0c             	mov    0xc(%edx),%edx
  8016b6:	85 d2                	test   %edx,%edx
  8016b8:	74 17                	je     8016d1 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8016ba:	83 ec 04             	sub    $0x4,%esp
  8016bd:	ff 75 10             	pushl  0x10(%ebp)
  8016c0:	ff 75 0c             	pushl  0xc(%ebp)
  8016c3:	50                   	push   %eax
  8016c4:	ff d2                	call   *%edx
  8016c6:	89 c2                	mov    %eax,%edx
  8016c8:	83 c4 10             	add    $0x10,%esp
  8016cb:	eb 09                	jmp    8016d6 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016cd:	89 c2                	mov    %eax,%edx
  8016cf:	eb 05                	jmp    8016d6 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8016d1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8016d6:	89 d0                	mov    %edx,%eax
  8016d8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016db:	c9                   	leave  
  8016dc:	c3                   	ret    

008016dd <seek>:

int
seek(int fdnum, off_t offset)
{
  8016dd:	55                   	push   %ebp
  8016de:	89 e5                	mov    %esp,%ebp
  8016e0:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016e3:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8016e6:	50                   	push   %eax
  8016e7:	ff 75 08             	pushl  0x8(%ebp)
  8016ea:	e8 22 fc ff ff       	call   801311 <fd_lookup>
  8016ef:	83 c4 08             	add    $0x8,%esp
  8016f2:	85 c0                	test   %eax,%eax
  8016f4:	78 0e                	js     801704 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8016f6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016f9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016fc:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016ff:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801704:	c9                   	leave  
  801705:	c3                   	ret    

00801706 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801706:	55                   	push   %ebp
  801707:	89 e5                	mov    %esp,%ebp
  801709:	53                   	push   %ebx
  80170a:	83 ec 14             	sub    $0x14,%esp
  80170d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801710:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801713:	50                   	push   %eax
  801714:	53                   	push   %ebx
  801715:	e8 f7 fb ff ff       	call   801311 <fd_lookup>
  80171a:	83 c4 08             	add    $0x8,%esp
  80171d:	89 c2                	mov    %eax,%edx
  80171f:	85 c0                	test   %eax,%eax
  801721:	78 65                	js     801788 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801723:	83 ec 08             	sub    $0x8,%esp
  801726:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801729:	50                   	push   %eax
  80172a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80172d:	ff 30                	pushl  (%eax)
  80172f:	e8 33 fc ff ff       	call   801367 <dev_lookup>
  801734:	83 c4 10             	add    $0x10,%esp
  801737:	85 c0                	test   %eax,%eax
  801739:	78 44                	js     80177f <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80173b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80173e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801742:	75 21                	jne    801765 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801744:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801749:	8b 40 48             	mov    0x48(%eax),%eax
  80174c:	83 ec 04             	sub    $0x4,%esp
  80174f:	53                   	push   %ebx
  801750:	50                   	push   %eax
  801751:	68 ac 28 80 00       	push   $0x8028ac
  801756:	e8 16 ec ff ff       	call   800371 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80175b:	83 c4 10             	add    $0x10,%esp
  80175e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801763:	eb 23                	jmp    801788 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801765:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801768:	8b 52 18             	mov    0x18(%edx),%edx
  80176b:	85 d2                	test   %edx,%edx
  80176d:	74 14                	je     801783 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80176f:	83 ec 08             	sub    $0x8,%esp
  801772:	ff 75 0c             	pushl  0xc(%ebp)
  801775:	50                   	push   %eax
  801776:	ff d2                	call   *%edx
  801778:	89 c2                	mov    %eax,%edx
  80177a:	83 c4 10             	add    $0x10,%esp
  80177d:	eb 09                	jmp    801788 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80177f:	89 c2                	mov    %eax,%edx
  801781:	eb 05                	jmp    801788 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801783:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801788:	89 d0                	mov    %edx,%eax
  80178a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80178d:	c9                   	leave  
  80178e:	c3                   	ret    

0080178f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80178f:	55                   	push   %ebp
  801790:	89 e5                	mov    %esp,%ebp
  801792:	53                   	push   %ebx
  801793:	83 ec 14             	sub    $0x14,%esp
  801796:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801799:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80179c:	50                   	push   %eax
  80179d:	ff 75 08             	pushl  0x8(%ebp)
  8017a0:	e8 6c fb ff ff       	call   801311 <fd_lookup>
  8017a5:	83 c4 08             	add    $0x8,%esp
  8017a8:	89 c2                	mov    %eax,%edx
  8017aa:	85 c0                	test   %eax,%eax
  8017ac:	78 58                	js     801806 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017ae:	83 ec 08             	sub    $0x8,%esp
  8017b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017b4:	50                   	push   %eax
  8017b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017b8:	ff 30                	pushl  (%eax)
  8017ba:	e8 a8 fb ff ff       	call   801367 <dev_lookup>
  8017bf:	83 c4 10             	add    $0x10,%esp
  8017c2:	85 c0                	test   %eax,%eax
  8017c4:	78 37                	js     8017fd <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8017c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017c9:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8017cd:	74 32                	je     801801 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8017cf:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8017d2:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017d9:	00 00 00 
	stat->st_isdir = 0;
  8017dc:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017e3:	00 00 00 
	stat->st_dev = dev;
  8017e6:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017ec:	83 ec 08             	sub    $0x8,%esp
  8017ef:	53                   	push   %ebx
  8017f0:	ff 75 f0             	pushl  -0x10(%ebp)
  8017f3:	ff 50 14             	call   *0x14(%eax)
  8017f6:	89 c2                	mov    %eax,%edx
  8017f8:	83 c4 10             	add    $0x10,%esp
  8017fb:	eb 09                	jmp    801806 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017fd:	89 c2                	mov    %eax,%edx
  8017ff:	eb 05                	jmp    801806 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801801:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801806:	89 d0                	mov    %edx,%eax
  801808:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80180b:	c9                   	leave  
  80180c:	c3                   	ret    

0080180d <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80180d:	55                   	push   %ebp
  80180e:	89 e5                	mov    %esp,%ebp
  801810:	56                   	push   %esi
  801811:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801812:	83 ec 08             	sub    $0x8,%esp
  801815:	6a 00                	push   $0x0
  801817:	ff 75 08             	pushl  0x8(%ebp)
  80181a:	e8 b7 01 00 00       	call   8019d6 <open>
  80181f:	89 c3                	mov    %eax,%ebx
  801821:	83 c4 10             	add    $0x10,%esp
  801824:	85 c0                	test   %eax,%eax
  801826:	78 1b                	js     801843 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801828:	83 ec 08             	sub    $0x8,%esp
  80182b:	ff 75 0c             	pushl  0xc(%ebp)
  80182e:	50                   	push   %eax
  80182f:	e8 5b ff ff ff       	call   80178f <fstat>
  801834:	89 c6                	mov    %eax,%esi
	close(fd);
  801836:	89 1c 24             	mov    %ebx,(%esp)
  801839:	e8 fd fb ff ff       	call   80143b <close>
	return r;
  80183e:	83 c4 10             	add    $0x10,%esp
  801841:	89 f0                	mov    %esi,%eax
}
  801843:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801846:	5b                   	pop    %ebx
  801847:	5e                   	pop    %esi
  801848:	5d                   	pop    %ebp
  801849:	c3                   	ret    

0080184a <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80184a:	55                   	push   %ebp
  80184b:	89 e5                	mov    %esp,%ebp
  80184d:	56                   	push   %esi
  80184e:	53                   	push   %ebx
  80184f:	89 c6                	mov    %eax,%esi
  801851:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801853:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80185a:	75 12                	jne    80186e <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80185c:	83 ec 0c             	sub    $0xc,%esp
  80185f:	6a 01                	push   $0x1
  801861:	e8 2c 08 00 00       	call   802092 <ipc_find_env>
  801866:	a3 00 40 80 00       	mov    %eax,0x804000
  80186b:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80186e:	6a 07                	push   $0x7
  801870:	68 00 50 80 00       	push   $0x805000
  801875:	56                   	push   %esi
  801876:	ff 35 00 40 80 00    	pushl  0x804000
  80187c:	e8 bd 07 00 00       	call   80203e <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801881:	83 c4 0c             	add    $0xc,%esp
  801884:	6a 00                	push   $0x0
  801886:	53                   	push   %ebx
  801887:	6a 00                	push   $0x0
  801889:	e8 3b 07 00 00       	call   801fc9 <ipc_recv>
}
  80188e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801891:	5b                   	pop    %ebx
  801892:	5e                   	pop    %esi
  801893:	5d                   	pop    %ebp
  801894:	c3                   	ret    

00801895 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801895:	55                   	push   %ebp
  801896:	89 e5                	mov    %esp,%ebp
  801898:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80189b:	8b 45 08             	mov    0x8(%ebp),%eax
  80189e:	8b 40 0c             	mov    0xc(%eax),%eax
  8018a1:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8018a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018a9:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8018ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8018b3:	b8 02 00 00 00       	mov    $0x2,%eax
  8018b8:	e8 8d ff ff ff       	call   80184a <fsipc>
}
  8018bd:	c9                   	leave  
  8018be:	c3                   	ret    

008018bf <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8018bf:	55                   	push   %ebp
  8018c0:	89 e5                	mov    %esp,%ebp
  8018c2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c8:	8b 40 0c             	mov    0xc(%eax),%eax
  8018cb:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8018d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8018d5:	b8 06 00 00 00       	mov    $0x6,%eax
  8018da:	e8 6b ff ff ff       	call   80184a <fsipc>
}
  8018df:	c9                   	leave  
  8018e0:	c3                   	ret    

008018e1 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8018e1:	55                   	push   %ebp
  8018e2:	89 e5                	mov    %esp,%ebp
  8018e4:	53                   	push   %ebx
  8018e5:	83 ec 04             	sub    $0x4,%esp
  8018e8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ee:	8b 40 0c             	mov    0xc(%eax),%eax
  8018f1:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018f6:	ba 00 00 00 00       	mov    $0x0,%edx
  8018fb:	b8 05 00 00 00       	mov    $0x5,%eax
  801900:	e8 45 ff ff ff       	call   80184a <fsipc>
  801905:	85 c0                	test   %eax,%eax
  801907:	78 2c                	js     801935 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801909:	83 ec 08             	sub    $0x8,%esp
  80190c:	68 00 50 80 00       	push   $0x805000
  801911:	53                   	push   %ebx
  801912:	e8 86 f0 ff ff       	call   80099d <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801917:	a1 80 50 80 00       	mov    0x805080,%eax
  80191c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801922:	a1 84 50 80 00       	mov    0x805084,%eax
  801927:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80192d:	83 c4 10             	add    $0x10,%esp
  801930:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801935:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801938:	c9                   	leave  
  801939:	c3                   	ret    

0080193a <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80193a:	55                   	push   %ebp
  80193b:	89 e5                	mov    %esp,%ebp
  80193d:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801940:	68 1c 29 80 00       	push   $0x80291c
  801945:	68 90 00 00 00       	push   $0x90
  80194a:	68 3a 29 80 00       	push   $0x80293a
  80194f:	e8 44 e9 ff ff       	call   800298 <_panic>

00801954 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801954:	55                   	push   %ebp
  801955:	89 e5                	mov    %esp,%ebp
  801957:	56                   	push   %esi
  801958:	53                   	push   %ebx
  801959:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80195c:	8b 45 08             	mov    0x8(%ebp),%eax
  80195f:	8b 40 0c             	mov    0xc(%eax),%eax
  801962:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801967:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80196d:	ba 00 00 00 00       	mov    $0x0,%edx
  801972:	b8 03 00 00 00       	mov    $0x3,%eax
  801977:	e8 ce fe ff ff       	call   80184a <fsipc>
  80197c:	89 c3                	mov    %eax,%ebx
  80197e:	85 c0                	test   %eax,%eax
  801980:	78 4b                	js     8019cd <devfile_read+0x79>
		return r;
	assert(r <= n);
  801982:	39 c6                	cmp    %eax,%esi
  801984:	73 16                	jae    80199c <devfile_read+0x48>
  801986:	68 45 29 80 00       	push   $0x802945
  80198b:	68 4c 29 80 00       	push   $0x80294c
  801990:	6a 7c                	push   $0x7c
  801992:	68 3a 29 80 00       	push   $0x80293a
  801997:	e8 fc e8 ff ff       	call   800298 <_panic>
	assert(r <= PGSIZE);
  80199c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8019a1:	7e 16                	jle    8019b9 <devfile_read+0x65>
  8019a3:	68 61 29 80 00       	push   $0x802961
  8019a8:	68 4c 29 80 00       	push   $0x80294c
  8019ad:	6a 7d                	push   $0x7d
  8019af:	68 3a 29 80 00       	push   $0x80293a
  8019b4:	e8 df e8 ff ff       	call   800298 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8019b9:	83 ec 04             	sub    $0x4,%esp
  8019bc:	50                   	push   %eax
  8019bd:	68 00 50 80 00       	push   $0x805000
  8019c2:	ff 75 0c             	pushl  0xc(%ebp)
  8019c5:	e8 65 f1 ff ff       	call   800b2f <memmove>
	return r;
  8019ca:	83 c4 10             	add    $0x10,%esp
}
  8019cd:	89 d8                	mov    %ebx,%eax
  8019cf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019d2:	5b                   	pop    %ebx
  8019d3:	5e                   	pop    %esi
  8019d4:	5d                   	pop    %ebp
  8019d5:	c3                   	ret    

008019d6 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8019d6:	55                   	push   %ebp
  8019d7:	89 e5                	mov    %esp,%ebp
  8019d9:	53                   	push   %ebx
  8019da:	83 ec 20             	sub    $0x20,%esp
  8019dd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8019e0:	53                   	push   %ebx
  8019e1:	e8 7e ef ff ff       	call   800964 <strlen>
  8019e6:	83 c4 10             	add    $0x10,%esp
  8019e9:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019ee:	7f 67                	jg     801a57 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019f0:	83 ec 0c             	sub    $0xc,%esp
  8019f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019f6:	50                   	push   %eax
  8019f7:	e8 c6 f8 ff ff       	call   8012c2 <fd_alloc>
  8019fc:	83 c4 10             	add    $0x10,%esp
		return r;
  8019ff:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a01:	85 c0                	test   %eax,%eax
  801a03:	78 57                	js     801a5c <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a05:	83 ec 08             	sub    $0x8,%esp
  801a08:	53                   	push   %ebx
  801a09:	68 00 50 80 00       	push   $0x805000
  801a0e:	e8 8a ef ff ff       	call   80099d <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a13:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a16:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a1b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a1e:	b8 01 00 00 00       	mov    $0x1,%eax
  801a23:	e8 22 fe ff ff       	call   80184a <fsipc>
  801a28:	89 c3                	mov    %eax,%ebx
  801a2a:	83 c4 10             	add    $0x10,%esp
  801a2d:	85 c0                	test   %eax,%eax
  801a2f:	79 14                	jns    801a45 <open+0x6f>
		fd_close(fd, 0);
  801a31:	83 ec 08             	sub    $0x8,%esp
  801a34:	6a 00                	push   $0x0
  801a36:	ff 75 f4             	pushl  -0xc(%ebp)
  801a39:	e8 7c f9 ff ff       	call   8013ba <fd_close>
		return r;
  801a3e:	83 c4 10             	add    $0x10,%esp
  801a41:	89 da                	mov    %ebx,%edx
  801a43:	eb 17                	jmp    801a5c <open+0x86>
	}

	return fd2num(fd);
  801a45:	83 ec 0c             	sub    $0xc,%esp
  801a48:	ff 75 f4             	pushl  -0xc(%ebp)
  801a4b:	e8 4b f8 ff ff       	call   80129b <fd2num>
  801a50:	89 c2                	mov    %eax,%edx
  801a52:	83 c4 10             	add    $0x10,%esp
  801a55:	eb 05                	jmp    801a5c <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a57:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a5c:	89 d0                	mov    %edx,%eax
  801a5e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a61:	c9                   	leave  
  801a62:	c3                   	ret    

00801a63 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a63:	55                   	push   %ebp
  801a64:	89 e5                	mov    %esp,%ebp
  801a66:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a69:	ba 00 00 00 00       	mov    $0x0,%edx
  801a6e:	b8 08 00 00 00       	mov    $0x8,%eax
  801a73:	e8 d2 fd ff ff       	call   80184a <fsipc>
}
  801a78:	c9                   	leave  
  801a79:	c3                   	ret    

00801a7a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a7a:	55                   	push   %ebp
  801a7b:	89 e5                	mov    %esp,%ebp
  801a7d:	56                   	push   %esi
  801a7e:	53                   	push   %ebx
  801a7f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a82:	83 ec 0c             	sub    $0xc,%esp
  801a85:	ff 75 08             	pushl  0x8(%ebp)
  801a88:	e8 1e f8 ff ff       	call   8012ab <fd2data>
  801a8d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a8f:	83 c4 08             	add    $0x8,%esp
  801a92:	68 6d 29 80 00       	push   $0x80296d
  801a97:	53                   	push   %ebx
  801a98:	e8 00 ef ff ff       	call   80099d <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a9d:	8b 46 04             	mov    0x4(%esi),%eax
  801aa0:	2b 06                	sub    (%esi),%eax
  801aa2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801aa8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801aaf:	00 00 00 
	stat->st_dev = &devpipe;
  801ab2:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801ab9:	30 80 00 
	return 0;
}
  801abc:	b8 00 00 00 00       	mov    $0x0,%eax
  801ac1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ac4:	5b                   	pop    %ebx
  801ac5:	5e                   	pop    %esi
  801ac6:	5d                   	pop    %ebp
  801ac7:	c3                   	ret    

00801ac8 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ac8:	55                   	push   %ebp
  801ac9:	89 e5                	mov    %esp,%ebp
  801acb:	53                   	push   %ebx
  801acc:	83 ec 0c             	sub    $0xc,%esp
  801acf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ad2:	53                   	push   %ebx
  801ad3:	6a 00                	push   $0x0
  801ad5:	e8 4b f3 ff ff       	call   800e25 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ada:	89 1c 24             	mov    %ebx,(%esp)
  801add:	e8 c9 f7 ff ff       	call   8012ab <fd2data>
  801ae2:	83 c4 08             	add    $0x8,%esp
  801ae5:	50                   	push   %eax
  801ae6:	6a 00                	push   $0x0
  801ae8:	e8 38 f3 ff ff       	call   800e25 <sys_page_unmap>
}
  801aed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801af0:	c9                   	leave  
  801af1:	c3                   	ret    

00801af2 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801af2:	55                   	push   %ebp
  801af3:	89 e5                	mov    %esp,%ebp
  801af5:	57                   	push   %edi
  801af6:	56                   	push   %esi
  801af7:	53                   	push   %ebx
  801af8:	83 ec 1c             	sub    $0x1c,%esp
  801afb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801afe:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b00:	a1 04 40 80 00       	mov    0x804004,%eax
  801b05:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801b08:	83 ec 0c             	sub    $0xc,%esp
  801b0b:	ff 75 e0             	pushl  -0x20(%ebp)
  801b0e:	e8 b8 05 00 00       	call   8020cb <pageref>
  801b13:	89 c3                	mov    %eax,%ebx
  801b15:	89 3c 24             	mov    %edi,(%esp)
  801b18:	e8 ae 05 00 00       	call   8020cb <pageref>
  801b1d:	83 c4 10             	add    $0x10,%esp
  801b20:	39 c3                	cmp    %eax,%ebx
  801b22:	0f 94 c1             	sete   %cl
  801b25:	0f b6 c9             	movzbl %cl,%ecx
  801b28:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801b2b:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801b31:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b34:	39 ce                	cmp    %ecx,%esi
  801b36:	74 1b                	je     801b53 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801b38:	39 c3                	cmp    %eax,%ebx
  801b3a:	75 c4                	jne    801b00 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b3c:	8b 42 58             	mov    0x58(%edx),%eax
  801b3f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b42:	50                   	push   %eax
  801b43:	56                   	push   %esi
  801b44:	68 74 29 80 00       	push   $0x802974
  801b49:	e8 23 e8 ff ff       	call   800371 <cprintf>
  801b4e:	83 c4 10             	add    $0x10,%esp
  801b51:	eb ad                	jmp    801b00 <_pipeisclosed+0xe>
	}
}
  801b53:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b59:	5b                   	pop    %ebx
  801b5a:	5e                   	pop    %esi
  801b5b:	5f                   	pop    %edi
  801b5c:	5d                   	pop    %ebp
  801b5d:	c3                   	ret    

00801b5e <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b5e:	55                   	push   %ebp
  801b5f:	89 e5                	mov    %esp,%ebp
  801b61:	57                   	push   %edi
  801b62:	56                   	push   %esi
  801b63:	53                   	push   %ebx
  801b64:	83 ec 28             	sub    $0x28,%esp
  801b67:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b6a:	56                   	push   %esi
  801b6b:	e8 3b f7 ff ff       	call   8012ab <fd2data>
  801b70:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b72:	83 c4 10             	add    $0x10,%esp
  801b75:	bf 00 00 00 00       	mov    $0x0,%edi
  801b7a:	eb 4b                	jmp    801bc7 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b7c:	89 da                	mov    %ebx,%edx
  801b7e:	89 f0                	mov    %esi,%eax
  801b80:	e8 6d ff ff ff       	call   801af2 <_pipeisclosed>
  801b85:	85 c0                	test   %eax,%eax
  801b87:	75 48                	jne    801bd1 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b89:	e8 f3 f1 ff ff       	call   800d81 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b8e:	8b 43 04             	mov    0x4(%ebx),%eax
  801b91:	8b 0b                	mov    (%ebx),%ecx
  801b93:	8d 51 20             	lea    0x20(%ecx),%edx
  801b96:	39 d0                	cmp    %edx,%eax
  801b98:	73 e2                	jae    801b7c <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b9a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b9d:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801ba1:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801ba4:	89 c2                	mov    %eax,%edx
  801ba6:	c1 fa 1f             	sar    $0x1f,%edx
  801ba9:	89 d1                	mov    %edx,%ecx
  801bab:	c1 e9 1b             	shr    $0x1b,%ecx
  801bae:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801bb1:	83 e2 1f             	and    $0x1f,%edx
  801bb4:	29 ca                	sub    %ecx,%edx
  801bb6:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801bba:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801bbe:	83 c0 01             	add    $0x1,%eax
  801bc1:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bc4:	83 c7 01             	add    $0x1,%edi
  801bc7:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801bca:	75 c2                	jne    801b8e <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801bcc:	8b 45 10             	mov    0x10(%ebp),%eax
  801bcf:	eb 05                	jmp    801bd6 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bd1:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801bd6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bd9:	5b                   	pop    %ebx
  801bda:	5e                   	pop    %esi
  801bdb:	5f                   	pop    %edi
  801bdc:	5d                   	pop    %ebp
  801bdd:	c3                   	ret    

00801bde <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801bde:	55                   	push   %ebp
  801bdf:	89 e5                	mov    %esp,%ebp
  801be1:	57                   	push   %edi
  801be2:	56                   	push   %esi
  801be3:	53                   	push   %ebx
  801be4:	83 ec 18             	sub    $0x18,%esp
  801be7:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801bea:	57                   	push   %edi
  801beb:	e8 bb f6 ff ff       	call   8012ab <fd2data>
  801bf0:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bf2:	83 c4 10             	add    $0x10,%esp
  801bf5:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bfa:	eb 3d                	jmp    801c39 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801bfc:	85 db                	test   %ebx,%ebx
  801bfe:	74 04                	je     801c04 <devpipe_read+0x26>
				return i;
  801c00:	89 d8                	mov    %ebx,%eax
  801c02:	eb 44                	jmp    801c48 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c04:	89 f2                	mov    %esi,%edx
  801c06:	89 f8                	mov    %edi,%eax
  801c08:	e8 e5 fe ff ff       	call   801af2 <_pipeisclosed>
  801c0d:	85 c0                	test   %eax,%eax
  801c0f:	75 32                	jne    801c43 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c11:	e8 6b f1 ff ff       	call   800d81 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c16:	8b 06                	mov    (%esi),%eax
  801c18:	3b 46 04             	cmp    0x4(%esi),%eax
  801c1b:	74 df                	je     801bfc <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c1d:	99                   	cltd   
  801c1e:	c1 ea 1b             	shr    $0x1b,%edx
  801c21:	01 d0                	add    %edx,%eax
  801c23:	83 e0 1f             	and    $0x1f,%eax
  801c26:	29 d0                	sub    %edx,%eax
  801c28:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801c2d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c30:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801c33:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c36:	83 c3 01             	add    $0x1,%ebx
  801c39:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c3c:	75 d8                	jne    801c16 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c3e:	8b 45 10             	mov    0x10(%ebp),%eax
  801c41:	eb 05                	jmp    801c48 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c43:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c48:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c4b:	5b                   	pop    %ebx
  801c4c:	5e                   	pop    %esi
  801c4d:	5f                   	pop    %edi
  801c4e:	5d                   	pop    %ebp
  801c4f:	c3                   	ret    

00801c50 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c50:	55                   	push   %ebp
  801c51:	89 e5                	mov    %esp,%ebp
  801c53:	56                   	push   %esi
  801c54:	53                   	push   %ebx
  801c55:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c58:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c5b:	50                   	push   %eax
  801c5c:	e8 61 f6 ff ff       	call   8012c2 <fd_alloc>
  801c61:	83 c4 10             	add    $0x10,%esp
  801c64:	89 c2                	mov    %eax,%edx
  801c66:	85 c0                	test   %eax,%eax
  801c68:	0f 88 2c 01 00 00    	js     801d9a <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c6e:	83 ec 04             	sub    $0x4,%esp
  801c71:	68 07 04 00 00       	push   $0x407
  801c76:	ff 75 f4             	pushl  -0xc(%ebp)
  801c79:	6a 00                	push   $0x0
  801c7b:	e8 20 f1 ff ff       	call   800da0 <sys_page_alloc>
  801c80:	83 c4 10             	add    $0x10,%esp
  801c83:	89 c2                	mov    %eax,%edx
  801c85:	85 c0                	test   %eax,%eax
  801c87:	0f 88 0d 01 00 00    	js     801d9a <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c8d:	83 ec 0c             	sub    $0xc,%esp
  801c90:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c93:	50                   	push   %eax
  801c94:	e8 29 f6 ff ff       	call   8012c2 <fd_alloc>
  801c99:	89 c3                	mov    %eax,%ebx
  801c9b:	83 c4 10             	add    $0x10,%esp
  801c9e:	85 c0                	test   %eax,%eax
  801ca0:	0f 88 e2 00 00 00    	js     801d88 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ca6:	83 ec 04             	sub    $0x4,%esp
  801ca9:	68 07 04 00 00       	push   $0x407
  801cae:	ff 75 f0             	pushl  -0x10(%ebp)
  801cb1:	6a 00                	push   $0x0
  801cb3:	e8 e8 f0 ff ff       	call   800da0 <sys_page_alloc>
  801cb8:	89 c3                	mov    %eax,%ebx
  801cba:	83 c4 10             	add    $0x10,%esp
  801cbd:	85 c0                	test   %eax,%eax
  801cbf:	0f 88 c3 00 00 00    	js     801d88 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801cc5:	83 ec 0c             	sub    $0xc,%esp
  801cc8:	ff 75 f4             	pushl  -0xc(%ebp)
  801ccb:	e8 db f5 ff ff       	call   8012ab <fd2data>
  801cd0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cd2:	83 c4 0c             	add    $0xc,%esp
  801cd5:	68 07 04 00 00       	push   $0x407
  801cda:	50                   	push   %eax
  801cdb:	6a 00                	push   $0x0
  801cdd:	e8 be f0 ff ff       	call   800da0 <sys_page_alloc>
  801ce2:	89 c3                	mov    %eax,%ebx
  801ce4:	83 c4 10             	add    $0x10,%esp
  801ce7:	85 c0                	test   %eax,%eax
  801ce9:	0f 88 89 00 00 00    	js     801d78 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cef:	83 ec 0c             	sub    $0xc,%esp
  801cf2:	ff 75 f0             	pushl  -0x10(%ebp)
  801cf5:	e8 b1 f5 ff ff       	call   8012ab <fd2data>
  801cfa:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d01:	50                   	push   %eax
  801d02:	6a 00                	push   $0x0
  801d04:	56                   	push   %esi
  801d05:	6a 00                	push   $0x0
  801d07:	e8 d7 f0 ff ff       	call   800de3 <sys_page_map>
  801d0c:	89 c3                	mov    %eax,%ebx
  801d0e:	83 c4 20             	add    $0x20,%esp
  801d11:	85 c0                	test   %eax,%eax
  801d13:	78 55                	js     801d6a <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d15:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d1e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d20:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d23:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d2a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d30:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d33:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d35:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d38:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d3f:	83 ec 0c             	sub    $0xc,%esp
  801d42:	ff 75 f4             	pushl  -0xc(%ebp)
  801d45:	e8 51 f5 ff ff       	call   80129b <fd2num>
  801d4a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d4d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d4f:	83 c4 04             	add    $0x4,%esp
  801d52:	ff 75 f0             	pushl  -0x10(%ebp)
  801d55:	e8 41 f5 ff ff       	call   80129b <fd2num>
  801d5a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d5d:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d60:	83 c4 10             	add    $0x10,%esp
  801d63:	ba 00 00 00 00       	mov    $0x0,%edx
  801d68:	eb 30                	jmp    801d9a <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d6a:	83 ec 08             	sub    $0x8,%esp
  801d6d:	56                   	push   %esi
  801d6e:	6a 00                	push   $0x0
  801d70:	e8 b0 f0 ff ff       	call   800e25 <sys_page_unmap>
  801d75:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d78:	83 ec 08             	sub    $0x8,%esp
  801d7b:	ff 75 f0             	pushl  -0x10(%ebp)
  801d7e:	6a 00                	push   $0x0
  801d80:	e8 a0 f0 ff ff       	call   800e25 <sys_page_unmap>
  801d85:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d88:	83 ec 08             	sub    $0x8,%esp
  801d8b:	ff 75 f4             	pushl  -0xc(%ebp)
  801d8e:	6a 00                	push   $0x0
  801d90:	e8 90 f0 ff ff       	call   800e25 <sys_page_unmap>
  801d95:	83 c4 10             	add    $0x10,%esp
  801d98:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d9a:	89 d0                	mov    %edx,%eax
  801d9c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d9f:	5b                   	pop    %ebx
  801da0:	5e                   	pop    %esi
  801da1:	5d                   	pop    %ebp
  801da2:	c3                   	ret    

00801da3 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801da3:	55                   	push   %ebp
  801da4:	89 e5                	mov    %esp,%ebp
  801da6:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801da9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dac:	50                   	push   %eax
  801dad:	ff 75 08             	pushl  0x8(%ebp)
  801db0:	e8 5c f5 ff ff       	call   801311 <fd_lookup>
  801db5:	83 c4 10             	add    $0x10,%esp
  801db8:	85 c0                	test   %eax,%eax
  801dba:	78 18                	js     801dd4 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801dbc:	83 ec 0c             	sub    $0xc,%esp
  801dbf:	ff 75 f4             	pushl  -0xc(%ebp)
  801dc2:	e8 e4 f4 ff ff       	call   8012ab <fd2data>
	return _pipeisclosed(fd, p);
  801dc7:	89 c2                	mov    %eax,%edx
  801dc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dcc:	e8 21 fd ff ff       	call   801af2 <_pipeisclosed>
  801dd1:	83 c4 10             	add    $0x10,%esp
}
  801dd4:	c9                   	leave  
  801dd5:	c3                   	ret    

00801dd6 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801dd6:	55                   	push   %ebp
  801dd7:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801dd9:	b8 00 00 00 00       	mov    $0x0,%eax
  801dde:	5d                   	pop    %ebp
  801ddf:	c3                   	ret    

00801de0 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801de0:	55                   	push   %ebp
  801de1:	89 e5                	mov    %esp,%ebp
  801de3:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801de6:	68 87 29 80 00       	push   $0x802987
  801deb:	ff 75 0c             	pushl  0xc(%ebp)
  801dee:	e8 aa eb ff ff       	call   80099d <strcpy>
	return 0;
}
  801df3:	b8 00 00 00 00       	mov    $0x0,%eax
  801df8:	c9                   	leave  
  801df9:	c3                   	ret    

00801dfa <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801dfa:	55                   	push   %ebp
  801dfb:	89 e5                	mov    %esp,%ebp
  801dfd:	57                   	push   %edi
  801dfe:	56                   	push   %esi
  801dff:	53                   	push   %ebx
  801e00:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e06:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e0b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e11:	eb 2d                	jmp    801e40 <devcons_write+0x46>
		m = n - tot;
  801e13:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e16:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801e18:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e1b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801e20:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e23:	83 ec 04             	sub    $0x4,%esp
  801e26:	53                   	push   %ebx
  801e27:	03 45 0c             	add    0xc(%ebp),%eax
  801e2a:	50                   	push   %eax
  801e2b:	57                   	push   %edi
  801e2c:	e8 fe ec ff ff       	call   800b2f <memmove>
		sys_cputs(buf, m);
  801e31:	83 c4 08             	add    $0x8,%esp
  801e34:	53                   	push   %ebx
  801e35:	57                   	push   %edi
  801e36:	e8 a9 ee ff ff       	call   800ce4 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e3b:	01 de                	add    %ebx,%esi
  801e3d:	83 c4 10             	add    $0x10,%esp
  801e40:	89 f0                	mov    %esi,%eax
  801e42:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e45:	72 cc                	jb     801e13 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e47:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e4a:	5b                   	pop    %ebx
  801e4b:	5e                   	pop    %esi
  801e4c:	5f                   	pop    %edi
  801e4d:	5d                   	pop    %ebp
  801e4e:	c3                   	ret    

00801e4f <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e4f:	55                   	push   %ebp
  801e50:	89 e5                	mov    %esp,%ebp
  801e52:	83 ec 08             	sub    $0x8,%esp
  801e55:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801e5a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e5e:	74 2a                	je     801e8a <devcons_read+0x3b>
  801e60:	eb 05                	jmp    801e67 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e62:	e8 1a ef ff ff       	call   800d81 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e67:	e8 96 ee ff ff       	call   800d02 <sys_cgetc>
  801e6c:	85 c0                	test   %eax,%eax
  801e6e:	74 f2                	je     801e62 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801e70:	85 c0                	test   %eax,%eax
  801e72:	78 16                	js     801e8a <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e74:	83 f8 04             	cmp    $0x4,%eax
  801e77:	74 0c                	je     801e85 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e79:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e7c:	88 02                	mov    %al,(%edx)
	return 1;
  801e7e:	b8 01 00 00 00       	mov    $0x1,%eax
  801e83:	eb 05                	jmp    801e8a <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e85:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e8a:	c9                   	leave  
  801e8b:	c3                   	ret    

00801e8c <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e8c:	55                   	push   %ebp
  801e8d:	89 e5                	mov    %esp,%ebp
  801e8f:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e92:	8b 45 08             	mov    0x8(%ebp),%eax
  801e95:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e98:	6a 01                	push   $0x1
  801e9a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e9d:	50                   	push   %eax
  801e9e:	e8 41 ee ff ff       	call   800ce4 <sys_cputs>
}
  801ea3:	83 c4 10             	add    $0x10,%esp
  801ea6:	c9                   	leave  
  801ea7:	c3                   	ret    

00801ea8 <getchar>:

int
getchar(void)
{
  801ea8:	55                   	push   %ebp
  801ea9:	89 e5                	mov    %esp,%ebp
  801eab:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801eae:	6a 01                	push   $0x1
  801eb0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801eb3:	50                   	push   %eax
  801eb4:	6a 00                	push   $0x0
  801eb6:	e8 bc f6 ff ff       	call   801577 <read>
	if (r < 0)
  801ebb:	83 c4 10             	add    $0x10,%esp
  801ebe:	85 c0                	test   %eax,%eax
  801ec0:	78 0f                	js     801ed1 <getchar+0x29>
		return r;
	if (r < 1)
  801ec2:	85 c0                	test   %eax,%eax
  801ec4:	7e 06                	jle    801ecc <getchar+0x24>
		return -E_EOF;
	return c;
  801ec6:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801eca:	eb 05                	jmp    801ed1 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801ecc:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801ed1:	c9                   	leave  
  801ed2:	c3                   	ret    

00801ed3 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801ed3:	55                   	push   %ebp
  801ed4:	89 e5                	mov    %esp,%ebp
  801ed6:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ed9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801edc:	50                   	push   %eax
  801edd:	ff 75 08             	pushl  0x8(%ebp)
  801ee0:	e8 2c f4 ff ff       	call   801311 <fd_lookup>
  801ee5:	83 c4 10             	add    $0x10,%esp
  801ee8:	85 c0                	test   %eax,%eax
  801eea:	78 11                	js     801efd <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801eec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eef:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ef5:	39 10                	cmp    %edx,(%eax)
  801ef7:	0f 94 c0             	sete   %al
  801efa:	0f b6 c0             	movzbl %al,%eax
}
  801efd:	c9                   	leave  
  801efe:	c3                   	ret    

00801eff <opencons>:

int
opencons(void)
{
  801eff:	55                   	push   %ebp
  801f00:	89 e5                	mov    %esp,%ebp
  801f02:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f05:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f08:	50                   	push   %eax
  801f09:	e8 b4 f3 ff ff       	call   8012c2 <fd_alloc>
  801f0e:	83 c4 10             	add    $0x10,%esp
		return r;
  801f11:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f13:	85 c0                	test   %eax,%eax
  801f15:	78 3e                	js     801f55 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f17:	83 ec 04             	sub    $0x4,%esp
  801f1a:	68 07 04 00 00       	push   $0x407
  801f1f:	ff 75 f4             	pushl  -0xc(%ebp)
  801f22:	6a 00                	push   $0x0
  801f24:	e8 77 ee ff ff       	call   800da0 <sys_page_alloc>
  801f29:	83 c4 10             	add    $0x10,%esp
		return r;
  801f2c:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f2e:	85 c0                	test   %eax,%eax
  801f30:	78 23                	js     801f55 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f32:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f38:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f3b:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f40:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f47:	83 ec 0c             	sub    $0xc,%esp
  801f4a:	50                   	push   %eax
  801f4b:	e8 4b f3 ff ff       	call   80129b <fd2num>
  801f50:	89 c2                	mov    %eax,%edx
  801f52:	83 c4 10             	add    $0x10,%esp
}
  801f55:	89 d0                	mov    %edx,%eax
  801f57:	c9                   	leave  
  801f58:	c3                   	ret    

00801f59 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f59:	55                   	push   %ebp
  801f5a:	89 e5                	mov    %esp,%ebp
  801f5c:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f5f:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f66:	75 31                	jne    801f99 <set_pgfault_handler+0x40>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc(thisenv->env_id, (void*)(UXSTACKTOP - PGSIZE), PTE_P | 
  801f68:	a1 04 40 80 00       	mov    0x804004,%eax
  801f6d:	8b 40 48             	mov    0x48(%eax),%eax
  801f70:	83 ec 04             	sub    $0x4,%esp
  801f73:	6a 07                	push   $0x7
  801f75:	68 00 f0 bf ee       	push   $0xeebff000
  801f7a:	50                   	push   %eax
  801f7b:	e8 20 ee ff ff       	call   800da0 <sys_page_alloc>
				PTE_U | PTE_W);
		sys_env_set_pgfault_upcall(thisenv->env_id, (void*)_pgfault_upcall);
  801f80:	a1 04 40 80 00       	mov    0x804004,%eax
  801f85:	8b 40 48             	mov    0x48(%eax),%eax
  801f88:	83 c4 08             	add    $0x8,%esp
  801f8b:	68 a3 1f 80 00       	push   $0x801fa3
  801f90:	50                   	push   %eax
  801f91:	e8 55 ef ff ff       	call   800eeb <sys_env_set_pgfault_upcall>
  801f96:	83 c4 10             	add    $0x10,%esp

		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f99:	8b 45 08             	mov    0x8(%ebp),%eax
  801f9c:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801fa1:	c9                   	leave  
  801fa2:	c3                   	ret    

00801fa3 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801fa3:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801fa4:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801fa9:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801fab:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	addl $8, %esp      // pop utf_fault_va and utf_err
  801fae:	83 c4 08             	add    $0x8,%esp
	movl 32(%esp), %eax  // eax <- [esp + 32]
  801fb1:	8b 44 24 20          	mov    0x20(%esp),%eax
	movl 40(%esp), %ebx  // ebx <- [esp + 40]
  801fb5:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	leal -4(%ebx), %ebx  // ebx <- ebx - 4
  801fb9:	8d 5b fc             	lea    -0x4(%ebx),%ebx
	movl %eax, (%ebx)
  801fbc:	89 03                	mov    %eax,(%ebx)
	movl %ebx, 40(%esp)  // push trap eip and decrement trap esp manually
  801fbe:	89 5c 24 28          	mov    %ebx,0x28(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  801fc2:	61                   	popa   
	addl $4, %esp        // skip eip
  801fc3:	83 c4 04             	add    $0x4,%esp

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	popf
  801fc6:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	pop %esp
  801fc7:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801fc8:	c3                   	ret    

00801fc9 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801fc9:	55                   	push   %ebp
  801fca:	89 e5                	mov    %esp,%ebp
  801fcc:	56                   	push   %esi
  801fcd:	53                   	push   %ebx
  801fce:	8b 75 08             	mov    0x8(%ebp),%esi
  801fd1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fd4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int ret;
	if (pg) ret = sys_ipc_recv(pg);
  801fd7:	85 c0                	test   %eax,%eax
  801fd9:	74 0e                	je     801fe9 <ipc_recv+0x20>
  801fdb:	83 ec 0c             	sub    $0xc,%esp
  801fde:	50                   	push   %eax
  801fdf:	e8 6c ef ff ff       	call   800f50 <sys_ipc_recv>
  801fe4:	83 c4 10             	add    $0x10,%esp
  801fe7:	eb 10                	jmp    801ff9 <ipc_recv+0x30>
	else ret = sys_ipc_recv((void*)UTOP);
  801fe9:	83 ec 0c             	sub    $0xc,%esp
  801fec:	68 00 00 c0 ee       	push   $0xeec00000
  801ff1:	e8 5a ef ff ff       	call   800f50 <sys_ipc_recv>
  801ff6:	83 c4 10             	add    $0x10,%esp
	if (ret) {
  801ff9:	85 c0                	test   %eax,%eax
  801ffb:	74 16                	je     802013 <ipc_recv+0x4a>
		if (from_env_store) *from_env_store = 0;
  801ffd:	85 f6                	test   %esi,%esi
  801fff:	74 06                	je     802007 <ipc_recv+0x3e>
  802001:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  802007:	85 db                	test   %ebx,%ebx
  802009:	74 2c                	je     802037 <ipc_recv+0x6e>
  80200b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802011:	eb 24                	jmp    802037 <ipc_recv+0x6e>
		return ret;
	}
	if (from_env_store) *from_env_store = thisenv->env_ipc_from;
  802013:	85 f6                	test   %esi,%esi
  802015:	74 0a                	je     802021 <ipc_recv+0x58>
  802017:	a1 04 40 80 00       	mov    0x804004,%eax
  80201c:	8b 40 74             	mov    0x74(%eax),%eax
  80201f:	89 06                	mov    %eax,(%esi)
	if (perm_store) *perm_store = thisenv->env_ipc_perm;
  802021:	85 db                	test   %ebx,%ebx
  802023:	74 0a                	je     80202f <ipc_recv+0x66>
  802025:	a1 04 40 80 00       	mov    0x804004,%eax
  80202a:	8b 40 78             	mov    0x78(%eax),%eax
  80202d:	89 03                	mov    %eax,(%ebx)

	// panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  80202f:	a1 04 40 80 00       	mov    0x804004,%eax
  802034:	8b 40 70             	mov    0x70(%eax),%eax
}
  802037:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80203a:	5b                   	pop    %ebx
  80203b:	5e                   	pop    %esi
  80203c:	5d                   	pop    %ebp
  80203d:	c3                   	ret    

0080203e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80203e:	55                   	push   %ebp
  80203f:	89 e5                	mov    %esp,%ebp
  802041:	57                   	push   %edi
  802042:	56                   	push   %esi
  802043:	53                   	push   %ebx
  802044:	83 ec 0c             	sub    $0xc,%esp
  802047:	8b 7d 08             	mov    0x8(%ebp),%edi
  80204a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80204d:	8b 45 10             	mov    0x10(%ebp),%eax
  802050:	85 c0                	test   %eax,%eax
  802052:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  802057:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	while (true) {
		void* srcva = (pg)? pg: (void*)UTOP;
		int ret = sys_ipc_try_send(to_env, val, srcva, perm);
  80205a:	ff 75 14             	pushl  0x14(%ebp)
  80205d:	53                   	push   %ebx
  80205e:	56                   	push   %esi
  80205f:	57                   	push   %edi
  802060:	e8 c8 ee ff ff       	call   800f2d <sys_ipc_try_send>
		if (ret == 0) break;
  802065:	83 c4 10             	add    $0x10,%esp
  802068:	85 c0                	test   %eax,%eax
  80206a:	74 1e                	je     80208a <ipc_send+0x4c>
		if (ret != -E_IPC_NOT_RECV) panic("ipc_send: %e", ret);
  80206c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80206f:	74 12                	je     802083 <ipc_send+0x45>
  802071:	50                   	push   %eax
  802072:	68 93 29 80 00       	push   $0x802993
  802077:	6a 39                	push   $0x39
  802079:	68 a0 29 80 00       	push   $0x8029a0
  80207e:	e8 15 e2 ff ff       	call   800298 <_panic>
		sys_yield();
  802083:	e8 f9 ec ff ff       	call   800d81 <sys_yield>
	}
  802088:	eb d0                	jmp    80205a <ipc_send+0x1c>
	// panic("ipc_send not implemented");
}
  80208a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80208d:	5b                   	pop    %ebx
  80208e:	5e                   	pop    %esi
  80208f:	5f                   	pop    %edi
  802090:	5d                   	pop    %ebp
  802091:	c3                   	ret    

00802092 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802092:	55                   	push   %ebp
  802093:	89 e5                	mov    %esp,%ebp
  802095:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802098:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80209d:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8020a0:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8020a6:	8b 52 50             	mov    0x50(%edx),%edx
  8020a9:	39 ca                	cmp    %ecx,%edx
  8020ab:	75 0d                	jne    8020ba <ipc_find_env+0x28>
			return envs[i].env_id;
  8020ad:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8020b0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8020b5:	8b 40 48             	mov    0x48(%eax),%eax
  8020b8:	eb 0f                	jmp    8020c9 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8020ba:	83 c0 01             	add    $0x1,%eax
  8020bd:	3d 00 04 00 00       	cmp    $0x400,%eax
  8020c2:	75 d9                	jne    80209d <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8020c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8020c9:	5d                   	pop    %ebp
  8020ca:	c3                   	ret    

008020cb <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020cb:	55                   	push   %ebp
  8020cc:	89 e5                	mov    %esp,%ebp
  8020ce:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020d1:	89 d0                	mov    %edx,%eax
  8020d3:	c1 e8 16             	shr    $0x16,%eax
  8020d6:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8020dd:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020e2:	f6 c1 01             	test   $0x1,%cl
  8020e5:	74 1d                	je     802104 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8020e7:	c1 ea 0c             	shr    $0xc,%edx
  8020ea:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8020f1:	f6 c2 01             	test   $0x1,%dl
  8020f4:	74 0e                	je     802104 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020f6:	c1 ea 0c             	shr    $0xc,%edx
  8020f9:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802100:	ef 
  802101:	0f b7 c0             	movzwl %ax,%eax
}
  802104:	5d                   	pop    %ebp
  802105:	c3                   	ret    
  802106:	66 90                	xchg   %ax,%ax
  802108:	66 90                	xchg   %ax,%ax
  80210a:	66 90                	xchg   %ax,%ax
  80210c:	66 90                	xchg   %ax,%ax
  80210e:	66 90                	xchg   %ax,%ax

00802110 <__udivdi3>:
  802110:	55                   	push   %ebp
  802111:	57                   	push   %edi
  802112:	56                   	push   %esi
  802113:	53                   	push   %ebx
  802114:	83 ec 1c             	sub    $0x1c,%esp
  802117:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80211b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80211f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802123:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802127:	85 f6                	test   %esi,%esi
  802129:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80212d:	89 ca                	mov    %ecx,%edx
  80212f:	89 f8                	mov    %edi,%eax
  802131:	75 3d                	jne    802170 <__udivdi3+0x60>
  802133:	39 cf                	cmp    %ecx,%edi
  802135:	0f 87 c5 00 00 00    	ja     802200 <__udivdi3+0xf0>
  80213b:	85 ff                	test   %edi,%edi
  80213d:	89 fd                	mov    %edi,%ebp
  80213f:	75 0b                	jne    80214c <__udivdi3+0x3c>
  802141:	b8 01 00 00 00       	mov    $0x1,%eax
  802146:	31 d2                	xor    %edx,%edx
  802148:	f7 f7                	div    %edi
  80214a:	89 c5                	mov    %eax,%ebp
  80214c:	89 c8                	mov    %ecx,%eax
  80214e:	31 d2                	xor    %edx,%edx
  802150:	f7 f5                	div    %ebp
  802152:	89 c1                	mov    %eax,%ecx
  802154:	89 d8                	mov    %ebx,%eax
  802156:	89 cf                	mov    %ecx,%edi
  802158:	f7 f5                	div    %ebp
  80215a:	89 c3                	mov    %eax,%ebx
  80215c:	89 d8                	mov    %ebx,%eax
  80215e:	89 fa                	mov    %edi,%edx
  802160:	83 c4 1c             	add    $0x1c,%esp
  802163:	5b                   	pop    %ebx
  802164:	5e                   	pop    %esi
  802165:	5f                   	pop    %edi
  802166:	5d                   	pop    %ebp
  802167:	c3                   	ret    
  802168:	90                   	nop
  802169:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802170:	39 ce                	cmp    %ecx,%esi
  802172:	77 74                	ja     8021e8 <__udivdi3+0xd8>
  802174:	0f bd fe             	bsr    %esi,%edi
  802177:	83 f7 1f             	xor    $0x1f,%edi
  80217a:	0f 84 98 00 00 00    	je     802218 <__udivdi3+0x108>
  802180:	bb 20 00 00 00       	mov    $0x20,%ebx
  802185:	89 f9                	mov    %edi,%ecx
  802187:	89 c5                	mov    %eax,%ebp
  802189:	29 fb                	sub    %edi,%ebx
  80218b:	d3 e6                	shl    %cl,%esi
  80218d:	89 d9                	mov    %ebx,%ecx
  80218f:	d3 ed                	shr    %cl,%ebp
  802191:	89 f9                	mov    %edi,%ecx
  802193:	d3 e0                	shl    %cl,%eax
  802195:	09 ee                	or     %ebp,%esi
  802197:	89 d9                	mov    %ebx,%ecx
  802199:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80219d:	89 d5                	mov    %edx,%ebp
  80219f:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021a3:	d3 ed                	shr    %cl,%ebp
  8021a5:	89 f9                	mov    %edi,%ecx
  8021a7:	d3 e2                	shl    %cl,%edx
  8021a9:	89 d9                	mov    %ebx,%ecx
  8021ab:	d3 e8                	shr    %cl,%eax
  8021ad:	09 c2                	or     %eax,%edx
  8021af:	89 d0                	mov    %edx,%eax
  8021b1:	89 ea                	mov    %ebp,%edx
  8021b3:	f7 f6                	div    %esi
  8021b5:	89 d5                	mov    %edx,%ebp
  8021b7:	89 c3                	mov    %eax,%ebx
  8021b9:	f7 64 24 0c          	mull   0xc(%esp)
  8021bd:	39 d5                	cmp    %edx,%ebp
  8021bf:	72 10                	jb     8021d1 <__udivdi3+0xc1>
  8021c1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8021c5:	89 f9                	mov    %edi,%ecx
  8021c7:	d3 e6                	shl    %cl,%esi
  8021c9:	39 c6                	cmp    %eax,%esi
  8021cb:	73 07                	jae    8021d4 <__udivdi3+0xc4>
  8021cd:	39 d5                	cmp    %edx,%ebp
  8021cf:	75 03                	jne    8021d4 <__udivdi3+0xc4>
  8021d1:	83 eb 01             	sub    $0x1,%ebx
  8021d4:	31 ff                	xor    %edi,%edi
  8021d6:	89 d8                	mov    %ebx,%eax
  8021d8:	89 fa                	mov    %edi,%edx
  8021da:	83 c4 1c             	add    $0x1c,%esp
  8021dd:	5b                   	pop    %ebx
  8021de:	5e                   	pop    %esi
  8021df:	5f                   	pop    %edi
  8021e0:	5d                   	pop    %ebp
  8021e1:	c3                   	ret    
  8021e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021e8:	31 ff                	xor    %edi,%edi
  8021ea:	31 db                	xor    %ebx,%ebx
  8021ec:	89 d8                	mov    %ebx,%eax
  8021ee:	89 fa                	mov    %edi,%edx
  8021f0:	83 c4 1c             	add    $0x1c,%esp
  8021f3:	5b                   	pop    %ebx
  8021f4:	5e                   	pop    %esi
  8021f5:	5f                   	pop    %edi
  8021f6:	5d                   	pop    %ebp
  8021f7:	c3                   	ret    
  8021f8:	90                   	nop
  8021f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802200:	89 d8                	mov    %ebx,%eax
  802202:	f7 f7                	div    %edi
  802204:	31 ff                	xor    %edi,%edi
  802206:	89 c3                	mov    %eax,%ebx
  802208:	89 d8                	mov    %ebx,%eax
  80220a:	89 fa                	mov    %edi,%edx
  80220c:	83 c4 1c             	add    $0x1c,%esp
  80220f:	5b                   	pop    %ebx
  802210:	5e                   	pop    %esi
  802211:	5f                   	pop    %edi
  802212:	5d                   	pop    %ebp
  802213:	c3                   	ret    
  802214:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802218:	39 ce                	cmp    %ecx,%esi
  80221a:	72 0c                	jb     802228 <__udivdi3+0x118>
  80221c:	31 db                	xor    %ebx,%ebx
  80221e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802222:	0f 87 34 ff ff ff    	ja     80215c <__udivdi3+0x4c>
  802228:	bb 01 00 00 00       	mov    $0x1,%ebx
  80222d:	e9 2a ff ff ff       	jmp    80215c <__udivdi3+0x4c>
  802232:	66 90                	xchg   %ax,%ax
  802234:	66 90                	xchg   %ax,%ax
  802236:	66 90                	xchg   %ax,%ax
  802238:	66 90                	xchg   %ax,%ax
  80223a:	66 90                	xchg   %ax,%ax
  80223c:	66 90                	xchg   %ax,%ax
  80223e:	66 90                	xchg   %ax,%ax

00802240 <__umoddi3>:
  802240:	55                   	push   %ebp
  802241:	57                   	push   %edi
  802242:	56                   	push   %esi
  802243:	53                   	push   %ebx
  802244:	83 ec 1c             	sub    $0x1c,%esp
  802247:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80224b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80224f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802253:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802257:	85 d2                	test   %edx,%edx
  802259:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80225d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802261:	89 f3                	mov    %esi,%ebx
  802263:	89 3c 24             	mov    %edi,(%esp)
  802266:	89 74 24 04          	mov    %esi,0x4(%esp)
  80226a:	75 1c                	jne    802288 <__umoddi3+0x48>
  80226c:	39 f7                	cmp    %esi,%edi
  80226e:	76 50                	jbe    8022c0 <__umoddi3+0x80>
  802270:	89 c8                	mov    %ecx,%eax
  802272:	89 f2                	mov    %esi,%edx
  802274:	f7 f7                	div    %edi
  802276:	89 d0                	mov    %edx,%eax
  802278:	31 d2                	xor    %edx,%edx
  80227a:	83 c4 1c             	add    $0x1c,%esp
  80227d:	5b                   	pop    %ebx
  80227e:	5e                   	pop    %esi
  80227f:	5f                   	pop    %edi
  802280:	5d                   	pop    %ebp
  802281:	c3                   	ret    
  802282:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802288:	39 f2                	cmp    %esi,%edx
  80228a:	89 d0                	mov    %edx,%eax
  80228c:	77 52                	ja     8022e0 <__umoddi3+0xa0>
  80228e:	0f bd ea             	bsr    %edx,%ebp
  802291:	83 f5 1f             	xor    $0x1f,%ebp
  802294:	75 5a                	jne    8022f0 <__umoddi3+0xb0>
  802296:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80229a:	0f 82 e0 00 00 00    	jb     802380 <__umoddi3+0x140>
  8022a0:	39 0c 24             	cmp    %ecx,(%esp)
  8022a3:	0f 86 d7 00 00 00    	jbe    802380 <__umoddi3+0x140>
  8022a9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8022ad:	8b 54 24 04          	mov    0x4(%esp),%edx
  8022b1:	83 c4 1c             	add    $0x1c,%esp
  8022b4:	5b                   	pop    %ebx
  8022b5:	5e                   	pop    %esi
  8022b6:	5f                   	pop    %edi
  8022b7:	5d                   	pop    %ebp
  8022b8:	c3                   	ret    
  8022b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022c0:	85 ff                	test   %edi,%edi
  8022c2:	89 fd                	mov    %edi,%ebp
  8022c4:	75 0b                	jne    8022d1 <__umoddi3+0x91>
  8022c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8022cb:	31 d2                	xor    %edx,%edx
  8022cd:	f7 f7                	div    %edi
  8022cf:	89 c5                	mov    %eax,%ebp
  8022d1:	89 f0                	mov    %esi,%eax
  8022d3:	31 d2                	xor    %edx,%edx
  8022d5:	f7 f5                	div    %ebp
  8022d7:	89 c8                	mov    %ecx,%eax
  8022d9:	f7 f5                	div    %ebp
  8022db:	89 d0                	mov    %edx,%eax
  8022dd:	eb 99                	jmp    802278 <__umoddi3+0x38>
  8022df:	90                   	nop
  8022e0:	89 c8                	mov    %ecx,%eax
  8022e2:	89 f2                	mov    %esi,%edx
  8022e4:	83 c4 1c             	add    $0x1c,%esp
  8022e7:	5b                   	pop    %ebx
  8022e8:	5e                   	pop    %esi
  8022e9:	5f                   	pop    %edi
  8022ea:	5d                   	pop    %ebp
  8022eb:	c3                   	ret    
  8022ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022f0:	8b 34 24             	mov    (%esp),%esi
  8022f3:	bf 20 00 00 00       	mov    $0x20,%edi
  8022f8:	89 e9                	mov    %ebp,%ecx
  8022fa:	29 ef                	sub    %ebp,%edi
  8022fc:	d3 e0                	shl    %cl,%eax
  8022fe:	89 f9                	mov    %edi,%ecx
  802300:	89 f2                	mov    %esi,%edx
  802302:	d3 ea                	shr    %cl,%edx
  802304:	89 e9                	mov    %ebp,%ecx
  802306:	09 c2                	or     %eax,%edx
  802308:	89 d8                	mov    %ebx,%eax
  80230a:	89 14 24             	mov    %edx,(%esp)
  80230d:	89 f2                	mov    %esi,%edx
  80230f:	d3 e2                	shl    %cl,%edx
  802311:	89 f9                	mov    %edi,%ecx
  802313:	89 54 24 04          	mov    %edx,0x4(%esp)
  802317:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80231b:	d3 e8                	shr    %cl,%eax
  80231d:	89 e9                	mov    %ebp,%ecx
  80231f:	89 c6                	mov    %eax,%esi
  802321:	d3 e3                	shl    %cl,%ebx
  802323:	89 f9                	mov    %edi,%ecx
  802325:	89 d0                	mov    %edx,%eax
  802327:	d3 e8                	shr    %cl,%eax
  802329:	89 e9                	mov    %ebp,%ecx
  80232b:	09 d8                	or     %ebx,%eax
  80232d:	89 d3                	mov    %edx,%ebx
  80232f:	89 f2                	mov    %esi,%edx
  802331:	f7 34 24             	divl   (%esp)
  802334:	89 d6                	mov    %edx,%esi
  802336:	d3 e3                	shl    %cl,%ebx
  802338:	f7 64 24 04          	mull   0x4(%esp)
  80233c:	39 d6                	cmp    %edx,%esi
  80233e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802342:	89 d1                	mov    %edx,%ecx
  802344:	89 c3                	mov    %eax,%ebx
  802346:	72 08                	jb     802350 <__umoddi3+0x110>
  802348:	75 11                	jne    80235b <__umoddi3+0x11b>
  80234a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80234e:	73 0b                	jae    80235b <__umoddi3+0x11b>
  802350:	2b 44 24 04          	sub    0x4(%esp),%eax
  802354:	1b 14 24             	sbb    (%esp),%edx
  802357:	89 d1                	mov    %edx,%ecx
  802359:	89 c3                	mov    %eax,%ebx
  80235b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80235f:	29 da                	sub    %ebx,%edx
  802361:	19 ce                	sbb    %ecx,%esi
  802363:	89 f9                	mov    %edi,%ecx
  802365:	89 f0                	mov    %esi,%eax
  802367:	d3 e0                	shl    %cl,%eax
  802369:	89 e9                	mov    %ebp,%ecx
  80236b:	d3 ea                	shr    %cl,%edx
  80236d:	89 e9                	mov    %ebp,%ecx
  80236f:	d3 ee                	shr    %cl,%esi
  802371:	09 d0                	or     %edx,%eax
  802373:	89 f2                	mov    %esi,%edx
  802375:	83 c4 1c             	add    $0x1c,%esp
  802378:	5b                   	pop    %ebx
  802379:	5e                   	pop    %esi
  80237a:	5f                   	pop    %edi
  80237b:	5d                   	pop    %ebp
  80237c:	c3                   	ret    
  80237d:	8d 76 00             	lea    0x0(%esi),%esi
  802380:	29 f9                	sub    %edi,%ecx
  802382:	19 d6                	sbb    %edx,%esi
  802384:	89 74 24 04          	mov    %esi,0x4(%esp)
  802388:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80238c:	e9 18 ff ff ff       	jmp    8022a9 <__umoddi3+0x69>
