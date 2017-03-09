
obj/user/forktree.debug:     file format elf32-i386


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
  80002c:	e8 b0 00 00 00       	call   8000e1 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <forktree>:
	}
}

void
forktree(const char *cur)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 04             	sub    $0x4,%esp
  80003a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("%04x: I am '%s'\n", sys_getenvid(), cur);
  80003d:	e8 83 0b 00 00       	call   800bc5 <sys_getenvid>
  800042:	83 ec 04             	sub    $0x4,%esp
  800045:	53                   	push   %ebx
  800046:	50                   	push   %eax
  800047:	68 40 22 80 00       	push   $0x802240
  80004c:	e8 83 01 00 00       	call   8001d4 <cprintf>

	forkchild(cur, '0');
  800051:	83 c4 08             	add    $0x8,%esp
  800054:	6a 30                	push   $0x30
  800056:	53                   	push   %ebx
  800057:	e8 13 00 00 00       	call   80006f <forkchild>
	forkchild(cur, '1');
  80005c:	83 c4 08             	add    $0x8,%esp
  80005f:	6a 31                	push   $0x31
  800061:	53                   	push   %ebx
  800062:	e8 08 00 00 00       	call   80006f <forkchild>
}
  800067:	83 c4 10             	add    $0x10,%esp
  80006a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80006d:	c9                   	leave  
  80006e:	c3                   	ret    

0080006f <forkchild>:

void forktree(const char *cur);

void
forkchild(const char *cur, char branch)
{
  80006f:	55                   	push   %ebp
  800070:	89 e5                	mov    %esp,%ebp
  800072:	56                   	push   %esi
  800073:	53                   	push   %ebx
  800074:	83 ec 1c             	sub    $0x1c,%esp
  800077:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80007a:	8b 75 0c             	mov    0xc(%ebp),%esi
	char nxt[DEPTH+1];

	if (strlen(cur) >= DEPTH)
  80007d:	53                   	push   %ebx
  80007e:	e8 44 07 00 00       	call   8007c7 <strlen>
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	83 f8 02             	cmp    $0x2,%eax
  800089:	7f 3a                	jg     8000c5 <forkchild+0x56>
		return;

	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
  80008b:	83 ec 0c             	sub    $0xc,%esp
  80008e:	89 f0                	mov    %esi,%eax
  800090:	0f be f0             	movsbl %al,%esi
  800093:	56                   	push   %esi
  800094:	53                   	push   %ebx
  800095:	68 51 22 80 00       	push   $0x802251
  80009a:	6a 04                	push   $0x4
  80009c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80009f:	50                   	push   %eax
  8000a0:	e8 08 07 00 00       	call   8007ad <snprintf>
	if (fork() == 0) {
  8000a5:	83 c4 20             	add    $0x20,%esp
  8000a8:	e8 f4 0e 00 00       	call   800fa1 <fork>
  8000ad:	85 c0                	test   %eax,%eax
  8000af:	75 14                	jne    8000c5 <forkchild+0x56>
		forktree(nxt);
  8000b1:	83 ec 0c             	sub    $0xc,%esp
  8000b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000b7:	50                   	push   %eax
  8000b8:	e8 76 ff ff ff       	call   800033 <forktree>
		exit();
  8000bd:	e8 65 00 00 00       	call   800127 <exit>
  8000c2:	83 c4 10             	add    $0x10,%esp
	}
}
  8000c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000c8:	5b                   	pop    %ebx
  8000c9:	5e                   	pop    %esi
  8000ca:	5d                   	pop    %ebp
  8000cb:	c3                   	ret    

008000cc <umain>:
	forkchild(cur, '1');
}

void
umain(int argc, char **argv)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	83 ec 14             	sub    $0x14,%esp
	forktree("");
  8000d2:	68 50 22 80 00       	push   $0x802250
  8000d7:	e8 57 ff ff ff       	call   800033 <forktree>
}
  8000dc:	83 c4 10             	add    $0x10,%esp
  8000df:	c9                   	leave  
  8000e0:	c3                   	ret    

008000e1 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e1:	55                   	push   %ebp
  8000e2:	89 e5                	mov    %esp,%ebp
  8000e4:	56                   	push   %esi
  8000e5:	53                   	push   %ebx
  8000e6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000e9:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	envid_t envid = sys_getenvid();
  8000ec:	e8 d4 0a 00 00       	call   800bc5 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8000f1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000f9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000fe:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800103:	85 db                	test   %ebx,%ebx
  800105:	7e 07                	jle    80010e <libmain+0x2d>
		binaryname = argv[0];
  800107:	8b 06                	mov    (%esi),%eax
  800109:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80010e:	83 ec 08             	sub    $0x8,%esp
  800111:	56                   	push   %esi
  800112:	53                   	push   %ebx
  800113:	e8 b4 ff ff ff       	call   8000cc <umain>

	// exit gracefully
	exit();
  800118:	e8 0a 00 00 00       	call   800127 <exit>
}
  80011d:	83 c4 10             	add    $0x10,%esp
  800120:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800123:	5b                   	pop    %ebx
  800124:	5e                   	pop    %esi
  800125:	5d                   	pop    %ebp
  800126:	c3                   	ret    

00800127 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800127:	55                   	push   %ebp
  800128:	89 e5                	mov    %esp,%ebp
  80012a:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80012d:	e8 97 11 00 00       	call   8012c9 <close_all>
	sys_env_destroy(0);
  800132:	83 ec 0c             	sub    $0xc,%esp
  800135:	6a 00                	push   $0x0
  800137:	e8 48 0a 00 00       	call   800b84 <sys_env_destroy>
}
  80013c:	83 c4 10             	add    $0x10,%esp
  80013f:	c9                   	leave  
  800140:	c3                   	ret    

00800141 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800141:	55                   	push   %ebp
  800142:	89 e5                	mov    %esp,%ebp
  800144:	53                   	push   %ebx
  800145:	83 ec 04             	sub    $0x4,%esp
  800148:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80014b:	8b 13                	mov    (%ebx),%edx
  80014d:	8d 42 01             	lea    0x1(%edx),%eax
  800150:	89 03                	mov    %eax,(%ebx)
  800152:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800155:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800159:	3d ff 00 00 00       	cmp    $0xff,%eax
  80015e:	75 1a                	jne    80017a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800160:	83 ec 08             	sub    $0x8,%esp
  800163:	68 ff 00 00 00       	push   $0xff
  800168:	8d 43 08             	lea    0x8(%ebx),%eax
  80016b:	50                   	push   %eax
  80016c:	e8 d6 09 00 00       	call   800b47 <sys_cputs>
		b->idx = 0;
  800171:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800177:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80017a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80017e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800181:	c9                   	leave  
  800182:	c3                   	ret    

00800183 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800183:	55                   	push   %ebp
  800184:	89 e5                	mov    %esp,%ebp
  800186:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80018c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800193:	00 00 00 
	b.cnt = 0;
  800196:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80019d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001a0:	ff 75 0c             	pushl  0xc(%ebp)
  8001a3:	ff 75 08             	pushl  0x8(%ebp)
  8001a6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001ac:	50                   	push   %eax
  8001ad:	68 41 01 80 00       	push   $0x800141
  8001b2:	e8 1a 01 00 00       	call   8002d1 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001b7:	83 c4 08             	add    $0x8,%esp
  8001ba:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001c0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001c6:	50                   	push   %eax
  8001c7:	e8 7b 09 00 00       	call   800b47 <sys_cputs>

	return b.cnt;
}
  8001cc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001d2:	c9                   	leave  
  8001d3:	c3                   	ret    

008001d4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001d4:	55                   	push   %ebp
  8001d5:	89 e5                	mov    %esp,%ebp
  8001d7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001da:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001dd:	50                   	push   %eax
  8001de:	ff 75 08             	pushl  0x8(%ebp)
  8001e1:	e8 9d ff ff ff       	call   800183 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001e6:	c9                   	leave  
  8001e7:	c3                   	ret    

008001e8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001e8:	55                   	push   %ebp
  8001e9:	89 e5                	mov    %esp,%ebp
  8001eb:	57                   	push   %edi
  8001ec:	56                   	push   %esi
  8001ed:	53                   	push   %ebx
  8001ee:	83 ec 1c             	sub    $0x1c,%esp
  8001f1:	89 c7                	mov    %eax,%edi
  8001f3:	89 d6                	mov    %edx,%esi
  8001f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001f8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001fb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001fe:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800201:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800204:	bb 00 00 00 00       	mov    $0x0,%ebx
  800209:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80020c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80020f:	39 d3                	cmp    %edx,%ebx
  800211:	72 05                	jb     800218 <printnum+0x30>
  800213:	39 45 10             	cmp    %eax,0x10(%ebp)
  800216:	77 45                	ja     80025d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800218:	83 ec 0c             	sub    $0xc,%esp
  80021b:	ff 75 18             	pushl  0x18(%ebp)
  80021e:	8b 45 14             	mov    0x14(%ebp),%eax
  800221:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800224:	53                   	push   %ebx
  800225:	ff 75 10             	pushl  0x10(%ebp)
  800228:	83 ec 08             	sub    $0x8,%esp
  80022b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80022e:	ff 75 e0             	pushl  -0x20(%ebp)
  800231:	ff 75 dc             	pushl  -0x24(%ebp)
  800234:	ff 75 d8             	pushl  -0x28(%ebp)
  800237:	e8 74 1d 00 00       	call   801fb0 <__udivdi3>
  80023c:	83 c4 18             	add    $0x18,%esp
  80023f:	52                   	push   %edx
  800240:	50                   	push   %eax
  800241:	89 f2                	mov    %esi,%edx
  800243:	89 f8                	mov    %edi,%eax
  800245:	e8 9e ff ff ff       	call   8001e8 <printnum>
  80024a:	83 c4 20             	add    $0x20,%esp
  80024d:	eb 18                	jmp    800267 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80024f:	83 ec 08             	sub    $0x8,%esp
  800252:	56                   	push   %esi
  800253:	ff 75 18             	pushl  0x18(%ebp)
  800256:	ff d7                	call   *%edi
  800258:	83 c4 10             	add    $0x10,%esp
  80025b:	eb 03                	jmp    800260 <printnum+0x78>
  80025d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800260:	83 eb 01             	sub    $0x1,%ebx
  800263:	85 db                	test   %ebx,%ebx
  800265:	7f e8                	jg     80024f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800267:	83 ec 08             	sub    $0x8,%esp
  80026a:	56                   	push   %esi
  80026b:	83 ec 04             	sub    $0x4,%esp
  80026e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800271:	ff 75 e0             	pushl  -0x20(%ebp)
  800274:	ff 75 dc             	pushl  -0x24(%ebp)
  800277:	ff 75 d8             	pushl  -0x28(%ebp)
  80027a:	e8 61 1e 00 00       	call   8020e0 <__umoddi3>
  80027f:	83 c4 14             	add    $0x14,%esp
  800282:	0f be 80 60 22 80 00 	movsbl 0x802260(%eax),%eax
  800289:	50                   	push   %eax
  80028a:	ff d7                	call   *%edi
}
  80028c:	83 c4 10             	add    $0x10,%esp
  80028f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800292:	5b                   	pop    %ebx
  800293:	5e                   	pop    %esi
  800294:	5f                   	pop    %edi
  800295:	5d                   	pop    %ebp
  800296:	c3                   	ret    

00800297 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800297:	55                   	push   %ebp
  800298:	89 e5                	mov    %esp,%ebp
  80029a:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80029d:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002a1:	8b 10                	mov    (%eax),%edx
  8002a3:	3b 50 04             	cmp    0x4(%eax),%edx
  8002a6:	73 0a                	jae    8002b2 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002a8:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002ab:	89 08                	mov    %ecx,(%eax)
  8002ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b0:	88 02                	mov    %al,(%edx)
}
  8002b2:	5d                   	pop    %ebp
  8002b3:	c3                   	ret    

008002b4 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002b4:	55                   	push   %ebp
  8002b5:	89 e5                	mov    %esp,%ebp
  8002b7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002ba:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002bd:	50                   	push   %eax
  8002be:	ff 75 10             	pushl  0x10(%ebp)
  8002c1:	ff 75 0c             	pushl  0xc(%ebp)
  8002c4:	ff 75 08             	pushl  0x8(%ebp)
  8002c7:	e8 05 00 00 00       	call   8002d1 <vprintfmt>
	va_end(ap);
}
  8002cc:	83 c4 10             	add    $0x10,%esp
  8002cf:	c9                   	leave  
  8002d0:	c3                   	ret    

