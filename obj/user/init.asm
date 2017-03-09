
obj/user/init.debug:     file format elf32-i386


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
  80002c:	e8 6e 03 00 00       	call   80039f <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <sum>:

char bss[6000];

int
sum(const char *s, int n)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 75 08             	mov    0x8(%ebp),%esi
  80003b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i, tot = 0;
  80003e:	b8 00 00 00 00       	mov    $0x0,%eax
	for (i = 0; i < n; i++)
  800043:	ba 00 00 00 00       	mov    $0x0,%edx
  800048:	eb 0c                	jmp    800056 <sum+0x23>
		tot ^= i * s[i];
  80004a:	0f be 0c 16          	movsbl (%esi,%edx,1),%ecx
  80004e:	0f af ca             	imul   %edx,%ecx
  800051:	31 c8                	xor    %ecx,%eax

int
sum(const char *s, int n)
{
	int i, tot = 0;
	for (i = 0; i < n; i++)
  800053:	83 c2 01             	add    $0x1,%edx
  800056:	39 da                	cmp    %ebx,%edx
  800058:	7c f0                	jl     80004a <sum+0x17>
		tot ^= i * s[i];
	return tot;
}
  80005a:	5b                   	pop    %ebx
  80005b:	5e                   	pop    %esi
  80005c:	5d                   	pop    %ebp
  80005d:	c3                   	ret    

0080005e <umain>:

void
umain(int argc, char **argv)
{
  80005e:	55                   	push   %ebp
  80005f:	89 e5                	mov    %esp,%ebp
  800061:	57                   	push   %edi
  800062:	56                   	push   %esi
  800063:	53                   	push   %ebx
  800064:	81 ec 18 01 00 00    	sub    $0x118,%esp
  80006a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int i, r, x, want;
	char args[256];

	cprintf("init: running\n");
  80006d:	68 a0 25 80 00       	push   $0x8025a0
  800072:	e8 61 04 00 00       	call   8004d8 <cprintf>

	want = 0xf989e;
	if ((x = sum((char*)&data, sizeof data)) != want)
  800077:	83 c4 08             	add    $0x8,%esp
  80007a:	68 70 17 00 00       	push   $0x1770
  80007f:	68 00 30 80 00       	push   $0x803000
  800084:	e8 aa ff ff ff       	call   800033 <sum>
  800089:	83 c4 10             	add    $0x10,%esp
  80008c:	3d 9e 98 0f 00       	cmp    $0xf989e,%eax
  800091:	74 18                	je     8000ab <umain+0x4d>
		cprintf("init: data is not initialized: got sum %08x wanted %08x\n",
  800093:	83 ec 04             	sub    $0x4,%esp
  800096:	68 9e 98 0f 00       	push   $0xf989e
  80009b:	50                   	push   %eax
  80009c:	68 68 26 80 00       	push   $0x802668
  8000a1:	e8 32 04 00 00       	call   8004d8 <cprintf>
  8000a6:	83 c4 10             	add    $0x10,%esp
  8000a9:	eb 10                	jmp    8000bb <umain+0x5d>
			x, want);
	else
		cprintf("init: data seems okay\n");
  8000ab:	83 ec 0c             	sub    $0xc,%esp
  8000ae:	68 af 25 80 00       	push   $0x8025af
  8000b3:	e8 20 04 00 00       	call   8004d8 <cprintf>
  8000b8:	83 c4 10             	add    $0x10,%esp
	if ((x = sum(bss, sizeof bss)) != 0)
  8000bb:	83 ec 08             	sub    $0x8,%esp
  8000be:	68 70 17 00 00       	push   $0x1770
  8000c3:	68 20 50 80 00       	push   $0x805020
  8000c8:	e8 66 ff ff ff       	call   800033 <sum>
  8000cd:	83 c4 10             	add    $0x10,%esp
  8000d0:	85 c0                	test   %eax,%eax
  8000d2:	74 13                	je     8000e7 <umain+0x89>
		cprintf("bss is not initialized: wanted sum 0 got %08x\n", x);
  8000d4:	83 ec 08             	sub    $0x8,%esp
  8000d7:	50                   	push   %eax
  8000d8:	68 a4 26 80 00       	push   $0x8026a4
  8000dd:	e8 f6 03 00 00       	call   8004d8 <cprintf>
  8000e2:	83 c4 10             	add    $0x10,%esp
  8000e5:	eb 10                	jmp    8000f7 <umain+0x99>
	else
		cprintf("init: bss seems okay\n");
  8000e7:	83 ec 0c             	sub    $0xc,%esp
  8000ea:	68 c6 25 80 00       	push   $0x8025c6
  8000ef:	e8 e4 03 00 00       	call   8004d8 <cprintf>
  8000f4:	83 c4 10             	add    $0x10,%esp

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
  8000f7:	83 ec 08             	sub    $0x8,%esp
  8000fa:	68 dc 25 80 00       	push   $0x8025dc
  8000ff:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  800105:	50                   	push   %eax
  800106:	e8 19 0a 00 00       	call   800b24 <strcat>
	for (i = 0; i < argc; i++) {
  80010b:	83 c4 10             	add    $0x10,%esp
  80010e:	bb 00 00 00 00       	mov    $0x0,%ebx
		strcat(args, " '");
  800113:	8d b5 e8 fe ff ff    	lea    -0x118(%ebp),%esi
	else
		cprintf("init: bss seems okay\n");

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
	for (i = 0; i < argc; i++) {
  800119:	eb 2e                	jmp    800149 <umain+0xeb>
		strcat(args, " '");
  80011b:	83 ec 08             	sub    $0x8,%esp
  80011e:	68 e8 25 80 00       	push   $0x8025e8
  800123:	56                   	push   %esi
  800124:	e8 fb 09 00 00       	call   800b24 <strcat>
		strcat(args, argv[i]);
  800129:	83 c4 08             	add    $0x8,%esp
  80012c:	ff 34 9f             	pushl  (%edi,%ebx,4)
  80012f:	56                   	push   %esi
  800130:	e8 ef 09 00 00       	call   800b24 <strcat>
		strcat(args, "'");
  800135:	83 c4 08             	add    $0x8,%esp
  800138:	68 e9 25 80 00       	push   $0x8025e9
  80013d:	56                   	push   %esi
  80013e:	e8 e1 09 00 00       	call   800b24 <strcat>
	else
		cprintf("init: bss seems okay\n");

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
	for (i = 0; i < argc; i++) {
  800143:	83 c3 01             	add    $0x1,%ebx
  800146:	83 c4 10             	add    $0x10,%esp
  800149:	3b 5d 08             	cmp    0x8(%ebp),%ebx
  80014c:	7c cd                	jl     80011b <umain+0xbd>
		strcat(args, " '");
		strcat(args, argv[i]);
		strcat(args, "'");
	}
	cprintf("%s\n", args);
  80014e:	83 ec 08             	sub    $0x8,%esp
  800151:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  800157:	50                   	push   %eax
  800158:	68 eb 25 80 00       	push   $0x8025eb
  80015d:	e8 76 03 00 00       	call   8004d8 <cprintf>

	cprintf("init: running sh\n");
  800162:	c7 04 24 ef 25 80 00 	movl   $0x8025ef,(%esp)
  800169:	e8 6a 03 00 00       	call   8004d8 <cprintf>

	// being run directly from kernel, so no file descriptors open yet
	close(0);
  80016e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800175:	e8 1e 11 00 00       	call   801298 <close>
	if ((r = opencons()) < 0)
  80017a:	e8 c6 01 00 00       	call   800345 <opencons>
  80017f:	83 c4 10             	add    $0x10,%esp
  800182:	85 c0                	test   %eax,%eax
  800184:	79 12                	jns    800198 <umain+0x13a>
		panic("opencons: %e", r);
  800186:	50                   	push   %eax
  800187:	68 01 26 80 00       	push   $0x802601
  80018c:	6a 37                	push   $0x37
  80018e:	68 0e 26 80 00       	push   $0x80260e
  800193:	e8 67 02 00 00       	call   8003ff <_panic>
	if (r != 0)
  800198:	85 c0                	test   %eax,%eax
  80019a:	74 12                	je     8001ae <umain+0x150>
		panic("first opencons used fd %d", r);
  80019c:	50                   	push   %eax
  80019d:	68 1a 26 80 00       	push   $0x80261a
  8001a2:	6a 39                	push   $0x39
  8001a4:	68 0e 26 80 00       	push   $0x80260e
  8001a9:	e8 51 02 00 00       	call   8003ff <_panic>
	if ((r = dup(0, 1)) < 0)
  8001ae:	83 ec 08             	sub    $0x8,%esp
  8001b1:	6a 01                	push   $0x1
  8001b3:	6a 00                	push   $0x0
  8001b5:	e8 2e 11 00 00       	call   8012e8 <dup>
  8001ba:	83 c4 10             	add    $0x10,%esp
  8001bd:	85 c0                	test   %eax,%eax
  8001bf:	79 12                	jns    8001d3 <umain+0x175>
		panic("dup: %e", r);
  8001c1:	50                   	push   %eax
  8001c2:	68 34 26 80 00       	push   $0x802634
  8001c7:	6a 3b                	push   $0x3b
  8001c9:	68 0e 26 80 00       	push   $0x80260e
  8001ce:	e8 2c 02 00 00       	call   8003ff <_panic>
	while (1) {
		cprintf("init: starting sh\n");
  8001d3:	83 ec 0c             	sub    $0xc,%esp
  8001d6:	68 3c 26 80 00       	push   $0x80263c
  8001db:	e8 f8 02 00 00       	call   8004d8 <cprintf>
		r = spawnl("/sh", "sh", (char*)0);
  8001e0:	83 c4 0c             	add    $0xc,%esp
  8001e3:	6a 00                	push   $0x0
  8001e5:	68 50 26 80 00       	push   $0x802650
  8001ea:	68 4f 26 80 00       	push   $0x80264f
  8001ef:	e8 b0 1b 00 00       	call   801da4 <spawnl>
		if (r < 0) {
  8001f4:	83 c4 10             	add    $0x10,%esp
  8001f7:	85 c0                	test   %eax,%eax
  8001f9:	79 13                	jns    80020e <umain+0x1b0>
			cprintf("init: spawn sh: %e\n", r);
  8001fb:	83 ec 08             	sub    $0x8,%esp
  8001fe:	50                   	push   %eax
  8001ff:	68 53 26 80 00       	push   $0x802653
  800204:	e8 cf 02 00 00       	call   8004d8 <cprintf>
			continue;
  800209:	83 c4 10             	add    $0x10,%esp
  80020c:	eb c5                	jmp    8001d3 <umain+0x175>
		}
		wait(r);
  80020e:	83 ec 0c             	sub    $0xc,%esp
  800211:	50                   	push   %eax
  800212:	e8 5c 1f 00 00       	call   802173 <wait>
  800217:	83 c4 10             	add    $0x10,%esp
  80021a:	eb b7                	jmp    8001d3 <umain+0x175>

0080021c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80021f:	b8 00 00 00 00       	mov    $0x0,%eax
  800224:	5d                   	pop    %ebp
  800225:	c3                   	ret    

00800226 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800226:	55                   	push   %ebp
  800227:	89 e5                	mov    %esp,%ebp
  800229:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80022c:	68 d3 26 80 00       	push   $0x8026d3
  800231:	ff 75 0c             	pushl  0xc(%ebp)
  800234:	e8 cb 08 00 00       	call   800b04 <strcpy>
	return 0;
}
  800239:	b8 00 00 00 00       	mov    $0x0,%eax
  80023e:	c9                   	leave  
  80023f:	c3                   	ret    

00800240 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800240:	55                   	push   %ebp
  800241:	89 e5                	mov    %esp,%ebp
  800243:	57                   	push   %edi
  800244:	56                   	push   %esi
  800245:	53                   	push   %ebx
  800246:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80024c:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800251:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800257:	eb 2d                	jmp    800286 <devcons_write+0x46>
		m = n - tot;
  800259:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80025c:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80025e:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800261:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800266:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800269:	83 ec 04             	sub    $0x4,%esp
  80026c:	53                   	push   %ebx
  80026d:	03 45 0c             	add    0xc(%ebp),%eax
  800270:	50                   	push   %eax
  800271:	57                   	push   %edi
  800272:	e8 1f 0a 00 00       	call   800c96 <memmove>
		sys_cputs(buf, m);
  800277:	83 c4 08             	add    $0x8,%esp
  80027a:	53                   	push   %ebx
  80027b:	57                   	push   %edi
  80027c:	e8 ca 0b 00 00       	call   800e4b <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800281:	01 de                	add    %ebx,%esi
  800283:	83 c4 10             	add    $0x10,%esp
  800286:	89 f0                	mov    %esi,%eax
  800288:	3b 75 10             	cmp    0x10(%ebp),%esi
  80028b:	72 cc                	jb     800259 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80028d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800290:	5b                   	pop    %ebx
  800291:	5e                   	pop    %esi
  800292:	5f                   	pop    %edi
  800293:	5d                   	pop    %ebp
  800294:	c3                   	ret    

00800295 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800295:	55                   	push   %ebp
  800296:	89 e5                	mov    %esp,%ebp
  800298:	83 ec 08             	sub    $0x8,%esp
  80029b:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8002a0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8002a4:	74 2a                	je     8002d0 <devcons_read+0x3b>
  8002a6:	eb 05                	jmp    8002ad <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8002a8:	e8 3b 0c 00 00       	call   800ee8 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8002ad:	e8 b7 0b 00 00       	call   800e69 <sys_cgetc>
  8002b2:	85 c0                	test   %eax,%eax
  8002b4:	74 f2                	je     8002a8 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8002b6:	85 c0                	test   %eax,%eax
  8002b8:	78 16                	js     8002d0 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8002ba:	83 f8 04             	cmp    $0x4,%eax
  8002bd:	74 0c                	je     8002cb <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8002bf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002c2:	88 02                	mov    %al,(%edx)
	return 1;
  8002c4:	b8 01 00 00 00       	mov    $0x1,%eax
  8002c9:	eb 05                	jmp    8002d0 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8002cb:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8002d0:	c9                   	leave  
  8002d1:	c3                   	ret    

008002d2 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8002d2:	55                   	push   %ebp
  8002d3:	89 e5                	mov    %esp,%ebp
  8002d5:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8002d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8002db:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8002de:	6a 01                	push   $0x1
  8002e0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8002e3:	50                   	push   %eax
  8002e4:	e8 62 0b 00 00       	call   800e4b <sys_cputs>
}
  8002e9:	83 c4 10             	add    $0x10,%esp
  8002ec:	c9                   	leave  
  8002ed:	c3                   	ret    

008002ee <getchar>:

int
getchar(void)
{
  8002ee:	55                   	push   %ebp
  8002ef:	89 e5                	mov    %esp,%ebp
  8002f1:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8002f4:	6a 01                	push   $0x1
  8002f6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8002f9:	50                   	push   %eax
  8002fa:	6a 00                	push   $0x0
  8002fc:	e8 d3 10 00 00       	call   8013d4 <read>
	if (r < 0)
  800301:	83 c4 10             	add    $0x10,%esp
  800304:	85 c0                	test   %eax,%eax
  800306:	78 0f                	js     800317 <getchar+0x29>
		return r;
	if (r < 1)
  800308:	85 c0                	test   %eax,%eax
  80030a:	7e 06                	jle    800312 <getchar+0x24>
		return -E_EOF;
	return c;
  80030c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800310:	eb 05                	jmp    800317 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800312:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800317:	c9                   	leave  
  800318:	c3                   	ret    

00800319 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800319:	55                   	push   %ebp
  80031a:	89 e5                	mov    %esp,%ebp
  80031c:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80031f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800322:	50                   	push   %eax
  800323:	ff 75 08             	pushl  0x8(%ebp)
  800326:	e8 43 0e 00 00       	call   80116e <fd_lookup>
  80032b:	83 c4 10             	add    $0x10,%esp
  80032e:	85 c0                	test   %eax,%eax
  800330:	78 11                	js     800343 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800332:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800335:	8b 15 70 47 80 00    	mov    0x804770,%edx
  80033b:	39 10                	cmp    %edx,(%eax)
  80033d:	0f 94 c0             	sete   %al
  800340:	0f b6 c0             	movzbl %al,%eax
}
  800343:	c9                   	leave  
  800344:	c3                   	ret    

00800345 <opencons>:

int
opencons(void)
{
  800345:	55                   	push   %ebp
  800346:	89 e5                	mov    %esp,%ebp
  800348:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80034b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80034e:	50                   	push   %eax
  80034f:	e8 cb 0d 00 00       	call   80111f <fd_alloc>
  800354:	83 c4 10             	add    $0x10,%esp
		return r;
  800357:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800359:	85 c0                	test   %eax,%eax
  80035b:	78 3e                	js     80039b <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80035d:	83 ec 04             	sub    $0x4,%esp
  800360:	68 07 04 00 00       	push   $0x407
  800365:	ff 75 f4             	pushl  -0xc(%ebp)
  800368:	6a 00                	push   $0x0
  80036a:	e8 98 0b 00 00       	call   800f07 <sys_page_alloc>
  80036f:	83 c4 10             	add    $0x10,%esp
		return r;
  800372:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800374:	85 c0                	test   %eax,%eax
  800376:	78 23                	js     80039b <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800378:	8b 15 70 47 80 00    	mov    0x804770,%edx
  80037e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800381:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800383:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800386:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80038d:	83 ec 0c             	sub    $0xc,%esp
  800390:	50                   	push   %eax
  800391:	e8 62 0d 00 00       	call   8010f8 <fd2num>
  800396:	89 c2                	mov    %eax,%edx
  800398:	83 c4 10             	add    $0x10,%esp
}
  80039b:	89 d0                	mov    %edx,%eax
  80039d:	c9                   	leave  
  80039e:	c3                   	ret    

0080039f <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80039f:	55                   	push   %ebp
  8003a0:	89 e5                	mov    %esp,%ebp
  8003a2:	56                   	push   %esi
  8003a3:	53                   	push   %ebx
  8003a4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8003a7:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	envid_t envid = sys_getenvid();
  8003aa:	e8 1a 0b 00 00       	call   800ec9 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8003af:	25 ff 03 00 00       	and    $0x3ff,%eax
  8003b4:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8003b7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8003bc:	a3 90 67 80 00       	mov    %eax,0x806790

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8003c1:	85 db                	test   %ebx,%ebx
  8003c3:	7e 07                	jle    8003cc <libmain+0x2d>
		binaryname = argv[0];
  8003c5:	8b 06                	mov    (%esi),%eax
  8003c7:	a3 8c 47 80 00       	mov    %eax,0x80478c

	// call user main routine
	umain(argc, argv);
  8003cc:	83 ec 08             	sub    $0x8,%esp
  8003cf:	56                   	push   %esi
  8003d0:	53                   	push   %ebx
  8003d1:	e8 88 fc ff ff       	call   80005e <umain>

	// exit gracefully
	exit();
  8003d6:	e8 0a 00 00 00       	call   8003e5 <exit>
}
  8003db:	83 c4 10             	add    $0x10,%esp
  8003de:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8003e1:	5b                   	pop    %ebx
  8003e2:	5e                   	pop    %esi
  8003e3:	5d                   	pop    %ebp
  8003e4:	c3                   	ret    

008003e5 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8003e5:	55                   	push   %ebp
  8003e6:	89 e5                	mov    %esp,%ebp
  8003e8:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8003eb:	e8 d3 0e 00 00       	call   8012c3 <close_all>
	sys_env_destroy(0);
  8003f0:	83 ec 0c             	sub    $0xc,%esp
  8003f3:	6a 00                	push   $0x0
  8003f5:	e8 8e 0a 00 00       	call   800e88 <sys_env_destroy>
}
  8003fa:	83 c4 10             	add    $0x10,%esp
  8003fd:	c9                   	leave  
  8003fe:	c3                   	ret    

008003ff <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8003ff:	55                   	push   %ebp
  800400:	89 e5                	mov    %esp,%ebp
  800402:	56                   	push   %esi
  800403:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800404:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800407:	8b 35 8c 47 80 00    	mov    0x80478c,%esi
  80040d:	e8 b7 0a 00 00       	call   800ec9 <sys_getenvid>
  800412:	83 ec 0c             	sub    $0xc,%esp
  800415:	ff 75 0c             	pushl  0xc(%ebp)
  800418:	ff 75 08             	pushl  0x8(%ebp)
  80041b:	56                   	push   %esi
  80041c:	50                   	push   %eax
  80041d:	68 ec 26 80 00       	push   $0x8026ec
  800422:	e8 b1 00 00 00       	call   8004d8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800427:	83 c4 18             	add    $0x18,%esp
  80042a:	53                   	push   %ebx
  80042b:	ff 75 10             	pushl  0x10(%ebp)
  80042e:	e8 54 00 00 00       	call   800487 <vcprintf>
	cprintf("\n");
  800433:	c7 04 24 e0 2b 80 00 	movl   $0x802be0,(%esp)
  80043a:	e8 99 00 00 00       	call   8004d8 <cprintf>
  80043f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800442:	cc                   	int3   
  800443:	eb fd                	jmp    800442 <_panic+0x43>

00800445 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800445:	55                   	push   %ebp
  800446:	89 e5                	mov    %esp,%ebp
  800448:	53                   	push   %ebx
  800449:	83 ec 04             	sub    $0x4,%esp
  80044c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80044f:	8b 13                	mov    (%ebx),%edx
  800451:	8d 42 01             	lea    0x1(%edx),%eax
  800454:	89 03                	mov    %eax,(%ebx)
  800456:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800459:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80045d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800462:	75 1a                	jne    80047e <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800464:	83 ec 08             	sub    $0x8,%esp
  800467:	68 ff 00 00 00       	push   $0xff
  80046c:	8d 43 08             	lea    0x8(%ebx),%eax
  80046f:	50                   	push   %eax
  800470:	e8 d6 09 00 00       	call   800e4b <sys_cputs>
		b->idx = 0;
  800475:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80047b:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80047e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800482:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800485:	c9                   	leave  
  800486:	c3                   	ret    

