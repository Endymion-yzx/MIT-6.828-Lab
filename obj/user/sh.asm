
obj/user/sh.debug:     file format elf32-i386


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
  80002c:	e8 47 09 00 00       	call   800978 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <_gettoken>:
#define WHITESPACE " \t\r\n"
#define SYMBOLS "<|>&;()"

int
_gettoken(char *s, char **p1, char **p2)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 0c             	sub    $0xc,%esp
  80003c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80003f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int t;

	if (s == 0) {
  800042:	85 db                	test   %ebx,%ebx
  800044:	75 2c                	jne    800072 <_gettoken+0x3f>
		if (debug > 1)
			cprintf("GETTOKEN NULL\n");
		return 0;
  800046:	b8 00 00 00 00       	mov    $0x0,%eax
_gettoken(char *s, char **p1, char **p2)
{
	int t;

	if (s == 0) {
		if (debug > 1)
  80004b:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800052:	0f 8e 3e 01 00 00    	jle    800196 <_gettoken+0x163>
			cprintf("GETTOKEN NULL\n");
  800058:	83 ec 0c             	sub    $0xc,%esp
  80005b:	68 40 32 80 00       	push   $0x803240
  800060:	e8 4c 0a 00 00       	call   800ab1 <cprintf>
  800065:	83 c4 10             	add    $0x10,%esp
		return 0;
  800068:	b8 00 00 00 00       	mov    $0x0,%eax
  80006d:	e9 24 01 00 00       	jmp    800196 <_gettoken+0x163>
	}

	if (debug > 1)
  800072:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800079:	7e 11                	jle    80008c <_gettoken+0x59>
		cprintf("GETTOKEN: %s\n", s);
  80007b:	83 ec 08             	sub    $0x8,%esp
  80007e:	53                   	push   %ebx
  80007f:	68 4f 32 80 00       	push   $0x80324f
  800084:	e8 28 0a 00 00       	call   800ab1 <cprintf>
  800089:	83 c4 10             	add    $0x10,%esp

	*p1 = 0;
  80008c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	*p2 = 0;
  800092:	8b 45 10             	mov    0x10(%ebp),%eax
  800095:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	while (strchr(WHITESPACE, *s))
  80009b:	eb 07                	jmp    8000a4 <_gettoken+0x71>
		*s++ = 0;
  80009d:	83 c3 01             	add    $0x1,%ebx
  8000a0:	c6 43 ff 00          	movb   $0x0,-0x1(%ebx)
		cprintf("GETTOKEN: %s\n", s);

	*p1 = 0;
	*p2 = 0;

	while (strchr(WHITESPACE, *s))
  8000a4:	83 ec 08             	sub    $0x8,%esp
  8000a7:	0f be 03             	movsbl (%ebx),%eax
  8000aa:	50                   	push   %eax
  8000ab:	68 5d 32 80 00       	push   $0x80325d
  8000b0:	e8 23 12 00 00       	call   8012d8 <strchr>
  8000b5:	83 c4 10             	add    $0x10,%esp
  8000b8:	85 c0                	test   %eax,%eax
  8000ba:	75 e1                	jne    80009d <_gettoken+0x6a>
		*s++ = 0;
	if (*s == 0) {
  8000bc:	0f b6 03             	movzbl (%ebx),%eax
  8000bf:	84 c0                	test   %al,%al
  8000c1:	75 2c                	jne    8000ef <_gettoken+0xbc>
		if (debug > 1)
			cprintf("EOL\n");
		return 0;
  8000c3:	b8 00 00 00 00       	mov    $0x0,%eax
	*p2 = 0;

	while (strchr(WHITESPACE, *s))
		*s++ = 0;
	if (*s == 0) {
		if (debug > 1)
  8000c8:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  8000cf:	0f 8e c1 00 00 00    	jle    800196 <_gettoken+0x163>
			cprintf("EOL\n");
  8000d5:	83 ec 0c             	sub    $0xc,%esp
  8000d8:	68 62 32 80 00       	push   $0x803262
  8000dd:	e8 cf 09 00 00       	call   800ab1 <cprintf>
  8000e2:	83 c4 10             	add    $0x10,%esp
		return 0;
  8000e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ea:	e9 a7 00 00 00       	jmp    800196 <_gettoken+0x163>
	}
	if (strchr(SYMBOLS, *s)) {
  8000ef:	83 ec 08             	sub    $0x8,%esp
  8000f2:	0f be c0             	movsbl %al,%eax
  8000f5:	50                   	push   %eax
  8000f6:	68 73 32 80 00       	push   $0x803273
  8000fb:	e8 d8 11 00 00       	call   8012d8 <strchr>
  800100:	83 c4 10             	add    $0x10,%esp
  800103:	85 c0                	test   %eax,%eax
  800105:	74 30                	je     800137 <_gettoken+0x104>
		t = *s;
  800107:	0f be 3b             	movsbl (%ebx),%edi
		*p1 = s;
  80010a:	89 1e                	mov    %ebx,(%esi)
		*s++ = 0;
  80010c:	c6 03 00             	movb   $0x0,(%ebx)
		*p2 = s;
  80010f:	83 c3 01             	add    $0x1,%ebx
  800112:	8b 45 10             	mov    0x10(%ebp),%eax
  800115:	89 18                	mov    %ebx,(%eax)
		if (debug > 1)
			cprintf("TOK %c\n", t);
		return t;
  800117:	89 f8                	mov    %edi,%eax
	if (strchr(SYMBOLS, *s)) {
		t = *s;
		*p1 = s;
		*s++ = 0;
		*p2 = s;
		if (debug > 1)
  800119:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800120:	7e 74                	jle    800196 <_gettoken+0x163>
			cprintf("TOK %c\n", t);
  800122:	83 ec 08             	sub    $0x8,%esp
  800125:	57                   	push   %edi
  800126:	68 67 32 80 00       	push   $0x803267
  80012b:	e8 81 09 00 00       	call   800ab1 <cprintf>
  800130:	83 c4 10             	add    $0x10,%esp
		return t;
  800133:	89 f8                	mov    %edi,%eax
  800135:	eb 5f                	jmp    800196 <_gettoken+0x163>
	}
	*p1 = s;
  800137:	89 1e                	mov    %ebx,(%esi)
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
  800139:	eb 03                	jmp    80013e <_gettoken+0x10b>
		s++;
  80013b:	83 c3 01             	add    $0x1,%ebx
		if (debug > 1)
			cprintf("TOK %c\n", t);
		return t;
	}
	*p1 = s;
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
  80013e:	0f b6 03             	movzbl (%ebx),%eax
  800141:	84 c0                	test   %al,%al
  800143:	74 18                	je     80015d <_gettoken+0x12a>
  800145:	83 ec 08             	sub    $0x8,%esp
  800148:	0f be c0             	movsbl %al,%eax
  80014b:	50                   	push   %eax
  80014c:	68 6f 32 80 00       	push   $0x80326f
  800151:	e8 82 11 00 00       	call   8012d8 <strchr>
  800156:	83 c4 10             	add    $0x10,%esp
  800159:	85 c0                	test   %eax,%eax
  80015b:	74 de                	je     80013b <_gettoken+0x108>
		s++;
	*p2 = s;
  80015d:	8b 45 10             	mov    0x10(%ebp),%eax
  800160:	89 18                	mov    %ebx,(%eax)
		t = **p2;
		**p2 = 0;
		cprintf("WORD: %s\n", *p1);
		**p2 = t;
	}
	return 'w';
  800162:	b8 77 00 00 00       	mov    $0x77,%eax
	}
	*p1 = s;
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
		s++;
	*p2 = s;
	if (debug > 1) {
  800167:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  80016e:	7e 26                	jle    800196 <_gettoken+0x163>
		t = **p2;
  800170:	0f b6 3b             	movzbl (%ebx),%edi
		**p2 = 0;
  800173:	c6 03 00             	movb   $0x0,(%ebx)
		cprintf("WORD: %s\n", *p1);
  800176:	83 ec 08             	sub    $0x8,%esp
  800179:	ff 36                	pushl  (%esi)
  80017b:	68 7b 32 80 00       	push   $0x80327b
  800180:	e8 2c 09 00 00       	call   800ab1 <cprintf>
		**p2 = t;
  800185:	8b 45 10             	mov    0x10(%ebp),%eax
  800188:	8b 00                	mov    (%eax),%eax
  80018a:	89 fa                	mov    %edi,%edx
  80018c:	88 10                	mov    %dl,(%eax)
  80018e:	83 c4 10             	add    $0x10,%esp
	}
	return 'w';
  800191:	b8 77 00 00 00       	mov    $0x77,%eax
}
  800196:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800199:	5b                   	pop    %ebx
  80019a:	5e                   	pop    %esi
  80019b:	5f                   	pop    %edi
  80019c:	5d                   	pop    %ebp
  80019d:	c3                   	ret    

0080019e <gettoken>:

int
gettoken(char *s, char **p1)
{
  80019e:	55                   	push   %ebp
  80019f:	89 e5                	mov    %esp,%ebp
  8001a1:	83 ec 08             	sub    $0x8,%esp
  8001a4:	8b 45 08             	mov    0x8(%ebp),%eax
	static int c, nc;
	static char* np1, *np2;

	if (s) {
  8001a7:	85 c0                	test   %eax,%eax
  8001a9:	74 22                	je     8001cd <gettoken+0x2f>
		nc = _gettoken(s, &np1, &np2);
  8001ab:	83 ec 04             	sub    $0x4,%esp
  8001ae:	68 0c 50 80 00       	push   $0x80500c
  8001b3:	68 10 50 80 00       	push   $0x805010
  8001b8:	50                   	push   %eax
  8001b9:	e8 75 fe ff ff       	call   800033 <_gettoken>
  8001be:	a3 08 50 80 00       	mov    %eax,0x805008
		return 0;
  8001c3:	83 c4 10             	add    $0x10,%esp
  8001c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8001cb:	eb 3a                	jmp    800207 <gettoken+0x69>
	}
	c = nc;
  8001cd:	a1 08 50 80 00       	mov    0x805008,%eax
  8001d2:	a3 04 50 80 00       	mov    %eax,0x805004
	*p1 = np1;
  8001d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001da:	8b 15 10 50 80 00    	mov    0x805010,%edx
  8001e0:	89 10                	mov    %edx,(%eax)
	nc = _gettoken(np2, &np1, &np2);
  8001e2:	83 ec 04             	sub    $0x4,%esp
  8001e5:	68 0c 50 80 00       	push   $0x80500c
  8001ea:	68 10 50 80 00       	push   $0x805010
  8001ef:	ff 35 0c 50 80 00    	pushl  0x80500c
  8001f5:	e8 39 fe ff ff       	call   800033 <_gettoken>
  8001fa:	a3 08 50 80 00       	mov    %eax,0x805008
	return c;
  8001ff:	a1 04 50 80 00       	mov    0x805004,%eax
  800204:	83 c4 10             	add    $0x10,%esp
}
  800207:	c9                   	leave  
  800208:	c3                   	ret    