008002d1 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002d1:	55                   	push   %ebp
  8002d2:	89 e5                	mov    %esp,%ebp
  8002d4:	57                   	push   %edi
  8002d5:	56                   	push   %esi
  8002d6:	53                   	push   %ebx
  8002d7:	83 ec 2c             	sub    $0x2c,%esp
  8002da:	8b 75 08             	mov    0x8(%ebp),%esi
  8002dd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002e0:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002e3:	eb 12                	jmp    8002f7 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002e5:	85 c0                	test   %eax,%eax
  8002e7:	0f 84 6a 04 00 00    	je     800757 <vprintfmt+0x486>
				return;
			putch(ch, putdat);
  8002ed:	83 ec 08             	sub    $0x8,%esp
  8002f0:	53                   	push   %ebx
  8002f1:	50                   	push   %eax
  8002f2:	ff d6                	call   *%esi
  8002f4:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002f7:	83 c7 01             	add    $0x1,%edi
  8002fa:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002fe:	83 f8 25             	cmp    $0x25,%eax
  800301:	75 e2                	jne    8002e5 <vprintfmt+0x14>
  800303:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800307:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80030e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800315:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80031c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800321:	eb 07                	jmp    80032a <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800323:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800326:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80032a:	8d 47 01             	lea    0x1(%edi),%eax
  80032d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800330:	0f b6 07             	movzbl (%edi),%eax
  800333:	0f b6 d0             	movzbl %al,%edx
  800336:	83 e8 23             	sub    $0x23,%eax
  800339:	3c 55                	cmp    $0x55,%al
  80033b:	0f 87 fb 03 00 00    	ja     80073c <vprintfmt+0x46b>
  800341:	0f b6 c0             	movzbl %al,%eax
  800344:	ff 24 85 a0 23 80 00 	jmp    *0x8023a0(,%eax,4)
  80034b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80034e:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800352:	eb d6                	jmp    80032a <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800354:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800357:	b8 00 00 00 00       	mov    $0x0,%eax
  80035c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80035f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800362:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800366:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800369:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80036c:	83 f9 09             	cmp    $0x9,%ecx
  80036f:	77 3f                	ja     8003b0 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800371:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800374:	eb e9                	jmp    80035f <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800376:	8b 45 14             	mov    0x14(%ebp),%eax
  800379:	8b 00                	mov    (%eax),%eax
  80037b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80037e:	8b 45 14             	mov    0x14(%ebp),%eax
  800381:	8d 40 04             	lea    0x4(%eax),%eax
  800384:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800387:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80038a:	eb 2a                	jmp    8003b6 <vprintfmt+0xe5>
  80038c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80038f:	85 c0                	test   %eax,%eax
  800391:	ba 00 00 00 00       	mov    $0x0,%edx
  800396:	0f 49 d0             	cmovns %eax,%edx
  800399:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80039f:	eb 89                	jmp    80032a <vprintfmt+0x59>
  8003a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003a4:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003ab:	e9 7a ff ff ff       	jmp    80032a <vprintfmt+0x59>
  8003b0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003b3:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003b6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003ba:	0f 89 6a ff ff ff    	jns    80032a <vprintfmt+0x59>
				width = precision, precision = -1;
  8003c0:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003c3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003c6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003cd:	e9 58 ff ff ff       	jmp    80032a <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003d2:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003d8:	e9 4d ff ff ff       	jmp    80032a <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e0:	8d 78 04             	lea    0x4(%eax),%edi
  8003e3:	83 ec 08             	sub    $0x8,%esp
  8003e6:	53                   	push   %ebx
  8003e7:	ff 30                	pushl  (%eax)
  8003e9:	ff d6                	call   *%esi
			break;
  8003eb:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003ee:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003f4:	e9 fe fe ff ff       	jmp    8002f7 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fc:	8d 78 04             	lea    0x4(%eax),%edi
  8003ff:	8b 00                	mov    (%eax),%eax
  800401:	99                   	cltd   
  800402:	31 d0                	xor    %edx,%eax
  800404:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800406:	83 f8 0f             	cmp    $0xf,%eax
  800409:	7f 0b                	jg     800416 <vprintfmt+0x145>
  80040b:	8b 14 85 00 25 80 00 	mov    0x802500(,%eax,4),%edx
  800412:	85 d2                	test   %edx,%edx
  800414:	75 1b                	jne    800431 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800416:	50                   	push   %eax
  800417:	68 78 22 80 00       	push   $0x802278
  80041c:	53                   	push   %ebx
  80041d:	56                   	push   %esi
  80041e:	e8 91 fe ff ff       	call   8002b4 <printfmt>
  800423:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800426:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800429:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80042c:	e9 c6 fe ff ff       	jmp    8002f7 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800431:	52                   	push   %edx
  800432:	68 3a 27 80 00       	push   $0x80273a
  800437:	53                   	push   %ebx
  800438:	56                   	push   %esi
  800439:	e8 76 fe ff ff       	call   8002b4 <printfmt>
  80043e:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800441:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800444:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800447:	e9 ab fe ff ff       	jmp    8002f7 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80044c:	8b 45 14             	mov    0x14(%ebp),%eax
  80044f:	83 c0 04             	add    $0x4,%eax
  800452:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800455:	8b 45 14             	mov    0x14(%ebp),%eax
  800458:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80045a:	85 ff                	test   %edi,%edi
  80045c:	b8 71 22 80 00       	mov    $0x802271,%eax
  800461:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800464:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800468:	0f 8e 94 00 00 00    	jle    800502 <vprintfmt+0x231>
  80046e:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800472:	0f 84 98 00 00 00    	je     800510 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800478:	83 ec 08             	sub    $0x8,%esp
  80047b:	ff 75 d0             	pushl  -0x30(%ebp)
  80047e:	57                   	push   %edi
  80047f:	e8 5b 03 00 00       	call   8007df <strnlen>
  800484:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800487:	29 c1                	sub    %eax,%ecx
  800489:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80048c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80048f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800493:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800496:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800499:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80049b:	eb 0f                	jmp    8004ac <vprintfmt+0x1db>
					putch(padc, putdat);
  80049d:	83 ec 08             	sub    $0x8,%esp
  8004a0:	53                   	push   %ebx
  8004a1:	ff 75 e0             	pushl  -0x20(%ebp)
  8004a4:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a6:	83 ef 01             	sub    $0x1,%edi
  8004a9:	83 c4 10             	add    $0x10,%esp
  8004ac:	85 ff                	test   %edi,%edi
  8004ae:	7f ed                	jg     80049d <vprintfmt+0x1cc>
  8004b0:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004b3:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004b6:	85 c9                	test   %ecx,%ecx
  8004b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8004bd:	0f 49 c1             	cmovns %ecx,%eax
  8004c0:	29 c1                	sub    %eax,%ecx
  8004c2:	89 75 08             	mov    %esi,0x8(%ebp)
  8004c5:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004c8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004cb:	89 cb                	mov    %ecx,%ebx
  8004cd:	eb 4d                	jmp    80051c <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004cf:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004d3:	74 1b                	je     8004f0 <vprintfmt+0x21f>
  8004d5:	0f be c0             	movsbl %al,%eax
  8004d8:	83 e8 20             	sub    $0x20,%eax
  8004db:	83 f8 5e             	cmp    $0x5e,%eax
  8004de:	76 10                	jbe    8004f0 <vprintfmt+0x21f>
					putch('?', putdat);
  8004e0:	83 ec 08             	sub    $0x8,%esp
  8004e3:	ff 75 0c             	pushl  0xc(%ebp)
  8004e6:	6a 3f                	push   $0x3f
  8004e8:	ff 55 08             	call   *0x8(%ebp)
  8004eb:	83 c4 10             	add    $0x10,%esp
  8004ee:	eb 0d                	jmp    8004fd <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  8004f0:	83 ec 08             	sub    $0x8,%esp
  8004f3:	ff 75 0c             	pushl  0xc(%ebp)
  8004f6:	52                   	push   %edx
  8004f7:	ff 55 08             	call   *0x8(%ebp)
  8004fa:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004fd:	83 eb 01             	sub    $0x1,%ebx
  800500:	eb 1a                	jmp    80051c <vprintfmt+0x24b>
  800502:	89 75 08             	mov    %esi,0x8(%ebp)
  800505:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800508:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80050b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80050e:	eb 0c                	jmp    80051c <vprintfmt+0x24b>
  800510:	89 75 08             	mov    %esi,0x8(%ebp)
  800513:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800516:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800519:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80051c:	83 c7 01             	add    $0x1,%edi
  80051f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800523:	0f be d0             	movsbl %al,%edx
  800526:	85 d2                	test   %edx,%edx
  800528:	74 23                	je     80054d <vprintfmt+0x27c>
  80052a:	85 f6                	test   %esi,%esi
  80052c:	78 a1                	js     8004cf <vprintfmt+0x1fe>
  80052e:	83 ee 01             	sub    $0x1,%esi
  800531:	79 9c                	jns    8004cf <vprintfmt+0x1fe>
  800533:	89 df                	mov    %ebx,%edi
  800535:	8b 75 08             	mov    0x8(%ebp),%esi
  800538:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80053b:	eb 18                	jmp    800555 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80053d:	83 ec 08             	sub    $0x8,%esp
  800540:	53                   	push   %ebx
  800541:	6a 20                	push   $0x20
  800543:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800545:	83 ef 01             	sub    $0x1,%edi
  800548:	83 c4 10             	add    $0x10,%esp
  80054b:	eb 08                	jmp    800555 <vprintfmt+0x284>
  80054d:	89 df                	mov    %ebx,%edi
  80054f:	8b 75 08             	mov    0x8(%ebp),%esi
  800552:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800555:	85 ff                	test   %edi,%edi
  800557:	7f e4                	jg     80053d <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800559:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80055c:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800562:	e9 90 fd ff ff       	jmp    8002f7 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800567:	83 f9 01             	cmp    $0x1,%ecx
  80056a:	7e 19                	jle    800585 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  80056c:	8b 45 14             	mov    0x14(%ebp),%eax
  80056f:	8b 50 04             	mov    0x4(%eax),%edx
  800572:	8b 00                	mov    (%eax),%eax
  800574:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800577:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80057a:	8b 45 14             	mov    0x14(%ebp),%eax
  80057d:	8d 40 08             	lea    0x8(%eax),%eax
  800580:	89 45 14             	mov    %eax,0x14(%ebp)
  800583:	eb 38                	jmp    8005bd <vprintfmt+0x2ec>
	else if (lflag)
  800585:	85 c9                	test   %ecx,%ecx
  800587:	74 1b                	je     8005a4 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800589:	8b 45 14             	mov    0x14(%ebp),%eax
  80058c:	8b 00                	mov    (%eax),%eax
  80058e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800591:	89 c1                	mov    %eax,%ecx
  800593:	c1 f9 1f             	sar    $0x1f,%ecx
  800596:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800599:	8b 45 14             	mov    0x14(%ebp),%eax
  80059c:	8d 40 04             	lea    0x4(%eax),%eax
  80059f:	89 45 14             	mov    %eax,0x14(%ebp)
  8005a2:	eb 19                	jmp    8005bd <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8005a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a7:	8b 00                	mov    (%eax),%eax
  8005a9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ac:	89 c1                	mov    %eax,%ecx
  8005ae:	c1 f9 1f             	sar    $0x1f,%ecx
  8005b1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b7:	8d 40 04             	lea    0x4(%eax),%eax
  8005ba:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005bd:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005c0:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005c3:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005c8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005cc:	0f 89 36 01 00 00    	jns    800708 <vprintfmt+0x437>
				putch('-', putdat);
  8005d2:	83 ec 08             	sub    $0x8,%esp
  8005d5:	53                   	push   %ebx
  8005d6:	6a 2d                	push   $0x2d
  8005d8:	ff d6                	call   *%esi
				num = -(long long) num;
  8005da:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005dd:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005e0:	f7 da                	neg    %edx
  8005e2:	83 d1 00             	adc    $0x0,%ecx
  8005e5:	f7 d9                	neg    %ecx
  8005e7:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005ea:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ef:	e9 14 01 00 00       	jmp    800708 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005f4:	83 f9 01             	cmp    $0x1,%ecx
  8005f7:	7e 18                	jle    800611 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  8005f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fc:	8b 10                	mov    (%eax),%edx
  8005fe:	8b 48 04             	mov    0x4(%eax),%ecx
  800601:	8d 40 08             	lea    0x8(%eax),%eax
  800604:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800607:	b8 0a 00 00 00       	mov    $0xa,%eax
  80060c:	e9 f7 00 00 00       	jmp    800708 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800611:	85 c9                	test   %ecx,%ecx
  800613:	74 1a                	je     80062f <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  800615:	8b 45 14             	mov    0x14(%ebp),%eax
  800618:	8b 10                	mov    (%eax),%edx
  80061a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80061f:	8d 40 04             	lea    0x4(%eax),%eax
  800622:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800625:	b8 0a 00 00 00       	mov    $0xa,%eax
  80062a:	e9 d9 00 00 00       	jmp    800708 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80062f:	8b 45 14             	mov    0x14(%ebp),%eax
  800632:	8b 10                	mov    (%eax),%edx
  800634:	b9 00 00 00 00       	mov    $0x0,%ecx
  800639:	8d 40 04             	lea    0x4(%eax),%eax
  80063c:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80063f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800644:	e9 bf 00 00 00       	jmp    800708 <vprintfmt+0x437>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800649:	83 f9 01             	cmp    $0x1,%ecx
  80064c:	7e 13                	jle    800661 <vprintfmt+0x390>
		return va_arg(*ap, long long);
  80064e:	8b 45 14             	mov    0x14(%ebp),%eax
  800651:	8b 50 04             	mov    0x4(%eax),%edx
  800654:	8b 00                	mov    (%eax),%eax
  800656:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800659:	8d 49 08             	lea    0x8(%ecx),%ecx
  80065c:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80065f:	eb 28                	jmp    800689 <vprintfmt+0x3b8>
	else if (lflag)
  800661:	85 c9                	test   %ecx,%ecx
  800663:	74 13                	je     800678 <vprintfmt+0x3a7>
		return va_arg(*ap, long);
  800665:	8b 45 14             	mov    0x14(%ebp),%eax
  800668:	8b 10                	mov    (%eax),%edx
  80066a:	89 d0                	mov    %edx,%eax
  80066c:	99                   	cltd   
  80066d:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800670:	8d 49 04             	lea    0x4(%ecx),%ecx
  800673:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800676:	eb 11                	jmp    800689 <vprintfmt+0x3b8>
	else
		return va_arg(*ap, int);
  800678:	8b 45 14             	mov    0x14(%ebp),%eax
  80067b:	8b 10                	mov    (%eax),%edx
  80067d:	89 d0                	mov    %edx,%eax
  80067f:	99                   	cltd   
  800680:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800683:	8d 49 04             	lea    0x4(%ecx),%ecx
  800686:	89 4d 14             	mov    %ecx,0x14(%ebp)
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getint(&ap, lflag);
  800689:	89 d1                	mov    %edx,%ecx
  80068b:	89 c2                	mov    %eax,%edx
			base = 8;
  80068d:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800692:	eb 74                	jmp    800708 <vprintfmt+0x437>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800694:	83 ec 08             	sub    $0x8,%esp
  800697:	53                   	push   %ebx
  800698:	6a 30                	push   $0x30
  80069a:	ff d6                	call   *%esi
			putch('x', putdat);
  80069c:	83 c4 08             	add    $0x8,%esp
  80069f:	53                   	push   %ebx
  8006a0:	6a 78                	push   $0x78
  8006a2:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a7:	8b 10                	mov    (%eax),%edx
  8006a9:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006ae:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006b1:	8d 40 04             	lea    0x4(%eax),%eax
  8006b4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006b7:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006bc:	eb 4a                	jmp    800708 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006be:	83 f9 01             	cmp    $0x1,%ecx
  8006c1:	7e 15                	jle    8006d8 <vprintfmt+0x407>
		return va_arg(*ap, unsigned long long);
  8006c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c6:	8b 10                	mov    (%eax),%edx
  8006c8:	8b 48 04             	mov    0x4(%eax),%ecx
  8006cb:	8d 40 08             	lea    0x8(%eax),%eax
  8006ce:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006d1:	b8 10 00 00 00       	mov    $0x10,%eax
  8006d6:	eb 30                	jmp    800708 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8006d8:	85 c9                	test   %ecx,%ecx
  8006da:	74 17                	je     8006f3 <vprintfmt+0x422>
		return va_arg(*ap, unsigned long);
  8006dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006df:	8b 10                	mov    (%eax),%edx
  8006e1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006e6:	8d 40 04             	lea    0x4(%eax),%eax
  8006e9:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006ec:	b8 10 00 00 00       	mov    $0x10,%eax
  8006f1:	eb 15                	jmp    800708 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8006f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f6:	8b 10                	mov    (%eax),%edx
  8006f8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006fd:	8d 40 04             	lea    0x4(%eax),%eax
  800700:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800703:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800708:	83 ec 0c             	sub    $0xc,%esp
  80070b:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80070f:	57                   	push   %edi
  800710:	ff 75 e0             	pushl  -0x20(%ebp)
  800713:	50                   	push   %eax
  800714:	51                   	push   %ecx
  800715:	52                   	push   %edx
  800716:	89 da                	mov    %ebx,%edx
  800718:	89 f0                	mov    %esi,%eax
  80071a:	e8 c9 fa ff ff       	call   8001e8 <printnum>
			break;
  80071f:	83 c4 20             	add    $0x20,%esp
  800722:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800725:	e9 cd fb ff ff       	jmp    8002f7 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80072a:	83 ec 08             	sub    $0x8,%esp
  80072d:	53                   	push   %ebx
  80072e:	52                   	push   %edx
  80072f:	ff d6                	call   *%esi
			break;
  800731:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800734:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800737:	e9 bb fb ff ff       	jmp    8002f7 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80073c:	83 ec 08             	sub    $0x8,%esp
  80073f:	53                   	push   %ebx
  800740:	6a 25                	push   $0x25
  800742:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800744:	83 c4 10             	add    $0x10,%esp
  800747:	eb 03                	jmp    80074c <vprintfmt+0x47b>
  800749:	83 ef 01             	sub    $0x1,%edi
  80074c:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800750:	75 f7                	jne    800749 <vprintfmt+0x478>
  800752:	e9 a0 fb ff ff       	jmp    8002f7 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800757:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80075a:	5b                   	pop    %ebx
  80075b:	5e                   	pop    %esi
  80075c:	5f                   	pop    %edi
  80075d:	5d                   	pop    %ebp
  80075e:	c3                   	ret    

0080075f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80075f:	55                   	push   %ebp
  800760:	89 e5                	mov    %esp,%ebp
  800762:	83 ec 18             	sub    $0x18,%esp
  800765:	8b 45 08             	mov    0x8(%ebp),%eax
  800768:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80076b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80076e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800772:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800775:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80077c:	85 c0                	test   %eax,%eax
  80077e:	74 26                	je     8007a6 <vsnprintf+0x47>
  800780:	85 d2                	test   %edx,%edx
  800782:	7e 22                	jle    8007a6 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800784:	ff 75 14             	pushl  0x14(%ebp)
  800787:	ff 75 10             	pushl  0x10(%ebp)
  80078a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80078d:	50                   	push   %eax
  80078e:	68 97 02 80 00       	push   $0x800297
  800793:	e8 39 fb ff ff       	call   8002d1 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800798:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80079b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80079e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007a1:	83 c4 10             	add    $0x10,%esp
  8007a4:	eb 05                	jmp    8007ab <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007a6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007ab:	c9                   	leave  
  8007ac:	c3                   	ret    

008007ad <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007ad:	55                   	push   %ebp
  8007ae:	89 e5                	mov    %esp,%ebp
  8007b0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007b3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007b6:	50                   	push   %eax
  8007b7:	ff 75 10             	pushl  0x10(%ebp)
  8007ba:	ff 75 0c             	pushl  0xc(%ebp)
  8007bd:	ff 75 08             	pushl  0x8(%ebp)
  8007c0:	e8 9a ff ff ff       	call   80075f <vsnprintf>
	va_end(ap);

	return rc;
}
  8007c5:	c9                   	leave  
  8007c6:	c3                   	ret    

008007c7 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007c7:	55                   	push   %ebp
  8007c8:	89 e5                	mov    %esp,%ebp
  8007ca:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d2:	eb 03                	jmp    8007d7 <strlen+0x10>
		n++;
  8007d4:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007d7:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007db:	75 f7                	jne    8007d4 <strlen+0xd>
		n++;
	return n;
}
  8007dd:	5d                   	pop    %ebp
  8007de:	c3                   	ret    

008007df <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007df:	55                   	push   %ebp
  8007e0:	89 e5                	mov    %esp,%ebp
  8007e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007e5:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e8:	ba 00 00 00 00       	mov    $0x0,%edx
  8007ed:	eb 03                	jmp    8007f2 <strnlen+0x13>
		n++;
  8007ef:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007f2:	39 c2                	cmp    %eax,%edx
  8007f4:	74 08                	je     8007fe <strnlen+0x1f>
  8007f6:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007fa:	75 f3                	jne    8007ef <strnlen+0x10>
  8007fc:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007fe:	5d                   	pop    %ebp
  8007ff:	c3                   	ret    

00800800 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800800:	55                   	push   %ebp
  800801:	89 e5                	mov    %esp,%ebp
  800803:	53                   	push   %ebx
  800804:	8b 45 08             	mov    0x8(%ebp),%eax
  800807:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80080a:	89 c2                	mov    %eax,%edx
  80080c:	83 c2 01             	add    $0x1,%edx
  80080f:	83 c1 01             	add    $0x1,%ecx
  800812:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800816:	88 5a ff             	mov    %bl,-0x1(%edx)
  800819:	84 db                	test   %bl,%bl
  80081b:	75 ef                	jne    80080c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80081d:	5b                   	pop    %ebx
  80081e:	5d                   	pop    %ebp
  80081f:	c3                   	ret    

00800820 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800820:	55                   	push   %ebp
  800821:	89 e5                	mov    %esp,%ebp
  800823:	53                   	push   %ebx
  800824:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800827:	53                   	push   %ebx
  800828:	e8 9a ff ff ff       	call   8007c7 <strlen>
  80082d:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800830:	ff 75 0c             	pushl  0xc(%ebp)
  800833:	01 d8                	add    %ebx,%eax
  800835:	50                   	push   %eax
  800836:	e8 c5 ff ff ff       	call   800800 <strcpy>
	return dst;
}
  80083b:	89 d8                	mov    %ebx,%eax
  80083d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800840:	c9                   	leave  
  800841:	c3                   	ret    

00800842 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800842:	55                   	push   %ebp
  800843:	89 e5                	mov    %esp,%ebp
  800845:	56                   	push   %esi
  800846:	53                   	push   %ebx
  800847:	8b 75 08             	mov    0x8(%ebp),%esi
  80084a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80084d:	89 f3                	mov    %esi,%ebx
  80084f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800852:	89 f2                	mov    %esi,%edx
  800854:	eb 0f                	jmp    800865 <strncpy+0x23>
		*dst++ = *src;
  800856:	83 c2 01             	add    $0x1,%edx
  800859:	0f b6 01             	movzbl (%ecx),%eax
  80085c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80085f:	80 39 01             	cmpb   $0x1,(%ecx)
  800862:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800865:	39 da                	cmp    %ebx,%edx
  800867:	75 ed                	jne    800856 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800869:	89 f0                	mov    %esi,%eax
  80086b:	5b                   	pop    %ebx
  80086c:	5e                   	pop    %esi
  80086d:	5d                   	pop    %ebp
  80086e:	c3                   	ret    

0080086f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80086f:	55                   	push   %ebp
  800870:	89 e5                	mov    %esp,%ebp
  800872:	56                   	push   %esi
  800873:	53                   	push   %ebx
  800874:	8b 75 08             	mov    0x8(%ebp),%esi
  800877:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80087a:	8b 55 10             	mov    0x10(%ebp),%edx
  80087d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80087f:	85 d2                	test   %edx,%edx
  800881:	74 21                	je     8008a4 <strlcpy+0x35>
  800883:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800887:	89 f2                	mov    %esi,%edx
  800889:	eb 09                	jmp    800894 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80088b:	83 c2 01             	add    $0x1,%edx
  80088e:	83 c1 01             	add    $0x1,%ecx
  800891:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800894:	39 c2                	cmp    %eax,%edx
  800896:	74 09                	je     8008a1 <strlcpy+0x32>
  800898:	0f b6 19             	movzbl (%ecx),%ebx
  80089b:	84 db                	test   %bl,%bl
  80089d:	75 ec                	jne    80088b <strlcpy+0x1c>
  80089f:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008a1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008a4:	29 f0                	sub    %esi,%eax
}
  8008a6:	5b                   	pop    %ebx
  8008a7:	5e                   	pop    %esi
  8008a8:	5d                   	pop    %ebp
  8008a9:	c3                   	ret    

008008aa <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008aa:	55                   	push   %ebp
  8008ab:	89 e5                	mov    %esp,%ebp
  8008ad:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008b0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008b3:	eb 06                	jmp    8008bb <strcmp+0x11>
		p++, q++;
  8008b5:	83 c1 01             	add    $0x1,%ecx
  8008b8:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008bb:	0f b6 01             	movzbl (%ecx),%eax
  8008be:	84 c0                	test   %al,%al
  8008c0:	74 04                	je     8008c6 <strcmp+0x1c>
  8008c2:	3a 02                	cmp    (%edx),%al
  8008c4:	74 ef                	je     8008b5 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c6:	0f b6 c0             	movzbl %al,%eax
  8008c9:	0f b6 12             	movzbl (%edx),%edx
  8008cc:	29 d0                	sub    %edx,%eax
}
  8008ce:	5d                   	pop    %ebp
  8008cf:	c3                   	ret    

008008d0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008d0:	55                   	push   %ebp
  8008d1:	89 e5                	mov    %esp,%ebp
  8008d3:	53                   	push   %ebx
  8008d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008da:	89 c3                	mov    %eax,%ebx
  8008dc:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008df:	eb 06                	jmp    8008e7 <strncmp+0x17>
		n--, p++, q++;
  8008e1:	83 c0 01             	add    $0x1,%eax
  8008e4:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008e7:	39 d8                	cmp    %ebx,%eax
  8008e9:	74 15                	je     800900 <strncmp+0x30>
  8008eb:	0f b6 08             	movzbl (%eax),%ecx
  8008ee:	84 c9                	test   %cl,%cl
  8008f0:	74 04                	je     8008f6 <strncmp+0x26>
  8008f2:	3a 0a                	cmp    (%edx),%cl
  8008f4:	74 eb                	je     8008e1 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008f6:	0f b6 00             	movzbl (%eax),%eax
  8008f9:	0f b6 12             	movzbl (%edx),%edx
  8008fc:	29 d0                	sub    %edx,%eax
  8008fe:	eb 05                	jmp    800905 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800900:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800905:	5b                   	pop    %ebx
  800906:	5d                   	pop    %ebp
  800907:	c3                   	ret    

00800908 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800908:	55                   	push   %ebp
  800909:	89 e5                	mov    %esp,%ebp
  80090b:	8b 45 08             	mov    0x8(%ebp),%eax
  80090e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800912:	eb 07                	jmp    80091b <strchr+0x13>
		if (*s == c)
  800914:	38 ca                	cmp    %cl,%dl
  800916:	74 0f                	je     800927 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800918:	83 c0 01             	add    $0x1,%eax
  80091b:	0f b6 10             	movzbl (%eax),%edx
  80091e:	84 d2                	test   %dl,%dl
  800920:	75 f2                	jne    800914 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800922:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800927:	5d                   	pop    %ebp
  800928:	c3                   	ret    

00800929 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800929:	55                   	push   %ebp
  80092a:	89 e5                	mov    %esp,%ebp
  80092c:	8b 45 08             	mov    0x8(%ebp),%eax
  80092f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800933:	eb 03                	jmp    800938 <strfind+0xf>
  800935:	83 c0 01             	add    $0x1,%eax
  800938:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80093b:	38 ca                	cmp    %cl,%dl
  80093d:	74 04                	je     800943 <strfind+0x1a>
  80093f:	84 d2                	test   %dl,%dl
  800941:	75 f2                	jne    800935 <strfind+0xc>
			break;
	return (char *) s;
}
  800943:	5d                   	pop    %ebp
  800944:	c3                   	ret    