00800487 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800487:	55                   	push   %ebp
  800488:	89 e5                	mov    %esp,%ebp
  80048a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800490:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800497:	00 00 00 
	b.cnt = 0;
  80049a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8004a1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8004a4:	ff 75 0c             	pushl  0xc(%ebp)
  8004a7:	ff 75 08             	pushl  0x8(%ebp)
  8004aa:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8004b0:	50                   	push   %eax
  8004b1:	68 45 04 80 00       	push   $0x800445
  8004b6:	e8 1a 01 00 00       	call   8005d5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8004bb:	83 c4 08             	add    $0x8,%esp
  8004be:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8004c4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8004ca:	50                   	push   %eax
  8004cb:	e8 7b 09 00 00       	call   800e4b <sys_cputs>

	return b.cnt;
}
  8004d0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8004d6:	c9                   	leave  
  8004d7:	c3                   	ret    

008004d8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8004d8:	55                   	push   %ebp
  8004d9:	89 e5                	mov    %esp,%ebp
  8004db:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8004de:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8004e1:	50                   	push   %eax
  8004e2:	ff 75 08             	pushl  0x8(%ebp)
  8004e5:	e8 9d ff ff ff       	call   800487 <vcprintf>
	va_end(ap);

	return cnt;
}
  8004ea:	c9                   	leave  
  8004eb:	c3                   	ret    

008004ec <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8004ec:	55                   	push   %ebp
  8004ed:	89 e5                	mov    %esp,%ebp
  8004ef:	57                   	push   %edi
  8004f0:	56                   	push   %esi
  8004f1:	53                   	push   %ebx
  8004f2:	83 ec 1c             	sub    $0x1c,%esp
  8004f5:	89 c7                	mov    %eax,%edi
  8004f7:	89 d6                	mov    %edx,%esi
  8004f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8004fc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004ff:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800502:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800505:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800508:	bb 00 00 00 00       	mov    $0x0,%ebx
  80050d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800510:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800513:	39 d3                	cmp    %edx,%ebx
  800515:	72 05                	jb     80051c <printnum+0x30>
  800517:	39 45 10             	cmp    %eax,0x10(%ebp)
  80051a:	77 45                	ja     800561 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80051c:	83 ec 0c             	sub    $0xc,%esp
  80051f:	ff 75 18             	pushl  0x18(%ebp)
  800522:	8b 45 14             	mov    0x14(%ebp),%eax
  800525:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800528:	53                   	push   %ebx
  800529:	ff 75 10             	pushl  0x10(%ebp)
  80052c:	83 ec 08             	sub    $0x8,%esp
  80052f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800532:	ff 75 e0             	pushl  -0x20(%ebp)
  800535:	ff 75 dc             	pushl  -0x24(%ebp)
  800538:	ff 75 d8             	pushl  -0x28(%ebp)
  80053b:	e8 c0 1d 00 00       	call   802300 <__udivdi3>
  800540:	83 c4 18             	add    $0x18,%esp
  800543:	52                   	push   %edx
  800544:	50                   	push   %eax
  800545:	89 f2                	mov    %esi,%edx
  800547:	89 f8                	mov    %edi,%eax
  800549:	e8 9e ff ff ff       	call   8004ec <printnum>
  80054e:	83 c4 20             	add    $0x20,%esp
  800551:	eb 18                	jmp    80056b <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800553:	83 ec 08             	sub    $0x8,%esp
  800556:	56                   	push   %esi
  800557:	ff 75 18             	pushl  0x18(%ebp)
  80055a:	ff d7                	call   *%edi
  80055c:	83 c4 10             	add    $0x10,%esp
  80055f:	eb 03                	jmp    800564 <printnum+0x78>
  800561:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800564:	83 eb 01             	sub    $0x1,%ebx
  800567:	85 db                	test   %ebx,%ebx
  800569:	7f e8                	jg     800553 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80056b:	83 ec 08             	sub    $0x8,%esp
  80056e:	56                   	push   %esi
  80056f:	83 ec 04             	sub    $0x4,%esp
  800572:	ff 75 e4             	pushl  -0x1c(%ebp)
  800575:	ff 75 e0             	pushl  -0x20(%ebp)
  800578:	ff 75 dc             	pushl  -0x24(%ebp)
  80057b:	ff 75 d8             	pushl  -0x28(%ebp)
  80057e:	e8 ad 1e 00 00       	call   802430 <__umoddi3>
  800583:	83 c4 14             	add    $0x14,%esp
  800586:	0f be 80 0f 27 80 00 	movsbl 0x80270f(%eax),%eax
  80058d:	50                   	push   %eax
  80058e:	ff d7                	call   *%edi
}
  800590:	83 c4 10             	add    $0x10,%esp
  800593:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800596:	5b                   	pop    %ebx
  800597:	5e                   	pop    %esi
  800598:	5f                   	pop    %edi
  800599:	5d                   	pop    %ebp
  80059a:	c3                   	ret    

0080059b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80059b:	55                   	push   %ebp
  80059c:	89 e5                	mov    %esp,%ebp
  80059e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8005a1:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8005a5:	8b 10                	mov    (%eax),%edx
  8005a7:	3b 50 04             	cmp    0x4(%eax),%edx
  8005aa:	73 0a                	jae    8005b6 <sprintputch+0x1b>
		*b->buf++ = ch;
  8005ac:	8d 4a 01             	lea    0x1(%edx),%ecx
  8005af:	89 08                	mov    %ecx,(%eax)
  8005b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8005b4:	88 02                	mov    %al,(%edx)
}
  8005b6:	5d                   	pop    %ebp
  8005b7:	c3                   	ret    

008005b8 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8005b8:	55                   	push   %ebp
  8005b9:	89 e5                	mov    %esp,%ebp
  8005bb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8005be:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8005c1:	50                   	push   %eax
  8005c2:	ff 75 10             	pushl  0x10(%ebp)
  8005c5:	ff 75 0c             	pushl  0xc(%ebp)
  8005c8:	ff 75 08             	pushl  0x8(%ebp)
  8005cb:	e8 05 00 00 00       	call   8005d5 <vprintfmt>
	va_end(ap);
}
  8005d0:	83 c4 10             	add    $0x10,%esp
  8005d3:	c9                   	leave  
  8005d4:	c3                   	ret    

008005d5 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8005d5:	55                   	push   %ebp
  8005d6:	89 e5                	mov    %esp,%ebp
  8005d8:	57                   	push   %edi
  8005d9:	56                   	push   %esi
  8005da:	53                   	push   %ebx
  8005db:	83 ec 2c             	sub    $0x2c,%esp
  8005de:	8b 75 08             	mov    0x8(%ebp),%esi
  8005e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005e4:	8b 7d 10             	mov    0x10(%ebp),%edi
  8005e7:	eb 12                	jmp    8005fb <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8005e9:	85 c0                	test   %eax,%eax
  8005eb:	0f 84 6a 04 00 00    	je     800a5b <vprintfmt+0x486>
				return;
			putch(ch, putdat);
  8005f1:	83 ec 08             	sub    $0x8,%esp
  8005f4:	53                   	push   %ebx
  8005f5:	50                   	push   %eax
  8005f6:	ff d6                	call   *%esi
  8005f8:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005fb:	83 c7 01             	add    $0x1,%edi
  8005fe:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800602:	83 f8 25             	cmp    $0x25,%eax
  800605:	75 e2                	jne    8005e9 <vprintfmt+0x14>
  800607:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80060b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800612:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800619:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800620:	b9 00 00 00 00       	mov    $0x0,%ecx
  800625:	eb 07                	jmp    80062e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800627:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80062a:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80062e:	8d 47 01             	lea    0x1(%edi),%eax
  800631:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800634:	0f b6 07             	movzbl (%edi),%eax
  800637:	0f b6 d0             	movzbl %al,%edx
  80063a:	83 e8 23             	sub    $0x23,%eax
  80063d:	3c 55                	cmp    $0x55,%al
  80063f:	0f 87 fb 03 00 00    	ja     800a40 <vprintfmt+0x46b>
  800645:	0f b6 c0             	movzbl %al,%eax
  800648:	ff 24 85 60 28 80 00 	jmp    *0x802860(,%eax,4)
  80064f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800652:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800656:	eb d6                	jmp    80062e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800658:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80065b:	b8 00 00 00 00       	mov    $0x0,%eax
  800660:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800663:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800666:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80066a:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80066d:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800670:	83 f9 09             	cmp    $0x9,%ecx
  800673:	77 3f                	ja     8006b4 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800675:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800678:	eb e9                	jmp    800663 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80067a:	8b 45 14             	mov    0x14(%ebp),%eax
  80067d:	8b 00                	mov    (%eax),%eax
  80067f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800682:	8b 45 14             	mov    0x14(%ebp),%eax
  800685:	8d 40 04             	lea    0x4(%eax),%eax
  800688:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80068b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80068e:	eb 2a                	jmp    8006ba <vprintfmt+0xe5>
  800690:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800693:	85 c0                	test   %eax,%eax
  800695:	ba 00 00 00 00       	mov    $0x0,%edx
  80069a:	0f 49 d0             	cmovns %eax,%edx
  80069d:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006a3:	eb 89                	jmp    80062e <vprintfmt+0x59>
  8006a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8006a8:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8006af:	e9 7a ff ff ff       	jmp    80062e <vprintfmt+0x59>
  8006b4:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8006b7:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8006ba:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006be:	0f 89 6a ff ff ff    	jns    80062e <vprintfmt+0x59>
				width = precision, precision = -1;
  8006c4:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8006c7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006ca:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8006d1:	e9 58 ff ff ff       	jmp    80062e <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8006d6:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8006dc:	e9 4d ff ff ff       	jmp    80062e <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8006e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e4:	8d 78 04             	lea    0x4(%eax),%edi
  8006e7:	83 ec 08             	sub    $0x8,%esp
  8006ea:	53                   	push   %ebx
  8006eb:	ff 30                	pushl  (%eax)
  8006ed:	ff d6                	call   *%esi
			break;
  8006ef:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8006f2:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8006f8:	e9 fe fe ff ff       	jmp    8005fb <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8006fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800700:	8d 78 04             	lea    0x4(%eax),%edi
  800703:	8b 00                	mov    (%eax),%eax
  800705:	99                   	cltd   
  800706:	31 d0                	xor    %edx,%eax
  800708:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80070a:	83 f8 0f             	cmp    $0xf,%eax
  80070d:	7f 0b                	jg     80071a <vprintfmt+0x145>
  80070f:	8b 14 85 c0 29 80 00 	mov    0x8029c0(,%eax,4),%edx
  800716:	85 d2                	test   %edx,%edx
  800718:	75 1b                	jne    800735 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  80071a:	50                   	push   %eax
  80071b:	68 27 27 80 00       	push   $0x802727
  800720:	53                   	push   %ebx
  800721:	56                   	push   %esi
  800722:	e8 91 fe ff ff       	call   8005b8 <printfmt>
  800727:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80072a:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80072d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800730:	e9 c6 fe ff ff       	jmp    8005fb <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800735:	52                   	push   %edx
  800736:	68 1a 2b 80 00       	push   $0x802b1a
  80073b:	53                   	push   %ebx
  80073c:	56                   	push   %esi
  80073d:	e8 76 fe ff ff       	call   8005b8 <printfmt>
  800742:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800745:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800748:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80074b:	e9 ab fe ff ff       	jmp    8005fb <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800750:	8b 45 14             	mov    0x14(%ebp),%eax
  800753:	83 c0 04             	add    $0x4,%eax
  800756:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800759:	8b 45 14             	mov    0x14(%ebp),%eax
  80075c:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80075e:	85 ff                	test   %edi,%edi
  800760:	b8 20 27 80 00       	mov    $0x802720,%eax
  800765:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800768:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80076c:	0f 8e 94 00 00 00    	jle    800806 <vprintfmt+0x231>
  800772:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800776:	0f 84 98 00 00 00    	je     800814 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  80077c:	83 ec 08             	sub    $0x8,%esp
  80077f:	ff 75 d0             	pushl  -0x30(%ebp)
  800782:	57                   	push   %edi
  800783:	e8 5b 03 00 00       	call   800ae3 <strnlen>
  800788:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80078b:	29 c1                	sub    %eax,%ecx
  80078d:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800790:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800793:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800797:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80079a:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80079d:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80079f:	eb 0f                	jmp    8007b0 <vprintfmt+0x1db>
					putch(padc, putdat);
  8007a1:	83 ec 08             	sub    $0x8,%esp
  8007a4:	53                   	push   %ebx
  8007a5:	ff 75 e0             	pushl  -0x20(%ebp)
  8007a8:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007aa:	83 ef 01             	sub    $0x1,%edi
  8007ad:	83 c4 10             	add    $0x10,%esp
  8007b0:	85 ff                	test   %edi,%edi
  8007b2:	7f ed                	jg     8007a1 <vprintfmt+0x1cc>
  8007b4:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8007b7:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8007ba:	85 c9                	test   %ecx,%ecx
  8007bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c1:	0f 49 c1             	cmovns %ecx,%eax
  8007c4:	29 c1                	sub    %eax,%ecx
  8007c6:	89 75 08             	mov    %esi,0x8(%ebp)
  8007c9:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8007cc:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8007cf:	89 cb                	mov    %ecx,%ebx
  8007d1:	eb 4d                	jmp    800820 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8007d3:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8007d7:	74 1b                	je     8007f4 <vprintfmt+0x21f>
  8007d9:	0f be c0             	movsbl %al,%eax
  8007dc:	83 e8 20             	sub    $0x20,%eax
  8007df:	83 f8 5e             	cmp    $0x5e,%eax
  8007e2:	76 10                	jbe    8007f4 <vprintfmt+0x21f>
					putch('?', putdat);
  8007e4:	83 ec 08             	sub    $0x8,%esp
  8007e7:	ff 75 0c             	pushl  0xc(%ebp)
  8007ea:	6a 3f                	push   $0x3f
  8007ec:	ff 55 08             	call   *0x8(%ebp)
  8007ef:	83 c4 10             	add    $0x10,%esp
  8007f2:	eb 0d                	jmp    800801 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  8007f4:	83 ec 08             	sub    $0x8,%esp
  8007f7:	ff 75 0c             	pushl  0xc(%ebp)
  8007fa:	52                   	push   %edx
  8007fb:	ff 55 08             	call   *0x8(%ebp)
  8007fe:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800801:	83 eb 01             	sub    $0x1,%ebx
  800804:	eb 1a                	jmp    800820 <vprintfmt+0x24b>
  800806:	89 75 08             	mov    %esi,0x8(%ebp)
  800809:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80080c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80080f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800812:	eb 0c                	jmp    800820 <vprintfmt+0x24b>
  800814:	89 75 08             	mov    %esi,0x8(%ebp)
  800817:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80081a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80081d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800820:	83 c7 01             	add    $0x1,%edi
  800823:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800827:	0f be d0             	movsbl %al,%edx
  80082a:	85 d2                	test   %edx,%edx
  80082c:	74 23                	je     800851 <vprintfmt+0x27c>
  80082e:	85 f6                	test   %esi,%esi
  800830:	78 a1                	js     8007d3 <vprintfmt+0x1fe>
  800832:	83 ee 01             	sub    $0x1,%esi
  800835:	79 9c                	jns    8007d3 <vprintfmt+0x1fe>
  800837:	89 df                	mov    %ebx,%edi
  800839:	8b 75 08             	mov    0x8(%ebp),%esi
  80083c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80083f:	eb 18                	jmp    800859 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800841:	83 ec 08             	sub    $0x8,%esp
  800844:	53                   	push   %ebx
  800845:	6a 20                	push   $0x20
  800847:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800849:	83 ef 01             	sub    $0x1,%edi
  80084c:	83 c4 10             	add    $0x10,%esp
  80084f:	eb 08                	jmp    800859 <vprintfmt+0x284>
  800851:	89 df                	mov    %ebx,%edi
  800853:	8b 75 08             	mov    0x8(%ebp),%esi
  800856:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800859:	85 ff                	test   %edi,%edi
  80085b:	7f e4                	jg     800841 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80085d:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800860:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800863:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800866:	e9 90 fd ff ff       	jmp    8005fb <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80086b:	83 f9 01             	cmp    $0x1,%ecx
  80086e:	7e 19                	jle    800889 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800870:	8b 45 14             	mov    0x14(%ebp),%eax
  800873:	8b 50 04             	mov    0x4(%eax),%edx
  800876:	8b 00                	mov    (%eax),%eax
  800878:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80087b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80087e:	8b 45 14             	mov    0x14(%ebp),%eax
  800881:	8d 40 08             	lea    0x8(%eax),%eax
  800884:	89 45 14             	mov    %eax,0x14(%ebp)
  800887:	eb 38                	jmp    8008c1 <vprintfmt+0x2ec>
	else if (lflag)
  800889:	85 c9                	test   %ecx,%ecx
  80088b:	74 1b                	je     8008a8 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  80088d:	8b 45 14             	mov    0x14(%ebp),%eax
  800890:	8b 00                	mov    (%eax),%eax
  800892:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800895:	89 c1                	mov    %eax,%ecx
  800897:	c1 f9 1f             	sar    $0x1f,%ecx
  80089a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80089d:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a0:	8d 40 04             	lea    0x4(%eax),%eax
  8008a3:	89 45 14             	mov    %eax,0x14(%ebp)
  8008a6:	eb 19                	jmp    8008c1 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8008a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ab:	8b 00                	mov    (%eax),%eax
  8008ad:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008b0:	89 c1                	mov    %eax,%ecx
  8008b2:	c1 f9 1f             	sar    $0x1f,%ecx
  8008b5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8008b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8008bb:	8d 40 04             	lea    0x4(%eax),%eax
  8008be:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8008c1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8008c4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8008c7:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8008cc:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8008d0:	0f 89 36 01 00 00    	jns    800a0c <vprintfmt+0x437>
				putch('-', putdat);
  8008d6:	83 ec 08             	sub    $0x8,%esp
  8008d9:	53                   	push   %ebx
  8008da:	6a 2d                	push   $0x2d
  8008dc:	ff d6                	call   *%esi
				num = -(long long) num;
  8008de:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8008e1:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8008e4:	f7 da                	neg    %edx
  8008e6:	83 d1 00             	adc    $0x0,%ecx
  8008e9:	f7 d9                	neg    %ecx
  8008eb:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8008ee:	b8 0a 00 00 00       	mov    $0xa,%eax
  8008f3:	e9 14 01 00 00       	jmp    800a0c <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8008f8:	83 f9 01             	cmp    $0x1,%ecx
  8008fb:	7e 18                	jle    800915 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  8008fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800900:	8b 10                	mov    (%eax),%edx
  800902:	8b 48 04             	mov    0x4(%eax),%ecx
  800905:	8d 40 08             	lea    0x8(%eax),%eax
  800908:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80090b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800910:	e9 f7 00 00 00       	jmp    800a0c <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800915:	85 c9                	test   %ecx,%ecx
  800917:	74 1a                	je     800933 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  800919:	8b 45 14             	mov    0x14(%ebp),%eax
  80091c:	8b 10                	mov    (%eax),%edx
  80091e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800923:	8d 40 04             	lea    0x4(%eax),%eax
  800926:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800929:	b8 0a 00 00 00       	mov    $0xa,%eax
  80092e:	e9 d9 00 00 00       	jmp    800a0c <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800933:	8b 45 14             	mov    0x14(%ebp),%eax
  800936:	8b 10                	mov    (%eax),%edx
  800938:	b9 00 00 00 00       	mov    $0x0,%ecx
  80093d:	8d 40 04             	lea    0x4(%eax),%eax
  800940:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800943:	b8 0a 00 00 00       	mov    $0xa,%eax
  800948:	e9 bf 00 00 00       	jmp    800a0c <vprintfmt+0x437>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80094d:	83 f9 01             	cmp    $0x1,%ecx
  800950:	7e 13                	jle    800965 <vprintfmt+0x390>
		return va_arg(*ap, long long);
  800952:	8b 45 14             	mov    0x14(%ebp),%eax
  800955:	8b 50 04             	mov    0x4(%eax),%edx
  800958:	8b 00                	mov    (%eax),%eax
  80095a:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80095d:	8d 49 08             	lea    0x8(%ecx),%ecx
  800960:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800963:	eb 28                	jmp    80098d <vprintfmt+0x3b8>
	else if (lflag)
  800965:	85 c9                	test   %ecx,%ecx
  800967:	74 13                	je     80097c <vprintfmt+0x3a7>
		return va_arg(*ap, long);
  800969:	8b 45 14             	mov    0x14(%ebp),%eax
  80096c:	8b 10                	mov    (%eax),%edx
  80096e:	89 d0                	mov    %edx,%eax
  800970:	99                   	cltd   
  800971:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800974:	8d 49 04             	lea    0x4(%ecx),%ecx
  800977:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80097a:	eb 11                	jmp    80098d <vprintfmt+0x3b8>
	else
		return va_arg(*ap, int);
  80097c:	8b 45 14             	mov    0x14(%ebp),%eax
  80097f:	8b 10                	mov    (%eax),%edx
  800981:	89 d0                	mov    %edx,%eax
  800983:	99                   	cltd   
  800984:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800987:	8d 49 04             	lea    0x4(%ecx),%ecx
  80098a:	89 4d 14             	mov    %ecx,0x14(%ebp)
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getint(&ap, lflag);
  80098d:	89 d1                	mov    %edx,%ecx
  80098f:	89 c2                	mov    %eax,%edx
			base = 8;
  800991:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800996:	eb 74                	jmp    800a0c <vprintfmt+0x437>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800998:	83 ec 08             	sub    $0x8,%esp
  80099b:	53                   	push   %ebx
  80099c:	6a 30                	push   $0x30
  80099e:	ff d6                	call   *%esi
			putch('x', putdat);
  8009a0:	83 c4 08             	add    $0x8,%esp
  8009a3:	53                   	push   %ebx
  8009a4:	6a 78                	push   $0x78
  8009a6:	ff d6                	call   *%esi
			num = (unsigned long long)
  8009a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8009ab:	8b 10                	mov    (%eax),%edx
  8009ad:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8009b2:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8009b5:	8d 40 04             	lea    0x4(%eax),%eax
  8009b8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8009bb:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8009c0:	eb 4a                	jmp    800a0c <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8009c2:	83 f9 01             	cmp    $0x1,%ecx
  8009c5:	7e 15                	jle    8009dc <vprintfmt+0x407>
		return va_arg(*ap, unsigned long long);
  8009c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8009ca:	8b 10                	mov    (%eax),%edx
  8009cc:	8b 48 04             	mov    0x4(%eax),%ecx
  8009cf:	8d 40 08             	lea    0x8(%eax),%eax
  8009d2:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8009d5:	b8 10 00 00 00       	mov    $0x10,%eax
  8009da:	eb 30                	jmp    800a0c <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8009dc:	85 c9                	test   %ecx,%ecx
  8009de:	74 17                	je     8009f7 <vprintfmt+0x422>
		return va_arg(*ap, unsigned long);
  8009e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8009e3:	8b 10                	mov    (%eax),%edx
  8009e5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009ea:	8d 40 04             	lea    0x4(%eax),%eax
  8009ed:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8009f0:	b8 10 00 00 00       	mov    $0x10,%eax
  8009f5:	eb 15                	jmp    800a0c <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8009f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8009fa:	8b 10                	mov    (%eax),%edx
  8009fc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a01:	8d 40 04             	lea    0x4(%eax),%eax
  800a04:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800a07:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a0c:	83 ec 0c             	sub    $0xc,%esp
  800a0f:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800a13:	57                   	push   %edi
  800a14:	ff 75 e0             	pushl  -0x20(%ebp)
  800a17:	50                   	push   %eax
  800a18:	51                   	push   %ecx
  800a19:	52                   	push   %edx
  800a1a:	89 da                	mov    %ebx,%edx
  800a1c:	89 f0                	mov    %esi,%eax
  800a1e:	e8 c9 fa ff ff       	call   8004ec <printnum>
			break;
  800a23:	83 c4 20             	add    $0x20,%esp
  800a26:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a29:	e9 cd fb ff ff       	jmp    8005fb <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a2e:	83 ec 08             	sub    $0x8,%esp
  800a31:	53                   	push   %ebx
  800a32:	52                   	push   %edx
  800a33:	ff d6                	call   *%esi
			break;
  800a35:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a38:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800a3b:	e9 bb fb ff ff       	jmp    8005fb <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a40:	83 ec 08             	sub    $0x8,%esp
  800a43:	53                   	push   %ebx
  800a44:	6a 25                	push   $0x25
  800a46:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a48:	83 c4 10             	add    $0x10,%esp
  800a4b:	eb 03                	jmp    800a50 <vprintfmt+0x47b>
  800a4d:	83 ef 01             	sub    $0x1,%edi
  800a50:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800a54:	75 f7                	jne    800a4d <vprintfmt+0x478>
  800a56:	e9 a0 fb ff ff       	jmp    8005fb <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800a5b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a5e:	5b                   	pop    %ebx
  800a5f:	5e                   	pop    %esi
  800a60:	5f                   	pop    %edi
  800a61:	5d                   	pop    %ebp
  800a62:	c3                   	ret    