00800209 <runcmd>:
// runcmd() is called in a forked child,
// so it's OK to manipulate file descriptor state.
#define MAXARGS 16
void
runcmd(char* s)
{
  800209:	55                   	push   %ebp
  80020a:	89 e5                	mov    %esp,%ebp
  80020c:	57                   	push   %edi
  80020d:	56                   	push   %esi
  80020e:	53                   	push   %ebx
  80020f:	81 ec 64 04 00 00    	sub    $0x464,%esp
	char *argv[MAXARGS], *t, argv0buf[BUFSIZ];
	int argc, c, i, r, p[2], fd, pipe_child;

	pipe_child = 0;
	gettoken(s, 0);
  800215:	6a 00                	push   $0x0
  800217:	ff 75 08             	pushl  0x8(%ebp)
  80021a:	e8 7f ff ff ff       	call   80019e <gettoken>
  80021f:	83 c4 10             	add    $0x10,%esp

again:
	argc = 0;
	while (1) {
		switch ((c = gettoken(0, &t))) {
  800222:	8d 5d a4             	lea    -0x5c(%ebp),%ebx

	pipe_child = 0;
	gettoken(s, 0);

again:
	argc = 0;
  800225:	be 00 00 00 00       	mov    $0x0,%esi
	while (1) {
		switch ((c = gettoken(0, &t))) {
  80022a:	83 ec 08             	sub    $0x8,%esp
  80022d:	53                   	push   %ebx
  80022e:	6a 00                	push   $0x0
  800230:	e8 69 ff ff ff       	call   80019e <gettoken>
  800235:	83 c4 10             	add    $0x10,%esp
  800238:	83 f8 3e             	cmp    $0x3e,%eax
  80023b:	0f 84 8f 00 00 00    	je     8002d0 <runcmd+0xc7>
  800241:	83 f8 3e             	cmp    $0x3e,%eax
  800244:	7f 12                	jg     800258 <runcmd+0x4f>
  800246:	85 c0                	test   %eax,%eax
  800248:	0f 84 fe 01 00 00    	je     80044c <runcmd+0x243>
  80024e:	83 f8 3c             	cmp    $0x3c,%eax
  800251:	74 3e                	je     800291 <runcmd+0x88>
  800253:	e9 e2 01 00 00       	jmp    80043a <runcmd+0x231>
  800258:	83 f8 77             	cmp    $0x77,%eax
  80025b:	74 0e                	je     80026b <runcmd+0x62>
  80025d:	83 f8 7c             	cmp    $0x7c,%eax
  800260:	0f 84 e8 00 00 00    	je     80034e <runcmd+0x145>
  800266:	e9 cf 01 00 00       	jmp    80043a <runcmd+0x231>

		case 'w':	// Add an argument
			if (argc == MAXARGS) {
  80026b:	83 fe 10             	cmp    $0x10,%esi
  80026e:	75 15                	jne    800285 <runcmd+0x7c>
				cprintf("too many arguments\n");
  800270:	83 ec 0c             	sub    $0xc,%esp
  800273:	68 85 32 80 00       	push   $0x803285
  800278:	e8 34 08 00 00       	call   800ab1 <cprintf>
				exit();
  80027d:	e8 3c 07 00 00       	call   8009be <exit>
  800282:	83 c4 10             	add    $0x10,%esp
			}
			argv[argc++] = t;
  800285:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  800288:	89 44 b5 a8          	mov    %eax,-0x58(%ebp,%esi,4)
  80028c:	8d 76 01             	lea    0x1(%esi),%esi
			break;
  80028f:	eb 99                	jmp    80022a <runcmd+0x21>

		case '<':	// Input redirection
			// Grab the filename from the argument list
			if (gettoken(0, &t) != 'w') {
  800291:	83 ec 08             	sub    $0x8,%esp
  800294:	8d 45 a4             	lea    -0x5c(%ebp),%eax
  800297:	50                   	push   %eax
  800298:	6a 00                	push   $0x0
  80029a:	e8 ff fe ff ff       	call   80019e <gettoken>
  80029f:	83 c4 10             	add    $0x10,%esp
  8002a2:	83 f8 77             	cmp    $0x77,%eax
  8002a5:	74 15                	je     8002bc <runcmd+0xb3>
				cprintf("syntax error: < not followed by word\n");
  8002a7:	83 ec 0c             	sub    $0xc,%esp
  8002aa:	68 e0 33 80 00       	push   $0x8033e0
  8002af:	e8 fd 07 00 00       	call   800ab1 <cprintf>
				exit();
  8002b4:	e8 05 07 00 00       	call   8009be <exit>
  8002b9:	83 c4 10             	add    $0x10,%esp
			// then check whether 'fd' is 0.
			// If not, dup 'fd' onto file descriptor 0,
			// then close the original 'fd'.

			// LAB 5: Your code here.
			panic("< redirection not implemented");
  8002bc:	83 ec 04             	sub    $0x4,%esp
  8002bf:	68 99 32 80 00       	push   $0x803299
  8002c4:	6a 3a                	push   $0x3a
  8002c6:	68 b7 32 80 00       	push   $0x8032b7
  8002cb:	e8 08 07 00 00       	call   8009d8 <_panic>
			break;

		case '>':	// Output redirection
			// Grab the filename from the argument list
			if (gettoken(0, &t) != 'w') {
  8002d0:	83 ec 08             	sub    $0x8,%esp
  8002d3:	53                   	push   %ebx
  8002d4:	6a 00                	push   $0x0
  8002d6:	e8 c3 fe ff ff       	call   80019e <gettoken>
  8002db:	83 c4 10             	add    $0x10,%esp
  8002de:	83 f8 77             	cmp    $0x77,%eax
  8002e1:	74 15                	je     8002f8 <runcmd+0xef>
				cprintf("syntax error: > not followed by word\n");
  8002e3:	83 ec 0c             	sub    $0xc,%esp
  8002e6:	68 08 34 80 00       	push   $0x803408
  8002eb:	e8 c1 07 00 00       	call   800ab1 <cprintf>
				exit();
  8002f0:	e8 c9 06 00 00       	call   8009be <exit>
  8002f5:	83 c4 10             	add    $0x10,%esp
			}
			if ((fd = open(t, O_WRONLY|O_CREAT|O_TRUNC)) < 0) {
  8002f8:	83 ec 08             	sub    $0x8,%esp
  8002fb:	68 01 03 00 00       	push   $0x301
  800300:	ff 75 a4             	pushl  -0x5c(%ebp)
  800303:	e8 55 20 00 00       	call   80235d <open>
  800308:	89 c7                	mov    %eax,%edi
  80030a:	83 c4 10             	add    $0x10,%esp
  80030d:	85 c0                	test   %eax,%eax
  80030f:	79 19                	jns    80032a <runcmd+0x121>
				cprintf("open %s for write: %e", t, fd);
  800311:	83 ec 04             	sub    $0x4,%esp
  800314:	50                   	push   %eax
  800315:	ff 75 a4             	pushl  -0x5c(%ebp)
  800318:	68 c1 32 80 00       	push   $0x8032c1
  80031d:	e8 8f 07 00 00       	call   800ab1 <cprintf>
				exit();
  800322:	e8 97 06 00 00       	call   8009be <exit>
  800327:	83 c4 10             	add    $0x10,%esp
			}
			if (fd != 1) {
  80032a:	83 ff 01             	cmp    $0x1,%edi
  80032d:	0f 84 f7 fe ff ff    	je     80022a <runcmd+0x21>
				dup(fd, 1);
  800333:	83 ec 08             	sub    $0x8,%esp
  800336:	6a 01                	push   $0x1
  800338:	57                   	push   %edi
  800339:	e8 d4 1a 00 00       	call   801e12 <dup>
				close(fd);
  80033e:	89 3c 24             	mov    %edi,(%esp)
  800341:	e8 7c 1a 00 00       	call   801dc2 <close>
  800346:	83 c4 10             	add    $0x10,%esp
  800349:	e9 dc fe ff ff       	jmp    80022a <runcmd+0x21>
			}
			break;

		case '|':	// Pipe
			if ((r = pipe(p)) < 0) {
  80034e:	83 ec 0c             	sub    $0xc,%esp
  800351:	8d 85 9c fb ff ff    	lea    -0x464(%ebp),%eax
  800357:	50                   	push   %eax
  800358:	e8 ca 28 00 00       	call   802c27 <pipe>
  80035d:	83 c4 10             	add    $0x10,%esp
  800360:	85 c0                	test   %eax,%eax
  800362:	79 16                	jns    80037a <runcmd+0x171>
				cprintf("pipe: %e", r);
  800364:	83 ec 08             	sub    $0x8,%esp
  800367:	50                   	push   %eax
  800368:	68 d7 32 80 00       	push   $0x8032d7
  80036d:	e8 3f 07 00 00       	call   800ab1 <cprintf>
				exit();
  800372:	e8 47 06 00 00       	call   8009be <exit>
  800377:	83 c4 10             	add    $0x10,%esp
			}
			if (debug)
  80037a:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800381:	74 1c                	je     80039f <runcmd+0x196>
				cprintf("PIPE: %d %d\n", p[0], p[1]);
  800383:	83 ec 04             	sub    $0x4,%esp
  800386:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  80038c:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  800392:	68 e0 32 80 00       	push   $0x8032e0
  800397:	e8 15 07 00 00       	call   800ab1 <cprintf>
  80039c:	83 c4 10             	add    $0x10,%esp
			if ((r = fork()) < 0) {
  80039f:	e8 cd 15 00 00       	call   801971 <fork>
  8003a4:	89 c7                	mov    %eax,%edi
  8003a6:	85 c0                	test   %eax,%eax
  8003a8:	79 16                	jns    8003c0 <runcmd+0x1b7>
				cprintf("fork: %e", r);
  8003aa:	83 ec 08             	sub    $0x8,%esp
  8003ad:	50                   	push   %eax
  8003ae:	68 ed 32 80 00       	push   $0x8032ed
  8003b3:	e8 f9 06 00 00       	call   800ab1 <cprintf>
				exit();
  8003b8:	e8 01 06 00 00       	call   8009be <exit>
  8003bd:	83 c4 10             	add    $0x10,%esp
			}
			if (r == 0) {
  8003c0:	85 ff                	test   %edi,%edi
  8003c2:	75 3c                	jne    800400 <runcmd+0x1f7>
				if (p[0] != 0) {
  8003c4:	8b 85 9c fb ff ff    	mov    -0x464(%ebp),%eax
  8003ca:	85 c0                	test   %eax,%eax
  8003cc:	74 1c                	je     8003ea <runcmd+0x1e1>
					dup(p[0], 0);
  8003ce:	83 ec 08             	sub    $0x8,%esp
  8003d1:	6a 00                	push   $0x0
  8003d3:	50                   	push   %eax
  8003d4:	e8 39 1a 00 00       	call   801e12 <dup>
					close(p[0]);
  8003d9:	83 c4 04             	add    $0x4,%esp
  8003dc:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  8003e2:	e8 db 19 00 00       	call   801dc2 <close>
  8003e7:	83 c4 10             	add    $0x10,%esp
				}
				close(p[1]);
  8003ea:	83 ec 0c             	sub    $0xc,%esp
  8003ed:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  8003f3:	e8 ca 19 00 00       	call   801dc2 <close>
				goto again;
  8003f8:	83 c4 10             	add    $0x10,%esp
  8003fb:	e9 25 fe ff ff       	jmp    800225 <runcmd+0x1c>
			} else {
				pipe_child = r;
				if (p[1] != 1) {
  800400:	8b 85 a0 fb ff ff    	mov    -0x460(%ebp),%eax
  800406:	83 f8 01             	cmp    $0x1,%eax
  800409:	74 1c                	je     800427 <runcmd+0x21e>
					dup(p[1], 1);
  80040b:	83 ec 08             	sub    $0x8,%esp
  80040e:	6a 01                	push   $0x1
  800410:	50                   	push   %eax
  800411:	e8 fc 19 00 00       	call   801e12 <dup>
					close(p[1]);
  800416:	83 c4 04             	add    $0x4,%esp
  800419:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  80041f:	e8 9e 19 00 00       	call   801dc2 <close>
  800424:	83 c4 10             	add    $0x10,%esp
				}
				close(p[0]);
  800427:	83 ec 0c             	sub    $0xc,%esp
  80042a:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  800430:	e8 8d 19 00 00       	call   801dc2 <close>
				goto runit;
  800435:	83 c4 10             	add    $0x10,%esp
  800438:	eb 17                	jmp    800451 <runcmd+0x248>
		case 0:		// String is complete
			// Run the current command!
			goto runit;

		default:
			panic("bad return %d from gettoken", c);
  80043a:	50                   	push   %eax
  80043b:	68 f6 32 80 00       	push   $0x8032f6
  800440:	6a 70                	push   $0x70
  800442:	68 b7 32 80 00       	push   $0x8032b7
  800447:	e8 8c 05 00 00       	call   8009d8 <_panic>
runcmd(char* s)
{
	char *argv[MAXARGS], *t, argv0buf[BUFSIZ];
	int argc, c, i, r, p[2], fd, pipe_child;

	pipe_child = 0;
  80044c:	bf 00 00 00 00       	mov    $0x0,%edi
		}
	}

runit:
	// Return immediately if command line was empty.
	if(argc == 0) {
  800451:	85 f6                	test   %esi,%esi
  800453:	75 22                	jne    800477 <runcmd+0x26e>
		if (debug)
  800455:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80045c:	0f 84 96 01 00 00    	je     8005f8 <runcmd+0x3ef>
			cprintf("EMPTY COMMAND\n");
  800462:	83 ec 0c             	sub    $0xc,%esp
  800465:	68 12 33 80 00       	push   $0x803312
  80046a:	e8 42 06 00 00       	call   800ab1 <cprintf>
  80046f:	83 c4 10             	add    $0x10,%esp
  800472:	e9 81 01 00 00       	jmp    8005f8 <runcmd+0x3ef>

	// Clean up command line.
	// Read all commands from the filesystem: add an initial '/' to
	// the command name.
	// This essentially acts like 'PATH=/'.
	if (argv[0][0] != '/') {
  800477:	8b 45 a8             	mov    -0x58(%ebp),%eax
  80047a:	80 38 2f             	cmpb   $0x2f,(%eax)
  80047d:	74 23                	je     8004a2 <runcmd+0x299>
		argv0buf[0] = '/';
  80047f:	c6 85 a4 fb ff ff 2f 	movb   $0x2f,-0x45c(%ebp)
		strcpy(argv0buf + 1, argv[0]);
  800486:	83 ec 08             	sub    $0x8,%esp
  800489:	50                   	push   %eax
  80048a:	8d 9d a4 fb ff ff    	lea    -0x45c(%ebp),%ebx
  800490:	8d 85 a5 fb ff ff    	lea    -0x45b(%ebp),%eax
  800496:	50                   	push   %eax
  800497:	e8 34 0d 00 00       	call   8011d0 <strcpy>
		argv[0] = argv0buf;
  80049c:	89 5d a8             	mov    %ebx,-0x58(%ebp)
  80049f:	83 c4 10             	add    $0x10,%esp
	}
	argv[argc] = 0;
  8004a2:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
  8004a9:	00 

	// Print the command.
	if (debug) {
  8004aa:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8004b1:	74 49                	je     8004fc <runcmd+0x2f3>
		cprintf("[%08x] SPAWN:", thisenv->env_id);
  8004b3:	a1 24 54 80 00       	mov    0x805424,%eax
  8004b8:	8b 40 48             	mov    0x48(%eax),%eax
  8004bb:	83 ec 08             	sub    $0x8,%esp
  8004be:	50                   	push   %eax
  8004bf:	68 21 33 80 00       	push   $0x803321
  8004c4:	e8 e8 05 00 00       	call   800ab1 <cprintf>
  8004c9:	8d 5d a8             	lea    -0x58(%ebp),%ebx
		for (i = 0; argv[i]; i++)
  8004cc:	83 c4 10             	add    $0x10,%esp
  8004cf:	eb 11                	jmp    8004e2 <runcmd+0x2d9>
			cprintf(" %s", argv[i]);
  8004d1:	83 ec 08             	sub    $0x8,%esp
  8004d4:	50                   	push   %eax
  8004d5:	68 a9 33 80 00       	push   $0x8033a9
  8004da:	e8 d2 05 00 00       	call   800ab1 <cprintf>
  8004df:	83 c4 10             	add    $0x10,%esp
  8004e2:	83 c3 04             	add    $0x4,%ebx
	argv[argc] = 0;

	// Print the command.
	if (debug) {
		cprintf("[%08x] SPAWN:", thisenv->env_id);
		for (i = 0; argv[i]; i++)
  8004e5:	8b 43 fc             	mov    -0x4(%ebx),%eax
  8004e8:	85 c0                	test   %eax,%eax
  8004ea:	75 e5                	jne    8004d1 <runcmd+0x2c8>
			cprintf(" %s", argv[i]);
		cprintf("\n");
  8004ec:	83 ec 0c             	sub    $0xc,%esp
  8004ef:	68 60 32 80 00       	push   $0x803260
  8004f4:	e8 b8 05 00 00       	call   800ab1 <cprintf>
  8004f9:	83 c4 10             	add    $0x10,%esp
	}

	// Spawn the command!
	if ((r = spawn(argv[0], (const char**) argv)) < 0)
  8004fc:	83 ec 08             	sub    $0x8,%esp
  8004ff:	8d 45 a8             	lea    -0x58(%ebp),%eax
  800502:	50                   	push   %eax
  800503:	ff 75 a8             	pushl  -0x58(%ebp)
  800506:	e8 06 20 00 00       	call   802511 <spawn>
  80050b:	89 c3                	mov    %eax,%ebx
  80050d:	83 c4 10             	add    $0x10,%esp
  800510:	85 c0                	test   %eax,%eax
  800512:	0f 89 c3 00 00 00    	jns    8005db <runcmd+0x3d2>
		cprintf("spawn %s: %e\n", argv[0], r);
  800518:	83 ec 04             	sub    $0x4,%esp
  80051b:	50                   	push   %eax
  80051c:	ff 75 a8             	pushl  -0x58(%ebp)
  80051f:	68 2f 33 80 00       	push   $0x80332f
  800524:	e8 88 05 00 00       	call   800ab1 <cprintf>

	// In the parent, close all file descriptors and wait for the
	// spawned command to exit.
	close_all();
  800529:	e8 bf 18 00 00       	call   801ded <close_all>
  80052e:	83 c4 10             	add    $0x10,%esp
  800531:	eb 4c                	jmp    80057f <runcmd+0x376>
	if (r >= 0) {
		if (debug)
			cprintf("[%08x] WAIT %s %08x\n", thisenv->env_id, argv[0], r);
  800533:	a1 24 54 80 00       	mov    0x805424,%eax
  800538:	8b 40 48             	mov    0x48(%eax),%eax
  80053b:	53                   	push   %ebx
  80053c:	ff 75 a8             	pushl  -0x58(%ebp)
  80053f:	50                   	push   %eax
  800540:	68 3d 33 80 00       	push   $0x80333d
  800545:	e8 67 05 00 00       	call   800ab1 <cprintf>
  80054a:	83 c4 10             	add    $0x10,%esp
		wait(r);
  80054d:	83 ec 0c             	sub    $0xc,%esp
  800550:	53                   	push   %ebx
  800551:	e8 57 28 00 00       	call   802dad <wait>
		if (debug)
  800556:	83 c4 10             	add    $0x10,%esp
  800559:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800560:	0f 84 8c 00 00 00    	je     8005f2 <runcmd+0x3e9>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  800566:	a1 24 54 80 00       	mov    0x805424,%eax
  80056b:	8b 40 48             	mov    0x48(%eax),%eax
  80056e:	83 ec 08             	sub    $0x8,%esp
  800571:	50                   	push   %eax
  800572:	68 52 33 80 00       	push   $0x803352
  800577:	e8 35 05 00 00       	call   800ab1 <cprintf>
  80057c:	83 c4 10             	add    $0x10,%esp
	}

	// If we were the left-hand part of a pipe,
	// wait for the right-hand part to finish.
	if (pipe_child) {
  80057f:	85 ff                	test   %edi,%edi
  800581:	74 51                	je     8005d4 <runcmd+0x3cb>
		if (debug)
  800583:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80058a:	74 1a                	je     8005a6 <runcmd+0x39d>
			cprintf("[%08x] WAIT pipe_child %08x\n", thisenv->env_id, pipe_child);
  80058c:	a1 24 54 80 00       	mov    0x805424,%eax
  800591:	8b 40 48             	mov    0x48(%eax),%eax
  800594:	83 ec 04             	sub    $0x4,%esp
  800597:	57                   	push   %edi
  800598:	50                   	push   %eax
  800599:	68 68 33 80 00       	push   $0x803368
  80059e:	e8 0e 05 00 00       	call   800ab1 <cprintf>
  8005a3:	83 c4 10             	add    $0x10,%esp
		wait(pipe_child);
  8005a6:	83 ec 0c             	sub    $0xc,%esp
  8005a9:	57                   	push   %edi
  8005aa:	e8 fe 27 00 00       	call   802dad <wait>
		if (debug)
  8005af:	83 c4 10             	add    $0x10,%esp
  8005b2:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8005b9:	74 19                	je     8005d4 <runcmd+0x3cb>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  8005bb:	a1 24 54 80 00       	mov    0x805424,%eax
  8005c0:	8b 40 48             	mov    0x48(%eax),%eax
  8005c3:	83 ec 08             	sub    $0x8,%esp
  8005c6:	50                   	push   %eax
  8005c7:	68 52 33 80 00       	push   $0x803352
  8005cc:	e8 e0 04 00 00       	call   800ab1 <cprintf>
  8005d1:	83 c4 10             	add    $0x10,%esp
	}

	// Done!
	exit();
  8005d4:	e8 e5 03 00 00       	call   8009be <exit>
  8005d9:	eb 1d                	jmp    8005f8 <runcmd+0x3ef>
	if ((r = spawn(argv[0], (const char**) argv)) < 0)
		cprintf("spawn %s: %e\n", argv[0], r);

	// In the parent, close all file descriptors and wait for the
	// spawned command to exit.
	close_all();
  8005db:	e8 0d 18 00 00       	call   801ded <close_all>
	if (r >= 0) {
		if (debug)
  8005e0:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8005e7:	0f 84 60 ff ff ff    	je     80054d <runcmd+0x344>
  8005ed:	e9 41 ff ff ff       	jmp    800533 <runcmd+0x32a>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
	}

	// If we were the left-hand part of a pipe,
	// wait for the right-hand part to finish.
	if (pipe_child) {
  8005f2:	85 ff                	test   %edi,%edi
  8005f4:	75 b0                	jne    8005a6 <runcmd+0x39d>
  8005f6:	eb dc                	jmp    8005d4 <runcmd+0x3cb>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
	}

	// Done!
	exit();
}
  8005f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005fb:	5b                   	pop    %ebx
  8005fc:	5e                   	pop    %esi
  8005fd:	5f                   	pop    %edi
  8005fe:	5d                   	pop    %ebp
  8005ff:	c3                   	ret    

00800600 <usage>:
}


void
usage(void)
{
  800600:	55                   	push   %ebp
  800601:	89 e5                	mov    %esp,%ebp
  800603:	83 ec 14             	sub    $0x14,%esp
	cprintf("usage: sh [-dix] [command-file]\n");
  800606:	68 30 34 80 00       	push   $0x803430
  80060b:	e8 a1 04 00 00       	call   800ab1 <cprintf>
	exit();
  800610:	e8 a9 03 00 00       	call   8009be <exit>
}
  800615:	83 c4 10             	add    $0x10,%esp
  800618:	c9                   	leave  
  800619:	c3                   	ret    

0080061a <umain>:

void
umain(int argc, char **argv)
{
  80061a:	55                   	push   %ebp
  80061b:	89 e5                	mov    %esp,%ebp
  80061d:	57                   	push   %edi
  80061e:	56                   	push   %esi
  80061f:	53                   	push   %ebx
  800620:	83 ec 30             	sub    $0x30,%esp
  800623:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
	argstart(&argc, argv, &args);
  800626:	8d 45 d8             	lea    -0x28(%ebp),%eax
  800629:	50                   	push   %eax
  80062a:	57                   	push   %edi
  80062b:	8d 45 08             	lea    0x8(%ebp),%eax
  80062e:	50                   	push   %eax
  80062f:	e8 9a 14 00 00       	call   801ace <argstart>
	while ((r = argnext(&args)) >= 0)
  800634:	83 c4 10             	add    $0x10,%esp
{
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
  800637:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
umain(int argc, char **argv)
{
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
  80063e:	be 3f 00 00 00       	mov    $0x3f,%esi
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
  800643:	8d 5d d8             	lea    -0x28(%ebp),%ebx
  800646:	eb 2f                	jmp    800677 <umain+0x5d>
		switch (r) {
  800648:	83 f8 69             	cmp    $0x69,%eax
  80064b:	74 25                	je     800672 <umain+0x58>
  80064d:	83 f8 78             	cmp    $0x78,%eax
  800650:	74 07                	je     800659 <umain+0x3f>
  800652:	83 f8 64             	cmp    $0x64,%eax
  800655:	75 14                	jne    80066b <umain+0x51>
  800657:	eb 09                	jmp    800662 <umain+0x48>
			break;
		case 'i':
			interactive = 1;
			break;
		case 'x':
			echocmds = 1;
  800659:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  800660:	eb 15                	jmp    800677 <umain+0x5d>
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
		switch (r) {
		case 'd':
			debug++;
  800662:	83 05 00 50 80 00 01 	addl   $0x1,0x805000
			break;
  800669:	eb 0c                	jmp    800677 <umain+0x5d>
			break;
		case 'x':
			echocmds = 1;
			break;
		default:
			usage();
  80066b:	e8 90 ff ff ff       	call   800600 <usage>
  800670:	eb 05                	jmp    800677 <umain+0x5d>
		switch (r) {
		case 'd':
			debug++;
			break;
		case 'i':
			interactive = 1;
  800672:	be 01 00 00 00       	mov    $0x1,%esi
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
  800677:	83 ec 0c             	sub    $0xc,%esp
  80067a:	53                   	push   %ebx
  80067b:	e8 7e 14 00 00       	call   801afe <argnext>
  800680:	83 c4 10             	add    $0x10,%esp
  800683:	85 c0                	test   %eax,%eax
  800685:	79 c1                	jns    800648 <umain+0x2e>
			break;
		default:
			usage();
		}

	if (argc > 2)
  800687:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  80068b:	7e 05                	jle    800692 <umain+0x78>
		usage();
  80068d:	e8 6e ff ff ff       	call   800600 <usage>
	if (argc == 2) {
  800692:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  800696:	75 56                	jne    8006ee <umain+0xd4>
		close(0);
  800698:	83 ec 0c             	sub    $0xc,%esp
  80069b:	6a 00                	push   $0x0
  80069d:	e8 20 17 00 00       	call   801dc2 <close>
		if ((r = open(argv[1], O_RDONLY)) < 0)
  8006a2:	83 c4 08             	add    $0x8,%esp
  8006a5:	6a 00                	push   $0x0
  8006a7:	ff 77 04             	pushl  0x4(%edi)
  8006aa:	e8 ae 1c 00 00       	call   80235d <open>
  8006af:	83 c4 10             	add    $0x10,%esp
  8006b2:	85 c0                	test   %eax,%eax
  8006b4:	79 1b                	jns    8006d1 <umain+0xb7>
			panic("open %s: %e", argv[1], r);
  8006b6:	83 ec 0c             	sub    $0xc,%esp
  8006b9:	50                   	push   %eax
  8006ba:	ff 77 04             	pushl  0x4(%edi)
  8006bd:	68 85 33 80 00       	push   $0x803385
  8006c2:	68 20 01 00 00       	push   $0x120
  8006c7:	68 b7 32 80 00       	push   $0x8032b7
  8006cc:	e8 07 03 00 00       	call   8009d8 <_panic>
		assert(r == 0);
  8006d1:	85 c0                	test   %eax,%eax
  8006d3:	74 19                	je     8006ee <umain+0xd4>
  8006d5:	68 91 33 80 00       	push   $0x803391
  8006da:	68 98 33 80 00       	push   $0x803398
  8006df:	68 21 01 00 00       	push   $0x121
  8006e4:	68 b7 32 80 00       	push   $0x8032b7
  8006e9:	e8 ea 02 00 00       	call   8009d8 <_panic>
	}
	if (interactive == '?')
  8006ee:	83 fe 3f             	cmp    $0x3f,%esi
  8006f1:	75 0f                	jne    800702 <umain+0xe8>
		interactive = iscons(0);
  8006f3:	83 ec 0c             	sub    $0xc,%esp
  8006f6:	6a 00                	push   $0x0
  8006f8:	e8 f5 01 00 00       	call   8008f2 <iscons>
  8006fd:	89 c6                	mov    %eax,%esi
  8006ff:	83 c4 10             	add    $0x10,%esp
  800702:	85 f6                	test   %esi,%esi
  800704:	b8 00 00 00 00       	mov    $0x0,%eax
  800709:	bf ad 33 80 00       	mov    $0x8033ad,%edi
  80070e:	0f 44 f8             	cmove  %eax,%edi

	while (1) {
		char *buf;

		buf = readline(interactive ? "$ " : NULL);
  800711:	83 ec 0c             	sub    $0xc,%esp
  800714:	57                   	push   %edi
  800715:	e8 8a 09 00 00       	call   8010a4 <readline>
  80071a:	89 c3                	mov    %eax,%ebx
		if (buf == NULL) {
  80071c:	83 c4 10             	add    $0x10,%esp
  80071f:	85 c0                	test   %eax,%eax
  800721:	75 1e                	jne    800741 <umain+0x127>
			if (debug)
  800723:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80072a:	74 10                	je     80073c <umain+0x122>
				cprintf("EXITING\n");
  80072c:	83 ec 0c             	sub    $0xc,%esp
  80072f:	68 b0 33 80 00       	push   $0x8033b0
  800734:	e8 78 03 00 00       	call   800ab1 <cprintf>
  800739:	83 c4 10             	add    $0x10,%esp
			exit();	// end of file
  80073c:	e8 7d 02 00 00       	call   8009be <exit>
		}
		if (debug)
  800741:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800748:	74 11                	je     80075b <umain+0x141>
			cprintf("LINE: %s\n", buf);
  80074a:	83 ec 08             	sub    $0x8,%esp
  80074d:	53                   	push   %ebx
  80074e:	68 b9 33 80 00       	push   $0x8033b9
  800753:	e8 59 03 00 00       	call   800ab1 <cprintf>
  800758:	83 c4 10             	add    $0x10,%esp
		if (buf[0] == '#')
  80075b:	80 3b 23             	cmpb   $0x23,(%ebx)
  80075e:	74 b1                	je     800711 <umain+0xf7>
			continue;
		if (echocmds)
  800760:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800764:	74 11                	je     800777 <umain+0x15d>
			printf("# %s\n", buf);
  800766:	83 ec 08             	sub    $0x8,%esp
  800769:	53                   	push   %ebx
  80076a:	68 c3 33 80 00       	push   $0x8033c3
  80076f:	e8 87 1d 00 00       	call   8024fb <printf>
  800774:	83 c4 10             	add    $0x10,%esp
		if (debug)
  800777:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80077e:	74 10                	je     800790 <umain+0x176>
			cprintf("BEFORE FORK\n");
  800780:	83 ec 0c             	sub    $0xc,%esp
  800783:	68 c9 33 80 00       	push   $0x8033c9
  800788:	e8 24 03 00 00       	call   800ab1 <cprintf>
  80078d:	83 c4 10             	add    $0x10,%esp
		if ((r = fork()) < 0)
  800790:	e8 dc 11 00 00       	call   801971 <fork>
  800795:	89 c6                	mov    %eax,%esi
  800797:	85 c0                	test   %eax,%eax
  800799:	79 15                	jns    8007b0 <umain+0x196>
			panic("fork: %e", r);
  80079b:	50                   	push   %eax
  80079c:	68 ed 32 80 00       	push   $0x8032ed
  8007a1:	68 38 01 00 00       	push   $0x138
  8007a6:	68 b7 32 80 00       	push   $0x8032b7
  8007ab:	e8 28 02 00 00       	call   8009d8 <_panic>
		if (debug)
  8007b0:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8007b7:	74 11                	je     8007ca <umain+0x1b0>
			cprintf("FORK: %d\n", r);
  8007b9:	83 ec 08             	sub    $0x8,%esp
  8007bc:	50                   	push   %eax
  8007bd:	68 d6 33 80 00       	push   $0x8033d6
  8007c2:	e8 ea 02 00 00       	call   800ab1 <cprintf>
  8007c7:	83 c4 10             	add    $0x10,%esp
		if (r == 0) {
  8007ca:	85 f6                	test   %esi,%esi
  8007cc:	75 16                	jne    8007e4 <umain+0x1ca>
			runcmd(buf);
  8007ce:	83 ec 0c             	sub    $0xc,%esp
  8007d1:	53                   	push   %ebx
  8007d2:	e8 32 fa ff ff       	call   800209 <runcmd>
			exit();
  8007d7:	e8 e2 01 00 00       	call   8009be <exit>
  8007dc:	83 c4 10             	add    $0x10,%esp
  8007df:	e9 2d ff ff ff       	jmp    800711 <umain+0xf7>
		} else
			wait(r);
  8007e4:	83 ec 0c             	sub    $0xc,%esp
  8007e7:	56                   	push   %esi
  8007e8:	e8 c0 25 00 00       	call   802dad <wait>
  8007ed:	83 c4 10             	add    $0x10,%esp
  8007f0:	e9 1c ff ff ff       	jmp    800711 <umain+0xf7>

008007f5 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8007f5:	55                   	push   %ebp
  8007f6:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8007f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8007fd:	5d                   	pop    %ebp
  8007fe:	c3                   	ret    

008007ff <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8007ff:	55                   	push   %ebp
  800800:	89 e5                	mov    %esp,%ebp
  800802:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800805:	68 51 34 80 00       	push   $0x803451
  80080a:	ff 75 0c             	pushl  0xc(%ebp)
  80080d:	e8 be 09 00 00       	call   8011d0 <strcpy>
	return 0;
}
  800812:	b8 00 00 00 00       	mov    $0x0,%eax
  800817:	c9                   	leave  
  800818:	c3                   	ret    

00800819 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800819:	55                   	push   %ebp
  80081a:	89 e5                	mov    %esp,%ebp
  80081c:	57                   	push   %edi
  80081d:	56                   	push   %esi
  80081e:	53                   	push   %ebx
  80081f:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800825:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80082a:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800830:	eb 2d                	jmp    80085f <devcons_write+0x46>
		m = n - tot;
  800832:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800835:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800837:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80083a:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80083f:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800842:	83 ec 04             	sub    $0x4,%esp
  800845:	53                   	push   %ebx
  800846:	03 45 0c             	add    0xc(%ebp),%eax
  800849:	50                   	push   %eax
  80084a:	57                   	push   %edi
  80084b:	e8 12 0b 00 00       	call   801362 <memmove>
		sys_cputs(buf, m);
  800850:	83 c4 08             	add    $0x8,%esp
  800853:	53                   	push   %ebx
  800854:	57                   	push   %edi
  800855:	e8 bd 0c 00 00       	call   801517 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80085a:	01 de                	add    %ebx,%esi
  80085c:	83 c4 10             	add    $0x10,%esp
  80085f:	89 f0                	mov    %esi,%eax
  800861:	3b 75 10             	cmp    0x10(%ebp),%esi
  800864:	72 cc                	jb     800832 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800866:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800869:	5b                   	pop    %ebx
  80086a:	5e                   	pop    %esi
  80086b:	5f                   	pop    %edi
  80086c:	5d                   	pop    %ebp
  80086d:	c3                   	ret    

0080086e <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80086e:	55                   	push   %ebp
  80086f:	89 e5                	mov    %esp,%ebp
  800871:	83 ec 08             	sub    $0x8,%esp
  800874:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800879:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80087d:	74 2a                	je     8008a9 <devcons_read+0x3b>
  80087f:	eb 05                	jmp    800886 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800881:	e8 2e 0d 00 00       	call   8015b4 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800886:	e8 aa 0c 00 00       	call   801535 <sys_cgetc>
  80088b:	85 c0                	test   %eax,%eax
  80088d:	74 f2                	je     800881 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80088f:	85 c0                	test   %eax,%eax
  800891:	78 16                	js     8008a9 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800893:	83 f8 04             	cmp    $0x4,%eax
  800896:	74 0c                	je     8008a4 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800898:	8b 55 0c             	mov    0xc(%ebp),%edx
  80089b:	88 02                	mov    %al,(%edx)
	return 1;
  80089d:	b8 01 00 00 00       	mov    $0x1,%eax
  8008a2:	eb 05                	jmp    8008a9 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8008a4:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8008a9:	c9                   	leave  
  8008aa:	c3                   	ret    

008008ab <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8008ab:	55                   	push   %ebp
  8008ac:	89 e5                	mov    %esp,%ebp
  8008ae:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8008b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b4:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8008b7:	6a 01                	push   $0x1
  8008b9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8008bc:	50                   	push   %eax
  8008bd:	e8 55 0c 00 00       	call   801517 <sys_cputs>
}
  8008c2:	83 c4 10             	add    $0x10,%esp
  8008c5:	c9                   	leave  
  8008c6:	c3                   	ret    

008008c7 <getchar>:

int
getchar(void)
{
  8008c7:	55                   	push   %ebp
  8008c8:	89 e5                	mov    %esp,%ebp
  8008ca:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8008cd:	6a 01                	push   $0x1
  8008cf:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8008d2:	50                   	push   %eax
  8008d3:	6a 00                	push   $0x0
  8008d5:	e8 24 16 00 00       	call   801efe <read>
	if (r < 0)
  8008da:	83 c4 10             	add    $0x10,%esp
  8008dd:	85 c0                	test   %eax,%eax
  8008df:	78 0f                	js     8008f0 <getchar+0x29>
		return r;
	if (r < 1)
  8008e1:	85 c0                	test   %eax,%eax
  8008e3:	7e 06                	jle    8008eb <getchar+0x24>
		return -E_EOF;
	return c;
  8008e5:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8008e9:	eb 05                	jmp    8008f0 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8008eb:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8008f0:	c9                   	leave  
  8008f1:	c3                   	ret    

008008f2 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8008f2:	55                   	push   %ebp
  8008f3:	89 e5                	mov    %esp,%ebp
  8008f5:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8008f8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008fb:	50                   	push   %eax
  8008fc:	ff 75 08             	pushl  0x8(%ebp)
  8008ff:	e8 94 13 00 00       	call   801c98 <fd_lookup>
  800904:	83 c4 10             	add    $0x10,%esp
  800907:	85 c0                	test   %eax,%eax
  800909:	78 11                	js     80091c <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80090b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80090e:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800914:	39 10                	cmp    %edx,(%eax)
  800916:	0f 94 c0             	sete   %al
  800919:	0f b6 c0             	movzbl %al,%eax
}
  80091c:	c9                   	leave  
  80091d:	c3                   	ret    

0080091e <opencons>:

int
opencons(void)
{
  80091e:	55                   	push   %ebp
  80091f:	89 e5                	mov    %esp,%ebp
  800921:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800924:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800927:	50                   	push   %eax
  800928:	e8 1c 13 00 00       	call   801c49 <fd_alloc>
  80092d:	83 c4 10             	add    $0x10,%esp
		return r;
  800930:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800932:	85 c0                	test   %eax,%eax
  800934:	78 3e                	js     800974 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800936:	83 ec 04             	sub    $0x4,%esp
  800939:	68 07 04 00 00       	push   $0x407
  80093e:	ff 75 f4             	pushl  -0xc(%ebp)
  800941:	6a 00                	push   $0x0
  800943:	e8 8b 0c 00 00       	call   8015d3 <sys_page_alloc>
  800948:	83 c4 10             	add    $0x10,%esp
		return r;
  80094b:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80094d:	85 c0                	test   %eax,%eax
  80094f:	78 23                	js     800974 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800951:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800957:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80095a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80095c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80095f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800966:	83 ec 0c             	sub    $0xc,%esp
  800969:	50                   	push   %eax
  80096a:	e8 b3 12 00 00       	call   801c22 <fd2num>
  80096f:	89 c2                	mov    %eax,%edx
  800971:	83 c4 10             	add    $0x10,%esp
}
  800974:	89 d0                	mov    %edx,%eax
  800976:	c9                   	leave  
  800977:	c3                   	ret    

00800978 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800978:	55                   	push   %ebp
  800979:	89 e5                	mov    %esp,%ebp
  80097b:	56                   	push   %esi
  80097c:	53                   	push   %ebx
  80097d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800980:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	envid_t envid = sys_getenvid();
  800983:	e8 0d 0c 00 00       	call   801595 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  800988:	25 ff 03 00 00       	and    $0x3ff,%eax
  80098d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800990:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800995:	a3 24 54 80 00       	mov    %eax,0x805424

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80099a:	85 db                	test   %ebx,%ebx
  80099c:	7e 07                	jle    8009a5 <libmain+0x2d>
		binaryname = argv[0];
  80099e:	8b 06                	mov    (%esi),%eax
  8009a0:	a3 1c 40 80 00       	mov    %eax,0x80401c

	// call user main routine
	umain(argc, argv);
  8009a5:	83 ec 08             	sub    $0x8,%esp
  8009a8:	56                   	push   %esi
  8009a9:	53                   	push   %ebx
  8009aa:	e8 6b fc ff ff       	call   80061a <umain>

	// exit gracefully
	exit();
  8009af:	e8 0a 00 00 00       	call   8009be <exit>
}
  8009b4:	83 c4 10             	add    $0x10,%esp
  8009b7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009ba:	5b                   	pop    %ebx
  8009bb:	5e                   	pop    %esi
  8009bc:	5d                   	pop    %ebp
  8009bd:	c3                   	ret    

008009be <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8009be:	55                   	push   %ebp
  8009bf:	89 e5                	mov    %esp,%ebp
  8009c1:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8009c4:	e8 24 14 00 00       	call   801ded <close_all>
	sys_env_destroy(0);
  8009c9:	83 ec 0c             	sub    $0xc,%esp
  8009cc:	6a 00                	push   $0x0
  8009ce:	e8 81 0b 00 00       	call   801554 <sys_env_destroy>
}
  8009d3:	83 c4 10             	add    $0x10,%esp
  8009d6:	c9                   	leave  
  8009d7:	c3                   	ret    

008009d8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8009d8:	55                   	push   %ebp
  8009d9:	89 e5                	mov    %esp,%ebp
  8009db:	56                   	push   %esi
  8009dc:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8009dd:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8009e0:	8b 35 1c 40 80 00    	mov    0x80401c,%esi
  8009e6:	e8 aa 0b 00 00       	call   801595 <sys_getenvid>
  8009eb:	83 ec 0c             	sub    $0xc,%esp
  8009ee:	ff 75 0c             	pushl  0xc(%ebp)
  8009f1:	ff 75 08             	pushl  0x8(%ebp)
  8009f4:	56                   	push   %esi
  8009f5:	50                   	push   %eax
  8009f6:	68 68 34 80 00       	push   $0x803468
  8009fb:	e8 b1 00 00 00       	call   800ab1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800a00:	83 c4 18             	add    $0x18,%esp
  800a03:	53                   	push   %ebx
  800a04:	ff 75 10             	pushl  0x10(%ebp)
  800a07:	e8 54 00 00 00       	call   800a60 <vcprintf>
	cprintf("\n");
  800a0c:	c7 04 24 60 32 80 00 	movl   $0x803260,(%esp)
  800a13:	e8 99 00 00 00       	call   800ab1 <cprintf>
  800a18:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800a1b:	cc                   	int3   
  800a1c:	eb fd                	jmp    800a1b <_panic+0x43>

00800a1e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800a1e:	55                   	push   %ebp
  800a1f:	89 e5                	mov    %esp,%ebp
  800a21:	53                   	push   %ebx
  800a22:	83 ec 04             	sub    $0x4,%esp
  800a25:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800a28:	8b 13                	mov    (%ebx),%edx
  800a2a:	8d 42 01             	lea    0x1(%edx),%eax
  800a2d:	89 03                	mov    %eax,(%ebx)
  800a2f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a32:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800a36:	3d ff 00 00 00       	cmp    $0xff,%eax
  800a3b:	75 1a                	jne    800a57 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800a3d:	83 ec 08             	sub    $0x8,%esp
  800a40:	68 ff 00 00 00       	push   $0xff
  800a45:	8d 43 08             	lea    0x8(%ebx),%eax
  800a48:	50                   	push   %eax
  800a49:	e8 c9 0a 00 00       	call   801517 <sys_cputs>
		b->idx = 0;
  800a4e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800a54:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800a57:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800a5b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a5e:	c9                   	leave  
  800a5f:	c3                   	ret    

00800a60 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800a60:	55                   	push   %ebp
  800a61:	89 e5                	mov    %esp,%ebp
  800a63:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800a69:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800a70:	00 00 00 
	b.cnt = 0;
  800a73:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800a7a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800a7d:	ff 75 0c             	pushl  0xc(%ebp)
  800a80:	ff 75 08             	pushl  0x8(%ebp)
  800a83:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800a89:	50                   	push   %eax
  800a8a:	68 1e 0a 80 00       	push   $0x800a1e
  800a8f:	e8 1a 01 00 00       	call   800bae <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800a94:	83 c4 08             	add    $0x8,%esp
  800a97:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800a9d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800aa3:	50                   	push   %eax
  800aa4:	e8 6e 0a 00 00       	call   801517 <sys_cputs>

	return b.cnt;
}
  800aa9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800aaf:	c9                   	leave  
  800ab0:	c3                   	ret    

00800ab1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800ab1:	55                   	push   %ebp
  800ab2:	89 e5                	mov    %esp,%ebp
  800ab4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800ab7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800aba:	50                   	push   %eax
  800abb:	ff 75 08             	pushl  0x8(%ebp)
  800abe:	e8 9d ff ff ff       	call   800a60 <vcprintf>
	va_end(ap);

	return cnt;
}
  800ac3:	c9                   	leave  
  800ac4:	c3                   	ret    

00800ac5 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800ac5:	55                   	push   %ebp
  800ac6:	89 e5                	mov    %esp,%ebp
  800ac8:	57                   	push   %edi
  800ac9:	56                   	push   %esi
  800aca:	53                   	push   %ebx
  800acb:	83 ec 1c             	sub    $0x1c,%esp
  800ace:	89 c7                	mov    %eax,%edi
  800ad0:	89 d6                	mov    %edx,%esi
  800ad2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ad8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800adb:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800ade:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800ae1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ae6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800ae9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800aec:	39 d3                	cmp    %edx,%ebx
  800aee:	72 05                	jb     800af5 <printnum+0x30>
  800af0:	39 45 10             	cmp    %eax,0x10(%ebp)
  800af3:	77 45                	ja     800b3a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800af5:	83 ec 0c             	sub    $0xc,%esp
  800af8:	ff 75 18             	pushl  0x18(%ebp)
  800afb:	8b 45 14             	mov    0x14(%ebp),%eax
  800afe:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800b01:	53                   	push   %ebx
  800b02:	ff 75 10             	pushl  0x10(%ebp)
  800b05:	83 ec 08             	sub    $0x8,%esp
  800b08:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b0b:	ff 75 e0             	pushl  -0x20(%ebp)
  800b0e:	ff 75 dc             	pushl  -0x24(%ebp)
  800b11:	ff 75 d8             	pushl  -0x28(%ebp)
  800b14:	e8 97 24 00 00       	call   802fb0 <__udivdi3>
  800b19:	83 c4 18             	add    $0x18,%esp
  800b1c:	52                   	push   %edx
  800b1d:	50                   	push   %eax
  800b1e:	89 f2                	mov    %esi,%edx
  800b20:	89 f8                	mov    %edi,%eax
  800b22:	e8 9e ff ff ff       	call   800ac5 <printnum>
  800b27:	83 c4 20             	add    $0x20,%esp
  800b2a:	eb 18                	jmp    800b44 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800b2c:	83 ec 08             	sub    $0x8,%esp
  800b2f:	56                   	push   %esi
  800b30:	ff 75 18             	pushl  0x18(%ebp)
  800b33:	ff d7                	call   *%edi
  800b35:	83 c4 10             	add    $0x10,%esp
  800b38:	eb 03                	jmp    800b3d <printnum+0x78>
  800b3a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800b3d:	83 eb 01             	sub    $0x1,%ebx
  800b40:	85 db                	test   %ebx,%ebx
  800b42:	7f e8                	jg     800b2c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800b44:	83 ec 08             	sub    $0x8,%esp
  800b47:	56                   	push   %esi
  800b48:	83 ec 04             	sub    $0x4,%esp
  800b4b:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b4e:	ff 75 e0             	pushl  -0x20(%ebp)
  800b51:	ff 75 dc             	pushl  -0x24(%ebp)
  800b54:	ff 75 d8             	pushl  -0x28(%ebp)
  800b57:	e8 84 25 00 00       	call   8030e0 <__umoddi3>
  800b5c:	83 c4 14             	add    $0x14,%esp
  800b5f:	0f be 80 8b 34 80 00 	movsbl 0x80348b(%eax),%eax
  800b66:	50                   	push   %eax
  800b67:	ff d7                	call   *%edi
}
  800b69:	83 c4 10             	add    $0x10,%esp
  800b6c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b6f:	5b                   	pop    %ebx
  800b70:	5e                   	pop    %esi
  800b71:	5f                   	pop    %edi
  800b72:	5d                   	pop    %ebp
  800b73:	c3                   	ret    

00800b74 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800b74:	55                   	push   %ebp
  800b75:	89 e5                	mov    %esp,%ebp
  800b77:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800b7a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800b7e:	8b 10                	mov    (%eax),%edx
  800b80:	3b 50 04             	cmp    0x4(%eax),%edx
  800b83:	73 0a                	jae    800b8f <sprintputch+0x1b>
		*b->buf++ = ch;
  800b85:	8d 4a 01             	lea    0x1(%edx),%ecx
  800b88:	89 08                	mov    %ecx,(%eax)
  800b8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8d:	88 02                	mov    %al,(%edx)
}
  800b8f:	5d                   	pop    %ebp
  800b90:	c3                   	ret    

00800b91 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800b91:	55                   	push   %ebp
  800b92:	89 e5                	mov    %esp,%ebp
  800b94:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800b97:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800b9a:	50                   	push   %eax
  800b9b:	ff 75 10             	pushl  0x10(%ebp)
  800b9e:	ff 75 0c             	pushl  0xc(%ebp)
  800ba1:	ff 75 08             	pushl  0x8(%ebp)
  800ba4:	e8 05 00 00 00       	call   800bae <vprintfmt>
	va_end(ap);
}
  800ba9:	83 c4 10             	add    $0x10,%esp
  800bac:	c9                   	leave  
  800bad:	c3                   	ret    

00800bae <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800bae:	55                   	push   %ebp
  800baf:	89 e5                	mov    %esp,%ebp
  800bb1:	57                   	push   %edi
  800bb2:	56                   	push   %esi
  800bb3:	53                   	push   %ebx
  800bb4:	83 ec 2c             	sub    $0x2c,%esp
  800bb7:	8b 75 08             	mov    0x8(%ebp),%esi
  800bba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bbd:	8b 7d 10             	mov    0x10(%ebp),%edi
  800bc0:	eb 12                	jmp    800bd4 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800bc2:	85 c0                	test   %eax,%eax
  800bc4:	0f 84 6a 04 00 00    	je     801034 <vprintfmt+0x486>
				return;
			putch(ch, putdat);
  800bca:	83 ec 08             	sub    $0x8,%esp
  800bcd:	53                   	push   %ebx
  800bce:	50                   	push   %eax
  800bcf:	ff d6                	call   *%esi
  800bd1:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800bd4:	83 c7 01             	add    $0x1,%edi
  800bd7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800bdb:	83 f8 25             	cmp    $0x25,%eax
  800bde:	75 e2                	jne    800bc2 <vprintfmt+0x14>
  800be0:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800be4:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800beb:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800bf2:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800bf9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bfe:	eb 07                	jmp    800c07 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c00:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800c03:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c07:	8d 47 01             	lea    0x1(%edi),%eax
  800c0a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c0d:	0f b6 07             	movzbl (%edi),%eax
  800c10:	0f b6 d0             	movzbl %al,%edx
  800c13:	83 e8 23             	sub    $0x23,%eax
  800c16:	3c 55                	cmp    $0x55,%al
  800c18:	0f 87 fb 03 00 00    	ja     801019 <vprintfmt+0x46b>
  800c1e:	0f b6 c0             	movzbl %al,%eax
  800c21:	ff 24 85 c0 35 80 00 	jmp    *0x8035c0(,%eax,4)
  800c28:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800c2b:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800c2f:	eb d6                	jmp    800c07 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c31:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800c34:	b8 00 00 00 00       	mov    $0x0,%eax
  800c39:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800c3c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800c3f:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800c43:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800c46:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800c49:	83 f9 09             	cmp    $0x9,%ecx
  800c4c:	77 3f                	ja     800c8d <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800c4e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800c51:	eb e9                	jmp    800c3c <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800c53:	8b 45 14             	mov    0x14(%ebp),%eax
  800c56:	8b 00                	mov    (%eax),%eax
  800c58:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800c5b:	8b 45 14             	mov    0x14(%ebp),%eax
  800c5e:	8d 40 04             	lea    0x4(%eax),%eax
  800c61:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c64:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800c67:	eb 2a                	jmp    800c93 <vprintfmt+0xe5>
  800c69:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800c6c:	85 c0                	test   %eax,%eax
  800c6e:	ba 00 00 00 00       	mov    $0x0,%edx
  800c73:	0f 49 d0             	cmovns %eax,%edx
  800c76:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c79:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800c7c:	eb 89                	jmp    800c07 <vprintfmt+0x59>
  800c7e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800c81:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800c88:	e9 7a ff ff ff       	jmp    800c07 <vprintfmt+0x59>
  800c8d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800c90:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800c93:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800c97:	0f 89 6a ff ff ff    	jns    800c07 <vprintfmt+0x59>
				width = precision, precision = -1;
  800c9d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800ca0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800ca3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800caa:	e9 58 ff ff ff       	jmp    800c07 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800caf:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cb2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800cb5:	e9 4d ff ff ff       	jmp    800c07 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800cba:	8b 45 14             	mov    0x14(%ebp),%eax
  800cbd:	8d 78 04             	lea    0x4(%eax),%edi
  800cc0:	83 ec 08             	sub    $0x8,%esp
  800cc3:	53                   	push   %ebx
  800cc4:	ff 30                	pushl  (%eax)
  800cc6:	ff d6                	call   *%esi
			break;
  800cc8:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800ccb:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800cd1:	e9 fe fe ff ff       	jmp    800bd4 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800cd6:	8b 45 14             	mov    0x14(%ebp),%eax
  800cd9:	8d 78 04             	lea    0x4(%eax),%edi
  800cdc:	8b 00                	mov    (%eax),%eax
  800cde:	99                   	cltd   
  800cdf:	31 d0                	xor    %edx,%eax
  800ce1:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800ce3:	83 f8 0f             	cmp    $0xf,%eax
  800ce6:	7f 0b                	jg     800cf3 <vprintfmt+0x145>
  800ce8:	8b 14 85 20 37 80 00 	mov    0x803720(,%eax,4),%edx
  800cef:	85 d2                	test   %edx,%edx
  800cf1:	75 1b                	jne    800d0e <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800cf3:	50                   	push   %eax
  800cf4:	68 a3 34 80 00       	push   $0x8034a3
  800cf9:	53                   	push   %ebx
  800cfa:	56                   	push   %esi
  800cfb:	e8 91 fe ff ff       	call   800b91 <printfmt>
  800d00:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800d03:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d06:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800d09:	e9 c6 fe ff ff       	jmp    800bd4 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800d0e:	52                   	push   %edx
  800d0f:	68 aa 33 80 00       	push   $0x8033aa
  800d14:	53                   	push   %ebx
  800d15:	56                   	push   %esi
  800d16:	e8 76 fe ff ff       	call   800b91 <printfmt>
  800d1b:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800d1e:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d21:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800d24:	e9 ab fe ff ff       	jmp    800bd4 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800d29:	8b 45 14             	mov    0x14(%ebp),%eax
  800d2c:	83 c0 04             	add    $0x4,%eax
  800d2f:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800d32:	8b 45 14             	mov    0x14(%ebp),%eax
  800d35:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800d37:	85 ff                	test   %edi,%edi
  800d39:	b8 9c 34 80 00       	mov    $0x80349c,%eax
  800d3e:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800d41:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800d45:	0f 8e 94 00 00 00    	jle    800ddf <vprintfmt+0x231>
  800d4b:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800d4f:	0f 84 98 00 00 00    	je     800ded <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800d55:	83 ec 08             	sub    $0x8,%esp
  800d58:	ff 75 d0             	pushl  -0x30(%ebp)
  800d5b:	57                   	push   %edi
  800d5c:	e8 4e 04 00 00       	call   8011af <strnlen>
  800d61:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800d64:	29 c1                	sub    %eax,%ecx
  800d66:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800d69:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800d6c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800d70:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800d73:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800d76:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800d78:	eb 0f                	jmp    800d89 <vprintfmt+0x1db>
					putch(padc, putdat);
  800d7a:	83 ec 08             	sub    $0x8,%esp
  800d7d:	53                   	push   %ebx
  800d7e:	ff 75 e0             	pushl  -0x20(%ebp)
  800d81:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800d83:	83 ef 01             	sub    $0x1,%edi
  800d86:	83 c4 10             	add    $0x10,%esp
  800d89:	85 ff                	test   %edi,%edi
  800d8b:	7f ed                	jg     800d7a <vprintfmt+0x1cc>
  800d8d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800d90:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800d93:	85 c9                	test   %ecx,%ecx
  800d95:	b8 00 00 00 00       	mov    $0x0,%eax
  800d9a:	0f 49 c1             	cmovns %ecx,%eax
  800d9d:	29 c1                	sub    %eax,%ecx
  800d9f:	89 75 08             	mov    %esi,0x8(%ebp)
  800da2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800da5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800da8:	89 cb                	mov    %ecx,%ebx
  800daa:	eb 4d                	jmp    800df9 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800dac:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800db0:	74 1b                	je     800dcd <vprintfmt+0x21f>
  800db2:	0f be c0             	movsbl %al,%eax
  800db5:	83 e8 20             	sub    $0x20,%eax
  800db8:	83 f8 5e             	cmp    $0x5e,%eax
  800dbb:	76 10                	jbe    800dcd <vprintfmt+0x21f>
					putch('?', putdat);
  800dbd:	83 ec 08             	sub    $0x8,%esp
  800dc0:	ff 75 0c             	pushl  0xc(%ebp)
  800dc3:	6a 3f                	push   $0x3f
  800dc5:	ff 55 08             	call   *0x8(%ebp)
  800dc8:	83 c4 10             	add    $0x10,%esp
  800dcb:	eb 0d                	jmp    800dda <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  800dcd:	83 ec 08             	sub    $0x8,%esp
  800dd0:	ff 75 0c             	pushl  0xc(%ebp)
  800dd3:	52                   	push   %edx
  800dd4:	ff 55 08             	call   *0x8(%ebp)
  800dd7:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800dda:	83 eb 01             	sub    $0x1,%ebx
  800ddd:	eb 1a                	jmp    800df9 <vprintfmt+0x24b>
  800ddf:	89 75 08             	mov    %esi,0x8(%ebp)
  800de2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800de5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800de8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800deb:	eb 0c                	jmp    800df9 <vprintfmt+0x24b>
  800ded:	89 75 08             	mov    %esi,0x8(%ebp)
  800df0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800df3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800df6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800df9:	83 c7 01             	add    $0x1,%edi
  800dfc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800e00:	0f be d0             	movsbl %al,%edx
  800e03:	85 d2                	test   %edx,%edx
  800e05:	74 23                	je     800e2a <vprintfmt+0x27c>
  800e07:	85 f6                	test   %esi,%esi
  800e09:	78 a1                	js     800dac <vprintfmt+0x1fe>
  800e0b:	83 ee 01             	sub    $0x1,%esi
  800e0e:	79 9c                	jns    800dac <vprintfmt+0x1fe>
  800e10:	89 df                	mov    %ebx,%edi
  800e12:	8b 75 08             	mov    0x8(%ebp),%esi
  800e15:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e18:	eb 18                	jmp    800e32 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800e1a:	83 ec 08             	sub    $0x8,%esp
  800e1d:	53                   	push   %ebx
  800e1e:	6a 20                	push   $0x20
  800e20:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800e22:	83 ef 01             	sub    $0x1,%edi
  800e25:	83 c4 10             	add    $0x10,%esp
  800e28:	eb 08                	jmp    800e32 <vprintfmt+0x284>
  800e2a:	89 df                	mov    %ebx,%edi
  800e2c:	8b 75 08             	mov    0x8(%ebp),%esi
  800e2f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e32:	85 ff                	test   %edi,%edi
  800e34:	7f e4                	jg     800e1a <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800e36:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800e39:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800e3c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800e3f:	e9 90 fd ff ff       	jmp    800bd4 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800e44:	83 f9 01             	cmp    $0x1,%ecx
  800e47:	7e 19                	jle    800e62 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800e49:	8b 45 14             	mov    0x14(%ebp),%eax
  800e4c:	8b 50 04             	mov    0x4(%eax),%edx
  800e4f:	8b 00                	mov    (%eax),%eax
  800e51:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800e54:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800e57:	8b 45 14             	mov    0x14(%ebp),%eax
  800e5a:	8d 40 08             	lea    0x8(%eax),%eax
  800e5d:	89 45 14             	mov    %eax,0x14(%ebp)
  800e60:	eb 38                	jmp    800e9a <vprintfmt+0x2ec>
	else if (lflag)
  800e62:	85 c9                	test   %ecx,%ecx
  800e64:	74 1b                	je     800e81 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800e66:	8b 45 14             	mov    0x14(%ebp),%eax
  800e69:	8b 00                	mov    (%eax),%eax
  800e6b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800e6e:	89 c1                	mov    %eax,%ecx
  800e70:	c1 f9 1f             	sar    $0x1f,%ecx
  800e73:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800e76:	8b 45 14             	mov    0x14(%ebp),%eax
  800e79:	8d 40 04             	lea    0x4(%eax),%eax
  800e7c:	89 45 14             	mov    %eax,0x14(%ebp)
  800e7f:	eb 19                	jmp    800e9a <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800e81:	8b 45 14             	mov    0x14(%ebp),%eax
  800e84:	8b 00                	mov    (%eax),%eax
  800e86:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800e89:	89 c1                	mov    %eax,%ecx
  800e8b:	c1 f9 1f             	sar    $0x1f,%ecx
  800e8e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800e91:	8b 45 14             	mov    0x14(%ebp),%eax
  800e94:	8d 40 04             	lea    0x4(%eax),%eax
  800e97:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800e9a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800e9d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800ea0:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800ea5:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800ea9:	0f 89 36 01 00 00    	jns    800fe5 <vprintfmt+0x437>
				putch('-', putdat);
  800eaf:	83 ec 08             	sub    $0x8,%esp
  800eb2:	53                   	push   %ebx
  800eb3:	6a 2d                	push   $0x2d
  800eb5:	ff d6                	call   *%esi
				num = -(long long) num;
  800eb7:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800eba:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800ebd:	f7 da                	neg    %edx
  800ebf:	83 d1 00             	adc    $0x0,%ecx
  800ec2:	f7 d9                	neg    %ecx
  800ec4:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800ec7:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ecc:	e9 14 01 00 00       	jmp    800fe5 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800ed1:	83 f9 01             	cmp    $0x1,%ecx
  800ed4:	7e 18                	jle    800eee <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800ed6:	8b 45 14             	mov    0x14(%ebp),%eax
  800ed9:	8b 10                	mov    (%eax),%edx
  800edb:	8b 48 04             	mov    0x4(%eax),%ecx
  800ede:	8d 40 08             	lea    0x8(%eax),%eax
  800ee1:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800ee4:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ee9:	e9 f7 00 00 00       	jmp    800fe5 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800eee:	85 c9                	test   %ecx,%ecx
  800ef0:	74 1a                	je     800f0c <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  800ef2:	8b 45 14             	mov    0x14(%ebp),%eax
  800ef5:	8b 10                	mov    (%eax),%edx
  800ef7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800efc:	8d 40 04             	lea    0x4(%eax),%eax
  800eff:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800f02:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f07:	e9 d9 00 00 00       	jmp    800fe5 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800f0c:	8b 45 14             	mov    0x14(%ebp),%eax
  800f0f:	8b 10                	mov    (%eax),%edx
  800f11:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f16:	8d 40 04             	lea    0x4(%eax),%eax
  800f19:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800f1c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f21:	e9 bf 00 00 00       	jmp    800fe5 <vprintfmt+0x437>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800f26:	83 f9 01             	cmp    $0x1,%ecx
  800f29:	7e 13                	jle    800f3e <vprintfmt+0x390>
		return va_arg(*ap, long long);
  800f2b:	8b 45 14             	mov    0x14(%ebp),%eax
  800f2e:	8b 50 04             	mov    0x4(%eax),%edx
  800f31:	8b 00                	mov    (%eax),%eax
  800f33:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800f36:	8d 49 08             	lea    0x8(%ecx),%ecx
  800f39:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800f3c:	eb 28                	jmp    800f66 <vprintfmt+0x3b8>
	else if (lflag)
  800f3e:	85 c9                	test   %ecx,%ecx
  800f40:	74 13                	je     800f55 <vprintfmt+0x3a7>
		return va_arg(*ap, long);
  800f42:	8b 45 14             	mov    0x14(%ebp),%eax
  800f45:	8b 10                	mov    (%eax),%edx
  800f47:	89 d0                	mov    %edx,%eax
  800f49:	99                   	cltd   
  800f4a:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800f4d:	8d 49 04             	lea    0x4(%ecx),%ecx
  800f50:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800f53:	eb 11                	jmp    800f66 <vprintfmt+0x3b8>
	else
		return va_arg(*ap, int);
  800f55:	8b 45 14             	mov    0x14(%ebp),%eax
  800f58:	8b 10                	mov    (%eax),%edx
  800f5a:	89 d0                	mov    %edx,%eax
  800f5c:	99                   	cltd   
  800f5d:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800f60:	8d 49 04             	lea    0x4(%ecx),%ecx
  800f63:	89 4d 14             	mov    %ecx,0x14(%ebp)
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getint(&ap, lflag);
  800f66:	89 d1                	mov    %edx,%ecx
  800f68:	89 c2                	mov    %eax,%edx
			base = 8;
  800f6a:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800f6f:	eb 74                	jmp    800fe5 <vprintfmt+0x437>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800f71:	83 ec 08             	sub    $0x8,%esp
  800f74:	53                   	push   %ebx
  800f75:	6a 30                	push   $0x30
  800f77:	ff d6                	call   *%esi
			putch('x', putdat);
  800f79:	83 c4 08             	add    $0x8,%esp
  800f7c:	53                   	push   %ebx
  800f7d:	6a 78                	push   $0x78
  800f7f:	ff d6                	call   *%esi
			num = (unsigned long long)
  800f81:	8b 45 14             	mov    0x14(%ebp),%eax
  800f84:	8b 10                	mov    (%eax),%edx
  800f86:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800f8b:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800f8e:	8d 40 04             	lea    0x4(%eax),%eax
  800f91:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800f94:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800f99:	eb 4a                	jmp    800fe5 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800f9b:	83 f9 01             	cmp    $0x1,%ecx
  800f9e:	7e 15                	jle    800fb5 <vprintfmt+0x407>
		return va_arg(*ap, unsigned long long);
  800fa0:	8b 45 14             	mov    0x14(%ebp),%eax
  800fa3:	8b 10                	mov    (%eax),%edx
  800fa5:	8b 48 04             	mov    0x4(%eax),%ecx
  800fa8:	8d 40 08             	lea    0x8(%eax),%eax
  800fab:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800fae:	b8 10 00 00 00       	mov    $0x10,%eax
  800fb3:	eb 30                	jmp    800fe5 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800fb5:	85 c9                	test   %ecx,%ecx
  800fb7:	74 17                	je     800fd0 <vprintfmt+0x422>
		return va_arg(*ap, unsigned long);
  800fb9:	8b 45 14             	mov    0x14(%ebp),%eax
  800fbc:	8b 10                	mov    (%eax),%edx
  800fbe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fc3:	8d 40 04             	lea    0x4(%eax),%eax
  800fc6:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800fc9:	b8 10 00 00 00       	mov    $0x10,%eax
  800fce:	eb 15                	jmp    800fe5 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800fd0:	8b 45 14             	mov    0x14(%ebp),%eax
  800fd3:	8b 10                	mov    (%eax),%edx
  800fd5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fda:	8d 40 04             	lea    0x4(%eax),%eax
  800fdd:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800fe0:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800fe5:	83 ec 0c             	sub    $0xc,%esp
  800fe8:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800fec:	57                   	push   %edi
  800fed:	ff 75 e0             	pushl  -0x20(%ebp)
  800ff0:	50                   	push   %eax
  800ff1:	51                   	push   %ecx
  800ff2:	52                   	push   %edx
  800ff3:	89 da                	mov    %ebx,%edx
  800ff5:	89 f0                	mov    %esi,%eax
  800ff7:	e8 c9 fa ff ff       	call   800ac5 <printnum>
			break;
  800ffc:	83 c4 20             	add    $0x20,%esp
  800fff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801002:	e9 cd fb ff ff       	jmp    800bd4 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801007:	83 ec 08             	sub    $0x8,%esp
  80100a:	53                   	push   %ebx
  80100b:	52                   	push   %edx
  80100c:	ff d6                	call   *%esi
			break;
  80100e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801011:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801014:	e9 bb fb ff ff       	jmp    800bd4 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801019:	83 ec 08             	sub    $0x8,%esp
  80101c:	53                   	push   %ebx
  80101d:	6a 25                	push   $0x25
  80101f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801021:	83 c4 10             	add    $0x10,%esp
  801024:	eb 03                	jmp    801029 <vprintfmt+0x47b>
  801026:	83 ef 01             	sub    $0x1,%edi
  801029:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80102d:	75 f7                	jne    801026 <vprintfmt+0x478>
  80102f:	e9 a0 fb ff ff       	jmp    800bd4 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801034:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801037:	5b                   	pop    %ebx
  801038:	5e                   	pop    %esi
  801039:	5f                   	pop    %edi
  80103a:	5d                   	pop    %ebp
  80103b:	c3                   	ret    

0080103c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80103c:	55                   	push   %ebp
  80103d:	89 e5                	mov    %esp,%ebp
  80103f:	83 ec 18             	sub    $0x18,%esp
  801042:	8b 45 08             	mov    0x8(%ebp),%eax
  801045:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801048:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80104b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80104f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801052:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801059:	85 c0                	test   %eax,%eax
  80105b:	74 26                	je     801083 <vsnprintf+0x47>
  80105d:	85 d2                	test   %edx,%edx
  80105f:	7e 22                	jle    801083 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801061:	ff 75 14             	pushl  0x14(%ebp)
  801064:	ff 75 10             	pushl  0x10(%ebp)
  801067:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80106a:	50                   	push   %eax
  80106b:	68 74 0b 80 00       	push   $0x800b74
  801070:	e8 39 fb ff ff       	call   800bae <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801075:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801078:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80107b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80107e:	83 c4 10             	add    $0x10,%esp
  801081:	eb 05                	jmp    801088 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801083:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801088:	c9                   	leave  
  801089:	c3                   	ret    

0080108a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80108a:	55                   	push   %ebp
  80108b:	89 e5                	mov    %esp,%ebp
  80108d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801090:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801093:	50                   	push   %eax
  801094:	ff 75 10             	pushl  0x10(%ebp)
  801097:	ff 75 0c             	pushl  0xc(%ebp)
  80109a:	ff 75 08             	pushl  0x8(%ebp)
  80109d:	e8 9a ff ff ff       	call   80103c <vsnprintf>
	va_end(ap);

	return rc;
}
  8010a2:	c9                   	leave  
  8010a3:	c3                   	ret    

008010a4 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  8010a4:	55                   	push   %ebp
  8010a5:	89 e5                	mov    %esp,%ebp
  8010a7:	57                   	push   %edi
  8010a8:	56                   	push   %esi
  8010a9:	53                   	push   %ebx
  8010aa:	83 ec 0c             	sub    $0xc,%esp
  8010ad:	8b 45 08             	mov    0x8(%ebp),%eax

#if JOS_KERNEL
	if (prompt != NULL)
		cprintf("%s", prompt);
#else
	if (prompt != NULL)
  8010b0:	85 c0                	test   %eax,%eax
  8010b2:	74 13                	je     8010c7 <readline+0x23>
		fprintf(1, "%s", prompt);
  8010b4:	83 ec 04             	sub    $0x4,%esp
  8010b7:	50                   	push   %eax
  8010b8:	68 aa 33 80 00       	push   $0x8033aa
  8010bd:	6a 01                	push   $0x1
  8010bf:	e8 20 14 00 00       	call   8024e4 <fprintf>
  8010c4:	83 c4 10             	add    $0x10,%esp
#endif

	i = 0;
	echoing = iscons(0);
  8010c7:	83 ec 0c             	sub    $0xc,%esp
  8010ca:	6a 00                	push   $0x0
  8010cc:	e8 21 f8 ff ff       	call   8008f2 <iscons>
  8010d1:	89 c7                	mov    %eax,%edi
  8010d3:	83 c4 10             	add    $0x10,%esp
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
  8010d6:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
  8010db:	e8 e7 f7 ff ff       	call   8008c7 <getchar>
  8010e0:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  8010e2:	85 c0                	test   %eax,%eax
  8010e4:	79 29                	jns    80110f <readline+0x6b>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
  8010e6:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
  8010eb:	83 fb f8             	cmp    $0xfffffff8,%ebx
  8010ee:	0f 84 9b 00 00 00    	je     80118f <readline+0xeb>
				cprintf("read error: %e\n", c);
  8010f4:	83 ec 08             	sub    $0x8,%esp
  8010f7:	53                   	push   %ebx
  8010f8:	68 7f 37 80 00       	push   $0x80377f
  8010fd:	e8 af f9 ff ff       	call   800ab1 <cprintf>
  801102:	83 c4 10             	add    $0x10,%esp
			return NULL;
  801105:	b8 00 00 00 00       	mov    $0x0,%eax
  80110a:	e9 80 00 00 00       	jmp    80118f <readline+0xeb>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  80110f:	83 f8 08             	cmp    $0x8,%eax
  801112:	0f 94 c2             	sete   %dl
  801115:	83 f8 7f             	cmp    $0x7f,%eax
  801118:	0f 94 c0             	sete   %al
  80111b:	08 c2                	or     %al,%dl
  80111d:	74 1a                	je     801139 <readline+0x95>
  80111f:	85 f6                	test   %esi,%esi
  801121:	7e 16                	jle    801139 <readline+0x95>
			if (echoing)
  801123:	85 ff                	test   %edi,%edi
  801125:	74 0d                	je     801134 <readline+0x90>
				cputchar('\b');
  801127:	83 ec 0c             	sub    $0xc,%esp
  80112a:	6a 08                	push   $0x8
  80112c:	e8 7a f7 ff ff       	call   8008ab <cputchar>
  801131:	83 c4 10             	add    $0x10,%esp
			i--;
  801134:	83 ee 01             	sub    $0x1,%esi
  801137:	eb a2                	jmp    8010db <readline+0x37>
		} else if (c >= ' ' && i < BUFLEN-1) {
  801139:	83 fb 1f             	cmp    $0x1f,%ebx
  80113c:	7e 26                	jle    801164 <readline+0xc0>
  80113e:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  801144:	7f 1e                	jg     801164 <readline+0xc0>
			if (echoing)
  801146:	85 ff                	test   %edi,%edi
  801148:	74 0c                	je     801156 <readline+0xb2>
				cputchar(c);
  80114a:	83 ec 0c             	sub    $0xc,%esp
  80114d:	53                   	push   %ebx
  80114e:	e8 58 f7 ff ff       	call   8008ab <cputchar>
  801153:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
  801156:	88 9e 20 50 80 00    	mov    %bl,0x805020(%esi)
  80115c:	8d 76 01             	lea    0x1(%esi),%esi
  80115f:	e9 77 ff ff ff       	jmp    8010db <readline+0x37>
		} else if (c == '\n' || c == '\r') {
  801164:	83 fb 0a             	cmp    $0xa,%ebx
  801167:	74 09                	je     801172 <readline+0xce>
  801169:	83 fb 0d             	cmp    $0xd,%ebx
  80116c:	0f 85 69 ff ff ff    	jne    8010db <readline+0x37>
			if (echoing)
  801172:	85 ff                	test   %edi,%edi
  801174:	74 0d                	je     801183 <readline+0xdf>
				cputchar('\n');
  801176:	83 ec 0c             	sub    $0xc,%esp
  801179:	6a 0a                	push   $0xa
  80117b:	e8 2b f7 ff ff       	call   8008ab <cputchar>
  801180:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
  801183:	c6 86 20 50 80 00 00 	movb   $0x0,0x805020(%esi)
			return buf;
  80118a:	b8 20 50 80 00       	mov    $0x805020,%eax
		}
	}
}
  80118f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801192:	5b                   	pop    %ebx
  801193:	5e                   	pop    %esi
  801194:	5f                   	pop    %edi
  801195:	5d                   	pop    %ebp
  801196:	c3                   	ret    