00800945 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800945:	55                   	push   %ebp
  800946:	89 e5                	mov    %esp,%ebp
  800948:	57                   	push   %edi
  800949:	56                   	push   %esi
  80094a:	53                   	push   %ebx
  80094b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80094e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800951:	85 c9                	test   %ecx,%ecx
  800953:	74 36                	je     80098b <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800955:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80095b:	75 28                	jne    800985 <memset+0x40>
  80095d:	f6 c1 03             	test   $0x3,%cl
  800960:	75 23                	jne    800985 <memset+0x40>
		c &= 0xFF;
  800962:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800966:	89 d3                	mov    %edx,%ebx
  800968:	c1 e3 08             	shl    $0x8,%ebx
  80096b:	89 d6                	mov    %edx,%esi
  80096d:	c1 e6 18             	shl    $0x18,%esi
  800970:	89 d0                	mov    %edx,%eax
  800972:	c1 e0 10             	shl    $0x10,%eax
  800975:	09 f0                	or     %esi,%eax
  800977:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800979:	89 d8                	mov    %ebx,%eax
  80097b:	09 d0                	or     %edx,%eax
  80097d:	c1 e9 02             	shr    $0x2,%ecx
  800980:	fc                   	cld    
  800981:	f3 ab                	rep stos %eax,%es:(%edi)
  800983:	eb 06                	jmp    80098b <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800985:	8b 45 0c             	mov    0xc(%ebp),%eax
  800988:	fc                   	cld    
  800989:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80098b:	89 f8                	mov    %edi,%eax
  80098d:	5b                   	pop    %ebx
  80098e:	5e                   	pop    %esi
  80098f:	5f                   	pop    %edi
  800990:	5d                   	pop    %ebp
  800991:	c3                   	ret    

00800992 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800992:	55                   	push   %ebp
  800993:	89 e5                	mov    %esp,%ebp
  800995:	57                   	push   %edi
  800996:	56                   	push   %esi
  800997:	8b 45 08             	mov    0x8(%ebp),%eax
  80099a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80099d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009a0:	39 c6                	cmp    %eax,%esi
  8009a2:	73 35                	jae    8009d9 <memmove+0x47>
  8009a4:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009a7:	39 d0                	cmp    %edx,%eax
  8009a9:	73 2e                	jae    8009d9 <memmove+0x47>
		s += n;
		d += n;
  8009ab:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ae:	89 d6                	mov    %edx,%esi
  8009b0:	09 fe                	or     %edi,%esi
  8009b2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009b8:	75 13                	jne    8009cd <memmove+0x3b>
  8009ba:	f6 c1 03             	test   $0x3,%cl
  8009bd:	75 0e                	jne    8009cd <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009bf:	83 ef 04             	sub    $0x4,%edi
  8009c2:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009c5:	c1 e9 02             	shr    $0x2,%ecx
  8009c8:	fd                   	std    
  8009c9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009cb:	eb 09                	jmp    8009d6 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009cd:	83 ef 01             	sub    $0x1,%edi
  8009d0:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009d3:	fd                   	std    
  8009d4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009d6:	fc                   	cld    
  8009d7:	eb 1d                	jmp    8009f6 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009d9:	89 f2                	mov    %esi,%edx
  8009db:	09 c2                	or     %eax,%edx
  8009dd:	f6 c2 03             	test   $0x3,%dl
  8009e0:	75 0f                	jne    8009f1 <memmove+0x5f>
  8009e2:	f6 c1 03             	test   $0x3,%cl
  8009e5:	75 0a                	jne    8009f1 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009e7:	c1 e9 02             	shr    $0x2,%ecx
  8009ea:	89 c7                	mov    %eax,%edi
  8009ec:	fc                   	cld    
  8009ed:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ef:	eb 05                	jmp    8009f6 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009f1:	89 c7                	mov    %eax,%edi
  8009f3:	fc                   	cld    
  8009f4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009f6:	5e                   	pop    %esi
  8009f7:	5f                   	pop    %edi
  8009f8:	5d                   	pop    %ebp
  8009f9:	c3                   	ret    

008009fa <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009fa:	55                   	push   %ebp
  8009fb:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009fd:	ff 75 10             	pushl  0x10(%ebp)
  800a00:	ff 75 0c             	pushl  0xc(%ebp)
  800a03:	ff 75 08             	pushl  0x8(%ebp)
  800a06:	e8 87 ff ff ff       	call   800992 <memmove>
}
  800a0b:	c9                   	leave  
  800a0c:	c3                   	ret    

00800a0d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a0d:	55                   	push   %ebp
  800a0e:	89 e5                	mov    %esp,%ebp
  800a10:	56                   	push   %esi
  800a11:	53                   	push   %ebx
  800a12:	8b 45 08             	mov    0x8(%ebp),%eax
  800a15:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a18:	89 c6                	mov    %eax,%esi
  800a1a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a1d:	eb 1a                	jmp    800a39 <memcmp+0x2c>
		if (*s1 != *s2)
  800a1f:	0f b6 08             	movzbl (%eax),%ecx
  800a22:	0f b6 1a             	movzbl (%edx),%ebx
  800a25:	38 d9                	cmp    %bl,%cl
  800a27:	74 0a                	je     800a33 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a29:	0f b6 c1             	movzbl %cl,%eax
  800a2c:	0f b6 db             	movzbl %bl,%ebx
  800a2f:	29 d8                	sub    %ebx,%eax
  800a31:	eb 0f                	jmp    800a42 <memcmp+0x35>
		s1++, s2++;
  800a33:	83 c0 01             	add    $0x1,%eax
  800a36:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a39:	39 f0                	cmp    %esi,%eax
  800a3b:	75 e2                	jne    800a1f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a3d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a42:	5b                   	pop    %ebx
  800a43:	5e                   	pop    %esi
  800a44:	5d                   	pop    %ebp
  800a45:	c3                   	ret    

00800a46 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a46:	55                   	push   %ebp
  800a47:	89 e5                	mov    %esp,%ebp
  800a49:	53                   	push   %ebx
  800a4a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a4d:	89 c1                	mov    %eax,%ecx
  800a4f:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a52:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a56:	eb 0a                	jmp    800a62 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a58:	0f b6 10             	movzbl (%eax),%edx
  800a5b:	39 da                	cmp    %ebx,%edx
  800a5d:	74 07                	je     800a66 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a5f:	83 c0 01             	add    $0x1,%eax
  800a62:	39 c8                	cmp    %ecx,%eax
  800a64:	72 f2                	jb     800a58 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a66:	5b                   	pop    %ebx
  800a67:	5d                   	pop    %ebp
  800a68:	c3                   	ret    

00800a69 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a69:	55                   	push   %ebp
  800a6a:	89 e5                	mov    %esp,%ebp
  800a6c:	57                   	push   %edi
  800a6d:	56                   	push   %esi
  800a6e:	53                   	push   %ebx
  800a6f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a72:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a75:	eb 03                	jmp    800a7a <strtol+0x11>
		s++;
  800a77:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a7a:	0f b6 01             	movzbl (%ecx),%eax
  800a7d:	3c 20                	cmp    $0x20,%al
  800a7f:	74 f6                	je     800a77 <strtol+0xe>
  800a81:	3c 09                	cmp    $0x9,%al
  800a83:	74 f2                	je     800a77 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a85:	3c 2b                	cmp    $0x2b,%al
  800a87:	75 0a                	jne    800a93 <strtol+0x2a>
		s++;
  800a89:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a8c:	bf 00 00 00 00       	mov    $0x0,%edi
  800a91:	eb 11                	jmp    800aa4 <strtol+0x3b>
  800a93:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a98:	3c 2d                	cmp    $0x2d,%al
  800a9a:	75 08                	jne    800aa4 <strtol+0x3b>
		s++, neg = 1;
  800a9c:	83 c1 01             	add    $0x1,%ecx
  800a9f:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aa4:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800aaa:	75 15                	jne    800ac1 <strtol+0x58>
  800aac:	80 39 30             	cmpb   $0x30,(%ecx)
  800aaf:	75 10                	jne    800ac1 <strtol+0x58>
  800ab1:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ab5:	75 7c                	jne    800b33 <strtol+0xca>
		s += 2, base = 16;
  800ab7:	83 c1 02             	add    $0x2,%ecx
  800aba:	bb 10 00 00 00       	mov    $0x10,%ebx
  800abf:	eb 16                	jmp    800ad7 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800ac1:	85 db                	test   %ebx,%ebx
  800ac3:	75 12                	jne    800ad7 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ac5:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aca:	80 39 30             	cmpb   $0x30,(%ecx)
  800acd:	75 08                	jne    800ad7 <strtol+0x6e>
		s++, base = 8;
  800acf:	83 c1 01             	add    $0x1,%ecx
  800ad2:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ad7:	b8 00 00 00 00       	mov    $0x0,%eax
  800adc:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800adf:	0f b6 11             	movzbl (%ecx),%edx
  800ae2:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ae5:	89 f3                	mov    %esi,%ebx
  800ae7:	80 fb 09             	cmp    $0x9,%bl
  800aea:	77 08                	ja     800af4 <strtol+0x8b>
			dig = *s - '0';
  800aec:	0f be d2             	movsbl %dl,%edx
  800aef:	83 ea 30             	sub    $0x30,%edx
  800af2:	eb 22                	jmp    800b16 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800af4:	8d 72 9f             	lea    -0x61(%edx),%esi
  800af7:	89 f3                	mov    %esi,%ebx
  800af9:	80 fb 19             	cmp    $0x19,%bl
  800afc:	77 08                	ja     800b06 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800afe:	0f be d2             	movsbl %dl,%edx
  800b01:	83 ea 57             	sub    $0x57,%edx
  800b04:	eb 10                	jmp    800b16 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b06:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b09:	89 f3                	mov    %esi,%ebx
  800b0b:	80 fb 19             	cmp    $0x19,%bl
  800b0e:	77 16                	ja     800b26 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b10:	0f be d2             	movsbl %dl,%edx
  800b13:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b16:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b19:	7d 0b                	jge    800b26 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b1b:	83 c1 01             	add    $0x1,%ecx
  800b1e:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b22:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b24:	eb b9                	jmp    800adf <strtol+0x76>

	if (endptr)
  800b26:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b2a:	74 0d                	je     800b39 <strtol+0xd0>
		*endptr = (char *) s;
  800b2c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b2f:	89 0e                	mov    %ecx,(%esi)
  800b31:	eb 06                	jmp    800b39 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b33:	85 db                	test   %ebx,%ebx
  800b35:	74 98                	je     800acf <strtol+0x66>
  800b37:	eb 9e                	jmp    800ad7 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b39:	89 c2                	mov    %eax,%edx
  800b3b:	f7 da                	neg    %edx
  800b3d:	85 ff                	test   %edi,%edi
  800b3f:	0f 45 c2             	cmovne %edx,%eax
}
  800b42:	5b                   	pop    %ebx
  800b43:	5e                   	pop    %esi
  800b44:	5f                   	pop    %edi
  800b45:	5d                   	pop    %ebp
  800b46:	c3                   	ret    

00800b47 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b47:	55                   	push   %ebp
  800b48:	89 e5                	mov    %esp,%ebp
  800b4a:	57                   	push   %edi
  800b4b:	56                   	push   %esi
  800b4c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b4d:	b8 00 00 00 00       	mov    $0x0,%eax
  800b52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b55:	8b 55 08             	mov    0x8(%ebp),%edx
  800b58:	89 c3                	mov    %eax,%ebx
  800b5a:	89 c7                	mov    %eax,%edi
  800b5c:	89 c6                	mov    %eax,%esi
  800b5e:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b60:	5b                   	pop    %ebx
  800b61:	5e                   	pop    %esi
  800b62:	5f                   	pop    %edi
  800b63:	5d                   	pop    %ebp
  800b64:	c3                   	ret    

00800b65 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b65:	55                   	push   %ebp
  800b66:	89 e5                	mov    %esp,%ebp
  800b68:	57                   	push   %edi
  800b69:	56                   	push   %esi
  800b6a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b6b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b70:	b8 01 00 00 00       	mov    $0x1,%eax
  800b75:	89 d1                	mov    %edx,%ecx
  800b77:	89 d3                	mov    %edx,%ebx
  800b79:	89 d7                	mov    %edx,%edi
  800b7b:	89 d6                	mov    %edx,%esi
  800b7d:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b7f:	5b                   	pop    %ebx
  800b80:	5e                   	pop    %esi
  800b81:	5f                   	pop    %edi
  800b82:	5d                   	pop    %ebp
  800b83:	c3                   	ret    

00800b84 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b84:	55                   	push   %ebp
  800b85:	89 e5                	mov    %esp,%ebp
  800b87:	57                   	push   %edi
  800b88:	56                   	push   %esi
  800b89:	53                   	push   %ebx
  800b8a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b92:	b8 03 00 00 00       	mov    $0x3,%eax
  800b97:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9a:	89 cb                	mov    %ecx,%ebx
  800b9c:	89 cf                	mov    %ecx,%edi
  800b9e:	89 ce                	mov    %ecx,%esi
  800ba0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ba2:	85 c0                	test   %eax,%eax
  800ba4:	7e 17                	jle    800bbd <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba6:	83 ec 0c             	sub    $0xc,%esp
  800ba9:	50                   	push   %eax
  800baa:	6a 03                	push   $0x3
  800bac:	68 5f 25 80 00       	push   $0x80255f
  800bb1:	6a 23                	push   $0x23
  800bb3:	68 7c 25 80 00       	push   $0x80257c
  800bb8:	e8 ff 11 00 00       	call   801dbc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bbd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc0:	5b                   	pop    %ebx
  800bc1:	5e                   	pop    %esi
  800bc2:	5f                   	pop    %edi
  800bc3:	5d                   	pop    %ebp
  800bc4:	c3                   	ret    

00800bc5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bc5:	55                   	push   %ebp
  800bc6:	89 e5                	mov    %esp,%ebp
  800bc8:	57                   	push   %edi
  800bc9:	56                   	push   %esi
  800bca:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bcb:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd0:	b8 02 00 00 00       	mov    $0x2,%eax
  800bd5:	89 d1                	mov    %edx,%ecx
  800bd7:	89 d3                	mov    %edx,%ebx
  800bd9:	89 d7                	mov    %edx,%edi
  800bdb:	89 d6                	mov    %edx,%esi
  800bdd:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bdf:	5b                   	pop    %ebx
  800be0:	5e                   	pop    %esi
  800be1:	5f                   	pop    %edi
  800be2:	5d                   	pop    %ebp
  800be3:	c3                   	ret    

00800be4 <sys_yield>:

void
sys_yield(void)
{
  800be4:	55                   	push   %ebp
  800be5:	89 e5                	mov    %esp,%ebp
  800be7:	57                   	push   %edi
  800be8:	56                   	push   %esi
  800be9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bea:	ba 00 00 00 00       	mov    $0x0,%edx
  800bef:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bf4:	89 d1                	mov    %edx,%ecx
  800bf6:	89 d3                	mov    %edx,%ebx
  800bf8:	89 d7                	mov    %edx,%edi
  800bfa:	89 d6                	mov    %edx,%esi
  800bfc:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bfe:	5b                   	pop    %ebx
  800bff:	5e                   	pop    %esi
  800c00:	5f                   	pop    %edi
  800c01:	5d                   	pop    %ebp
  800c02:	c3                   	ret    

00800c03 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c03:	55                   	push   %ebp
  800c04:	89 e5                	mov    %esp,%ebp
  800c06:	57                   	push   %edi
  800c07:	56                   	push   %esi
  800c08:	53                   	push   %ebx
  800c09:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0c:	be 00 00 00 00       	mov    $0x0,%esi
  800c11:	b8 04 00 00 00       	mov    $0x4,%eax
  800c16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c19:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c1f:	89 f7                	mov    %esi,%edi
  800c21:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c23:	85 c0                	test   %eax,%eax
  800c25:	7e 17                	jle    800c3e <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c27:	83 ec 0c             	sub    $0xc,%esp
  800c2a:	50                   	push   %eax
  800c2b:	6a 04                	push   $0x4
  800c2d:	68 5f 25 80 00       	push   $0x80255f
  800c32:	6a 23                	push   $0x23
  800c34:	68 7c 25 80 00       	push   $0x80257c
  800c39:	e8 7e 11 00 00       	call   801dbc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c41:	5b                   	pop    %ebx
  800c42:	5e                   	pop    %esi
  800c43:	5f                   	pop    %edi
  800c44:	5d                   	pop    %ebp
  800c45:	c3                   	ret    

00800c46 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c46:	55                   	push   %ebp
  800c47:	89 e5                	mov    %esp,%ebp
  800c49:	57                   	push   %edi
  800c4a:	56                   	push   %esi
  800c4b:	53                   	push   %ebx
  800c4c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4f:	b8 05 00 00 00       	mov    $0x5,%eax
  800c54:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c57:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c5d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c60:	8b 75 18             	mov    0x18(%ebp),%esi
  800c63:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c65:	85 c0                	test   %eax,%eax
  800c67:	7e 17                	jle    800c80 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c69:	83 ec 0c             	sub    $0xc,%esp
  800c6c:	50                   	push   %eax
  800c6d:	6a 05                	push   $0x5
  800c6f:	68 5f 25 80 00       	push   $0x80255f
  800c74:	6a 23                	push   $0x23
  800c76:	68 7c 25 80 00       	push   $0x80257c
  800c7b:	e8 3c 11 00 00       	call   801dbc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c83:	5b                   	pop    %ebx
  800c84:	5e                   	pop    %esi
  800c85:	5f                   	pop    %edi
  800c86:	5d                   	pop    %ebp
  800c87:	c3                   	ret    

00800c88 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c88:	55                   	push   %ebp
  800c89:	89 e5                	mov    %esp,%ebp
  800c8b:	57                   	push   %edi
  800c8c:	56                   	push   %esi
  800c8d:	53                   	push   %ebx
  800c8e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c91:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c96:	b8 06 00 00 00       	mov    $0x6,%eax
  800c9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca1:	89 df                	mov    %ebx,%edi
  800ca3:	89 de                	mov    %ebx,%esi
  800ca5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ca7:	85 c0                	test   %eax,%eax
  800ca9:	7e 17                	jle    800cc2 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cab:	83 ec 0c             	sub    $0xc,%esp
  800cae:	50                   	push   %eax
  800caf:	6a 06                	push   $0x6
  800cb1:	68 5f 25 80 00       	push   $0x80255f
  800cb6:	6a 23                	push   $0x23
  800cb8:	68 7c 25 80 00       	push   $0x80257c
  800cbd:	e8 fa 10 00 00       	call   801dbc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cc2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc5:	5b                   	pop    %ebx
  800cc6:	5e                   	pop    %esi
  800cc7:	5f                   	pop    %edi
  800cc8:	5d                   	pop    %ebp
  800cc9:	c3                   	ret    

00800cca <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cca:	55                   	push   %ebp
  800ccb:	89 e5                	mov    %esp,%ebp
  800ccd:	57                   	push   %edi
  800cce:	56                   	push   %esi
  800ccf:	53                   	push   %ebx
  800cd0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd8:	b8 08 00 00 00       	mov    $0x8,%eax
  800cdd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce3:	89 df                	mov    %ebx,%edi
  800ce5:	89 de                	mov    %ebx,%esi
  800ce7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ce9:	85 c0                	test   %eax,%eax
  800ceb:	7e 17                	jle    800d04 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ced:	83 ec 0c             	sub    $0xc,%esp
  800cf0:	50                   	push   %eax
  800cf1:	6a 08                	push   $0x8
  800cf3:	68 5f 25 80 00       	push   $0x80255f
  800cf8:	6a 23                	push   $0x23
  800cfa:	68 7c 25 80 00       	push   $0x80257c
  800cff:	e8 b8 10 00 00       	call   801dbc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d04:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d07:	5b                   	pop    %ebx
  800d08:	5e                   	pop    %esi
  800d09:	5f                   	pop    %edi
  800d0a:	5d                   	pop    %ebp
  800d0b:	c3                   	ret    

00800d0c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d0c:	55                   	push   %ebp
  800d0d:	89 e5                	mov    %esp,%ebp
  800d0f:	57                   	push   %edi
  800d10:	56                   	push   %esi
  800d11:	53                   	push   %ebx
  800d12:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d15:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d1a:	b8 09 00 00 00       	mov    $0x9,%eax
  800d1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d22:	8b 55 08             	mov    0x8(%ebp),%edx
  800d25:	89 df                	mov    %ebx,%edi
  800d27:	89 de                	mov    %ebx,%esi
  800d29:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d2b:	85 c0                	test   %eax,%eax
  800d2d:	7e 17                	jle    800d46 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2f:	83 ec 0c             	sub    $0xc,%esp
  800d32:	50                   	push   %eax
  800d33:	6a 09                	push   $0x9
  800d35:	68 5f 25 80 00       	push   $0x80255f
  800d3a:	6a 23                	push   $0x23
  800d3c:	68 7c 25 80 00       	push   $0x80257c
  800d41:	e8 76 10 00 00       	call   801dbc <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d46:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d49:	5b                   	pop    %ebx
  800d4a:	5e                   	pop    %esi
  800d4b:	5f                   	pop    %edi
  800d4c:	5d                   	pop    %ebp
  800d4d:	c3                   	ret    

00800d4e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d4e:	55                   	push   %ebp
  800d4f:	89 e5                	mov    %esp,%ebp
  800d51:	57                   	push   %edi
  800d52:	56                   	push   %esi
  800d53:	53                   	push   %ebx
  800d54:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d57:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d5c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d61:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d64:	8b 55 08             	mov    0x8(%ebp),%edx
  800d67:	89 df                	mov    %ebx,%edi
  800d69:	89 de                	mov    %ebx,%esi
  800d6b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d6d:	85 c0                	test   %eax,%eax
  800d6f:	7e 17                	jle    800d88 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d71:	83 ec 0c             	sub    $0xc,%esp
  800d74:	50                   	push   %eax
  800d75:	6a 0a                	push   $0xa
  800d77:	68 5f 25 80 00       	push   $0x80255f
  800d7c:	6a 23                	push   $0x23
  800d7e:	68 7c 25 80 00       	push   $0x80257c
  800d83:	e8 34 10 00 00       	call   801dbc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d88:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d8b:	5b                   	pop    %ebx
  800d8c:	5e                   	pop    %esi
  800d8d:	5f                   	pop    %edi
  800d8e:	5d                   	pop    %ebp
  800d8f:	c3                   	ret    

00800d90 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d90:	55                   	push   %ebp
  800d91:	89 e5                	mov    %esp,%ebp
  800d93:	57                   	push   %edi
  800d94:	56                   	push   %esi
  800d95:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d96:	be 00 00 00 00       	mov    $0x0,%esi
  800d9b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800da0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da3:	8b 55 08             	mov    0x8(%ebp),%edx
  800da6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800da9:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dac:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dae:	5b                   	pop    %ebx
  800daf:	5e                   	pop    %esi
  800db0:	5f                   	pop    %edi
  800db1:	5d                   	pop    %ebp
  800db2:	c3                   	ret    

00800db3 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800db3:	55                   	push   %ebp
  800db4:	89 e5                	mov    %esp,%ebp
  800db6:	57                   	push   %edi
  800db7:	56                   	push   %esi
  800db8:	53                   	push   %ebx
  800db9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dbc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dc1:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dc6:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc9:	89 cb                	mov    %ecx,%ebx
  800dcb:	89 cf                	mov    %ecx,%edi
  800dcd:	89 ce                	mov    %ecx,%esi
  800dcf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dd1:	85 c0                	test   %eax,%eax
  800dd3:	7e 17                	jle    800dec <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd5:	83 ec 0c             	sub    $0xc,%esp
  800dd8:	50                   	push   %eax
  800dd9:	6a 0d                	push   $0xd
  800ddb:	68 5f 25 80 00       	push   $0x80255f
  800de0:	6a 23                	push   $0x23
  800de2:	68 7c 25 80 00       	push   $0x80257c
  800de7:	e8 d0 0f 00 00       	call   801dbc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800def:	5b                   	pop    %ebx
  800df0:	5e                   	pop    %esi
  800df1:	5f                   	pop    %edi
  800df2:	5d                   	pop    %ebp
  800df3:	c3                   	ret    

00800df4 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800df4:	55                   	push   %ebp
  800df5:	89 e5                	mov    %esp,%ebp
  800df7:	53                   	push   %ebx
  800df8:	83 ec 04             	sub    $0x4,%esp
  800dfb:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800dfe:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & 
  800e00:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e04:	0f 84 48 01 00 00    	je     800f52 <pgfault+0x15e>
  800e0a:	89 d8                	mov    %ebx,%eax
  800e0c:	c1 e8 16             	shr    $0x16,%eax
  800e0f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e16:	a8 01                	test   $0x1,%al
  800e18:	0f 84 5f 01 00 00    	je     800f7d <pgfault+0x189>
  800e1e:	89 d8                	mov    %ebx,%eax
  800e20:	c1 e8 0c             	shr    $0xc,%eax
  800e23:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800e2a:	f6 c2 01             	test   $0x1,%dl
  800e2d:	0f 84 4a 01 00 00    	je     800f7d <pgfault+0x189>
				PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW))) {
  800e33:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & 
  800e3a:	f6 c4 08             	test   $0x8,%ah
  800e3d:	75 79                	jne    800eb8 <pgfault+0xc4>
  800e3f:	e9 39 01 00 00       	jmp    800f7d <pgfault+0x189>
				PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW))) {
		cprintf("Fault address = %08x, envid = %08x\n", addr, thisenv->env_id);
		if (!(err & FEC_WR)) cprintf("Not write\n");
		if (!(uvpd[PDX(addr)] & PTE_P)) cprintf("PDE not present\n");
  800e44:	89 d8                	mov    %ebx,%eax
  800e46:	c1 e8 16             	shr    $0x16,%eax
  800e49:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e50:	a8 01                	test   $0x1,%al
  800e52:	75 10                	jne    800e64 <pgfault+0x70>
  800e54:	83 ec 0c             	sub    $0xc,%esp
  800e57:	68 8a 25 80 00       	push   $0x80258a
  800e5c:	e8 73 f3 ff ff       	call   8001d4 <cprintf>
  800e61:	83 c4 10             	add    $0x10,%esp
		if (!(uvpt[PTX(addr)] & PTE_P)) cprintf("PTE not present\n");
  800e64:	c1 eb 0c             	shr    $0xc,%ebx
  800e67:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  800e6d:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800e74:	a8 01                	test   $0x1,%al
  800e76:	75 10                	jne    800e88 <pgfault+0x94>
  800e78:	83 ec 0c             	sub    $0xc,%esp
  800e7b:	68 9b 25 80 00       	push   $0x80259b
  800e80:	e8 4f f3 ff ff       	call   8001d4 <cprintf>
  800e85:	83 c4 10             	add    $0x10,%esp
		if (!(uvpt[PTX(addr)] & PTE_COW)) cprintf("Not copy-on-write\n");
  800e88:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800e8f:	f6 c4 08             	test   $0x8,%ah
  800e92:	75 10                	jne    800ea4 <pgfault+0xb0>
  800e94:	83 ec 0c             	sub    $0xc,%esp
  800e97:	68 ac 25 80 00       	push   $0x8025ac
  800e9c:	e8 33 f3 ff ff       	call   8001d4 <cprintf>
  800ea1:	83 c4 10             	add    $0x10,%esp
		panic("User page fault");
  800ea4:	83 ec 04             	sub    $0x4,%esp
  800ea7:	68 bf 25 80 00       	push   $0x8025bf
  800eac:	6a 23                	push   $0x23
  800eae:	68 cf 25 80 00       	push   $0x8025cf
  800eb3:	e8 04 0f 00 00       	call   801dbc <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// 0 refers to curenv
	if ((r = sys_page_alloc(0, (void*)PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  800eb8:	83 ec 04             	sub    $0x4,%esp
  800ebb:	6a 07                	push   $0x7
  800ebd:	68 00 f0 7f 00       	push   $0x7ff000
  800ec2:	6a 00                	push   $0x0
  800ec4:	e8 3a fd ff ff       	call   800c03 <sys_page_alloc>
  800ec9:	83 c4 10             	add    $0x10,%esp
  800ecc:	85 c0                	test   %eax,%eax
  800ece:	79 12                	jns    800ee2 <pgfault+0xee>
		panic("sys_page_alloc failed: %e", r);
  800ed0:	50                   	push   %eax
  800ed1:	68 da 25 80 00       	push   $0x8025da
  800ed6:	6a 2f                	push   $0x2f
  800ed8:	68 cf 25 80 00       	push   $0x8025cf
  800edd:	e8 da 0e 00 00       	call   801dbc <_panic>
	memcpy((void*)PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  800ee2:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800ee8:	83 ec 04             	sub    $0x4,%esp
  800eeb:	68 00 10 00 00       	push   $0x1000
  800ef0:	53                   	push   %ebx
  800ef1:	68 00 f0 7f 00       	push   $0x7ff000
  800ef6:	e8 ff fa ff ff       	call   8009fa <memcpy>
	if ((r = sys_page_map(0, (void*)PFTEMP, 0, (void*)ROUNDDOWN(addr, PGSIZE), 
  800efb:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f02:	53                   	push   %ebx
  800f03:	6a 00                	push   $0x0
  800f05:	68 00 f0 7f 00       	push   $0x7ff000
  800f0a:	6a 00                	push   $0x0
  800f0c:	e8 35 fd ff ff       	call   800c46 <sys_page_map>
  800f11:	83 c4 20             	add    $0x20,%esp
  800f14:	85 c0                	test   %eax,%eax
  800f16:	79 12                	jns    800f2a <pgfault+0x136>
					PTE_P | PTE_U | PTE_W)) < 0)
		panic("sys_page_map failed: %e", r);
  800f18:	50                   	push   %eax
  800f19:	68 f4 25 80 00       	push   $0x8025f4
  800f1e:	6a 33                	push   $0x33
  800f20:	68 cf 25 80 00       	push   $0x8025cf
  800f25:	e8 92 0e 00 00       	call   801dbc <_panic>
	if ((r = sys_page_unmap(0, (void*)PFTEMP)) < 0)
  800f2a:	83 ec 08             	sub    $0x8,%esp
  800f2d:	68 00 f0 7f 00       	push   $0x7ff000
  800f32:	6a 00                	push   $0x0
  800f34:	e8 4f fd ff ff       	call   800c88 <sys_page_unmap>
  800f39:	83 c4 10             	add    $0x10,%esp
  800f3c:	85 c0                	test   %eax,%eax
  800f3e:	79 5c                	jns    800f9c <pgfault+0x1a8>
		panic("sys_page_unmap failed: %e", r);
  800f40:	50                   	push   %eax
  800f41:	68 0c 26 80 00       	push   $0x80260c
  800f46:	6a 35                	push   $0x35
  800f48:	68 cf 25 80 00       	push   $0x8025cf
  800f4d:	e8 6a 0e 00 00       	call   801dbc <_panic>
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & 
				PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW))) {
		cprintf("Fault address = %08x, envid = %08x\n", addr, thisenv->env_id);
  800f52:	a1 04 40 80 00       	mov    0x804004,%eax
  800f57:	8b 40 48             	mov    0x48(%eax),%eax
  800f5a:	83 ec 04             	sub    $0x4,%esp
  800f5d:	50                   	push   %eax
  800f5e:	53                   	push   %ebx
  800f5f:	68 48 26 80 00       	push   $0x802648
  800f64:	e8 6b f2 ff ff       	call   8001d4 <cprintf>
		if (!(err & FEC_WR)) cprintf("Not write\n");
  800f69:	c7 04 24 26 26 80 00 	movl   $0x802626,(%esp)
  800f70:	e8 5f f2 ff ff       	call   8001d4 <cprintf>
  800f75:	83 c4 10             	add    $0x10,%esp
  800f78:	e9 c7 fe ff ff       	jmp    800e44 <pgfault+0x50>
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & 
				PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW))) {
		cprintf("Fault address = %08x, envid = %08x\n", addr, thisenv->env_id);
  800f7d:	a1 04 40 80 00       	mov    0x804004,%eax
  800f82:	8b 40 48             	mov    0x48(%eax),%eax
  800f85:	83 ec 04             	sub    $0x4,%esp
  800f88:	50                   	push   %eax
  800f89:	53                   	push   %ebx
  800f8a:	68 48 26 80 00       	push   $0x802648
  800f8f:	e8 40 f2 ff ff       	call   8001d4 <cprintf>
  800f94:	83 c4 10             	add    $0x10,%esp
  800f97:	e9 a8 fe ff ff       	jmp    800e44 <pgfault+0x50>
		panic("sys_page_map failed: %e", r);
	if ((r = sys_page_unmap(0, (void*)PFTEMP)) < 0)
		panic("sys_page_unmap failed: %e", r);

	// panic("pgfault not implemented");
}
  800f9c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f9f:	c9                   	leave  
  800fa0:	c3                   	ret    

00800fa1 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fa1:	55                   	push   %ebp
  800fa2:	89 e5                	mov    %esp,%ebp
  800fa4:	57                   	push   %edi
  800fa5:	56                   	push   %esi
  800fa6:	53                   	push   %ebx
  800fa7:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	int ret;
	set_pgfault_handler(pgfault);
  800faa:	68 f4 0d 80 00       	push   $0x800df4
  800faf:	e8 4e 0e 00 00       	call   801e02 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800fb4:	b8 07 00 00 00       	mov    $0x7,%eax
  800fb9:	cd 30                	int    $0x30
  800fbb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800fbe:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	envid_t envid = sys_exofork();

	if (envid < 0) return envid;
  800fc1:	83 c4 10             	add    $0x10,%esp
  800fc4:	85 c0                	test   %eax,%eax
  800fc6:	0f 88 0d 01 00 00    	js     8010d9 <fork+0x138>
  800fcc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fd1:	be 00 00 00 00       	mov    $0x0,%esi
	else if (envid == 0) {
  800fd6:	85 c0                	test   %eax,%eax
  800fd8:	75 2f                	jne    801009 <fork+0x68>
		// Child returns
		thisenv = &envs[ENVX(sys_getenvid())];
  800fda:	e8 e6 fb ff ff       	call   800bc5 <sys_getenvid>
  800fdf:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fe4:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800fe7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fec:	a3 04 40 80 00       	mov    %eax,0x804004
		// set_pgfault_handler(pgfault);
		return 0;
  800ff1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ff6:	e9 e1 00 00 00       	jmp    8010dc <fork+0x13b>
  800ffb:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
	}
	else {
		uint32_t pn;
		for (pn = 0; pn * PGSIZE < UTOP; pn++){
			// cprintf("virtual page %08x\n", pn * PGSIZE);
			if (pn * PGSIZE == UXSTACKTOP - PGSIZE) 
  801001:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801007:	74 77                	je     801080 <fork+0xdf>
{
	int r;

	// LAB 4: Your code here.
	int perm = PTE_P | PTE_U;
	pde_t pde = uvpd[pn / NPTENTRIES];
  801009:	89 f0                	mov    %esi,%eax
  80100b:	c1 e8 0a             	shr    $0xa,%eax
  80100e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
	if (!(pde & PTE_P)) return 0;
  801015:	a8 01                	test   $0x1,%al
  801017:	74 0b                	je     801024 <fork+0x83>
	pte_t pte = uvpt[pn];
  801019:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	if (!(pte & PTE_P)) return 0;
  801020:	a8 01                	test   $0x1,%al
  801022:	75 08                	jne    80102c <fork+0x8b>
  801024:	8d 5e 01             	lea    0x1(%esi),%ebx
  801027:	c1 e3 0c             	shl    $0xc,%ebx
  80102a:	eb 56                	jmp    801082 <fork+0xe1>
	// cprintf("virtual page %08x\n", pn * PGSIZE);

	if ((pte & PTE_W) || (pte & PTE_COW)) perm |= PTE_COW;
  80102c:	25 02 08 00 00       	and    $0x802,%eax
  801031:	83 f8 01             	cmp    $0x1,%eax
  801034:	19 ff                	sbb    %edi,%edi
  801036:	81 e7 00 f8 ff ff    	and    $0xfffff800,%edi
  80103c:	81 c7 05 08 00 00    	add    $0x805,%edi

	if ((r = sys_page_map(thisenv->env_id, (void*)(pn * PGSIZE), envid, 
  801042:	a1 04 40 80 00       	mov    0x804004,%eax
  801047:	8b 40 48             	mov    0x48(%eax),%eax
  80104a:	83 ec 0c             	sub    $0xc,%esp
  80104d:	57                   	push   %edi
  80104e:	53                   	push   %ebx
  80104f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801052:	53                   	push   %ebx
  801053:	50                   	push   %eax
  801054:	e8 ed fb ff ff       	call   800c46 <sys_page_map>
  801059:	83 c4 20             	add    $0x20,%esp
  80105c:	85 c0                	test   %eax,%eax
  80105e:	78 7c                	js     8010dc <fork+0x13b>
				(void*)(pn * PGSIZE), perm)) < 0) 
		return r;
	r = sys_page_map(envid, (void*)(pn * PGSIZE), thisenv->env_id, 
  801060:	a1 04 40 80 00       	mov    0x804004,%eax
  801065:	8b 40 48             	mov    0x48(%eax),%eax
  801068:	83 ec 0c             	sub    $0xc,%esp
  80106b:	57                   	push   %edi
  80106c:	53                   	push   %ebx
  80106d:	50                   	push   %eax
  80106e:	53                   	push   %ebx
  80106f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801072:	e8 cf fb ff ff       	call   800c46 <sys_page_map>
		uint32_t pn;
		for (pn = 0; pn * PGSIZE < UTOP; pn++){
			// cprintf("virtual page %08x\n", pn * PGSIZE);
			if (pn * PGSIZE == UXSTACKTOP - PGSIZE) 
				continue;
			if ((ret = duppage(envid, pn)) < 0)
  801077:	83 c4 20             	add    $0x20,%esp
  80107a:	85 c0                	test   %eax,%eax
  80107c:	79 a6                	jns    801024 <fork+0x83>
  80107e:	eb 5c                	jmp    8010dc <fork+0x13b>
  801080:	89 c3                	mov    %eax,%ebx
		// set_pgfault_handler(pgfault);
		return 0;
	}
	else {
		uint32_t pn;
		for (pn = 0; pn * PGSIZE < UTOP; pn++){
  801082:	83 c6 01             	add    $0x1,%esi
  801085:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
  80108b:	0f 86 6a ff ff ff    	jbe    800ffb <fork+0x5a>
				return ret;
		}
		// cprintf("Fork: duppage finished\n");

		// Should be done by parent
		if ((ret = sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P |
  801091:	83 ec 04             	sub    $0x4,%esp
  801094:	6a 07                	push   $0x7
  801096:	68 00 f0 bf ee       	push   $0xeebff000
  80109b:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80109e:	57                   	push   %edi
  80109f:	e8 5f fb ff ff       	call   800c03 <sys_page_alloc>
  8010a4:	83 c4 10             	add    $0x10,%esp
  8010a7:	85 c0                	test   %eax,%eax
  8010a9:	78 31                	js     8010dc <fork+0x13b>
						PTE_U | PTE_W)) < 0)
			return ret;
		if ((ret = sys_env_set_pgfault_upcall(envid, 
						thisenv->env_pgfault_upcall)) < 0)
  8010ab:	a1 04 40 80 00       	mov    0x804004,%eax

		// Should be done by parent
		if ((ret = sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P |
						PTE_U | PTE_W)) < 0)
			return ret;
		if ((ret = sys_env_set_pgfault_upcall(envid, 
  8010b0:	8b 40 64             	mov    0x64(%eax),%eax
  8010b3:	83 ec 08             	sub    $0x8,%esp
  8010b6:	50                   	push   %eax
  8010b7:	57                   	push   %edi
  8010b8:	e8 91 fc ff ff       	call   800d4e <sys_env_set_pgfault_upcall>
  8010bd:	83 c4 10             	add    $0x10,%esp
  8010c0:	85 c0                	test   %eax,%eax
  8010c2:	78 18                	js     8010dc <fork+0x13b>
						thisenv->env_pgfault_upcall)) < 0)
			return ret;

		if ((ret = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8010c4:	83 ec 08             	sub    $0x8,%esp
  8010c7:	6a 02                	push   $0x2
  8010c9:	57                   	push   %edi
  8010ca:	e8 fb fb ff ff       	call   800cca <sys_env_set_status>
  8010cf:	83 c4 10             	add    $0x10,%esp
			return ret;
		return envid;
  8010d2:	85 c0                	test   %eax,%eax
  8010d4:	0f 49 c7             	cmovns %edi,%eax
  8010d7:	eb 03                	jmp    8010dc <fork+0x13b>
	int ret;
	set_pgfault_handler(pgfault);

	envid_t envid = sys_exofork();

	if (envid < 0) return envid;
  8010d9:	8b 45 e0             	mov    -0x20(%ebp),%eax
			return ret;
		return envid;
	}

	panic("fork not implemented");
}
  8010dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010df:	5b                   	pop    %ebx
  8010e0:	5e                   	pop    %esi
  8010e1:	5f                   	pop    %edi
  8010e2:	5d                   	pop    %ebp
  8010e3:	c3                   	ret    

008010e4 <sfork>:

// Challenge!
int
sfork(void)
{
  8010e4:	55                   	push   %ebp
  8010e5:	89 e5                	mov    %esp,%ebp
  8010e7:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010ea:	68 31 26 80 00       	push   $0x802631
  8010ef:	68 9f 00 00 00       	push   $0x9f
  8010f4:	68 cf 25 80 00       	push   $0x8025cf
  8010f9:	e8 be 0c 00 00       	call   801dbc <_panic>

008010fe <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010fe:	55                   	push   %ebp
  8010ff:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801101:	8b 45 08             	mov    0x8(%ebp),%eax
  801104:	05 00 00 00 30       	add    $0x30000000,%eax
  801109:	c1 e8 0c             	shr    $0xc,%eax
}
  80110c:	5d                   	pop    %ebp
  80110d:	c3                   	ret    

0080110e <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80110e:	55                   	push   %ebp
  80110f:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801111:	8b 45 08             	mov    0x8(%ebp),%eax
  801114:	05 00 00 00 30       	add    $0x30000000,%eax
  801119:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80111e:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801123:	5d                   	pop    %ebp
  801124:	c3                   	ret    

00801125 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801125:	55                   	push   %ebp
  801126:	89 e5                	mov    %esp,%ebp
  801128:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80112b:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801130:	89 c2                	mov    %eax,%edx
  801132:	c1 ea 16             	shr    $0x16,%edx
  801135:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80113c:	f6 c2 01             	test   $0x1,%dl
  80113f:	74 11                	je     801152 <fd_alloc+0x2d>
  801141:	89 c2                	mov    %eax,%edx
  801143:	c1 ea 0c             	shr    $0xc,%edx
  801146:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80114d:	f6 c2 01             	test   $0x1,%dl
  801150:	75 09                	jne    80115b <fd_alloc+0x36>
			*fd_store = fd;
  801152:	89 01                	mov    %eax,(%ecx)
			return 0;
  801154:	b8 00 00 00 00       	mov    $0x0,%eax
  801159:	eb 17                	jmp    801172 <fd_alloc+0x4d>
  80115b:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801160:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801165:	75 c9                	jne    801130 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801167:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80116d:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801172:	5d                   	pop    %ebp
  801173:	c3                   	ret    

00801174 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801174:	55                   	push   %ebp
  801175:	89 e5                	mov    %esp,%ebp
  801177:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80117a:	83 f8 1f             	cmp    $0x1f,%eax
  80117d:	77 36                	ja     8011b5 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80117f:	c1 e0 0c             	shl    $0xc,%eax
  801182:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801187:	89 c2                	mov    %eax,%edx
  801189:	c1 ea 16             	shr    $0x16,%edx
  80118c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801193:	f6 c2 01             	test   $0x1,%dl
  801196:	74 24                	je     8011bc <fd_lookup+0x48>
  801198:	89 c2                	mov    %eax,%edx
  80119a:	c1 ea 0c             	shr    $0xc,%edx
  80119d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011a4:	f6 c2 01             	test   $0x1,%dl
  8011a7:	74 1a                	je     8011c3 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011ac:	89 02                	mov    %eax,(%edx)
	return 0;
  8011ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8011b3:	eb 13                	jmp    8011c8 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011b5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011ba:	eb 0c                	jmp    8011c8 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011bc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011c1:	eb 05                	jmp    8011c8 <fd_lookup+0x54>
  8011c3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8011c8:	5d                   	pop    %ebp
  8011c9:	c3                   	ret    

008011ca <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011ca:	55                   	push   %ebp
  8011cb:	89 e5                	mov    %esp,%ebp
  8011cd:	83 ec 08             	sub    $0x8,%esp
  8011d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011d3:	ba e8 26 80 00       	mov    $0x8026e8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8011d8:	eb 13                	jmp    8011ed <dev_lookup+0x23>
  8011da:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8011dd:	39 08                	cmp    %ecx,(%eax)
  8011df:	75 0c                	jne    8011ed <dev_lookup+0x23>
			*dev = devtab[i];
  8011e1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011e4:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8011eb:	eb 2e                	jmp    80121b <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011ed:	8b 02                	mov    (%edx),%eax
  8011ef:	85 c0                	test   %eax,%eax
  8011f1:	75 e7                	jne    8011da <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011f3:	a1 04 40 80 00       	mov    0x804004,%eax
  8011f8:	8b 40 48             	mov    0x48(%eax),%eax
  8011fb:	83 ec 04             	sub    $0x4,%esp
  8011fe:	51                   	push   %ecx
  8011ff:	50                   	push   %eax
  801200:	68 6c 26 80 00       	push   $0x80266c
  801205:	e8 ca ef ff ff       	call   8001d4 <cprintf>
	*dev = 0;
  80120a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80120d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801213:	83 c4 10             	add    $0x10,%esp
  801216:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80121b:	c9                   	leave  
  80121c:	c3                   	ret    

0080121d <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80121d:	55                   	push   %ebp
  80121e:	89 e5                	mov    %esp,%ebp
  801220:	56                   	push   %esi
  801221:	53                   	push   %ebx
  801222:	83 ec 10             	sub    $0x10,%esp
  801225:	8b 75 08             	mov    0x8(%ebp),%esi
  801228:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80122b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80122e:	50                   	push   %eax
  80122f:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801235:	c1 e8 0c             	shr    $0xc,%eax
  801238:	50                   	push   %eax
  801239:	e8 36 ff ff ff       	call   801174 <fd_lookup>
  80123e:	83 c4 08             	add    $0x8,%esp
  801241:	85 c0                	test   %eax,%eax
  801243:	78 05                	js     80124a <fd_close+0x2d>
	    || fd != fd2)
  801245:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801248:	74 0c                	je     801256 <fd_close+0x39>
		return (must_exist ? r : 0);
  80124a:	84 db                	test   %bl,%bl
  80124c:	ba 00 00 00 00       	mov    $0x0,%edx
  801251:	0f 44 c2             	cmove  %edx,%eax
  801254:	eb 41                	jmp    801297 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801256:	83 ec 08             	sub    $0x8,%esp
  801259:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80125c:	50                   	push   %eax
  80125d:	ff 36                	pushl  (%esi)
  80125f:	e8 66 ff ff ff       	call   8011ca <dev_lookup>
  801264:	89 c3                	mov    %eax,%ebx
  801266:	83 c4 10             	add    $0x10,%esp
  801269:	85 c0                	test   %eax,%eax
  80126b:	78 1a                	js     801287 <fd_close+0x6a>
		if (dev->dev_close)
  80126d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801270:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801273:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801278:	85 c0                	test   %eax,%eax
  80127a:	74 0b                	je     801287 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80127c:	83 ec 0c             	sub    $0xc,%esp
  80127f:	56                   	push   %esi
  801280:	ff d0                	call   *%eax
  801282:	89 c3                	mov    %eax,%ebx
  801284:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801287:	83 ec 08             	sub    $0x8,%esp
  80128a:	56                   	push   %esi
  80128b:	6a 00                	push   $0x0
  80128d:	e8 f6 f9 ff ff       	call   800c88 <sys_page_unmap>
	return r;
  801292:	83 c4 10             	add    $0x10,%esp
  801295:	89 d8                	mov    %ebx,%eax
}
  801297:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80129a:	5b                   	pop    %ebx
  80129b:	5e                   	pop    %esi
  80129c:	5d                   	pop    %ebp
  80129d:	c3                   	ret    

0080129e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80129e:	55                   	push   %ebp
  80129f:	89 e5                	mov    %esp,%ebp
  8012a1:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012a4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012a7:	50                   	push   %eax
  8012a8:	ff 75 08             	pushl  0x8(%ebp)
  8012ab:	e8 c4 fe ff ff       	call   801174 <fd_lookup>
  8012b0:	83 c4 08             	add    $0x8,%esp
  8012b3:	85 c0                	test   %eax,%eax
  8012b5:	78 10                	js     8012c7 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8012b7:	83 ec 08             	sub    $0x8,%esp
  8012ba:	6a 01                	push   $0x1
  8012bc:	ff 75 f4             	pushl  -0xc(%ebp)
  8012bf:	e8 59 ff ff ff       	call   80121d <fd_close>
  8012c4:	83 c4 10             	add    $0x10,%esp
}
  8012c7:	c9                   	leave  
  8012c8:	c3                   	ret    