00800a63 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a63:	55                   	push   %ebp
  800a64:	89 e5                	mov    %esp,%ebp
  800a66:	83 ec 18             	sub    $0x18,%esp
  800a69:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a6f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a72:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800a76:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800a79:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800a80:	85 c0                	test   %eax,%eax
  800a82:	74 26                	je     800aaa <vsnprintf+0x47>
  800a84:	85 d2                	test   %edx,%edx
  800a86:	7e 22                	jle    800aaa <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a88:	ff 75 14             	pushl  0x14(%ebp)
  800a8b:	ff 75 10             	pushl  0x10(%ebp)
  800a8e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a91:	50                   	push   %eax
  800a92:	68 9b 05 80 00       	push   $0x80059b
  800a97:	e8 39 fb ff ff       	call   8005d5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a9c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a9f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800aa2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800aa5:	83 c4 10             	add    $0x10,%esp
  800aa8:	eb 05                	jmp    800aaf <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800aaa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800aaf:	c9                   	leave  
  800ab0:	c3                   	ret    

00800ab1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800ab1:	55                   	push   %ebp
  800ab2:	89 e5                	mov    %esp,%ebp
  800ab4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800ab7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800aba:	50                   	push   %eax
  800abb:	ff 75 10             	pushl  0x10(%ebp)
  800abe:	ff 75 0c             	pushl  0xc(%ebp)
  800ac1:	ff 75 08             	pushl  0x8(%ebp)
  800ac4:	e8 9a ff ff ff       	call   800a63 <vsnprintf>
	va_end(ap);

	return rc;
}
  800ac9:	c9                   	leave  
  800aca:	c3                   	ret    

00800acb <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800acb:	55                   	push   %ebp
  800acc:	89 e5                	mov    %esp,%ebp
  800ace:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800ad1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad6:	eb 03                	jmp    800adb <strlen+0x10>
		n++;
  800ad8:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800adb:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800adf:	75 f7                	jne    800ad8 <strlen+0xd>
		n++;
	return n;
}
  800ae1:	5d                   	pop    %ebp
  800ae2:	c3                   	ret    

00800ae3 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800ae3:	55                   	push   %ebp
  800ae4:	89 e5                	mov    %esp,%ebp
  800ae6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ae9:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800aec:	ba 00 00 00 00       	mov    $0x0,%edx
  800af1:	eb 03                	jmp    800af6 <strnlen+0x13>
		n++;
  800af3:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800af6:	39 c2                	cmp    %eax,%edx
  800af8:	74 08                	je     800b02 <strnlen+0x1f>
  800afa:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800afe:	75 f3                	jne    800af3 <strnlen+0x10>
  800b00:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800b02:	5d                   	pop    %ebp
  800b03:	c3                   	ret    

00800b04 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b04:	55                   	push   %ebp
  800b05:	89 e5                	mov    %esp,%ebp
  800b07:	53                   	push   %ebx
  800b08:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b0e:	89 c2                	mov    %eax,%edx
  800b10:	83 c2 01             	add    $0x1,%edx
  800b13:	83 c1 01             	add    $0x1,%ecx
  800b16:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800b1a:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b1d:	84 db                	test   %bl,%bl
  800b1f:	75 ef                	jne    800b10 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800b21:	5b                   	pop    %ebx
  800b22:	5d                   	pop    %ebp
  800b23:	c3                   	ret    

00800b24 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b24:	55                   	push   %ebp
  800b25:	89 e5                	mov    %esp,%ebp
  800b27:	53                   	push   %ebx
  800b28:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b2b:	53                   	push   %ebx
  800b2c:	e8 9a ff ff ff       	call   800acb <strlen>
  800b31:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800b34:	ff 75 0c             	pushl  0xc(%ebp)
  800b37:	01 d8                	add    %ebx,%eax
  800b39:	50                   	push   %eax
  800b3a:	e8 c5 ff ff ff       	call   800b04 <strcpy>
	return dst;
}
  800b3f:	89 d8                	mov    %ebx,%eax
  800b41:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b44:	c9                   	leave  
  800b45:	c3                   	ret    

00800b46 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b46:	55                   	push   %ebp
  800b47:	89 e5                	mov    %esp,%ebp
  800b49:	56                   	push   %esi
  800b4a:	53                   	push   %ebx
  800b4b:	8b 75 08             	mov    0x8(%ebp),%esi
  800b4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b51:	89 f3                	mov    %esi,%ebx
  800b53:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b56:	89 f2                	mov    %esi,%edx
  800b58:	eb 0f                	jmp    800b69 <strncpy+0x23>
		*dst++ = *src;
  800b5a:	83 c2 01             	add    $0x1,%edx
  800b5d:	0f b6 01             	movzbl (%ecx),%eax
  800b60:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b63:	80 39 01             	cmpb   $0x1,(%ecx)
  800b66:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b69:	39 da                	cmp    %ebx,%edx
  800b6b:	75 ed                	jne    800b5a <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b6d:	89 f0                	mov    %esi,%eax
  800b6f:	5b                   	pop    %ebx
  800b70:	5e                   	pop    %esi
  800b71:	5d                   	pop    %ebp
  800b72:	c3                   	ret    

00800b73 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b73:	55                   	push   %ebp
  800b74:	89 e5                	mov    %esp,%ebp
  800b76:	56                   	push   %esi
  800b77:	53                   	push   %ebx
  800b78:	8b 75 08             	mov    0x8(%ebp),%esi
  800b7b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b7e:	8b 55 10             	mov    0x10(%ebp),%edx
  800b81:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b83:	85 d2                	test   %edx,%edx
  800b85:	74 21                	je     800ba8 <strlcpy+0x35>
  800b87:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800b8b:	89 f2                	mov    %esi,%edx
  800b8d:	eb 09                	jmp    800b98 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800b8f:	83 c2 01             	add    $0x1,%edx
  800b92:	83 c1 01             	add    $0x1,%ecx
  800b95:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800b98:	39 c2                	cmp    %eax,%edx
  800b9a:	74 09                	je     800ba5 <strlcpy+0x32>
  800b9c:	0f b6 19             	movzbl (%ecx),%ebx
  800b9f:	84 db                	test   %bl,%bl
  800ba1:	75 ec                	jne    800b8f <strlcpy+0x1c>
  800ba3:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800ba5:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800ba8:	29 f0                	sub    %esi,%eax
}
  800baa:	5b                   	pop    %ebx
  800bab:	5e                   	pop    %esi
  800bac:	5d                   	pop    %ebp
  800bad:	c3                   	ret    

00800bae <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800bae:	55                   	push   %ebp
  800baf:	89 e5                	mov    %esp,%ebp
  800bb1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bb4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800bb7:	eb 06                	jmp    800bbf <strcmp+0x11>
		p++, q++;
  800bb9:	83 c1 01             	add    $0x1,%ecx
  800bbc:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800bbf:	0f b6 01             	movzbl (%ecx),%eax
  800bc2:	84 c0                	test   %al,%al
  800bc4:	74 04                	je     800bca <strcmp+0x1c>
  800bc6:	3a 02                	cmp    (%edx),%al
  800bc8:	74 ef                	je     800bb9 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800bca:	0f b6 c0             	movzbl %al,%eax
  800bcd:	0f b6 12             	movzbl (%edx),%edx
  800bd0:	29 d0                	sub    %edx,%eax
}
  800bd2:	5d                   	pop    %ebp
  800bd3:	c3                   	ret    

00800bd4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800bd4:	55                   	push   %ebp
  800bd5:	89 e5                	mov    %esp,%ebp
  800bd7:	53                   	push   %ebx
  800bd8:	8b 45 08             	mov    0x8(%ebp),%eax
  800bdb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bde:	89 c3                	mov    %eax,%ebx
  800be0:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800be3:	eb 06                	jmp    800beb <strncmp+0x17>
		n--, p++, q++;
  800be5:	83 c0 01             	add    $0x1,%eax
  800be8:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800beb:	39 d8                	cmp    %ebx,%eax
  800bed:	74 15                	je     800c04 <strncmp+0x30>
  800bef:	0f b6 08             	movzbl (%eax),%ecx
  800bf2:	84 c9                	test   %cl,%cl
  800bf4:	74 04                	je     800bfa <strncmp+0x26>
  800bf6:	3a 0a                	cmp    (%edx),%cl
  800bf8:	74 eb                	je     800be5 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800bfa:	0f b6 00             	movzbl (%eax),%eax
  800bfd:	0f b6 12             	movzbl (%edx),%edx
  800c00:	29 d0                	sub    %edx,%eax
  800c02:	eb 05                	jmp    800c09 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800c04:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c09:	5b                   	pop    %ebx
  800c0a:	5d                   	pop    %ebp
  800c0b:	c3                   	ret    

00800c0c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c0c:	55                   	push   %ebp
  800c0d:	89 e5                	mov    %esp,%ebp
  800c0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c12:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c16:	eb 07                	jmp    800c1f <strchr+0x13>
		if (*s == c)
  800c18:	38 ca                	cmp    %cl,%dl
  800c1a:	74 0f                	je     800c2b <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c1c:	83 c0 01             	add    $0x1,%eax
  800c1f:	0f b6 10             	movzbl (%eax),%edx
  800c22:	84 d2                	test   %dl,%dl
  800c24:	75 f2                	jne    800c18 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800c26:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c2b:	5d                   	pop    %ebp
  800c2c:	c3                   	ret    

00800c2d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c2d:	55                   	push   %ebp
  800c2e:	89 e5                	mov    %esp,%ebp
  800c30:	8b 45 08             	mov    0x8(%ebp),%eax
  800c33:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c37:	eb 03                	jmp    800c3c <strfind+0xf>
  800c39:	83 c0 01             	add    $0x1,%eax
  800c3c:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800c3f:	38 ca                	cmp    %cl,%dl
  800c41:	74 04                	je     800c47 <strfind+0x1a>
  800c43:	84 d2                	test   %dl,%dl
  800c45:	75 f2                	jne    800c39 <strfind+0xc>
			break;
	return (char *) s;
}
  800c47:	5d                   	pop    %ebp
  800c48:	c3                   	ret    

00800c49 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c49:	55                   	push   %ebp
  800c4a:	89 e5                	mov    %esp,%ebp
  800c4c:	57                   	push   %edi
  800c4d:	56                   	push   %esi
  800c4e:	53                   	push   %ebx
  800c4f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c52:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c55:	85 c9                	test   %ecx,%ecx
  800c57:	74 36                	je     800c8f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c59:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c5f:	75 28                	jne    800c89 <memset+0x40>
  800c61:	f6 c1 03             	test   $0x3,%cl
  800c64:	75 23                	jne    800c89 <memset+0x40>
		c &= 0xFF;
  800c66:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c6a:	89 d3                	mov    %edx,%ebx
  800c6c:	c1 e3 08             	shl    $0x8,%ebx
  800c6f:	89 d6                	mov    %edx,%esi
  800c71:	c1 e6 18             	shl    $0x18,%esi
  800c74:	89 d0                	mov    %edx,%eax
  800c76:	c1 e0 10             	shl    $0x10,%eax
  800c79:	09 f0                	or     %esi,%eax
  800c7b:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800c7d:	89 d8                	mov    %ebx,%eax
  800c7f:	09 d0                	or     %edx,%eax
  800c81:	c1 e9 02             	shr    $0x2,%ecx
  800c84:	fc                   	cld    
  800c85:	f3 ab                	rep stos %eax,%es:(%edi)
  800c87:	eb 06                	jmp    800c8f <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c89:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c8c:	fc                   	cld    
  800c8d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c8f:	89 f8                	mov    %edi,%eax
  800c91:	5b                   	pop    %ebx
  800c92:	5e                   	pop    %esi
  800c93:	5f                   	pop    %edi
  800c94:	5d                   	pop    %ebp
  800c95:	c3                   	ret    

00800c96 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c96:	55                   	push   %ebp
  800c97:	89 e5                	mov    %esp,%ebp
  800c99:	57                   	push   %edi
  800c9a:	56                   	push   %esi
  800c9b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c9e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ca1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ca4:	39 c6                	cmp    %eax,%esi
  800ca6:	73 35                	jae    800cdd <memmove+0x47>
  800ca8:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800cab:	39 d0                	cmp    %edx,%eax
  800cad:	73 2e                	jae    800cdd <memmove+0x47>
		s += n;
		d += n;
  800caf:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cb2:	89 d6                	mov    %edx,%esi
  800cb4:	09 fe                	or     %edi,%esi
  800cb6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800cbc:	75 13                	jne    800cd1 <memmove+0x3b>
  800cbe:	f6 c1 03             	test   $0x3,%cl
  800cc1:	75 0e                	jne    800cd1 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800cc3:	83 ef 04             	sub    $0x4,%edi
  800cc6:	8d 72 fc             	lea    -0x4(%edx),%esi
  800cc9:	c1 e9 02             	shr    $0x2,%ecx
  800ccc:	fd                   	std    
  800ccd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ccf:	eb 09                	jmp    800cda <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800cd1:	83 ef 01             	sub    $0x1,%edi
  800cd4:	8d 72 ff             	lea    -0x1(%edx),%esi
  800cd7:	fd                   	std    
  800cd8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800cda:	fc                   	cld    
  800cdb:	eb 1d                	jmp    800cfa <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cdd:	89 f2                	mov    %esi,%edx
  800cdf:	09 c2                	or     %eax,%edx
  800ce1:	f6 c2 03             	test   $0x3,%dl
  800ce4:	75 0f                	jne    800cf5 <memmove+0x5f>
  800ce6:	f6 c1 03             	test   $0x3,%cl
  800ce9:	75 0a                	jne    800cf5 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800ceb:	c1 e9 02             	shr    $0x2,%ecx
  800cee:	89 c7                	mov    %eax,%edi
  800cf0:	fc                   	cld    
  800cf1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800cf3:	eb 05                	jmp    800cfa <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800cf5:	89 c7                	mov    %eax,%edi
  800cf7:	fc                   	cld    
  800cf8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800cfa:	5e                   	pop    %esi
  800cfb:	5f                   	pop    %edi
  800cfc:	5d                   	pop    %ebp
  800cfd:	c3                   	ret    

00800cfe <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800cfe:	55                   	push   %ebp
  800cff:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800d01:	ff 75 10             	pushl  0x10(%ebp)
  800d04:	ff 75 0c             	pushl  0xc(%ebp)
  800d07:	ff 75 08             	pushl  0x8(%ebp)
  800d0a:	e8 87 ff ff ff       	call   800c96 <memmove>
}
  800d0f:	c9                   	leave  
  800d10:	c3                   	ret    

00800d11 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d11:	55                   	push   %ebp
  800d12:	89 e5                	mov    %esp,%ebp
  800d14:	56                   	push   %esi
  800d15:	53                   	push   %ebx
  800d16:	8b 45 08             	mov    0x8(%ebp),%eax
  800d19:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d1c:	89 c6                	mov    %eax,%esi
  800d1e:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d21:	eb 1a                	jmp    800d3d <memcmp+0x2c>
		if (*s1 != *s2)
  800d23:	0f b6 08             	movzbl (%eax),%ecx
  800d26:	0f b6 1a             	movzbl (%edx),%ebx
  800d29:	38 d9                	cmp    %bl,%cl
  800d2b:	74 0a                	je     800d37 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800d2d:	0f b6 c1             	movzbl %cl,%eax
  800d30:	0f b6 db             	movzbl %bl,%ebx
  800d33:	29 d8                	sub    %ebx,%eax
  800d35:	eb 0f                	jmp    800d46 <memcmp+0x35>
		s1++, s2++;
  800d37:	83 c0 01             	add    $0x1,%eax
  800d3a:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d3d:	39 f0                	cmp    %esi,%eax
  800d3f:	75 e2                	jne    800d23 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d41:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d46:	5b                   	pop    %ebx
  800d47:	5e                   	pop    %esi
  800d48:	5d                   	pop    %ebp
  800d49:	c3                   	ret    

00800d4a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d4a:	55                   	push   %ebp
  800d4b:	89 e5                	mov    %esp,%ebp
  800d4d:	53                   	push   %ebx
  800d4e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800d51:	89 c1                	mov    %eax,%ecx
  800d53:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800d56:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d5a:	eb 0a                	jmp    800d66 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d5c:	0f b6 10             	movzbl (%eax),%edx
  800d5f:	39 da                	cmp    %ebx,%edx
  800d61:	74 07                	je     800d6a <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d63:	83 c0 01             	add    $0x1,%eax
  800d66:	39 c8                	cmp    %ecx,%eax
  800d68:	72 f2                	jb     800d5c <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d6a:	5b                   	pop    %ebx
  800d6b:	5d                   	pop    %ebp
  800d6c:	c3                   	ret    