00801197 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801197:	55                   	push   %ebp
  801198:	89 e5                	mov    %esp,%ebp
  80119a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80119d:	b8 00 00 00 00       	mov    $0x0,%eax
  8011a2:	eb 03                	jmp    8011a7 <strlen+0x10>
		n++;
  8011a4:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8011a7:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8011ab:	75 f7                	jne    8011a4 <strlen+0xd>
		n++;
	return n;
}
  8011ad:	5d                   	pop    %ebp
  8011ae:	c3                   	ret    

008011af <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8011af:	55                   	push   %ebp
  8011b0:	89 e5                	mov    %esp,%ebp
  8011b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011b5:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8011b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8011bd:	eb 03                	jmp    8011c2 <strnlen+0x13>
		n++;
  8011bf:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8011c2:	39 c2                	cmp    %eax,%edx
  8011c4:	74 08                	je     8011ce <strnlen+0x1f>
  8011c6:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8011ca:	75 f3                	jne    8011bf <strnlen+0x10>
  8011cc:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8011ce:	5d                   	pop    %ebp
  8011cf:	c3                   	ret    

008011d0 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8011d0:	55                   	push   %ebp
  8011d1:	89 e5                	mov    %esp,%ebp
  8011d3:	53                   	push   %ebx
  8011d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8011d7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8011da:	89 c2                	mov    %eax,%edx
  8011dc:	83 c2 01             	add    $0x1,%edx
  8011df:	83 c1 01             	add    $0x1,%ecx
  8011e2:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8011e6:	88 5a ff             	mov    %bl,-0x1(%edx)
  8011e9:	84 db                	test   %bl,%bl
  8011eb:	75 ef                	jne    8011dc <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8011ed:	5b                   	pop    %ebx
  8011ee:	5d                   	pop    %ebp
  8011ef:	c3                   	ret    

008011f0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8011f0:	55                   	push   %ebp
  8011f1:	89 e5                	mov    %esp,%ebp
  8011f3:	53                   	push   %ebx
  8011f4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8011f7:	53                   	push   %ebx
  8011f8:	e8 9a ff ff ff       	call   801197 <strlen>
  8011fd:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801200:	ff 75 0c             	pushl  0xc(%ebp)
  801203:	01 d8                	add    %ebx,%eax
  801205:	50                   	push   %eax
  801206:	e8 c5 ff ff ff       	call   8011d0 <strcpy>
	return dst;
}
  80120b:	89 d8                	mov    %ebx,%eax
  80120d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801210:	c9                   	leave  
  801211:	c3                   	ret    

00801212 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801212:	55                   	push   %ebp
  801213:	89 e5                	mov    %esp,%ebp
  801215:	56                   	push   %esi
  801216:	53                   	push   %ebx
  801217:	8b 75 08             	mov    0x8(%ebp),%esi
  80121a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80121d:	89 f3                	mov    %esi,%ebx
  80121f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801222:	89 f2                	mov    %esi,%edx
  801224:	eb 0f                	jmp    801235 <strncpy+0x23>
		*dst++ = *src;
  801226:	83 c2 01             	add    $0x1,%edx
  801229:	0f b6 01             	movzbl (%ecx),%eax
  80122c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80122f:	80 39 01             	cmpb   $0x1,(%ecx)
  801232:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801235:	39 da                	cmp    %ebx,%edx
  801237:	75 ed                	jne    801226 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801239:	89 f0                	mov    %esi,%eax
  80123b:	5b                   	pop    %ebx
  80123c:	5e                   	pop    %esi
  80123d:	5d                   	pop    %ebp
  80123e:	c3                   	ret    