008012c9 <close_all>:

void
close_all(void)
{
  8012c9:	55                   	push   %ebp
  8012ca:	89 e5                	mov    %esp,%ebp
  8012cc:	53                   	push   %ebx
  8012cd:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012d0:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012d5:	83 ec 0c             	sub    $0xc,%esp
  8012d8:	53                   	push   %ebx
  8012d9:	e8 c0 ff ff ff       	call   80129e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8012de:	83 c3 01             	add    $0x1,%ebx
  8012e1:	83 c4 10             	add    $0x10,%esp
  8012e4:	83 fb 20             	cmp    $0x20,%ebx
  8012e7:	75 ec                	jne    8012d5 <close_all+0xc>
		close(i);
}
  8012e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012ec:	c9                   	leave  
  8012ed:	c3                   	ret    

008012ee <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012ee:	55                   	push   %ebp
  8012ef:	89 e5                	mov    %esp,%ebp
  8012f1:	57                   	push   %edi
  8012f2:	56                   	push   %esi
  8012f3:	53                   	push   %ebx
  8012f4:	83 ec 2c             	sub    $0x2c,%esp
  8012f7:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012fa:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012fd:	50                   	push   %eax
  8012fe:	ff 75 08             	pushl  0x8(%ebp)
  801301:	e8 6e fe ff ff       	call   801174 <fd_lookup>
  801306:	83 c4 08             	add    $0x8,%esp
  801309:	85 c0                	test   %eax,%eax
  80130b:	0f 88 c1 00 00 00    	js     8013d2 <dup+0xe4>
		return r;
	close(newfdnum);
  801311:	83 ec 0c             	sub    $0xc,%esp
  801314:	56                   	push   %esi
  801315:	e8 84 ff ff ff       	call   80129e <close>

	newfd = INDEX2FD(newfdnum);
  80131a:	89 f3                	mov    %esi,%ebx
  80131c:	c1 e3 0c             	shl    $0xc,%ebx
  80131f:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801325:	83 c4 04             	add    $0x4,%esp
  801328:	ff 75 e4             	pushl  -0x1c(%ebp)
  80132b:	e8 de fd ff ff       	call   80110e <fd2data>
  801330:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801332:	89 1c 24             	mov    %ebx,(%esp)
  801335:	e8 d4 fd ff ff       	call   80110e <fd2data>
  80133a:	83 c4 10             	add    $0x10,%esp
  80133d:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801340:	89 f8                	mov    %edi,%eax
  801342:	c1 e8 16             	shr    $0x16,%eax
  801345:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80134c:	a8 01                	test   $0x1,%al
  80134e:	74 37                	je     801387 <dup+0x99>
  801350:	89 f8                	mov    %edi,%eax
  801352:	c1 e8 0c             	shr    $0xc,%eax
  801355:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80135c:	f6 c2 01             	test   $0x1,%dl
  80135f:	74 26                	je     801387 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801361:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801368:	83 ec 0c             	sub    $0xc,%esp
  80136b:	25 07 0e 00 00       	and    $0xe07,%eax
  801370:	50                   	push   %eax
  801371:	ff 75 d4             	pushl  -0x2c(%ebp)
  801374:	6a 00                	push   $0x0
  801376:	57                   	push   %edi
  801377:	6a 00                	push   $0x0
  801379:	e8 c8 f8 ff ff       	call   800c46 <sys_page_map>
  80137e:	89 c7                	mov    %eax,%edi
  801380:	83 c4 20             	add    $0x20,%esp
  801383:	85 c0                	test   %eax,%eax
  801385:	78 2e                	js     8013b5 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801387:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80138a:	89 d0                	mov    %edx,%eax
  80138c:	c1 e8 0c             	shr    $0xc,%eax
  80138f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801396:	83 ec 0c             	sub    $0xc,%esp
  801399:	25 07 0e 00 00       	and    $0xe07,%eax
  80139e:	50                   	push   %eax
  80139f:	53                   	push   %ebx
  8013a0:	6a 00                	push   $0x0
  8013a2:	52                   	push   %edx
  8013a3:	6a 00                	push   $0x0
  8013a5:	e8 9c f8 ff ff       	call   800c46 <sys_page_map>
  8013aa:	89 c7                	mov    %eax,%edi
  8013ac:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8013af:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013b1:	85 ff                	test   %edi,%edi
  8013b3:	79 1d                	jns    8013d2 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8013b5:	83 ec 08             	sub    $0x8,%esp
  8013b8:	53                   	push   %ebx
  8013b9:	6a 00                	push   $0x0
  8013bb:	e8 c8 f8 ff ff       	call   800c88 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013c0:	83 c4 08             	add    $0x8,%esp
  8013c3:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013c6:	6a 00                	push   $0x0
  8013c8:	e8 bb f8 ff ff       	call   800c88 <sys_page_unmap>
	return r;
  8013cd:	83 c4 10             	add    $0x10,%esp
  8013d0:	89 f8                	mov    %edi,%eax
}
  8013d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013d5:	5b                   	pop    %ebx
  8013d6:	5e                   	pop    %esi
  8013d7:	5f                   	pop    %edi
  8013d8:	5d                   	pop    %ebp
  8013d9:	c3                   	ret    

008013da <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013da:	55                   	push   %ebp
  8013db:	89 e5                	mov    %esp,%ebp
  8013dd:	53                   	push   %ebx
  8013de:	83 ec 14             	sub    $0x14,%esp
  8013e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013e4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013e7:	50                   	push   %eax
  8013e8:	53                   	push   %ebx
  8013e9:	e8 86 fd ff ff       	call   801174 <fd_lookup>
  8013ee:	83 c4 08             	add    $0x8,%esp
  8013f1:	89 c2                	mov    %eax,%edx
  8013f3:	85 c0                	test   %eax,%eax
  8013f5:	78 6d                	js     801464 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013f7:	83 ec 08             	sub    $0x8,%esp
  8013fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013fd:	50                   	push   %eax
  8013fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801401:	ff 30                	pushl  (%eax)
  801403:	e8 c2 fd ff ff       	call   8011ca <dev_lookup>
  801408:	83 c4 10             	add    $0x10,%esp
  80140b:	85 c0                	test   %eax,%eax
  80140d:	78 4c                	js     80145b <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80140f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801412:	8b 42 08             	mov    0x8(%edx),%eax
  801415:	83 e0 03             	and    $0x3,%eax
  801418:	83 f8 01             	cmp    $0x1,%eax
  80141b:	75 21                	jne    80143e <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80141d:	a1 04 40 80 00       	mov    0x804004,%eax
  801422:	8b 40 48             	mov    0x48(%eax),%eax
  801425:	83 ec 04             	sub    $0x4,%esp
  801428:	53                   	push   %ebx
  801429:	50                   	push   %eax
  80142a:	68 ad 26 80 00       	push   $0x8026ad
  80142f:	e8 a0 ed ff ff       	call   8001d4 <cprintf>
		return -E_INVAL;
  801434:	83 c4 10             	add    $0x10,%esp
  801437:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80143c:	eb 26                	jmp    801464 <read+0x8a>
	}
	if (!dev->dev_read)
  80143e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801441:	8b 40 08             	mov    0x8(%eax),%eax
  801444:	85 c0                	test   %eax,%eax
  801446:	74 17                	je     80145f <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801448:	83 ec 04             	sub    $0x4,%esp
  80144b:	ff 75 10             	pushl  0x10(%ebp)
  80144e:	ff 75 0c             	pushl  0xc(%ebp)
  801451:	52                   	push   %edx
  801452:	ff d0                	call   *%eax
  801454:	89 c2                	mov    %eax,%edx
  801456:	83 c4 10             	add    $0x10,%esp
  801459:	eb 09                	jmp    801464 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80145b:	89 c2                	mov    %eax,%edx
  80145d:	eb 05                	jmp    801464 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80145f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801464:	89 d0                	mov    %edx,%eax
  801466:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801469:	c9                   	leave  
  80146a:	c3                   	ret    

0080146b <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80146b:	55                   	push   %ebp
  80146c:	89 e5                	mov    %esp,%ebp
  80146e:	57                   	push   %edi
  80146f:	56                   	push   %esi
  801470:	53                   	push   %ebx
  801471:	83 ec 0c             	sub    $0xc,%esp
  801474:	8b 7d 08             	mov    0x8(%ebp),%edi
  801477:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80147a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80147f:	eb 21                	jmp    8014a2 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801481:	83 ec 04             	sub    $0x4,%esp
  801484:	89 f0                	mov    %esi,%eax
  801486:	29 d8                	sub    %ebx,%eax
  801488:	50                   	push   %eax
  801489:	89 d8                	mov    %ebx,%eax
  80148b:	03 45 0c             	add    0xc(%ebp),%eax
  80148e:	50                   	push   %eax
  80148f:	57                   	push   %edi
  801490:	e8 45 ff ff ff       	call   8013da <read>
		if (m < 0)
  801495:	83 c4 10             	add    $0x10,%esp
  801498:	85 c0                	test   %eax,%eax
  80149a:	78 10                	js     8014ac <readn+0x41>
			return m;
		if (m == 0)
  80149c:	85 c0                	test   %eax,%eax
  80149e:	74 0a                	je     8014aa <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014a0:	01 c3                	add    %eax,%ebx
  8014a2:	39 f3                	cmp    %esi,%ebx
  8014a4:	72 db                	jb     801481 <readn+0x16>
  8014a6:	89 d8                	mov    %ebx,%eax
  8014a8:	eb 02                	jmp    8014ac <readn+0x41>
  8014aa:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8014ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014af:	5b                   	pop    %ebx
  8014b0:	5e                   	pop    %esi
  8014b1:	5f                   	pop    %edi
  8014b2:	5d                   	pop    %ebp
  8014b3:	c3                   	ret    

008014b4 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014b4:	55                   	push   %ebp
  8014b5:	89 e5                	mov    %esp,%ebp
  8014b7:	53                   	push   %ebx
  8014b8:	83 ec 14             	sub    $0x14,%esp
  8014bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014be:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014c1:	50                   	push   %eax
  8014c2:	53                   	push   %ebx
  8014c3:	e8 ac fc ff ff       	call   801174 <fd_lookup>
  8014c8:	83 c4 08             	add    $0x8,%esp
  8014cb:	89 c2                	mov    %eax,%edx
  8014cd:	85 c0                	test   %eax,%eax
  8014cf:	78 68                	js     801539 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014d1:	83 ec 08             	sub    $0x8,%esp
  8014d4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014d7:	50                   	push   %eax
  8014d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014db:	ff 30                	pushl  (%eax)
  8014dd:	e8 e8 fc ff ff       	call   8011ca <dev_lookup>
  8014e2:	83 c4 10             	add    $0x10,%esp
  8014e5:	85 c0                	test   %eax,%eax
  8014e7:	78 47                	js     801530 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014ec:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014f0:	75 21                	jne    801513 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014f2:	a1 04 40 80 00       	mov    0x804004,%eax
  8014f7:	8b 40 48             	mov    0x48(%eax),%eax
  8014fa:	83 ec 04             	sub    $0x4,%esp
  8014fd:	53                   	push   %ebx
  8014fe:	50                   	push   %eax
  8014ff:	68 c9 26 80 00       	push   $0x8026c9
  801504:	e8 cb ec ff ff       	call   8001d4 <cprintf>
		return -E_INVAL;
  801509:	83 c4 10             	add    $0x10,%esp
  80150c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801511:	eb 26                	jmp    801539 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801513:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801516:	8b 52 0c             	mov    0xc(%edx),%edx
  801519:	85 d2                	test   %edx,%edx
  80151b:	74 17                	je     801534 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80151d:	83 ec 04             	sub    $0x4,%esp
  801520:	ff 75 10             	pushl  0x10(%ebp)
  801523:	ff 75 0c             	pushl  0xc(%ebp)
  801526:	50                   	push   %eax
  801527:	ff d2                	call   *%edx
  801529:	89 c2                	mov    %eax,%edx
  80152b:	83 c4 10             	add    $0x10,%esp
  80152e:	eb 09                	jmp    801539 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801530:	89 c2                	mov    %eax,%edx
  801532:	eb 05                	jmp    801539 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801534:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801539:	89 d0                	mov    %edx,%eax
  80153b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80153e:	c9                   	leave  
  80153f:	c3                   	ret    

00801540 <seek>:

int
seek(int fdnum, off_t offset)
{
  801540:	55                   	push   %ebp
  801541:	89 e5                	mov    %esp,%ebp
  801543:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801546:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801549:	50                   	push   %eax
  80154a:	ff 75 08             	pushl  0x8(%ebp)
  80154d:	e8 22 fc ff ff       	call   801174 <fd_lookup>
  801552:	83 c4 08             	add    $0x8,%esp
  801555:	85 c0                	test   %eax,%eax
  801557:	78 0e                	js     801567 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801559:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80155c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80155f:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801562:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801567:	c9                   	leave  
  801568:	c3                   	ret    

00801569 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801569:	55                   	push   %ebp
  80156a:	89 e5                	mov    %esp,%ebp
  80156c:	53                   	push   %ebx
  80156d:	83 ec 14             	sub    $0x14,%esp
  801570:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801573:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801576:	50                   	push   %eax
  801577:	53                   	push   %ebx
  801578:	e8 f7 fb ff ff       	call   801174 <fd_lookup>
  80157d:	83 c4 08             	add    $0x8,%esp
  801580:	89 c2                	mov    %eax,%edx
  801582:	85 c0                	test   %eax,%eax
  801584:	78 65                	js     8015eb <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801586:	83 ec 08             	sub    $0x8,%esp
  801589:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80158c:	50                   	push   %eax
  80158d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801590:	ff 30                	pushl  (%eax)
  801592:	e8 33 fc ff ff       	call   8011ca <dev_lookup>
  801597:	83 c4 10             	add    $0x10,%esp
  80159a:	85 c0                	test   %eax,%eax
  80159c:	78 44                	js     8015e2 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80159e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015a1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015a5:	75 21                	jne    8015c8 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015a7:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015ac:	8b 40 48             	mov    0x48(%eax),%eax
  8015af:	83 ec 04             	sub    $0x4,%esp
  8015b2:	53                   	push   %ebx
  8015b3:	50                   	push   %eax
  8015b4:	68 8c 26 80 00       	push   $0x80268c
  8015b9:	e8 16 ec ff ff       	call   8001d4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8015be:	83 c4 10             	add    $0x10,%esp
  8015c1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015c6:	eb 23                	jmp    8015eb <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8015c8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015cb:	8b 52 18             	mov    0x18(%edx),%edx
  8015ce:	85 d2                	test   %edx,%edx
  8015d0:	74 14                	je     8015e6 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015d2:	83 ec 08             	sub    $0x8,%esp
  8015d5:	ff 75 0c             	pushl  0xc(%ebp)
  8015d8:	50                   	push   %eax
  8015d9:	ff d2                	call   *%edx
  8015db:	89 c2                	mov    %eax,%edx
  8015dd:	83 c4 10             	add    $0x10,%esp
  8015e0:	eb 09                	jmp    8015eb <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015e2:	89 c2                	mov    %eax,%edx
  8015e4:	eb 05                	jmp    8015eb <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8015e6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8015eb:	89 d0                	mov    %edx,%eax
  8015ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015f0:	c9                   	leave  
  8015f1:	c3                   	ret    

008015f2 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015f2:	55                   	push   %ebp
  8015f3:	89 e5                	mov    %esp,%ebp
  8015f5:	53                   	push   %ebx
  8015f6:	83 ec 14             	sub    $0x14,%esp
  8015f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015fc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015ff:	50                   	push   %eax
  801600:	ff 75 08             	pushl  0x8(%ebp)
  801603:	e8 6c fb ff ff       	call   801174 <fd_lookup>
  801608:	83 c4 08             	add    $0x8,%esp
  80160b:	89 c2                	mov    %eax,%edx
  80160d:	85 c0                	test   %eax,%eax
  80160f:	78 58                	js     801669 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801611:	83 ec 08             	sub    $0x8,%esp
  801614:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801617:	50                   	push   %eax
  801618:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80161b:	ff 30                	pushl  (%eax)
  80161d:	e8 a8 fb ff ff       	call   8011ca <dev_lookup>
  801622:	83 c4 10             	add    $0x10,%esp
  801625:	85 c0                	test   %eax,%eax
  801627:	78 37                	js     801660 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801629:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80162c:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801630:	74 32                	je     801664 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801632:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801635:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80163c:	00 00 00 
	stat->st_isdir = 0;
  80163f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801646:	00 00 00 
	stat->st_dev = dev;
  801649:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80164f:	83 ec 08             	sub    $0x8,%esp
  801652:	53                   	push   %ebx
  801653:	ff 75 f0             	pushl  -0x10(%ebp)
  801656:	ff 50 14             	call   *0x14(%eax)
  801659:	89 c2                	mov    %eax,%edx
  80165b:	83 c4 10             	add    $0x10,%esp
  80165e:	eb 09                	jmp    801669 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801660:	89 c2                	mov    %eax,%edx
  801662:	eb 05                	jmp    801669 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801664:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801669:	89 d0                	mov    %edx,%eax
  80166b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80166e:	c9                   	leave  
  80166f:	c3                   	ret    

00801670 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801670:	55                   	push   %ebp
  801671:	89 e5                	mov    %esp,%ebp
  801673:	56                   	push   %esi
  801674:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801675:	83 ec 08             	sub    $0x8,%esp
  801678:	6a 00                	push   $0x0
  80167a:	ff 75 08             	pushl  0x8(%ebp)
  80167d:	e8 b7 01 00 00       	call   801839 <open>
  801682:	89 c3                	mov    %eax,%ebx
  801684:	83 c4 10             	add    $0x10,%esp
  801687:	85 c0                	test   %eax,%eax
  801689:	78 1b                	js     8016a6 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80168b:	83 ec 08             	sub    $0x8,%esp
  80168e:	ff 75 0c             	pushl  0xc(%ebp)
  801691:	50                   	push   %eax
  801692:	e8 5b ff ff ff       	call   8015f2 <fstat>
  801697:	89 c6                	mov    %eax,%esi
	close(fd);
  801699:	89 1c 24             	mov    %ebx,(%esp)
  80169c:	e8 fd fb ff ff       	call   80129e <close>
	return r;
  8016a1:	83 c4 10             	add    $0x10,%esp
  8016a4:	89 f0                	mov    %esi,%eax
}
  8016a6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016a9:	5b                   	pop    %ebx
  8016aa:	5e                   	pop    %esi
  8016ab:	5d                   	pop    %ebp
  8016ac:	c3                   	ret    

008016ad <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016ad:	55                   	push   %ebp
  8016ae:	89 e5                	mov    %esp,%ebp
  8016b0:	56                   	push   %esi
  8016b1:	53                   	push   %ebx
  8016b2:	89 c6                	mov    %eax,%esi
  8016b4:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016b6:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8016bd:	75 12                	jne    8016d1 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016bf:	83 ec 0c             	sub    $0xc,%esp
  8016c2:	6a 01                	push   $0x1
  8016c4:	e8 72 08 00 00       	call   801f3b <ipc_find_env>
  8016c9:	a3 00 40 80 00       	mov    %eax,0x804000
  8016ce:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016d1:	6a 07                	push   $0x7
  8016d3:	68 00 50 80 00       	push   $0x805000
  8016d8:	56                   	push   %esi
  8016d9:	ff 35 00 40 80 00    	pushl  0x804000
  8016df:	e8 03 08 00 00       	call   801ee7 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016e4:	83 c4 0c             	add    $0xc,%esp
  8016e7:	6a 00                	push   $0x0
  8016e9:	53                   	push   %ebx
  8016ea:	6a 00                	push   $0x0
  8016ec:	e8 81 07 00 00       	call   801e72 <ipc_recv>
}
  8016f1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016f4:	5b                   	pop    %ebx
  8016f5:	5e                   	pop    %esi
  8016f6:	5d                   	pop    %ebp
  8016f7:	c3                   	ret    

008016f8 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016f8:	55                   	push   %ebp
  8016f9:	89 e5                	mov    %esp,%ebp
  8016fb:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801701:	8b 40 0c             	mov    0xc(%eax),%eax
  801704:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801709:	8b 45 0c             	mov    0xc(%ebp),%eax
  80170c:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801711:	ba 00 00 00 00       	mov    $0x0,%edx
  801716:	b8 02 00 00 00       	mov    $0x2,%eax
  80171b:	e8 8d ff ff ff       	call   8016ad <fsipc>
}
  801720:	c9                   	leave  
  801721:	c3                   	ret    

00801722 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801722:	55                   	push   %ebp
  801723:	89 e5                	mov    %esp,%ebp
  801725:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801728:	8b 45 08             	mov    0x8(%ebp),%eax
  80172b:	8b 40 0c             	mov    0xc(%eax),%eax
  80172e:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801733:	ba 00 00 00 00       	mov    $0x0,%edx
  801738:	b8 06 00 00 00       	mov    $0x6,%eax
  80173d:	e8 6b ff ff ff       	call   8016ad <fsipc>
}
  801742:	c9                   	leave  
  801743:	c3                   	ret    

00801744 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801744:	55                   	push   %ebp
  801745:	89 e5                	mov    %esp,%ebp
  801747:	53                   	push   %ebx
  801748:	83 ec 04             	sub    $0x4,%esp
  80174b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80174e:	8b 45 08             	mov    0x8(%ebp),%eax
  801751:	8b 40 0c             	mov    0xc(%eax),%eax
  801754:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801759:	ba 00 00 00 00       	mov    $0x0,%edx
  80175e:	b8 05 00 00 00       	mov    $0x5,%eax
  801763:	e8 45 ff ff ff       	call   8016ad <fsipc>
  801768:	85 c0                	test   %eax,%eax
  80176a:	78 2c                	js     801798 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80176c:	83 ec 08             	sub    $0x8,%esp
  80176f:	68 00 50 80 00       	push   $0x805000
  801774:	53                   	push   %ebx
  801775:	e8 86 f0 ff ff       	call   800800 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80177a:	a1 80 50 80 00       	mov    0x805080,%eax
  80177f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801785:	a1 84 50 80 00       	mov    0x805084,%eax
  80178a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801790:	83 c4 10             	add    $0x10,%esp
  801793:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801798:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80179b:	c9                   	leave  
  80179c:	c3                   	ret    

0080179d <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80179d:	55                   	push   %ebp
  80179e:	89 e5                	mov    %esp,%ebp
  8017a0:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  8017a3:	68 f8 26 80 00       	push   $0x8026f8
  8017a8:	68 90 00 00 00       	push   $0x90
  8017ad:	68 16 27 80 00       	push   $0x802716
  8017b2:	e8 05 06 00 00       	call   801dbc <_panic>

008017b7 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8017b7:	55                   	push   %ebp
  8017b8:	89 e5                	mov    %esp,%ebp
  8017ba:	56                   	push   %esi
  8017bb:	53                   	push   %ebx
  8017bc:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c2:	8b 40 0c             	mov    0xc(%eax),%eax
  8017c5:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8017ca:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8017d5:	b8 03 00 00 00       	mov    $0x3,%eax
  8017da:	e8 ce fe ff ff       	call   8016ad <fsipc>
  8017df:	89 c3                	mov    %eax,%ebx
  8017e1:	85 c0                	test   %eax,%eax
  8017e3:	78 4b                	js     801830 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8017e5:	39 c6                	cmp    %eax,%esi
  8017e7:	73 16                	jae    8017ff <devfile_read+0x48>
  8017e9:	68 21 27 80 00       	push   $0x802721
  8017ee:	68 28 27 80 00       	push   $0x802728
  8017f3:	6a 7c                	push   $0x7c
  8017f5:	68 16 27 80 00       	push   $0x802716
  8017fa:	e8 bd 05 00 00       	call   801dbc <_panic>
	assert(r <= PGSIZE);
  8017ff:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801804:	7e 16                	jle    80181c <devfile_read+0x65>
  801806:	68 3d 27 80 00       	push   $0x80273d
  80180b:	68 28 27 80 00       	push   $0x802728
  801810:	6a 7d                	push   $0x7d
  801812:	68 16 27 80 00       	push   $0x802716
  801817:	e8 a0 05 00 00       	call   801dbc <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80181c:	83 ec 04             	sub    $0x4,%esp
  80181f:	50                   	push   %eax
  801820:	68 00 50 80 00       	push   $0x805000
  801825:	ff 75 0c             	pushl  0xc(%ebp)
  801828:	e8 65 f1 ff ff       	call   800992 <memmove>
	return r;
  80182d:	83 c4 10             	add    $0x10,%esp
}
  801830:	89 d8                	mov    %ebx,%eax
  801832:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801835:	5b                   	pop    %ebx
  801836:	5e                   	pop    %esi
  801837:	5d                   	pop    %ebp
  801838:	c3                   	ret    

00801839 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801839:	55                   	push   %ebp
  80183a:	89 e5                	mov    %esp,%ebp
  80183c:	53                   	push   %ebx
  80183d:	83 ec 20             	sub    $0x20,%esp
  801840:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801843:	53                   	push   %ebx
  801844:	e8 7e ef ff ff       	call   8007c7 <strlen>
  801849:	83 c4 10             	add    $0x10,%esp
  80184c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801851:	7f 67                	jg     8018ba <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801853:	83 ec 0c             	sub    $0xc,%esp
  801856:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801859:	50                   	push   %eax
  80185a:	e8 c6 f8 ff ff       	call   801125 <fd_alloc>
  80185f:	83 c4 10             	add    $0x10,%esp
		return r;
  801862:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801864:	85 c0                	test   %eax,%eax
  801866:	78 57                	js     8018bf <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801868:	83 ec 08             	sub    $0x8,%esp
  80186b:	53                   	push   %ebx
  80186c:	68 00 50 80 00       	push   $0x805000
  801871:	e8 8a ef ff ff       	call   800800 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801876:	8b 45 0c             	mov    0xc(%ebp),%eax
  801879:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80187e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801881:	b8 01 00 00 00       	mov    $0x1,%eax
  801886:	e8 22 fe ff ff       	call   8016ad <fsipc>
  80188b:	89 c3                	mov    %eax,%ebx
  80188d:	83 c4 10             	add    $0x10,%esp
  801890:	85 c0                	test   %eax,%eax
  801892:	79 14                	jns    8018a8 <open+0x6f>
		fd_close(fd, 0);
  801894:	83 ec 08             	sub    $0x8,%esp
  801897:	6a 00                	push   $0x0
  801899:	ff 75 f4             	pushl  -0xc(%ebp)
  80189c:	e8 7c f9 ff ff       	call   80121d <fd_close>
		return r;
  8018a1:	83 c4 10             	add    $0x10,%esp
  8018a4:	89 da                	mov    %ebx,%edx
  8018a6:	eb 17                	jmp    8018bf <open+0x86>
	}

	return fd2num(fd);
  8018a8:	83 ec 0c             	sub    $0xc,%esp
  8018ab:	ff 75 f4             	pushl  -0xc(%ebp)
  8018ae:	e8 4b f8 ff ff       	call   8010fe <fd2num>
  8018b3:	89 c2                	mov    %eax,%edx
  8018b5:	83 c4 10             	add    $0x10,%esp
  8018b8:	eb 05                	jmp    8018bf <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8018ba:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8018bf:	89 d0                	mov    %edx,%eax
  8018c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018c4:	c9                   	leave  
  8018c5:	c3                   	ret    

008018c6 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8018c6:	55                   	push   %ebp
  8018c7:	89 e5                	mov    %esp,%ebp
  8018c9:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8018cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8018d1:	b8 08 00 00 00       	mov    $0x8,%eax
  8018d6:	e8 d2 fd ff ff       	call   8016ad <fsipc>
}
  8018db:	c9                   	leave  
  8018dc:	c3                   	ret    

008018dd <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8018dd:	55                   	push   %ebp
  8018de:	89 e5                	mov    %esp,%ebp
  8018e0:	56                   	push   %esi
  8018e1:	53                   	push   %ebx
  8018e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8018e5:	83 ec 0c             	sub    $0xc,%esp
  8018e8:	ff 75 08             	pushl  0x8(%ebp)
  8018eb:	e8 1e f8 ff ff       	call   80110e <fd2data>
  8018f0:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8018f2:	83 c4 08             	add    $0x8,%esp
  8018f5:	68 49 27 80 00       	push   $0x802749
  8018fa:	53                   	push   %ebx
  8018fb:	e8 00 ef ff ff       	call   800800 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801900:	8b 46 04             	mov    0x4(%esi),%eax
  801903:	2b 06                	sub    (%esi),%eax
  801905:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80190b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801912:	00 00 00 
	stat->st_dev = &devpipe;
  801915:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80191c:	30 80 00 
	return 0;
}
  80191f:	b8 00 00 00 00       	mov    $0x0,%eax
  801924:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801927:	5b                   	pop    %ebx
  801928:	5e                   	pop    %esi
  801929:	5d                   	pop    %ebp
  80192a:	c3                   	ret    

0080192b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80192b:	55                   	push   %ebp
  80192c:	89 e5                	mov    %esp,%ebp
  80192e:	53                   	push   %ebx
  80192f:	83 ec 0c             	sub    $0xc,%esp
  801932:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801935:	53                   	push   %ebx
  801936:	6a 00                	push   $0x0
  801938:	e8 4b f3 ff ff       	call   800c88 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80193d:	89 1c 24             	mov    %ebx,(%esp)
  801940:	e8 c9 f7 ff ff       	call   80110e <fd2data>
  801945:	83 c4 08             	add    $0x8,%esp
  801948:	50                   	push   %eax
  801949:	6a 00                	push   $0x0
  80194b:	e8 38 f3 ff ff       	call   800c88 <sys_page_unmap>
}
  801950:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801953:	c9                   	leave  
  801954:	c3                   	ret    

00801955 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801955:	55                   	push   %ebp
  801956:	89 e5                	mov    %esp,%ebp
  801958:	57                   	push   %edi
  801959:	56                   	push   %esi
  80195a:	53                   	push   %ebx
  80195b:	83 ec 1c             	sub    $0x1c,%esp
  80195e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801961:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801963:	a1 04 40 80 00       	mov    0x804004,%eax
  801968:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80196b:	83 ec 0c             	sub    $0xc,%esp
  80196e:	ff 75 e0             	pushl  -0x20(%ebp)
  801971:	e8 fe 05 00 00       	call   801f74 <pageref>
  801976:	89 c3                	mov    %eax,%ebx
  801978:	89 3c 24             	mov    %edi,(%esp)
  80197b:	e8 f4 05 00 00       	call   801f74 <pageref>
  801980:	83 c4 10             	add    $0x10,%esp
  801983:	39 c3                	cmp    %eax,%ebx
  801985:	0f 94 c1             	sete   %cl
  801988:	0f b6 c9             	movzbl %cl,%ecx
  80198b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80198e:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801994:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801997:	39 ce                	cmp    %ecx,%esi
  801999:	74 1b                	je     8019b6 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80199b:	39 c3                	cmp    %eax,%ebx
  80199d:	75 c4                	jne    801963 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80199f:	8b 42 58             	mov    0x58(%edx),%eax
  8019a2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8019a5:	50                   	push   %eax
  8019a6:	56                   	push   %esi
  8019a7:	68 50 27 80 00       	push   $0x802750
  8019ac:	e8 23 e8 ff ff       	call   8001d4 <cprintf>
  8019b1:	83 c4 10             	add    $0x10,%esp
  8019b4:	eb ad                	jmp    801963 <_pipeisclosed+0xe>
	}
}
  8019b6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019b9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019bc:	5b                   	pop    %ebx
  8019bd:	5e                   	pop    %esi
  8019be:	5f                   	pop    %edi
  8019bf:	5d                   	pop    %ebp
  8019c0:	c3                   	ret    

008019c1 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8019c1:	55                   	push   %ebp
  8019c2:	89 e5                	mov    %esp,%ebp
  8019c4:	57                   	push   %edi
  8019c5:	56                   	push   %esi
  8019c6:	53                   	push   %ebx
  8019c7:	83 ec 28             	sub    $0x28,%esp
  8019ca:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8019cd:	56                   	push   %esi
  8019ce:	e8 3b f7 ff ff       	call   80110e <fd2data>
  8019d3:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019d5:	83 c4 10             	add    $0x10,%esp
  8019d8:	bf 00 00 00 00       	mov    $0x0,%edi
  8019dd:	eb 4b                	jmp    801a2a <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8019df:	89 da                	mov    %ebx,%edx
  8019e1:	89 f0                	mov    %esi,%eax
  8019e3:	e8 6d ff ff ff       	call   801955 <_pipeisclosed>
  8019e8:	85 c0                	test   %eax,%eax
  8019ea:	75 48                	jne    801a34 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8019ec:	e8 f3 f1 ff ff       	call   800be4 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8019f1:	8b 43 04             	mov    0x4(%ebx),%eax
  8019f4:	8b 0b                	mov    (%ebx),%ecx
  8019f6:	8d 51 20             	lea    0x20(%ecx),%edx
  8019f9:	39 d0                	cmp    %edx,%eax
  8019fb:	73 e2                	jae    8019df <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8019fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a00:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a04:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a07:	89 c2                	mov    %eax,%edx
  801a09:	c1 fa 1f             	sar    $0x1f,%edx
  801a0c:	89 d1                	mov    %edx,%ecx
  801a0e:	c1 e9 1b             	shr    $0x1b,%ecx
  801a11:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801a14:	83 e2 1f             	and    $0x1f,%edx
  801a17:	29 ca                	sub    %ecx,%edx
  801a19:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801a1d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a21:	83 c0 01             	add    $0x1,%eax
  801a24:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a27:	83 c7 01             	add    $0x1,%edi
  801a2a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a2d:	75 c2                	jne    8019f1 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801a2f:	8b 45 10             	mov    0x10(%ebp),%eax
  801a32:	eb 05                	jmp    801a39 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a34:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801a39:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a3c:	5b                   	pop    %ebx
  801a3d:	5e                   	pop    %esi
  801a3e:	5f                   	pop    %edi
  801a3f:	5d                   	pop    %ebp
  801a40:	c3                   	ret    