00800d6d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d6d:	55                   	push   %ebp
  800d6e:	89 e5                	mov    %esp,%ebp
  800d70:	57                   	push   %edi
  800d71:	56                   	push   %esi
  800d72:	53                   	push   %ebx
  800d73:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d76:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d79:	eb 03                	jmp    800d7e <strtol+0x11>
		s++;
  800d7b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d7e:	0f b6 01             	movzbl (%ecx),%eax
  800d81:	3c 20                	cmp    $0x20,%al
  800d83:	74 f6                	je     800d7b <strtol+0xe>
  800d85:	3c 09                	cmp    $0x9,%al
  800d87:	74 f2                	je     800d7b <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d89:	3c 2b                	cmp    $0x2b,%al
  800d8b:	75 0a                	jne    800d97 <strtol+0x2a>
		s++;
  800d8d:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d90:	bf 00 00 00 00       	mov    $0x0,%edi
  800d95:	eb 11                	jmp    800da8 <strtol+0x3b>
  800d97:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d9c:	3c 2d                	cmp    $0x2d,%al
  800d9e:	75 08                	jne    800da8 <strtol+0x3b>
		s++, neg = 1;
  800da0:	83 c1 01             	add    $0x1,%ecx
  800da3:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800da8:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800dae:	75 15                	jne    800dc5 <strtol+0x58>
  800db0:	80 39 30             	cmpb   $0x30,(%ecx)
  800db3:	75 10                	jne    800dc5 <strtol+0x58>
  800db5:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800db9:	75 7c                	jne    800e37 <strtol+0xca>
		s += 2, base = 16;
  800dbb:	83 c1 02             	add    $0x2,%ecx
  800dbe:	bb 10 00 00 00       	mov    $0x10,%ebx
  800dc3:	eb 16                	jmp    800ddb <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800dc5:	85 db                	test   %ebx,%ebx
  800dc7:	75 12                	jne    800ddb <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800dc9:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800dce:	80 39 30             	cmpb   $0x30,(%ecx)
  800dd1:	75 08                	jne    800ddb <strtol+0x6e>
		s++, base = 8;
  800dd3:	83 c1 01             	add    $0x1,%ecx
  800dd6:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ddb:	b8 00 00 00 00       	mov    $0x0,%eax
  800de0:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800de3:	0f b6 11             	movzbl (%ecx),%edx
  800de6:	8d 72 d0             	lea    -0x30(%edx),%esi
  800de9:	89 f3                	mov    %esi,%ebx
  800deb:	80 fb 09             	cmp    $0x9,%bl
  800dee:	77 08                	ja     800df8 <strtol+0x8b>
			dig = *s - '0';
  800df0:	0f be d2             	movsbl %dl,%edx
  800df3:	83 ea 30             	sub    $0x30,%edx
  800df6:	eb 22                	jmp    800e1a <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800df8:	8d 72 9f             	lea    -0x61(%edx),%esi
  800dfb:	89 f3                	mov    %esi,%ebx
  800dfd:	80 fb 19             	cmp    $0x19,%bl
  800e00:	77 08                	ja     800e0a <strtol+0x9d>
			dig = *s - 'a' + 10;
  800e02:	0f be d2             	movsbl %dl,%edx
  800e05:	83 ea 57             	sub    $0x57,%edx
  800e08:	eb 10                	jmp    800e1a <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800e0a:	8d 72 bf             	lea    -0x41(%edx),%esi
  800e0d:	89 f3                	mov    %esi,%ebx
  800e0f:	80 fb 19             	cmp    $0x19,%bl
  800e12:	77 16                	ja     800e2a <strtol+0xbd>
			dig = *s - 'A' + 10;
  800e14:	0f be d2             	movsbl %dl,%edx
  800e17:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800e1a:	3b 55 10             	cmp    0x10(%ebp),%edx
  800e1d:	7d 0b                	jge    800e2a <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800e1f:	83 c1 01             	add    $0x1,%ecx
  800e22:	0f af 45 10          	imul   0x10(%ebp),%eax
  800e26:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800e28:	eb b9                	jmp    800de3 <strtol+0x76>

	if (endptr)
  800e2a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e2e:	74 0d                	je     800e3d <strtol+0xd0>
		*endptr = (char *) s;
  800e30:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e33:	89 0e                	mov    %ecx,(%esi)
  800e35:	eb 06                	jmp    800e3d <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e37:	85 db                	test   %ebx,%ebx
  800e39:	74 98                	je     800dd3 <strtol+0x66>
  800e3b:	eb 9e                	jmp    800ddb <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800e3d:	89 c2                	mov    %eax,%edx
  800e3f:	f7 da                	neg    %edx
  800e41:	85 ff                	test   %edi,%edi
  800e43:	0f 45 c2             	cmovne %edx,%eax
}
  800e46:	5b                   	pop    %ebx
  800e47:	5e                   	pop    %esi
  800e48:	5f                   	pop    %edi
  800e49:	5d                   	pop    %ebp
  800e4a:	c3                   	ret    

00800e4b <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800e4b:	55                   	push   %ebp
  800e4c:	89 e5                	mov    %esp,%ebp
  800e4e:	57                   	push   %edi
  800e4f:	56                   	push   %esi
  800e50:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e51:	b8 00 00 00 00       	mov    $0x0,%eax
  800e56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e59:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5c:	89 c3                	mov    %eax,%ebx
  800e5e:	89 c7                	mov    %eax,%edi
  800e60:	89 c6                	mov    %eax,%esi
  800e62:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800e64:	5b                   	pop    %ebx
  800e65:	5e                   	pop    %esi
  800e66:	5f                   	pop    %edi
  800e67:	5d                   	pop    %ebp
  800e68:	c3                   	ret    

00800e69 <sys_cgetc>:

int
sys_cgetc(void)
{
  800e69:	55                   	push   %ebp
  800e6a:	89 e5                	mov    %esp,%ebp
  800e6c:	57                   	push   %edi
  800e6d:	56                   	push   %esi
  800e6e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e6f:	ba 00 00 00 00       	mov    $0x0,%edx
  800e74:	b8 01 00 00 00       	mov    $0x1,%eax
  800e79:	89 d1                	mov    %edx,%ecx
  800e7b:	89 d3                	mov    %edx,%ebx
  800e7d:	89 d7                	mov    %edx,%edi
  800e7f:	89 d6                	mov    %edx,%esi
  800e81:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e83:	5b                   	pop    %ebx
  800e84:	5e                   	pop    %esi
  800e85:	5f                   	pop    %edi
  800e86:	5d                   	pop    %ebp
  800e87:	c3                   	ret    

00800e88 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800e88:	55                   	push   %ebp
  800e89:	89 e5                	mov    %esp,%ebp
  800e8b:	57                   	push   %edi
  800e8c:	56                   	push   %esi
  800e8d:	53                   	push   %ebx
  800e8e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e91:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e96:	b8 03 00 00 00       	mov    $0x3,%eax
  800e9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9e:	89 cb                	mov    %ecx,%ebx
  800ea0:	89 cf                	mov    %ecx,%edi
  800ea2:	89 ce                	mov    %ecx,%esi
  800ea4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ea6:	85 c0                	test   %eax,%eax
  800ea8:	7e 17                	jle    800ec1 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eaa:	83 ec 0c             	sub    $0xc,%esp
  800ead:	50                   	push   %eax
  800eae:	6a 03                	push   $0x3
  800eb0:	68 1f 2a 80 00       	push   $0x802a1f
  800eb5:	6a 23                	push   $0x23
  800eb7:	68 3c 2a 80 00       	push   $0x802a3c
  800ebc:	e8 3e f5 ff ff       	call   8003ff <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ec1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ec4:	5b                   	pop    %ebx
  800ec5:	5e                   	pop    %esi
  800ec6:	5f                   	pop    %edi
  800ec7:	5d                   	pop    %ebp
  800ec8:	c3                   	ret    

00800ec9 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ec9:	55                   	push   %ebp
  800eca:	89 e5                	mov    %esp,%ebp
  800ecc:	57                   	push   %edi
  800ecd:	56                   	push   %esi
  800ece:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ecf:	ba 00 00 00 00       	mov    $0x0,%edx
  800ed4:	b8 02 00 00 00       	mov    $0x2,%eax
  800ed9:	89 d1                	mov    %edx,%ecx
  800edb:	89 d3                	mov    %edx,%ebx
  800edd:	89 d7                	mov    %edx,%edi
  800edf:	89 d6                	mov    %edx,%esi
  800ee1:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ee3:	5b                   	pop    %ebx
  800ee4:	5e                   	pop    %esi
  800ee5:	5f                   	pop    %edi
  800ee6:	5d                   	pop    %ebp
  800ee7:	c3                   	ret    

00800ee8 <sys_yield>:

void
sys_yield(void)
{
  800ee8:	55                   	push   %ebp
  800ee9:	89 e5                	mov    %esp,%ebp
  800eeb:	57                   	push   %edi
  800eec:	56                   	push   %esi
  800eed:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eee:	ba 00 00 00 00       	mov    $0x0,%edx
  800ef3:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ef8:	89 d1                	mov    %edx,%ecx
  800efa:	89 d3                	mov    %edx,%ebx
  800efc:	89 d7                	mov    %edx,%edi
  800efe:	89 d6                	mov    %edx,%esi
  800f00:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800f02:	5b                   	pop    %ebx
  800f03:	5e                   	pop    %esi
  800f04:	5f                   	pop    %edi
  800f05:	5d                   	pop    %ebp
  800f06:	c3                   	ret    

00800f07 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f07:	55                   	push   %ebp
  800f08:	89 e5                	mov    %esp,%ebp
  800f0a:	57                   	push   %edi
  800f0b:	56                   	push   %esi
  800f0c:	53                   	push   %ebx
  800f0d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f10:	be 00 00 00 00       	mov    $0x0,%esi
  800f15:	b8 04 00 00 00       	mov    $0x4,%eax
  800f1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f1d:	8b 55 08             	mov    0x8(%ebp),%edx
  800f20:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f23:	89 f7                	mov    %esi,%edi
  800f25:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f27:	85 c0                	test   %eax,%eax
  800f29:	7e 17                	jle    800f42 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f2b:	83 ec 0c             	sub    $0xc,%esp
  800f2e:	50                   	push   %eax
  800f2f:	6a 04                	push   $0x4
  800f31:	68 1f 2a 80 00       	push   $0x802a1f
  800f36:	6a 23                	push   $0x23
  800f38:	68 3c 2a 80 00       	push   $0x802a3c
  800f3d:	e8 bd f4 ff ff       	call   8003ff <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800f42:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f45:	5b                   	pop    %ebx
  800f46:	5e                   	pop    %esi
  800f47:	5f                   	pop    %edi
  800f48:	5d                   	pop    %ebp
  800f49:	c3                   	ret    

00800f4a <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f4a:	55                   	push   %ebp
  800f4b:	89 e5                	mov    %esp,%ebp
  800f4d:	57                   	push   %edi
  800f4e:	56                   	push   %esi
  800f4f:	53                   	push   %ebx
  800f50:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f53:	b8 05 00 00 00       	mov    $0x5,%eax
  800f58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f5b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f5e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f61:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f64:	8b 75 18             	mov    0x18(%ebp),%esi
  800f67:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f69:	85 c0                	test   %eax,%eax
  800f6b:	7e 17                	jle    800f84 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f6d:	83 ec 0c             	sub    $0xc,%esp
  800f70:	50                   	push   %eax
  800f71:	6a 05                	push   $0x5
  800f73:	68 1f 2a 80 00       	push   $0x802a1f
  800f78:	6a 23                	push   $0x23
  800f7a:	68 3c 2a 80 00       	push   $0x802a3c
  800f7f:	e8 7b f4 ff ff       	call   8003ff <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f84:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f87:	5b                   	pop    %ebx
  800f88:	5e                   	pop    %esi
  800f89:	5f                   	pop    %edi
  800f8a:	5d                   	pop    %ebp
  800f8b:	c3                   	ret    

00800f8c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800f8c:	55                   	push   %ebp
  800f8d:	89 e5                	mov    %esp,%ebp
  800f8f:	57                   	push   %edi
  800f90:	56                   	push   %esi
  800f91:	53                   	push   %ebx
  800f92:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f95:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f9a:	b8 06 00 00 00       	mov    $0x6,%eax
  800f9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fa2:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa5:	89 df                	mov    %ebx,%edi
  800fa7:	89 de                	mov    %ebx,%esi
  800fa9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fab:	85 c0                	test   %eax,%eax
  800fad:	7e 17                	jle    800fc6 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800faf:	83 ec 0c             	sub    $0xc,%esp
  800fb2:	50                   	push   %eax
  800fb3:	6a 06                	push   $0x6
  800fb5:	68 1f 2a 80 00       	push   $0x802a1f
  800fba:	6a 23                	push   $0x23
  800fbc:	68 3c 2a 80 00       	push   $0x802a3c
  800fc1:	e8 39 f4 ff ff       	call   8003ff <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800fc6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fc9:	5b                   	pop    %ebx
  800fca:	5e                   	pop    %esi
  800fcb:	5f                   	pop    %edi
  800fcc:	5d                   	pop    %ebp
  800fcd:	c3                   	ret    

00800fce <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800fce:	55                   	push   %ebp
  800fcf:	89 e5                	mov    %esp,%ebp
  800fd1:	57                   	push   %edi
  800fd2:	56                   	push   %esi
  800fd3:	53                   	push   %ebx
  800fd4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fd7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fdc:	b8 08 00 00 00       	mov    $0x8,%eax
  800fe1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fe4:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe7:	89 df                	mov    %ebx,%edi
  800fe9:	89 de                	mov    %ebx,%esi
  800feb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fed:	85 c0                	test   %eax,%eax
  800fef:	7e 17                	jle    801008 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ff1:	83 ec 0c             	sub    $0xc,%esp
  800ff4:	50                   	push   %eax
  800ff5:	6a 08                	push   $0x8
  800ff7:	68 1f 2a 80 00       	push   $0x802a1f
  800ffc:	6a 23                	push   $0x23
  800ffe:	68 3c 2a 80 00       	push   $0x802a3c
  801003:	e8 f7 f3 ff ff       	call   8003ff <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801008:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80100b:	5b                   	pop    %ebx
  80100c:	5e                   	pop    %esi
  80100d:	5f                   	pop    %edi
  80100e:	5d                   	pop    %ebp
  80100f:	c3                   	ret    

00801010 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801010:	55                   	push   %ebp
  801011:	89 e5                	mov    %esp,%ebp
  801013:	57                   	push   %edi
  801014:	56                   	push   %esi
  801015:	53                   	push   %ebx
  801016:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801019:	bb 00 00 00 00       	mov    $0x0,%ebx
  80101e:	b8 09 00 00 00       	mov    $0x9,%eax
  801023:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801026:	8b 55 08             	mov    0x8(%ebp),%edx
  801029:	89 df                	mov    %ebx,%edi
  80102b:	89 de                	mov    %ebx,%esi
  80102d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80102f:	85 c0                	test   %eax,%eax
  801031:	7e 17                	jle    80104a <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801033:	83 ec 0c             	sub    $0xc,%esp
  801036:	50                   	push   %eax
  801037:	6a 09                	push   $0x9
  801039:	68 1f 2a 80 00       	push   $0x802a1f
  80103e:	6a 23                	push   $0x23
  801040:	68 3c 2a 80 00       	push   $0x802a3c
  801045:	e8 b5 f3 ff ff       	call   8003ff <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80104a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80104d:	5b                   	pop    %ebx
  80104e:	5e                   	pop    %esi
  80104f:	5f                   	pop    %edi
  801050:	5d                   	pop    %ebp
  801051:	c3                   	ret    

00801052 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801052:	55                   	push   %ebp
  801053:	89 e5                	mov    %esp,%ebp
  801055:	57                   	push   %edi
  801056:	56                   	push   %esi
  801057:	53                   	push   %ebx
  801058:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80105b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801060:	b8 0a 00 00 00       	mov    $0xa,%eax
  801065:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801068:	8b 55 08             	mov    0x8(%ebp),%edx
  80106b:	89 df                	mov    %ebx,%edi
  80106d:	89 de                	mov    %ebx,%esi
  80106f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801071:	85 c0                	test   %eax,%eax
  801073:	7e 17                	jle    80108c <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801075:	83 ec 0c             	sub    $0xc,%esp
  801078:	50                   	push   %eax
  801079:	6a 0a                	push   $0xa
  80107b:	68 1f 2a 80 00       	push   $0x802a1f
  801080:	6a 23                	push   $0x23
  801082:	68 3c 2a 80 00       	push   $0x802a3c
  801087:	e8 73 f3 ff ff       	call   8003ff <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80108c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80108f:	5b                   	pop    %ebx
  801090:	5e                   	pop    %esi
  801091:	5f                   	pop    %edi
  801092:	5d                   	pop    %ebp
  801093:	c3                   	ret    

00801094 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801094:	55                   	push   %ebp
  801095:	89 e5                	mov    %esp,%ebp
  801097:	57                   	push   %edi
  801098:	56                   	push   %esi
  801099:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80109a:	be 00 00 00 00       	mov    $0x0,%esi
  80109f:	b8 0c 00 00 00       	mov    $0xc,%eax
  8010a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010a7:	8b 55 08             	mov    0x8(%ebp),%edx
  8010aa:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010ad:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010b0:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8010b2:	5b                   	pop    %ebx
  8010b3:	5e                   	pop    %esi
  8010b4:	5f                   	pop    %edi
  8010b5:	5d                   	pop    %ebp
  8010b6:	c3                   	ret    

008010b7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8010b7:	55                   	push   %ebp
  8010b8:	89 e5                	mov    %esp,%ebp
  8010ba:	57                   	push   %edi
  8010bb:	56                   	push   %esi
  8010bc:	53                   	push   %ebx
  8010bd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010c0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010c5:	b8 0d 00 00 00       	mov    $0xd,%eax
  8010ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8010cd:	89 cb                	mov    %ecx,%ebx
  8010cf:	89 cf                	mov    %ecx,%edi
  8010d1:	89 ce                	mov    %ecx,%esi
  8010d3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010d5:	85 c0                	test   %eax,%eax
  8010d7:	7e 17                	jle    8010f0 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010d9:	83 ec 0c             	sub    $0xc,%esp
  8010dc:	50                   	push   %eax
  8010dd:	6a 0d                	push   $0xd
  8010df:	68 1f 2a 80 00       	push   $0x802a1f
  8010e4:	6a 23                	push   $0x23
  8010e6:	68 3c 2a 80 00       	push   $0x802a3c
  8010eb:	e8 0f f3 ff ff       	call   8003ff <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8010f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010f3:	5b                   	pop    %ebx
  8010f4:	5e                   	pop    %esi
  8010f5:	5f                   	pop    %edi
  8010f6:	5d                   	pop    %ebp
  8010f7:	c3                   	ret    

008010f8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010f8:	55                   	push   %ebp
  8010f9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8010fe:	05 00 00 00 30       	add    $0x30000000,%eax
  801103:	c1 e8 0c             	shr    $0xc,%eax
}
  801106:	5d                   	pop    %ebp
  801107:	c3                   	ret    

00801108 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801108:	55                   	push   %ebp
  801109:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80110b:	8b 45 08             	mov    0x8(%ebp),%eax
  80110e:	05 00 00 00 30       	add    $0x30000000,%eax
  801113:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801118:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80111d:	5d                   	pop    %ebp
  80111e:	c3                   	ret    

0080111f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80111f:	55                   	push   %ebp
  801120:	89 e5                	mov    %esp,%ebp
  801122:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801125:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80112a:	89 c2                	mov    %eax,%edx
  80112c:	c1 ea 16             	shr    $0x16,%edx
  80112f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801136:	f6 c2 01             	test   $0x1,%dl
  801139:	74 11                	je     80114c <fd_alloc+0x2d>
  80113b:	89 c2                	mov    %eax,%edx
  80113d:	c1 ea 0c             	shr    $0xc,%edx
  801140:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801147:	f6 c2 01             	test   $0x1,%dl
  80114a:	75 09                	jne    801155 <fd_alloc+0x36>
			*fd_store = fd;
  80114c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80114e:	b8 00 00 00 00       	mov    $0x0,%eax
  801153:	eb 17                	jmp    80116c <fd_alloc+0x4d>
  801155:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80115a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80115f:	75 c9                	jne    80112a <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801161:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801167:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80116c:	5d                   	pop    %ebp
  80116d:	c3                   	ret    

0080116e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80116e:	55                   	push   %ebp
  80116f:	89 e5                	mov    %esp,%ebp
  801171:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801174:	83 f8 1f             	cmp    $0x1f,%eax
  801177:	77 36                	ja     8011af <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801179:	c1 e0 0c             	shl    $0xc,%eax
  80117c:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801181:	89 c2                	mov    %eax,%edx
  801183:	c1 ea 16             	shr    $0x16,%edx
  801186:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80118d:	f6 c2 01             	test   $0x1,%dl
  801190:	74 24                	je     8011b6 <fd_lookup+0x48>
  801192:	89 c2                	mov    %eax,%edx
  801194:	c1 ea 0c             	shr    $0xc,%edx
  801197:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80119e:	f6 c2 01             	test   $0x1,%dl
  8011a1:	74 1a                	je     8011bd <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011a3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011a6:	89 02                	mov    %eax,(%edx)
	return 0;
  8011a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8011ad:	eb 13                	jmp    8011c2 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011b4:	eb 0c                	jmp    8011c2 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011b6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011bb:	eb 05                	jmp    8011c2 <fd_lookup+0x54>
  8011bd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8011c2:	5d                   	pop    %ebp
  8011c3:	c3                   	ret    

008011c4 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011c4:	55                   	push   %ebp
  8011c5:	89 e5                	mov    %esp,%ebp
  8011c7:	83 ec 08             	sub    $0x8,%esp
  8011ca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011cd:	ba c8 2a 80 00       	mov    $0x802ac8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8011d2:	eb 13                	jmp    8011e7 <dev_lookup+0x23>
  8011d4:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8011d7:	39 08                	cmp    %ecx,(%eax)
  8011d9:	75 0c                	jne    8011e7 <dev_lookup+0x23>
			*dev = devtab[i];
  8011db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011de:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8011e5:	eb 2e                	jmp    801215 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011e7:	8b 02                	mov    (%edx),%eax
  8011e9:	85 c0                	test   %eax,%eax
  8011eb:	75 e7                	jne    8011d4 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011ed:	a1 90 67 80 00       	mov    0x806790,%eax
  8011f2:	8b 40 48             	mov    0x48(%eax),%eax
  8011f5:	83 ec 04             	sub    $0x4,%esp
  8011f8:	51                   	push   %ecx
  8011f9:	50                   	push   %eax
  8011fa:	68 4c 2a 80 00       	push   $0x802a4c
  8011ff:	e8 d4 f2 ff ff       	call   8004d8 <cprintf>
	*dev = 0;
  801204:	8b 45 0c             	mov    0xc(%ebp),%eax
  801207:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80120d:	83 c4 10             	add    $0x10,%esp
  801210:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801215:	c9                   	leave  
  801216:	c3                   	ret    

00801217 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801217:	55                   	push   %ebp
  801218:	89 e5                	mov    %esp,%ebp
  80121a:	56                   	push   %esi
  80121b:	53                   	push   %ebx
  80121c:	83 ec 10             	sub    $0x10,%esp
  80121f:	8b 75 08             	mov    0x8(%ebp),%esi
  801222:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801225:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801228:	50                   	push   %eax
  801229:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80122f:	c1 e8 0c             	shr    $0xc,%eax
  801232:	50                   	push   %eax
  801233:	e8 36 ff ff ff       	call   80116e <fd_lookup>
  801238:	83 c4 08             	add    $0x8,%esp
  80123b:	85 c0                	test   %eax,%eax
  80123d:	78 05                	js     801244 <fd_close+0x2d>
	    || fd != fd2)
  80123f:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801242:	74 0c                	je     801250 <fd_close+0x39>
		return (must_exist ? r : 0);
  801244:	84 db                	test   %bl,%bl
  801246:	ba 00 00 00 00       	mov    $0x0,%edx
  80124b:	0f 44 c2             	cmove  %edx,%eax
  80124e:	eb 41                	jmp    801291 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801250:	83 ec 08             	sub    $0x8,%esp
  801253:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801256:	50                   	push   %eax
  801257:	ff 36                	pushl  (%esi)
  801259:	e8 66 ff ff ff       	call   8011c4 <dev_lookup>
  80125e:	89 c3                	mov    %eax,%ebx
  801260:	83 c4 10             	add    $0x10,%esp
  801263:	85 c0                	test   %eax,%eax
  801265:	78 1a                	js     801281 <fd_close+0x6a>
		if (dev->dev_close)
  801267:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80126a:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80126d:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801272:	85 c0                	test   %eax,%eax
  801274:	74 0b                	je     801281 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801276:	83 ec 0c             	sub    $0xc,%esp
  801279:	56                   	push   %esi
  80127a:	ff d0                	call   *%eax
  80127c:	89 c3                	mov    %eax,%ebx
  80127e:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801281:	83 ec 08             	sub    $0x8,%esp
  801284:	56                   	push   %esi
  801285:	6a 00                	push   $0x0
  801287:	e8 00 fd ff ff       	call   800f8c <sys_page_unmap>
	return r;
  80128c:	83 c4 10             	add    $0x10,%esp
  80128f:	89 d8                	mov    %ebx,%eax
}
  801291:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801294:	5b                   	pop    %ebx
  801295:	5e                   	pop    %esi
  801296:	5d                   	pop    %ebp
  801297:	c3                   	ret    