0080123f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80123f:	55                   	push   %ebp
  801240:	89 e5                	mov    %esp,%ebp
  801242:	56                   	push   %esi
  801243:	53                   	push   %ebx
  801244:	8b 75 08             	mov    0x8(%ebp),%esi
  801247:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80124a:	8b 55 10             	mov    0x10(%ebp),%edx
  80124d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80124f:	85 d2                	test   %edx,%edx
  801251:	74 21                	je     801274 <strlcpy+0x35>
  801253:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801257:	89 f2                	mov    %esi,%edx
  801259:	eb 09                	jmp    801264 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80125b:	83 c2 01             	add    $0x1,%edx
  80125e:	83 c1 01             	add    $0x1,%ecx
  801261:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801264:	39 c2                	cmp    %eax,%edx
  801266:	74 09                	je     801271 <strlcpy+0x32>
  801268:	0f b6 19             	movzbl (%ecx),%ebx
  80126b:	84 db                	test   %bl,%bl
  80126d:	75 ec                	jne    80125b <strlcpy+0x1c>
  80126f:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801271:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801274:	29 f0                	sub    %esi,%eax
}
  801276:	5b                   	pop    %ebx
  801277:	5e                   	pop    %esi
  801278:	5d                   	pop    %ebp
  801279:	c3                   	ret    

0080127a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80127a:	55                   	push   %ebp
  80127b:	89 e5                	mov    %esp,%ebp
  80127d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801280:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801283:	eb 06                	jmp    80128b <strcmp+0x11>
		p++, q++;
  801285:	83 c1 01             	add    $0x1,%ecx
  801288:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80128b:	0f b6 01             	movzbl (%ecx),%eax
  80128e:	84 c0                	test   %al,%al
  801290:	74 04                	je     801296 <strcmp+0x1c>
  801292:	3a 02                	cmp    (%edx),%al
  801294:	74 ef                	je     801285 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801296:	0f b6 c0             	movzbl %al,%eax
  801299:	0f b6 12             	movzbl (%edx),%edx
  80129c:	29 d0                	sub    %edx,%eax
}
  80129e:	5d                   	pop    %ebp
  80129f:	c3                   	ret    

008012a0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8012a0:	55                   	push   %ebp
  8012a1:	89 e5                	mov    %esp,%ebp
  8012a3:	53                   	push   %ebx
  8012a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8012a7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012aa:	89 c3                	mov    %eax,%ebx
  8012ac:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8012af:	eb 06                	jmp    8012b7 <strncmp+0x17>
		n--, p++, q++;
  8012b1:	83 c0 01             	add    $0x1,%eax
  8012b4:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8012b7:	39 d8                	cmp    %ebx,%eax
  8012b9:	74 15                	je     8012d0 <strncmp+0x30>
  8012bb:	0f b6 08             	movzbl (%eax),%ecx
  8012be:	84 c9                	test   %cl,%cl
  8012c0:	74 04                	je     8012c6 <strncmp+0x26>
  8012c2:	3a 0a                	cmp    (%edx),%cl
  8012c4:	74 eb                	je     8012b1 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8012c6:	0f b6 00             	movzbl (%eax),%eax
  8012c9:	0f b6 12             	movzbl (%edx),%edx
  8012cc:	29 d0                	sub    %edx,%eax
  8012ce:	eb 05                	jmp    8012d5 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8012d0:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8012d5:	5b                   	pop    %ebx
  8012d6:	5d                   	pop    %ebp
  8012d7:	c3                   	ret    

008012d8 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8012d8:	55                   	push   %ebp
  8012d9:	89 e5                	mov    %esp,%ebp
  8012db:	8b 45 08             	mov    0x8(%ebp),%eax
  8012de:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8012e2:	eb 07                	jmp    8012eb <strchr+0x13>
		if (*s == c)
  8012e4:	38 ca                	cmp    %cl,%dl
  8012e6:	74 0f                	je     8012f7 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8012e8:	83 c0 01             	add    $0x1,%eax
  8012eb:	0f b6 10             	movzbl (%eax),%edx
  8012ee:	84 d2                	test   %dl,%dl
  8012f0:	75 f2                	jne    8012e4 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8012f2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012f7:	5d                   	pop    %ebp
  8012f8:	c3                   	ret    

008012f9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8012f9:	55                   	push   %ebp
  8012fa:	89 e5                	mov    %esp,%ebp
  8012fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8012ff:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801303:	eb 03                	jmp    801308 <strfind+0xf>
  801305:	83 c0 01             	add    $0x1,%eax
  801308:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80130b:	38 ca                	cmp    %cl,%dl
  80130d:	74 04                	je     801313 <strfind+0x1a>
  80130f:	84 d2                	test   %dl,%dl
  801311:	75 f2                	jne    801305 <strfind+0xc>
			break;
	return (char *) s;
}
  801313:	5d                   	pop    %ebp
  801314:	c3                   	ret    

00801315 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801315:	55                   	push   %ebp
  801316:	89 e5                	mov    %esp,%ebp
  801318:	57                   	push   %edi
  801319:	56                   	push   %esi
  80131a:	53                   	push   %ebx
  80131b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80131e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801321:	85 c9                	test   %ecx,%ecx
  801323:	74 36                	je     80135b <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801325:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80132b:	75 28                	jne    801355 <memset+0x40>
  80132d:	f6 c1 03             	test   $0x3,%cl
  801330:	75 23                	jne    801355 <memset+0x40>
		c &= 0xFF;
  801332:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801336:	89 d3                	mov    %edx,%ebx
  801338:	c1 e3 08             	shl    $0x8,%ebx
  80133b:	89 d6                	mov    %edx,%esi
  80133d:	c1 e6 18             	shl    $0x18,%esi
  801340:	89 d0                	mov    %edx,%eax
  801342:	c1 e0 10             	shl    $0x10,%eax
  801345:	09 f0                	or     %esi,%eax
  801347:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801349:	89 d8                	mov    %ebx,%eax
  80134b:	09 d0                	or     %edx,%eax
  80134d:	c1 e9 02             	shr    $0x2,%ecx
  801350:	fc                   	cld    
  801351:	f3 ab                	rep stos %eax,%es:(%edi)
  801353:	eb 06                	jmp    80135b <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801355:	8b 45 0c             	mov    0xc(%ebp),%eax
  801358:	fc                   	cld    
  801359:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80135b:	89 f8                	mov    %edi,%eax
  80135d:	5b                   	pop    %ebx
  80135e:	5e                   	pop    %esi
  80135f:	5f                   	pop    %edi
  801360:	5d                   	pop    %ebp
  801361:	c3                   	ret    

00801362 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801362:	55                   	push   %ebp
  801363:	89 e5                	mov    %esp,%ebp
  801365:	57                   	push   %edi
  801366:	56                   	push   %esi
  801367:	8b 45 08             	mov    0x8(%ebp),%eax
  80136a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80136d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801370:	39 c6                	cmp    %eax,%esi
  801372:	73 35                	jae    8013a9 <memmove+0x47>
  801374:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801377:	39 d0                	cmp    %edx,%eax
  801379:	73 2e                	jae    8013a9 <memmove+0x47>
		s += n;
		d += n;
  80137b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80137e:	89 d6                	mov    %edx,%esi
  801380:	09 fe                	or     %edi,%esi
  801382:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801388:	75 13                	jne    80139d <memmove+0x3b>
  80138a:	f6 c1 03             	test   $0x3,%cl
  80138d:	75 0e                	jne    80139d <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80138f:	83 ef 04             	sub    $0x4,%edi
  801392:	8d 72 fc             	lea    -0x4(%edx),%esi
  801395:	c1 e9 02             	shr    $0x2,%ecx
  801398:	fd                   	std    
  801399:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80139b:	eb 09                	jmp    8013a6 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80139d:	83 ef 01             	sub    $0x1,%edi
  8013a0:	8d 72 ff             	lea    -0x1(%edx),%esi
  8013a3:	fd                   	std    
  8013a4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8013a6:	fc                   	cld    
  8013a7:	eb 1d                	jmp    8013c6 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8013a9:	89 f2                	mov    %esi,%edx
  8013ab:	09 c2                	or     %eax,%edx
  8013ad:	f6 c2 03             	test   $0x3,%dl
  8013b0:	75 0f                	jne    8013c1 <memmove+0x5f>
  8013b2:	f6 c1 03             	test   $0x3,%cl
  8013b5:	75 0a                	jne    8013c1 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8013b7:	c1 e9 02             	shr    $0x2,%ecx
  8013ba:	89 c7                	mov    %eax,%edi
  8013bc:	fc                   	cld    
  8013bd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8013bf:	eb 05                	jmp    8013c6 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8013c1:	89 c7                	mov    %eax,%edi
  8013c3:	fc                   	cld    
  8013c4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8013c6:	5e                   	pop    %esi
  8013c7:	5f                   	pop    %edi
  8013c8:	5d                   	pop    %ebp
  8013c9:	c3                   	ret    

008013ca <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8013ca:	55                   	push   %ebp
  8013cb:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8013cd:	ff 75 10             	pushl  0x10(%ebp)
  8013d0:	ff 75 0c             	pushl  0xc(%ebp)
  8013d3:	ff 75 08             	pushl  0x8(%ebp)
  8013d6:	e8 87 ff ff ff       	call   801362 <memmove>
}
  8013db:	c9                   	leave  
  8013dc:	c3                   	ret    

008013dd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8013dd:	55                   	push   %ebp
  8013de:	89 e5                	mov    %esp,%ebp
  8013e0:	56                   	push   %esi
  8013e1:	53                   	push   %ebx
  8013e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8013e5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013e8:	89 c6                	mov    %eax,%esi
  8013ea:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8013ed:	eb 1a                	jmp    801409 <memcmp+0x2c>
		if (*s1 != *s2)
  8013ef:	0f b6 08             	movzbl (%eax),%ecx
  8013f2:	0f b6 1a             	movzbl (%edx),%ebx
  8013f5:	38 d9                	cmp    %bl,%cl
  8013f7:	74 0a                	je     801403 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8013f9:	0f b6 c1             	movzbl %cl,%eax
  8013fc:	0f b6 db             	movzbl %bl,%ebx
  8013ff:	29 d8                	sub    %ebx,%eax
  801401:	eb 0f                	jmp    801412 <memcmp+0x35>
		s1++, s2++;
  801403:	83 c0 01             	add    $0x1,%eax
  801406:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801409:	39 f0                	cmp    %esi,%eax
  80140b:	75 e2                	jne    8013ef <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80140d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801412:	5b                   	pop    %ebx
  801413:	5e                   	pop    %esi
  801414:	5d                   	pop    %ebp
  801415:	c3                   	ret    

00801416 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801416:	55                   	push   %ebp
  801417:	89 e5                	mov    %esp,%ebp
  801419:	53                   	push   %ebx
  80141a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80141d:	89 c1                	mov    %eax,%ecx
  80141f:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801422:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801426:	eb 0a                	jmp    801432 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801428:	0f b6 10             	movzbl (%eax),%edx
  80142b:	39 da                	cmp    %ebx,%edx
  80142d:	74 07                	je     801436 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80142f:	83 c0 01             	add    $0x1,%eax
  801432:	39 c8                	cmp    %ecx,%eax
  801434:	72 f2                	jb     801428 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801436:	5b                   	pop    %ebx
  801437:	5d                   	pop    %ebp
  801438:	c3                   	ret    

00801439 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801439:	55                   	push   %ebp
  80143a:	89 e5                	mov    %esp,%ebp
  80143c:	57                   	push   %edi
  80143d:	56                   	push   %esi
  80143e:	53                   	push   %ebx
  80143f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801442:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801445:	eb 03                	jmp    80144a <strtol+0x11>
		s++;
  801447:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80144a:	0f b6 01             	movzbl (%ecx),%eax
  80144d:	3c 20                	cmp    $0x20,%al
  80144f:	74 f6                	je     801447 <strtol+0xe>
  801451:	3c 09                	cmp    $0x9,%al
  801453:	74 f2                	je     801447 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801455:	3c 2b                	cmp    $0x2b,%al
  801457:	75 0a                	jne    801463 <strtol+0x2a>
		s++;
  801459:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80145c:	bf 00 00 00 00       	mov    $0x0,%edi
  801461:	eb 11                	jmp    801474 <strtol+0x3b>
  801463:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801468:	3c 2d                	cmp    $0x2d,%al
  80146a:	75 08                	jne    801474 <strtol+0x3b>
		s++, neg = 1;
  80146c:	83 c1 01             	add    $0x1,%ecx
  80146f:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801474:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80147a:	75 15                	jne    801491 <strtol+0x58>
  80147c:	80 39 30             	cmpb   $0x30,(%ecx)
  80147f:	75 10                	jne    801491 <strtol+0x58>
  801481:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801485:	75 7c                	jne    801503 <strtol+0xca>
		s += 2, base = 16;
  801487:	83 c1 02             	add    $0x2,%ecx
  80148a:	bb 10 00 00 00       	mov    $0x10,%ebx
  80148f:	eb 16                	jmp    8014a7 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801491:	85 db                	test   %ebx,%ebx
  801493:	75 12                	jne    8014a7 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801495:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80149a:	80 39 30             	cmpb   $0x30,(%ecx)
  80149d:	75 08                	jne    8014a7 <strtol+0x6e>
		s++, base = 8;
  80149f:	83 c1 01             	add    $0x1,%ecx
  8014a2:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8014a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8014ac:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8014af:	0f b6 11             	movzbl (%ecx),%edx
  8014b2:	8d 72 d0             	lea    -0x30(%edx),%esi
  8014b5:	89 f3                	mov    %esi,%ebx
  8014b7:	80 fb 09             	cmp    $0x9,%bl
  8014ba:	77 08                	ja     8014c4 <strtol+0x8b>
			dig = *s - '0';
  8014bc:	0f be d2             	movsbl %dl,%edx
  8014bf:	83 ea 30             	sub    $0x30,%edx
  8014c2:	eb 22                	jmp    8014e6 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8014c4:	8d 72 9f             	lea    -0x61(%edx),%esi
  8014c7:	89 f3                	mov    %esi,%ebx
  8014c9:	80 fb 19             	cmp    $0x19,%bl
  8014cc:	77 08                	ja     8014d6 <strtol+0x9d>
			dig = *s - 'a' + 10;
  8014ce:	0f be d2             	movsbl %dl,%edx
  8014d1:	83 ea 57             	sub    $0x57,%edx
  8014d4:	eb 10                	jmp    8014e6 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8014d6:	8d 72 bf             	lea    -0x41(%edx),%esi
  8014d9:	89 f3                	mov    %esi,%ebx
  8014db:	80 fb 19             	cmp    $0x19,%bl
  8014de:	77 16                	ja     8014f6 <strtol+0xbd>
			dig = *s - 'A' + 10;
  8014e0:	0f be d2             	movsbl %dl,%edx
  8014e3:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8014e6:	3b 55 10             	cmp    0x10(%ebp),%edx
  8014e9:	7d 0b                	jge    8014f6 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  8014eb:	83 c1 01             	add    $0x1,%ecx
  8014ee:	0f af 45 10          	imul   0x10(%ebp),%eax
  8014f2:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8014f4:	eb b9                	jmp    8014af <strtol+0x76>

	if (endptr)
  8014f6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8014fa:	74 0d                	je     801509 <strtol+0xd0>
		*endptr = (char *) s;
  8014fc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8014ff:	89 0e                	mov    %ecx,(%esi)
  801501:	eb 06                	jmp    801509 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801503:	85 db                	test   %ebx,%ebx
  801505:	74 98                	je     80149f <strtol+0x66>
  801507:	eb 9e                	jmp    8014a7 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801509:	89 c2                	mov    %eax,%edx
  80150b:	f7 da                	neg    %edx
  80150d:	85 ff                	test   %edi,%edi
  80150f:	0f 45 c2             	cmovne %edx,%eax
}
  801512:	5b                   	pop    %ebx
  801513:	5e                   	pop    %esi
  801514:	5f                   	pop    %edi
  801515:	5d                   	pop    %ebp
  801516:	c3                   	ret    

00801517 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801517:	55                   	push   %ebp
  801518:	89 e5                	mov    %esp,%ebp
  80151a:	57                   	push   %edi
  80151b:	56                   	push   %esi
  80151c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80151d:	b8 00 00 00 00       	mov    $0x0,%eax
  801522:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801525:	8b 55 08             	mov    0x8(%ebp),%edx
  801528:	89 c3                	mov    %eax,%ebx
  80152a:	89 c7                	mov    %eax,%edi
  80152c:	89 c6                	mov    %eax,%esi
  80152e:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  801530:	5b                   	pop    %ebx
  801531:	5e                   	pop    %esi
  801532:	5f                   	pop    %edi
  801533:	5d                   	pop    %ebp
  801534:	c3                   	ret    

00801535 <sys_cgetc>:

int
sys_cgetc(void)
{
  801535:	55                   	push   %ebp
  801536:	89 e5                	mov    %esp,%ebp
  801538:	57                   	push   %edi
  801539:	56                   	push   %esi
  80153a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80153b:	ba 00 00 00 00       	mov    $0x0,%edx
  801540:	b8 01 00 00 00       	mov    $0x1,%eax
  801545:	89 d1                	mov    %edx,%ecx
  801547:	89 d3                	mov    %edx,%ebx
  801549:	89 d7                	mov    %edx,%edi
  80154b:	89 d6                	mov    %edx,%esi
  80154d:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80154f:	5b                   	pop    %ebx
  801550:	5e                   	pop    %esi
  801551:	5f                   	pop    %edi
  801552:	5d                   	pop    %ebp
  801553:	c3                   	ret    

00801554 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  801554:	55                   	push   %ebp
  801555:	89 e5                	mov    %esp,%ebp
  801557:	57                   	push   %edi
  801558:	56                   	push   %esi
  801559:	53                   	push   %ebx
  80155a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80155d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801562:	b8 03 00 00 00       	mov    $0x3,%eax
  801567:	8b 55 08             	mov    0x8(%ebp),%edx
  80156a:	89 cb                	mov    %ecx,%ebx
  80156c:	89 cf                	mov    %ecx,%edi
  80156e:	89 ce                	mov    %ecx,%esi
  801570:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801572:	85 c0                	test   %eax,%eax
  801574:	7e 17                	jle    80158d <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801576:	83 ec 0c             	sub    $0xc,%esp
  801579:	50                   	push   %eax
  80157a:	6a 03                	push   $0x3
  80157c:	68 8f 37 80 00       	push   $0x80378f
  801581:	6a 23                	push   $0x23
  801583:	68 ac 37 80 00       	push   $0x8037ac
  801588:	e8 4b f4 ff ff       	call   8009d8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80158d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801590:	5b                   	pop    %ebx
  801591:	5e                   	pop    %esi
  801592:	5f                   	pop    %edi
  801593:	5d                   	pop    %ebp
  801594:	c3                   	ret    

00801595 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801595:	55                   	push   %ebp
  801596:	89 e5                	mov    %esp,%ebp
  801598:	57                   	push   %edi
  801599:	56                   	push   %esi
  80159a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80159b:	ba 00 00 00 00       	mov    $0x0,%edx
  8015a0:	b8 02 00 00 00       	mov    $0x2,%eax
  8015a5:	89 d1                	mov    %edx,%ecx
  8015a7:	89 d3                	mov    %edx,%ebx
  8015a9:	89 d7                	mov    %edx,%edi
  8015ab:	89 d6                	mov    %edx,%esi
  8015ad:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8015af:	5b                   	pop    %ebx
  8015b0:	5e                   	pop    %esi
  8015b1:	5f                   	pop    %edi
  8015b2:	5d                   	pop    %ebp
  8015b3:	c3                   	ret    

008015b4 <sys_yield>:

void
sys_yield(void)
{
  8015b4:	55                   	push   %ebp
  8015b5:	89 e5                	mov    %esp,%ebp
  8015b7:	57                   	push   %edi
  8015b8:	56                   	push   %esi
  8015b9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8015ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8015bf:	b8 0b 00 00 00       	mov    $0xb,%eax
  8015c4:	89 d1                	mov    %edx,%ecx
  8015c6:	89 d3                	mov    %edx,%ebx
  8015c8:	89 d7                	mov    %edx,%edi
  8015ca:	89 d6                	mov    %edx,%esi
  8015cc:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8015ce:	5b                   	pop    %ebx
  8015cf:	5e                   	pop    %esi
  8015d0:	5f                   	pop    %edi
  8015d1:	5d                   	pop    %ebp
  8015d2:	c3                   	ret    

008015d3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8015d3:	55                   	push   %ebp
  8015d4:	89 e5                	mov    %esp,%ebp
  8015d6:	57                   	push   %edi
  8015d7:	56                   	push   %esi
  8015d8:	53                   	push   %ebx
  8015d9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8015dc:	be 00 00 00 00       	mov    $0x0,%esi
  8015e1:	b8 04 00 00 00       	mov    $0x4,%eax
  8015e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8015ec:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8015ef:	89 f7                	mov    %esi,%edi
  8015f1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8015f3:	85 c0                	test   %eax,%eax
  8015f5:	7e 17                	jle    80160e <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8015f7:	83 ec 0c             	sub    $0xc,%esp
  8015fa:	50                   	push   %eax
  8015fb:	6a 04                	push   $0x4
  8015fd:	68 8f 37 80 00       	push   $0x80378f
  801602:	6a 23                	push   $0x23
  801604:	68 ac 37 80 00       	push   $0x8037ac
  801609:	e8 ca f3 ff ff       	call   8009d8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80160e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801611:	5b                   	pop    %ebx
  801612:	5e                   	pop    %esi
  801613:	5f                   	pop    %edi
  801614:	5d                   	pop    %ebp
  801615:	c3                   	ret    

00801616 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801616:	55                   	push   %ebp
  801617:	89 e5                	mov    %esp,%ebp
  801619:	57                   	push   %edi
  80161a:	56                   	push   %esi
  80161b:	53                   	push   %ebx
  80161c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80161f:	b8 05 00 00 00       	mov    $0x5,%eax
  801624:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801627:	8b 55 08             	mov    0x8(%ebp),%edx
  80162a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80162d:	8b 7d 14             	mov    0x14(%ebp),%edi
  801630:	8b 75 18             	mov    0x18(%ebp),%esi
  801633:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801635:	85 c0                	test   %eax,%eax
  801637:	7e 17                	jle    801650 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801639:	83 ec 0c             	sub    $0xc,%esp
  80163c:	50                   	push   %eax
  80163d:	6a 05                	push   $0x5
  80163f:	68 8f 37 80 00       	push   $0x80378f
  801644:	6a 23                	push   $0x23
  801646:	68 ac 37 80 00       	push   $0x8037ac
  80164b:	e8 88 f3 ff ff       	call   8009d8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801650:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801653:	5b                   	pop    %ebx
  801654:	5e                   	pop    %esi
  801655:	5f                   	pop    %edi
  801656:	5d                   	pop    %ebp
  801657:	c3                   	ret    

00801658 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801658:	55                   	push   %ebp
  801659:	89 e5                	mov    %esp,%ebp
  80165b:	57                   	push   %edi
  80165c:	56                   	push   %esi
  80165d:	53                   	push   %ebx
  80165e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801661:	bb 00 00 00 00       	mov    $0x0,%ebx
  801666:	b8 06 00 00 00       	mov    $0x6,%eax
  80166b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80166e:	8b 55 08             	mov    0x8(%ebp),%edx
  801671:	89 df                	mov    %ebx,%edi
  801673:	89 de                	mov    %ebx,%esi
  801675:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801677:	85 c0                	test   %eax,%eax
  801679:	7e 17                	jle    801692 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80167b:	83 ec 0c             	sub    $0xc,%esp
  80167e:	50                   	push   %eax
  80167f:	6a 06                	push   $0x6
  801681:	68 8f 37 80 00       	push   $0x80378f
  801686:	6a 23                	push   $0x23
  801688:	68 ac 37 80 00       	push   $0x8037ac
  80168d:	e8 46 f3 ff ff       	call   8009d8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801692:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801695:	5b                   	pop    %ebx
  801696:	5e                   	pop    %esi
  801697:	5f                   	pop    %edi
  801698:	5d                   	pop    %ebp
  801699:	c3                   	ret    

0080169a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80169a:	55                   	push   %ebp
  80169b:	89 e5                	mov    %esp,%ebp
  80169d:	57                   	push   %edi
  80169e:	56                   	push   %esi
  80169f:	53                   	push   %ebx
  8016a0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8016a3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016a8:	b8 08 00 00 00       	mov    $0x8,%eax
  8016ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8016b3:	89 df                	mov    %ebx,%edi
  8016b5:	89 de                	mov    %ebx,%esi
  8016b7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8016b9:	85 c0                	test   %eax,%eax
  8016bb:	7e 17                	jle    8016d4 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8016bd:	83 ec 0c             	sub    $0xc,%esp
  8016c0:	50                   	push   %eax
  8016c1:	6a 08                	push   $0x8
  8016c3:	68 8f 37 80 00       	push   $0x80378f
  8016c8:	6a 23                	push   $0x23
  8016ca:	68 ac 37 80 00       	push   $0x8037ac
  8016cf:	e8 04 f3 ff ff       	call   8009d8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8016d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016d7:	5b                   	pop    %ebx
  8016d8:	5e                   	pop    %esi
  8016d9:	5f                   	pop    %edi
  8016da:	5d                   	pop    %ebp
  8016db:	c3                   	ret    

008016dc <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8016dc:	55                   	push   %ebp
  8016dd:	89 e5                	mov    %esp,%ebp
  8016df:	57                   	push   %edi
  8016e0:	56                   	push   %esi
  8016e1:	53                   	push   %ebx
  8016e2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8016e5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016ea:	b8 09 00 00 00       	mov    $0x9,%eax
  8016ef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8016f5:	89 df                	mov    %ebx,%edi
  8016f7:	89 de                	mov    %ebx,%esi
  8016f9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8016fb:	85 c0                	test   %eax,%eax
  8016fd:	7e 17                	jle    801716 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8016ff:	83 ec 0c             	sub    $0xc,%esp
  801702:	50                   	push   %eax
  801703:	6a 09                	push   $0x9
  801705:	68 8f 37 80 00       	push   $0x80378f
  80170a:	6a 23                	push   $0x23
  80170c:	68 ac 37 80 00       	push   $0x8037ac
  801711:	e8 c2 f2 ff ff       	call   8009d8 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801716:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801719:	5b                   	pop    %ebx
  80171a:	5e                   	pop    %esi
  80171b:	5f                   	pop    %edi
  80171c:	5d                   	pop    %ebp
  80171d:	c3                   	ret    

0080171e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80171e:	55                   	push   %ebp
  80171f:	89 e5                	mov    %esp,%ebp
  801721:	57                   	push   %edi
  801722:	56                   	push   %esi
  801723:	53                   	push   %ebx
  801724:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801727:	bb 00 00 00 00       	mov    $0x0,%ebx
  80172c:	b8 0a 00 00 00       	mov    $0xa,%eax
  801731:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801734:	8b 55 08             	mov    0x8(%ebp),%edx
  801737:	89 df                	mov    %ebx,%edi
  801739:	89 de                	mov    %ebx,%esi
  80173b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80173d:	85 c0                	test   %eax,%eax
  80173f:	7e 17                	jle    801758 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801741:	83 ec 0c             	sub    $0xc,%esp
  801744:	50                   	push   %eax
  801745:	6a 0a                	push   $0xa
  801747:	68 8f 37 80 00       	push   $0x80378f
  80174c:	6a 23                	push   $0x23
  80174e:	68 ac 37 80 00       	push   $0x8037ac
  801753:	e8 80 f2 ff ff       	call   8009d8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801758:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80175b:	5b                   	pop    %ebx
  80175c:	5e                   	pop    %esi
  80175d:	5f                   	pop    %edi
  80175e:	5d                   	pop    %ebp
  80175f:	c3                   	ret    

00801760 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801760:	55                   	push   %ebp
  801761:	89 e5                	mov    %esp,%ebp
  801763:	57                   	push   %edi
  801764:	56                   	push   %esi
  801765:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801766:	be 00 00 00 00       	mov    $0x0,%esi
  80176b:	b8 0c 00 00 00       	mov    $0xc,%eax
  801770:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801773:	8b 55 08             	mov    0x8(%ebp),%edx
  801776:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801779:	8b 7d 14             	mov    0x14(%ebp),%edi
  80177c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80177e:	5b                   	pop    %ebx
  80177f:	5e                   	pop    %esi
  801780:	5f                   	pop    %edi
  801781:	5d                   	pop    %ebp
  801782:	c3                   	ret    

00801783 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801783:	55                   	push   %ebp
  801784:	89 e5                	mov    %esp,%ebp
  801786:	57                   	push   %edi
  801787:	56                   	push   %esi
  801788:	53                   	push   %ebx
  801789:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80178c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801791:	b8 0d 00 00 00       	mov    $0xd,%eax
  801796:	8b 55 08             	mov    0x8(%ebp),%edx
  801799:	89 cb                	mov    %ecx,%ebx
  80179b:	89 cf                	mov    %ecx,%edi
  80179d:	89 ce                	mov    %ecx,%esi
  80179f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8017a1:	85 c0                	test   %eax,%eax
  8017a3:	7e 17                	jle    8017bc <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8017a5:	83 ec 0c             	sub    $0xc,%esp
  8017a8:	50                   	push   %eax
  8017a9:	6a 0d                	push   $0xd
  8017ab:	68 8f 37 80 00       	push   $0x80378f
  8017b0:	6a 23                	push   $0x23
  8017b2:	68 ac 37 80 00       	push   $0x8037ac
  8017b7:	e8 1c f2 ff ff       	call   8009d8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8017bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017bf:	5b                   	pop    %ebx
  8017c0:	5e                   	pop    %esi
  8017c1:	5f                   	pop    %edi
  8017c2:	5d                   	pop    %ebp
  8017c3:	c3                   	ret    

008017c4 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8017c4:	55                   	push   %ebp
  8017c5:	89 e5                	mov    %esp,%ebp
  8017c7:	53                   	push   %ebx
  8017c8:	83 ec 04             	sub    $0x4,%esp
  8017cb:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8017ce:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & 
  8017d0:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8017d4:	0f 84 48 01 00 00    	je     801922 <pgfault+0x15e>
  8017da:	89 d8                	mov    %ebx,%eax
  8017dc:	c1 e8 16             	shr    $0x16,%eax
  8017df:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8017e6:	a8 01                	test   $0x1,%al
  8017e8:	0f 84 5f 01 00 00    	je     80194d <pgfault+0x189>
  8017ee:	89 d8                	mov    %ebx,%eax
  8017f0:	c1 e8 0c             	shr    $0xc,%eax
  8017f3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8017fa:	f6 c2 01             	test   $0x1,%dl
  8017fd:	0f 84 4a 01 00 00    	je     80194d <pgfault+0x189>
				PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW))) {
  801803:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & 
  80180a:	f6 c4 08             	test   $0x8,%ah
  80180d:	75 79                	jne    801888 <pgfault+0xc4>
  80180f:	e9 39 01 00 00       	jmp    80194d <pgfault+0x189>
				PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW))) {
		cprintf("Fault address = %08x, envid = %08x\n", addr, thisenv->env_id);
		if (!(err & FEC_WR)) cprintf("Not write\n");
		if (!(uvpd[PDX(addr)] & PTE_P)) cprintf("PDE not present\n");
  801814:	89 d8                	mov    %ebx,%eax
  801816:	c1 e8 16             	shr    $0x16,%eax
  801819:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801820:	a8 01                	test   $0x1,%al
  801822:	75 10                	jne    801834 <pgfault+0x70>
  801824:	83 ec 0c             	sub    $0xc,%esp
  801827:	68 ba 37 80 00       	push   $0x8037ba
  80182c:	e8 80 f2 ff ff       	call   800ab1 <cprintf>
  801831:	83 c4 10             	add    $0x10,%esp
		if (!(uvpt[PTX(addr)] & PTE_P)) cprintf("PTE not present\n");
  801834:	c1 eb 0c             	shr    $0xc,%ebx
  801837:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  80183d:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801844:	a8 01                	test   $0x1,%al
  801846:	75 10                	jne    801858 <pgfault+0x94>
  801848:	83 ec 0c             	sub    $0xc,%esp
  80184b:	68 cb 37 80 00       	push   $0x8037cb
  801850:	e8 5c f2 ff ff       	call   800ab1 <cprintf>
  801855:	83 c4 10             	add    $0x10,%esp
		if (!(uvpt[PTX(addr)] & PTE_COW)) cprintf("Not copy-on-write\n");
  801858:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  80185f:	f6 c4 08             	test   $0x8,%ah
  801862:	75 10                	jne    801874 <pgfault+0xb0>
  801864:	83 ec 0c             	sub    $0xc,%esp
  801867:	68 dc 37 80 00       	push   $0x8037dc
  80186c:	e8 40 f2 ff ff       	call   800ab1 <cprintf>
  801871:	83 c4 10             	add    $0x10,%esp
		panic("User page fault");
  801874:	83 ec 04             	sub    $0x4,%esp
  801877:	68 ef 37 80 00       	push   $0x8037ef
  80187c:	6a 23                	push   $0x23
  80187e:	68 ff 37 80 00       	push   $0x8037ff
  801883:	e8 50 f1 ff ff       	call   8009d8 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// 0 refers to curenv
	if ((r = sys_page_alloc(0, (void*)PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  801888:	83 ec 04             	sub    $0x4,%esp
  80188b:	6a 07                	push   $0x7
  80188d:	68 00 f0 7f 00       	push   $0x7ff000
  801892:	6a 00                	push   $0x0
  801894:	e8 3a fd ff ff       	call   8015d3 <sys_page_alloc>
  801899:	83 c4 10             	add    $0x10,%esp
  80189c:	85 c0                	test   %eax,%eax
  80189e:	79 12                	jns    8018b2 <pgfault+0xee>
		panic("sys_page_alloc failed: %e", r);
  8018a0:	50                   	push   %eax
  8018a1:	68 0a 38 80 00       	push   $0x80380a
  8018a6:	6a 2f                	push   $0x2f
  8018a8:	68 ff 37 80 00       	push   $0x8037ff
  8018ad:	e8 26 f1 ff ff       	call   8009d8 <_panic>
	memcpy((void*)PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  8018b2:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  8018b8:	83 ec 04             	sub    $0x4,%esp
  8018bb:	68 00 10 00 00       	push   $0x1000
  8018c0:	53                   	push   %ebx
  8018c1:	68 00 f0 7f 00       	push   $0x7ff000
  8018c6:	e8 ff fa ff ff       	call   8013ca <memcpy>
	if ((r = sys_page_map(0, (void*)PFTEMP, 0, (void*)ROUNDDOWN(addr, PGSIZE), 
  8018cb:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  8018d2:	53                   	push   %ebx
  8018d3:	6a 00                	push   $0x0
  8018d5:	68 00 f0 7f 00       	push   $0x7ff000
  8018da:	6a 00                	push   $0x0
  8018dc:	e8 35 fd ff ff       	call   801616 <sys_page_map>
  8018e1:	83 c4 20             	add    $0x20,%esp
  8018e4:	85 c0                	test   %eax,%eax
  8018e6:	79 12                	jns    8018fa <pgfault+0x136>
					PTE_P | PTE_U | PTE_W)) < 0)
		panic("sys_page_map failed: %e", r);
  8018e8:	50                   	push   %eax
  8018e9:	68 24 38 80 00       	push   $0x803824
  8018ee:	6a 33                	push   $0x33
  8018f0:	68 ff 37 80 00       	push   $0x8037ff
  8018f5:	e8 de f0 ff ff       	call   8009d8 <_panic>
	if ((r = sys_page_unmap(0, (void*)PFTEMP)) < 0)
  8018fa:	83 ec 08             	sub    $0x8,%esp
  8018fd:	68 00 f0 7f 00       	push   $0x7ff000
  801902:	6a 00                	push   $0x0
  801904:	e8 4f fd ff ff       	call   801658 <sys_page_unmap>
  801909:	83 c4 10             	add    $0x10,%esp
  80190c:	85 c0                	test   %eax,%eax
  80190e:	79 5c                	jns    80196c <pgfault+0x1a8>
		panic("sys_page_unmap failed: %e", r);
  801910:	50                   	push   %eax
  801911:	68 3c 38 80 00       	push   $0x80383c
  801916:	6a 35                	push   $0x35
  801918:	68 ff 37 80 00       	push   $0x8037ff
  80191d:	e8 b6 f0 ff ff       	call   8009d8 <_panic>
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & 
				PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW))) {
		cprintf("Fault address = %08x, envid = %08x\n", addr, thisenv->env_id);
  801922:	a1 24 54 80 00       	mov    0x805424,%eax
  801927:	8b 40 48             	mov    0x48(%eax),%eax
  80192a:	83 ec 04             	sub    $0x4,%esp
  80192d:	50                   	push   %eax
  80192e:	53                   	push   %ebx
  80192f:	68 78 38 80 00       	push   $0x803878
  801934:	e8 78 f1 ff ff       	call   800ab1 <cprintf>
		if (!(err & FEC_WR)) cprintf("Not write\n");
  801939:	c7 04 24 56 38 80 00 	movl   $0x803856,(%esp)
  801940:	e8 6c f1 ff ff       	call   800ab1 <cprintf>
  801945:	83 c4 10             	add    $0x10,%esp
  801948:	e9 c7 fe ff ff       	jmp    801814 <pgfault+0x50>
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & 
				PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW))) {
		cprintf("Fault address = %08x, envid = %08x\n", addr, thisenv->env_id);
  80194d:	a1 24 54 80 00       	mov    0x805424,%eax
  801952:	8b 40 48             	mov    0x48(%eax),%eax
  801955:	83 ec 04             	sub    $0x4,%esp
  801958:	50                   	push   %eax
  801959:	53                   	push   %ebx
  80195a:	68 78 38 80 00       	push   $0x803878
  80195f:	e8 4d f1 ff ff       	call   800ab1 <cprintf>
  801964:	83 c4 10             	add    $0x10,%esp
  801967:	e9 a8 fe ff ff       	jmp    801814 <pgfault+0x50>
		panic("sys_page_map failed: %e", r);
	if ((r = sys_page_unmap(0, (void*)PFTEMP)) < 0)
		panic("sys_page_unmap failed: %e", r);

	// panic("pgfault not implemented");
}
  80196c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80196f:	c9                   	leave  
  801970:	c3                   	ret    