00801a41 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a41:	55                   	push   %ebp
  801a42:	89 e5                	mov    %esp,%ebp
  801a44:	57                   	push   %edi
  801a45:	56                   	push   %esi
  801a46:	53                   	push   %ebx
  801a47:	83 ec 18             	sub    $0x18,%esp
  801a4a:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801a4d:	57                   	push   %edi
  801a4e:	e8 bb f6 ff ff       	call   80110e <fd2data>
  801a53:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a55:	83 c4 10             	add    $0x10,%esp
  801a58:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a5d:	eb 3d                	jmp    801a9c <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801a5f:	85 db                	test   %ebx,%ebx
  801a61:	74 04                	je     801a67 <devpipe_read+0x26>
				return i;
  801a63:	89 d8                	mov    %ebx,%eax
  801a65:	eb 44                	jmp    801aab <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801a67:	89 f2                	mov    %esi,%edx
  801a69:	89 f8                	mov    %edi,%eax
  801a6b:	e8 e5 fe ff ff       	call   801955 <_pipeisclosed>
  801a70:	85 c0                	test   %eax,%eax
  801a72:	75 32                	jne    801aa6 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801a74:	e8 6b f1 ff ff       	call   800be4 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801a79:	8b 06                	mov    (%esi),%eax
  801a7b:	3b 46 04             	cmp    0x4(%esi),%eax
  801a7e:	74 df                	je     801a5f <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a80:	99                   	cltd   
  801a81:	c1 ea 1b             	shr    $0x1b,%edx
  801a84:	01 d0                	add    %edx,%eax
  801a86:	83 e0 1f             	and    $0x1f,%eax
  801a89:	29 d0                	sub    %edx,%eax
  801a8b:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801a90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a93:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801a96:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a99:	83 c3 01             	add    $0x1,%ebx
  801a9c:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801a9f:	75 d8                	jne    801a79 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801aa1:	8b 45 10             	mov    0x10(%ebp),%eax
  801aa4:	eb 05                	jmp    801aab <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801aa6:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801aab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aae:	5b                   	pop    %ebx
  801aaf:	5e                   	pop    %esi
  801ab0:	5f                   	pop    %edi
  801ab1:	5d                   	pop    %ebp
  801ab2:	c3                   	ret    

00801ab3 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801ab3:	55                   	push   %ebp
  801ab4:	89 e5                	mov    %esp,%ebp
  801ab6:	56                   	push   %esi
  801ab7:	53                   	push   %ebx
  801ab8:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801abb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801abe:	50                   	push   %eax
  801abf:	e8 61 f6 ff ff       	call   801125 <fd_alloc>
  801ac4:	83 c4 10             	add    $0x10,%esp
  801ac7:	89 c2                	mov    %eax,%edx
  801ac9:	85 c0                	test   %eax,%eax
  801acb:	0f 88 2c 01 00 00    	js     801bfd <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ad1:	83 ec 04             	sub    $0x4,%esp
  801ad4:	68 07 04 00 00       	push   $0x407
  801ad9:	ff 75 f4             	pushl  -0xc(%ebp)
  801adc:	6a 00                	push   $0x0
  801ade:	e8 20 f1 ff ff       	call   800c03 <sys_page_alloc>
  801ae3:	83 c4 10             	add    $0x10,%esp
  801ae6:	89 c2                	mov    %eax,%edx
  801ae8:	85 c0                	test   %eax,%eax
  801aea:	0f 88 0d 01 00 00    	js     801bfd <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801af0:	83 ec 0c             	sub    $0xc,%esp
  801af3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801af6:	50                   	push   %eax
  801af7:	e8 29 f6 ff ff       	call   801125 <fd_alloc>
  801afc:	89 c3                	mov    %eax,%ebx
  801afe:	83 c4 10             	add    $0x10,%esp
  801b01:	85 c0                	test   %eax,%eax
  801b03:	0f 88 e2 00 00 00    	js     801beb <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b09:	83 ec 04             	sub    $0x4,%esp
  801b0c:	68 07 04 00 00       	push   $0x407
  801b11:	ff 75 f0             	pushl  -0x10(%ebp)
  801b14:	6a 00                	push   $0x0
  801b16:	e8 e8 f0 ff ff       	call   800c03 <sys_page_alloc>
  801b1b:	89 c3                	mov    %eax,%ebx
  801b1d:	83 c4 10             	add    $0x10,%esp
  801b20:	85 c0                	test   %eax,%eax
  801b22:	0f 88 c3 00 00 00    	js     801beb <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801b28:	83 ec 0c             	sub    $0xc,%esp
  801b2b:	ff 75 f4             	pushl  -0xc(%ebp)
  801b2e:	e8 db f5 ff ff       	call   80110e <fd2data>
  801b33:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b35:	83 c4 0c             	add    $0xc,%esp
  801b38:	68 07 04 00 00       	push   $0x407
  801b3d:	50                   	push   %eax
  801b3e:	6a 00                	push   $0x0
  801b40:	e8 be f0 ff ff       	call   800c03 <sys_page_alloc>
  801b45:	89 c3                	mov    %eax,%ebx
  801b47:	83 c4 10             	add    $0x10,%esp
  801b4a:	85 c0                	test   %eax,%eax
  801b4c:	0f 88 89 00 00 00    	js     801bdb <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b52:	83 ec 0c             	sub    $0xc,%esp
  801b55:	ff 75 f0             	pushl  -0x10(%ebp)
  801b58:	e8 b1 f5 ff ff       	call   80110e <fd2data>
  801b5d:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801b64:	50                   	push   %eax
  801b65:	6a 00                	push   $0x0
  801b67:	56                   	push   %esi
  801b68:	6a 00                	push   $0x0
  801b6a:	e8 d7 f0 ff ff       	call   800c46 <sys_page_map>
  801b6f:	89 c3                	mov    %eax,%ebx
  801b71:	83 c4 20             	add    $0x20,%esp
  801b74:	85 c0                	test   %eax,%eax
  801b76:	78 55                	js     801bcd <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801b78:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b81:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b83:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b86:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801b8d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b93:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b96:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801b98:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b9b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801ba2:	83 ec 0c             	sub    $0xc,%esp
  801ba5:	ff 75 f4             	pushl  -0xc(%ebp)
  801ba8:	e8 51 f5 ff ff       	call   8010fe <fd2num>
  801bad:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bb0:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801bb2:	83 c4 04             	add    $0x4,%esp
  801bb5:	ff 75 f0             	pushl  -0x10(%ebp)
  801bb8:	e8 41 f5 ff ff       	call   8010fe <fd2num>
  801bbd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bc0:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801bc3:	83 c4 10             	add    $0x10,%esp
  801bc6:	ba 00 00 00 00       	mov    $0x0,%edx
  801bcb:	eb 30                	jmp    801bfd <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801bcd:	83 ec 08             	sub    $0x8,%esp
  801bd0:	56                   	push   %esi
  801bd1:	6a 00                	push   $0x0
  801bd3:	e8 b0 f0 ff ff       	call   800c88 <sys_page_unmap>
  801bd8:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801bdb:	83 ec 08             	sub    $0x8,%esp
  801bde:	ff 75 f0             	pushl  -0x10(%ebp)
  801be1:	6a 00                	push   $0x0
  801be3:	e8 a0 f0 ff ff       	call   800c88 <sys_page_unmap>
  801be8:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801beb:	83 ec 08             	sub    $0x8,%esp
  801bee:	ff 75 f4             	pushl  -0xc(%ebp)
  801bf1:	6a 00                	push   $0x0
  801bf3:	e8 90 f0 ff ff       	call   800c88 <sys_page_unmap>
  801bf8:	83 c4 10             	add    $0x10,%esp
  801bfb:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801bfd:	89 d0                	mov    %edx,%eax
  801bff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c02:	5b                   	pop    %ebx
  801c03:	5e                   	pop    %esi
  801c04:	5d                   	pop    %ebp
  801c05:	c3                   	ret    

00801c06 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c06:	55                   	push   %ebp
  801c07:	89 e5                	mov    %esp,%ebp
  801c09:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c0c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c0f:	50                   	push   %eax
  801c10:	ff 75 08             	pushl  0x8(%ebp)
  801c13:	e8 5c f5 ff ff       	call   801174 <fd_lookup>
  801c18:	83 c4 10             	add    $0x10,%esp
  801c1b:	85 c0                	test   %eax,%eax
  801c1d:	78 18                	js     801c37 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801c1f:	83 ec 0c             	sub    $0xc,%esp
  801c22:	ff 75 f4             	pushl  -0xc(%ebp)
  801c25:	e8 e4 f4 ff ff       	call   80110e <fd2data>
	return _pipeisclosed(fd, p);
  801c2a:	89 c2                	mov    %eax,%edx
  801c2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c2f:	e8 21 fd ff ff       	call   801955 <_pipeisclosed>
  801c34:	83 c4 10             	add    $0x10,%esp
}
  801c37:	c9                   	leave  
  801c38:	c3                   	ret    

00801c39 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c39:	55                   	push   %ebp
  801c3a:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801c3c:	b8 00 00 00 00       	mov    $0x0,%eax
  801c41:	5d                   	pop    %ebp
  801c42:	c3                   	ret    

00801c43 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c43:	55                   	push   %ebp
  801c44:	89 e5                	mov    %esp,%ebp
  801c46:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801c49:	68 68 27 80 00       	push   $0x802768
  801c4e:	ff 75 0c             	pushl  0xc(%ebp)
  801c51:	e8 aa eb ff ff       	call   800800 <strcpy>
	return 0;
}
  801c56:	b8 00 00 00 00       	mov    $0x0,%eax
  801c5b:	c9                   	leave  
  801c5c:	c3                   	ret    

00801c5d <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c5d:	55                   	push   %ebp
  801c5e:	89 e5                	mov    %esp,%ebp
  801c60:	57                   	push   %edi
  801c61:	56                   	push   %esi
  801c62:	53                   	push   %ebx
  801c63:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c69:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c6e:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c74:	eb 2d                	jmp    801ca3 <devcons_write+0x46>
		m = n - tot;
  801c76:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c79:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801c7b:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801c7e:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801c83:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c86:	83 ec 04             	sub    $0x4,%esp
  801c89:	53                   	push   %ebx
  801c8a:	03 45 0c             	add    0xc(%ebp),%eax
  801c8d:	50                   	push   %eax
  801c8e:	57                   	push   %edi
  801c8f:	e8 fe ec ff ff       	call   800992 <memmove>
		sys_cputs(buf, m);
  801c94:	83 c4 08             	add    $0x8,%esp
  801c97:	53                   	push   %ebx
  801c98:	57                   	push   %edi
  801c99:	e8 a9 ee ff ff       	call   800b47 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c9e:	01 de                	add    %ebx,%esi
  801ca0:	83 c4 10             	add    $0x10,%esp
  801ca3:	89 f0                	mov    %esi,%eax
  801ca5:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ca8:	72 cc                	jb     801c76 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801caa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cad:	5b                   	pop    %ebx
  801cae:	5e                   	pop    %esi
  801caf:	5f                   	pop    %edi
  801cb0:	5d                   	pop    %ebp
  801cb1:	c3                   	ret    

00801cb2 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801cb2:	55                   	push   %ebp
  801cb3:	89 e5                	mov    %esp,%ebp
  801cb5:	83 ec 08             	sub    $0x8,%esp
  801cb8:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801cbd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801cc1:	74 2a                	je     801ced <devcons_read+0x3b>
  801cc3:	eb 05                	jmp    801cca <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801cc5:	e8 1a ef ff ff       	call   800be4 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801cca:	e8 96 ee ff ff       	call   800b65 <sys_cgetc>
  801ccf:	85 c0                	test   %eax,%eax
  801cd1:	74 f2                	je     801cc5 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801cd3:	85 c0                	test   %eax,%eax
  801cd5:	78 16                	js     801ced <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801cd7:	83 f8 04             	cmp    $0x4,%eax
  801cda:	74 0c                	je     801ce8 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801cdc:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cdf:	88 02                	mov    %al,(%edx)
	return 1;
  801ce1:	b8 01 00 00 00       	mov    $0x1,%eax
  801ce6:	eb 05                	jmp    801ced <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ce8:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801ced:	c9                   	leave  
  801cee:	c3                   	ret    

00801cef <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801cef:	55                   	push   %ebp
  801cf0:	89 e5                	mov    %esp,%ebp
  801cf2:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801cf5:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf8:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801cfb:	6a 01                	push   $0x1
  801cfd:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d00:	50                   	push   %eax
  801d01:	e8 41 ee ff ff       	call   800b47 <sys_cputs>
}
  801d06:	83 c4 10             	add    $0x10,%esp
  801d09:	c9                   	leave  
  801d0a:	c3                   	ret    

00801d0b <getchar>:

int
getchar(void)
{
  801d0b:	55                   	push   %ebp
  801d0c:	89 e5                	mov    %esp,%ebp
  801d0e:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801d11:	6a 01                	push   $0x1
  801d13:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d16:	50                   	push   %eax
  801d17:	6a 00                	push   $0x0
  801d19:	e8 bc f6 ff ff       	call   8013da <read>
	if (r < 0)
  801d1e:	83 c4 10             	add    $0x10,%esp
  801d21:	85 c0                	test   %eax,%eax
  801d23:	78 0f                	js     801d34 <getchar+0x29>
		return r;
	if (r < 1)
  801d25:	85 c0                	test   %eax,%eax
  801d27:	7e 06                	jle    801d2f <getchar+0x24>
		return -E_EOF;
	return c;
  801d29:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801d2d:	eb 05                	jmp    801d34 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801d2f:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801d34:	c9                   	leave  
  801d35:	c3                   	ret    

00801d36 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801d36:	55                   	push   %ebp
  801d37:	89 e5                	mov    %esp,%ebp
  801d39:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d3c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d3f:	50                   	push   %eax
  801d40:	ff 75 08             	pushl  0x8(%ebp)
  801d43:	e8 2c f4 ff ff       	call   801174 <fd_lookup>
  801d48:	83 c4 10             	add    $0x10,%esp
  801d4b:	85 c0                	test   %eax,%eax
  801d4d:	78 11                	js     801d60 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801d4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d52:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d58:	39 10                	cmp    %edx,(%eax)
  801d5a:	0f 94 c0             	sete   %al
  801d5d:	0f b6 c0             	movzbl %al,%eax
}
  801d60:	c9                   	leave  
  801d61:	c3                   	ret    

00801d62 <opencons>:

int
opencons(void)
{
  801d62:	55                   	push   %ebp
  801d63:	89 e5                	mov    %esp,%ebp
  801d65:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d68:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d6b:	50                   	push   %eax
  801d6c:	e8 b4 f3 ff ff       	call   801125 <fd_alloc>
  801d71:	83 c4 10             	add    $0x10,%esp
		return r;
  801d74:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d76:	85 c0                	test   %eax,%eax
  801d78:	78 3e                	js     801db8 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d7a:	83 ec 04             	sub    $0x4,%esp
  801d7d:	68 07 04 00 00       	push   $0x407
  801d82:	ff 75 f4             	pushl  -0xc(%ebp)
  801d85:	6a 00                	push   $0x0
  801d87:	e8 77 ee ff ff       	call   800c03 <sys_page_alloc>
  801d8c:	83 c4 10             	add    $0x10,%esp
		return r;
  801d8f:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d91:	85 c0                	test   %eax,%eax
  801d93:	78 23                	js     801db8 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801d95:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d9e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801da0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801da3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801daa:	83 ec 0c             	sub    $0xc,%esp
  801dad:	50                   	push   %eax
  801dae:	e8 4b f3 ff ff       	call   8010fe <fd2num>
  801db3:	89 c2                	mov    %eax,%edx
  801db5:	83 c4 10             	add    $0x10,%esp
}
  801db8:	89 d0                	mov    %edx,%eax
  801dba:	c9                   	leave  
  801dbb:	c3                   	ret    

00801dbc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801dbc:	55                   	push   %ebp
  801dbd:	89 e5                	mov    %esp,%ebp
  801dbf:	56                   	push   %esi
  801dc0:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801dc1:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801dc4:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801dca:	e8 f6 ed ff ff       	call   800bc5 <sys_getenvid>
  801dcf:	83 ec 0c             	sub    $0xc,%esp
  801dd2:	ff 75 0c             	pushl  0xc(%ebp)
  801dd5:	ff 75 08             	pushl  0x8(%ebp)
  801dd8:	56                   	push   %esi
  801dd9:	50                   	push   %eax
  801dda:	68 74 27 80 00       	push   $0x802774
  801ddf:	e8 f0 e3 ff ff       	call   8001d4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801de4:	83 c4 18             	add    $0x18,%esp
  801de7:	53                   	push   %ebx
  801de8:	ff 75 10             	pushl  0x10(%ebp)
  801deb:	e8 93 e3 ff ff       	call   800183 <vcprintf>
	cprintf("\n");
  801df0:	c7 04 24 4f 22 80 00 	movl   $0x80224f,(%esp)
  801df7:	e8 d8 e3 ff ff       	call   8001d4 <cprintf>
  801dfc:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801dff:	cc                   	int3   
  801e00:	eb fd                	jmp    801dff <_panic+0x43>

00801e02 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801e02:	55                   	push   %ebp
  801e03:	89 e5                	mov    %esp,%ebp
  801e05:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801e08:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801e0f:	75 31                	jne    801e42 <set_pgfault_handler+0x40>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc(thisenv->env_id, (void*)(UXSTACKTOP - PGSIZE), PTE_P | 
  801e11:	a1 04 40 80 00       	mov    0x804004,%eax
  801e16:	8b 40 48             	mov    0x48(%eax),%eax
  801e19:	83 ec 04             	sub    $0x4,%esp
  801e1c:	6a 07                	push   $0x7
  801e1e:	68 00 f0 bf ee       	push   $0xeebff000
  801e23:	50                   	push   %eax
  801e24:	e8 da ed ff ff       	call   800c03 <sys_page_alloc>
				PTE_U | PTE_W);
		sys_env_set_pgfault_upcall(thisenv->env_id, (void*)_pgfault_upcall);
  801e29:	a1 04 40 80 00       	mov    0x804004,%eax
  801e2e:	8b 40 48             	mov    0x48(%eax),%eax
  801e31:	83 c4 08             	add    $0x8,%esp
  801e34:	68 4c 1e 80 00       	push   $0x801e4c
  801e39:	50                   	push   %eax
  801e3a:	e8 0f ef ff ff       	call   800d4e <sys_env_set_pgfault_upcall>
  801e3f:	83 c4 10             	add    $0x10,%esp

		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801e42:	8b 45 08             	mov    0x8(%ebp),%eax
  801e45:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801e4a:	c9                   	leave  
  801e4b:	c3                   	ret    