00801298 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801298:	55                   	push   %ebp
  801299:	89 e5                	mov    %esp,%ebp
  80129b:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80129e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012a1:	50                   	push   %eax
  8012a2:	ff 75 08             	pushl  0x8(%ebp)
  8012a5:	e8 c4 fe ff ff       	call   80116e <fd_lookup>
  8012aa:	83 c4 08             	add    $0x8,%esp
  8012ad:	85 c0                	test   %eax,%eax
  8012af:	78 10                	js     8012c1 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8012b1:	83 ec 08             	sub    $0x8,%esp
  8012b4:	6a 01                	push   $0x1
  8012b6:	ff 75 f4             	pushl  -0xc(%ebp)
  8012b9:	e8 59 ff ff ff       	call   801217 <fd_close>
  8012be:	83 c4 10             	add    $0x10,%esp
}
  8012c1:	c9                   	leave  
  8012c2:	c3                   	ret    

008012c3 <close_all>:

void
close_all(void)
{
  8012c3:	55                   	push   %ebp
  8012c4:	89 e5                	mov    %esp,%ebp
  8012c6:	53                   	push   %ebx
  8012c7:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012ca:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012cf:	83 ec 0c             	sub    $0xc,%esp
  8012d2:	53                   	push   %ebx
  8012d3:	e8 c0 ff ff ff       	call   801298 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8012d8:	83 c3 01             	add    $0x1,%ebx
  8012db:	83 c4 10             	add    $0x10,%esp
  8012de:	83 fb 20             	cmp    $0x20,%ebx
  8012e1:	75 ec                	jne    8012cf <close_all+0xc>
		close(i);
}
  8012e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012e6:	c9                   	leave  
  8012e7:	c3                   	ret    

008012e8 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012e8:	55                   	push   %ebp
  8012e9:	89 e5                	mov    %esp,%ebp
  8012eb:	57                   	push   %edi
  8012ec:	56                   	push   %esi
  8012ed:	53                   	push   %ebx
  8012ee:	83 ec 2c             	sub    $0x2c,%esp
  8012f1:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012f4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012f7:	50                   	push   %eax
  8012f8:	ff 75 08             	pushl  0x8(%ebp)
  8012fb:	e8 6e fe ff ff       	call   80116e <fd_lookup>
  801300:	83 c4 08             	add    $0x8,%esp
  801303:	85 c0                	test   %eax,%eax
  801305:	0f 88 c1 00 00 00    	js     8013cc <dup+0xe4>
		return r;
	close(newfdnum);
  80130b:	83 ec 0c             	sub    $0xc,%esp
  80130e:	56                   	push   %esi
  80130f:	e8 84 ff ff ff       	call   801298 <close>

	newfd = INDEX2FD(newfdnum);
  801314:	89 f3                	mov    %esi,%ebx
  801316:	c1 e3 0c             	shl    $0xc,%ebx
  801319:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80131f:	83 c4 04             	add    $0x4,%esp
  801322:	ff 75 e4             	pushl  -0x1c(%ebp)
  801325:	e8 de fd ff ff       	call   801108 <fd2data>
  80132a:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80132c:	89 1c 24             	mov    %ebx,(%esp)
  80132f:	e8 d4 fd ff ff       	call   801108 <fd2data>
  801334:	83 c4 10             	add    $0x10,%esp
  801337:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80133a:	89 f8                	mov    %edi,%eax
  80133c:	c1 e8 16             	shr    $0x16,%eax
  80133f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801346:	a8 01                	test   $0x1,%al
  801348:	74 37                	je     801381 <dup+0x99>
  80134a:	89 f8                	mov    %edi,%eax
  80134c:	c1 e8 0c             	shr    $0xc,%eax
  80134f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801356:	f6 c2 01             	test   $0x1,%dl
  801359:	74 26                	je     801381 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80135b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801362:	83 ec 0c             	sub    $0xc,%esp
  801365:	25 07 0e 00 00       	and    $0xe07,%eax
  80136a:	50                   	push   %eax
  80136b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80136e:	6a 00                	push   $0x0
  801370:	57                   	push   %edi
  801371:	6a 00                	push   $0x0
  801373:	e8 d2 fb ff ff       	call   800f4a <sys_page_map>
  801378:	89 c7                	mov    %eax,%edi
  80137a:	83 c4 20             	add    $0x20,%esp
  80137d:	85 c0                	test   %eax,%eax
  80137f:	78 2e                	js     8013af <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801381:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801384:	89 d0                	mov    %edx,%eax
  801386:	c1 e8 0c             	shr    $0xc,%eax
  801389:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801390:	83 ec 0c             	sub    $0xc,%esp
  801393:	25 07 0e 00 00       	and    $0xe07,%eax
  801398:	50                   	push   %eax
  801399:	53                   	push   %ebx
  80139a:	6a 00                	push   $0x0
  80139c:	52                   	push   %edx
  80139d:	6a 00                	push   $0x0
  80139f:	e8 a6 fb ff ff       	call   800f4a <sys_page_map>
  8013a4:	89 c7                	mov    %eax,%edi
  8013a6:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8013a9:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013ab:	85 ff                	test   %edi,%edi
  8013ad:	79 1d                	jns    8013cc <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8013af:	83 ec 08             	sub    $0x8,%esp
  8013b2:	53                   	push   %ebx
  8013b3:	6a 00                	push   $0x0
  8013b5:	e8 d2 fb ff ff       	call   800f8c <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013ba:	83 c4 08             	add    $0x8,%esp
  8013bd:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013c0:	6a 00                	push   $0x0
  8013c2:	e8 c5 fb ff ff       	call   800f8c <sys_page_unmap>
	return r;
  8013c7:	83 c4 10             	add    $0x10,%esp
  8013ca:	89 f8                	mov    %edi,%eax
}
  8013cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013cf:	5b                   	pop    %ebx
  8013d0:	5e                   	pop    %esi
  8013d1:	5f                   	pop    %edi
  8013d2:	5d                   	pop    %ebp
  8013d3:	c3                   	ret    

008013d4 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013d4:	55                   	push   %ebp
  8013d5:	89 e5                	mov    %esp,%ebp
  8013d7:	53                   	push   %ebx
  8013d8:	83 ec 14             	sub    $0x14,%esp
  8013db:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013de:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013e1:	50                   	push   %eax
  8013e2:	53                   	push   %ebx
  8013e3:	e8 86 fd ff ff       	call   80116e <fd_lookup>
  8013e8:	83 c4 08             	add    $0x8,%esp
  8013eb:	89 c2                	mov    %eax,%edx
  8013ed:	85 c0                	test   %eax,%eax
  8013ef:	78 6d                	js     80145e <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013f1:	83 ec 08             	sub    $0x8,%esp
  8013f4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013f7:	50                   	push   %eax
  8013f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013fb:	ff 30                	pushl  (%eax)
  8013fd:	e8 c2 fd ff ff       	call   8011c4 <dev_lookup>
  801402:	83 c4 10             	add    $0x10,%esp
  801405:	85 c0                	test   %eax,%eax
  801407:	78 4c                	js     801455 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801409:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80140c:	8b 42 08             	mov    0x8(%edx),%eax
  80140f:	83 e0 03             	and    $0x3,%eax
  801412:	83 f8 01             	cmp    $0x1,%eax
  801415:	75 21                	jne    801438 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801417:	a1 90 67 80 00       	mov    0x806790,%eax
  80141c:	8b 40 48             	mov    0x48(%eax),%eax
  80141f:	83 ec 04             	sub    $0x4,%esp
  801422:	53                   	push   %ebx
  801423:	50                   	push   %eax
  801424:	68 8d 2a 80 00       	push   $0x802a8d
  801429:	e8 aa f0 ff ff       	call   8004d8 <cprintf>
		return -E_INVAL;
  80142e:	83 c4 10             	add    $0x10,%esp
  801431:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801436:	eb 26                	jmp    80145e <read+0x8a>
	}
	if (!dev->dev_read)
  801438:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80143b:	8b 40 08             	mov    0x8(%eax),%eax
  80143e:	85 c0                	test   %eax,%eax
  801440:	74 17                	je     801459 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801442:	83 ec 04             	sub    $0x4,%esp
  801445:	ff 75 10             	pushl  0x10(%ebp)
  801448:	ff 75 0c             	pushl  0xc(%ebp)
  80144b:	52                   	push   %edx
  80144c:	ff d0                	call   *%eax
  80144e:	89 c2                	mov    %eax,%edx
  801450:	83 c4 10             	add    $0x10,%esp
  801453:	eb 09                	jmp    80145e <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801455:	89 c2                	mov    %eax,%edx
  801457:	eb 05                	jmp    80145e <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801459:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80145e:	89 d0                	mov    %edx,%eax
  801460:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801463:	c9                   	leave  
  801464:	c3                   	ret    

00801465 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801465:	55                   	push   %ebp
  801466:	89 e5                	mov    %esp,%ebp
  801468:	57                   	push   %edi
  801469:	56                   	push   %esi
  80146a:	53                   	push   %ebx
  80146b:	83 ec 0c             	sub    $0xc,%esp
  80146e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801471:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801474:	bb 00 00 00 00       	mov    $0x0,%ebx
  801479:	eb 21                	jmp    80149c <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80147b:	83 ec 04             	sub    $0x4,%esp
  80147e:	89 f0                	mov    %esi,%eax
  801480:	29 d8                	sub    %ebx,%eax
  801482:	50                   	push   %eax
  801483:	89 d8                	mov    %ebx,%eax
  801485:	03 45 0c             	add    0xc(%ebp),%eax
  801488:	50                   	push   %eax
  801489:	57                   	push   %edi
  80148a:	e8 45 ff ff ff       	call   8013d4 <read>
		if (m < 0)
  80148f:	83 c4 10             	add    $0x10,%esp
  801492:	85 c0                	test   %eax,%eax
  801494:	78 10                	js     8014a6 <readn+0x41>
			return m;
		if (m == 0)
  801496:	85 c0                	test   %eax,%eax
  801498:	74 0a                	je     8014a4 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80149a:	01 c3                	add    %eax,%ebx
  80149c:	39 f3                	cmp    %esi,%ebx
  80149e:	72 db                	jb     80147b <readn+0x16>
  8014a0:	89 d8                	mov    %ebx,%eax
  8014a2:	eb 02                	jmp    8014a6 <readn+0x41>
  8014a4:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8014a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014a9:	5b                   	pop    %ebx
  8014aa:	5e                   	pop    %esi
  8014ab:	5f                   	pop    %edi
  8014ac:	5d                   	pop    %ebp
  8014ad:	c3                   	ret    

008014ae <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014ae:	55                   	push   %ebp
  8014af:	89 e5                	mov    %esp,%ebp
  8014b1:	53                   	push   %ebx
  8014b2:	83 ec 14             	sub    $0x14,%esp
  8014b5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014b8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014bb:	50                   	push   %eax
  8014bc:	53                   	push   %ebx
  8014bd:	e8 ac fc ff ff       	call   80116e <fd_lookup>
  8014c2:	83 c4 08             	add    $0x8,%esp
  8014c5:	89 c2                	mov    %eax,%edx
  8014c7:	85 c0                	test   %eax,%eax
  8014c9:	78 68                	js     801533 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014cb:	83 ec 08             	sub    $0x8,%esp
  8014ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014d1:	50                   	push   %eax
  8014d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014d5:	ff 30                	pushl  (%eax)
  8014d7:	e8 e8 fc ff ff       	call   8011c4 <dev_lookup>
  8014dc:	83 c4 10             	add    $0x10,%esp
  8014df:	85 c0                	test   %eax,%eax
  8014e1:	78 47                	js     80152a <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014e6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014ea:	75 21                	jne    80150d <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014ec:	a1 90 67 80 00       	mov    0x806790,%eax
  8014f1:	8b 40 48             	mov    0x48(%eax),%eax
  8014f4:	83 ec 04             	sub    $0x4,%esp
  8014f7:	53                   	push   %ebx
  8014f8:	50                   	push   %eax
  8014f9:	68 a9 2a 80 00       	push   $0x802aa9
  8014fe:	e8 d5 ef ff ff       	call   8004d8 <cprintf>
		return -E_INVAL;
  801503:	83 c4 10             	add    $0x10,%esp
  801506:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80150b:	eb 26                	jmp    801533 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80150d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801510:	8b 52 0c             	mov    0xc(%edx),%edx
  801513:	85 d2                	test   %edx,%edx
  801515:	74 17                	je     80152e <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801517:	83 ec 04             	sub    $0x4,%esp
  80151a:	ff 75 10             	pushl  0x10(%ebp)
  80151d:	ff 75 0c             	pushl  0xc(%ebp)
  801520:	50                   	push   %eax
  801521:	ff d2                	call   *%edx
  801523:	89 c2                	mov    %eax,%edx
  801525:	83 c4 10             	add    $0x10,%esp
  801528:	eb 09                	jmp    801533 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80152a:	89 c2                	mov    %eax,%edx
  80152c:	eb 05                	jmp    801533 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80152e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801533:	89 d0                	mov    %edx,%eax
  801535:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801538:	c9                   	leave  
  801539:	c3                   	ret    

0080153a <seek>:

int
seek(int fdnum, off_t offset)
{
  80153a:	55                   	push   %ebp
  80153b:	89 e5                	mov    %esp,%ebp
  80153d:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801540:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801543:	50                   	push   %eax
  801544:	ff 75 08             	pushl  0x8(%ebp)
  801547:	e8 22 fc ff ff       	call   80116e <fd_lookup>
  80154c:	83 c4 08             	add    $0x8,%esp
  80154f:	85 c0                	test   %eax,%eax
  801551:	78 0e                	js     801561 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801553:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801556:	8b 55 0c             	mov    0xc(%ebp),%edx
  801559:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80155c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801561:	c9                   	leave  
  801562:	c3                   	ret    

00801563 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801563:	55                   	push   %ebp
  801564:	89 e5                	mov    %esp,%ebp
  801566:	53                   	push   %ebx
  801567:	83 ec 14             	sub    $0x14,%esp
  80156a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80156d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801570:	50                   	push   %eax
  801571:	53                   	push   %ebx
  801572:	e8 f7 fb ff ff       	call   80116e <fd_lookup>
  801577:	83 c4 08             	add    $0x8,%esp
  80157a:	89 c2                	mov    %eax,%edx
  80157c:	85 c0                	test   %eax,%eax
  80157e:	78 65                	js     8015e5 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801580:	83 ec 08             	sub    $0x8,%esp
  801583:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801586:	50                   	push   %eax
  801587:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80158a:	ff 30                	pushl  (%eax)
  80158c:	e8 33 fc ff ff       	call   8011c4 <dev_lookup>
  801591:	83 c4 10             	add    $0x10,%esp
  801594:	85 c0                	test   %eax,%eax
  801596:	78 44                	js     8015dc <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801598:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80159b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80159f:	75 21                	jne    8015c2 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015a1:	a1 90 67 80 00       	mov    0x806790,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015a6:	8b 40 48             	mov    0x48(%eax),%eax
  8015a9:	83 ec 04             	sub    $0x4,%esp
  8015ac:	53                   	push   %ebx
  8015ad:	50                   	push   %eax
  8015ae:	68 6c 2a 80 00       	push   $0x802a6c
  8015b3:	e8 20 ef ff ff       	call   8004d8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8015b8:	83 c4 10             	add    $0x10,%esp
  8015bb:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015c0:	eb 23                	jmp    8015e5 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8015c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015c5:	8b 52 18             	mov    0x18(%edx),%edx
  8015c8:	85 d2                	test   %edx,%edx
  8015ca:	74 14                	je     8015e0 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015cc:	83 ec 08             	sub    $0x8,%esp
  8015cf:	ff 75 0c             	pushl  0xc(%ebp)
  8015d2:	50                   	push   %eax
  8015d3:	ff d2                	call   *%edx
  8015d5:	89 c2                	mov    %eax,%edx
  8015d7:	83 c4 10             	add    $0x10,%esp
  8015da:	eb 09                	jmp    8015e5 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015dc:	89 c2                	mov    %eax,%edx
  8015de:	eb 05                	jmp    8015e5 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8015e0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8015e5:	89 d0                	mov    %edx,%eax
  8015e7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015ea:	c9                   	leave  
  8015eb:	c3                   	ret    

008015ec <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015ec:	55                   	push   %ebp
  8015ed:	89 e5                	mov    %esp,%ebp
  8015ef:	53                   	push   %ebx
  8015f0:	83 ec 14             	sub    $0x14,%esp
  8015f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015f6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015f9:	50                   	push   %eax
  8015fa:	ff 75 08             	pushl  0x8(%ebp)
  8015fd:	e8 6c fb ff ff       	call   80116e <fd_lookup>
  801602:	83 c4 08             	add    $0x8,%esp
  801605:	89 c2                	mov    %eax,%edx
  801607:	85 c0                	test   %eax,%eax
  801609:	78 58                	js     801663 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80160b:	83 ec 08             	sub    $0x8,%esp
  80160e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801611:	50                   	push   %eax
  801612:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801615:	ff 30                	pushl  (%eax)
  801617:	e8 a8 fb ff ff       	call   8011c4 <dev_lookup>
  80161c:	83 c4 10             	add    $0x10,%esp
  80161f:	85 c0                	test   %eax,%eax
  801621:	78 37                	js     80165a <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801623:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801626:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80162a:	74 32                	je     80165e <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80162c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80162f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801636:	00 00 00 
	stat->st_isdir = 0;
  801639:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801640:	00 00 00 
	stat->st_dev = dev;
  801643:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801649:	83 ec 08             	sub    $0x8,%esp
  80164c:	53                   	push   %ebx
  80164d:	ff 75 f0             	pushl  -0x10(%ebp)
  801650:	ff 50 14             	call   *0x14(%eax)
  801653:	89 c2                	mov    %eax,%edx
  801655:	83 c4 10             	add    $0x10,%esp
  801658:	eb 09                	jmp    801663 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80165a:	89 c2                	mov    %eax,%edx
  80165c:	eb 05                	jmp    801663 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80165e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801663:	89 d0                	mov    %edx,%eax
  801665:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801668:	c9                   	leave  
  801669:	c3                   	ret    

0080166a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80166a:	55                   	push   %ebp
  80166b:	89 e5                	mov    %esp,%ebp
  80166d:	56                   	push   %esi
  80166e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80166f:	83 ec 08             	sub    $0x8,%esp
  801672:	6a 00                	push   $0x0
  801674:	ff 75 08             	pushl  0x8(%ebp)
  801677:	e8 b7 01 00 00       	call   801833 <open>
  80167c:	89 c3                	mov    %eax,%ebx
  80167e:	83 c4 10             	add    $0x10,%esp
  801681:	85 c0                	test   %eax,%eax
  801683:	78 1b                	js     8016a0 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801685:	83 ec 08             	sub    $0x8,%esp
  801688:	ff 75 0c             	pushl  0xc(%ebp)
  80168b:	50                   	push   %eax
  80168c:	e8 5b ff ff ff       	call   8015ec <fstat>
  801691:	89 c6                	mov    %eax,%esi
	close(fd);
  801693:	89 1c 24             	mov    %ebx,(%esp)
  801696:	e8 fd fb ff ff       	call   801298 <close>
	return r;
  80169b:	83 c4 10             	add    $0x10,%esp
  80169e:	89 f0                	mov    %esi,%eax
}
  8016a0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016a3:	5b                   	pop    %ebx
  8016a4:	5e                   	pop    %esi
  8016a5:	5d                   	pop    %ebp
  8016a6:	c3                   	ret    