00801971 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801971:	55                   	push   %ebp
  801972:	89 e5                	mov    %esp,%ebp
  801974:	57                   	push   %edi
  801975:	56                   	push   %esi
  801976:	53                   	push   %ebx
  801977:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	int ret;
	set_pgfault_handler(pgfault);
  80197a:	68 c4 17 80 00       	push   $0x8017c4
  80197f:	e8 78 14 00 00       	call   802dfc <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801984:	b8 07 00 00 00       	mov    $0x7,%eax
  801989:	cd 30                	int    $0x30
  80198b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80198e:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	envid_t envid = sys_exofork();

	if (envid < 0) return envid;
  801991:	83 c4 10             	add    $0x10,%esp
  801994:	85 c0                	test   %eax,%eax
  801996:	0f 88 0d 01 00 00    	js     801aa9 <fork+0x138>
  80199c:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019a1:	be 00 00 00 00       	mov    $0x0,%esi
	else if (envid == 0) {
  8019a6:	85 c0                	test   %eax,%eax
  8019a8:	75 2f                	jne    8019d9 <fork+0x68>
		// Child returns
		thisenv = &envs[ENVX(sys_getenvid())];
  8019aa:	e8 e6 fb ff ff       	call   801595 <sys_getenvid>
  8019af:	25 ff 03 00 00       	and    $0x3ff,%eax
  8019b4:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8019b7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8019bc:	a3 24 54 80 00       	mov    %eax,0x805424
		// set_pgfault_handler(pgfault);
		return 0;
  8019c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8019c6:	e9 e1 00 00 00       	jmp    801aac <fork+0x13b>
  8019cb:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
	}
	else {
		uint32_t pn;
		for (pn = 0; pn * PGSIZE < UTOP; pn++){
			// cprintf("virtual page %08x\n", pn * PGSIZE);
			if (pn * PGSIZE == UXSTACKTOP - PGSIZE) 
  8019d1:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  8019d7:	74 77                	je     801a50 <fork+0xdf>
{
	int r;

	// LAB 4: Your code here.
	int perm = PTE_P | PTE_U;
	pde_t pde = uvpd[pn / NPTENTRIES];
  8019d9:	89 f0                	mov    %esi,%eax
  8019db:	c1 e8 0a             	shr    $0xa,%eax
  8019de:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
	if (!(pde & PTE_P)) return 0;
  8019e5:	a8 01                	test   $0x1,%al
  8019e7:	74 0b                	je     8019f4 <fork+0x83>
	pte_t pte = uvpt[pn];
  8019e9:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	if (!(pte & PTE_P)) return 0;
  8019f0:	a8 01                	test   $0x1,%al
  8019f2:	75 08                	jne    8019fc <fork+0x8b>
  8019f4:	8d 5e 01             	lea    0x1(%esi),%ebx
  8019f7:	c1 e3 0c             	shl    $0xc,%ebx
  8019fa:	eb 56                	jmp    801a52 <fork+0xe1>
	// cprintf("virtual page %08x\n", pn * PGSIZE);

	if ((pte & PTE_W) || (pte & PTE_COW)) perm |= PTE_COW;
  8019fc:	25 02 08 00 00       	and    $0x802,%eax
  801a01:	83 f8 01             	cmp    $0x1,%eax
  801a04:	19 ff                	sbb    %edi,%edi
  801a06:	81 e7 00 f8 ff ff    	and    $0xfffff800,%edi
  801a0c:	81 c7 05 08 00 00    	add    $0x805,%edi

	if ((r = sys_page_map(thisenv->env_id, (void*)(pn * PGSIZE), envid, 
  801a12:	a1 24 54 80 00       	mov    0x805424,%eax
  801a17:	8b 40 48             	mov    0x48(%eax),%eax
  801a1a:	83 ec 0c             	sub    $0xc,%esp
  801a1d:	57                   	push   %edi
  801a1e:	53                   	push   %ebx
  801a1f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a22:	53                   	push   %ebx
  801a23:	50                   	push   %eax
  801a24:	e8 ed fb ff ff       	call   801616 <sys_page_map>
  801a29:	83 c4 20             	add    $0x20,%esp
  801a2c:	85 c0                	test   %eax,%eax
  801a2e:	78 7c                	js     801aac <fork+0x13b>
				(void*)(pn * PGSIZE), perm)) < 0) 
		return r;
	r = sys_page_map(envid, (void*)(pn * PGSIZE), thisenv->env_id, 
  801a30:	a1 24 54 80 00       	mov    0x805424,%eax
  801a35:	8b 40 48             	mov    0x48(%eax),%eax
  801a38:	83 ec 0c             	sub    $0xc,%esp
  801a3b:	57                   	push   %edi
  801a3c:	53                   	push   %ebx
  801a3d:	50                   	push   %eax
  801a3e:	53                   	push   %ebx
  801a3f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a42:	e8 cf fb ff ff       	call   801616 <sys_page_map>
		uint32_t pn;
		for (pn = 0; pn * PGSIZE < UTOP; pn++){
			// cprintf("virtual page %08x\n", pn * PGSIZE);
			if (pn * PGSIZE == UXSTACKTOP - PGSIZE) 
				continue;
			if ((ret = duppage(envid, pn)) < 0)
  801a47:	83 c4 20             	add    $0x20,%esp
  801a4a:	85 c0                	test   %eax,%eax
  801a4c:	79 a6                	jns    8019f4 <fork+0x83>
  801a4e:	eb 5c                	jmp    801aac <fork+0x13b>
  801a50:	89 c3                	mov    %eax,%ebx
		// set_pgfault_handler(pgfault);
		return 0;
	}
	else {
		uint32_t pn;
		for (pn = 0; pn * PGSIZE < UTOP; pn++){
  801a52:	83 c6 01             	add    $0x1,%esi
  801a55:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
  801a5b:	0f 86 6a ff ff ff    	jbe    8019cb <fork+0x5a>
				return ret;
		}
		// cprintf("Fork: duppage finished\n");

		// Should be done by parent
		if ((ret = sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P |
  801a61:	83 ec 04             	sub    $0x4,%esp
  801a64:	6a 07                	push   $0x7
  801a66:	68 00 f0 bf ee       	push   $0xeebff000
  801a6b:	8b 7d e0             	mov    -0x20(%ebp),%edi
  801a6e:	57                   	push   %edi
  801a6f:	e8 5f fb ff ff       	call   8015d3 <sys_page_alloc>
  801a74:	83 c4 10             	add    $0x10,%esp
  801a77:	85 c0                	test   %eax,%eax
  801a79:	78 31                	js     801aac <fork+0x13b>
						PTE_U | PTE_W)) < 0)
			return ret;
		if ((ret = sys_env_set_pgfault_upcall(envid, 
						thisenv->env_pgfault_upcall)) < 0)
  801a7b:	a1 24 54 80 00       	mov    0x805424,%eax

		// Should be done by parent
		if ((ret = sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P |
						PTE_U | PTE_W)) < 0)
			return ret;
		if ((ret = sys_env_set_pgfault_upcall(envid, 
  801a80:	8b 40 64             	mov    0x64(%eax),%eax
  801a83:	83 ec 08             	sub    $0x8,%esp
  801a86:	50                   	push   %eax
  801a87:	57                   	push   %edi
  801a88:	e8 91 fc ff ff       	call   80171e <sys_env_set_pgfault_upcall>
  801a8d:	83 c4 10             	add    $0x10,%esp
  801a90:	85 c0                	test   %eax,%eax
  801a92:	78 18                	js     801aac <fork+0x13b>
						thisenv->env_pgfault_upcall)) < 0)
			return ret;

		if ((ret = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  801a94:	83 ec 08             	sub    $0x8,%esp
  801a97:	6a 02                	push   $0x2
  801a99:	57                   	push   %edi
  801a9a:	e8 fb fb ff ff       	call   80169a <sys_env_set_status>
  801a9f:	83 c4 10             	add    $0x10,%esp
			return ret;
		return envid;
  801aa2:	85 c0                	test   %eax,%eax
  801aa4:	0f 49 c7             	cmovns %edi,%eax
  801aa7:	eb 03                	jmp    801aac <fork+0x13b>
	int ret;
	set_pgfault_handler(pgfault);

	envid_t envid = sys_exofork();

	if (envid < 0) return envid;
  801aa9:	8b 45 e0             	mov    -0x20(%ebp),%eax
			return ret;
		return envid;
	}

	panic("fork not implemented");
}
  801aac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aaf:	5b                   	pop    %ebx
  801ab0:	5e                   	pop    %esi
  801ab1:	5f                   	pop    %edi
  801ab2:	5d                   	pop    %ebp
  801ab3:	c3                   	ret    

00801ab4 <sfork>:

// Challenge!
int
sfork(void)
{
  801ab4:	55                   	push   %ebp
  801ab5:	89 e5                	mov    %esp,%ebp
  801ab7:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801aba:	68 61 38 80 00       	push   $0x803861
  801abf:	68 9f 00 00 00       	push   $0x9f
  801ac4:	68 ff 37 80 00       	push   $0x8037ff
  801ac9:	e8 0a ef ff ff       	call   8009d8 <_panic>

00801ace <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  801ace:	55                   	push   %ebp
  801acf:	89 e5                	mov    %esp,%ebp
  801ad1:	8b 55 08             	mov    0x8(%ebp),%edx
  801ad4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ad7:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  801ada:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  801adc:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  801adf:	83 3a 01             	cmpl   $0x1,(%edx)
  801ae2:	7e 09                	jle    801aed <argstart+0x1f>
  801ae4:	ba 61 32 80 00       	mov    $0x803261,%edx
  801ae9:	85 c9                	test   %ecx,%ecx
  801aeb:	75 05                	jne    801af2 <argstart+0x24>
  801aed:	ba 00 00 00 00       	mov    $0x0,%edx
  801af2:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  801af5:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  801afc:	5d                   	pop    %ebp
  801afd:	c3                   	ret    

00801afe <argnext>:

int
argnext(struct Argstate *args)
{
  801afe:	55                   	push   %ebp
  801aff:	89 e5                	mov    %esp,%ebp
  801b01:	53                   	push   %ebx
  801b02:	83 ec 04             	sub    $0x4,%esp
  801b05:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  801b08:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  801b0f:	8b 43 08             	mov    0x8(%ebx),%eax
  801b12:	85 c0                	test   %eax,%eax
  801b14:	74 6f                	je     801b85 <argnext+0x87>
		return -1;

	if (!*args->curarg) {
  801b16:	80 38 00             	cmpb   $0x0,(%eax)
  801b19:	75 4e                	jne    801b69 <argnext+0x6b>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  801b1b:	8b 0b                	mov    (%ebx),%ecx
  801b1d:	83 39 01             	cmpl   $0x1,(%ecx)
  801b20:	74 55                	je     801b77 <argnext+0x79>
		    || args->argv[1][0] != '-'
  801b22:	8b 53 04             	mov    0x4(%ebx),%edx
  801b25:	8b 42 04             	mov    0x4(%edx),%eax
  801b28:	80 38 2d             	cmpb   $0x2d,(%eax)
  801b2b:	75 4a                	jne    801b77 <argnext+0x79>
		    || args->argv[1][1] == '\0')
  801b2d:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801b31:	74 44                	je     801b77 <argnext+0x79>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  801b33:	83 c0 01             	add    $0x1,%eax
  801b36:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801b39:	83 ec 04             	sub    $0x4,%esp
  801b3c:	8b 01                	mov    (%ecx),%eax
  801b3e:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801b45:	50                   	push   %eax
  801b46:	8d 42 08             	lea    0x8(%edx),%eax
  801b49:	50                   	push   %eax
  801b4a:	83 c2 04             	add    $0x4,%edx
  801b4d:	52                   	push   %edx
  801b4e:	e8 0f f8 ff ff       	call   801362 <memmove>
		(*args->argc)--;
  801b53:	8b 03                	mov    (%ebx),%eax
  801b55:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801b58:	8b 43 08             	mov    0x8(%ebx),%eax
  801b5b:	83 c4 10             	add    $0x10,%esp
  801b5e:	80 38 2d             	cmpb   $0x2d,(%eax)
  801b61:	75 06                	jne    801b69 <argnext+0x6b>
  801b63:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801b67:	74 0e                	je     801b77 <argnext+0x79>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  801b69:	8b 53 08             	mov    0x8(%ebx),%edx
  801b6c:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  801b6f:	83 c2 01             	add    $0x1,%edx
  801b72:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  801b75:	eb 13                	jmp    801b8a <argnext+0x8c>

    endofargs:
	args->curarg = 0;
  801b77:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  801b7e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801b83:	eb 05                	jmp    801b8a <argnext+0x8c>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  801b85:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  801b8a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b8d:	c9                   	leave  
  801b8e:	c3                   	ret    

00801b8f <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  801b8f:	55                   	push   %ebp
  801b90:	89 e5                	mov    %esp,%ebp
  801b92:	53                   	push   %ebx
  801b93:	83 ec 04             	sub    $0x4,%esp
  801b96:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  801b99:	8b 43 08             	mov    0x8(%ebx),%eax
  801b9c:	85 c0                	test   %eax,%eax
  801b9e:	74 58                	je     801bf8 <argnextvalue+0x69>
		return 0;
	if (*args->curarg) {
  801ba0:	80 38 00             	cmpb   $0x0,(%eax)
  801ba3:	74 0c                	je     801bb1 <argnextvalue+0x22>
		args->argvalue = args->curarg;
  801ba5:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  801ba8:	c7 43 08 61 32 80 00 	movl   $0x803261,0x8(%ebx)
  801baf:	eb 42                	jmp    801bf3 <argnextvalue+0x64>
	} else if (*args->argc > 1) {
  801bb1:	8b 13                	mov    (%ebx),%edx
  801bb3:	83 3a 01             	cmpl   $0x1,(%edx)
  801bb6:	7e 2d                	jle    801be5 <argnextvalue+0x56>
		args->argvalue = args->argv[1];
  801bb8:	8b 43 04             	mov    0x4(%ebx),%eax
  801bbb:	8b 48 04             	mov    0x4(%eax),%ecx
  801bbe:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801bc1:	83 ec 04             	sub    $0x4,%esp
  801bc4:	8b 12                	mov    (%edx),%edx
  801bc6:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  801bcd:	52                   	push   %edx
  801bce:	8d 50 08             	lea    0x8(%eax),%edx
  801bd1:	52                   	push   %edx
  801bd2:	83 c0 04             	add    $0x4,%eax
  801bd5:	50                   	push   %eax
  801bd6:	e8 87 f7 ff ff       	call   801362 <memmove>
		(*args->argc)--;
  801bdb:	8b 03                	mov    (%ebx),%eax
  801bdd:	83 28 01             	subl   $0x1,(%eax)
  801be0:	83 c4 10             	add    $0x10,%esp
  801be3:	eb 0e                	jmp    801bf3 <argnextvalue+0x64>
	} else {
		args->argvalue = 0;
  801be5:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  801bec:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  801bf3:	8b 43 0c             	mov    0xc(%ebx),%eax
  801bf6:	eb 05                	jmp    801bfd <argnextvalue+0x6e>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  801bf8:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  801bfd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c00:	c9                   	leave  
  801c01:	c3                   	ret    

00801c02 <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  801c02:	55                   	push   %ebp
  801c03:	89 e5                	mov    %esp,%ebp
  801c05:	83 ec 08             	sub    $0x8,%esp
  801c08:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801c0b:	8b 51 0c             	mov    0xc(%ecx),%edx
  801c0e:	89 d0                	mov    %edx,%eax
  801c10:	85 d2                	test   %edx,%edx
  801c12:	75 0c                	jne    801c20 <argvalue+0x1e>
  801c14:	83 ec 0c             	sub    $0xc,%esp
  801c17:	51                   	push   %ecx
  801c18:	e8 72 ff ff ff       	call   801b8f <argnextvalue>
  801c1d:	83 c4 10             	add    $0x10,%esp
}
  801c20:	c9                   	leave  
  801c21:	c3                   	ret    

00801c22 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801c22:	55                   	push   %ebp
  801c23:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801c25:	8b 45 08             	mov    0x8(%ebp),%eax
  801c28:	05 00 00 00 30       	add    $0x30000000,%eax
  801c2d:	c1 e8 0c             	shr    $0xc,%eax
}
  801c30:	5d                   	pop    %ebp
  801c31:	c3                   	ret    

00801c32 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801c32:	55                   	push   %ebp
  801c33:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801c35:	8b 45 08             	mov    0x8(%ebp),%eax
  801c38:	05 00 00 00 30       	add    $0x30000000,%eax
  801c3d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801c42:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801c47:	5d                   	pop    %ebp
  801c48:	c3                   	ret    

00801c49 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801c49:	55                   	push   %ebp
  801c4a:	89 e5                	mov    %esp,%ebp
  801c4c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c4f:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801c54:	89 c2                	mov    %eax,%edx
  801c56:	c1 ea 16             	shr    $0x16,%edx
  801c59:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801c60:	f6 c2 01             	test   $0x1,%dl
  801c63:	74 11                	je     801c76 <fd_alloc+0x2d>
  801c65:	89 c2                	mov    %eax,%edx
  801c67:	c1 ea 0c             	shr    $0xc,%edx
  801c6a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801c71:	f6 c2 01             	test   $0x1,%dl
  801c74:	75 09                	jne    801c7f <fd_alloc+0x36>
			*fd_store = fd;
  801c76:	89 01                	mov    %eax,(%ecx)
			return 0;
  801c78:	b8 00 00 00 00       	mov    $0x0,%eax
  801c7d:	eb 17                	jmp    801c96 <fd_alloc+0x4d>
  801c7f:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801c84:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801c89:	75 c9                	jne    801c54 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801c8b:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801c91:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801c96:	5d                   	pop    %ebp
  801c97:	c3                   	ret    

00801c98 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801c98:	55                   	push   %ebp
  801c99:	89 e5                	mov    %esp,%ebp
  801c9b:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801c9e:	83 f8 1f             	cmp    $0x1f,%eax
  801ca1:	77 36                	ja     801cd9 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801ca3:	c1 e0 0c             	shl    $0xc,%eax
  801ca6:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801cab:	89 c2                	mov    %eax,%edx
  801cad:	c1 ea 16             	shr    $0x16,%edx
  801cb0:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801cb7:	f6 c2 01             	test   $0x1,%dl
  801cba:	74 24                	je     801ce0 <fd_lookup+0x48>
  801cbc:	89 c2                	mov    %eax,%edx
  801cbe:	c1 ea 0c             	shr    $0xc,%edx
  801cc1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801cc8:	f6 c2 01             	test   $0x1,%dl
  801ccb:	74 1a                	je     801ce7 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801ccd:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cd0:	89 02                	mov    %eax,(%edx)
	return 0;
  801cd2:	b8 00 00 00 00       	mov    $0x0,%eax
  801cd7:	eb 13                	jmp    801cec <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801cd9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801cde:	eb 0c                	jmp    801cec <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801ce0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801ce5:	eb 05                	jmp    801cec <fd_lookup+0x54>
  801ce7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801cec:	5d                   	pop    %ebp
  801ced:	c3                   	ret    

00801cee <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801cee:	55                   	push   %ebp
  801cef:	89 e5                	mov    %esp,%ebp
  801cf1:	83 ec 08             	sub    $0x8,%esp
  801cf4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cf7:	ba 18 39 80 00       	mov    $0x803918,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801cfc:	eb 13                	jmp    801d11 <dev_lookup+0x23>
  801cfe:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801d01:	39 08                	cmp    %ecx,(%eax)
  801d03:	75 0c                	jne    801d11 <dev_lookup+0x23>
			*dev = devtab[i];
  801d05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d08:	89 01                	mov    %eax,(%ecx)
			return 0;
  801d0a:	b8 00 00 00 00       	mov    $0x0,%eax
  801d0f:	eb 2e                	jmp    801d3f <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801d11:	8b 02                	mov    (%edx),%eax
  801d13:	85 c0                	test   %eax,%eax
  801d15:	75 e7                	jne    801cfe <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801d17:	a1 24 54 80 00       	mov    0x805424,%eax
  801d1c:	8b 40 48             	mov    0x48(%eax),%eax
  801d1f:	83 ec 04             	sub    $0x4,%esp
  801d22:	51                   	push   %ecx
  801d23:	50                   	push   %eax
  801d24:	68 9c 38 80 00       	push   $0x80389c
  801d29:	e8 83 ed ff ff       	call   800ab1 <cprintf>
	*dev = 0;
  801d2e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d31:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801d37:	83 c4 10             	add    $0x10,%esp
  801d3a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801d3f:	c9                   	leave  
  801d40:	c3                   	ret    

00801d41 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801d41:	55                   	push   %ebp
  801d42:	89 e5                	mov    %esp,%ebp
  801d44:	56                   	push   %esi
  801d45:	53                   	push   %ebx
  801d46:	83 ec 10             	sub    $0x10,%esp
  801d49:	8b 75 08             	mov    0x8(%ebp),%esi
  801d4c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801d4f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d52:	50                   	push   %eax
  801d53:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801d59:	c1 e8 0c             	shr    $0xc,%eax
  801d5c:	50                   	push   %eax
  801d5d:	e8 36 ff ff ff       	call   801c98 <fd_lookup>
  801d62:	83 c4 08             	add    $0x8,%esp
  801d65:	85 c0                	test   %eax,%eax
  801d67:	78 05                	js     801d6e <fd_close+0x2d>
	    || fd != fd2)
  801d69:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801d6c:	74 0c                	je     801d7a <fd_close+0x39>
		return (must_exist ? r : 0);
  801d6e:	84 db                	test   %bl,%bl
  801d70:	ba 00 00 00 00       	mov    $0x0,%edx
  801d75:	0f 44 c2             	cmove  %edx,%eax
  801d78:	eb 41                	jmp    801dbb <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801d7a:	83 ec 08             	sub    $0x8,%esp
  801d7d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d80:	50                   	push   %eax
  801d81:	ff 36                	pushl  (%esi)
  801d83:	e8 66 ff ff ff       	call   801cee <dev_lookup>
  801d88:	89 c3                	mov    %eax,%ebx
  801d8a:	83 c4 10             	add    $0x10,%esp
  801d8d:	85 c0                	test   %eax,%eax
  801d8f:	78 1a                	js     801dab <fd_close+0x6a>
		if (dev->dev_close)
  801d91:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d94:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801d97:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801d9c:	85 c0                	test   %eax,%eax
  801d9e:	74 0b                	je     801dab <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801da0:	83 ec 0c             	sub    $0xc,%esp
  801da3:	56                   	push   %esi
  801da4:	ff d0                	call   *%eax
  801da6:	89 c3                	mov    %eax,%ebx
  801da8:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801dab:	83 ec 08             	sub    $0x8,%esp
  801dae:	56                   	push   %esi
  801daf:	6a 00                	push   $0x0
  801db1:	e8 a2 f8 ff ff       	call   801658 <sys_page_unmap>
	return r;
  801db6:	83 c4 10             	add    $0x10,%esp
  801db9:	89 d8                	mov    %ebx,%eax
}
  801dbb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dbe:	5b                   	pop    %ebx
  801dbf:	5e                   	pop    %esi
  801dc0:	5d                   	pop    %ebp
  801dc1:	c3                   	ret    

00801dc2 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801dc2:	55                   	push   %ebp
  801dc3:	89 e5                	mov    %esp,%ebp
  801dc5:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801dc8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dcb:	50                   	push   %eax
  801dcc:	ff 75 08             	pushl  0x8(%ebp)
  801dcf:	e8 c4 fe ff ff       	call   801c98 <fd_lookup>
  801dd4:	83 c4 08             	add    $0x8,%esp
  801dd7:	85 c0                	test   %eax,%eax
  801dd9:	78 10                	js     801deb <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801ddb:	83 ec 08             	sub    $0x8,%esp
  801dde:	6a 01                	push   $0x1
  801de0:	ff 75 f4             	pushl  -0xc(%ebp)
  801de3:	e8 59 ff ff ff       	call   801d41 <fd_close>
  801de8:	83 c4 10             	add    $0x10,%esp
}
  801deb:	c9                   	leave  
  801dec:	c3                   	ret    

00801ded <close_all>:

void
close_all(void)
{
  801ded:	55                   	push   %ebp
  801dee:	89 e5                	mov    %esp,%ebp
  801df0:	53                   	push   %ebx
  801df1:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801df4:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801df9:	83 ec 0c             	sub    $0xc,%esp
  801dfc:	53                   	push   %ebx
  801dfd:	e8 c0 ff ff ff       	call   801dc2 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801e02:	83 c3 01             	add    $0x1,%ebx
  801e05:	83 c4 10             	add    $0x10,%esp
  801e08:	83 fb 20             	cmp    $0x20,%ebx
  801e0b:	75 ec                	jne    801df9 <close_all+0xc>
		close(i);
}
  801e0d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e10:	c9                   	leave  
  801e11:	c3                   	ret    

00801e12 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801e12:	55                   	push   %ebp
  801e13:	89 e5                	mov    %esp,%ebp
  801e15:	57                   	push   %edi
  801e16:	56                   	push   %esi
  801e17:	53                   	push   %ebx
  801e18:	83 ec 2c             	sub    $0x2c,%esp
  801e1b:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801e1e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801e21:	50                   	push   %eax
  801e22:	ff 75 08             	pushl  0x8(%ebp)
  801e25:	e8 6e fe ff ff       	call   801c98 <fd_lookup>
  801e2a:	83 c4 08             	add    $0x8,%esp
  801e2d:	85 c0                	test   %eax,%eax
  801e2f:	0f 88 c1 00 00 00    	js     801ef6 <dup+0xe4>
		return r;
	close(newfdnum);
  801e35:	83 ec 0c             	sub    $0xc,%esp
  801e38:	56                   	push   %esi
  801e39:	e8 84 ff ff ff       	call   801dc2 <close>

	newfd = INDEX2FD(newfdnum);
  801e3e:	89 f3                	mov    %esi,%ebx
  801e40:	c1 e3 0c             	shl    $0xc,%ebx
  801e43:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801e49:	83 c4 04             	add    $0x4,%esp
  801e4c:	ff 75 e4             	pushl  -0x1c(%ebp)
  801e4f:	e8 de fd ff ff       	call   801c32 <fd2data>
  801e54:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801e56:	89 1c 24             	mov    %ebx,(%esp)
  801e59:	e8 d4 fd ff ff       	call   801c32 <fd2data>
  801e5e:	83 c4 10             	add    $0x10,%esp
  801e61:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801e64:	89 f8                	mov    %edi,%eax
  801e66:	c1 e8 16             	shr    $0x16,%eax
  801e69:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801e70:	a8 01                	test   $0x1,%al
  801e72:	74 37                	je     801eab <dup+0x99>
  801e74:	89 f8                	mov    %edi,%eax
  801e76:	c1 e8 0c             	shr    $0xc,%eax
  801e79:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801e80:	f6 c2 01             	test   $0x1,%dl
  801e83:	74 26                	je     801eab <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801e85:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801e8c:	83 ec 0c             	sub    $0xc,%esp
  801e8f:	25 07 0e 00 00       	and    $0xe07,%eax
  801e94:	50                   	push   %eax
  801e95:	ff 75 d4             	pushl  -0x2c(%ebp)
  801e98:	6a 00                	push   $0x0
  801e9a:	57                   	push   %edi
  801e9b:	6a 00                	push   $0x0
  801e9d:	e8 74 f7 ff ff       	call   801616 <sys_page_map>
  801ea2:	89 c7                	mov    %eax,%edi
  801ea4:	83 c4 20             	add    $0x20,%esp
  801ea7:	85 c0                	test   %eax,%eax
  801ea9:	78 2e                	js     801ed9 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801eab:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801eae:	89 d0                	mov    %edx,%eax
  801eb0:	c1 e8 0c             	shr    $0xc,%eax
  801eb3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801eba:	83 ec 0c             	sub    $0xc,%esp
  801ebd:	25 07 0e 00 00       	and    $0xe07,%eax
  801ec2:	50                   	push   %eax
  801ec3:	53                   	push   %ebx
  801ec4:	6a 00                	push   $0x0
  801ec6:	52                   	push   %edx
  801ec7:	6a 00                	push   $0x0
  801ec9:	e8 48 f7 ff ff       	call   801616 <sys_page_map>
  801ece:	89 c7                	mov    %eax,%edi
  801ed0:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801ed3:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801ed5:	85 ff                	test   %edi,%edi
  801ed7:	79 1d                	jns    801ef6 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801ed9:	83 ec 08             	sub    $0x8,%esp
  801edc:	53                   	push   %ebx
  801edd:	6a 00                	push   $0x0
  801edf:	e8 74 f7 ff ff       	call   801658 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801ee4:	83 c4 08             	add    $0x8,%esp
  801ee7:	ff 75 d4             	pushl  -0x2c(%ebp)
  801eea:	6a 00                	push   $0x0
  801eec:	e8 67 f7 ff ff       	call   801658 <sys_page_unmap>
	return r;
  801ef1:	83 c4 10             	add    $0x10,%esp
  801ef4:	89 f8                	mov    %edi,%eax
}
  801ef6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ef9:	5b                   	pop    %ebx
  801efa:	5e                   	pop    %esi
  801efb:	5f                   	pop    %edi
  801efc:	5d                   	pop    %ebp
  801efd:	c3                   	ret    