00801e4c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e4c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e4d:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e52:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e54:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	addl $8, %esp      // pop utf_fault_va and utf_err
  801e57:	83 c4 08             	add    $0x8,%esp
	movl 32(%esp), %eax  // eax <- [esp + 32]
  801e5a:	8b 44 24 20          	mov    0x20(%esp),%eax
	movl 40(%esp), %ebx  // ebx <- [esp + 40]
  801e5e:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	leal -4(%ebx), %ebx  // ebx <- ebx - 4
  801e62:	8d 5b fc             	lea    -0x4(%ebx),%ebx
	movl %eax, (%ebx)
  801e65:	89 03                	mov    %eax,(%ebx)
	movl %ebx, 40(%esp)  // push trap eip and decrement trap esp manually
  801e67:	89 5c 24 28          	mov    %ebx,0x28(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  801e6b:	61                   	popa   
	addl $4, %esp        // skip eip
  801e6c:	83 c4 04             	add    $0x4,%esp

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	popf
  801e6f:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	pop %esp
  801e70:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801e71:	c3                   	ret    

00801e72 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e72:	55                   	push   %ebp
  801e73:	89 e5                	mov    %esp,%ebp
  801e75:	56                   	push   %esi
  801e76:	53                   	push   %ebx
  801e77:	8b 75 08             	mov    0x8(%ebp),%esi
  801e7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e7d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int ret;
	if (pg) ret = sys_ipc_recv(pg);
  801e80:	85 c0                	test   %eax,%eax
  801e82:	74 0e                	je     801e92 <ipc_recv+0x20>
  801e84:	83 ec 0c             	sub    $0xc,%esp
  801e87:	50                   	push   %eax
  801e88:	e8 26 ef ff ff       	call   800db3 <sys_ipc_recv>
  801e8d:	83 c4 10             	add    $0x10,%esp
  801e90:	eb 10                	jmp    801ea2 <ipc_recv+0x30>
	else ret = sys_ipc_recv((void*)UTOP);
  801e92:	83 ec 0c             	sub    $0xc,%esp
  801e95:	68 00 00 c0 ee       	push   $0xeec00000
  801e9a:	e8 14 ef ff ff       	call   800db3 <sys_ipc_recv>
  801e9f:	83 c4 10             	add    $0x10,%esp
	if (ret) {
  801ea2:	85 c0                	test   %eax,%eax
  801ea4:	74 16                	je     801ebc <ipc_recv+0x4a>
		if (from_env_store) *from_env_store = 0;
  801ea6:	85 f6                	test   %esi,%esi
  801ea8:	74 06                	je     801eb0 <ipc_recv+0x3e>
  801eaa:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  801eb0:	85 db                	test   %ebx,%ebx
  801eb2:	74 2c                	je     801ee0 <ipc_recv+0x6e>
  801eb4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801eba:	eb 24                	jmp    801ee0 <ipc_recv+0x6e>
		return ret;
	}
	if (from_env_store) *from_env_store = thisenv->env_ipc_from;
  801ebc:	85 f6                	test   %esi,%esi
  801ebe:	74 0a                	je     801eca <ipc_recv+0x58>
  801ec0:	a1 04 40 80 00       	mov    0x804004,%eax
  801ec5:	8b 40 74             	mov    0x74(%eax),%eax
  801ec8:	89 06                	mov    %eax,(%esi)
	if (perm_store) *perm_store = thisenv->env_ipc_perm;
  801eca:	85 db                	test   %ebx,%ebx
  801ecc:	74 0a                	je     801ed8 <ipc_recv+0x66>
  801ece:	a1 04 40 80 00       	mov    0x804004,%eax
  801ed3:	8b 40 78             	mov    0x78(%eax),%eax
  801ed6:	89 03                	mov    %eax,(%ebx)

	// panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801ed8:	a1 04 40 80 00       	mov    0x804004,%eax
  801edd:	8b 40 70             	mov    0x70(%eax),%eax
}
  801ee0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ee3:	5b                   	pop    %ebx
  801ee4:	5e                   	pop    %esi
  801ee5:	5d                   	pop    %ebp
  801ee6:	c3                   	ret    

00801ee7 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ee7:	55                   	push   %ebp
  801ee8:	89 e5                	mov    %esp,%ebp
  801eea:	57                   	push   %edi
  801eeb:	56                   	push   %esi
  801eec:	53                   	push   %ebx
  801eed:	83 ec 0c             	sub    $0xc,%esp
  801ef0:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ef3:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ef6:	8b 45 10             	mov    0x10(%ebp),%eax
  801ef9:	85 c0                	test   %eax,%eax
  801efb:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801f00:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	while (true) {
		void* srcva = (pg)? pg: (void*)UTOP;
		int ret = sys_ipc_try_send(to_env, val, srcva, perm);
  801f03:	ff 75 14             	pushl  0x14(%ebp)
  801f06:	53                   	push   %ebx
  801f07:	56                   	push   %esi
  801f08:	57                   	push   %edi
  801f09:	e8 82 ee ff ff       	call   800d90 <sys_ipc_try_send>
		if (ret == 0) break;
  801f0e:	83 c4 10             	add    $0x10,%esp
  801f11:	85 c0                	test   %eax,%eax
  801f13:	74 1e                	je     801f33 <ipc_send+0x4c>
		if (ret != -E_IPC_NOT_RECV) panic("ipc_send: %e", ret);
  801f15:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f18:	74 12                	je     801f2c <ipc_send+0x45>
  801f1a:	50                   	push   %eax
  801f1b:	68 98 27 80 00       	push   $0x802798
  801f20:	6a 39                	push   $0x39
  801f22:	68 a5 27 80 00       	push   $0x8027a5
  801f27:	e8 90 fe ff ff       	call   801dbc <_panic>
		sys_yield();
  801f2c:	e8 b3 ec ff ff       	call   800be4 <sys_yield>
	}
  801f31:	eb d0                	jmp    801f03 <ipc_send+0x1c>
	// panic("ipc_send not implemented");
}
  801f33:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f36:	5b                   	pop    %ebx
  801f37:	5e                   	pop    %esi
  801f38:	5f                   	pop    %edi
  801f39:	5d                   	pop    %ebp
  801f3a:	c3                   	ret    

00801f3b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f3b:	55                   	push   %ebp
  801f3c:	89 e5                	mov    %esp,%ebp
  801f3e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f41:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f46:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f49:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f4f:	8b 52 50             	mov    0x50(%edx),%edx
  801f52:	39 ca                	cmp    %ecx,%edx
  801f54:	75 0d                	jne    801f63 <ipc_find_env+0x28>
			return envs[i].env_id;
  801f56:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f59:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f5e:	8b 40 48             	mov    0x48(%eax),%eax
  801f61:	eb 0f                	jmp    801f72 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f63:	83 c0 01             	add    $0x1,%eax
  801f66:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f6b:	75 d9                	jne    801f46 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f6d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f72:	5d                   	pop    %ebp
  801f73:	c3                   	ret    

00801f74 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f74:	55                   	push   %ebp
  801f75:	89 e5                	mov    %esp,%ebp
  801f77:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f7a:	89 d0                	mov    %edx,%eax
  801f7c:	c1 e8 16             	shr    $0x16,%eax
  801f7f:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f86:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f8b:	f6 c1 01             	test   $0x1,%cl
  801f8e:	74 1d                	je     801fad <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f90:	c1 ea 0c             	shr    $0xc,%edx
  801f93:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f9a:	f6 c2 01             	test   $0x1,%dl
  801f9d:	74 0e                	je     801fad <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f9f:	c1 ea 0c             	shr    $0xc,%edx
  801fa2:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fa9:	ef 
  801faa:	0f b7 c0             	movzwl %ax,%eax
}
  801fad:	5d                   	pop    %ebp
  801fae:	c3                   	ret    
  801faf:	90                   	nop

00801fb0 <__udivdi3>:
  801fb0:	55                   	push   %ebp
  801fb1:	57                   	push   %edi
  801fb2:	56                   	push   %esi
  801fb3:	53                   	push   %ebx
  801fb4:	83 ec 1c             	sub    $0x1c,%esp
  801fb7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801fbb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801fbf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801fc3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801fc7:	85 f6                	test   %esi,%esi
  801fc9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fcd:	89 ca                	mov    %ecx,%edx
  801fcf:	89 f8                	mov    %edi,%eax
  801fd1:	75 3d                	jne    802010 <__udivdi3+0x60>
  801fd3:	39 cf                	cmp    %ecx,%edi
  801fd5:	0f 87 c5 00 00 00    	ja     8020a0 <__udivdi3+0xf0>
  801fdb:	85 ff                	test   %edi,%edi
  801fdd:	89 fd                	mov    %edi,%ebp
  801fdf:	75 0b                	jne    801fec <__udivdi3+0x3c>
  801fe1:	b8 01 00 00 00       	mov    $0x1,%eax
  801fe6:	31 d2                	xor    %edx,%edx
  801fe8:	f7 f7                	div    %edi
  801fea:	89 c5                	mov    %eax,%ebp
  801fec:	89 c8                	mov    %ecx,%eax
  801fee:	31 d2                	xor    %edx,%edx
  801ff0:	f7 f5                	div    %ebp
  801ff2:	89 c1                	mov    %eax,%ecx
  801ff4:	89 d8                	mov    %ebx,%eax
  801ff6:	89 cf                	mov    %ecx,%edi
  801ff8:	f7 f5                	div    %ebp
  801ffa:	89 c3                	mov    %eax,%ebx
  801ffc:	89 d8                	mov    %ebx,%eax
  801ffe:	89 fa                	mov    %edi,%edx
  802000:	83 c4 1c             	add    $0x1c,%esp
  802003:	5b                   	pop    %ebx
  802004:	5e                   	pop    %esi
  802005:	5f                   	pop    %edi
  802006:	5d                   	pop    %ebp
  802007:	c3                   	ret    
  802008:	90                   	nop
  802009:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802010:	39 ce                	cmp    %ecx,%esi
  802012:	77 74                	ja     802088 <__udivdi3+0xd8>
  802014:	0f bd fe             	bsr    %esi,%edi
  802017:	83 f7 1f             	xor    $0x1f,%edi
  80201a:	0f 84 98 00 00 00    	je     8020b8 <__udivdi3+0x108>
  802020:	bb 20 00 00 00       	mov    $0x20,%ebx
  802025:	89 f9                	mov    %edi,%ecx
  802027:	89 c5                	mov    %eax,%ebp
  802029:	29 fb                	sub    %edi,%ebx
  80202b:	d3 e6                	shl    %cl,%esi
  80202d:	89 d9                	mov    %ebx,%ecx
  80202f:	d3 ed                	shr    %cl,%ebp
  802031:	89 f9                	mov    %edi,%ecx
  802033:	d3 e0                	shl    %cl,%eax
  802035:	09 ee                	or     %ebp,%esi
  802037:	89 d9                	mov    %ebx,%ecx
  802039:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80203d:	89 d5                	mov    %edx,%ebp
  80203f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802043:	d3 ed                	shr    %cl,%ebp
  802045:	89 f9                	mov    %edi,%ecx
  802047:	d3 e2                	shl    %cl,%edx
  802049:	89 d9                	mov    %ebx,%ecx
  80204b:	d3 e8                	shr    %cl,%eax
  80204d:	09 c2                	or     %eax,%edx
  80204f:	89 d0                	mov    %edx,%eax
  802051:	89 ea                	mov    %ebp,%edx
  802053:	f7 f6                	div    %esi
  802055:	89 d5                	mov    %edx,%ebp
  802057:	89 c3                	mov    %eax,%ebx
  802059:	f7 64 24 0c          	mull   0xc(%esp)
  80205d:	39 d5                	cmp    %edx,%ebp
  80205f:	72 10                	jb     802071 <__udivdi3+0xc1>
  802061:	8b 74 24 08          	mov    0x8(%esp),%esi
  802065:	89 f9                	mov    %edi,%ecx
  802067:	d3 e6                	shl    %cl,%esi
  802069:	39 c6                	cmp    %eax,%esi
  80206b:	73 07                	jae    802074 <__udivdi3+0xc4>
  80206d:	39 d5                	cmp    %edx,%ebp
  80206f:	75 03                	jne    802074 <__udivdi3+0xc4>
  802071:	83 eb 01             	sub    $0x1,%ebx
  802074:	31 ff                	xor    %edi,%edi
  802076:	89 d8                	mov    %ebx,%eax
  802078:	89 fa                	mov    %edi,%edx
  80207a:	83 c4 1c             	add    $0x1c,%esp
  80207d:	5b                   	pop    %ebx
  80207e:	5e                   	pop    %esi
  80207f:	5f                   	pop    %edi
  802080:	5d                   	pop    %ebp
  802081:	c3                   	ret    
  802082:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802088:	31 ff                	xor    %edi,%edi
  80208a:	31 db                	xor    %ebx,%ebx
  80208c:	89 d8                	mov    %ebx,%eax
  80208e:	89 fa                	mov    %edi,%edx
  802090:	83 c4 1c             	add    $0x1c,%esp
  802093:	5b                   	pop    %ebx
  802094:	5e                   	pop    %esi
  802095:	5f                   	pop    %edi
  802096:	5d                   	pop    %ebp
  802097:	c3                   	ret    
  802098:	90                   	nop
  802099:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020a0:	89 d8                	mov    %ebx,%eax
  8020a2:	f7 f7                	div    %edi
  8020a4:	31 ff                	xor    %edi,%edi
  8020a6:	89 c3                	mov    %eax,%ebx
  8020a8:	89 d8                	mov    %ebx,%eax
  8020aa:	89 fa                	mov    %edi,%edx
  8020ac:	83 c4 1c             	add    $0x1c,%esp
  8020af:	5b                   	pop    %ebx
  8020b0:	5e                   	pop    %esi
  8020b1:	5f                   	pop    %edi
  8020b2:	5d                   	pop    %ebp
  8020b3:	c3                   	ret    
  8020b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020b8:	39 ce                	cmp    %ecx,%esi
  8020ba:	72 0c                	jb     8020c8 <__udivdi3+0x118>
  8020bc:	31 db                	xor    %ebx,%ebx
  8020be:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8020c2:	0f 87 34 ff ff ff    	ja     801ffc <__udivdi3+0x4c>
  8020c8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8020cd:	e9 2a ff ff ff       	jmp    801ffc <__udivdi3+0x4c>
  8020d2:	66 90                	xchg   %ax,%ax
  8020d4:	66 90                	xchg   %ax,%ax
  8020d6:	66 90                	xchg   %ax,%ax
  8020d8:	66 90                	xchg   %ax,%ax
  8020da:	66 90                	xchg   %ax,%ax
  8020dc:	66 90                	xchg   %ax,%ax
  8020de:	66 90                	xchg   %ax,%ax

008020e0 <__umoddi3>:
  8020e0:	55                   	push   %ebp
  8020e1:	57                   	push   %edi
  8020e2:	56                   	push   %esi
  8020e3:	53                   	push   %ebx
  8020e4:	83 ec 1c             	sub    $0x1c,%esp
  8020e7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8020eb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8020ef:	8b 74 24 34          	mov    0x34(%esp),%esi
  8020f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020f7:	85 d2                	test   %edx,%edx
  8020f9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8020fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802101:	89 f3                	mov    %esi,%ebx
  802103:	89 3c 24             	mov    %edi,(%esp)
  802106:	89 74 24 04          	mov    %esi,0x4(%esp)
  80210a:	75 1c                	jne    802128 <__umoddi3+0x48>
  80210c:	39 f7                	cmp    %esi,%edi
  80210e:	76 50                	jbe    802160 <__umoddi3+0x80>
  802110:	89 c8                	mov    %ecx,%eax
  802112:	89 f2                	mov    %esi,%edx
  802114:	f7 f7                	div    %edi
  802116:	89 d0                	mov    %edx,%eax
  802118:	31 d2                	xor    %edx,%edx
  80211a:	83 c4 1c             	add    $0x1c,%esp
  80211d:	5b                   	pop    %ebx
  80211e:	5e                   	pop    %esi
  80211f:	5f                   	pop    %edi
  802120:	5d                   	pop    %ebp
  802121:	c3                   	ret    
  802122:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802128:	39 f2                	cmp    %esi,%edx
  80212a:	89 d0                	mov    %edx,%eax
  80212c:	77 52                	ja     802180 <__umoddi3+0xa0>
  80212e:	0f bd ea             	bsr    %edx,%ebp
  802131:	83 f5 1f             	xor    $0x1f,%ebp
  802134:	75 5a                	jne    802190 <__umoddi3+0xb0>
  802136:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80213a:	0f 82 e0 00 00 00    	jb     802220 <__umoddi3+0x140>
  802140:	39 0c 24             	cmp    %ecx,(%esp)
  802143:	0f 86 d7 00 00 00    	jbe    802220 <__umoddi3+0x140>
  802149:	8b 44 24 08          	mov    0x8(%esp),%eax
  80214d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802151:	83 c4 1c             	add    $0x1c,%esp
  802154:	5b                   	pop    %ebx
  802155:	5e                   	pop    %esi
  802156:	5f                   	pop    %edi
  802157:	5d                   	pop    %ebp
  802158:	c3                   	ret    
  802159:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802160:	85 ff                	test   %edi,%edi
  802162:	89 fd                	mov    %edi,%ebp
  802164:	75 0b                	jne    802171 <__umoddi3+0x91>
  802166:	b8 01 00 00 00       	mov    $0x1,%eax
  80216b:	31 d2                	xor    %edx,%edx
  80216d:	f7 f7                	div    %edi
  80216f:	89 c5                	mov    %eax,%ebp
  802171:	89 f0                	mov    %esi,%eax
  802173:	31 d2                	xor    %edx,%edx
  802175:	f7 f5                	div    %ebp
  802177:	89 c8                	mov    %ecx,%eax
  802179:	f7 f5                	div    %ebp
  80217b:	89 d0                	mov    %edx,%eax
  80217d:	eb 99                	jmp    802118 <__umoddi3+0x38>
  80217f:	90                   	nop
  802180:	89 c8                	mov    %ecx,%eax
  802182:	89 f2                	mov    %esi,%edx
  802184:	83 c4 1c             	add    $0x1c,%esp
  802187:	5b                   	pop    %ebx
  802188:	5e                   	pop    %esi
  802189:	5f                   	pop    %edi
  80218a:	5d                   	pop    %ebp
  80218b:	c3                   	ret    
  80218c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802190:	8b 34 24             	mov    (%esp),%esi
  802193:	bf 20 00 00 00       	mov    $0x20,%edi
  802198:	89 e9                	mov    %ebp,%ecx
  80219a:	29 ef                	sub    %ebp,%edi
  80219c:	d3 e0                	shl    %cl,%eax
  80219e:	89 f9                	mov    %edi,%ecx
  8021a0:	89 f2                	mov    %esi,%edx
  8021a2:	d3 ea                	shr    %cl,%edx
  8021a4:	89 e9                	mov    %ebp,%ecx
  8021a6:	09 c2                	or     %eax,%edx
  8021a8:	89 d8                	mov    %ebx,%eax
  8021aa:	89 14 24             	mov    %edx,(%esp)
  8021ad:	89 f2                	mov    %esi,%edx
  8021af:	d3 e2                	shl    %cl,%edx
  8021b1:	89 f9                	mov    %edi,%ecx
  8021b3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021b7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8021bb:	d3 e8                	shr    %cl,%eax
  8021bd:	89 e9                	mov    %ebp,%ecx
  8021bf:	89 c6                	mov    %eax,%esi
  8021c1:	d3 e3                	shl    %cl,%ebx
  8021c3:	89 f9                	mov    %edi,%ecx
  8021c5:	89 d0                	mov    %edx,%eax
  8021c7:	d3 e8                	shr    %cl,%eax
  8021c9:	89 e9                	mov    %ebp,%ecx
  8021cb:	09 d8                	or     %ebx,%eax
  8021cd:	89 d3                	mov    %edx,%ebx
  8021cf:	89 f2                	mov    %esi,%edx
  8021d1:	f7 34 24             	divl   (%esp)
  8021d4:	89 d6                	mov    %edx,%esi
  8021d6:	d3 e3                	shl    %cl,%ebx
  8021d8:	f7 64 24 04          	mull   0x4(%esp)
  8021dc:	39 d6                	cmp    %edx,%esi
  8021de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021e2:	89 d1                	mov    %edx,%ecx
  8021e4:	89 c3                	mov    %eax,%ebx
  8021e6:	72 08                	jb     8021f0 <__umoddi3+0x110>
  8021e8:	75 11                	jne    8021fb <__umoddi3+0x11b>
  8021ea:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8021ee:	73 0b                	jae    8021fb <__umoddi3+0x11b>
  8021f0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8021f4:	1b 14 24             	sbb    (%esp),%edx
  8021f7:	89 d1                	mov    %edx,%ecx
  8021f9:	89 c3                	mov    %eax,%ebx
  8021fb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8021ff:	29 da                	sub    %ebx,%edx
  802201:	19 ce                	sbb    %ecx,%esi
  802203:	89 f9                	mov    %edi,%ecx
  802205:	89 f0                	mov    %esi,%eax
  802207:	d3 e0                	shl    %cl,%eax
  802209:	89 e9                	mov    %ebp,%ecx
  80220b:	d3 ea                	shr    %cl,%edx
  80220d:	89 e9                	mov    %ebp,%ecx
  80220f:	d3 ee                	shr    %cl,%esi
  802211:	09 d0                	or     %edx,%eax
  802213:	89 f2                	mov    %esi,%edx
  802215:	83 c4 1c             	add    $0x1c,%esp
  802218:	5b                   	pop    %ebx
  802219:	5e                   	pop    %esi
  80221a:	5f                   	pop    %edi
  80221b:	5d                   	pop    %ebp
  80221c:	c3                   	ret    
  80221d:	8d 76 00             	lea    0x0(%esi),%esi
  802220:	29 f9                	sub    %edi,%ecx
  802222:	19 d6                	sbb    %edx,%esi
  802224:	89 74 24 04          	mov    %esi,0x4(%esp)
  802228:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80222c:	e9 18 ff ff ff       	jmp    802149 <__umoddi3+0x69>