008016a7 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016a7:	55                   	push   %ebp
  8016a8:	89 e5                	mov    %esp,%ebp
  8016aa:	56                   	push   %esi
  8016ab:	53                   	push   %ebx
  8016ac:	89 c6                	mov    %eax,%esi
  8016ae:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016b0:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8016b7:	75 12                	jne    8016cb <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016b9:	83 ec 0c             	sub    $0xc,%esp
  8016bc:	6a 01                	push   $0x1
  8016be:	e8 c8 0b 00 00       	call   80228b <ipc_find_env>
  8016c3:	a3 00 50 80 00       	mov    %eax,0x805000
  8016c8:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016cb:	6a 07                	push   $0x7
  8016cd:	68 00 70 80 00       	push   $0x807000
  8016d2:	56                   	push   %esi
  8016d3:	ff 35 00 50 80 00    	pushl  0x805000
  8016d9:	e8 59 0b 00 00       	call   802237 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016de:	83 c4 0c             	add    $0xc,%esp
  8016e1:	6a 00                	push   $0x0
  8016e3:	53                   	push   %ebx
  8016e4:	6a 00                	push   $0x0
  8016e6:	e8 d7 0a 00 00       	call   8021c2 <ipc_recv>
}
  8016eb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016ee:	5b                   	pop    %ebx
  8016ef:	5e                   	pop    %esi
  8016f0:	5d                   	pop    %ebp
  8016f1:	c3                   	ret    

008016f2 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016f2:	55                   	push   %ebp
  8016f3:	89 e5                	mov    %esp,%ebp
  8016f5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8016fb:	8b 40 0c             	mov    0xc(%eax),%eax
  8016fe:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.set_size.req_size = newsize;
  801703:	8b 45 0c             	mov    0xc(%ebp),%eax
  801706:	a3 04 70 80 00       	mov    %eax,0x807004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80170b:	ba 00 00 00 00       	mov    $0x0,%edx
  801710:	b8 02 00 00 00       	mov    $0x2,%eax
  801715:	e8 8d ff ff ff       	call   8016a7 <fsipc>
}
  80171a:	c9                   	leave  
  80171b:	c3                   	ret    

0080171c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80171c:	55                   	push   %ebp
  80171d:	89 e5                	mov    %esp,%ebp
  80171f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801722:	8b 45 08             	mov    0x8(%ebp),%eax
  801725:	8b 40 0c             	mov    0xc(%eax),%eax
  801728:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  80172d:	ba 00 00 00 00       	mov    $0x0,%edx
  801732:	b8 06 00 00 00       	mov    $0x6,%eax
  801737:	e8 6b ff ff ff       	call   8016a7 <fsipc>
}
  80173c:	c9                   	leave  
  80173d:	c3                   	ret    

0080173e <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80173e:	55                   	push   %ebp
  80173f:	89 e5                	mov    %esp,%ebp
  801741:	53                   	push   %ebx
  801742:	83 ec 04             	sub    $0x4,%esp
  801745:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801748:	8b 45 08             	mov    0x8(%ebp),%eax
  80174b:	8b 40 0c             	mov    0xc(%eax),%eax
  80174e:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801753:	ba 00 00 00 00       	mov    $0x0,%edx
  801758:	b8 05 00 00 00       	mov    $0x5,%eax
  80175d:	e8 45 ff ff ff       	call   8016a7 <fsipc>
  801762:	85 c0                	test   %eax,%eax
  801764:	78 2c                	js     801792 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801766:	83 ec 08             	sub    $0x8,%esp
  801769:	68 00 70 80 00       	push   $0x807000
  80176e:	53                   	push   %ebx
  80176f:	e8 90 f3 ff ff       	call   800b04 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801774:	a1 80 70 80 00       	mov    0x807080,%eax
  801779:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80177f:	a1 84 70 80 00       	mov    0x807084,%eax
  801784:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80178a:	83 c4 10             	add    $0x10,%esp
  80178d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801792:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801795:	c9                   	leave  
  801796:	c3                   	ret    

00801797 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801797:	55                   	push   %ebp
  801798:	89 e5                	mov    %esp,%ebp
  80179a:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  80179d:	68 d8 2a 80 00       	push   $0x802ad8
  8017a2:	68 90 00 00 00       	push   $0x90
  8017a7:	68 f6 2a 80 00       	push   $0x802af6
  8017ac:	e8 4e ec ff ff       	call   8003ff <_panic>

008017b1 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8017b1:	55                   	push   %ebp
  8017b2:	89 e5                	mov    %esp,%ebp
  8017b4:	56                   	push   %esi
  8017b5:	53                   	push   %ebx
  8017b6:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8017bc:	8b 40 0c             	mov    0xc(%eax),%eax
  8017bf:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  8017c4:	89 35 04 70 80 00    	mov    %esi,0x807004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8017cf:	b8 03 00 00 00       	mov    $0x3,%eax
  8017d4:	e8 ce fe ff ff       	call   8016a7 <fsipc>
  8017d9:	89 c3                	mov    %eax,%ebx
  8017db:	85 c0                	test   %eax,%eax
  8017dd:	78 4b                	js     80182a <devfile_read+0x79>
		return r;
	assert(r <= n);
  8017df:	39 c6                	cmp    %eax,%esi
  8017e1:	73 16                	jae    8017f9 <devfile_read+0x48>
  8017e3:	68 01 2b 80 00       	push   $0x802b01
  8017e8:	68 08 2b 80 00       	push   $0x802b08
  8017ed:	6a 7c                	push   $0x7c
  8017ef:	68 f6 2a 80 00       	push   $0x802af6
  8017f4:	e8 06 ec ff ff       	call   8003ff <_panic>
	assert(r <= PGSIZE);
  8017f9:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017fe:	7e 16                	jle    801816 <devfile_read+0x65>
  801800:	68 1d 2b 80 00       	push   $0x802b1d
  801805:	68 08 2b 80 00       	push   $0x802b08
  80180a:	6a 7d                	push   $0x7d
  80180c:	68 f6 2a 80 00       	push   $0x802af6
  801811:	e8 e9 eb ff ff       	call   8003ff <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801816:	83 ec 04             	sub    $0x4,%esp
  801819:	50                   	push   %eax
  80181a:	68 00 70 80 00       	push   $0x807000
  80181f:	ff 75 0c             	pushl  0xc(%ebp)
  801822:	e8 6f f4 ff ff       	call   800c96 <memmove>
	return r;
  801827:	83 c4 10             	add    $0x10,%esp
}
  80182a:	89 d8                	mov    %ebx,%eax
  80182c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80182f:	5b                   	pop    %ebx
  801830:	5e                   	pop    %esi
  801831:	5d                   	pop    %ebp
  801832:	c3                   	ret    

00801833 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801833:	55                   	push   %ebp
  801834:	89 e5                	mov    %esp,%ebp
  801836:	53                   	push   %ebx
  801837:	83 ec 20             	sub    $0x20,%esp
  80183a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80183d:	53                   	push   %ebx
  80183e:	e8 88 f2 ff ff       	call   800acb <strlen>
  801843:	83 c4 10             	add    $0x10,%esp
  801846:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80184b:	7f 67                	jg     8018b4 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80184d:	83 ec 0c             	sub    $0xc,%esp
  801850:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801853:	50                   	push   %eax
  801854:	e8 c6 f8 ff ff       	call   80111f <fd_alloc>
  801859:	83 c4 10             	add    $0x10,%esp
		return r;
  80185c:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80185e:	85 c0                	test   %eax,%eax
  801860:	78 57                	js     8018b9 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801862:	83 ec 08             	sub    $0x8,%esp
  801865:	53                   	push   %ebx
  801866:	68 00 70 80 00       	push   $0x807000
  80186b:	e8 94 f2 ff ff       	call   800b04 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801870:	8b 45 0c             	mov    0xc(%ebp),%eax
  801873:	a3 00 74 80 00       	mov    %eax,0x807400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801878:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80187b:	b8 01 00 00 00       	mov    $0x1,%eax
  801880:	e8 22 fe ff ff       	call   8016a7 <fsipc>
  801885:	89 c3                	mov    %eax,%ebx
  801887:	83 c4 10             	add    $0x10,%esp
  80188a:	85 c0                	test   %eax,%eax
  80188c:	79 14                	jns    8018a2 <open+0x6f>
		fd_close(fd, 0);
  80188e:	83 ec 08             	sub    $0x8,%esp
  801891:	6a 00                	push   $0x0
  801893:	ff 75 f4             	pushl  -0xc(%ebp)
  801896:	e8 7c f9 ff ff       	call   801217 <fd_close>
		return r;
  80189b:	83 c4 10             	add    $0x10,%esp
  80189e:	89 da                	mov    %ebx,%edx
  8018a0:	eb 17                	jmp    8018b9 <open+0x86>
	}

	return fd2num(fd);
  8018a2:	83 ec 0c             	sub    $0xc,%esp
  8018a5:	ff 75 f4             	pushl  -0xc(%ebp)
  8018a8:	e8 4b f8 ff ff       	call   8010f8 <fd2num>
  8018ad:	89 c2                	mov    %eax,%edx
  8018af:	83 c4 10             	add    $0x10,%esp
  8018b2:	eb 05                	jmp    8018b9 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8018b4:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8018b9:	89 d0                	mov    %edx,%eax
  8018bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018be:	c9                   	leave  
  8018bf:	c3                   	ret    

008018c0 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8018c0:	55                   	push   %ebp
  8018c1:	89 e5                	mov    %esp,%ebp
  8018c3:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8018c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8018cb:	b8 08 00 00 00       	mov    $0x8,%eax
  8018d0:	e8 d2 fd ff ff       	call   8016a7 <fsipc>
}
  8018d5:	c9                   	leave  
  8018d6:	c3                   	ret    

008018d7 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8018d7:	55                   	push   %ebp
  8018d8:	89 e5                	mov    %esp,%ebp
  8018da:	57                   	push   %edi
  8018db:	56                   	push   %esi
  8018dc:	53                   	push   %ebx
  8018dd:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8018e3:	6a 00                	push   $0x0
  8018e5:	ff 75 08             	pushl  0x8(%ebp)
  8018e8:	e8 46 ff ff ff       	call   801833 <open>
  8018ed:	89 c7                	mov    %eax,%edi
  8018ef:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  8018f5:	83 c4 10             	add    $0x10,%esp
  8018f8:	85 c0                	test   %eax,%eax
  8018fa:	0f 88 3a 04 00 00    	js     801d3a <spawn+0x463>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801900:	83 ec 04             	sub    $0x4,%esp
  801903:	68 00 02 00 00       	push   $0x200
  801908:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  80190e:	50                   	push   %eax
  80190f:	57                   	push   %edi
  801910:	e8 50 fb ff ff       	call   801465 <readn>
  801915:	83 c4 10             	add    $0x10,%esp
  801918:	3d 00 02 00 00       	cmp    $0x200,%eax
  80191d:	75 0c                	jne    80192b <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  80191f:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801926:	45 4c 46 
  801929:	74 33                	je     80195e <spawn+0x87>
		close(fd);
  80192b:	83 ec 0c             	sub    $0xc,%esp
  80192e:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801934:	e8 5f f9 ff ff       	call   801298 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801939:	83 c4 0c             	add    $0xc,%esp
  80193c:	68 7f 45 4c 46       	push   $0x464c457f
  801941:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801947:	68 29 2b 80 00       	push   $0x802b29
  80194c:	e8 87 eb ff ff       	call   8004d8 <cprintf>
		return -E_NOT_EXEC;
  801951:	83 c4 10             	add    $0x10,%esp
  801954:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  801959:	e9 3c 04 00 00       	jmp    801d9a <spawn+0x4c3>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80195e:	b8 07 00 00 00       	mov    $0x7,%eax
  801963:	cd 30                	int    $0x30
  801965:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  80196b:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801971:	85 c0                	test   %eax,%eax
  801973:	0f 88 c9 03 00 00    	js     801d42 <spawn+0x46b>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801979:	89 c6                	mov    %eax,%esi
  80197b:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801981:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801984:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  80198a:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801990:	b9 11 00 00 00       	mov    $0x11,%ecx
  801995:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801997:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  80199d:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8019a3:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  8019a8:	be 00 00 00 00       	mov    $0x0,%esi
  8019ad:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8019b0:	eb 13                	jmp    8019c5 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  8019b2:	83 ec 0c             	sub    $0xc,%esp
  8019b5:	50                   	push   %eax
  8019b6:	e8 10 f1 ff ff       	call   800acb <strlen>
  8019bb:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8019bf:	83 c3 01             	add    $0x1,%ebx
  8019c2:	83 c4 10             	add    $0x10,%esp
  8019c5:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  8019cc:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  8019cf:	85 c0                	test   %eax,%eax
  8019d1:	75 df                	jne    8019b2 <spawn+0xdb>
  8019d3:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  8019d9:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  8019df:	bf 00 10 40 00       	mov    $0x401000,%edi
  8019e4:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  8019e6:	89 fa                	mov    %edi,%edx
  8019e8:	83 e2 fc             	and    $0xfffffffc,%edx
  8019eb:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  8019f2:	29 c2                	sub    %eax,%edx
  8019f4:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  8019fa:	8d 42 f8             	lea    -0x8(%edx),%eax
  8019fd:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801a02:	0f 86 4a 03 00 00    	jbe    801d52 <spawn+0x47b>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801a08:	83 ec 04             	sub    $0x4,%esp
  801a0b:	6a 07                	push   $0x7
  801a0d:	68 00 00 40 00       	push   $0x400000
  801a12:	6a 00                	push   $0x0
  801a14:	e8 ee f4 ff ff       	call   800f07 <sys_page_alloc>
  801a19:	83 c4 10             	add    $0x10,%esp
  801a1c:	85 c0                	test   %eax,%eax
  801a1e:	0f 88 35 03 00 00    	js     801d59 <spawn+0x482>
  801a24:	be 00 00 00 00       	mov    $0x0,%esi
  801a29:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801a2f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a32:	eb 30                	jmp    801a64 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801a34:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801a3a:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801a40:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801a43:	83 ec 08             	sub    $0x8,%esp
  801a46:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801a49:	57                   	push   %edi
  801a4a:	e8 b5 f0 ff ff       	call   800b04 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801a4f:	83 c4 04             	add    $0x4,%esp
  801a52:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801a55:	e8 71 f0 ff ff       	call   800acb <strlen>
  801a5a:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801a5e:	83 c6 01             	add    $0x1,%esi
  801a61:	83 c4 10             	add    $0x10,%esp
  801a64:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801a6a:	7f c8                	jg     801a34 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801a6c:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801a72:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801a78:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801a7f:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801a85:	74 19                	je     801aa0 <spawn+0x1c9>
  801a87:	68 a0 2b 80 00       	push   $0x802ba0
  801a8c:	68 08 2b 80 00       	push   $0x802b08
  801a91:	68 f2 00 00 00       	push   $0xf2
  801a96:	68 43 2b 80 00       	push   $0x802b43
  801a9b:	e8 5f e9 ff ff       	call   8003ff <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801aa0:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801aa6:	89 c8                	mov    %ecx,%eax
  801aa8:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801aad:	89 41 fc             	mov    %eax,-0x4(%ecx)
	argv_store[-2] = argc;
  801ab0:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801ab6:	89 41 f8             	mov    %eax,-0x8(%ecx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801ab9:	8d 81 f8 cf 7f ee    	lea    -0x11803008(%ecx),%eax
  801abf:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801ac5:	83 ec 0c             	sub    $0xc,%esp
  801ac8:	6a 07                	push   $0x7
  801aca:	68 00 d0 bf ee       	push   $0xeebfd000
  801acf:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801ad5:	68 00 00 40 00       	push   $0x400000
  801ada:	6a 00                	push   $0x0
  801adc:	e8 69 f4 ff ff       	call   800f4a <sys_page_map>
  801ae1:	89 c3                	mov    %eax,%ebx
  801ae3:	83 c4 20             	add    $0x20,%esp
  801ae6:	85 c0                	test   %eax,%eax
  801ae8:	0f 88 9a 02 00 00    	js     801d88 <spawn+0x4b1>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801aee:	83 ec 08             	sub    $0x8,%esp
  801af1:	68 00 00 40 00       	push   $0x400000
  801af6:	6a 00                	push   $0x0
  801af8:	e8 8f f4 ff ff       	call   800f8c <sys_page_unmap>
  801afd:	89 c3                	mov    %eax,%ebx
  801aff:	83 c4 10             	add    $0x10,%esp
  801b02:	85 c0                	test   %eax,%eax
  801b04:	0f 88 7e 02 00 00    	js     801d88 <spawn+0x4b1>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801b0a:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801b10:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801b17:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801b1d:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801b24:	00 00 00 
  801b27:	e9 86 01 00 00       	jmp    801cb2 <spawn+0x3db>
		if (ph->p_type != ELF_PROG_LOAD)
  801b2c:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801b32:	83 38 01             	cmpl   $0x1,(%eax)
  801b35:	0f 85 69 01 00 00    	jne    801ca4 <spawn+0x3cd>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801b3b:	89 c1                	mov    %eax,%ecx
  801b3d:	8b 40 18             	mov    0x18(%eax),%eax
  801b40:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801b46:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801b49:	83 f8 01             	cmp    $0x1,%eax
  801b4c:	19 c0                	sbb    %eax,%eax
  801b4e:	83 e0 fe             	and    $0xfffffffe,%eax
  801b51:	83 c0 07             	add    $0x7,%eax
  801b54:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801b5a:	89 c8                	mov    %ecx,%eax
  801b5c:	8b 49 04             	mov    0x4(%ecx),%ecx
  801b5f:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
  801b65:	8b 78 10             	mov    0x10(%eax),%edi
  801b68:	8b 50 14             	mov    0x14(%eax),%edx
  801b6b:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  801b71:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801b74:	89 f0                	mov    %esi,%eax
  801b76:	25 ff 0f 00 00       	and    $0xfff,%eax
  801b7b:	74 14                	je     801b91 <spawn+0x2ba>
		va -= i;
  801b7d:	29 c6                	sub    %eax,%esi
		memsz += i;
  801b7f:	01 c2                	add    %eax,%edx
  801b81:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  801b87:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801b89:	29 c1                	sub    %eax,%ecx
  801b8b:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801b91:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b96:	e9 f7 00 00 00       	jmp    801c92 <spawn+0x3bb>
		if (i >= filesz) {
  801b9b:	39 df                	cmp    %ebx,%edi
  801b9d:	77 27                	ja     801bc6 <spawn+0x2ef>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801b9f:	83 ec 04             	sub    $0x4,%esp
  801ba2:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801ba8:	56                   	push   %esi
  801ba9:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801baf:	e8 53 f3 ff ff       	call   800f07 <sys_page_alloc>
  801bb4:	83 c4 10             	add    $0x10,%esp
  801bb7:	85 c0                	test   %eax,%eax
  801bb9:	0f 89 c7 00 00 00    	jns    801c86 <spawn+0x3af>
  801bbf:	89 c3                	mov    %eax,%ebx
  801bc1:	e9 a1 01 00 00       	jmp    801d67 <spawn+0x490>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801bc6:	83 ec 04             	sub    $0x4,%esp
  801bc9:	6a 07                	push   $0x7
  801bcb:	68 00 00 40 00       	push   $0x400000
  801bd0:	6a 00                	push   $0x0
  801bd2:	e8 30 f3 ff ff       	call   800f07 <sys_page_alloc>
  801bd7:	83 c4 10             	add    $0x10,%esp
  801bda:	85 c0                	test   %eax,%eax
  801bdc:	0f 88 7b 01 00 00    	js     801d5d <spawn+0x486>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801be2:	83 ec 08             	sub    $0x8,%esp
  801be5:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801beb:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801bf1:	50                   	push   %eax
  801bf2:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801bf8:	e8 3d f9 ff ff       	call   80153a <seek>
  801bfd:	83 c4 10             	add    $0x10,%esp
  801c00:	85 c0                	test   %eax,%eax
  801c02:	0f 88 59 01 00 00    	js     801d61 <spawn+0x48a>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801c08:	83 ec 04             	sub    $0x4,%esp
  801c0b:	89 f8                	mov    %edi,%eax
  801c0d:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801c13:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801c18:	b9 00 10 00 00       	mov    $0x1000,%ecx
  801c1d:	0f 47 c1             	cmova  %ecx,%eax
  801c20:	50                   	push   %eax
  801c21:	68 00 00 40 00       	push   $0x400000
  801c26:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801c2c:	e8 34 f8 ff ff       	call   801465 <readn>
  801c31:	83 c4 10             	add    $0x10,%esp
  801c34:	85 c0                	test   %eax,%eax
  801c36:	0f 88 29 01 00 00    	js     801d65 <spawn+0x48e>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801c3c:	83 ec 0c             	sub    $0xc,%esp
  801c3f:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801c45:	56                   	push   %esi
  801c46:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801c4c:	68 00 00 40 00       	push   $0x400000
  801c51:	6a 00                	push   $0x0
  801c53:	e8 f2 f2 ff ff       	call   800f4a <sys_page_map>
  801c58:	83 c4 20             	add    $0x20,%esp
  801c5b:	85 c0                	test   %eax,%eax
  801c5d:	79 15                	jns    801c74 <spawn+0x39d>
				panic("spawn: sys_page_map data: %e", r);
  801c5f:	50                   	push   %eax
  801c60:	68 4f 2b 80 00       	push   $0x802b4f
  801c65:	68 25 01 00 00       	push   $0x125
  801c6a:	68 43 2b 80 00       	push   $0x802b43
  801c6f:	e8 8b e7 ff ff       	call   8003ff <_panic>
			sys_page_unmap(0, UTEMP);
  801c74:	83 ec 08             	sub    $0x8,%esp
  801c77:	68 00 00 40 00       	push   $0x400000
  801c7c:	6a 00                	push   $0x0
  801c7e:	e8 09 f3 ff ff       	call   800f8c <sys_page_unmap>
  801c83:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801c86:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801c8c:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801c92:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801c98:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  801c9e:	0f 87 f7 fe ff ff    	ja     801b9b <spawn+0x2c4>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801ca4:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801cab:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801cb2:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801cb9:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801cbf:	0f 8c 67 fe ff ff    	jl     801b2c <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801cc5:	83 ec 0c             	sub    $0xc,%esp
  801cc8:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801cce:	e8 c5 f5 ff ff       	call   801298 <close>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801cd3:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801cda:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801cdd:	83 c4 08             	add    $0x8,%esp
  801ce0:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801ce6:	50                   	push   %eax
  801ce7:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801ced:	e8 1e f3 ff ff       	call   801010 <sys_env_set_trapframe>
  801cf2:	83 c4 10             	add    $0x10,%esp
  801cf5:	85 c0                	test   %eax,%eax
  801cf7:	79 15                	jns    801d0e <spawn+0x437>
		panic("sys_env_set_trapframe: %e", r);
  801cf9:	50                   	push   %eax
  801cfa:	68 6c 2b 80 00       	push   $0x802b6c
  801cff:	68 86 00 00 00       	push   $0x86
  801d04:	68 43 2b 80 00       	push   $0x802b43
  801d09:	e8 f1 e6 ff ff       	call   8003ff <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801d0e:	83 ec 08             	sub    $0x8,%esp
  801d11:	6a 02                	push   $0x2
  801d13:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801d19:	e8 b0 f2 ff ff       	call   800fce <sys_env_set_status>
  801d1e:	83 c4 10             	add    $0x10,%esp
  801d21:	85 c0                	test   %eax,%eax
  801d23:	79 25                	jns    801d4a <spawn+0x473>
		panic("sys_env_set_status: %e", r);
  801d25:	50                   	push   %eax
  801d26:	68 86 2b 80 00       	push   $0x802b86
  801d2b:	68 89 00 00 00       	push   $0x89
  801d30:	68 43 2b 80 00       	push   $0x802b43
  801d35:	e8 c5 e6 ff ff       	call   8003ff <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801d3a:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801d40:	eb 58                	jmp    801d9a <spawn+0x4c3>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801d42:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801d48:	eb 50                	jmp    801d9a <spawn+0x4c3>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801d4a:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801d50:	eb 48                	jmp    801d9a <spawn+0x4c3>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801d52:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801d57:	eb 41                	jmp    801d9a <spawn+0x4c3>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801d59:	89 c3                	mov    %eax,%ebx
  801d5b:	eb 3d                	jmp    801d9a <spawn+0x4c3>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801d5d:	89 c3                	mov    %eax,%ebx
  801d5f:	eb 06                	jmp    801d67 <spawn+0x490>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801d61:	89 c3                	mov    %eax,%ebx
  801d63:	eb 02                	jmp    801d67 <spawn+0x490>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801d65:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801d67:	83 ec 0c             	sub    $0xc,%esp
  801d6a:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801d70:	e8 13 f1 ff ff       	call   800e88 <sys_env_destroy>
	close(fd);
  801d75:	83 c4 04             	add    $0x4,%esp
  801d78:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801d7e:	e8 15 f5 ff ff       	call   801298 <close>
	return r;
  801d83:	83 c4 10             	add    $0x10,%esp
  801d86:	eb 12                	jmp    801d9a <spawn+0x4c3>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801d88:	83 ec 08             	sub    $0x8,%esp
  801d8b:	68 00 00 40 00       	push   $0x400000
  801d90:	6a 00                	push   $0x0
  801d92:	e8 f5 f1 ff ff       	call   800f8c <sys_page_unmap>
  801d97:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801d9a:	89 d8                	mov    %ebx,%eax
  801d9c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d9f:	5b                   	pop    %ebx
  801da0:	5e                   	pop    %esi
  801da1:	5f                   	pop    %edi
  801da2:	5d                   	pop    %ebp
  801da3:	c3                   	ret    

00801da4 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801da4:	55                   	push   %ebp
  801da5:	89 e5                	mov    %esp,%ebp
  801da7:	56                   	push   %esi
  801da8:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801da9:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801dac:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801db1:	eb 03                	jmp    801db6 <spawnl+0x12>
		argc++;
  801db3:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801db6:	83 c2 04             	add    $0x4,%edx
  801db9:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801dbd:	75 f4                	jne    801db3 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801dbf:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801dc6:	83 e2 f0             	and    $0xfffffff0,%edx
  801dc9:	29 d4                	sub    %edx,%esp
  801dcb:	8d 54 24 03          	lea    0x3(%esp),%edx
  801dcf:	c1 ea 02             	shr    $0x2,%edx
  801dd2:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801dd9:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801ddb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801dde:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801de5:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801dec:	00 
  801ded:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801def:	b8 00 00 00 00       	mov    $0x0,%eax
  801df4:	eb 0a                	jmp    801e00 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801df6:	83 c0 01             	add    $0x1,%eax
  801df9:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801dfd:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801e00:	39 d0                	cmp    %edx,%eax
  801e02:	75 f2                	jne    801df6 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801e04:	83 ec 08             	sub    $0x8,%esp
  801e07:	56                   	push   %esi
  801e08:	ff 75 08             	pushl  0x8(%ebp)
  801e0b:	e8 c7 fa ff ff       	call   8018d7 <spawn>
}
  801e10:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e13:	5b                   	pop    %ebx
  801e14:	5e                   	pop    %esi
  801e15:	5d                   	pop    %ebp
  801e16:	c3                   	ret    

00801e17 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801e17:	55                   	push   %ebp
  801e18:	89 e5                	mov    %esp,%ebp
  801e1a:	56                   	push   %esi
  801e1b:	53                   	push   %ebx
  801e1c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801e1f:	83 ec 0c             	sub    $0xc,%esp
  801e22:	ff 75 08             	pushl  0x8(%ebp)
  801e25:	e8 de f2 ff ff       	call   801108 <fd2data>
  801e2a:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801e2c:	83 c4 08             	add    $0x8,%esp
  801e2f:	68 c8 2b 80 00       	push   $0x802bc8
  801e34:	53                   	push   %ebx
  801e35:	e8 ca ec ff ff       	call   800b04 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e3a:	8b 46 04             	mov    0x4(%esi),%eax
  801e3d:	2b 06                	sub    (%esi),%eax
  801e3f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801e45:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801e4c:	00 00 00 
	stat->st_dev = &devpipe;
  801e4f:	c7 83 88 00 00 00 ac 	movl   $0x8047ac,0x88(%ebx)
  801e56:	47 80 00 
	return 0;
}
  801e59:	b8 00 00 00 00       	mov    $0x0,%eax
  801e5e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e61:	5b                   	pop    %ebx
  801e62:	5e                   	pop    %esi
  801e63:	5d                   	pop    %ebp
  801e64:	c3                   	ret    