00801efe <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801efe:	55                   	push   %ebp
  801eff:	89 e5                	mov    %esp,%ebp
  801f01:	53                   	push   %ebx
  801f02:	83 ec 14             	sub    $0x14,%esp
  801f05:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801f08:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f0b:	50                   	push   %eax
  801f0c:	53                   	push   %ebx
  801f0d:	e8 86 fd ff ff       	call   801c98 <fd_lookup>
  801f12:	83 c4 08             	add    $0x8,%esp
  801f15:	89 c2                	mov    %eax,%edx
  801f17:	85 c0                	test   %eax,%eax
  801f19:	78 6d                	js     801f88 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801f1b:	83 ec 08             	sub    $0x8,%esp
  801f1e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f21:	50                   	push   %eax
  801f22:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f25:	ff 30                	pushl  (%eax)
  801f27:	e8 c2 fd ff ff       	call   801cee <dev_lookup>
  801f2c:	83 c4 10             	add    $0x10,%esp
  801f2f:	85 c0                	test   %eax,%eax
  801f31:	78 4c                	js     801f7f <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801f33:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801f36:	8b 42 08             	mov    0x8(%edx),%eax
  801f39:	83 e0 03             	and    $0x3,%eax
  801f3c:	83 f8 01             	cmp    $0x1,%eax
  801f3f:	75 21                	jne    801f62 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801f41:	a1 24 54 80 00       	mov    0x805424,%eax
  801f46:	8b 40 48             	mov    0x48(%eax),%eax
  801f49:	83 ec 04             	sub    $0x4,%esp
  801f4c:	53                   	push   %ebx
  801f4d:	50                   	push   %eax
  801f4e:	68 dd 38 80 00       	push   $0x8038dd
  801f53:	e8 59 eb ff ff       	call   800ab1 <cprintf>
		return -E_INVAL;
  801f58:	83 c4 10             	add    $0x10,%esp
  801f5b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801f60:	eb 26                	jmp    801f88 <read+0x8a>
	}
	if (!dev->dev_read)
  801f62:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f65:	8b 40 08             	mov    0x8(%eax),%eax
  801f68:	85 c0                	test   %eax,%eax
  801f6a:	74 17                	je     801f83 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801f6c:	83 ec 04             	sub    $0x4,%esp
  801f6f:	ff 75 10             	pushl  0x10(%ebp)
  801f72:	ff 75 0c             	pushl  0xc(%ebp)
  801f75:	52                   	push   %edx
  801f76:	ff d0                	call   *%eax
  801f78:	89 c2                	mov    %eax,%edx
  801f7a:	83 c4 10             	add    $0x10,%esp
  801f7d:	eb 09                	jmp    801f88 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801f7f:	89 c2                	mov    %eax,%edx
  801f81:	eb 05                	jmp    801f88 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801f83:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801f88:	89 d0                	mov    %edx,%eax
  801f8a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f8d:	c9                   	leave  
  801f8e:	c3                   	ret    

00801f8f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801f8f:	55                   	push   %ebp
  801f90:	89 e5                	mov    %esp,%ebp
  801f92:	57                   	push   %edi
  801f93:	56                   	push   %esi
  801f94:	53                   	push   %ebx
  801f95:	83 ec 0c             	sub    $0xc,%esp
  801f98:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f9b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801f9e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801fa3:	eb 21                	jmp    801fc6 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801fa5:	83 ec 04             	sub    $0x4,%esp
  801fa8:	89 f0                	mov    %esi,%eax
  801faa:	29 d8                	sub    %ebx,%eax
  801fac:	50                   	push   %eax
  801fad:	89 d8                	mov    %ebx,%eax
  801faf:	03 45 0c             	add    0xc(%ebp),%eax
  801fb2:	50                   	push   %eax
  801fb3:	57                   	push   %edi
  801fb4:	e8 45 ff ff ff       	call   801efe <read>
		if (m < 0)
  801fb9:	83 c4 10             	add    $0x10,%esp
  801fbc:	85 c0                	test   %eax,%eax
  801fbe:	78 10                	js     801fd0 <readn+0x41>
			return m;
		if (m == 0)
  801fc0:	85 c0                	test   %eax,%eax
  801fc2:	74 0a                	je     801fce <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801fc4:	01 c3                	add    %eax,%ebx
  801fc6:	39 f3                	cmp    %esi,%ebx
  801fc8:	72 db                	jb     801fa5 <readn+0x16>
  801fca:	89 d8                	mov    %ebx,%eax
  801fcc:	eb 02                	jmp    801fd0 <readn+0x41>
  801fce:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801fd0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fd3:	5b                   	pop    %ebx
  801fd4:	5e                   	pop    %esi
  801fd5:	5f                   	pop    %edi
  801fd6:	5d                   	pop    %ebp
  801fd7:	c3                   	ret    

00801fd8 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801fd8:	55                   	push   %ebp
  801fd9:	89 e5                	mov    %esp,%ebp
  801fdb:	53                   	push   %ebx
  801fdc:	83 ec 14             	sub    $0x14,%esp
  801fdf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801fe2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801fe5:	50                   	push   %eax
  801fe6:	53                   	push   %ebx
  801fe7:	e8 ac fc ff ff       	call   801c98 <fd_lookup>
  801fec:	83 c4 08             	add    $0x8,%esp
  801fef:	89 c2                	mov    %eax,%edx
  801ff1:	85 c0                	test   %eax,%eax
  801ff3:	78 68                	js     80205d <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801ff5:	83 ec 08             	sub    $0x8,%esp
  801ff8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ffb:	50                   	push   %eax
  801ffc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fff:	ff 30                	pushl  (%eax)
  802001:	e8 e8 fc ff ff       	call   801cee <dev_lookup>
  802006:	83 c4 10             	add    $0x10,%esp
  802009:	85 c0                	test   %eax,%eax
  80200b:	78 47                	js     802054 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80200d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802010:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802014:	75 21                	jne    802037 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  802016:	a1 24 54 80 00       	mov    0x805424,%eax
  80201b:	8b 40 48             	mov    0x48(%eax),%eax
  80201e:	83 ec 04             	sub    $0x4,%esp
  802021:	53                   	push   %ebx
  802022:	50                   	push   %eax
  802023:	68 f9 38 80 00       	push   $0x8038f9
  802028:	e8 84 ea ff ff       	call   800ab1 <cprintf>
		return -E_INVAL;
  80202d:	83 c4 10             	add    $0x10,%esp
  802030:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802035:	eb 26                	jmp    80205d <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  802037:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80203a:	8b 52 0c             	mov    0xc(%edx),%edx
  80203d:	85 d2                	test   %edx,%edx
  80203f:	74 17                	je     802058 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  802041:	83 ec 04             	sub    $0x4,%esp
  802044:	ff 75 10             	pushl  0x10(%ebp)
  802047:	ff 75 0c             	pushl  0xc(%ebp)
  80204a:	50                   	push   %eax
  80204b:	ff d2                	call   *%edx
  80204d:	89 c2                	mov    %eax,%edx
  80204f:	83 c4 10             	add    $0x10,%esp
  802052:	eb 09                	jmp    80205d <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802054:	89 c2                	mov    %eax,%edx
  802056:	eb 05                	jmp    80205d <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  802058:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80205d:	89 d0                	mov    %edx,%eax
  80205f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802062:	c9                   	leave  
  802063:	c3                   	ret    

00802064 <seek>:

int
seek(int fdnum, off_t offset)
{
  802064:	55                   	push   %ebp
  802065:	89 e5                	mov    %esp,%ebp
  802067:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80206a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80206d:	50                   	push   %eax
  80206e:	ff 75 08             	pushl  0x8(%ebp)
  802071:	e8 22 fc ff ff       	call   801c98 <fd_lookup>
  802076:	83 c4 08             	add    $0x8,%esp
  802079:	85 c0                	test   %eax,%eax
  80207b:	78 0e                	js     80208b <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80207d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  802080:	8b 55 0c             	mov    0xc(%ebp),%edx
  802083:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  802086:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80208b:	c9                   	leave  
  80208c:	c3                   	ret    

0080208d <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80208d:	55                   	push   %ebp
  80208e:	89 e5                	mov    %esp,%ebp
  802090:	53                   	push   %ebx
  802091:	83 ec 14             	sub    $0x14,%esp
  802094:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  802097:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80209a:	50                   	push   %eax
  80209b:	53                   	push   %ebx
  80209c:	e8 f7 fb ff ff       	call   801c98 <fd_lookup>
  8020a1:	83 c4 08             	add    $0x8,%esp
  8020a4:	89 c2                	mov    %eax,%edx
  8020a6:	85 c0                	test   %eax,%eax
  8020a8:	78 65                	js     80210f <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8020aa:	83 ec 08             	sub    $0x8,%esp
  8020ad:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020b0:	50                   	push   %eax
  8020b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020b4:	ff 30                	pushl  (%eax)
  8020b6:	e8 33 fc ff ff       	call   801cee <dev_lookup>
  8020bb:	83 c4 10             	add    $0x10,%esp
  8020be:	85 c0                	test   %eax,%eax
  8020c0:	78 44                	js     802106 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8020c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020c5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8020c9:	75 21                	jne    8020ec <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8020cb:	a1 24 54 80 00       	mov    0x805424,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8020d0:	8b 40 48             	mov    0x48(%eax),%eax
  8020d3:	83 ec 04             	sub    $0x4,%esp
  8020d6:	53                   	push   %ebx
  8020d7:	50                   	push   %eax
  8020d8:	68 bc 38 80 00       	push   $0x8038bc
  8020dd:	e8 cf e9 ff ff       	call   800ab1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8020e2:	83 c4 10             	add    $0x10,%esp
  8020e5:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8020ea:	eb 23                	jmp    80210f <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8020ec:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8020ef:	8b 52 18             	mov    0x18(%edx),%edx
  8020f2:	85 d2                	test   %edx,%edx
  8020f4:	74 14                	je     80210a <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8020f6:	83 ec 08             	sub    $0x8,%esp
  8020f9:	ff 75 0c             	pushl  0xc(%ebp)
  8020fc:	50                   	push   %eax
  8020fd:	ff d2                	call   *%edx
  8020ff:	89 c2                	mov    %eax,%edx
  802101:	83 c4 10             	add    $0x10,%esp
  802104:	eb 09                	jmp    80210f <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802106:	89 c2                	mov    %eax,%edx
  802108:	eb 05                	jmp    80210f <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80210a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80210f:	89 d0                	mov    %edx,%eax
  802111:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802114:	c9                   	leave  
  802115:	c3                   	ret    

00802116 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  802116:	55                   	push   %ebp
  802117:	89 e5                	mov    %esp,%ebp
  802119:	53                   	push   %ebx
  80211a:	83 ec 14             	sub    $0x14,%esp
  80211d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802120:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802123:	50                   	push   %eax
  802124:	ff 75 08             	pushl  0x8(%ebp)
  802127:	e8 6c fb ff ff       	call   801c98 <fd_lookup>
  80212c:	83 c4 08             	add    $0x8,%esp
  80212f:	89 c2                	mov    %eax,%edx
  802131:	85 c0                	test   %eax,%eax
  802133:	78 58                	js     80218d <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802135:	83 ec 08             	sub    $0x8,%esp
  802138:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80213b:	50                   	push   %eax
  80213c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80213f:	ff 30                	pushl  (%eax)
  802141:	e8 a8 fb ff ff       	call   801cee <dev_lookup>
  802146:	83 c4 10             	add    $0x10,%esp
  802149:	85 c0                	test   %eax,%eax
  80214b:	78 37                	js     802184 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80214d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802150:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  802154:	74 32                	je     802188 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  802156:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  802159:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  802160:	00 00 00 
	stat->st_isdir = 0;
  802163:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80216a:	00 00 00 
	stat->st_dev = dev;
  80216d:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  802173:	83 ec 08             	sub    $0x8,%esp
  802176:	53                   	push   %ebx
  802177:	ff 75 f0             	pushl  -0x10(%ebp)
  80217a:	ff 50 14             	call   *0x14(%eax)
  80217d:	89 c2                	mov    %eax,%edx
  80217f:	83 c4 10             	add    $0x10,%esp
  802182:	eb 09                	jmp    80218d <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802184:	89 c2                	mov    %eax,%edx
  802186:	eb 05                	jmp    80218d <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  802188:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80218d:	89 d0                	mov    %edx,%eax
  80218f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802192:	c9                   	leave  
  802193:	c3                   	ret    

00802194 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  802194:	55                   	push   %ebp
  802195:	89 e5                	mov    %esp,%ebp
  802197:	56                   	push   %esi
  802198:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  802199:	83 ec 08             	sub    $0x8,%esp
  80219c:	6a 00                	push   $0x0
  80219e:	ff 75 08             	pushl  0x8(%ebp)
  8021a1:	e8 b7 01 00 00       	call   80235d <open>
  8021a6:	89 c3                	mov    %eax,%ebx
  8021a8:	83 c4 10             	add    $0x10,%esp
  8021ab:	85 c0                	test   %eax,%eax
  8021ad:	78 1b                	js     8021ca <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8021af:	83 ec 08             	sub    $0x8,%esp
  8021b2:	ff 75 0c             	pushl  0xc(%ebp)
  8021b5:	50                   	push   %eax
  8021b6:	e8 5b ff ff ff       	call   802116 <fstat>
  8021bb:	89 c6                	mov    %eax,%esi
	close(fd);
  8021bd:	89 1c 24             	mov    %ebx,(%esp)
  8021c0:	e8 fd fb ff ff       	call   801dc2 <close>
	return r;
  8021c5:	83 c4 10             	add    $0x10,%esp
  8021c8:	89 f0                	mov    %esi,%eax
}
  8021ca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021cd:	5b                   	pop    %ebx
  8021ce:	5e                   	pop    %esi
  8021cf:	5d                   	pop    %ebp
  8021d0:	c3                   	ret    

008021d1 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8021d1:	55                   	push   %ebp
  8021d2:	89 e5                	mov    %esp,%ebp
  8021d4:	56                   	push   %esi
  8021d5:	53                   	push   %ebx
  8021d6:	89 c6                	mov    %eax,%esi
  8021d8:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8021da:	83 3d 20 54 80 00 00 	cmpl   $0x0,0x805420
  8021e1:	75 12                	jne    8021f5 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8021e3:	83 ec 0c             	sub    $0xc,%esp
  8021e6:	6a 01                	push   $0x1
  8021e8:	e8 48 0d 00 00       	call   802f35 <ipc_find_env>
  8021ed:	a3 20 54 80 00       	mov    %eax,0x805420
  8021f2:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8021f5:	6a 07                	push   $0x7
  8021f7:	68 00 60 80 00       	push   $0x806000
  8021fc:	56                   	push   %esi
  8021fd:	ff 35 20 54 80 00    	pushl  0x805420
  802203:	e8 d9 0c 00 00       	call   802ee1 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  802208:	83 c4 0c             	add    $0xc,%esp
  80220b:	6a 00                	push   $0x0
  80220d:	53                   	push   %ebx
  80220e:	6a 00                	push   $0x0
  802210:	e8 57 0c 00 00       	call   802e6c <ipc_recv>
}
  802215:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802218:	5b                   	pop    %ebx
  802219:	5e                   	pop    %esi
  80221a:	5d                   	pop    %ebp
  80221b:	c3                   	ret    

0080221c <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80221c:	55                   	push   %ebp
  80221d:	89 e5                	mov    %esp,%ebp
  80221f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  802222:	8b 45 08             	mov    0x8(%ebp),%eax
  802225:	8b 40 0c             	mov    0xc(%eax),%eax
  802228:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  80222d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802230:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  802235:	ba 00 00 00 00       	mov    $0x0,%edx
  80223a:	b8 02 00 00 00       	mov    $0x2,%eax
  80223f:	e8 8d ff ff ff       	call   8021d1 <fsipc>
}
  802244:	c9                   	leave  
  802245:	c3                   	ret    

00802246 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  802246:	55                   	push   %ebp
  802247:	89 e5                	mov    %esp,%ebp
  802249:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80224c:	8b 45 08             	mov    0x8(%ebp),%eax
  80224f:	8b 40 0c             	mov    0xc(%eax),%eax
  802252:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  802257:	ba 00 00 00 00       	mov    $0x0,%edx
  80225c:	b8 06 00 00 00       	mov    $0x6,%eax
  802261:	e8 6b ff ff ff       	call   8021d1 <fsipc>
}
  802266:	c9                   	leave  
  802267:	c3                   	ret    

00802268 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  802268:	55                   	push   %ebp
  802269:	89 e5                	mov    %esp,%ebp
  80226b:	53                   	push   %ebx
  80226c:	83 ec 04             	sub    $0x4,%esp
  80226f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  802272:	8b 45 08             	mov    0x8(%ebp),%eax
  802275:	8b 40 0c             	mov    0xc(%eax),%eax
  802278:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80227d:	ba 00 00 00 00       	mov    $0x0,%edx
  802282:	b8 05 00 00 00       	mov    $0x5,%eax
  802287:	e8 45 ff ff ff       	call   8021d1 <fsipc>
  80228c:	85 c0                	test   %eax,%eax
  80228e:	78 2c                	js     8022bc <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  802290:	83 ec 08             	sub    $0x8,%esp
  802293:	68 00 60 80 00       	push   $0x806000
  802298:	53                   	push   %ebx
  802299:	e8 32 ef ff ff       	call   8011d0 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80229e:	a1 80 60 80 00       	mov    0x806080,%eax
  8022a3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8022a9:	a1 84 60 80 00       	mov    0x806084,%eax
  8022ae:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8022b4:	83 c4 10             	add    $0x10,%esp
  8022b7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8022bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8022bf:	c9                   	leave  
  8022c0:	c3                   	ret    

008022c1 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8022c1:	55                   	push   %ebp
  8022c2:	89 e5                	mov    %esp,%ebp
  8022c4:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  8022c7:	68 28 39 80 00       	push   $0x803928
  8022cc:	68 90 00 00 00       	push   $0x90
  8022d1:	68 46 39 80 00       	push   $0x803946
  8022d6:	e8 fd e6 ff ff       	call   8009d8 <_panic>

008022db <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8022db:	55                   	push   %ebp
  8022dc:	89 e5                	mov    %esp,%ebp
  8022de:	56                   	push   %esi
  8022df:	53                   	push   %ebx
  8022e0:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8022e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8022e6:	8b 40 0c             	mov    0xc(%eax),%eax
  8022e9:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  8022ee:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8022f4:	ba 00 00 00 00       	mov    $0x0,%edx
  8022f9:	b8 03 00 00 00       	mov    $0x3,%eax
  8022fe:	e8 ce fe ff ff       	call   8021d1 <fsipc>
  802303:	89 c3                	mov    %eax,%ebx
  802305:	85 c0                	test   %eax,%eax
  802307:	78 4b                	js     802354 <devfile_read+0x79>
		return r;
	assert(r <= n);
  802309:	39 c6                	cmp    %eax,%esi
  80230b:	73 16                	jae    802323 <devfile_read+0x48>
  80230d:	68 51 39 80 00       	push   $0x803951
  802312:	68 98 33 80 00       	push   $0x803398
  802317:	6a 7c                	push   $0x7c
  802319:	68 46 39 80 00       	push   $0x803946
  80231e:	e8 b5 e6 ff ff       	call   8009d8 <_panic>
	assert(r <= PGSIZE);
  802323:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802328:	7e 16                	jle    802340 <devfile_read+0x65>
  80232a:	68 58 39 80 00       	push   $0x803958
  80232f:	68 98 33 80 00       	push   $0x803398
  802334:	6a 7d                	push   $0x7d
  802336:	68 46 39 80 00       	push   $0x803946
  80233b:	e8 98 e6 ff ff       	call   8009d8 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  802340:	83 ec 04             	sub    $0x4,%esp
  802343:	50                   	push   %eax
  802344:	68 00 60 80 00       	push   $0x806000
  802349:	ff 75 0c             	pushl  0xc(%ebp)
  80234c:	e8 11 f0 ff ff       	call   801362 <memmove>
	return r;
  802351:	83 c4 10             	add    $0x10,%esp
}
  802354:	89 d8                	mov    %ebx,%eax
  802356:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802359:	5b                   	pop    %ebx
  80235a:	5e                   	pop    %esi
  80235b:	5d                   	pop    %ebp
  80235c:	c3                   	ret    

0080235d <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80235d:	55                   	push   %ebp
  80235e:	89 e5                	mov    %esp,%ebp
  802360:	53                   	push   %ebx
  802361:	83 ec 20             	sub    $0x20,%esp
  802364:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  802367:	53                   	push   %ebx
  802368:	e8 2a ee ff ff       	call   801197 <strlen>
  80236d:	83 c4 10             	add    $0x10,%esp
  802370:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  802375:	7f 67                	jg     8023de <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  802377:	83 ec 0c             	sub    $0xc,%esp
  80237a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80237d:	50                   	push   %eax
  80237e:	e8 c6 f8 ff ff       	call   801c49 <fd_alloc>
  802383:	83 c4 10             	add    $0x10,%esp
		return r;
  802386:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  802388:	85 c0                	test   %eax,%eax
  80238a:	78 57                	js     8023e3 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80238c:	83 ec 08             	sub    $0x8,%esp
  80238f:	53                   	push   %ebx
  802390:	68 00 60 80 00       	push   $0x806000
  802395:	e8 36 ee ff ff       	call   8011d0 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80239a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80239d:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8023a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8023a5:	b8 01 00 00 00       	mov    $0x1,%eax
  8023aa:	e8 22 fe ff ff       	call   8021d1 <fsipc>
  8023af:	89 c3                	mov    %eax,%ebx
  8023b1:	83 c4 10             	add    $0x10,%esp
  8023b4:	85 c0                	test   %eax,%eax
  8023b6:	79 14                	jns    8023cc <open+0x6f>
		fd_close(fd, 0);
  8023b8:	83 ec 08             	sub    $0x8,%esp
  8023bb:	6a 00                	push   $0x0
  8023bd:	ff 75 f4             	pushl  -0xc(%ebp)
  8023c0:	e8 7c f9 ff ff       	call   801d41 <fd_close>
		return r;
  8023c5:	83 c4 10             	add    $0x10,%esp
  8023c8:	89 da                	mov    %ebx,%edx
  8023ca:	eb 17                	jmp    8023e3 <open+0x86>
	}

	return fd2num(fd);
  8023cc:	83 ec 0c             	sub    $0xc,%esp
  8023cf:	ff 75 f4             	pushl  -0xc(%ebp)
  8023d2:	e8 4b f8 ff ff       	call   801c22 <fd2num>
  8023d7:	89 c2                	mov    %eax,%edx
  8023d9:	83 c4 10             	add    $0x10,%esp
  8023dc:	eb 05                	jmp    8023e3 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8023de:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8023e3:	89 d0                	mov    %edx,%eax
  8023e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8023e8:	c9                   	leave  
  8023e9:	c3                   	ret    

008023ea <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8023ea:	55                   	push   %ebp
  8023eb:	89 e5                	mov    %esp,%ebp
  8023ed:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8023f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8023f5:	b8 08 00 00 00       	mov    $0x8,%eax
  8023fa:	e8 d2 fd ff ff       	call   8021d1 <fsipc>
}
  8023ff:	c9                   	leave  
  802400:	c3                   	ret    

00802401 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  802401:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  802405:	7e 37                	jle    80243e <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  802407:	55                   	push   %ebp
  802408:	89 e5                	mov    %esp,%ebp
  80240a:	53                   	push   %ebx
  80240b:	83 ec 08             	sub    $0x8,%esp
  80240e:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  802410:	ff 70 04             	pushl  0x4(%eax)
  802413:	8d 40 10             	lea    0x10(%eax),%eax
  802416:	50                   	push   %eax
  802417:	ff 33                	pushl  (%ebx)
  802419:	e8 ba fb ff ff       	call   801fd8 <write>
		if (result > 0)
  80241e:	83 c4 10             	add    $0x10,%esp
  802421:	85 c0                	test   %eax,%eax
  802423:	7e 03                	jle    802428 <writebuf+0x27>
			b->result += result;
  802425:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  802428:	3b 43 04             	cmp    0x4(%ebx),%eax
  80242b:	74 0d                	je     80243a <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  80242d:	85 c0                	test   %eax,%eax
  80242f:	ba 00 00 00 00       	mov    $0x0,%edx
  802434:	0f 4f c2             	cmovg  %edx,%eax
  802437:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  80243a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80243d:	c9                   	leave  
  80243e:	f3 c3                	repz ret 

00802440 <putch>:

static void
putch(int ch, void *thunk)
{
  802440:	55                   	push   %ebp
  802441:	89 e5                	mov    %esp,%ebp
  802443:	53                   	push   %ebx
  802444:	83 ec 04             	sub    $0x4,%esp
  802447:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  80244a:	8b 53 04             	mov    0x4(%ebx),%edx
  80244d:	8d 42 01             	lea    0x1(%edx),%eax
  802450:	89 43 04             	mov    %eax,0x4(%ebx)
  802453:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802456:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  80245a:	3d 00 01 00 00       	cmp    $0x100,%eax
  80245f:	75 0e                	jne    80246f <putch+0x2f>
		writebuf(b);
  802461:	89 d8                	mov    %ebx,%eax
  802463:	e8 99 ff ff ff       	call   802401 <writebuf>
		b->idx = 0;
  802468:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  80246f:	83 c4 04             	add    $0x4,%esp
  802472:	5b                   	pop    %ebx
  802473:	5d                   	pop    %ebp
  802474:	c3                   	ret    

00802475 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  802475:	55                   	push   %ebp
  802476:	89 e5                	mov    %esp,%ebp
  802478:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  80247e:	8b 45 08             	mov    0x8(%ebp),%eax
  802481:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  802487:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  80248e:	00 00 00 
	b.result = 0;
  802491:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  802498:	00 00 00 
	b.error = 1;
  80249b:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8024a2:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8024a5:	ff 75 10             	pushl  0x10(%ebp)
  8024a8:	ff 75 0c             	pushl  0xc(%ebp)
  8024ab:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8024b1:	50                   	push   %eax
  8024b2:	68 40 24 80 00       	push   $0x802440
  8024b7:	e8 f2 e6 ff ff       	call   800bae <vprintfmt>
	if (b.idx > 0)
  8024bc:	83 c4 10             	add    $0x10,%esp
  8024bf:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  8024c6:	7e 0b                	jle    8024d3 <vfprintf+0x5e>
		writebuf(&b);
  8024c8:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8024ce:	e8 2e ff ff ff       	call   802401 <writebuf>

	return (b.result ? b.result : b.error);
  8024d3:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8024d9:	85 c0                	test   %eax,%eax
  8024db:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  8024e2:	c9                   	leave  
  8024e3:	c3                   	ret    

008024e4 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  8024e4:	55                   	push   %ebp
  8024e5:	89 e5                	mov    %esp,%ebp
  8024e7:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8024ea:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  8024ed:	50                   	push   %eax
  8024ee:	ff 75 0c             	pushl  0xc(%ebp)
  8024f1:	ff 75 08             	pushl  0x8(%ebp)
  8024f4:	e8 7c ff ff ff       	call   802475 <vfprintf>
	va_end(ap);

	return cnt;
}
  8024f9:	c9                   	leave  
  8024fa:	c3                   	ret    

008024fb <printf>:

int
printf(const char *fmt, ...)
{
  8024fb:	55                   	push   %ebp
  8024fc:	89 e5                	mov    %esp,%ebp
  8024fe:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  802501:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  802504:	50                   	push   %eax
  802505:	ff 75 08             	pushl  0x8(%ebp)
  802508:	6a 01                	push   $0x1
  80250a:	e8 66 ff ff ff       	call   802475 <vfprintf>
	va_end(ap);

	return cnt;
}
  80250f:	c9                   	leave  
  802510:	c3                   	ret    

00802511 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  802511:	55                   	push   %ebp
  802512:	89 e5                	mov    %esp,%ebp
  802514:	57                   	push   %edi
  802515:	56                   	push   %esi
  802516:	53                   	push   %ebx
  802517:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  80251d:	6a 00                	push   $0x0
  80251f:	ff 75 08             	pushl  0x8(%ebp)
  802522:	e8 36 fe ff ff       	call   80235d <open>
  802527:	89 c7                	mov    %eax,%edi
  802529:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  80252f:	83 c4 10             	add    $0x10,%esp
  802532:	85 c0                	test   %eax,%eax
  802534:	0f 88 3a 04 00 00    	js     802974 <spawn+0x463>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  80253a:	83 ec 04             	sub    $0x4,%esp
  80253d:	68 00 02 00 00       	push   $0x200
  802542:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  802548:	50                   	push   %eax
  802549:	57                   	push   %edi
  80254a:	e8 40 fa ff ff       	call   801f8f <readn>
  80254f:	83 c4 10             	add    $0x10,%esp
  802552:	3d 00 02 00 00       	cmp    $0x200,%eax
  802557:	75 0c                	jne    802565 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  802559:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  802560:	45 4c 46 
  802563:	74 33                	je     802598 <spawn+0x87>
		close(fd);
  802565:	83 ec 0c             	sub    $0xc,%esp
  802568:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80256e:	e8 4f f8 ff ff       	call   801dc2 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  802573:	83 c4 0c             	add    $0xc,%esp
  802576:	68 7f 45 4c 46       	push   $0x464c457f
  80257b:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  802581:	68 64 39 80 00       	push   $0x803964
  802586:	e8 26 e5 ff ff       	call   800ab1 <cprintf>
		return -E_NOT_EXEC;
  80258b:	83 c4 10             	add    $0x10,%esp
  80258e:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  802593:	e9 3c 04 00 00       	jmp    8029d4 <spawn+0x4c3>
  802598:	b8 07 00 00 00       	mov    $0x7,%eax
  80259d:	cd 30                	int    $0x30
  80259f:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  8025a5:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  8025ab:	85 c0                	test   %eax,%eax
  8025ad:	0f 88 c9 03 00 00    	js     80297c <spawn+0x46b>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  8025b3:	89 c6                	mov    %eax,%esi
  8025b5:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  8025bb:	6b f6 7c             	imul   $0x7c,%esi,%esi
  8025be:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  8025c4:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  8025ca:	b9 11 00 00 00       	mov    $0x11,%ecx
  8025cf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  8025d1:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  8025d7:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8025dd:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  8025e2:	be 00 00 00 00       	mov    $0x0,%esi
  8025e7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8025ea:	eb 13                	jmp    8025ff <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  8025ec:	83 ec 0c             	sub    $0xc,%esp
  8025ef:	50                   	push   %eax
  8025f0:	e8 a2 eb ff ff       	call   801197 <strlen>
  8025f5:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8025f9:	83 c3 01             	add    $0x1,%ebx
  8025fc:	83 c4 10             	add    $0x10,%esp
  8025ff:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  802606:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  802609:	85 c0                	test   %eax,%eax
  80260b:	75 df                	jne    8025ec <spawn+0xdb>
  80260d:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  802613:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  802619:	bf 00 10 40 00       	mov    $0x401000,%edi
  80261e:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  802620:	89 fa                	mov    %edi,%edx
  802622:	83 e2 fc             	and    $0xfffffffc,%edx
  802625:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  80262c:	29 c2                	sub    %eax,%edx
  80262e:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  802634:	8d 42 f8             	lea    -0x8(%edx),%eax
  802637:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  80263c:	0f 86 4a 03 00 00    	jbe    80298c <spawn+0x47b>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802642:	83 ec 04             	sub    $0x4,%esp
  802645:	6a 07                	push   $0x7
  802647:	68 00 00 40 00       	push   $0x400000
  80264c:	6a 00                	push   $0x0
  80264e:	e8 80 ef ff ff       	call   8015d3 <sys_page_alloc>
  802653:	83 c4 10             	add    $0x10,%esp
  802656:	85 c0                	test   %eax,%eax
  802658:	0f 88 35 03 00 00    	js     802993 <spawn+0x482>
  80265e:	be 00 00 00 00       	mov    $0x0,%esi
  802663:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  802669:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80266c:	eb 30                	jmp    80269e <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  80266e:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  802674:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  80267a:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  80267d:	83 ec 08             	sub    $0x8,%esp
  802680:	ff 34 b3             	pushl  (%ebx,%esi,4)
  802683:	57                   	push   %edi
  802684:	e8 47 eb ff ff       	call   8011d0 <strcpy>
		string_store += strlen(argv[i]) + 1;
  802689:	83 c4 04             	add    $0x4,%esp
  80268c:	ff 34 b3             	pushl  (%ebx,%esi,4)
  80268f:	e8 03 eb ff ff       	call   801197 <strlen>
  802694:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  802698:	83 c6 01             	add    $0x1,%esi
  80269b:	83 c4 10             	add    $0x10,%esp
  80269e:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  8026a4:	7f c8                	jg     80266e <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  8026a6:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  8026ac:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  8026b2:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  8026b9:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  8026bf:	74 19                	je     8026da <spawn+0x1c9>
  8026c1:	68 d8 39 80 00       	push   $0x8039d8
  8026c6:	68 98 33 80 00       	push   $0x803398
  8026cb:	68 f2 00 00 00       	push   $0xf2
  8026d0:	68 7e 39 80 00       	push   $0x80397e
  8026d5:	e8 fe e2 ff ff       	call   8009d8 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  8026da:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  8026e0:	89 c8                	mov    %ecx,%eax
  8026e2:	2d 00 30 80 11       	sub    $0x11803000,%eax
  8026e7:	89 41 fc             	mov    %eax,-0x4(%ecx)
	argv_store[-2] = argc;
  8026ea:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  8026f0:	89 41 f8             	mov    %eax,-0x8(%ecx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  8026f3:	8d 81 f8 cf 7f ee    	lea    -0x11803008(%ecx),%eax
  8026f9:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  8026ff:	83 ec 0c             	sub    $0xc,%esp
  802702:	6a 07                	push   $0x7
  802704:	68 00 d0 bf ee       	push   $0xeebfd000
  802709:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  80270f:	68 00 00 40 00       	push   $0x400000
  802714:	6a 00                	push   $0x0
  802716:	e8 fb ee ff ff       	call   801616 <sys_page_map>
  80271b:	89 c3                	mov    %eax,%ebx
  80271d:	83 c4 20             	add    $0x20,%esp
  802720:	85 c0                	test   %eax,%eax
  802722:	0f 88 9a 02 00 00    	js     8029c2 <spawn+0x4b1>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  802728:	83 ec 08             	sub    $0x8,%esp
  80272b:	68 00 00 40 00       	push   $0x400000
  802730:	6a 00                	push   $0x0
  802732:	e8 21 ef ff ff       	call   801658 <sys_page_unmap>
  802737:	89 c3                	mov    %eax,%ebx
  802739:	83 c4 10             	add    $0x10,%esp
  80273c:	85 c0                	test   %eax,%eax
  80273e:	0f 88 7e 02 00 00    	js     8029c2 <spawn+0x4b1>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  802744:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  80274a:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  802751:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802757:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  80275e:	00 00 00 
  802761:	e9 86 01 00 00       	jmp    8028ec <spawn+0x3db>
		if (ph->p_type != ELF_PROG_LOAD)
  802766:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  80276c:	83 38 01             	cmpl   $0x1,(%eax)
  80276f:	0f 85 69 01 00 00    	jne    8028de <spawn+0x3cd>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  802775:	89 c1                	mov    %eax,%ecx
  802777:	8b 40 18             	mov    0x18(%eax),%eax
  80277a:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  802780:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  802783:	83 f8 01             	cmp    $0x1,%eax
  802786:	19 c0                	sbb    %eax,%eax
  802788:	83 e0 fe             	and    $0xfffffffe,%eax
  80278b:	83 c0 07             	add    $0x7,%eax
  80278e:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  802794:	89 c8                	mov    %ecx,%eax
  802796:	8b 49 04             	mov    0x4(%ecx),%ecx
  802799:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
  80279f:	8b 78 10             	mov    0x10(%eax),%edi
  8027a2:	8b 50 14             	mov    0x14(%eax),%edx
  8027a5:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  8027ab:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  8027ae:	89 f0                	mov    %esi,%eax
  8027b0:	25 ff 0f 00 00       	and    $0xfff,%eax
  8027b5:	74 14                	je     8027cb <spawn+0x2ba>
		va -= i;
  8027b7:	29 c6                	sub    %eax,%esi
		memsz += i;
  8027b9:	01 c2                	add    %eax,%edx
  8027bb:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  8027c1:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  8027c3:	29 c1                	sub    %eax,%ecx
  8027c5:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8027cb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8027d0:	e9 f7 00 00 00       	jmp    8028cc <spawn+0x3bb>
		if (i >= filesz) {
  8027d5:	39 df                	cmp    %ebx,%edi
  8027d7:	77 27                	ja     802800 <spawn+0x2ef>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  8027d9:	83 ec 04             	sub    $0x4,%esp
  8027dc:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  8027e2:	56                   	push   %esi
  8027e3:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  8027e9:	e8 e5 ed ff ff       	call   8015d3 <sys_page_alloc>
  8027ee:	83 c4 10             	add    $0x10,%esp
  8027f1:	85 c0                	test   %eax,%eax
  8027f3:	0f 89 c7 00 00 00    	jns    8028c0 <spawn+0x3af>
  8027f9:	89 c3                	mov    %eax,%ebx
  8027fb:	e9 a1 01 00 00       	jmp    8029a1 <spawn+0x490>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802800:	83 ec 04             	sub    $0x4,%esp
  802803:	6a 07                	push   $0x7
  802805:	68 00 00 40 00       	push   $0x400000
  80280a:	6a 00                	push   $0x0
  80280c:	e8 c2 ed ff ff       	call   8015d3 <sys_page_alloc>
  802811:	83 c4 10             	add    $0x10,%esp
  802814:	85 c0                	test   %eax,%eax
  802816:	0f 88 7b 01 00 00    	js     802997 <spawn+0x486>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  80281c:	83 ec 08             	sub    $0x8,%esp
  80281f:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  802825:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  80282b:	50                   	push   %eax
  80282c:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802832:	e8 2d f8 ff ff       	call   802064 <seek>
  802837:	83 c4 10             	add    $0x10,%esp
  80283a:	85 c0                	test   %eax,%eax
  80283c:	0f 88 59 01 00 00    	js     80299b <spawn+0x48a>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  802842:	83 ec 04             	sub    $0x4,%esp
  802845:	89 f8                	mov    %edi,%eax
  802847:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  80284d:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802852:	b9 00 10 00 00       	mov    $0x1000,%ecx
  802857:	0f 47 c1             	cmova  %ecx,%eax
  80285a:	50                   	push   %eax
  80285b:	68 00 00 40 00       	push   $0x400000
  802860:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802866:	e8 24 f7 ff ff       	call   801f8f <readn>
  80286b:	83 c4 10             	add    $0x10,%esp
  80286e:	85 c0                	test   %eax,%eax
  802870:	0f 88 29 01 00 00    	js     80299f <spawn+0x48e>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  802876:	83 ec 0c             	sub    $0xc,%esp
  802879:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  80287f:	56                   	push   %esi
  802880:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  802886:	68 00 00 40 00       	push   $0x400000
  80288b:	6a 00                	push   $0x0
  80288d:	e8 84 ed ff ff       	call   801616 <sys_page_map>
  802892:	83 c4 20             	add    $0x20,%esp
  802895:	85 c0                	test   %eax,%eax
  802897:	79 15                	jns    8028ae <spawn+0x39d>
				panic("spawn: sys_page_map data: %e", r);
  802899:	50                   	push   %eax
  80289a:	68 8a 39 80 00       	push   $0x80398a
  80289f:	68 25 01 00 00       	push   $0x125
  8028a4:	68 7e 39 80 00       	push   $0x80397e
  8028a9:	e8 2a e1 ff ff       	call   8009d8 <_panic>
			sys_page_unmap(0, UTEMP);
  8028ae:	83 ec 08             	sub    $0x8,%esp
  8028b1:	68 00 00 40 00       	push   $0x400000
  8028b6:	6a 00                	push   $0x0
  8028b8:	e8 9b ed ff ff       	call   801658 <sys_page_unmap>
  8028bd:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8028c0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8028c6:	81 c6 00 10 00 00    	add    $0x1000,%esi
  8028cc:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  8028d2:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  8028d8:	0f 87 f7 fe ff ff    	ja     8027d5 <spawn+0x2c4>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8028de:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  8028e5:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  8028ec:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  8028f3:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  8028f9:	0f 8c 67 fe ff ff    	jl     802766 <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  8028ff:	83 ec 0c             	sub    $0xc,%esp
  802902:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802908:	e8 b5 f4 ff ff       	call   801dc2 <close>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  80290d:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  802914:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  802917:	83 c4 08             	add    $0x8,%esp
  80291a:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  802920:	50                   	push   %eax
  802921:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802927:	e8 b0 ed ff ff       	call   8016dc <sys_env_set_trapframe>
  80292c:	83 c4 10             	add    $0x10,%esp
  80292f:	85 c0                	test   %eax,%eax
  802931:	79 15                	jns    802948 <spawn+0x437>
		panic("sys_env_set_trapframe: %e", r);
  802933:	50                   	push   %eax
  802934:	68 a7 39 80 00       	push   $0x8039a7
  802939:	68 86 00 00 00       	push   $0x86
  80293e:	68 7e 39 80 00       	push   $0x80397e
  802943:	e8 90 e0 ff ff       	call   8009d8 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  802948:	83 ec 08             	sub    $0x8,%esp
  80294b:	6a 02                	push   $0x2
  80294d:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802953:	e8 42 ed ff ff       	call   80169a <sys_env_set_status>
  802958:	83 c4 10             	add    $0x10,%esp
  80295b:	85 c0                	test   %eax,%eax
  80295d:	79 25                	jns    802984 <spawn+0x473>
		panic("sys_env_set_status: %e", r);
  80295f:	50                   	push   %eax
  802960:	68 c1 39 80 00       	push   $0x8039c1
  802965:	68 89 00 00 00       	push   $0x89
  80296a:	68 7e 39 80 00       	push   $0x80397e
  80296f:	e8 64 e0 ff ff       	call   8009d8 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  802974:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  80297a:	eb 58                	jmp    8029d4 <spawn+0x4c3>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  80297c:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  802982:	eb 50                	jmp    8029d4 <spawn+0x4c3>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  802984:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  80298a:	eb 48                	jmp    8029d4 <spawn+0x4c3>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  80298c:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  802991:	eb 41                	jmp    8029d4 <spawn+0x4c3>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  802993:	89 c3                	mov    %eax,%ebx
  802995:	eb 3d                	jmp    8029d4 <spawn+0x4c3>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802997:	89 c3                	mov    %eax,%ebx
  802999:	eb 06                	jmp    8029a1 <spawn+0x490>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  80299b:	89 c3                	mov    %eax,%ebx
  80299d:	eb 02                	jmp    8029a1 <spawn+0x490>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  80299f:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  8029a1:	83 ec 0c             	sub    $0xc,%esp
  8029a4:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8029aa:	e8 a5 eb ff ff       	call   801554 <sys_env_destroy>
	close(fd);
  8029af:	83 c4 04             	add    $0x4,%esp
  8029b2:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8029b8:	e8 05 f4 ff ff       	call   801dc2 <close>
	return r;
  8029bd:	83 c4 10             	add    $0x10,%esp
  8029c0:	eb 12                	jmp    8029d4 <spawn+0x4c3>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  8029c2:	83 ec 08             	sub    $0x8,%esp
  8029c5:	68 00 00 40 00       	push   $0x400000
  8029ca:	6a 00                	push   $0x0
  8029cc:	e8 87 ec ff ff       	call   801658 <sys_page_unmap>
  8029d1:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  8029d4:	89 d8                	mov    %ebx,%eax
  8029d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8029d9:	5b                   	pop    %ebx
  8029da:	5e                   	pop    %esi
  8029db:	5f                   	pop    %edi
  8029dc:	5d                   	pop    %ebp
  8029dd:	c3                   	ret    

008029de <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  8029de:	55                   	push   %ebp
  8029df:	89 e5                	mov    %esp,%ebp
  8029e1:	56                   	push   %esi
  8029e2:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8029e3:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  8029e6:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8029eb:	eb 03                	jmp    8029f0 <spawnl+0x12>
		argc++;
  8029ed:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8029f0:	83 c2 04             	add    $0x4,%edx
  8029f3:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  8029f7:	75 f4                	jne    8029ed <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  8029f9:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  802a00:	83 e2 f0             	and    $0xfffffff0,%edx
  802a03:	29 d4                	sub    %edx,%esp
  802a05:	8d 54 24 03          	lea    0x3(%esp),%edx
  802a09:	c1 ea 02             	shr    $0x2,%edx
  802a0c:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  802a13:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  802a15:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802a18:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  802a1f:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  802a26:	00 
  802a27:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802a29:	b8 00 00 00 00       	mov    $0x0,%eax
  802a2e:	eb 0a                	jmp    802a3a <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  802a30:	83 c0 01             	add    $0x1,%eax
  802a33:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  802a37:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802a3a:	39 d0                	cmp    %edx,%eax
  802a3c:	75 f2                	jne    802a30 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  802a3e:	83 ec 08             	sub    $0x8,%esp
  802a41:	56                   	push   %esi
  802a42:	ff 75 08             	pushl  0x8(%ebp)
  802a45:	e8 c7 fa ff ff       	call   802511 <spawn>
}
  802a4a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802a4d:	5b                   	pop    %ebx
  802a4e:	5e                   	pop    %esi
  802a4f:	5d                   	pop    %ebp
  802a50:	c3                   	ret    

00802a51 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802a51:	55                   	push   %ebp
  802a52:	89 e5                	mov    %esp,%ebp
  802a54:	56                   	push   %esi
  802a55:	53                   	push   %ebx
  802a56:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802a59:	83 ec 0c             	sub    $0xc,%esp
  802a5c:	ff 75 08             	pushl  0x8(%ebp)
  802a5f:	e8 ce f1 ff ff       	call   801c32 <fd2data>
  802a64:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802a66:	83 c4 08             	add    $0x8,%esp
  802a69:	68 00 3a 80 00       	push   $0x803a00
  802a6e:	53                   	push   %ebx
  802a6f:	e8 5c e7 ff ff       	call   8011d0 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802a74:	8b 46 04             	mov    0x4(%esi),%eax
  802a77:	2b 06                	sub    (%esi),%eax
  802a79:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802a7f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802a86:	00 00 00 
	stat->st_dev = &devpipe;
  802a89:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  802a90:	40 80 00 
	return 0;
}
  802a93:	b8 00 00 00 00       	mov    $0x0,%eax
  802a98:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802a9b:	5b                   	pop    %ebx
  802a9c:	5e                   	pop    %esi
  802a9d:	5d                   	pop    %ebp
  802a9e:	c3                   	ret    

00802a9f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802a9f:	55                   	push   %ebp
  802aa0:	89 e5                	mov    %esp,%ebp
  802aa2:	53                   	push   %ebx
  802aa3:	83 ec 0c             	sub    $0xc,%esp
  802aa6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802aa9:	53                   	push   %ebx
  802aaa:	6a 00                	push   $0x0
  802aac:	e8 a7 eb ff ff       	call   801658 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802ab1:	89 1c 24             	mov    %ebx,(%esp)
  802ab4:	e8 79 f1 ff ff       	call   801c32 <fd2data>
  802ab9:	83 c4 08             	add    $0x8,%esp
  802abc:	50                   	push   %eax
  802abd:	6a 00                	push   $0x0
  802abf:	e8 94 eb ff ff       	call   801658 <sys_page_unmap>
}
  802ac4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802ac7:	c9                   	leave  
  802ac8:	c3                   	ret    

00802ac9 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802ac9:	55                   	push   %ebp
  802aca:	89 e5                	mov    %esp,%ebp
  802acc:	57                   	push   %edi
  802acd:	56                   	push   %esi
  802ace:	53                   	push   %ebx
  802acf:	83 ec 1c             	sub    $0x1c,%esp
  802ad2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802ad5:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802ad7:	a1 24 54 80 00       	mov    0x805424,%eax
  802adc:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  802adf:	83 ec 0c             	sub    $0xc,%esp
  802ae2:	ff 75 e0             	pushl  -0x20(%ebp)
  802ae5:	e8 84 04 00 00       	call   802f6e <pageref>
  802aea:	89 c3                	mov    %eax,%ebx
  802aec:	89 3c 24             	mov    %edi,(%esp)
  802aef:	e8 7a 04 00 00       	call   802f6e <pageref>
  802af4:	83 c4 10             	add    $0x10,%esp
  802af7:	39 c3                	cmp    %eax,%ebx
  802af9:	0f 94 c1             	sete   %cl
  802afc:	0f b6 c9             	movzbl %cl,%ecx
  802aff:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  802b02:	8b 15 24 54 80 00    	mov    0x805424,%edx
  802b08:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802b0b:	39 ce                	cmp    %ecx,%esi
  802b0d:	74 1b                	je     802b2a <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  802b0f:	39 c3                	cmp    %eax,%ebx
  802b11:	75 c4                	jne    802ad7 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802b13:	8b 42 58             	mov    0x58(%edx),%eax
  802b16:	ff 75 e4             	pushl  -0x1c(%ebp)
  802b19:	50                   	push   %eax
  802b1a:	56                   	push   %esi
  802b1b:	68 07 3a 80 00       	push   $0x803a07
  802b20:	e8 8c df ff ff       	call   800ab1 <cprintf>
  802b25:	83 c4 10             	add    $0x10,%esp
  802b28:	eb ad                	jmp    802ad7 <_pipeisclosed+0xe>
	}
}
  802b2a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802b2d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802b30:	5b                   	pop    %ebx
  802b31:	5e                   	pop    %esi
  802b32:	5f                   	pop    %edi
  802b33:	5d                   	pop    %ebp
  802b34:	c3                   	ret    

00802b35 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802b35:	55                   	push   %ebp
  802b36:	89 e5                	mov    %esp,%ebp
  802b38:	57                   	push   %edi
  802b39:	56                   	push   %esi
  802b3a:	53                   	push   %ebx
  802b3b:	83 ec 28             	sub    $0x28,%esp
  802b3e:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802b41:	56                   	push   %esi
  802b42:	e8 eb f0 ff ff       	call   801c32 <fd2data>
  802b47:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802b49:	83 c4 10             	add    $0x10,%esp
  802b4c:	bf 00 00 00 00       	mov    $0x0,%edi
  802b51:	eb 4b                	jmp    802b9e <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802b53:	89 da                	mov    %ebx,%edx
  802b55:	89 f0                	mov    %esi,%eax
  802b57:	e8 6d ff ff ff       	call   802ac9 <_pipeisclosed>
  802b5c:	85 c0                	test   %eax,%eax
  802b5e:	75 48                	jne    802ba8 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802b60:	e8 4f ea ff ff       	call   8015b4 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802b65:	8b 43 04             	mov    0x4(%ebx),%eax
  802b68:	8b 0b                	mov    (%ebx),%ecx
  802b6a:	8d 51 20             	lea    0x20(%ecx),%edx
  802b6d:	39 d0                	cmp    %edx,%eax
  802b6f:	73 e2                	jae    802b53 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802b71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802b74:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802b78:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802b7b:	89 c2                	mov    %eax,%edx
  802b7d:	c1 fa 1f             	sar    $0x1f,%edx
  802b80:	89 d1                	mov    %edx,%ecx
  802b82:	c1 e9 1b             	shr    $0x1b,%ecx
  802b85:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802b88:	83 e2 1f             	and    $0x1f,%edx
  802b8b:	29 ca                	sub    %ecx,%edx
  802b8d:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802b91:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802b95:	83 c0 01             	add    $0x1,%eax
  802b98:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802b9b:	83 c7 01             	add    $0x1,%edi
  802b9e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802ba1:	75 c2                	jne    802b65 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802ba3:	8b 45 10             	mov    0x10(%ebp),%eax
  802ba6:	eb 05                	jmp    802bad <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802ba8:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802bad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802bb0:	5b                   	pop    %ebx
  802bb1:	5e                   	pop    %esi
  802bb2:	5f                   	pop    %edi
  802bb3:	5d                   	pop    %ebp
  802bb4:	c3                   	ret    

00802bb5 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802bb5:	55                   	push   %ebp
  802bb6:	89 e5                	mov    %esp,%ebp
  802bb8:	57                   	push   %edi
  802bb9:	56                   	push   %esi
  802bba:	53                   	push   %ebx
  802bbb:	83 ec 18             	sub    $0x18,%esp
  802bbe:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802bc1:	57                   	push   %edi
  802bc2:	e8 6b f0 ff ff       	call   801c32 <fd2data>
  802bc7:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802bc9:	83 c4 10             	add    $0x10,%esp
  802bcc:	bb 00 00 00 00       	mov    $0x0,%ebx
  802bd1:	eb 3d                	jmp    802c10 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802bd3:	85 db                	test   %ebx,%ebx
  802bd5:	74 04                	je     802bdb <devpipe_read+0x26>
				return i;
  802bd7:	89 d8                	mov    %ebx,%eax
  802bd9:	eb 44                	jmp    802c1f <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802bdb:	89 f2                	mov    %esi,%edx
  802bdd:	89 f8                	mov    %edi,%eax
  802bdf:	e8 e5 fe ff ff       	call   802ac9 <_pipeisclosed>
  802be4:	85 c0                	test   %eax,%eax
  802be6:	75 32                	jne    802c1a <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802be8:	e8 c7 e9 ff ff       	call   8015b4 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802bed:	8b 06                	mov    (%esi),%eax
  802bef:	3b 46 04             	cmp    0x4(%esi),%eax
  802bf2:	74 df                	je     802bd3 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802bf4:	99                   	cltd   
  802bf5:	c1 ea 1b             	shr    $0x1b,%edx
  802bf8:	01 d0                	add    %edx,%eax
  802bfa:	83 e0 1f             	and    $0x1f,%eax
  802bfd:	29 d0                	sub    %edx,%eax
  802bff:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802c04:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802c07:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802c0a:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802c0d:	83 c3 01             	add    $0x1,%ebx
  802c10:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802c13:	75 d8                	jne    802bed <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802c15:	8b 45 10             	mov    0x10(%ebp),%eax
  802c18:	eb 05                	jmp    802c1f <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802c1a:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802c1f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802c22:	5b                   	pop    %ebx
  802c23:	5e                   	pop    %esi
  802c24:	5f                   	pop    %edi
  802c25:	5d                   	pop    %ebp
  802c26:	c3                   	ret    

00802c27 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802c27:	55                   	push   %ebp
  802c28:	89 e5                	mov    %esp,%ebp
  802c2a:	56                   	push   %esi
  802c2b:	53                   	push   %ebx
  802c2c:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802c2f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802c32:	50                   	push   %eax
  802c33:	e8 11 f0 ff ff       	call   801c49 <fd_alloc>
  802c38:	83 c4 10             	add    $0x10,%esp
  802c3b:	89 c2                	mov    %eax,%edx
  802c3d:	85 c0                	test   %eax,%eax
  802c3f:	0f 88 2c 01 00 00    	js     802d71 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802c45:	83 ec 04             	sub    $0x4,%esp
  802c48:	68 07 04 00 00       	push   $0x407
  802c4d:	ff 75 f4             	pushl  -0xc(%ebp)
  802c50:	6a 00                	push   $0x0
  802c52:	e8 7c e9 ff ff       	call   8015d3 <sys_page_alloc>
  802c57:	83 c4 10             	add    $0x10,%esp
  802c5a:	89 c2                	mov    %eax,%edx
  802c5c:	85 c0                	test   %eax,%eax
  802c5e:	0f 88 0d 01 00 00    	js     802d71 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802c64:	83 ec 0c             	sub    $0xc,%esp
  802c67:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802c6a:	50                   	push   %eax
  802c6b:	e8 d9 ef ff ff       	call   801c49 <fd_alloc>
  802c70:	89 c3                	mov    %eax,%ebx
  802c72:	83 c4 10             	add    $0x10,%esp
  802c75:	85 c0                	test   %eax,%eax
  802c77:	0f 88 e2 00 00 00    	js     802d5f <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802c7d:	83 ec 04             	sub    $0x4,%esp
  802c80:	68 07 04 00 00       	push   $0x407
  802c85:	ff 75 f0             	pushl  -0x10(%ebp)
  802c88:	6a 00                	push   $0x0
  802c8a:	e8 44 e9 ff ff       	call   8015d3 <sys_page_alloc>
  802c8f:	89 c3                	mov    %eax,%ebx
  802c91:	83 c4 10             	add    $0x10,%esp
  802c94:	85 c0                	test   %eax,%eax
  802c96:	0f 88 c3 00 00 00    	js     802d5f <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802c9c:	83 ec 0c             	sub    $0xc,%esp
  802c9f:	ff 75 f4             	pushl  -0xc(%ebp)
  802ca2:	e8 8b ef ff ff       	call   801c32 <fd2data>
  802ca7:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802ca9:	83 c4 0c             	add    $0xc,%esp
  802cac:	68 07 04 00 00       	push   $0x407
  802cb1:	50                   	push   %eax
  802cb2:	6a 00                	push   $0x0
  802cb4:	e8 1a e9 ff ff       	call   8015d3 <sys_page_alloc>
  802cb9:	89 c3                	mov    %eax,%ebx
  802cbb:	83 c4 10             	add    $0x10,%esp
  802cbe:	85 c0                	test   %eax,%eax
  802cc0:	0f 88 89 00 00 00    	js     802d4f <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802cc6:	83 ec 0c             	sub    $0xc,%esp
  802cc9:	ff 75 f0             	pushl  -0x10(%ebp)
  802ccc:	e8 61 ef ff ff       	call   801c32 <fd2data>
  802cd1:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802cd8:	50                   	push   %eax
  802cd9:	6a 00                	push   $0x0
  802cdb:	56                   	push   %esi
  802cdc:	6a 00                	push   $0x0
  802cde:	e8 33 e9 ff ff       	call   801616 <sys_page_map>
  802ce3:	89 c3                	mov    %eax,%ebx
  802ce5:	83 c4 20             	add    $0x20,%esp
  802ce8:	85 c0                	test   %eax,%eax
  802cea:	78 55                	js     802d41 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802cec:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802cf2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802cf5:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802cf7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802cfa:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802d01:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802d07:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802d0a:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802d0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802d0f:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802d16:	83 ec 0c             	sub    $0xc,%esp
  802d19:	ff 75 f4             	pushl  -0xc(%ebp)
  802d1c:	e8 01 ef ff ff       	call   801c22 <fd2num>
  802d21:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802d24:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802d26:	83 c4 04             	add    $0x4,%esp
  802d29:	ff 75 f0             	pushl  -0x10(%ebp)
  802d2c:	e8 f1 ee ff ff       	call   801c22 <fd2num>
  802d31:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802d34:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802d37:	83 c4 10             	add    $0x10,%esp
  802d3a:	ba 00 00 00 00       	mov    $0x0,%edx
  802d3f:	eb 30                	jmp    802d71 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802d41:	83 ec 08             	sub    $0x8,%esp
  802d44:	56                   	push   %esi
  802d45:	6a 00                	push   $0x0
  802d47:	e8 0c e9 ff ff       	call   801658 <sys_page_unmap>
  802d4c:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802d4f:	83 ec 08             	sub    $0x8,%esp
  802d52:	ff 75 f0             	pushl  -0x10(%ebp)
  802d55:	6a 00                	push   $0x0
  802d57:	e8 fc e8 ff ff       	call   801658 <sys_page_unmap>
  802d5c:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802d5f:	83 ec 08             	sub    $0x8,%esp
  802d62:	ff 75 f4             	pushl  -0xc(%ebp)
  802d65:	6a 00                	push   $0x0
  802d67:	e8 ec e8 ff ff       	call   801658 <sys_page_unmap>
  802d6c:	83 c4 10             	add    $0x10,%esp
  802d6f:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802d71:	89 d0                	mov    %edx,%eax
  802d73:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802d76:	5b                   	pop    %ebx
  802d77:	5e                   	pop    %esi
  802d78:	5d                   	pop    %ebp
  802d79:	c3                   	ret    

00802d7a <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802d7a:	55                   	push   %ebp
  802d7b:	89 e5                	mov    %esp,%ebp
  802d7d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802d80:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802d83:	50                   	push   %eax
  802d84:	ff 75 08             	pushl  0x8(%ebp)
  802d87:	e8 0c ef ff ff       	call   801c98 <fd_lookup>
  802d8c:	83 c4 10             	add    $0x10,%esp
  802d8f:	85 c0                	test   %eax,%eax
  802d91:	78 18                	js     802dab <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802d93:	83 ec 0c             	sub    $0xc,%esp
  802d96:	ff 75 f4             	pushl  -0xc(%ebp)
  802d99:	e8 94 ee ff ff       	call   801c32 <fd2data>
	return _pipeisclosed(fd, p);
  802d9e:	89 c2                	mov    %eax,%edx
  802da0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802da3:	e8 21 fd ff ff       	call   802ac9 <_pipeisclosed>
  802da8:	83 c4 10             	add    $0x10,%esp
}
  802dab:	c9                   	leave  
  802dac:	c3                   	ret    

00802dad <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802dad:	55                   	push   %ebp
  802dae:	89 e5                	mov    %esp,%ebp
  802db0:	56                   	push   %esi
  802db1:	53                   	push   %ebx
  802db2:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802db5:	85 f6                	test   %esi,%esi
  802db7:	75 16                	jne    802dcf <wait+0x22>
  802db9:	68 1f 3a 80 00       	push   $0x803a1f
  802dbe:	68 98 33 80 00       	push   $0x803398
  802dc3:	6a 09                	push   $0x9
  802dc5:	68 2a 3a 80 00       	push   $0x803a2a
  802dca:	e8 09 dc ff ff       	call   8009d8 <_panic>
	e = &envs[ENVX(envid)];
  802dcf:	89 f3                	mov    %esi,%ebx
  802dd1:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802dd7:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  802dda:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  802de0:	eb 05                	jmp    802de7 <wait+0x3a>
		sys_yield();
  802de2:	e8 cd e7 ff ff       	call   8015b4 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802de7:	8b 43 48             	mov    0x48(%ebx),%eax
  802dea:	39 c6                	cmp    %eax,%esi
  802dec:	75 07                	jne    802df5 <wait+0x48>
  802dee:	8b 43 54             	mov    0x54(%ebx),%eax
  802df1:	85 c0                	test   %eax,%eax
  802df3:	75 ed                	jne    802de2 <wait+0x35>
		sys_yield();
}
  802df5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802df8:	5b                   	pop    %ebx
  802df9:	5e                   	pop    %esi
  802dfa:	5d                   	pop    %ebp
  802dfb:	c3                   	ret    

00802dfc <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802dfc:	55                   	push   %ebp
  802dfd:	89 e5                	mov    %esp,%ebp
  802dff:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802e02:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802e09:	75 31                	jne    802e3c <set_pgfault_handler+0x40>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc(thisenv->env_id, (void*)(UXSTACKTOP - PGSIZE), PTE_P | 
  802e0b:	a1 24 54 80 00       	mov    0x805424,%eax
  802e10:	8b 40 48             	mov    0x48(%eax),%eax
  802e13:	83 ec 04             	sub    $0x4,%esp
  802e16:	6a 07                	push   $0x7
  802e18:	68 00 f0 bf ee       	push   $0xeebff000
  802e1d:	50                   	push   %eax
  802e1e:	e8 b0 e7 ff ff       	call   8015d3 <sys_page_alloc>
				PTE_U | PTE_W);
		sys_env_set_pgfault_upcall(thisenv->env_id, (void*)_pgfault_upcall);
  802e23:	a1 24 54 80 00       	mov    0x805424,%eax
  802e28:	8b 40 48             	mov    0x48(%eax),%eax
  802e2b:	83 c4 08             	add    $0x8,%esp
  802e2e:	68 46 2e 80 00       	push   $0x802e46
  802e33:	50                   	push   %eax
  802e34:	e8 e5 e8 ff ff       	call   80171e <sys_env_set_pgfault_upcall>
  802e39:	83 c4 10             	add    $0x10,%esp

		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802e3c:	8b 45 08             	mov    0x8(%ebp),%eax
  802e3f:	a3 00 70 80 00       	mov    %eax,0x807000
}
  802e44:	c9                   	leave  
  802e45:	c3                   	ret    

00802e46 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802e46:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802e47:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802e4c:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802e4e:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	addl $8, %esp      // pop utf_fault_va and utf_err
  802e51:	83 c4 08             	add    $0x8,%esp
	movl 32(%esp), %eax  // eax <- [esp + 32]
  802e54:	8b 44 24 20          	mov    0x20(%esp),%eax
	movl 40(%esp), %ebx  // ebx <- [esp + 40]
  802e58:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	leal -4(%ebx), %ebx  // ebx <- ebx - 4
  802e5c:	8d 5b fc             	lea    -0x4(%ebx),%ebx
	movl %eax, (%ebx)
  802e5f:	89 03                	mov    %eax,(%ebx)
	movl %ebx, 40(%esp)  // push trap eip and decrement trap esp manually
  802e61:	89 5c 24 28          	mov    %ebx,0x28(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  802e65:	61                   	popa   
	addl $4, %esp        // skip eip
  802e66:	83 c4 04             	add    $0x4,%esp

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	popf
  802e69:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	pop %esp
  802e6a:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802e6b:	c3                   	ret    

00802e6c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802e6c:	55                   	push   %ebp
  802e6d:	89 e5                	mov    %esp,%ebp
  802e6f:	56                   	push   %esi
  802e70:	53                   	push   %ebx
  802e71:	8b 75 08             	mov    0x8(%ebp),%esi
  802e74:	8b 45 0c             	mov    0xc(%ebp),%eax
  802e77:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int ret;
	if (pg) ret = sys_ipc_recv(pg);
  802e7a:	85 c0                	test   %eax,%eax
  802e7c:	74 0e                	je     802e8c <ipc_recv+0x20>
  802e7e:	83 ec 0c             	sub    $0xc,%esp
  802e81:	50                   	push   %eax
  802e82:	e8 fc e8 ff ff       	call   801783 <sys_ipc_recv>
  802e87:	83 c4 10             	add    $0x10,%esp
  802e8a:	eb 10                	jmp    802e9c <ipc_recv+0x30>
	else ret = sys_ipc_recv((void*)UTOP);
  802e8c:	83 ec 0c             	sub    $0xc,%esp
  802e8f:	68 00 00 c0 ee       	push   $0xeec00000
  802e94:	e8 ea e8 ff ff       	call   801783 <sys_ipc_recv>
  802e99:	83 c4 10             	add    $0x10,%esp
	if (ret) {
  802e9c:	85 c0                	test   %eax,%eax
  802e9e:	74 16                	je     802eb6 <ipc_recv+0x4a>
		if (from_env_store) *from_env_store = 0;
  802ea0:	85 f6                	test   %esi,%esi
  802ea2:	74 06                	je     802eaa <ipc_recv+0x3e>
  802ea4:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  802eaa:	85 db                	test   %ebx,%ebx
  802eac:	74 2c                	je     802eda <ipc_recv+0x6e>
  802eae:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802eb4:	eb 24                	jmp    802eda <ipc_recv+0x6e>
		return ret;
	}
	if (from_env_store) *from_env_store = thisenv->env_ipc_from;
  802eb6:	85 f6                	test   %esi,%esi
  802eb8:	74 0a                	je     802ec4 <ipc_recv+0x58>
  802eba:	a1 24 54 80 00       	mov    0x805424,%eax
  802ebf:	8b 40 74             	mov    0x74(%eax),%eax
  802ec2:	89 06                	mov    %eax,(%esi)
	if (perm_store) *perm_store = thisenv->env_ipc_perm;
  802ec4:	85 db                	test   %ebx,%ebx
  802ec6:	74 0a                	je     802ed2 <ipc_recv+0x66>
  802ec8:	a1 24 54 80 00       	mov    0x805424,%eax
  802ecd:	8b 40 78             	mov    0x78(%eax),%eax
  802ed0:	89 03                	mov    %eax,(%ebx)

	// panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802ed2:	a1 24 54 80 00       	mov    0x805424,%eax
  802ed7:	8b 40 70             	mov    0x70(%eax),%eax
}
  802eda:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802edd:	5b                   	pop    %ebx
  802ede:	5e                   	pop    %esi
  802edf:	5d                   	pop    %ebp
  802ee0:	c3                   	ret    

00802ee1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802ee1:	55                   	push   %ebp
  802ee2:	89 e5                	mov    %esp,%ebp
  802ee4:	57                   	push   %edi
  802ee5:	56                   	push   %esi
  802ee6:	53                   	push   %ebx
  802ee7:	83 ec 0c             	sub    $0xc,%esp
  802eea:	8b 7d 08             	mov    0x8(%ebp),%edi
  802eed:	8b 75 0c             	mov    0xc(%ebp),%esi
  802ef0:	8b 45 10             	mov    0x10(%ebp),%eax
  802ef3:	85 c0                	test   %eax,%eax
  802ef5:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  802efa:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	while (true) {
		void* srcva = (pg)? pg: (void*)UTOP;
		int ret = sys_ipc_try_send(to_env, val, srcva, perm);
  802efd:	ff 75 14             	pushl  0x14(%ebp)
  802f00:	53                   	push   %ebx
  802f01:	56                   	push   %esi
  802f02:	57                   	push   %edi
  802f03:	e8 58 e8 ff ff       	call   801760 <sys_ipc_try_send>
		if (ret == 0) break;
  802f08:	83 c4 10             	add    $0x10,%esp
  802f0b:	85 c0                	test   %eax,%eax
  802f0d:	74 1e                	je     802f2d <ipc_send+0x4c>
		if (ret != -E_IPC_NOT_RECV) panic("ipc_send: %e", ret);
  802f0f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802f12:	74 12                	je     802f26 <ipc_send+0x45>
  802f14:	50                   	push   %eax
  802f15:	68 35 3a 80 00       	push   $0x803a35
  802f1a:	6a 39                	push   $0x39
  802f1c:	68 42 3a 80 00       	push   $0x803a42
  802f21:	e8 b2 da ff ff       	call   8009d8 <_panic>
		sys_yield();
  802f26:	e8 89 e6 ff ff       	call   8015b4 <sys_yield>
	}
  802f2b:	eb d0                	jmp    802efd <ipc_send+0x1c>
	// panic("ipc_send not implemented");
}
  802f2d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802f30:	5b                   	pop    %ebx
  802f31:	5e                   	pop    %esi
  802f32:	5f                   	pop    %edi
  802f33:	5d                   	pop    %ebp
  802f34:	c3                   	ret    

00802f35 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802f35:	55                   	push   %ebp
  802f36:	89 e5                	mov    %esp,%ebp
  802f38:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802f3b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802f40:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802f43:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802f49:	8b 52 50             	mov    0x50(%edx),%edx
  802f4c:	39 ca                	cmp    %ecx,%edx
  802f4e:	75 0d                	jne    802f5d <ipc_find_env+0x28>
			return envs[i].env_id;
  802f50:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802f53:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802f58:	8b 40 48             	mov    0x48(%eax),%eax
  802f5b:	eb 0f                	jmp    802f6c <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802f5d:	83 c0 01             	add    $0x1,%eax
  802f60:	3d 00 04 00 00       	cmp    $0x400,%eax
  802f65:	75 d9                	jne    802f40 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802f67:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802f6c:	5d                   	pop    %ebp
  802f6d:	c3                   	ret    

00802f6e <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802f6e:	55                   	push   %ebp
  802f6f:	89 e5                	mov    %esp,%ebp
  802f71:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802f74:	89 d0                	mov    %edx,%eax
  802f76:	c1 e8 16             	shr    $0x16,%eax
  802f79:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802f80:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802f85:	f6 c1 01             	test   $0x1,%cl
  802f88:	74 1d                	je     802fa7 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802f8a:	c1 ea 0c             	shr    $0xc,%edx
  802f8d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802f94:	f6 c2 01             	test   $0x1,%dl
  802f97:	74 0e                	je     802fa7 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802f99:	c1 ea 0c             	shr    $0xc,%edx
  802f9c:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802fa3:	ef 
  802fa4:	0f b7 c0             	movzwl %ax,%eax
}
  802fa7:	5d                   	pop    %ebp
  802fa8:	c3                   	ret    
  802fa9:	66 90                	xchg   %ax,%ax
  802fab:	66 90                	xchg   %ax,%ax
  802fad:	66 90                	xchg   %ax,%ax
  802faf:	90                   	nop

00802fb0 <__udivdi3>:
  802fb0:	55                   	push   %ebp
  802fb1:	57                   	push   %edi
  802fb2:	56                   	push   %esi
  802fb3:	53                   	push   %ebx
  802fb4:	83 ec 1c             	sub    $0x1c,%esp
  802fb7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  802fbb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  802fbf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802fc3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802fc7:	85 f6                	test   %esi,%esi
  802fc9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802fcd:	89 ca                	mov    %ecx,%edx
  802fcf:	89 f8                	mov    %edi,%eax
  802fd1:	75 3d                	jne    803010 <__udivdi3+0x60>
  802fd3:	39 cf                	cmp    %ecx,%edi
  802fd5:	0f 87 c5 00 00 00    	ja     8030a0 <__udivdi3+0xf0>
  802fdb:	85 ff                	test   %edi,%edi
  802fdd:	89 fd                	mov    %edi,%ebp
  802fdf:	75 0b                	jne    802fec <__udivdi3+0x3c>
  802fe1:	b8 01 00 00 00       	mov    $0x1,%eax
  802fe6:	31 d2                	xor    %edx,%edx
  802fe8:	f7 f7                	div    %edi
  802fea:	89 c5                	mov    %eax,%ebp
  802fec:	89 c8                	mov    %ecx,%eax
  802fee:	31 d2                	xor    %edx,%edx
  802ff0:	f7 f5                	div    %ebp
  802ff2:	89 c1                	mov    %eax,%ecx
  802ff4:	89 d8                	mov    %ebx,%eax
  802ff6:	89 cf                	mov    %ecx,%edi
  802ff8:	f7 f5                	div    %ebp
  802ffa:	89 c3                	mov    %eax,%ebx
  802ffc:	89 d8                	mov    %ebx,%eax
  802ffe:	89 fa                	mov    %edi,%edx
  803000:	83 c4 1c             	add    $0x1c,%esp
  803003:	5b                   	pop    %ebx
  803004:	5e                   	pop    %esi
  803005:	5f                   	pop    %edi
  803006:	5d                   	pop    %ebp
  803007:	c3                   	ret    
  803008:	90                   	nop
  803009:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803010:	39 ce                	cmp    %ecx,%esi
  803012:	77 74                	ja     803088 <__udivdi3+0xd8>
  803014:	0f bd fe             	bsr    %esi,%edi
  803017:	83 f7 1f             	xor    $0x1f,%edi
  80301a:	0f 84 98 00 00 00    	je     8030b8 <__udivdi3+0x108>
  803020:	bb 20 00 00 00       	mov    $0x20,%ebx
  803025:	89 f9                	mov    %edi,%ecx
  803027:	89 c5                	mov    %eax,%ebp
  803029:	29 fb                	sub    %edi,%ebx
  80302b:	d3 e6                	shl    %cl,%esi
  80302d:	89 d9                	mov    %ebx,%ecx
  80302f:	d3 ed                	shr    %cl,%ebp
  803031:	89 f9                	mov    %edi,%ecx
  803033:	d3 e0                	shl    %cl,%eax
  803035:	09 ee                	or     %ebp,%esi
  803037:	89 d9                	mov    %ebx,%ecx
  803039:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80303d:	89 d5                	mov    %edx,%ebp
  80303f:	8b 44 24 08          	mov    0x8(%esp),%eax
  803043:	d3 ed                	shr    %cl,%ebp
  803045:	89 f9                	mov    %edi,%ecx
  803047:	d3 e2                	shl    %cl,%edx
  803049:	89 d9                	mov    %ebx,%ecx
  80304b:	d3 e8                	shr    %cl,%eax
  80304d:	09 c2                	or     %eax,%edx
  80304f:	89 d0                	mov    %edx,%eax
  803051:	89 ea                	mov    %ebp,%edx
  803053:	f7 f6                	div    %esi
  803055:	89 d5                	mov    %edx,%ebp
  803057:	89 c3                	mov    %eax,%ebx
  803059:	f7 64 24 0c          	mull   0xc(%esp)
  80305d:	39 d5                	cmp    %edx,%ebp
  80305f:	72 10                	jb     803071 <__udivdi3+0xc1>
  803061:	8b 74 24 08          	mov    0x8(%esp),%esi
  803065:	89 f9                	mov    %edi,%ecx
  803067:	d3 e6                	shl    %cl,%esi
  803069:	39 c6                	cmp    %eax,%esi
  80306b:	73 07                	jae    803074 <__udivdi3+0xc4>
  80306d:	39 d5                	cmp    %edx,%ebp
  80306f:	75 03                	jne    803074 <__udivdi3+0xc4>
  803071:	83 eb 01             	sub    $0x1,%ebx
  803074:	31 ff                	xor    %edi,%edi
  803076:	89 d8                	mov    %ebx,%eax
  803078:	89 fa                	mov    %edi,%edx
  80307a:	83 c4 1c             	add    $0x1c,%esp
  80307d:	5b                   	pop    %ebx
  80307e:	5e                   	pop    %esi
  80307f:	5f                   	pop    %edi
  803080:	5d                   	pop    %ebp
  803081:	c3                   	ret    
  803082:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803088:	31 ff                	xor    %edi,%edi
  80308a:	31 db                	xor    %ebx,%ebx
  80308c:	89 d8                	mov    %ebx,%eax
  80308e:	89 fa                	mov    %edi,%edx
  803090:	83 c4 1c             	add    $0x1c,%esp
  803093:	5b                   	pop    %ebx
  803094:	5e                   	pop    %esi
  803095:	5f                   	pop    %edi
  803096:	5d                   	pop    %ebp
  803097:	c3                   	ret    
  803098:	90                   	nop
  803099:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8030a0:	89 d8                	mov    %ebx,%eax
  8030a2:	f7 f7                	div    %edi
  8030a4:	31 ff                	xor    %edi,%edi
  8030a6:	89 c3                	mov    %eax,%ebx
  8030a8:	89 d8                	mov    %ebx,%eax
  8030aa:	89 fa                	mov    %edi,%edx
  8030ac:	83 c4 1c             	add    $0x1c,%esp
  8030af:	5b                   	pop    %ebx
  8030b0:	5e                   	pop    %esi
  8030b1:	5f                   	pop    %edi
  8030b2:	5d                   	pop    %ebp
  8030b3:	c3                   	ret    
  8030b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8030b8:	39 ce                	cmp    %ecx,%esi
  8030ba:	72 0c                	jb     8030c8 <__udivdi3+0x118>
  8030bc:	31 db                	xor    %ebx,%ebx
  8030be:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8030c2:	0f 87 34 ff ff ff    	ja     802ffc <__udivdi3+0x4c>
  8030c8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8030cd:	e9 2a ff ff ff       	jmp    802ffc <__udivdi3+0x4c>
  8030d2:	66 90                	xchg   %ax,%ax
  8030d4:	66 90                	xchg   %ax,%ax
  8030d6:	66 90                	xchg   %ax,%ax
  8030d8:	66 90                	xchg   %ax,%ax
  8030da:	66 90                	xchg   %ax,%ax
  8030dc:	66 90                	xchg   %ax,%ax
  8030de:	66 90                	xchg   %ax,%ax

008030e0 <__umoddi3>:
  8030e0:	55                   	push   %ebp
  8030e1:	57                   	push   %edi
  8030e2:	56                   	push   %esi
  8030e3:	53                   	push   %ebx
  8030e4:	83 ec 1c             	sub    $0x1c,%esp
  8030e7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8030eb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8030ef:	8b 74 24 34          	mov    0x34(%esp),%esi
  8030f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8030f7:	85 d2                	test   %edx,%edx
  8030f9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8030fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803101:	89 f3                	mov    %esi,%ebx
  803103:	89 3c 24             	mov    %edi,(%esp)
  803106:	89 74 24 04          	mov    %esi,0x4(%esp)
  80310a:	75 1c                	jne    803128 <__umoddi3+0x48>
  80310c:	39 f7                	cmp    %esi,%edi
  80310e:	76 50                	jbe    803160 <__umoddi3+0x80>
  803110:	89 c8                	mov    %ecx,%eax
  803112:	89 f2                	mov    %esi,%edx
  803114:	f7 f7                	div    %edi
  803116:	89 d0                	mov    %edx,%eax
  803118:	31 d2                	xor    %edx,%edx
  80311a:	83 c4 1c             	add    $0x1c,%esp
  80311d:	5b                   	pop    %ebx
  80311e:	5e                   	pop    %esi
  80311f:	5f                   	pop    %edi
  803120:	5d                   	pop    %ebp
  803121:	c3                   	ret    
  803122:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803128:	39 f2                	cmp    %esi,%edx
  80312a:	89 d0                	mov    %edx,%eax
  80312c:	77 52                	ja     803180 <__umoddi3+0xa0>
  80312e:	0f bd ea             	bsr    %edx,%ebp
  803131:	83 f5 1f             	xor    $0x1f,%ebp
  803134:	75 5a                	jne    803190 <__umoddi3+0xb0>
  803136:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80313a:	0f 82 e0 00 00 00    	jb     803220 <__umoddi3+0x140>
  803140:	39 0c 24             	cmp    %ecx,(%esp)
  803143:	0f 86 d7 00 00 00    	jbe    803220 <__umoddi3+0x140>
  803149:	8b 44 24 08          	mov    0x8(%esp),%eax
  80314d:	8b 54 24 04          	mov    0x4(%esp),%edx
  803151:	83 c4 1c             	add    $0x1c,%esp
  803154:	5b                   	pop    %ebx
  803155:	5e                   	pop    %esi
  803156:	5f                   	pop    %edi
  803157:	5d                   	pop    %ebp
  803158:	c3                   	ret    
  803159:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803160:	85 ff                	test   %edi,%edi
  803162:	89 fd                	mov    %edi,%ebp
  803164:	75 0b                	jne    803171 <__umoddi3+0x91>
  803166:	b8 01 00 00 00       	mov    $0x1,%eax
  80316b:	31 d2                	xor    %edx,%edx
  80316d:	f7 f7                	div    %edi
  80316f:	89 c5                	mov    %eax,%ebp
  803171:	89 f0                	mov    %esi,%eax
  803173:	31 d2                	xor    %edx,%edx
  803175:	f7 f5                	div    %ebp
  803177:	89 c8                	mov    %ecx,%eax
  803179:	f7 f5                	div    %ebp
  80317b:	89 d0                	mov    %edx,%eax
  80317d:	eb 99                	jmp    803118 <__umoddi3+0x38>
  80317f:	90                   	nop
  803180:	89 c8                	mov    %ecx,%eax
  803182:	89 f2                	mov    %esi,%edx
  803184:	83 c4 1c             	add    $0x1c,%esp
  803187:	5b                   	pop    %ebx
  803188:	5e                   	pop    %esi
  803189:	5f                   	pop    %edi
  80318a:	5d                   	pop    %ebp
  80318b:	c3                   	ret    
  80318c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803190:	8b 34 24             	mov    (%esp),%esi
  803193:	bf 20 00 00 00       	mov    $0x20,%edi
  803198:	89 e9                	mov    %ebp,%ecx
  80319a:	29 ef                	sub    %ebp,%edi
  80319c:	d3 e0                	shl    %cl,%eax
  80319e:	89 f9                	mov    %edi,%ecx
  8031a0:	89 f2                	mov    %esi,%edx
  8031a2:	d3 ea                	shr    %cl,%edx
  8031a4:	89 e9                	mov    %ebp,%ecx
  8031a6:	09 c2                	or     %eax,%edx
  8031a8:	89 d8                	mov    %ebx,%eax
  8031aa:	89 14 24             	mov    %edx,(%esp)
  8031ad:	89 f2                	mov    %esi,%edx
  8031af:	d3 e2                	shl    %cl,%edx
  8031b1:	89 f9                	mov    %edi,%ecx
  8031b3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8031b7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8031bb:	d3 e8                	shr    %cl,%eax
  8031bd:	89 e9                	mov    %ebp,%ecx
  8031bf:	89 c6                	mov    %eax,%esi
  8031c1:	d3 e3                	shl    %cl,%ebx
  8031c3:	89 f9                	mov    %edi,%ecx
  8031c5:	89 d0                	mov    %edx,%eax
  8031c7:	d3 e8                	shr    %cl,%eax
  8031c9:	89 e9                	mov    %ebp,%ecx
  8031cb:	09 d8                	or     %ebx,%eax
  8031cd:	89 d3                	mov    %edx,%ebx
  8031cf:	89 f2                	mov    %esi,%edx
  8031d1:	f7 34 24             	divl   (%esp)
  8031d4:	89 d6                	mov    %edx,%esi
  8031d6:	d3 e3                	shl    %cl,%ebx
  8031d8:	f7 64 24 04          	mull   0x4(%esp)
  8031dc:	39 d6                	cmp    %edx,%esi
  8031de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8031e2:	89 d1                	mov    %edx,%ecx
  8031e4:	89 c3                	mov    %eax,%ebx
  8031e6:	72 08                	jb     8031f0 <__umoddi3+0x110>
  8031e8:	75 11                	jne    8031fb <__umoddi3+0x11b>
  8031ea:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8031ee:	73 0b                	jae    8031fb <__umoddi3+0x11b>
  8031f0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8031f4:	1b 14 24             	sbb    (%esp),%edx
  8031f7:	89 d1                	mov    %edx,%ecx
  8031f9:	89 c3                	mov    %eax,%ebx
  8031fb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8031ff:	29 da                	sub    %ebx,%edx
  803201:	19 ce                	sbb    %ecx,%esi
  803203:	89 f9                	mov    %edi,%ecx
  803205:	89 f0                	mov    %esi,%eax
  803207:	d3 e0                	shl    %cl,%eax
  803209:	89 e9                	mov    %ebp,%ecx
  80320b:	d3 ea                	shr    %cl,%edx
  80320d:	89 e9                	mov    %ebp,%ecx
  80320f:	d3 ee                	shr    %cl,%esi
  803211:	09 d0                	or     %edx,%eax
  803213:	89 f2                	mov    %esi,%edx
  803215:	83 c4 1c             	add    $0x1c,%esp
  803218:	5b                   	pop    %ebx
  803219:	5e                   	pop    %esi
  80321a:	5f                   	pop    %edi
  80321b:	5d                   	pop    %ebp
  80321c:	c3                   	ret    
  80321d:	8d 76 00             	lea    0x0(%esi),%esi
  803220:	29 f9                	sub    %edi,%ecx
  803222:	19 d6                	sbb    %edx,%esi
  803224:	89 74 24 04          	mov    %esi,0x4(%esp)
  803228:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80322c:	e9 18 ff ff ff       	jmp    803149 <__umoddi3+0x69>