00801e65 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801e65:	55                   	push   %ebp
  801e66:	89 e5                	mov    %esp,%ebp
  801e68:	53                   	push   %ebx
  801e69:	83 ec 0c             	sub    $0xc,%esp
  801e6c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801e6f:	53                   	push   %ebx
  801e70:	6a 00                	push   $0x0
  801e72:	e8 15 f1 ff ff       	call   800f8c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801e77:	89 1c 24             	mov    %ebx,(%esp)
  801e7a:	e8 89 f2 ff ff       	call   801108 <fd2data>
  801e7f:	83 c4 08             	add    $0x8,%esp
  801e82:	50                   	push   %eax
  801e83:	6a 00                	push   $0x0
  801e85:	e8 02 f1 ff ff       	call   800f8c <sys_page_unmap>
}
  801e8a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e8d:	c9                   	leave  
  801e8e:	c3                   	ret    

00801e8f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801e8f:	55                   	push   %ebp
  801e90:	89 e5                	mov    %esp,%ebp
  801e92:	57                   	push   %edi
  801e93:	56                   	push   %esi
  801e94:	53                   	push   %ebx
  801e95:	83 ec 1c             	sub    $0x1c,%esp
  801e98:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801e9b:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801e9d:	a1 90 67 80 00       	mov    0x806790,%eax
  801ea2:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801ea5:	83 ec 0c             	sub    $0xc,%esp
  801ea8:	ff 75 e0             	pushl  -0x20(%ebp)
  801eab:	e8 14 04 00 00       	call   8022c4 <pageref>
  801eb0:	89 c3                	mov    %eax,%ebx
  801eb2:	89 3c 24             	mov    %edi,(%esp)
  801eb5:	e8 0a 04 00 00       	call   8022c4 <pageref>
  801eba:	83 c4 10             	add    $0x10,%esp
  801ebd:	39 c3                	cmp    %eax,%ebx
  801ebf:	0f 94 c1             	sete   %cl
  801ec2:	0f b6 c9             	movzbl %cl,%ecx
  801ec5:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801ec8:	8b 15 90 67 80 00    	mov    0x806790,%edx
  801ece:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ed1:	39 ce                	cmp    %ecx,%esi
  801ed3:	74 1b                	je     801ef0 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801ed5:	39 c3                	cmp    %eax,%ebx
  801ed7:	75 c4                	jne    801e9d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ed9:	8b 42 58             	mov    0x58(%edx),%eax
  801edc:	ff 75 e4             	pushl  -0x1c(%ebp)
  801edf:	50                   	push   %eax
  801ee0:	56                   	push   %esi
  801ee1:	68 cf 2b 80 00       	push   $0x802bcf
  801ee6:	e8 ed e5 ff ff       	call   8004d8 <cprintf>
  801eeb:	83 c4 10             	add    $0x10,%esp
  801eee:	eb ad                	jmp    801e9d <_pipeisclosed+0xe>
	}
}
  801ef0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ef3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ef6:	5b                   	pop    %ebx
  801ef7:	5e                   	pop    %esi
  801ef8:	5f                   	pop    %edi
  801ef9:	5d                   	pop    %ebp
  801efa:	c3                   	ret    

00801efb <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801efb:	55                   	push   %ebp
  801efc:	89 e5                	mov    %esp,%ebp
  801efe:	57                   	push   %edi
  801eff:	56                   	push   %esi
  801f00:	53                   	push   %ebx
  801f01:	83 ec 28             	sub    $0x28,%esp
  801f04:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801f07:	56                   	push   %esi
  801f08:	e8 fb f1 ff ff       	call   801108 <fd2data>
  801f0d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f0f:	83 c4 10             	add    $0x10,%esp
  801f12:	bf 00 00 00 00       	mov    $0x0,%edi
  801f17:	eb 4b                	jmp    801f64 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801f19:	89 da                	mov    %ebx,%edx
  801f1b:	89 f0                	mov    %esi,%eax
  801f1d:	e8 6d ff ff ff       	call   801e8f <_pipeisclosed>
  801f22:	85 c0                	test   %eax,%eax
  801f24:	75 48                	jne    801f6e <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801f26:	e8 bd ef ff ff       	call   800ee8 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f2b:	8b 43 04             	mov    0x4(%ebx),%eax
  801f2e:	8b 0b                	mov    (%ebx),%ecx
  801f30:	8d 51 20             	lea    0x20(%ecx),%edx
  801f33:	39 d0                	cmp    %edx,%eax
  801f35:	73 e2                	jae    801f19 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f3a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801f3e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801f41:	89 c2                	mov    %eax,%edx
  801f43:	c1 fa 1f             	sar    $0x1f,%edx
  801f46:	89 d1                	mov    %edx,%ecx
  801f48:	c1 e9 1b             	shr    $0x1b,%ecx
  801f4b:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801f4e:	83 e2 1f             	and    $0x1f,%edx
  801f51:	29 ca                	sub    %ecx,%edx
  801f53:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801f57:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801f5b:	83 c0 01             	add    $0x1,%eax
  801f5e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f61:	83 c7 01             	add    $0x1,%edi
  801f64:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801f67:	75 c2                	jne    801f2b <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801f69:	8b 45 10             	mov    0x10(%ebp),%eax
  801f6c:	eb 05                	jmp    801f73 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f6e:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801f73:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f76:	5b                   	pop    %ebx
  801f77:	5e                   	pop    %esi
  801f78:	5f                   	pop    %edi
  801f79:	5d                   	pop    %ebp
  801f7a:	c3                   	ret    

00801f7b <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f7b:	55                   	push   %ebp
  801f7c:	89 e5                	mov    %esp,%ebp
  801f7e:	57                   	push   %edi
  801f7f:	56                   	push   %esi
  801f80:	53                   	push   %ebx
  801f81:	83 ec 18             	sub    $0x18,%esp
  801f84:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801f87:	57                   	push   %edi
  801f88:	e8 7b f1 ff ff       	call   801108 <fd2data>
  801f8d:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f8f:	83 c4 10             	add    $0x10,%esp
  801f92:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f97:	eb 3d                	jmp    801fd6 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801f99:	85 db                	test   %ebx,%ebx
  801f9b:	74 04                	je     801fa1 <devpipe_read+0x26>
				return i;
  801f9d:	89 d8                	mov    %ebx,%eax
  801f9f:	eb 44                	jmp    801fe5 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801fa1:	89 f2                	mov    %esi,%edx
  801fa3:	89 f8                	mov    %edi,%eax
  801fa5:	e8 e5 fe ff ff       	call   801e8f <_pipeisclosed>
  801faa:	85 c0                	test   %eax,%eax
  801fac:	75 32                	jne    801fe0 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801fae:	e8 35 ef ff ff       	call   800ee8 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801fb3:	8b 06                	mov    (%esi),%eax
  801fb5:	3b 46 04             	cmp    0x4(%esi),%eax
  801fb8:	74 df                	je     801f99 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801fba:	99                   	cltd   
  801fbb:	c1 ea 1b             	shr    $0x1b,%edx
  801fbe:	01 d0                	add    %edx,%eax
  801fc0:	83 e0 1f             	and    $0x1f,%eax
  801fc3:	29 d0                	sub    %edx,%eax
  801fc5:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801fca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801fcd:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801fd0:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fd3:	83 c3 01             	add    $0x1,%ebx
  801fd6:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801fd9:	75 d8                	jne    801fb3 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801fdb:	8b 45 10             	mov    0x10(%ebp),%eax
  801fde:	eb 05                	jmp    801fe5 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801fe0:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801fe5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fe8:	5b                   	pop    %ebx
  801fe9:	5e                   	pop    %esi
  801fea:	5f                   	pop    %edi
  801feb:	5d                   	pop    %ebp
  801fec:	c3                   	ret    

00801fed <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801fed:	55                   	push   %ebp
  801fee:	89 e5                	mov    %esp,%ebp
  801ff0:	56                   	push   %esi
  801ff1:	53                   	push   %ebx
  801ff2:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ff5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ff8:	50                   	push   %eax
  801ff9:	e8 21 f1 ff ff       	call   80111f <fd_alloc>
  801ffe:	83 c4 10             	add    $0x10,%esp
  802001:	89 c2                	mov    %eax,%edx
  802003:	85 c0                	test   %eax,%eax
  802005:	0f 88 2c 01 00 00    	js     802137 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80200b:	83 ec 04             	sub    $0x4,%esp
  80200e:	68 07 04 00 00       	push   $0x407
  802013:	ff 75 f4             	pushl  -0xc(%ebp)
  802016:	6a 00                	push   $0x0
  802018:	e8 ea ee ff ff       	call   800f07 <sys_page_alloc>
  80201d:	83 c4 10             	add    $0x10,%esp
  802020:	89 c2                	mov    %eax,%edx
  802022:	85 c0                	test   %eax,%eax
  802024:	0f 88 0d 01 00 00    	js     802137 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80202a:	83 ec 0c             	sub    $0xc,%esp
  80202d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802030:	50                   	push   %eax
  802031:	e8 e9 f0 ff ff       	call   80111f <fd_alloc>
  802036:	89 c3                	mov    %eax,%ebx
  802038:	83 c4 10             	add    $0x10,%esp
  80203b:	85 c0                	test   %eax,%eax
  80203d:	0f 88 e2 00 00 00    	js     802125 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802043:	83 ec 04             	sub    $0x4,%esp
  802046:	68 07 04 00 00       	push   $0x407
  80204b:	ff 75 f0             	pushl  -0x10(%ebp)
  80204e:	6a 00                	push   $0x0
  802050:	e8 b2 ee ff ff       	call   800f07 <sys_page_alloc>
  802055:	89 c3                	mov    %eax,%ebx
  802057:	83 c4 10             	add    $0x10,%esp
  80205a:	85 c0                	test   %eax,%eax
  80205c:	0f 88 c3 00 00 00    	js     802125 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802062:	83 ec 0c             	sub    $0xc,%esp
  802065:	ff 75 f4             	pushl  -0xc(%ebp)
  802068:	e8 9b f0 ff ff       	call   801108 <fd2data>
  80206d:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80206f:	83 c4 0c             	add    $0xc,%esp
  802072:	68 07 04 00 00       	push   $0x407
  802077:	50                   	push   %eax
  802078:	6a 00                	push   $0x0
  80207a:	e8 88 ee ff ff       	call   800f07 <sys_page_alloc>
  80207f:	89 c3                	mov    %eax,%ebx
  802081:	83 c4 10             	add    $0x10,%esp
  802084:	85 c0                	test   %eax,%eax
  802086:	0f 88 89 00 00 00    	js     802115 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80208c:	83 ec 0c             	sub    $0xc,%esp
  80208f:	ff 75 f0             	pushl  -0x10(%ebp)
  802092:	e8 71 f0 ff ff       	call   801108 <fd2data>
  802097:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80209e:	50                   	push   %eax
  80209f:	6a 00                	push   $0x0
  8020a1:	56                   	push   %esi
  8020a2:	6a 00                	push   $0x0
  8020a4:	e8 a1 ee ff ff       	call   800f4a <sys_page_map>
  8020a9:	89 c3                	mov    %eax,%ebx
  8020ab:	83 c4 20             	add    $0x20,%esp
  8020ae:	85 c0                	test   %eax,%eax
  8020b0:	78 55                	js     802107 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8020b2:	8b 15 ac 47 80 00    	mov    0x8047ac,%edx
  8020b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020bb:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8020bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020c0:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8020c7:	8b 15 ac 47 80 00    	mov    0x8047ac,%edx
  8020cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020d0:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8020d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020d5:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8020dc:	83 ec 0c             	sub    $0xc,%esp
  8020df:	ff 75 f4             	pushl  -0xc(%ebp)
  8020e2:	e8 11 f0 ff ff       	call   8010f8 <fd2num>
  8020e7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020ea:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8020ec:	83 c4 04             	add    $0x4,%esp
  8020ef:	ff 75 f0             	pushl  -0x10(%ebp)
  8020f2:	e8 01 f0 ff ff       	call   8010f8 <fd2num>
  8020f7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020fa:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8020fd:	83 c4 10             	add    $0x10,%esp
  802100:	ba 00 00 00 00       	mov    $0x0,%edx
  802105:	eb 30                	jmp    802137 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802107:	83 ec 08             	sub    $0x8,%esp
  80210a:	56                   	push   %esi
  80210b:	6a 00                	push   $0x0
  80210d:	e8 7a ee ff ff       	call   800f8c <sys_page_unmap>
  802112:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802115:	83 ec 08             	sub    $0x8,%esp
  802118:	ff 75 f0             	pushl  -0x10(%ebp)
  80211b:	6a 00                	push   $0x0
  80211d:	e8 6a ee ff ff       	call   800f8c <sys_page_unmap>
  802122:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802125:	83 ec 08             	sub    $0x8,%esp
  802128:	ff 75 f4             	pushl  -0xc(%ebp)
  80212b:	6a 00                	push   $0x0
  80212d:	e8 5a ee ff ff       	call   800f8c <sys_page_unmap>
  802132:	83 c4 10             	add    $0x10,%esp
  802135:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802137:	89 d0                	mov    %edx,%eax
  802139:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80213c:	5b                   	pop    %ebx
  80213d:	5e                   	pop    %esi
  80213e:	5d                   	pop    %ebp
  80213f:	c3                   	ret    

00802140 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802140:	55                   	push   %ebp
  802141:	89 e5                	mov    %esp,%ebp
  802143:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802146:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802149:	50                   	push   %eax
  80214a:	ff 75 08             	pushl  0x8(%ebp)
  80214d:	e8 1c f0 ff ff       	call   80116e <fd_lookup>
  802152:	83 c4 10             	add    $0x10,%esp
  802155:	85 c0                	test   %eax,%eax
  802157:	78 18                	js     802171 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802159:	83 ec 0c             	sub    $0xc,%esp
  80215c:	ff 75 f4             	pushl  -0xc(%ebp)
  80215f:	e8 a4 ef ff ff       	call   801108 <fd2data>
	return _pipeisclosed(fd, p);
  802164:	89 c2                	mov    %eax,%edx
  802166:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802169:	e8 21 fd ff ff       	call   801e8f <_pipeisclosed>
  80216e:	83 c4 10             	add    $0x10,%esp
}
  802171:	c9                   	leave  
  802172:	c3                   	ret    

00802173 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802173:	55                   	push   %ebp
  802174:	89 e5                	mov    %esp,%ebp
  802176:	56                   	push   %esi
  802177:	53                   	push   %ebx
  802178:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  80217b:	85 f6                	test   %esi,%esi
  80217d:	75 16                	jne    802195 <wait+0x22>
  80217f:	68 e7 2b 80 00       	push   $0x802be7
  802184:	68 08 2b 80 00       	push   $0x802b08
  802189:	6a 09                	push   $0x9
  80218b:	68 f2 2b 80 00       	push   $0x802bf2
  802190:	e8 6a e2 ff ff       	call   8003ff <_panic>
	e = &envs[ENVX(envid)];
  802195:	89 f3                	mov    %esi,%ebx
  802197:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80219d:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  8021a0:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  8021a6:	eb 05                	jmp    8021ad <wait+0x3a>
		sys_yield();
  8021a8:	e8 3b ed ff ff       	call   800ee8 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8021ad:	8b 43 48             	mov    0x48(%ebx),%eax
  8021b0:	39 c6                	cmp    %eax,%esi
  8021b2:	75 07                	jne    8021bb <wait+0x48>
  8021b4:	8b 43 54             	mov    0x54(%ebx),%eax
  8021b7:	85 c0                	test   %eax,%eax
  8021b9:	75 ed                	jne    8021a8 <wait+0x35>
		sys_yield();
}
  8021bb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021be:	5b                   	pop    %ebx
  8021bf:	5e                   	pop    %esi
  8021c0:	5d                   	pop    %ebp
  8021c1:	c3                   	ret    

008021c2 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8021c2:	55                   	push   %ebp
  8021c3:	89 e5                	mov    %esp,%ebp
  8021c5:	56                   	push   %esi
  8021c6:	53                   	push   %ebx
  8021c7:	8b 75 08             	mov    0x8(%ebp),%esi
  8021ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021cd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int ret;
	if (pg) ret = sys_ipc_recv(pg);
  8021d0:	85 c0                	test   %eax,%eax
  8021d2:	74 0e                	je     8021e2 <ipc_recv+0x20>
  8021d4:	83 ec 0c             	sub    $0xc,%esp
  8021d7:	50                   	push   %eax
  8021d8:	e8 da ee ff ff       	call   8010b7 <sys_ipc_recv>
  8021dd:	83 c4 10             	add    $0x10,%esp
  8021e0:	eb 10                	jmp    8021f2 <ipc_recv+0x30>
	else ret = sys_ipc_recv((void*)UTOP);
  8021e2:	83 ec 0c             	sub    $0xc,%esp
  8021e5:	68 00 00 c0 ee       	push   $0xeec00000
  8021ea:	e8 c8 ee ff ff       	call   8010b7 <sys_ipc_recv>
  8021ef:	83 c4 10             	add    $0x10,%esp
	if (ret) {
  8021f2:	85 c0                	test   %eax,%eax
  8021f4:	74 16                	je     80220c <ipc_recv+0x4a>
		if (from_env_store) *from_env_store = 0;
  8021f6:	85 f6                	test   %esi,%esi
  8021f8:	74 06                	je     802200 <ipc_recv+0x3e>
  8021fa:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  802200:	85 db                	test   %ebx,%ebx
  802202:	74 2c                	je     802230 <ipc_recv+0x6e>
  802204:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80220a:	eb 24                	jmp    802230 <ipc_recv+0x6e>
		return ret;
	}
	if (from_env_store) *from_env_store = thisenv->env_ipc_from;
  80220c:	85 f6                	test   %esi,%esi
  80220e:	74 0a                	je     80221a <ipc_recv+0x58>
  802210:	a1 90 67 80 00       	mov    0x806790,%eax
  802215:	8b 40 74             	mov    0x74(%eax),%eax
  802218:	89 06                	mov    %eax,(%esi)
	if (perm_store) *perm_store = thisenv->env_ipc_perm;
  80221a:	85 db                	test   %ebx,%ebx
  80221c:	74 0a                	je     802228 <ipc_recv+0x66>
  80221e:	a1 90 67 80 00       	mov    0x806790,%eax
  802223:	8b 40 78             	mov    0x78(%eax),%eax
  802226:	89 03                	mov    %eax,(%ebx)

	// panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802228:	a1 90 67 80 00       	mov    0x806790,%eax
  80222d:	8b 40 70             	mov    0x70(%eax),%eax
}
  802230:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802233:	5b                   	pop    %ebx
  802234:	5e                   	pop    %esi
  802235:	5d                   	pop    %ebp
  802236:	c3                   	ret    

00802237 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802237:	55                   	push   %ebp
  802238:	89 e5                	mov    %esp,%ebp
  80223a:	57                   	push   %edi
  80223b:	56                   	push   %esi
  80223c:	53                   	push   %ebx
  80223d:	83 ec 0c             	sub    $0xc,%esp
  802240:	8b 7d 08             	mov    0x8(%ebp),%edi
  802243:	8b 75 0c             	mov    0xc(%ebp),%esi
  802246:	8b 45 10             	mov    0x10(%ebp),%eax
  802249:	85 c0                	test   %eax,%eax
  80224b:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  802250:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	while (true) {
		void* srcva = (pg)? pg: (void*)UTOP;
		int ret = sys_ipc_try_send(to_env, val, srcva, perm);
  802253:	ff 75 14             	pushl  0x14(%ebp)
  802256:	53                   	push   %ebx
  802257:	56                   	push   %esi
  802258:	57                   	push   %edi
  802259:	e8 36 ee ff ff       	call   801094 <sys_ipc_try_send>
		if (ret == 0) break;
  80225e:	83 c4 10             	add    $0x10,%esp
  802261:	85 c0                	test   %eax,%eax
  802263:	74 1e                	je     802283 <ipc_send+0x4c>
		if (ret != -E_IPC_NOT_RECV) panic("ipc_send: %e", ret);
  802265:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802268:	74 12                	je     80227c <ipc_send+0x45>
  80226a:	50                   	push   %eax
  80226b:	68 fd 2b 80 00       	push   $0x802bfd
  802270:	6a 39                	push   $0x39
  802272:	68 0a 2c 80 00       	push   $0x802c0a
  802277:	e8 83 e1 ff ff       	call   8003ff <_panic>
		sys_yield();
  80227c:	e8 67 ec ff ff       	call   800ee8 <sys_yield>
	}
  802281:	eb d0                	jmp    802253 <ipc_send+0x1c>
	// panic("ipc_send not implemented");
}
  802283:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802286:	5b                   	pop    %ebx
  802287:	5e                   	pop    %esi
  802288:	5f                   	pop    %edi
  802289:	5d                   	pop    %ebp
  80228a:	c3                   	ret    

0080228b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80228b:	55                   	push   %ebp
  80228c:	89 e5                	mov    %esp,%ebp
  80228e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802291:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802296:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802299:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80229f:	8b 52 50             	mov    0x50(%edx),%edx
  8022a2:	39 ca                	cmp    %ecx,%edx
  8022a4:	75 0d                	jne    8022b3 <ipc_find_env+0x28>
			return envs[i].env_id;
  8022a6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8022a9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8022ae:	8b 40 48             	mov    0x48(%eax),%eax
  8022b1:	eb 0f                	jmp    8022c2 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8022b3:	83 c0 01             	add    $0x1,%eax
  8022b6:	3d 00 04 00 00       	cmp    $0x400,%eax
  8022bb:	75 d9                	jne    802296 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8022bd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8022c2:	5d                   	pop    %ebp
  8022c3:	c3                   	ret    

008022c4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8022c4:	55                   	push   %ebp
  8022c5:	89 e5                	mov    %esp,%ebp
  8022c7:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8022ca:	89 d0                	mov    %edx,%eax
  8022cc:	c1 e8 16             	shr    $0x16,%eax
  8022cf:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8022d6:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8022db:	f6 c1 01             	test   $0x1,%cl
  8022de:	74 1d                	je     8022fd <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8022e0:	c1 ea 0c             	shr    $0xc,%edx
  8022e3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8022ea:	f6 c2 01             	test   $0x1,%dl
  8022ed:	74 0e                	je     8022fd <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8022ef:	c1 ea 0c             	shr    $0xc,%edx
  8022f2:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8022f9:	ef 
  8022fa:	0f b7 c0             	movzwl %ax,%eax
}
  8022fd:	5d                   	pop    %ebp
  8022fe:	c3                   	ret    
  8022ff:	90                   	nop

00802300 <__udivdi3>:
  802300:	55                   	push   %ebp
  802301:	57                   	push   %edi
  802302:	56                   	push   %esi
  802303:	53                   	push   %ebx
  802304:	83 ec 1c             	sub    $0x1c,%esp
  802307:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80230b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80230f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802313:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802317:	85 f6                	test   %esi,%esi
  802319:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80231d:	89 ca                	mov    %ecx,%edx
  80231f:	89 f8                	mov    %edi,%eax
  802321:	75 3d                	jne    802360 <__udivdi3+0x60>
  802323:	39 cf                	cmp    %ecx,%edi
  802325:	0f 87 c5 00 00 00    	ja     8023f0 <__udivdi3+0xf0>
  80232b:	85 ff                	test   %edi,%edi
  80232d:	89 fd                	mov    %edi,%ebp
  80232f:	75 0b                	jne    80233c <__udivdi3+0x3c>
  802331:	b8 01 00 00 00       	mov    $0x1,%eax
  802336:	31 d2                	xor    %edx,%edx
  802338:	f7 f7                	div    %edi
  80233a:	89 c5                	mov    %eax,%ebp
  80233c:	89 c8                	mov    %ecx,%eax
  80233e:	31 d2                	xor    %edx,%edx
  802340:	f7 f5                	div    %ebp
  802342:	89 c1                	mov    %eax,%ecx
  802344:	89 d8                	mov    %ebx,%eax
  802346:	89 cf                	mov    %ecx,%edi
  802348:	f7 f5                	div    %ebp
  80234a:	89 c3                	mov    %eax,%ebx
  80234c:	89 d8                	mov    %ebx,%eax
  80234e:	89 fa                	mov    %edi,%edx
  802350:	83 c4 1c             	add    $0x1c,%esp
  802353:	5b                   	pop    %ebx
  802354:	5e                   	pop    %esi
  802355:	5f                   	pop    %edi
  802356:	5d                   	pop    %ebp
  802357:	c3                   	ret    
  802358:	90                   	nop
  802359:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802360:	39 ce                	cmp    %ecx,%esi
  802362:	77 74                	ja     8023d8 <__udivdi3+0xd8>
  802364:	0f bd fe             	bsr    %esi,%edi
  802367:	83 f7 1f             	xor    $0x1f,%edi
  80236a:	0f 84 98 00 00 00    	je     802408 <__udivdi3+0x108>
  802370:	bb 20 00 00 00       	mov    $0x20,%ebx
  802375:	89 f9                	mov    %edi,%ecx
  802377:	89 c5                	mov    %eax,%ebp
  802379:	29 fb                	sub    %edi,%ebx
  80237b:	d3 e6                	shl    %cl,%esi
  80237d:	89 d9                	mov    %ebx,%ecx
  80237f:	d3 ed                	shr    %cl,%ebp
  802381:	89 f9                	mov    %edi,%ecx
  802383:	d3 e0                	shl    %cl,%eax
  802385:	09 ee                	or     %ebp,%esi
  802387:	89 d9                	mov    %ebx,%ecx
  802389:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80238d:	89 d5                	mov    %edx,%ebp
  80238f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802393:	d3 ed                	shr    %cl,%ebp
  802395:	89 f9                	mov    %edi,%ecx
  802397:	d3 e2                	shl    %cl,%edx
  802399:	89 d9                	mov    %ebx,%ecx
  80239b:	d3 e8                	shr    %cl,%eax
  80239d:	09 c2                	or     %eax,%edx
  80239f:	89 d0                	mov    %edx,%eax
  8023a1:	89 ea                	mov    %ebp,%edx
  8023a3:	f7 f6                	div    %esi
  8023a5:	89 d5                	mov    %edx,%ebp
  8023a7:	89 c3                	mov    %eax,%ebx
  8023a9:	f7 64 24 0c          	mull   0xc(%esp)
  8023ad:	39 d5                	cmp    %edx,%ebp
  8023af:	72 10                	jb     8023c1 <__udivdi3+0xc1>
  8023b1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8023b5:	89 f9                	mov    %edi,%ecx
  8023b7:	d3 e6                	shl    %cl,%esi
  8023b9:	39 c6                	cmp    %eax,%esi
  8023bb:	73 07                	jae    8023c4 <__udivdi3+0xc4>
  8023bd:	39 d5                	cmp    %edx,%ebp
  8023bf:	75 03                	jne    8023c4 <__udivdi3+0xc4>
  8023c1:	83 eb 01             	sub    $0x1,%ebx
  8023c4:	31 ff                	xor    %edi,%edi
  8023c6:	89 d8                	mov    %ebx,%eax
  8023c8:	89 fa                	mov    %edi,%edx
  8023ca:	83 c4 1c             	add    $0x1c,%esp
  8023cd:	5b                   	pop    %ebx
  8023ce:	5e                   	pop    %esi
  8023cf:	5f                   	pop    %edi
  8023d0:	5d                   	pop    %ebp
  8023d1:	c3                   	ret    
  8023d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8023d8:	31 ff                	xor    %edi,%edi
  8023da:	31 db                	xor    %ebx,%ebx
  8023dc:	89 d8                	mov    %ebx,%eax
  8023de:	89 fa                	mov    %edi,%edx
  8023e0:	83 c4 1c             	add    $0x1c,%esp
  8023e3:	5b                   	pop    %ebx
  8023e4:	5e                   	pop    %esi
  8023e5:	5f                   	pop    %edi
  8023e6:	5d                   	pop    %ebp
  8023e7:	c3                   	ret    
  8023e8:	90                   	nop
  8023e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023f0:	89 d8                	mov    %ebx,%eax
  8023f2:	f7 f7                	div    %edi
  8023f4:	31 ff                	xor    %edi,%edi
  8023f6:	89 c3                	mov    %eax,%ebx
  8023f8:	89 d8                	mov    %ebx,%eax
  8023fa:	89 fa                	mov    %edi,%edx
  8023fc:	83 c4 1c             	add    $0x1c,%esp
  8023ff:	5b                   	pop    %ebx
  802400:	5e                   	pop    %esi
  802401:	5f                   	pop    %edi
  802402:	5d                   	pop    %ebp
  802403:	c3                   	ret    
  802404:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802408:	39 ce                	cmp    %ecx,%esi
  80240a:	72 0c                	jb     802418 <__udivdi3+0x118>
  80240c:	31 db                	xor    %ebx,%ebx
  80240e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802412:	0f 87 34 ff ff ff    	ja     80234c <__udivdi3+0x4c>
  802418:	bb 01 00 00 00       	mov    $0x1,%ebx
  80241d:	e9 2a ff ff ff       	jmp    80234c <__udivdi3+0x4c>
  802422:	66 90                	xchg   %ax,%ax
  802424:	66 90                	xchg   %ax,%ax
  802426:	66 90                	xchg   %ax,%ax
  802428:	66 90                	xchg   %ax,%ax
  80242a:	66 90                	xchg   %ax,%ax
  80242c:	66 90                	xchg   %ax,%ax
  80242e:	66 90                	xchg   %ax,%ax

00802430 <__umoddi3>:
  802430:	55                   	push   %ebp
  802431:	57                   	push   %edi
  802432:	56                   	push   %esi
  802433:	53                   	push   %ebx
  802434:	83 ec 1c             	sub    $0x1c,%esp
  802437:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80243b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80243f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802443:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802447:	85 d2                	test   %edx,%edx
  802449:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80244d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802451:	89 f3                	mov    %esi,%ebx
  802453:	89 3c 24             	mov    %edi,(%esp)
  802456:	89 74 24 04          	mov    %esi,0x4(%esp)
  80245a:	75 1c                	jne    802478 <__umoddi3+0x48>
  80245c:	39 f7                	cmp    %esi,%edi
  80245e:	76 50                	jbe    8024b0 <__umoddi3+0x80>
  802460:	89 c8                	mov    %ecx,%eax
  802462:	89 f2                	mov    %esi,%edx
  802464:	f7 f7                	div    %edi
  802466:	89 d0                	mov    %edx,%eax
  802468:	31 d2                	xor    %edx,%edx
  80246a:	83 c4 1c             	add    $0x1c,%esp
  80246d:	5b                   	pop    %ebx
  80246e:	5e                   	pop    %esi
  80246f:	5f                   	pop    %edi
  802470:	5d                   	pop    %ebp
  802471:	c3                   	ret    
  802472:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802478:	39 f2                	cmp    %esi,%edx
  80247a:	89 d0                	mov    %edx,%eax
  80247c:	77 52                	ja     8024d0 <__umoddi3+0xa0>
  80247e:	0f bd ea             	bsr    %edx,%ebp
  802481:	83 f5 1f             	xor    $0x1f,%ebp
  802484:	75 5a                	jne    8024e0 <__umoddi3+0xb0>
  802486:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80248a:	0f 82 e0 00 00 00    	jb     802570 <__umoddi3+0x140>
  802490:	39 0c 24             	cmp    %ecx,(%esp)
  802493:	0f 86 d7 00 00 00    	jbe    802570 <__umoddi3+0x140>
  802499:	8b 44 24 08          	mov    0x8(%esp),%eax
  80249d:	8b 54 24 04          	mov    0x4(%esp),%edx
  8024a1:	83 c4 1c             	add    $0x1c,%esp
  8024a4:	5b                   	pop    %ebx
  8024a5:	5e                   	pop    %esi
  8024a6:	5f                   	pop    %edi
  8024a7:	5d                   	pop    %ebp
  8024a8:	c3                   	ret    
  8024a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024b0:	85 ff                	test   %edi,%edi
  8024b2:	89 fd                	mov    %edi,%ebp
  8024b4:	75 0b                	jne    8024c1 <__umoddi3+0x91>
  8024b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8024bb:	31 d2                	xor    %edx,%edx
  8024bd:	f7 f7                	div    %edi
  8024bf:	89 c5                	mov    %eax,%ebp
  8024c1:	89 f0                	mov    %esi,%eax
  8024c3:	31 d2                	xor    %edx,%edx
  8024c5:	f7 f5                	div    %ebp
  8024c7:	89 c8                	mov    %ecx,%eax
  8024c9:	f7 f5                	div    %ebp
  8024cb:	89 d0                	mov    %edx,%eax
  8024cd:	eb 99                	jmp    802468 <__umoddi3+0x38>
  8024cf:	90                   	nop
  8024d0:	89 c8                	mov    %ecx,%eax
  8024d2:	89 f2                	mov    %esi,%edx
  8024d4:	83 c4 1c             	add    $0x1c,%esp
  8024d7:	5b                   	pop    %ebx
  8024d8:	5e                   	pop    %esi
  8024d9:	5f                   	pop    %edi
  8024da:	5d                   	pop    %ebp
  8024db:	c3                   	ret    
  8024dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8024e0:	8b 34 24             	mov    (%esp),%esi
  8024e3:	bf 20 00 00 00       	mov    $0x20,%edi
  8024e8:	89 e9                	mov    %ebp,%ecx
  8024ea:	29 ef                	sub    %ebp,%edi
  8024ec:	d3 e0                	shl    %cl,%eax
  8024ee:	89 f9                	mov    %edi,%ecx
  8024f0:	89 f2                	mov    %esi,%edx
  8024f2:	d3 ea                	shr    %cl,%edx
  8024f4:	89 e9                	mov    %ebp,%ecx
  8024f6:	09 c2                	or     %eax,%edx
  8024f8:	89 d8                	mov    %ebx,%eax
  8024fa:	89 14 24             	mov    %edx,(%esp)
  8024fd:	89 f2                	mov    %esi,%edx
  8024ff:	d3 e2                	shl    %cl,%edx
  802501:	89 f9                	mov    %edi,%ecx
  802503:	89 54 24 04          	mov    %edx,0x4(%esp)
  802507:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80250b:	d3 e8                	shr    %cl,%eax
  80250d:	89 e9                	mov    %ebp,%ecx
  80250f:	89 c6                	mov    %eax,%esi
  802511:	d3 e3                	shl    %cl,%ebx
  802513:	89 f9                	mov    %edi,%ecx
  802515:	89 d0                	mov    %edx,%eax
  802517:	d3 e8                	shr    %cl,%eax
  802519:	89 e9                	mov    %ebp,%ecx
  80251b:	09 d8                	or     %ebx,%eax
  80251d:	89 d3                	mov    %edx,%ebx
  80251f:	89 f2                	mov    %esi,%edx
  802521:	f7 34 24             	divl   (%esp)
  802524:	89 d6                	mov    %edx,%esi
  802526:	d3 e3                	shl    %cl,%ebx
  802528:	f7 64 24 04          	mull   0x4(%esp)
  80252c:	39 d6                	cmp    %edx,%esi
  80252e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802532:	89 d1                	mov    %edx,%ecx
  802534:	89 c3                	mov    %eax,%ebx
  802536:	72 08                	jb     802540 <__umoddi3+0x110>
  802538:	75 11                	jne    80254b <__umoddi3+0x11b>
  80253a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80253e:	73 0b                	jae    80254b <__umoddi3+0x11b>
  802540:	2b 44 24 04          	sub    0x4(%esp),%eax
  802544:	1b 14 24             	sbb    (%esp),%edx
  802547:	89 d1                	mov    %edx,%ecx
  802549:	89 c3                	mov    %eax,%ebx
  80254b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80254f:	29 da                	sub    %ebx,%edx
  802551:	19 ce                	sbb    %ecx,%esi
  802553:	89 f9                	mov    %edi,%ecx
  802555:	89 f0                	mov    %esi,%eax
  802557:	d3 e0                	shl    %cl,%eax
  802559:	89 e9                	mov    %ebp,%ecx
  80255b:	d3 ea                	shr    %cl,%edx
  80255d:	89 e9                	mov    %ebp,%ecx
  80255f:	d3 ee                	shr    %cl,%esi
  802561:	09 d0                	or     %edx,%eax
  802563:	89 f2                	mov    %esi,%edx
  802565:	83 c4 1c             	add    $0x1c,%esp
  802568:	5b                   	pop    %ebx
  802569:	5e                   	pop    %esi
  80256a:	5f                   	pop    %edi
  80256b:	5d                   	pop    %ebp
  80256c:	c3                   	ret    
  80256d:	8d 76 00             	lea    0x0(%esi),%esi
  802570:	29 f9                	sub    %edi,%ecx
  802572:	19 d6                	sbb    %edx,%esi
  802574:	89 74 24 04          	mov    %esi,0x4(%esp)
  802578:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80257c:	e9 18 ff ff ff       	jmp    802499 <__umoddi3+0x69>
