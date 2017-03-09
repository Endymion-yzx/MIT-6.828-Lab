
obj/user/ls.debug:     file format elf32-i386


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
  80002c:	e8 93 02 00 00       	call   8002c4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <ls1>:
		panic("error reading directory %s: %e", path, n);
}

void
ls1(const char *prefix, bool isdir, off_t size, const char *name)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80003b:	8b 75 0c             	mov    0xc(%ebp),%esi
	const char *sep;

	if(flag['l'])
  80003e:	83 3d d0 41 80 00 00 	cmpl   $0x0,0x8041d0
  800045:	74 20                	je     800067 <ls1+0x34>
		printf("%11d %c ", size, isdir ? 'd' : '-');
  800047:	89 f0                	mov    %esi,%eax
  800049:	3c 01                	cmp    $0x1,%al
  80004b:	19 c0                	sbb    %eax,%eax
  80004d:	83 e0 c9             	and    $0xffffffc9,%eax
  800050:	83 c0 64             	add    $0x64,%eax
  800053:	83 ec 04             	sub    $0x4,%esp
  800056:	50                   	push   %eax
  800057:	ff 75 10             	pushl  0x10(%ebp)
  80005a:	68 22 23 80 00       	push   $0x802322
  80005f:	e8 e6 19 00 00       	call   801a4a <printf>
  800064:	83 c4 10             	add    $0x10,%esp
	if(prefix) {
  800067:	85 db                	test   %ebx,%ebx
  800069:	74 3a                	je     8000a5 <ls1+0x72>
		if (prefix[0] && prefix[strlen(prefix)-1] != '/')
			sep = "/";
		else
			sep = "";
  80006b:	b8 88 23 80 00       	mov    $0x802388,%eax
	const char *sep;

	if(flag['l'])
		printf("%11d %c ", size, isdir ? 'd' : '-');
	if(prefix) {
		if (prefix[0] && prefix[strlen(prefix)-1] != '/')
  800070:	80 3b 00             	cmpb   $0x0,(%ebx)
  800073:	74 1e                	je     800093 <ls1+0x60>
  800075:	83 ec 0c             	sub    $0xc,%esp
  800078:	53                   	push   %ebx
  800079:	e8 72 09 00 00       	call   8009f0 <strlen>
  80007e:	83 c4 10             	add    $0x10,%esp
			sep = "/";
		else
			sep = "";
  800081:	80 7c 03 ff 2f       	cmpb   $0x2f,-0x1(%ebx,%eax,1)
  800086:	ba 88 23 80 00       	mov    $0x802388,%edx
  80008b:	b8 20 23 80 00       	mov    $0x802320,%eax
  800090:	0f 44 c2             	cmove  %edx,%eax
		printf("%s%s", prefix, sep);
  800093:	83 ec 04             	sub    $0x4,%esp
  800096:	50                   	push   %eax
  800097:	53                   	push   %ebx
  800098:	68 2b 23 80 00       	push   $0x80232b
  80009d:	e8 a8 19 00 00       	call   801a4a <printf>
  8000a2:	83 c4 10             	add    $0x10,%esp
	}
	printf("%s", name);
  8000a5:	83 ec 08             	sub    $0x8,%esp
  8000a8:	ff 75 14             	pushl  0x14(%ebp)
  8000ab:	68 de 27 80 00       	push   $0x8027de
  8000b0:	e8 95 19 00 00       	call   801a4a <printf>
	if(flag['F'] && isdir)
  8000b5:	83 c4 10             	add    $0x10,%esp
  8000b8:	83 3d 38 41 80 00 00 	cmpl   $0x0,0x804138
  8000bf:	74 16                	je     8000d7 <ls1+0xa4>
  8000c1:	89 f0                	mov    %esi,%eax
  8000c3:	84 c0                	test   %al,%al
  8000c5:	74 10                	je     8000d7 <ls1+0xa4>
		printf("/");
  8000c7:	83 ec 0c             	sub    $0xc,%esp
  8000ca:	68 20 23 80 00       	push   $0x802320
  8000cf:	e8 76 19 00 00       	call   801a4a <printf>
  8000d4:	83 c4 10             	add    $0x10,%esp
	printf("\n");
  8000d7:	83 ec 0c             	sub    $0xc,%esp
  8000da:	68 87 23 80 00       	push   $0x802387
  8000df:	e8 66 19 00 00       	call   801a4a <printf>
}
  8000e4:	83 c4 10             	add    $0x10,%esp
  8000e7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000ea:	5b                   	pop    %ebx
  8000eb:	5e                   	pop    %esi
  8000ec:	5d                   	pop    %ebp
  8000ed:	c3                   	ret    

008000ee <lsdir>:
		ls1(0, st.st_isdir, st.st_size, path);
}

void
lsdir(const char *path, const char *prefix)
{
  8000ee:	55                   	push   %ebp
  8000ef:	89 e5                	mov    %esp,%ebp
  8000f1:	57                   	push   %edi
  8000f2:	56                   	push   %esi
  8000f3:	53                   	push   %ebx
  8000f4:	81 ec 14 01 00 00    	sub    $0x114,%esp
  8000fa:	8b 7d 08             	mov    0x8(%ebp),%edi
	int fd, n;
	struct File f;

	if ((fd = open(path, O_RDONLY)) < 0)
  8000fd:	6a 00                	push   $0x0
  8000ff:	57                   	push   %edi
  800100:	e8 a7 17 00 00       	call   8018ac <open>
  800105:	89 c3                	mov    %eax,%ebx
  800107:	83 c4 10             	add    $0x10,%esp
  80010a:	85 c0                	test   %eax,%eax
  80010c:	79 41                	jns    80014f <lsdir+0x61>
		panic("open %s: %e", path, fd);
  80010e:	83 ec 0c             	sub    $0xc,%esp
  800111:	50                   	push   %eax
  800112:	57                   	push   %edi
  800113:	68 30 23 80 00       	push   $0x802330
  800118:	6a 1d                	push   $0x1d
  80011a:	68 3c 23 80 00       	push   $0x80233c
  80011f:	e8 00 02 00 00       	call   800324 <_panic>
	while ((n = readn(fd, &f, sizeof f)) == sizeof f)
		if (f.f_name[0])
  800124:	80 bd e8 fe ff ff 00 	cmpb   $0x0,-0x118(%ebp)
  80012b:	74 28                	je     800155 <lsdir+0x67>
			ls1(prefix, f.f_type==FTYPE_DIR, f.f_size, f.f_name);
  80012d:	56                   	push   %esi
  80012e:	ff b5 68 ff ff ff    	pushl  -0x98(%ebp)
  800134:	83 bd 6c ff ff ff 01 	cmpl   $0x1,-0x94(%ebp)
  80013b:	0f 94 c0             	sete   %al
  80013e:	0f b6 c0             	movzbl %al,%eax
  800141:	50                   	push   %eax
  800142:	ff 75 0c             	pushl  0xc(%ebp)
  800145:	e8 e9 fe ff ff       	call   800033 <ls1>
  80014a:	83 c4 10             	add    $0x10,%esp
  80014d:	eb 06                	jmp    800155 <lsdir+0x67>
	int fd, n;
	struct File f;

	if ((fd = open(path, O_RDONLY)) < 0)
		panic("open %s: %e", path, fd);
	while ((n = readn(fd, &f, sizeof f)) == sizeof f)
  80014f:	8d b5 e8 fe ff ff    	lea    -0x118(%ebp),%esi
  800155:	83 ec 04             	sub    $0x4,%esp
  800158:	68 00 01 00 00       	push   $0x100
  80015d:	56                   	push   %esi
  80015e:	53                   	push   %ebx
  80015f:	e8 7a 13 00 00       	call   8014de <readn>
  800164:	83 c4 10             	add    $0x10,%esp
  800167:	3d 00 01 00 00       	cmp    $0x100,%eax
  80016c:	74 b6                	je     800124 <lsdir+0x36>
		if (f.f_name[0])
			ls1(prefix, f.f_type==FTYPE_DIR, f.f_size, f.f_name);
	if (n > 0)
  80016e:	85 c0                	test   %eax,%eax
  800170:	7e 12                	jle    800184 <lsdir+0x96>
		panic("short read in directory %s", path);
  800172:	57                   	push   %edi
  800173:	68 46 23 80 00       	push   $0x802346
  800178:	6a 22                	push   $0x22
  80017a:	68 3c 23 80 00       	push   $0x80233c
  80017f:	e8 a0 01 00 00       	call   800324 <_panic>
	if (n < 0)
  800184:	85 c0                	test   %eax,%eax
  800186:	79 16                	jns    80019e <lsdir+0xb0>
		panic("error reading directory %s: %e", path, n);
  800188:	83 ec 0c             	sub    $0xc,%esp
  80018b:	50                   	push   %eax
  80018c:	57                   	push   %edi
  80018d:	68 8c 23 80 00       	push   $0x80238c
  800192:	6a 24                	push   $0x24
  800194:	68 3c 23 80 00       	push   $0x80233c
  800199:	e8 86 01 00 00       	call   800324 <_panic>
}
  80019e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a1:	5b                   	pop    %ebx
  8001a2:	5e                   	pop    %esi
  8001a3:	5f                   	pop    %edi
  8001a4:	5d                   	pop    %ebp
  8001a5:	c3                   	ret    

008001a6 <ls>:
void lsdir(const char*, const char*);
void ls1(const char*, bool, off_t, const char*);

void
ls(const char *path, const char *prefix)
{
  8001a6:	55                   	push   %ebp
  8001a7:	89 e5                	mov    %esp,%ebp
  8001a9:	53                   	push   %ebx
  8001aa:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
  8001b0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Stat st;

	if ((r = stat(path, &st)) < 0)
  8001b3:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
  8001b9:	50                   	push   %eax
  8001ba:	53                   	push   %ebx
  8001bb:	e8 23 15 00 00       	call   8016e3 <stat>
  8001c0:	83 c4 10             	add    $0x10,%esp
  8001c3:	85 c0                	test   %eax,%eax
  8001c5:	79 16                	jns    8001dd <ls+0x37>
		panic("stat %s: %e", path, r);
  8001c7:	83 ec 0c             	sub    $0xc,%esp
  8001ca:	50                   	push   %eax
  8001cb:	53                   	push   %ebx
  8001cc:	68 61 23 80 00       	push   $0x802361
  8001d1:	6a 0f                	push   $0xf
  8001d3:	68 3c 23 80 00       	push   $0x80233c
  8001d8:	e8 47 01 00 00       	call   800324 <_panic>
	if (st.st_isdir && !flag['d'])
  8001dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8001e0:	85 c0                	test   %eax,%eax
  8001e2:	74 1a                	je     8001fe <ls+0x58>
  8001e4:	83 3d b0 41 80 00 00 	cmpl   $0x0,0x8041b0
  8001eb:	75 11                	jne    8001fe <ls+0x58>
		lsdir(path, prefix);
  8001ed:	83 ec 08             	sub    $0x8,%esp
  8001f0:	ff 75 0c             	pushl  0xc(%ebp)
  8001f3:	53                   	push   %ebx
  8001f4:	e8 f5 fe ff ff       	call   8000ee <lsdir>
  8001f9:	83 c4 10             	add    $0x10,%esp
  8001fc:	eb 17                	jmp    800215 <ls+0x6f>
	else
		ls1(0, st.st_isdir, st.st_size, path);
  8001fe:	53                   	push   %ebx
  8001ff:	ff 75 ec             	pushl  -0x14(%ebp)
  800202:	85 c0                	test   %eax,%eax
  800204:	0f 95 c0             	setne  %al
  800207:	0f b6 c0             	movzbl %al,%eax
  80020a:	50                   	push   %eax
  80020b:	6a 00                	push   $0x0
  80020d:	e8 21 fe ff ff       	call   800033 <ls1>
  800212:	83 c4 10             	add    $0x10,%esp
}
  800215:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800218:	c9                   	leave  
  800219:	c3                   	ret    

0080021a <usage>:
	printf("\n");
}

void
usage(void)
{
  80021a:	55                   	push   %ebp
  80021b:	89 e5                	mov    %esp,%ebp
  80021d:	83 ec 14             	sub    $0x14,%esp
	printf("usage: ls [-dFl] [file...]\n");
  800220:	68 6d 23 80 00       	push   $0x80236d
  800225:	e8 20 18 00 00       	call   801a4a <printf>
	exit();
  80022a:	e8 db 00 00 00       	call   80030a <exit>
}
  80022f:	83 c4 10             	add    $0x10,%esp
  800232:	c9                   	leave  
  800233:	c3                   	ret    

00800234 <umain>:

void
umain(int argc, char **argv)
{
  800234:	55                   	push   %ebp
  800235:	89 e5                	mov    %esp,%ebp
  800237:	56                   	push   %esi
  800238:	53                   	push   %ebx
  800239:	83 ec 14             	sub    $0x14,%esp
  80023c:	8b 75 0c             	mov    0xc(%ebp),%esi
	int i;
	struct Argstate args;

	argstart(&argc, argv, &args);
  80023f:	8d 45 e8             	lea    -0x18(%ebp),%eax
  800242:	50                   	push   %eax
  800243:	56                   	push   %esi
  800244:	8d 45 08             	lea    0x8(%ebp),%eax
  800247:	50                   	push   %eax
  800248:	e8 d0 0d 00 00       	call   80101d <argstart>
	while ((i = argnext(&args)) >= 0)
  80024d:	83 c4 10             	add    $0x10,%esp
  800250:	8d 5d e8             	lea    -0x18(%ebp),%ebx
  800253:	eb 1e                	jmp    800273 <umain+0x3f>
		switch (i) {
  800255:	83 f8 64             	cmp    $0x64,%eax
  800258:	74 0a                	je     800264 <umain+0x30>
  80025a:	83 f8 6c             	cmp    $0x6c,%eax
  80025d:	74 05                	je     800264 <umain+0x30>
  80025f:	83 f8 46             	cmp    $0x46,%eax
  800262:	75 0a                	jne    80026e <umain+0x3a>
		case 'd':
		case 'F':
		case 'l':
			flag[i]++;
  800264:	83 04 85 20 40 80 00 	addl   $0x1,0x804020(,%eax,4)
  80026b:	01 
			break;
  80026c:	eb 05                	jmp    800273 <umain+0x3f>
		default:
			usage();
  80026e:	e8 a7 ff ff ff       	call   80021a <usage>
{
	int i;
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
  800273:	83 ec 0c             	sub    $0xc,%esp
  800276:	53                   	push   %ebx
  800277:	e8 d1 0d 00 00       	call   80104d <argnext>
  80027c:	83 c4 10             	add    $0x10,%esp
  80027f:	85 c0                	test   %eax,%eax
  800281:	79 d2                	jns    800255 <umain+0x21>
  800283:	bb 01 00 00 00       	mov    $0x1,%ebx
			break;
		default:
			usage();
		}

	if (argc == 1)
  800288:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  80028c:	75 2a                	jne    8002b8 <umain+0x84>
		ls("/", "");
  80028e:	83 ec 08             	sub    $0x8,%esp
  800291:	68 88 23 80 00       	push   $0x802388
  800296:	68 20 23 80 00       	push   $0x802320
  80029b:	e8 06 ff ff ff       	call   8001a6 <ls>
  8002a0:	83 c4 10             	add    $0x10,%esp
  8002a3:	eb 18                	jmp    8002bd <umain+0x89>
	else {
		for (i = 1; i < argc; i++)
			ls(argv[i], argv[i]);
  8002a5:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  8002a8:	83 ec 08             	sub    $0x8,%esp
  8002ab:	50                   	push   %eax
  8002ac:	50                   	push   %eax
  8002ad:	e8 f4 fe ff ff       	call   8001a6 <ls>
		}

	if (argc == 1)
		ls("/", "");
	else {
		for (i = 1; i < argc; i++)
  8002b2:	83 c3 01             	add    $0x1,%ebx
  8002b5:	83 c4 10             	add    $0x10,%esp
  8002b8:	3b 5d 08             	cmp    0x8(%ebp),%ebx
  8002bb:	7c e8                	jl     8002a5 <umain+0x71>
			ls(argv[i], argv[i]);
	}
}
  8002bd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002c0:	5b                   	pop    %ebx
  8002c1:	5e                   	pop    %esi
  8002c2:	5d                   	pop    %ebp
  8002c3:	c3                   	ret    

008002c4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8002c4:	55                   	push   %ebp
  8002c5:	89 e5                	mov    %esp,%ebp
  8002c7:	56                   	push   %esi
  8002c8:	53                   	push   %ebx
  8002c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002cc:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	envid_t envid = sys_getenvid();
  8002cf:	e8 1a 0b 00 00       	call   800dee <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8002d4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002d9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8002dc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002e1:	a3 20 44 80 00       	mov    %eax,0x804420

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002e6:	85 db                	test   %ebx,%ebx
  8002e8:	7e 07                	jle    8002f1 <libmain+0x2d>
		binaryname = argv[0];
  8002ea:	8b 06                	mov    (%esi),%eax
  8002ec:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8002f1:	83 ec 08             	sub    $0x8,%esp
  8002f4:	56                   	push   %esi
  8002f5:	53                   	push   %ebx
  8002f6:	e8 39 ff ff ff       	call   800234 <umain>

	// exit gracefully
	exit();
  8002fb:	e8 0a 00 00 00       	call   80030a <exit>
}
  800300:	83 c4 10             	add    $0x10,%esp
  800303:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800306:	5b                   	pop    %ebx
  800307:	5e                   	pop    %esi
  800308:	5d                   	pop    %ebp
  800309:	c3                   	ret    

0080030a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80030a:	55                   	push   %ebp
  80030b:	89 e5                	mov    %esp,%ebp
  80030d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800310:	e8 27 10 00 00       	call   80133c <close_all>
	sys_env_destroy(0);
  800315:	83 ec 0c             	sub    $0xc,%esp
  800318:	6a 00                	push   $0x0
  80031a:	e8 8e 0a 00 00       	call   800dad <sys_env_destroy>
}
  80031f:	83 c4 10             	add    $0x10,%esp
  800322:	c9                   	leave  
  800323:	c3                   	ret    

00800324 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800324:	55                   	push   %ebp
  800325:	89 e5                	mov    %esp,%ebp
  800327:	56                   	push   %esi
  800328:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800329:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80032c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800332:	e8 b7 0a 00 00       	call   800dee <sys_getenvid>
  800337:	83 ec 0c             	sub    $0xc,%esp
  80033a:	ff 75 0c             	pushl  0xc(%ebp)
  80033d:	ff 75 08             	pushl  0x8(%ebp)
  800340:	56                   	push   %esi
  800341:	50                   	push   %eax
  800342:	68 b8 23 80 00       	push   $0x8023b8
  800347:	e8 b1 00 00 00       	call   8003fd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80034c:	83 c4 18             	add    $0x18,%esp
  80034f:	53                   	push   %ebx
  800350:	ff 75 10             	pushl  0x10(%ebp)
  800353:	e8 54 00 00 00       	call   8003ac <vcprintf>
	cprintf("\n");
  800358:	c7 04 24 87 23 80 00 	movl   $0x802387,(%esp)
  80035f:	e8 99 00 00 00       	call   8003fd <cprintf>
  800364:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800367:	cc                   	int3   
  800368:	eb fd                	jmp    800367 <_panic+0x43>

0080036a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80036a:	55                   	push   %ebp
  80036b:	89 e5                	mov    %esp,%ebp
  80036d:	53                   	push   %ebx
  80036e:	83 ec 04             	sub    $0x4,%esp
  800371:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800374:	8b 13                	mov    (%ebx),%edx
  800376:	8d 42 01             	lea    0x1(%edx),%eax
  800379:	89 03                	mov    %eax,(%ebx)
  80037b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80037e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800382:	3d ff 00 00 00       	cmp    $0xff,%eax
  800387:	75 1a                	jne    8003a3 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800389:	83 ec 08             	sub    $0x8,%esp
  80038c:	68 ff 00 00 00       	push   $0xff
  800391:	8d 43 08             	lea    0x8(%ebx),%eax
  800394:	50                   	push   %eax
  800395:	e8 d6 09 00 00       	call   800d70 <sys_cputs>
		b->idx = 0;
  80039a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003a0:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8003a3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003aa:	c9                   	leave  
  8003ab:	c3                   	ret    

008003ac <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003ac:	55                   	push   %ebp
  8003ad:	89 e5                	mov    %esp,%ebp
  8003af:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003b5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003bc:	00 00 00 
	b.cnt = 0;
  8003bf:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003c6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003c9:	ff 75 0c             	pushl  0xc(%ebp)
  8003cc:	ff 75 08             	pushl  0x8(%ebp)
  8003cf:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003d5:	50                   	push   %eax
  8003d6:	68 6a 03 80 00       	push   $0x80036a
  8003db:	e8 1a 01 00 00       	call   8004fa <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003e0:	83 c4 08             	add    $0x8,%esp
  8003e3:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003e9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003ef:	50                   	push   %eax
  8003f0:	e8 7b 09 00 00       	call   800d70 <sys_cputs>

	return b.cnt;
}
  8003f5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003fb:	c9                   	leave  
  8003fc:	c3                   	ret    

008003fd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003fd:	55                   	push   %ebp
  8003fe:	89 e5                	mov    %esp,%ebp
  800400:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800403:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800406:	50                   	push   %eax
  800407:	ff 75 08             	pushl  0x8(%ebp)
  80040a:	e8 9d ff ff ff       	call   8003ac <vcprintf>
	va_end(ap);

	return cnt;
}
  80040f:	c9                   	leave  
  800410:	c3                   	ret    

00800411 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800411:	55                   	push   %ebp
  800412:	89 e5                	mov    %esp,%ebp
  800414:	57                   	push   %edi
  800415:	56                   	push   %esi
  800416:	53                   	push   %ebx
  800417:	83 ec 1c             	sub    $0x1c,%esp
  80041a:	89 c7                	mov    %eax,%edi
  80041c:	89 d6                	mov    %edx,%esi
  80041e:	8b 45 08             	mov    0x8(%ebp),%eax
  800421:	8b 55 0c             	mov    0xc(%ebp),%edx
  800424:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800427:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80042a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80042d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800432:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800435:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800438:	39 d3                	cmp    %edx,%ebx
  80043a:	72 05                	jb     800441 <printnum+0x30>
  80043c:	39 45 10             	cmp    %eax,0x10(%ebp)
  80043f:	77 45                	ja     800486 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800441:	83 ec 0c             	sub    $0xc,%esp
  800444:	ff 75 18             	pushl  0x18(%ebp)
  800447:	8b 45 14             	mov    0x14(%ebp),%eax
  80044a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80044d:	53                   	push   %ebx
  80044e:	ff 75 10             	pushl  0x10(%ebp)
  800451:	83 ec 08             	sub    $0x8,%esp
  800454:	ff 75 e4             	pushl  -0x1c(%ebp)
  800457:	ff 75 e0             	pushl  -0x20(%ebp)
  80045a:	ff 75 dc             	pushl  -0x24(%ebp)
  80045d:	ff 75 d8             	pushl  -0x28(%ebp)
  800460:	e8 1b 1c 00 00       	call   802080 <__udivdi3>
  800465:	83 c4 18             	add    $0x18,%esp
  800468:	52                   	push   %edx
  800469:	50                   	push   %eax
  80046a:	89 f2                	mov    %esi,%edx
  80046c:	89 f8                	mov    %edi,%eax
  80046e:	e8 9e ff ff ff       	call   800411 <printnum>
  800473:	83 c4 20             	add    $0x20,%esp
  800476:	eb 18                	jmp    800490 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800478:	83 ec 08             	sub    $0x8,%esp
  80047b:	56                   	push   %esi
  80047c:	ff 75 18             	pushl  0x18(%ebp)
  80047f:	ff d7                	call   *%edi
  800481:	83 c4 10             	add    $0x10,%esp
  800484:	eb 03                	jmp    800489 <printnum+0x78>
  800486:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800489:	83 eb 01             	sub    $0x1,%ebx
  80048c:	85 db                	test   %ebx,%ebx
  80048e:	7f e8                	jg     800478 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800490:	83 ec 08             	sub    $0x8,%esp
  800493:	56                   	push   %esi
  800494:	83 ec 04             	sub    $0x4,%esp
  800497:	ff 75 e4             	pushl  -0x1c(%ebp)
  80049a:	ff 75 e0             	pushl  -0x20(%ebp)
  80049d:	ff 75 dc             	pushl  -0x24(%ebp)
  8004a0:	ff 75 d8             	pushl  -0x28(%ebp)
  8004a3:	e8 08 1d 00 00       	call   8021b0 <__umoddi3>
  8004a8:	83 c4 14             	add    $0x14,%esp
  8004ab:	0f be 80 db 23 80 00 	movsbl 0x8023db(%eax),%eax
  8004b2:	50                   	push   %eax
  8004b3:	ff d7                	call   *%edi
}
  8004b5:	83 c4 10             	add    $0x10,%esp
  8004b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004bb:	5b                   	pop    %ebx
  8004bc:	5e                   	pop    %esi
  8004bd:	5f                   	pop    %edi
  8004be:	5d                   	pop    %ebp
  8004bf:	c3                   	ret    

008004c0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004c0:	55                   	push   %ebp
  8004c1:	89 e5                	mov    %esp,%ebp
  8004c3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004c6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004ca:	8b 10                	mov    (%eax),%edx
  8004cc:	3b 50 04             	cmp    0x4(%eax),%edx
  8004cf:	73 0a                	jae    8004db <sprintputch+0x1b>
		*b->buf++ = ch;
  8004d1:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004d4:	89 08                	mov    %ecx,(%eax)
  8004d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8004d9:	88 02                	mov    %al,(%edx)
}
  8004db:	5d                   	pop    %ebp
  8004dc:	c3                   	ret    

008004dd <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004dd:	55                   	push   %ebp
  8004de:	89 e5                	mov    %esp,%ebp
  8004e0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004e3:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004e6:	50                   	push   %eax
  8004e7:	ff 75 10             	pushl  0x10(%ebp)
  8004ea:	ff 75 0c             	pushl  0xc(%ebp)
  8004ed:	ff 75 08             	pushl  0x8(%ebp)
  8004f0:	e8 05 00 00 00       	call   8004fa <vprintfmt>
	va_end(ap);
}
  8004f5:	83 c4 10             	add    $0x10,%esp
  8004f8:	c9                   	leave  
  8004f9:	c3                   	ret    

008004fa <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004fa:	55                   	push   %ebp
  8004fb:	89 e5                	mov    %esp,%ebp
  8004fd:	57                   	push   %edi
  8004fe:	56                   	push   %esi
  8004ff:	53                   	push   %ebx
  800500:	83 ec 2c             	sub    $0x2c,%esp
  800503:	8b 75 08             	mov    0x8(%ebp),%esi
  800506:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800509:	8b 7d 10             	mov    0x10(%ebp),%edi
  80050c:	eb 12                	jmp    800520 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80050e:	85 c0                	test   %eax,%eax
  800510:	0f 84 6a 04 00 00    	je     800980 <vprintfmt+0x486>
				return;
			putch(ch, putdat);
  800516:	83 ec 08             	sub    $0x8,%esp
  800519:	53                   	push   %ebx
  80051a:	50                   	push   %eax
  80051b:	ff d6                	call   *%esi
  80051d:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800520:	83 c7 01             	add    $0x1,%edi
  800523:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800527:	83 f8 25             	cmp    $0x25,%eax
  80052a:	75 e2                	jne    80050e <vprintfmt+0x14>
  80052c:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800530:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800537:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80053e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800545:	b9 00 00 00 00       	mov    $0x0,%ecx
  80054a:	eb 07                	jmp    800553 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054c:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80054f:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800553:	8d 47 01             	lea    0x1(%edi),%eax
  800556:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800559:	0f b6 07             	movzbl (%edi),%eax
  80055c:	0f b6 d0             	movzbl %al,%edx
  80055f:	83 e8 23             	sub    $0x23,%eax
  800562:	3c 55                	cmp    $0x55,%al
  800564:	0f 87 fb 03 00 00    	ja     800965 <vprintfmt+0x46b>
  80056a:	0f b6 c0             	movzbl %al,%eax
  80056d:	ff 24 85 20 25 80 00 	jmp    *0x802520(,%eax,4)
  800574:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800577:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80057b:	eb d6                	jmp    800553 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800580:	b8 00 00 00 00       	mov    $0x0,%eax
  800585:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800588:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80058b:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80058f:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800592:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800595:	83 f9 09             	cmp    $0x9,%ecx
  800598:	77 3f                	ja     8005d9 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80059a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80059d:	eb e9                	jmp    800588 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80059f:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a2:	8b 00                	mov    (%eax),%eax
  8005a4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005aa:	8d 40 04             	lea    0x4(%eax),%eax
  8005ad:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005b3:	eb 2a                	jmp    8005df <vprintfmt+0xe5>
  8005b5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005b8:	85 c0                	test   %eax,%eax
  8005ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8005bf:	0f 49 d0             	cmovns %eax,%edx
  8005c2:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005c8:	eb 89                	jmp    800553 <vprintfmt+0x59>
  8005ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005cd:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005d4:	e9 7a ff ff ff       	jmp    800553 <vprintfmt+0x59>
  8005d9:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005dc:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8005df:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005e3:	0f 89 6a ff ff ff    	jns    800553 <vprintfmt+0x59>
				width = precision, precision = -1;
  8005e9:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005ec:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005ef:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005f6:	e9 58 ff ff ff       	jmp    800553 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005fb:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800601:	e9 4d ff ff ff       	jmp    800553 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800606:	8b 45 14             	mov    0x14(%ebp),%eax
  800609:	8d 78 04             	lea    0x4(%eax),%edi
  80060c:	83 ec 08             	sub    $0x8,%esp
  80060f:	53                   	push   %ebx
  800610:	ff 30                	pushl  (%eax)
  800612:	ff d6                	call   *%esi
			break;
  800614:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800617:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80061a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80061d:	e9 fe fe ff ff       	jmp    800520 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800622:	8b 45 14             	mov    0x14(%ebp),%eax
  800625:	8d 78 04             	lea    0x4(%eax),%edi
  800628:	8b 00                	mov    (%eax),%eax
  80062a:	99                   	cltd   
  80062b:	31 d0                	xor    %edx,%eax
  80062d:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80062f:	83 f8 0f             	cmp    $0xf,%eax
  800632:	7f 0b                	jg     80063f <vprintfmt+0x145>
  800634:	8b 14 85 80 26 80 00 	mov    0x802680(,%eax,4),%edx
  80063b:	85 d2                	test   %edx,%edx
  80063d:	75 1b                	jne    80065a <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  80063f:	50                   	push   %eax
  800640:	68 f3 23 80 00       	push   $0x8023f3
  800645:	53                   	push   %ebx
  800646:	56                   	push   %esi
  800647:	e8 91 fe ff ff       	call   8004dd <printfmt>
  80064c:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80064f:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800652:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800655:	e9 c6 fe ff ff       	jmp    800520 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80065a:	52                   	push   %edx
  80065b:	68 de 27 80 00       	push   $0x8027de
  800660:	53                   	push   %ebx
  800661:	56                   	push   %esi
  800662:	e8 76 fe ff ff       	call   8004dd <printfmt>
  800667:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80066a:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80066d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800670:	e9 ab fe ff ff       	jmp    800520 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800675:	8b 45 14             	mov    0x14(%ebp),%eax
  800678:	83 c0 04             	add    $0x4,%eax
  80067b:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80067e:	8b 45 14             	mov    0x14(%ebp),%eax
  800681:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800683:	85 ff                	test   %edi,%edi
  800685:	b8 ec 23 80 00       	mov    $0x8023ec,%eax
  80068a:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80068d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800691:	0f 8e 94 00 00 00    	jle    80072b <vprintfmt+0x231>
  800697:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80069b:	0f 84 98 00 00 00    	je     800739 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006a1:	83 ec 08             	sub    $0x8,%esp
  8006a4:	ff 75 d0             	pushl  -0x30(%ebp)
  8006a7:	57                   	push   %edi
  8006a8:	e8 5b 03 00 00       	call   800a08 <strnlen>
  8006ad:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006b0:	29 c1                	sub    %eax,%ecx
  8006b2:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8006b5:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006b8:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006bc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006bf:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006c2:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006c4:	eb 0f                	jmp    8006d5 <vprintfmt+0x1db>
					putch(padc, putdat);
  8006c6:	83 ec 08             	sub    $0x8,%esp
  8006c9:	53                   	push   %ebx
  8006ca:	ff 75 e0             	pushl  -0x20(%ebp)
  8006cd:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006cf:	83 ef 01             	sub    $0x1,%edi
  8006d2:	83 c4 10             	add    $0x10,%esp
  8006d5:	85 ff                	test   %edi,%edi
  8006d7:	7f ed                	jg     8006c6 <vprintfmt+0x1cc>
  8006d9:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006dc:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006df:	85 c9                	test   %ecx,%ecx
  8006e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8006e6:	0f 49 c1             	cmovns %ecx,%eax
  8006e9:	29 c1                	sub    %eax,%ecx
  8006eb:	89 75 08             	mov    %esi,0x8(%ebp)
  8006ee:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006f1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006f4:	89 cb                	mov    %ecx,%ebx
  8006f6:	eb 4d                	jmp    800745 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006f8:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006fc:	74 1b                	je     800719 <vprintfmt+0x21f>
  8006fe:	0f be c0             	movsbl %al,%eax
  800701:	83 e8 20             	sub    $0x20,%eax
  800704:	83 f8 5e             	cmp    $0x5e,%eax
  800707:	76 10                	jbe    800719 <vprintfmt+0x21f>
					putch('?', putdat);
  800709:	83 ec 08             	sub    $0x8,%esp
  80070c:	ff 75 0c             	pushl  0xc(%ebp)
  80070f:	6a 3f                	push   $0x3f
  800711:	ff 55 08             	call   *0x8(%ebp)
  800714:	83 c4 10             	add    $0x10,%esp
  800717:	eb 0d                	jmp    800726 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  800719:	83 ec 08             	sub    $0x8,%esp
  80071c:	ff 75 0c             	pushl  0xc(%ebp)
  80071f:	52                   	push   %edx
  800720:	ff 55 08             	call   *0x8(%ebp)
  800723:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800726:	83 eb 01             	sub    $0x1,%ebx
  800729:	eb 1a                	jmp    800745 <vprintfmt+0x24b>
  80072b:	89 75 08             	mov    %esi,0x8(%ebp)
  80072e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800731:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800734:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800737:	eb 0c                	jmp    800745 <vprintfmt+0x24b>
  800739:	89 75 08             	mov    %esi,0x8(%ebp)
  80073c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80073f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800742:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800745:	83 c7 01             	add    $0x1,%edi
  800748:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80074c:	0f be d0             	movsbl %al,%edx
  80074f:	85 d2                	test   %edx,%edx
  800751:	74 23                	je     800776 <vprintfmt+0x27c>
  800753:	85 f6                	test   %esi,%esi
  800755:	78 a1                	js     8006f8 <vprintfmt+0x1fe>
  800757:	83 ee 01             	sub    $0x1,%esi
  80075a:	79 9c                	jns    8006f8 <vprintfmt+0x1fe>
  80075c:	89 df                	mov    %ebx,%edi
  80075e:	8b 75 08             	mov    0x8(%ebp),%esi
  800761:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800764:	eb 18                	jmp    80077e <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800766:	83 ec 08             	sub    $0x8,%esp
  800769:	53                   	push   %ebx
  80076a:	6a 20                	push   $0x20
  80076c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80076e:	83 ef 01             	sub    $0x1,%edi
  800771:	83 c4 10             	add    $0x10,%esp
  800774:	eb 08                	jmp    80077e <vprintfmt+0x284>
  800776:	89 df                	mov    %ebx,%edi
  800778:	8b 75 08             	mov    0x8(%ebp),%esi
  80077b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80077e:	85 ff                	test   %edi,%edi
  800780:	7f e4                	jg     800766 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800782:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800785:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800788:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80078b:	e9 90 fd ff ff       	jmp    800520 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800790:	83 f9 01             	cmp    $0x1,%ecx
  800793:	7e 19                	jle    8007ae <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800795:	8b 45 14             	mov    0x14(%ebp),%eax
  800798:	8b 50 04             	mov    0x4(%eax),%edx
  80079b:	8b 00                	mov    (%eax),%eax
  80079d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007a0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a6:	8d 40 08             	lea    0x8(%eax),%eax
  8007a9:	89 45 14             	mov    %eax,0x14(%ebp)
  8007ac:	eb 38                	jmp    8007e6 <vprintfmt+0x2ec>
	else if (lflag)
  8007ae:	85 c9                	test   %ecx,%ecx
  8007b0:	74 1b                	je     8007cd <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8007b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b5:	8b 00                	mov    (%eax),%eax
  8007b7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007ba:	89 c1                	mov    %eax,%ecx
  8007bc:	c1 f9 1f             	sar    $0x1f,%ecx
  8007bf:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c5:	8d 40 04             	lea    0x4(%eax),%eax
  8007c8:	89 45 14             	mov    %eax,0x14(%ebp)
  8007cb:	eb 19                	jmp    8007e6 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8007cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d0:	8b 00                	mov    (%eax),%eax
  8007d2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007d5:	89 c1                	mov    %eax,%ecx
  8007d7:	c1 f9 1f             	sar    $0x1f,%ecx
  8007da:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e0:	8d 40 04             	lea    0x4(%eax),%eax
  8007e3:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007e6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007e9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007ec:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007f1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007f5:	0f 89 36 01 00 00    	jns    800931 <vprintfmt+0x437>
				putch('-', putdat);
  8007fb:	83 ec 08             	sub    $0x8,%esp
  8007fe:	53                   	push   %ebx
  8007ff:	6a 2d                	push   $0x2d
  800801:	ff d6                	call   *%esi
				num = -(long long) num;
  800803:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800806:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800809:	f7 da                	neg    %edx
  80080b:	83 d1 00             	adc    $0x0,%ecx
  80080e:	f7 d9                	neg    %ecx
  800810:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800813:	b8 0a 00 00 00       	mov    $0xa,%eax
  800818:	e9 14 01 00 00       	jmp    800931 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80081d:	83 f9 01             	cmp    $0x1,%ecx
  800820:	7e 18                	jle    80083a <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800822:	8b 45 14             	mov    0x14(%ebp),%eax
  800825:	8b 10                	mov    (%eax),%edx
  800827:	8b 48 04             	mov    0x4(%eax),%ecx
  80082a:	8d 40 08             	lea    0x8(%eax),%eax
  80082d:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800830:	b8 0a 00 00 00       	mov    $0xa,%eax
  800835:	e9 f7 00 00 00       	jmp    800931 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80083a:	85 c9                	test   %ecx,%ecx
  80083c:	74 1a                	je     800858 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  80083e:	8b 45 14             	mov    0x14(%ebp),%eax
  800841:	8b 10                	mov    (%eax),%edx
  800843:	b9 00 00 00 00       	mov    $0x0,%ecx
  800848:	8d 40 04             	lea    0x4(%eax),%eax
  80084b:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80084e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800853:	e9 d9 00 00 00       	jmp    800931 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800858:	8b 45 14             	mov    0x14(%ebp),%eax
  80085b:	8b 10                	mov    (%eax),%edx
  80085d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800862:	8d 40 04             	lea    0x4(%eax),%eax
  800865:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800868:	b8 0a 00 00 00       	mov    $0xa,%eax
  80086d:	e9 bf 00 00 00       	jmp    800931 <vprintfmt+0x437>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800872:	83 f9 01             	cmp    $0x1,%ecx
  800875:	7e 13                	jle    80088a <vprintfmt+0x390>
		return va_arg(*ap, long long);
  800877:	8b 45 14             	mov    0x14(%ebp),%eax
  80087a:	8b 50 04             	mov    0x4(%eax),%edx
  80087d:	8b 00                	mov    (%eax),%eax
  80087f:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800882:	8d 49 08             	lea    0x8(%ecx),%ecx
  800885:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800888:	eb 28                	jmp    8008b2 <vprintfmt+0x3b8>
	else if (lflag)
  80088a:	85 c9                	test   %ecx,%ecx
  80088c:	74 13                	je     8008a1 <vprintfmt+0x3a7>
		return va_arg(*ap, long);
  80088e:	8b 45 14             	mov    0x14(%ebp),%eax
  800891:	8b 10                	mov    (%eax),%edx
  800893:	89 d0                	mov    %edx,%eax
  800895:	99                   	cltd   
  800896:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800899:	8d 49 04             	lea    0x4(%ecx),%ecx
  80089c:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80089f:	eb 11                	jmp    8008b2 <vprintfmt+0x3b8>
	else
		return va_arg(*ap, int);
  8008a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a4:	8b 10                	mov    (%eax),%edx
  8008a6:	89 d0                	mov    %edx,%eax
  8008a8:	99                   	cltd   
  8008a9:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8008ac:	8d 49 04             	lea    0x4(%ecx),%ecx
  8008af:	89 4d 14             	mov    %ecx,0x14(%ebp)
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getint(&ap, lflag);
  8008b2:	89 d1                	mov    %edx,%ecx
  8008b4:	89 c2                	mov    %eax,%edx
			base = 8;
  8008b6:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8008bb:	eb 74                	jmp    800931 <vprintfmt+0x437>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8008bd:	83 ec 08             	sub    $0x8,%esp
  8008c0:	53                   	push   %ebx
  8008c1:	6a 30                	push   $0x30
  8008c3:	ff d6                	call   *%esi
			putch('x', putdat);
  8008c5:	83 c4 08             	add    $0x8,%esp
  8008c8:	53                   	push   %ebx
  8008c9:	6a 78                	push   $0x78
  8008cb:	ff d6                	call   *%esi
			num = (unsigned long long)
  8008cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d0:	8b 10                	mov    (%eax),%edx
  8008d2:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8008d7:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8008da:	8d 40 04             	lea    0x4(%eax),%eax
  8008dd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008e0:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8008e5:	eb 4a                	jmp    800931 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8008e7:	83 f9 01             	cmp    $0x1,%ecx
  8008ea:	7e 15                	jle    800901 <vprintfmt+0x407>
		return va_arg(*ap, unsigned long long);
  8008ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ef:	8b 10                	mov    (%eax),%edx
  8008f1:	8b 48 04             	mov    0x4(%eax),%ecx
  8008f4:	8d 40 08             	lea    0x8(%eax),%eax
  8008f7:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8008fa:	b8 10 00 00 00       	mov    $0x10,%eax
  8008ff:	eb 30                	jmp    800931 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800901:	85 c9                	test   %ecx,%ecx
  800903:	74 17                	je     80091c <vprintfmt+0x422>
		return va_arg(*ap, unsigned long);
  800905:	8b 45 14             	mov    0x14(%ebp),%eax
  800908:	8b 10                	mov    (%eax),%edx
  80090a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80090f:	8d 40 04             	lea    0x4(%eax),%eax
  800912:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800915:	b8 10 00 00 00       	mov    $0x10,%eax
  80091a:	eb 15                	jmp    800931 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80091c:	8b 45 14             	mov    0x14(%ebp),%eax
  80091f:	8b 10                	mov    (%eax),%edx
  800921:	b9 00 00 00 00       	mov    $0x0,%ecx
  800926:	8d 40 04             	lea    0x4(%eax),%eax
  800929:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80092c:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800931:	83 ec 0c             	sub    $0xc,%esp
  800934:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800938:	57                   	push   %edi
  800939:	ff 75 e0             	pushl  -0x20(%ebp)
  80093c:	50                   	push   %eax
  80093d:	51                   	push   %ecx
  80093e:	52                   	push   %edx
  80093f:	89 da                	mov    %ebx,%edx
  800941:	89 f0                	mov    %esi,%eax
  800943:	e8 c9 fa ff ff       	call   800411 <printnum>
			break;
  800948:	83 c4 20             	add    $0x20,%esp
  80094b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80094e:	e9 cd fb ff ff       	jmp    800520 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800953:	83 ec 08             	sub    $0x8,%esp
  800956:	53                   	push   %ebx
  800957:	52                   	push   %edx
  800958:	ff d6                	call   *%esi
			break;
  80095a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80095d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800960:	e9 bb fb ff ff       	jmp    800520 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800965:	83 ec 08             	sub    $0x8,%esp
  800968:	53                   	push   %ebx
  800969:	6a 25                	push   $0x25
  80096b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80096d:	83 c4 10             	add    $0x10,%esp
  800970:	eb 03                	jmp    800975 <vprintfmt+0x47b>
  800972:	83 ef 01             	sub    $0x1,%edi
  800975:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800979:	75 f7                	jne    800972 <vprintfmt+0x478>
  80097b:	e9 a0 fb ff ff       	jmp    800520 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800980:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800983:	5b                   	pop    %ebx
  800984:	5e                   	pop    %esi
  800985:	5f                   	pop    %edi
  800986:	5d                   	pop    %ebp
  800987:	c3                   	ret    

00800988 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800988:	55                   	push   %ebp
  800989:	89 e5                	mov    %esp,%ebp
  80098b:	83 ec 18             	sub    $0x18,%esp
  80098e:	8b 45 08             	mov    0x8(%ebp),%eax
  800991:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800994:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800997:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80099b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80099e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009a5:	85 c0                	test   %eax,%eax
  8009a7:	74 26                	je     8009cf <vsnprintf+0x47>
  8009a9:	85 d2                	test   %edx,%edx
  8009ab:	7e 22                	jle    8009cf <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009ad:	ff 75 14             	pushl  0x14(%ebp)
  8009b0:	ff 75 10             	pushl  0x10(%ebp)
  8009b3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009b6:	50                   	push   %eax
  8009b7:	68 c0 04 80 00       	push   $0x8004c0
  8009bc:	e8 39 fb ff ff       	call   8004fa <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009c4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009ca:	83 c4 10             	add    $0x10,%esp
  8009cd:	eb 05                	jmp    8009d4 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8009cf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8009d4:	c9                   	leave  
  8009d5:	c3                   	ret    

008009d6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009d6:	55                   	push   %ebp
  8009d7:	89 e5                	mov    %esp,%ebp
  8009d9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009dc:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009df:	50                   	push   %eax
  8009e0:	ff 75 10             	pushl  0x10(%ebp)
  8009e3:	ff 75 0c             	pushl  0xc(%ebp)
  8009e6:	ff 75 08             	pushl  0x8(%ebp)
  8009e9:	e8 9a ff ff ff       	call   800988 <vsnprintf>
	va_end(ap);

	return rc;
}
  8009ee:	c9                   	leave  
  8009ef:	c3                   	ret    

008009f0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009f0:	55                   	push   %ebp
  8009f1:	89 e5                	mov    %esp,%ebp
  8009f3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8009fb:	eb 03                	jmp    800a00 <strlen+0x10>
		n++;
  8009fd:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a00:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a04:	75 f7                	jne    8009fd <strlen+0xd>
		n++;
	return n;
}
  800a06:	5d                   	pop    %ebp
  800a07:	c3                   	ret    

00800a08 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a08:	55                   	push   %ebp
  800a09:	89 e5                	mov    %esp,%ebp
  800a0b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a0e:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a11:	ba 00 00 00 00       	mov    $0x0,%edx
  800a16:	eb 03                	jmp    800a1b <strnlen+0x13>
		n++;
  800a18:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a1b:	39 c2                	cmp    %eax,%edx
  800a1d:	74 08                	je     800a27 <strnlen+0x1f>
  800a1f:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800a23:	75 f3                	jne    800a18 <strnlen+0x10>
  800a25:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800a27:	5d                   	pop    %ebp
  800a28:	c3                   	ret    

00800a29 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a29:	55                   	push   %ebp
  800a2a:	89 e5                	mov    %esp,%ebp
  800a2c:	53                   	push   %ebx
  800a2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a33:	89 c2                	mov    %eax,%edx
  800a35:	83 c2 01             	add    $0x1,%edx
  800a38:	83 c1 01             	add    $0x1,%ecx
  800a3b:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a3f:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a42:	84 db                	test   %bl,%bl
  800a44:	75 ef                	jne    800a35 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a46:	5b                   	pop    %ebx
  800a47:	5d                   	pop    %ebp
  800a48:	c3                   	ret    

00800a49 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a49:	55                   	push   %ebp
  800a4a:	89 e5                	mov    %esp,%ebp
  800a4c:	53                   	push   %ebx
  800a4d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a50:	53                   	push   %ebx
  800a51:	e8 9a ff ff ff       	call   8009f0 <strlen>
  800a56:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a59:	ff 75 0c             	pushl  0xc(%ebp)
  800a5c:	01 d8                	add    %ebx,%eax
  800a5e:	50                   	push   %eax
  800a5f:	e8 c5 ff ff ff       	call   800a29 <strcpy>
	return dst;
}
  800a64:	89 d8                	mov    %ebx,%eax
  800a66:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a69:	c9                   	leave  
  800a6a:	c3                   	ret    

00800a6b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a6b:	55                   	push   %ebp
  800a6c:	89 e5                	mov    %esp,%ebp
  800a6e:	56                   	push   %esi
  800a6f:	53                   	push   %ebx
  800a70:	8b 75 08             	mov    0x8(%ebp),%esi
  800a73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a76:	89 f3                	mov    %esi,%ebx
  800a78:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a7b:	89 f2                	mov    %esi,%edx
  800a7d:	eb 0f                	jmp    800a8e <strncpy+0x23>
		*dst++ = *src;
  800a7f:	83 c2 01             	add    $0x1,%edx
  800a82:	0f b6 01             	movzbl (%ecx),%eax
  800a85:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a88:	80 39 01             	cmpb   $0x1,(%ecx)
  800a8b:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a8e:	39 da                	cmp    %ebx,%edx
  800a90:	75 ed                	jne    800a7f <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a92:	89 f0                	mov    %esi,%eax
  800a94:	5b                   	pop    %ebx
  800a95:	5e                   	pop    %esi
  800a96:	5d                   	pop    %ebp
  800a97:	c3                   	ret    

00800a98 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a98:	55                   	push   %ebp
  800a99:	89 e5                	mov    %esp,%ebp
  800a9b:	56                   	push   %esi
  800a9c:	53                   	push   %ebx
  800a9d:	8b 75 08             	mov    0x8(%ebp),%esi
  800aa0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aa3:	8b 55 10             	mov    0x10(%ebp),%edx
  800aa6:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800aa8:	85 d2                	test   %edx,%edx
  800aaa:	74 21                	je     800acd <strlcpy+0x35>
  800aac:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800ab0:	89 f2                	mov    %esi,%edx
  800ab2:	eb 09                	jmp    800abd <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800ab4:	83 c2 01             	add    $0x1,%edx
  800ab7:	83 c1 01             	add    $0x1,%ecx
  800aba:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800abd:	39 c2                	cmp    %eax,%edx
  800abf:	74 09                	je     800aca <strlcpy+0x32>
  800ac1:	0f b6 19             	movzbl (%ecx),%ebx
  800ac4:	84 db                	test   %bl,%bl
  800ac6:	75 ec                	jne    800ab4 <strlcpy+0x1c>
  800ac8:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800aca:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800acd:	29 f0                	sub    %esi,%eax
}
  800acf:	5b                   	pop    %ebx
  800ad0:	5e                   	pop    %esi
  800ad1:	5d                   	pop    %ebp
  800ad2:	c3                   	ret    

00800ad3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ad3:	55                   	push   %ebp
  800ad4:	89 e5                	mov    %esp,%ebp
  800ad6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ad9:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800adc:	eb 06                	jmp    800ae4 <strcmp+0x11>
		p++, q++;
  800ade:	83 c1 01             	add    $0x1,%ecx
  800ae1:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800ae4:	0f b6 01             	movzbl (%ecx),%eax
  800ae7:	84 c0                	test   %al,%al
  800ae9:	74 04                	je     800aef <strcmp+0x1c>
  800aeb:	3a 02                	cmp    (%edx),%al
  800aed:	74 ef                	je     800ade <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800aef:	0f b6 c0             	movzbl %al,%eax
  800af2:	0f b6 12             	movzbl (%edx),%edx
  800af5:	29 d0                	sub    %edx,%eax
}
  800af7:	5d                   	pop    %ebp
  800af8:	c3                   	ret    

00800af9 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800af9:	55                   	push   %ebp
  800afa:	89 e5                	mov    %esp,%ebp
  800afc:	53                   	push   %ebx
  800afd:	8b 45 08             	mov    0x8(%ebp),%eax
  800b00:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b03:	89 c3                	mov    %eax,%ebx
  800b05:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b08:	eb 06                	jmp    800b10 <strncmp+0x17>
		n--, p++, q++;
  800b0a:	83 c0 01             	add    $0x1,%eax
  800b0d:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b10:	39 d8                	cmp    %ebx,%eax
  800b12:	74 15                	je     800b29 <strncmp+0x30>
  800b14:	0f b6 08             	movzbl (%eax),%ecx
  800b17:	84 c9                	test   %cl,%cl
  800b19:	74 04                	je     800b1f <strncmp+0x26>
  800b1b:	3a 0a                	cmp    (%edx),%cl
  800b1d:	74 eb                	je     800b0a <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b1f:	0f b6 00             	movzbl (%eax),%eax
  800b22:	0f b6 12             	movzbl (%edx),%edx
  800b25:	29 d0                	sub    %edx,%eax
  800b27:	eb 05                	jmp    800b2e <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b29:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b2e:	5b                   	pop    %ebx
  800b2f:	5d                   	pop    %ebp
  800b30:	c3                   	ret    

00800b31 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b31:	55                   	push   %ebp
  800b32:	89 e5                	mov    %esp,%ebp
  800b34:	8b 45 08             	mov    0x8(%ebp),%eax
  800b37:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b3b:	eb 07                	jmp    800b44 <strchr+0x13>
		if (*s == c)
  800b3d:	38 ca                	cmp    %cl,%dl
  800b3f:	74 0f                	je     800b50 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b41:	83 c0 01             	add    $0x1,%eax
  800b44:	0f b6 10             	movzbl (%eax),%edx
  800b47:	84 d2                	test   %dl,%dl
  800b49:	75 f2                	jne    800b3d <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800b4b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b50:	5d                   	pop    %ebp
  800b51:	c3                   	ret    

00800b52 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b52:	55                   	push   %ebp
  800b53:	89 e5                	mov    %esp,%ebp
  800b55:	8b 45 08             	mov    0x8(%ebp),%eax
  800b58:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b5c:	eb 03                	jmp    800b61 <strfind+0xf>
  800b5e:	83 c0 01             	add    $0x1,%eax
  800b61:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b64:	38 ca                	cmp    %cl,%dl
  800b66:	74 04                	je     800b6c <strfind+0x1a>
  800b68:	84 d2                	test   %dl,%dl
  800b6a:	75 f2                	jne    800b5e <strfind+0xc>
			break;
	return (char *) s;
}
  800b6c:	5d                   	pop    %ebp
  800b6d:	c3                   	ret    

00800b6e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b6e:	55                   	push   %ebp
  800b6f:	89 e5                	mov    %esp,%ebp
  800b71:	57                   	push   %edi
  800b72:	56                   	push   %esi
  800b73:	53                   	push   %ebx
  800b74:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b77:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b7a:	85 c9                	test   %ecx,%ecx
  800b7c:	74 36                	je     800bb4 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b7e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b84:	75 28                	jne    800bae <memset+0x40>
  800b86:	f6 c1 03             	test   $0x3,%cl
  800b89:	75 23                	jne    800bae <memset+0x40>
		c &= 0xFF;
  800b8b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b8f:	89 d3                	mov    %edx,%ebx
  800b91:	c1 e3 08             	shl    $0x8,%ebx
  800b94:	89 d6                	mov    %edx,%esi
  800b96:	c1 e6 18             	shl    $0x18,%esi
  800b99:	89 d0                	mov    %edx,%eax
  800b9b:	c1 e0 10             	shl    $0x10,%eax
  800b9e:	09 f0                	or     %esi,%eax
  800ba0:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800ba2:	89 d8                	mov    %ebx,%eax
  800ba4:	09 d0                	or     %edx,%eax
  800ba6:	c1 e9 02             	shr    $0x2,%ecx
  800ba9:	fc                   	cld    
  800baa:	f3 ab                	rep stos %eax,%es:(%edi)
  800bac:	eb 06                	jmp    800bb4 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bae:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bb1:	fc                   	cld    
  800bb2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800bb4:	89 f8                	mov    %edi,%eax
  800bb6:	5b                   	pop    %ebx
  800bb7:	5e                   	pop    %esi
  800bb8:	5f                   	pop    %edi
  800bb9:	5d                   	pop    %ebp
  800bba:	c3                   	ret    

00800bbb <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bbb:	55                   	push   %ebp
  800bbc:	89 e5                	mov    %esp,%ebp
  800bbe:	57                   	push   %edi
  800bbf:	56                   	push   %esi
  800bc0:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc3:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bc6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bc9:	39 c6                	cmp    %eax,%esi
  800bcb:	73 35                	jae    800c02 <memmove+0x47>
  800bcd:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bd0:	39 d0                	cmp    %edx,%eax
  800bd2:	73 2e                	jae    800c02 <memmove+0x47>
		s += n;
		d += n;
  800bd4:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bd7:	89 d6                	mov    %edx,%esi
  800bd9:	09 fe                	or     %edi,%esi
  800bdb:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800be1:	75 13                	jne    800bf6 <memmove+0x3b>
  800be3:	f6 c1 03             	test   $0x3,%cl
  800be6:	75 0e                	jne    800bf6 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800be8:	83 ef 04             	sub    $0x4,%edi
  800beb:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bee:	c1 e9 02             	shr    $0x2,%ecx
  800bf1:	fd                   	std    
  800bf2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bf4:	eb 09                	jmp    800bff <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800bf6:	83 ef 01             	sub    $0x1,%edi
  800bf9:	8d 72 ff             	lea    -0x1(%edx),%esi
  800bfc:	fd                   	std    
  800bfd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bff:	fc                   	cld    
  800c00:	eb 1d                	jmp    800c1f <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c02:	89 f2                	mov    %esi,%edx
  800c04:	09 c2                	or     %eax,%edx
  800c06:	f6 c2 03             	test   $0x3,%dl
  800c09:	75 0f                	jne    800c1a <memmove+0x5f>
  800c0b:	f6 c1 03             	test   $0x3,%cl
  800c0e:	75 0a                	jne    800c1a <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800c10:	c1 e9 02             	shr    $0x2,%ecx
  800c13:	89 c7                	mov    %eax,%edi
  800c15:	fc                   	cld    
  800c16:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c18:	eb 05                	jmp    800c1f <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c1a:	89 c7                	mov    %eax,%edi
  800c1c:	fc                   	cld    
  800c1d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c1f:	5e                   	pop    %esi
  800c20:	5f                   	pop    %edi
  800c21:	5d                   	pop    %ebp
  800c22:	c3                   	ret    

00800c23 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c23:	55                   	push   %ebp
  800c24:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800c26:	ff 75 10             	pushl  0x10(%ebp)
  800c29:	ff 75 0c             	pushl  0xc(%ebp)
  800c2c:	ff 75 08             	pushl  0x8(%ebp)
  800c2f:	e8 87 ff ff ff       	call   800bbb <memmove>
}
  800c34:	c9                   	leave  
  800c35:	c3                   	ret    

00800c36 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c36:	55                   	push   %ebp
  800c37:	89 e5                	mov    %esp,%ebp
  800c39:	56                   	push   %esi
  800c3a:	53                   	push   %ebx
  800c3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c3e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c41:	89 c6                	mov    %eax,%esi
  800c43:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c46:	eb 1a                	jmp    800c62 <memcmp+0x2c>
		if (*s1 != *s2)
  800c48:	0f b6 08             	movzbl (%eax),%ecx
  800c4b:	0f b6 1a             	movzbl (%edx),%ebx
  800c4e:	38 d9                	cmp    %bl,%cl
  800c50:	74 0a                	je     800c5c <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800c52:	0f b6 c1             	movzbl %cl,%eax
  800c55:	0f b6 db             	movzbl %bl,%ebx
  800c58:	29 d8                	sub    %ebx,%eax
  800c5a:	eb 0f                	jmp    800c6b <memcmp+0x35>
		s1++, s2++;
  800c5c:	83 c0 01             	add    $0x1,%eax
  800c5f:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c62:	39 f0                	cmp    %esi,%eax
  800c64:	75 e2                	jne    800c48 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c66:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c6b:	5b                   	pop    %ebx
  800c6c:	5e                   	pop    %esi
  800c6d:	5d                   	pop    %ebp
  800c6e:	c3                   	ret    

00800c6f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c6f:	55                   	push   %ebp
  800c70:	89 e5                	mov    %esp,%ebp
  800c72:	53                   	push   %ebx
  800c73:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c76:	89 c1                	mov    %eax,%ecx
  800c78:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800c7b:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c7f:	eb 0a                	jmp    800c8b <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c81:	0f b6 10             	movzbl (%eax),%edx
  800c84:	39 da                	cmp    %ebx,%edx
  800c86:	74 07                	je     800c8f <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c88:	83 c0 01             	add    $0x1,%eax
  800c8b:	39 c8                	cmp    %ecx,%eax
  800c8d:	72 f2                	jb     800c81 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c8f:	5b                   	pop    %ebx
  800c90:	5d                   	pop    %ebp
  800c91:	c3                   	ret    

00800c92 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c92:	55                   	push   %ebp
  800c93:	89 e5                	mov    %esp,%ebp
  800c95:	57                   	push   %edi
  800c96:	56                   	push   %esi
  800c97:	53                   	push   %ebx
  800c98:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c9b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c9e:	eb 03                	jmp    800ca3 <strtol+0x11>
		s++;
  800ca0:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ca3:	0f b6 01             	movzbl (%ecx),%eax
  800ca6:	3c 20                	cmp    $0x20,%al
  800ca8:	74 f6                	je     800ca0 <strtol+0xe>
  800caa:	3c 09                	cmp    $0x9,%al
  800cac:	74 f2                	je     800ca0 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800cae:	3c 2b                	cmp    $0x2b,%al
  800cb0:	75 0a                	jne    800cbc <strtol+0x2a>
		s++;
  800cb2:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800cb5:	bf 00 00 00 00       	mov    $0x0,%edi
  800cba:	eb 11                	jmp    800ccd <strtol+0x3b>
  800cbc:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800cc1:	3c 2d                	cmp    $0x2d,%al
  800cc3:	75 08                	jne    800ccd <strtol+0x3b>
		s++, neg = 1;
  800cc5:	83 c1 01             	add    $0x1,%ecx
  800cc8:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ccd:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800cd3:	75 15                	jne    800cea <strtol+0x58>
  800cd5:	80 39 30             	cmpb   $0x30,(%ecx)
  800cd8:	75 10                	jne    800cea <strtol+0x58>
  800cda:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800cde:	75 7c                	jne    800d5c <strtol+0xca>
		s += 2, base = 16;
  800ce0:	83 c1 02             	add    $0x2,%ecx
  800ce3:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ce8:	eb 16                	jmp    800d00 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800cea:	85 db                	test   %ebx,%ebx
  800cec:	75 12                	jne    800d00 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800cee:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cf3:	80 39 30             	cmpb   $0x30,(%ecx)
  800cf6:	75 08                	jne    800d00 <strtol+0x6e>
		s++, base = 8;
  800cf8:	83 c1 01             	add    $0x1,%ecx
  800cfb:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800d00:	b8 00 00 00 00       	mov    $0x0,%eax
  800d05:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d08:	0f b6 11             	movzbl (%ecx),%edx
  800d0b:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d0e:	89 f3                	mov    %esi,%ebx
  800d10:	80 fb 09             	cmp    $0x9,%bl
  800d13:	77 08                	ja     800d1d <strtol+0x8b>
			dig = *s - '0';
  800d15:	0f be d2             	movsbl %dl,%edx
  800d18:	83 ea 30             	sub    $0x30,%edx
  800d1b:	eb 22                	jmp    800d3f <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800d1d:	8d 72 9f             	lea    -0x61(%edx),%esi
  800d20:	89 f3                	mov    %esi,%ebx
  800d22:	80 fb 19             	cmp    $0x19,%bl
  800d25:	77 08                	ja     800d2f <strtol+0x9d>
			dig = *s - 'a' + 10;
  800d27:	0f be d2             	movsbl %dl,%edx
  800d2a:	83 ea 57             	sub    $0x57,%edx
  800d2d:	eb 10                	jmp    800d3f <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800d2f:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d32:	89 f3                	mov    %esi,%ebx
  800d34:	80 fb 19             	cmp    $0x19,%bl
  800d37:	77 16                	ja     800d4f <strtol+0xbd>
			dig = *s - 'A' + 10;
  800d39:	0f be d2             	movsbl %dl,%edx
  800d3c:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800d3f:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d42:	7d 0b                	jge    800d4f <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800d44:	83 c1 01             	add    $0x1,%ecx
  800d47:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d4b:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800d4d:	eb b9                	jmp    800d08 <strtol+0x76>

	if (endptr)
  800d4f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d53:	74 0d                	je     800d62 <strtol+0xd0>
		*endptr = (char *) s;
  800d55:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d58:	89 0e                	mov    %ecx,(%esi)
  800d5a:	eb 06                	jmp    800d62 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d5c:	85 db                	test   %ebx,%ebx
  800d5e:	74 98                	je     800cf8 <strtol+0x66>
  800d60:	eb 9e                	jmp    800d00 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800d62:	89 c2                	mov    %eax,%edx
  800d64:	f7 da                	neg    %edx
  800d66:	85 ff                	test   %edi,%edi
  800d68:	0f 45 c2             	cmovne %edx,%eax
}
  800d6b:	5b                   	pop    %ebx
  800d6c:	5e                   	pop    %esi
  800d6d:	5f                   	pop    %edi
  800d6e:	5d                   	pop    %ebp
  800d6f:	c3                   	ret    

00800d70 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d70:	55                   	push   %ebp
  800d71:	89 e5                	mov    %esp,%ebp
  800d73:	57                   	push   %edi
  800d74:	56                   	push   %esi
  800d75:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d76:	b8 00 00 00 00       	mov    $0x0,%eax
  800d7b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d81:	89 c3                	mov    %eax,%ebx
  800d83:	89 c7                	mov    %eax,%edi
  800d85:	89 c6                	mov    %eax,%esi
  800d87:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d89:	5b                   	pop    %ebx
  800d8a:	5e                   	pop    %esi
  800d8b:	5f                   	pop    %edi
  800d8c:	5d                   	pop    %ebp
  800d8d:	c3                   	ret    

00800d8e <sys_cgetc>:

int
sys_cgetc(void)
{
  800d8e:	55                   	push   %ebp
  800d8f:	89 e5                	mov    %esp,%ebp
  800d91:	57                   	push   %edi
  800d92:	56                   	push   %esi
  800d93:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d94:	ba 00 00 00 00       	mov    $0x0,%edx
  800d99:	b8 01 00 00 00       	mov    $0x1,%eax
  800d9e:	89 d1                	mov    %edx,%ecx
  800da0:	89 d3                	mov    %edx,%ebx
  800da2:	89 d7                	mov    %edx,%edi
  800da4:	89 d6                	mov    %edx,%esi
  800da6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800da8:	5b                   	pop    %ebx
  800da9:	5e                   	pop    %esi
  800daa:	5f                   	pop    %edi
  800dab:	5d                   	pop    %ebp
  800dac:	c3                   	ret    

00800dad <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800dad:	55                   	push   %ebp
  800dae:	89 e5                	mov    %esp,%ebp
  800db0:	57                   	push   %edi
  800db1:	56                   	push   %esi
  800db2:	53                   	push   %ebx
  800db3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dbb:	b8 03 00 00 00       	mov    $0x3,%eax
  800dc0:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc3:	89 cb                	mov    %ecx,%ebx
  800dc5:	89 cf                	mov    %ecx,%edi
  800dc7:	89 ce                	mov    %ecx,%esi
  800dc9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dcb:	85 c0                	test   %eax,%eax
  800dcd:	7e 17                	jle    800de6 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dcf:	83 ec 0c             	sub    $0xc,%esp
  800dd2:	50                   	push   %eax
  800dd3:	6a 03                	push   $0x3
  800dd5:	68 df 26 80 00       	push   $0x8026df
  800dda:	6a 23                	push   $0x23
  800ddc:	68 fc 26 80 00       	push   $0x8026fc
  800de1:	e8 3e f5 ff ff       	call   800324 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800de6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de9:	5b                   	pop    %ebx
  800dea:	5e                   	pop    %esi
  800deb:	5f                   	pop    %edi
  800dec:	5d                   	pop    %ebp
  800ded:	c3                   	ret    

00800dee <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800dee:	55                   	push   %ebp
  800def:	89 e5                	mov    %esp,%ebp
  800df1:	57                   	push   %edi
  800df2:	56                   	push   %esi
  800df3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df4:	ba 00 00 00 00       	mov    $0x0,%edx
  800df9:	b8 02 00 00 00       	mov    $0x2,%eax
  800dfe:	89 d1                	mov    %edx,%ecx
  800e00:	89 d3                	mov    %edx,%ebx
  800e02:	89 d7                	mov    %edx,%edi
  800e04:	89 d6                	mov    %edx,%esi
  800e06:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e08:	5b                   	pop    %ebx
  800e09:	5e                   	pop    %esi
  800e0a:	5f                   	pop    %edi
  800e0b:	5d                   	pop    %ebp
  800e0c:	c3                   	ret    

00800e0d <sys_yield>:

void
sys_yield(void)
{
  800e0d:	55                   	push   %ebp
  800e0e:	89 e5                	mov    %esp,%ebp
  800e10:	57                   	push   %edi
  800e11:	56                   	push   %esi
  800e12:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e13:	ba 00 00 00 00       	mov    $0x0,%edx
  800e18:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e1d:	89 d1                	mov    %edx,%ecx
  800e1f:	89 d3                	mov    %edx,%ebx
  800e21:	89 d7                	mov    %edx,%edi
  800e23:	89 d6                	mov    %edx,%esi
  800e25:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e27:	5b                   	pop    %ebx
  800e28:	5e                   	pop    %esi
  800e29:	5f                   	pop    %edi
  800e2a:	5d                   	pop    %ebp
  800e2b:	c3                   	ret    

00800e2c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e2c:	55                   	push   %ebp
  800e2d:	89 e5                	mov    %esp,%ebp
  800e2f:	57                   	push   %edi
  800e30:	56                   	push   %esi
  800e31:	53                   	push   %ebx
  800e32:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e35:	be 00 00 00 00       	mov    $0x0,%esi
  800e3a:	b8 04 00 00 00       	mov    $0x4,%eax
  800e3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e42:	8b 55 08             	mov    0x8(%ebp),%edx
  800e45:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e48:	89 f7                	mov    %esi,%edi
  800e4a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e4c:	85 c0                	test   %eax,%eax
  800e4e:	7e 17                	jle    800e67 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e50:	83 ec 0c             	sub    $0xc,%esp
  800e53:	50                   	push   %eax
  800e54:	6a 04                	push   $0x4
  800e56:	68 df 26 80 00       	push   $0x8026df
  800e5b:	6a 23                	push   $0x23
  800e5d:	68 fc 26 80 00       	push   $0x8026fc
  800e62:	e8 bd f4 ff ff       	call   800324 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e67:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e6a:	5b                   	pop    %ebx
  800e6b:	5e                   	pop    %esi
  800e6c:	5f                   	pop    %edi
  800e6d:	5d                   	pop    %ebp
  800e6e:	c3                   	ret    

00800e6f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e6f:	55                   	push   %ebp
  800e70:	89 e5                	mov    %esp,%ebp
  800e72:	57                   	push   %edi
  800e73:	56                   	push   %esi
  800e74:	53                   	push   %ebx
  800e75:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e78:	b8 05 00 00 00       	mov    $0x5,%eax
  800e7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e80:	8b 55 08             	mov    0x8(%ebp),%edx
  800e83:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e86:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e89:	8b 75 18             	mov    0x18(%ebp),%esi
  800e8c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e8e:	85 c0                	test   %eax,%eax
  800e90:	7e 17                	jle    800ea9 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e92:	83 ec 0c             	sub    $0xc,%esp
  800e95:	50                   	push   %eax
  800e96:	6a 05                	push   $0x5
  800e98:	68 df 26 80 00       	push   $0x8026df
  800e9d:	6a 23                	push   $0x23
  800e9f:	68 fc 26 80 00       	push   $0x8026fc
  800ea4:	e8 7b f4 ff ff       	call   800324 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ea9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eac:	5b                   	pop    %ebx
  800ead:	5e                   	pop    %esi
  800eae:	5f                   	pop    %edi
  800eaf:	5d                   	pop    %ebp
  800eb0:	c3                   	ret    

00800eb1 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800eb1:	55                   	push   %ebp
  800eb2:	89 e5                	mov    %esp,%ebp
  800eb4:	57                   	push   %edi
  800eb5:	56                   	push   %esi
  800eb6:	53                   	push   %ebx
  800eb7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eba:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ebf:	b8 06 00 00 00       	mov    $0x6,%eax
  800ec4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ec7:	8b 55 08             	mov    0x8(%ebp),%edx
  800eca:	89 df                	mov    %ebx,%edi
  800ecc:	89 de                	mov    %ebx,%esi
  800ece:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ed0:	85 c0                	test   %eax,%eax
  800ed2:	7e 17                	jle    800eeb <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ed4:	83 ec 0c             	sub    $0xc,%esp
  800ed7:	50                   	push   %eax
  800ed8:	6a 06                	push   $0x6
  800eda:	68 df 26 80 00       	push   $0x8026df
  800edf:	6a 23                	push   $0x23
  800ee1:	68 fc 26 80 00       	push   $0x8026fc
  800ee6:	e8 39 f4 ff ff       	call   800324 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800eeb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eee:	5b                   	pop    %ebx
  800eef:	5e                   	pop    %esi
  800ef0:	5f                   	pop    %edi
  800ef1:	5d                   	pop    %ebp
  800ef2:	c3                   	ret    

00800ef3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ef3:	55                   	push   %ebp
  800ef4:	89 e5                	mov    %esp,%ebp
  800ef6:	57                   	push   %edi
  800ef7:	56                   	push   %esi
  800ef8:	53                   	push   %ebx
  800ef9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800efc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f01:	b8 08 00 00 00       	mov    $0x8,%eax
  800f06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f09:	8b 55 08             	mov    0x8(%ebp),%edx
  800f0c:	89 df                	mov    %ebx,%edi
  800f0e:	89 de                	mov    %ebx,%esi
  800f10:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f12:	85 c0                	test   %eax,%eax
  800f14:	7e 17                	jle    800f2d <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f16:	83 ec 0c             	sub    $0xc,%esp
  800f19:	50                   	push   %eax
  800f1a:	6a 08                	push   $0x8
  800f1c:	68 df 26 80 00       	push   $0x8026df
  800f21:	6a 23                	push   $0x23
  800f23:	68 fc 26 80 00       	push   $0x8026fc
  800f28:	e8 f7 f3 ff ff       	call   800324 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f2d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f30:	5b                   	pop    %ebx
  800f31:	5e                   	pop    %esi
  800f32:	5f                   	pop    %edi
  800f33:	5d                   	pop    %ebp
  800f34:	c3                   	ret    

00800f35 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f35:	55                   	push   %ebp
  800f36:	89 e5                	mov    %esp,%ebp
  800f38:	57                   	push   %edi
  800f39:	56                   	push   %esi
  800f3a:	53                   	push   %ebx
  800f3b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f3e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f43:	b8 09 00 00 00       	mov    $0x9,%eax
  800f48:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f4b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f4e:	89 df                	mov    %ebx,%edi
  800f50:	89 de                	mov    %ebx,%esi
  800f52:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f54:	85 c0                	test   %eax,%eax
  800f56:	7e 17                	jle    800f6f <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f58:	83 ec 0c             	sub    $0xc,%esp
  800f5b:	50                   	push   %eax
  800f5c:	6a 09                	push   $0x9
  800f5e:	68 df 26 80 00       	push   $0x8026df
  800f63:	6a 23                	push   $0x23
  800f65:	68 fc 26 80 00       	push   $0x8026fc
  800f6a:	e8 b5 f3 ff ff       	call   800324 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800f6f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f72:	5b                   	pop    %ebx
  800f73:	5e                   	pop    %esi
  800f74:	5f                   	pop    %edi
  800f75:	5d                   	pop    %ebp
  800f76:	c3                   	ret    

00800f77 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f77:	55                   	push   %ebp
  800f78:	89 e5                	mov    %esp,%ebp
  800f7a:	57                   	push   %edi
  800f7b:	56                   	push   %esi
  800f7c:	53                   	push   %ebx
  800f7d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f80:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f85:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f8d:	8b 55 08             	mov    0x8(%ebp),%edx
  800f90:	89 df                	mov    %ebx,%edi
  800f92:	89 de                	mov    %ebx,%esi
  800f94:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f96:	85 c0                	test   %eax,%eax
  800f98:	7e 17                	jle    800fb1 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f9a:	83 ec 0c             	sub    $0xc,%esp
  800f9d:	50                   	push   %eax
  800f9e:	6a 0a                	push   $0xa
  800fa0:	68 df 26 80 00       	push   $0x8026df
  800fa5:	6a 23                	push   $0x23
  800fa7:	68 fc 26 80 00       	push   $0x8026fc
  800fac:	e8 73 f3 ff ff       	call   800324 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800fb1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fb4:	5b                   	pop    %ebx
  800fb5:	5e                   	pop    %esi
  800fb6:	5f                   	pop    %edi
  800fb7:	5d                   	pop    %ebp
  800fb8:	c3                   	ret    

00800fb9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800fb9:	55                   	push   %ebp
  800fba:	89 e5                	mov    %esp,%ebp
  800fbc:	57                   	push   %edi
  800fbd:	56                   	push   %esi
  800fbe:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fbf:	be 00 00 00 00       	mov    $0x0,%esi
  800fc4:	b8 0c 00 00 00       	mov    $0xc,%eax
  800fc9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fcc:	8b 55 08             	mov    0x8(%ebp),%edx
  800fcf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fd2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fd5:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800fd7:	5b                   	pop    %ebx
  800fd8:	5e                   	pop    %esi
  800fd9:	5f                   	pop    %edi
  800fda:	5d                   	pop    %ebp
  800fdb:	c3                   	ret    

00800fdc <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800fdc:	55                   	push   %ebp
  800fdd:	89 e5                	mov    %esp,%ebp
  800fdf:	57                   	push   %edi
  800fe0:	56                   	push   %esi
  800fe1:	53                   	push   %ebx
  800fe2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fe5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fea:	b8 0d 00 00 00       	mov    $0xd,%eax
  800fef:	8b 55 08             	mov    0x8(%ebp),%edx
  800ff2:	89 cb                	mov    %ecx,%ebx
  800ff4:	89 cf                	mov    %ecx,%edi
  800ff6:	89 ce                	mov    %ecx,%esi
  800ff8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ffa:	85 c0                	test   %eax,%eax
  800ffc:	7e 17                	jle    801015 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ffe:	83 ec 0c             	sub    $0xc,%esp
  801001:	50                   	push   %eax
  801002:	6a 0d                	push   $0xd
  801004:	68 df 26 80 00       	push   $0x8026df
  801009:	6a 23                	push   $0x23
  80100b:	68 fc 26 80 00       	push   $0x8026fc
  801010:	e8 0f f3 ff ff       	call   800324 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801015:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801018:	5b                   	pop    %ebx
  801019:	5e                   	pop    %esi
  80101a:	5f                   	pop    %edi
  80101b:	5d                   	pop    %ebp
  80101c:	c3                   	ret    

0080101d <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  80101d:	55                   	push   %ebp
  80101e:	89 e5                	mov    %esp,%ebp
  801020:	8b 55 08             	mov    0x8(%ebp),%edx
  801023:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801026:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  801029:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  80102b:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  80102e:	83 3a 01             	cmpl   $0x1,(%edx)
  801031:	7e 09                	jle    80103c <argstart+0x1f>
  801033:	ba 88 23 80 00       	mov    $0x802388,%edx
  801038:	85 c9                	test   %ecx,%ecx
  80103a:	75 05                	jne    801041 <argstart+0x24>
  80103c:	ba 00 00 00 00       	mov    $0x0,%edx
  801041:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  801044:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  80104b:	5d                   	pop    %ebp
  80104c:	c3                   	ret    

0080104d <argnext>:

int
argnext(struct Argstate *args)
{
  80104d:	55                   	push   %ebp
  80104e:	89 e5                	mov    %esp,%ebp
  801050:	53                   	push   %ebx
  801051:	83 ec 04             	sub    $0x4,%esp
  801054:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  801057:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  80105e:	8b 43 08             	mov    0x8(%ebx),%eax
  801061:	85 c0                	test   %eax,%eax
  801063:	74 6f                	je     8010d4 <argnext+0x87>
		return -1;

	if (!*args->curarg) {
  801065:	80 38 00             	cmpb   $0x0,(%eax)
  801068:	75 4e                	jne    8010b8 <argnext+0x6b>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  80106a:	8b 0b                	mov    (%ebx),%ecx
  80106c:	83 39 01             	cmpl   $0x1,(%ecx)
  80106f:	74 55                	je     8010c6 <argnext+0x79>
		    || args->argv[1][0] != '-'
  801071:	8b 53 04             	mov    0x4(%ebx),%edx
  801074:	8b 42 04             	mov    0x4(%edx),%eax
  801077:	80 38 2d             	cmpb   $0x2d,(%eax)
  80107a:	75 4a                	jne    8010c6 <argnext+0x79>
		    || args->argv[1][1] == '\0')
  80107c:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801080:	74 44                	je     8010c6 <argnext+0x79>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  801082:	83 c0 01             	add    $0x1,%eax
  801085:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801088:	83 ec 04             	sub    $0x4,%esp
  80108b:	8b 01                	mov    (%ecx),%eax
  80108d:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801094:	50                   	push   %eax
  801095:	8d 42 08             	lea    0x8(%edx),%eax
  801098:	50                   	push   %eax
  801099:	83 c2 04             	add    $0x4,%edx
  80109c:	52                   	push   %edx
  80109d:	e8 19 fb ff ff       	call   800bbb <memmove>
		(*args->argc)--;
  8010a2:	8b 03                	mov    (%ebx),%eax
  8010a4:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  8010a7:	8b 43 08             	mov    0x8(%ebx),%eax
  8010aa:	83 c4 10             	add    $0x10,%esp
  8010ad:	80 38 2d             	cmpb   $0x2d,(%eax)
  8010b0:	75 06                	jne    8010b8 <argnext+0x6b>
  8010b2:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  8010b6:	74 0e                	je     8010c6 <argnext+0x79>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  8010b8:	8b 53 08             	mov    0x8(%ebx),%edx
  8010bb:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  8010be:	83 c2 01             	add    $0x1,%edx
  8010c1:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  8010c4:	eb 13                	jmp    8010d9 <argnext+0x8c>

    endofargs:
	args->curarg = 0;
  8010c6:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  8010cd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8010d2:	eb 05                	jmp    8010d9 <argnext+0x8c>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  8010d4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  8010d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010dc:	c9                   	leave  
  8010dd:	c3                   	ret    

008010de <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  8010de:	55                   	push   %ebp
  8010df:	89 e5                	mov    %esp,%ebp
  8010e1:	53                   	push   %ebx
  8010e2:	83 ec 04             	sub    $0x4,%esp
  8010e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  8010e8:	8b 43 08             	mov    0x8(%ebx),%eax
  8010eb:	85 c0                	test   %eax,%eax
  8010ed:	74 58                	je     801147 <argnextvalue+0x69>
		return 0;
	if (*args->curarg) {
  8010ef:	80 38 00             	cmpb   $0x0,(%eax)
  8010f2:	74 0c                	je     801100 <argnextvalue+0x22>
		args->argvalue = args->curarg;
  8010f4:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  8010f7:	c7 43 08 88 23 80 00 	movl   $0x802388,0x8(%ebx)
  8010fe:	eb 42                	jmp    801142 <argnextvalue+0x64>
	} else if (*args->argc > 1) {
  801100:	8b 13                	mov    (%ebx),%edx
  801102:	83 3a 01             	cmpl   $0x1,(%edx)
  801105:	7e 2d                	jle    801134 <argnextvalue+0x56>
		args->argvalue = args->argv[1];
  801107:	8b 43 04             	mov    0x4(%ebx),%eax
  80110a:	8b 48 04             	mov    0x4(%eax),%ecx
  80110d:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801110:	83 ec 04             	sub    $0x4,%esp
  801113:	8b 12                	mov    (%edx),%edx
  801115:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  80111c:	52                   	push   %edx
  80111d:	8d 50 08             	lea    0x8(%eax),%edx
  801120:	52                   	push   %edx
  801121:	83 c0 04             	add    $0x4,%eax
  801124:	50                   	push   %eax
  801125:	e8 91 fa ff ff       	call   800bbb <memmove>
		(*args->argc)--;
  80112a:	8b 03                	mov    (%ebx),%eax
  80112c:	83 28 01             	subl   $0x1,(%eax)
  80112f:	83 c4 10             	add    $0x10,%esp
  801132:	eb 0e                	jmp    801142 <argnextvalue+0x64>
	} else {
		args->argvalue = 0;
  801134:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  80113b:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  801142:	8b 43 0c             	mov    0xc(%ebx),%eax
  801145:	eb 05                	jmp    80114c <argnextvalue+0x6e>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  801147:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  80114c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80114f:	c9                   	leave  
  801150:	c3                   	ret    

00801151 <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  801151:	55                   	push   %ebp
  801152:	89 e5                	mov    %esp,%ebp
  801154:	83 ec 08             	sub    $0x8,%esp
  801157:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  80115a:	8b 51 0c             	mov    0xc(%ecx),%edx
  80115d:	89 d0                	mov    %edx,%eax
  80115f:	85 d2                	test   %edx,%edx
  801161:	75 0c                	jne    80116f <argvalue+0x1e>
  801163:	83 ec 0c             	sub    $0xc,%esp
  801166:	51                   	push   %ecx
  801167:	e8 72 ff ff ff       	call   8010de <argnextvalue>
  80116c:	83 c4 10             	add    $0x10,%esp
}
  80116f:	c9                   	leave  
  801170:	c3                   	ret    

00801171 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801171:	55                   	push   %ebp
  801172:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801174:	8b 45 08             	mov    0x8(%ebp),%eax
  801177:	05 00 00 00 30       	add    $0x30000000,%eax
  80117c:	c1 e8 0c             	shr    $0xc,%eax
}
  80117f:	5d                   	pop    %ebp
  801180:	c3                   	ret    

00801181 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801181:	55                   	push   %ebp
  801182:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801184:	8b 45 08             	mov    0x8(%ebp),%eax
  801187:	05 00 00 00 30       	add    $0x30000000,%eax
  80118c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801191:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801196:	5d                   	pop    %ebp
  801197:	c3                   	ret    

00801198 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801198:	55                   	push   %ebp
  801199:	89 e5                	mov    %esp,%ebp
  80119b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80119e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011a3:	89 c2                	mov    %eax,%edx
  8011a5:	c1 ea 16             	shr    $0x16,%edx
  8011a8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011af:	f6 c2 01             	test   $0x1,%dl
  8011b2:	74 11                	je     8011c5 <fd_alloc+0x2d>
  8011b4:	89 c2                	mov    %eax,%edx
  8011b6:	c1 ea 0c             	shr    $0xc,%edx
  8011b9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011c0:	f6 c2 01             	test   $0x1,%dl
  8011c3:	75 09                	jne    8011ce <fd_alloc+0x36>
			*fd_store = fd;
  8011c5:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8011cc:	eb 17                	jmp    8011e5 <fd_alloc+0x4d>
  8011ce:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011d3:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011d8:	75 c9                	jne    8011a3 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011da:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011e0:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011e5:	5d                   	pop    %ebp
  8011e6:	c3                   	ret    

008011e7 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011e7:	55                   	push   %ebp
  8011e8:	89 e5                	mov    %esp,%ebp
  8011ea:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011ed:	83 f8 1f             	cmp    $0x1f,%eax
  8011f0:	77 36                	ja     801228 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011f2:	c1 e0 0c             	shl    $0xc,%eax
  8011f5:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011fa:	89 c2                	mov    %eax,%edx
  8011fc:	c1 ea 16             	shr    $0x16,%edx
  8011ff:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801206:	f6 c2 01             	test   $0x1,%dl
  801209:	74 24                	je     80122f <fd_lookup+0x48>
  80120b:	89 c2                	mov    %eax,%edx
  80120d:	c1 ea 0c             	shr    $0xc,%edx
  801210:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801217:	f6 c2 01             	test   $0x1,%dl
  80121a:	74 1a                	je     801236 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80121c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80121f:	89 02                	mov    %eax,(%edx)
	return 0;
  801221:	b8 00 00 00 00       	mov    $0x0,%eax
  801226:	eb 13                	jmp    80123b <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801228:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80122d:	eb 0c                	jmp    80123b <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80122f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801234:	eb 05                	jmp    80123b <fd_lookup+0x54>
  801236:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80123b:	5d                   	pop    %ebp
  80123c:	c3                   	ret    

0080123d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80123d:	55                   	push   %ebp
  80123e:	89 e5                	mov    %esp,%ebp
  801240:	83 ec 08             	sub    $0x8,%esp
  801243:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801246:	ba 8c 27 80 00       	mov    $0x80278c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80124b:	eb 13                	jmp    801260 <dev_lookup+0x23>
  80124d:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801250:	39 08                	cmp    %ecx,(%eax)
  801252:	75 0c                	jne    801260 <dev_lookup+0x23>
			*dev = devtab[i];
  801254:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801257:	89 01                	mov    %eax,(%ecx)
			return 0;
  801259:	b8 00 00 00 00       	mov    $0x0,%eax
  80125e:	eb 2e                	jmp    80128e <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801260:	8b 02                	mov    (%edx),%eax
  801262:	85 c0                	test   %eax,%eax
  801264:	75 e7                	jne    80124d <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801266:	a1 20 44 80 00       	mov    0x804420,%eax
  80126b:	8b 40 48             	mov    0x48(%eax),%eax
  80126e:	83 ec 04             	sub    $0x4,%esp
  801271:	51                   	push   %ecx
  801272:	50                   	push   %eax
  801273:	68 0c 27 80 00       	push   $0x80270c
  801278:	e8 80 f1 ff ff       	call   8003fd <cprintf>
	*dev = 0;
  80127d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801280:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801286:	83 c4 10             	add    $0x10,%esp
  801289:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80128e:	c9                   	leave  
  80128f:	c3                   	ret    

00801290 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801290:	55                   	push   %ebp
  801291:	89 e5                	mov    %esp,%ebp
  801293:	56                   	push   %esi
  801294:	53                   	push   %ebx
  801295:	83 ec 10             	sub    $0x10,%esp
  801298:	8b 75 08             	mov    0x8(%ebp),%esi
  80129b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80129e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012a1:	50                   	push   %eax
  8012a2:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012a8:	c1 e8 0c             	shr    $0xc,%eax
  8012ab:	50                   	push   %eax
  8012ac:	e8 36 ff ff ff       	call   8011e7 <fd_lookup>
  8012b1:	83 c4 08             	add    $0x8,%esp
  8012b4:	85 c0                	test   %eax,%eax
  8012b6:	78 05                	js     8012bd <fd_close+0x2d>
	    || fd != fd2)
  8012b8:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012bb:	74 0c                	je     8012c9 <fd_close+0x39>
		return (must_exist ? r : 0);
  8012bd:	84 db                	test   %bl,%bl
  8012bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8012c4:	0f 44 c2             	cmove  %edx,%eax
  8012c7:	eb 41                	jmp    80130a <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012c9:	83 ec 08             	sub    $0x8,%esp
  8012cc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012cf:	50                   	push   %eax
  8012d0:	ff 36                	pushl  (%esi)
  8012d2:	e8 66 ff ff ff       	call   80123d <dev_lookup>
  8012d7:	89 c3                	mov    %eax,%ebx
  8012d9:	83 c4 10             	add    $0x10,%esp
  8012dc:	85 c0                	test   %eax,%eax
  8012de:	78 1a                	js     8012fa <fd_close+0x6a>
		if (dev->dev_close)
  8012e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012e3:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8012e6:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8012eb:	85 c0                	test   %eax,%eax
  8012ed:	74 0b                	je     8012fa <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012ef:	83 ec 0c             	sub    $0xc,%esp
  8012f2:	56                   	push   %esi
  8012f3:	ff d0                	call   *%eax
  8012f5:	89 c3                	mov    %eax,%ebx
  8012f7:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012fa:	83 ec 08             	sub    $0x8,%esp
  8012fd:	56                   	push   %esi
  8012fe:	6a 00                	push   $0x0
  801300:	e8 ac fb ff ff       	call   800eb1 <sys_page_unmap>
	return r;
  801305:	83 c4 10             	add    $0x10,%esp
  801308:	89 d8                	mov    %ebx,%eax
}
  80130a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80130d:	5b                   	pop    %ebx
  80130e:	5e                   	pop    %esi
  80130f:	5d                   	pop    %ebp
  801310:	c3                   	ret    

00801311 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801311:	55                   	push   %ebp
  801312:	89 e5                	mov    %esp,%ebp
  801314:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801317:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80131a:	50                   	push   %eax
  80131b:	ff 75 08             	pushl  0x8(%ebp)
  80131e:	e8 c4 fe ff ff       	call   8011e7 <fd_lookup>
  801323:	83 c4 08             	add    $0x8,%esp
  801326:	85 c0                	test   %eax,%eax
  801328:	78 10                	js     80133a <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80132a:	83 ec 08             	sub    $0x8,%esp
  80132d:	6a 01                	push   $0x1
  80132f:	ff 75 f4             	pushl  -0xc(%ebp)
  801332:	e8 59 ff ff ff       	call   801290 <fd_close>
  801337:	83 c4 10             	add    $0x10,%esp
}
  80133a:	c9                   	leave  
  80133b:	c3                   	ret    

0080133c <close_all>:

void
close_all(void)
{
  80133c:	55                   	push   %ebp
  80133d:	89 e5                	mov    %esp,%ebp
  80133f:	53                   	push   %ebx
  801340:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801343:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801348:	83 ec 0c             	sub    $0xc,%esp
  80134b:	53                   	push   %ebx
  80134c:	e8 c0 ff ff ff       	call   801311 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801351:	83 c3 01             	add    $0x1,%ebx
  801354:	83 c4 10             	add    $0x10,%esp
  801357:	83 fb 20             	cmp    $0x20,%ebx
  80135a:	75 ec                	jne    801348 <close_all+0xc>
		close(i);
}
  80135c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80135f:	c9                   	leave  
  801360:	c3                   	ret    

00801361 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801361:	55                   	push   %ebp
  801362:	89 e5                	mov    %esp,%ebp
  801364:	57                   	push   %edi
  801365:	56                   	push   %esi
  801366:	53                   	push   %ebx
  801367:	83 ec 2c             	sub    $0x2c,%esp
  80136a:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80136d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801370:	50                   	push   %eax
  801371:	ff 75 08             	pushl  0x8(%ebp)
  801374:	e8 6e fe ff ff       	call   8011e7 <fd_lookup>
  801379:	83 c4 08             	add    $0x8,%esp
  80137c:	85 c0                	test   %eax,%eax
  80137e:	0f 88 c1 00 00 00    	js     801445 <dup+0xe4>
		return r;
	close(newfdnum);
  801384:	83 ec 0c             	sub    $0xc,%esp
  801387:	56                   	push   %esi
  801388:	e8 84 ff ff ff       	call   801311 <close>

	newfd = INDEX2FD(newfdnum);
  80138d:	89 f3                	mov    %esi,%ebx
  80138f:	c1 e3 0c             	shl    $0xc,%ebx
  801392:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801398:	83 c4 04             	add    $0x4,%esp
  80139b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80139e:	e8 de fd ff ff       	call   801181 <fd2data>
  8013a3:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8013a5:	89 1c 24             	mov    %ebx,(%esp)
  8013a8:	e8 d4 fd ff ff       	call   801181 <fd2data>
  8013ad:	83 c4 10             	add    $0x10,%esp
  8013b0:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013b3:	89 f8                	mov    %edi,%eax
  8013b5:	c1 e8 16             	shr    $0x16,%eax
  8013b8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013bf:	a8 01                	test   $0x1,%al
  8013c1:	74 37                	je     8013fa <dup+0x99>
  8013c3:	89 f8                	mov    %edi,%eax
  8013c5:	c1 e8 0c             	shr    $0xc,%eax
  8013c8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013cf:	f6 c2 01             	test   $0x1,%dl
  8013d2:	74 26                	je     8013fa <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013d4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013db:	83 ec 0c             	sub    $0xc,%esp
  8013de:	25 07 0e 00 00       	and    $0xe07,%eax
  8013e3:	50                   	push   %eax
  8013e4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013e7:	6a 00                	push   $0x0
  8013e9:	57                   	push   %edi
  8013ea:	6a 00                	push   $0x0
  8013ec:	e8 7e fa ff ff       	call   800e6f <sys_page_map>
  8013f1:	89 c7                	mov    %eax,%edi
  8013f3:	83 c4 20             	add    $0x20,%esp
  8013f6:	85 c0                	test   %eax,%eax
  8013f8:	78 2e                	js     801428 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013fa:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8013fd:	89 d0                	mov    %edx,%eax
  8013ff:	c1 e8 0c             	shr    $0xc,%eax
  801402:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801409:	83 ec 0c             	sub    $0xc,%esp
  80140c:	25 07 0e 00 00       	and    $0xe07,%eax
  801411:	50                   	push   %eax
  801412:	53                   	push   %ebx
  801413:	6a 00                	push   $0x0
  801415:	52                   	push   %edx
  801416:	6a 00                	push   $0x0
  801418:	e8 52 fa ff ff       	call   800e6f <sys_page_map>
  80141d:	89 c7                	mov    %eax,%edi
  80141f:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801422:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801424:	85 ff                	test   %edi,%edi
  801426:	79 1d                	jns    801445 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801428:	83 ec 08             	sub    $0x8,%esp
  80142b:	53                   	push   %ebx
  80142c:	6a 00                	push   $0x0
  80142e:	e8 7e fa ff ff       	call   800eb1 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801433:	83 c4 08             	add    $0x8,%esp
  801436:	ff 75 d4             	pushl  -0x2c(%ebp)
  801439:	6a 00                	push   $0x0
  80143b:	e8 71 fa ff ff       	call   800eb1 <sys_page_unmap>
	return r;
  801440:	83 c4 10             	add    $0x10,%esp
  801443:	89 f8                	mov    %edi,%eax
}
  801445:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801448:	5b                   	pop    %ebx
  801449:	5e                   	pop    %esi
  80144a:	5f                   	pop    %edi
  80144b:	5d                   	pop    %ebp
  80144c:	c3                   	ret    

0080144d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80144d:	55                   	push   %ebp
  80144e:	89 e5                	mov    %esp,%ebp
  801450:	53                   	push   %ebx
  801451:	83 ec 14             	sub    $0x14,%esp
  801454:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801457:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80145a:	50                   	push   %eax
  80145b:	53                   	push   %ebx
  80145c:	e8 86 fd ff ff       	call   8011e7 <fd_lookup>
  801461:	83 c4 08             	add    $0x8,%esp
  801464:	89 c2                	mov    %eax,%edx
  801466:	85 c0                	test   %eax,%eax
  801468:	78 6d                	js     8014d7 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80146a:	83 ec 08             	sub    $0x8,%esp
  80146d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801470:	50                   	push   %eax
  801471:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801474:	ff 30                	pushl  (%eax)
  801476:	e8 c2 fd ff ff       	call   80123d <dev_lookup>
  80147b:	83 c4 10             	add    $0x10,%esp
  80147e:	85 c0                	test   %eax,%eax
  801480:	78 4c                	js     8014ce <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801482:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801485:	8b 42 08             	mov    0x8(%edx),%eax
  801488:	83 e0 03             	and    $0x3,%eax
  80148b:	83 f8 01             	cmp    $0x1,%eax
  80148e:	75 21                	jne    8014b1 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801490:	a1 20 44 80 00       	mov    0x804420,%eax
  801495:	8b 40 48             	mov    0x48(%eax),%eax
  801498:	83 ec 04             	sub    $0x4,%esp
  80149b:	53                   	push   %ebx
  80149c:	50                   	push   %eax
  80149d:	68 50 27 80 00       	push   $0x802750
  8014a2:	e8 56 ef ff ff       	call   8003fd <cprintf>
		return -E_INVAL;
  8014a7:	83 c4 10             	add    $0x10,%esp
  8014aa:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014af:	eb 26                	jmp    8014d7 <read+0x8a>
	}
	if (!dev->dev_read)
  8014b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014b4:	8b 40 08             	mov    0x8(%eax),%eax
  8014b7:	85 c0                	test   %eax,%eax
  8014b9:	74 17                	je     8014d2 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014bb:	83 ec 04             	sub    $0x4,%esp
  8014be:	ff 75 10             	pushl  0x10(%ebp)
  8014c1:	ff 75 0c             	pushl  0xc(%ebp)
  8014c4:	52                   	push   %edx
  8014c5:	ff d0                	call   *%eax
  8014c7:	89 c2                	mov    %eax,%edx
  8014c9:	83 c4 10             	add    $0x10,%esp
  8014cc:	eb 09                	jmp    8014d7 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014ce:	89 c2                	mov    %eax,%edx
  8014d0:	eb 05                	jmp    8014d7 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014d2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8014d7:	89 d0                	mov    %edx,%eax
  8014d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014dc:	c9                   	leave  
  8014dd:	c3                   	ret    

008014de <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014de:	55                   	push   %ebp
  8014df:	89 e5                	mov    %esp,%ebp
  8014e1:	57                   	push   %edi
  8014e2:	56                   	push   %esi
  8014e3:	53                   	push   %ebx
  8014e4:	83 ec 0c             	sub    $0xc,%esp
  8014e7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014ea:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014ed:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014f2:	eb 21                	jmp    801515 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014f4:	83 ec 04             	sub    $0x4,%esp
  8014f7:	89 f0                	mov    %esi,%eax
  8014f9:	29 d8                	sub    %ebx,%eax
  8014fb:	50                   	push   %eax
  8014fc:	89 d8                	mov    %ebx,%eax
  8014fe:	03 45 0c             	add    0xc(%ebp),%eax
  801501:	50                   	push   %eax
  801502:	57                   	push   %edi
  801503:	e8 45 ff ff ff       	call   80144d <read>
		if (m < 0)
  801508:	83 c4 10             	add    $0x10,%esp
  80150b:	85 c0                	test   %eax,%eax
  80150d:	78 10                	js     80151f <readn+0x41>
			return m;
		if (m == 0)
  80150f:	85 c0                	test   %eax,%eax
  801511:	74 0a                	je     80151d <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801513:	01 c3                	add    %eax,%ebx
  801515:	39 f3                	cmp    %esi,%ebx
  801517:	72 db                	jb     8014f4 <readn+0x16>
  801519:	89 d8                	mov    %ebx,%eax
  80151b:	eb 02                	jmp    80151f <readn+0x41>
  80151d:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80151f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801522:	5b                   	pop    %ebx
  801523:	5e                   	pop    %esi
  801524:	5f                   	pop    %edi
  801525:	5d                   	pop    %ebp
  801526:	c3                   	ret    

00801527 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801527:	55                   	push   %ebp
  801528:	89 e5                	mov    %esp,%ebp
  80152a:	53                   	push   %ebx
  80152b:	83 ec 14             	sub    $0x14,%esp
  80152e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801531:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801534:	50                   	push   %eax
  801535:	53                   	push   %ebx
  801536:	e8 ac fc ff ff       	call   8011e7 <fd_lookup>
  80153b:	83 c4 08             	add    $0x8,%esp
  80153e:	89 c2                	mov    %eax,%edx
  801540:	85 c0                	test   %eax,%eax
  801542:	78 68                	js     8015ac <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801544:	83 ec 08             	sub    $0x8,%esp
  801547:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80154a:	50                   	push   %eax
  80154b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80154e:	ff 30                	pushl  (%eax)
  801550:	e8 e8 fc ff ff       	call   80123d <dev_lookup>
  801555:	83 c4 10             	add    $0x10,%esp
  801558:	85 c0                	test   %eax,%eax
  80155a:	78 47                	js     8015a3 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80155c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80155f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801563:	75 21                	jne    801586 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801565:	a1 20 44 80 00       	mov    0x804420,%eax
  80156a:	8b 40 48             	mov    0x48(%eax),%eax
  80156d:	83 ec 04             	sub    $0x4,%esp
  801570:	53                   	push   %ebx
  801571:	50                   	push   %eax
  801572:	68 6c 27 80 00       	push   $0x80276c
  801577:	e8 81 ee ff ff       	call   8003fd <cprintf>
		return -E_INVAL;
  80157c:	83 c4 10             	add    $0x10,%esp
  80157f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801584:	eb 26                	jmp    8015ac <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801586:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801589:	8b 52 0c             	mov    0xc(%edx),%edx
  80158c:	85 d2                	test   %edx,%edx
  80158e:	74 17                	je     8015a7 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801590:	83 ec 04             	sub    $0x4,%esp
  801593:	ff 75 10             	pushl  0x10(%ebp)
  801596:	ff 75 0c             	pushl  0xc(%ebp)
  801599:	50                   	push   %eax
  80159a:	ff d2                	call   *%edx
  80159c:	89 c2                	mov    %eax,%edx
  80159e:	83 c4 10             	add    $0x10,%esp
  8015a1:	eb 09                	jmp    8015ac <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015a3:	89 c2                	mov    %eax,%edx
  8015a5:	eb 05                	jmp    8015ac <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015a7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8015ac:	89 d0                	mov    %edx,%eax
  8015ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015b1:	c9                   	leave  
  8015b2:	c3                   	ret    

008015b3 <seek>:

int
seek(int fdnum, off_t offset)
{
  8015b3:	55                   	push   %ebp
  8015b4:	89 e5                	mov    %esp,%ebp
  8015b6:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015b9:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015bc:	50                   	push   %eax
  8015bd:	ff 75 08             	pushl  0x8(%ebp)
  8015c0:	e8 22 fc ff ff       	call   8011e7 <fd_lookup>
  8015c5:	83 c4 08             	add    $0x8,%esp
  8015c8:	85 c0                	test   %eax,%eax
  8015ca:	78 0e                	js     8015da <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015cc:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015cf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015d2:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015d5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015da:	c9                   	leave  
  8015db:	c3                   	ret    

008015dc <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015dc:	55                   	push   %ebp
  8015dd:	89 e5                	mov    %esp,%ebp
  8015df:	53                   	push   %ebx
  8015e0:	83 ec 14             	sub    $0x14,%esp
  8015e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015e6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015e9:	50                   	push   %eax
  8015ea:	53                   	push   %ebx
  8015eb:	e8 f7 fb ff ff       	call   8011e7 <fd_lookup>
  8015f0:	83 c4 08             	add    $0x8,%esp
  8015f3:	89 c2                	mov    %eax,%edx
  8015f5:	85 c0                	test   %eax,%eax
  8015f7:	78 65                	js     80165e <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015f9:	83 ec 08             	sub    $0x8,%esp
  8015fc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ff:	50                   	push   %eax
  801600:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801603:	ff 30                	pushl  (%eax)
  801605:	e8 33 fc ff ff       	call   80123d <dev_lookup>
  80160a:	83 c4 10             	add    $0x10,%esp
  80160d:	85 c0                	test   %eax,%eax
  80160f:	78 44                	js     801655 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801611:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801614:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801618:	75 21                	jne    80163b <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80161a:	a1 20 44 80 00       	mov    0x804420,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80161f:	8b 40 48             	mov    0x48(%eax),%eax
  801622:	83 ec 04             	sub    $0x4,%esp
  801625:	53                   	push   %ebx
  801626:	50                   	push   %eax
  801627:	68 2c 27 80 00       	push   $0x80272c
  80162c:	e8 cc ed ff ff       	call   8003fd <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801631:	83 c4 10             	add    $0x10,%esp
  801634:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801639:	eb 23                	jmp    80165e <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80163b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80163e:	8b 52 18             	mov    0x18(%edx),%edx
  801641:	85 d2                	test   %edx,%edx
  801643:	74 14                	je     801659 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801645:	83 ec 08             	sub    $0x8,%esp
  801648:	ff 75 0c             	pushl  0xc(%ebp)
  80164b:	50                   	push   %eax
  80164c:	ff d2                	call   *%edx
  80164e:	89 c2                	mov    %eax,%edx
  801650:	83 c4 10             	add    $0x10,%esp
  801653:	eb 09                	jmp    80165e <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801655:	89 c2                	mov    %eax,%edx
  801657:	eb 05                	jmp    80165e <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801659:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80165e:	89 d0                	mov    %edx,%eax
  801660:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801663:	c9                   	leave  
  801664:	c3                   	ret    

00801665 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801665:	55                   	push   %ebp
  801666:	89 e5                	mov    %esp,%ebp
  801668:	53                   	push   %ebx
  801669:	83 ec 14             	sub    $0x14,%esp
  80166c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80166f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801672:	50                   	push   %eax
  801673:	ff 75 08             	pushl  0x8(%ebp)
  801676:	e8 6c fb ff ff       	call   8011e7 <fd_lookup>
  80167b:	83 c4 08             	add    $0x8,%esp
  80167e:	89 c2                	mov    %eax,%edx
  801680:	85 c0                	test   %eax,%eax
  801682:	78 58                	js     8016dc <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801684:	83 ec 08             	sub    $0x8,%esp
  801687:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80168a:	50                   	push   %eax
  80168b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80168e:	ff 30                	pushl  (%eax)
  801690:	e8 a8 fb ff ff       	call   80123d <dev_lookup>
  801695:	83 c4 10             	add    $0x10,%esp
  801698:	85 c0                	test   %eax,%eax
  80169a:	78 37                	js     8016d3 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80169c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80169f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016a3:	74 32                	je     8016d7 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016a5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016a8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016af:	00 00 00 
	stat->st_isdir = 0;
  8016b2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016b9:	00 00 00 
	stat->st_dev = dev;
  8016bc:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016c2:	83 ec 08             	sub    $0x8,%esp
  8016c5:	53                   	push   %ebx
  8016c6:	ff 75 f0             	pushl  -0x10(%ebp)
  8016c9:	ff 50 14             	call   *0x14(%eax)
  8016cc:	89 c2                	mov    %eax,%edx
  8016ce:	83 c4 10             	add    $0x10,%esp
  8016d1:	eb 09                	jmp    8016dc <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016d3:	89 c2                	mov    %eax,%edx
  8016d5:	eb 05                	jmp    8016dc <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016d7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016dc:	89 d0                	mov    %edx,%eax
  8016de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016e1:	c9                   	leave  
  8016e2:	c3                   	ret    

008016e3 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016e3:	55                   	push   %ebp
  8016e4:	89 e5                	mov    %esp,%ebp
  8016e6:	56                   	push   %esi
  8016e7:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016e8:	83 ec 08             	sub    $0x8,%esp
  8016eb:	6a 00                	push   $0x0
  8016ed:	ff 75 08             	pushl  0x8(%ebp)
  8016f0:	e8 b7 01 00 00       	call   8018ac <open>
  8016f5:	89 c3                	mov    %eax,%ebx
  8016f7:	83 c4 10             	add    $0x10,%esp
  8016fa:	85 c0                	test   %eax,%eax
  8016fc:	78 1b                	js     801719 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016fe:	83 ec 08             	sub    $0x8,%esp
  801701:	ff 75 0c             	pushl  0xc(%ebp)
  801704:	50                   	push   %eax
  801705:	e8 5b ff ff ff       	call   801665 <fstat>
  80170a:	89 c6                	mov    %eax,%esi
	close(fd);
  80170c:	89 1c 24             	mov    %ebx,(%esp)
  80170f:	e8 fd fb ff ff       	call   801311 <close>
	return r;
  801714:	83 c4 10             	add    $0x10,%esp
  801717:	89 f0                	mov    %esi,%eax
}
  801719:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80171c:	5b                   	pop    %ebx
  80171d:	5e                   	pop    %esi
  80171e:	5d                   	pop    %ebp
  80171f:	c3                   	ret    

00801720 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801720:	55                   	push   %ebp
  801721:	89 e5                	mov    %esp,%ebp
  801723:	56                   	push   %esi
  801724:	53                   	push   %ebx
  801725:	89 c6                	mov    %eax,%esi
  801727:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801729:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801730:	75 12                	jne    801744 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801732:	83 ec 0c             	sub    $0xc,%esp
  801735:	6a 01                	push   $0x1
  801737:	e8 cc 08 00 00       	call   802008 <ipc_find_env>
  80173c:	a3 00 40 80 00       	mov    %eax,0x804000
  801741:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801744:	6a 07                	push   $0x7
  801746:	68 00 50 80 00       	push   $0x805000
  80174b:	56                   	push   %esi
  80174c:	ff 35 00 40 80 00    	pushl  0x804000
  801752:	e8 5d 08 00 00       	call   801fb4 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801757:	83 c4 0c             	add    $0xc,%esp
  80175a:	6a 00                	push   $0x0
  80175c:	53                   	push   %ebx
  80175d:	6a 00                	push   $0x0
  80175f:	e8 db 07 00 00       	call   801f3f <ipc_recv>
}
  801764:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801767:	5b                   	pop    %ebx
  801768:	5e                   	pop    %esi
  801769:	5d                   	pop    %ebp
  80176a:	c3                   	ret    

0080176b <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80176b:	55                   	push   %ebp
  80176c:	89 e5                	mov    %esp,%ebp
  80176e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801771:	8b 45 08             	mov    0x8(%ebp),%eax
  801774:	8b 40 0c             	mov    0xc(%eax),%eax
  801777:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80177c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80177f:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801784:	ba 00 00 00 00       	mov    $0x0,%edx
  801789:	b8 02 00 00 00       	mov    $0x2,%eax
  80178e:	e8 8d ff ff ff       	call   801720 <fsipc>
}
  801793:	c9                   	leave  
  801794:	c3                   	ret    

00801795 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801795:	55                   	push   %ebp
  801796:	89 e5                	mov    %esp,%ebp
  801798:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80179b:	8b 45 08             	mov    0x8(%ebp),%eax
  80179e:	8b 40 0c             	mov    0xc(%eax),%eax
  8017a1:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017a6:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ab:	b8 06 00 00 00       	mov    $0x6,%eax
  8017b0:	e8 6b ff ff ff       	call   801720 <fsipc>
}
  8017b5:	c9                   	leave  
  8017b6:	c3                   	ret    

008017b7 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017b7:	55                   	push   %ebp
  8017b8:	89 e5                	mov    %esp,%ebp
  8017ba:	53                   	push   %ebx
  8017bb:	83 ec 04             	sub    $0x4,%esp
  8017be:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c4:	8b 40 0c             	mov    0xc(%eax),%eax
  8017c7:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8017d1:	b8 05 00 00 00       	mov    $0x5,%eax
  8017d6:	e8 45 ff ff ff       	call   801720 <fsipc>
  8017db:	85 c0                	test   %eax,%eax
  8017dd:	78 2c                	js     80180b <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017df:	83 ec 08             	sub    $0x8,%esp
  8017e2:	68 00 50 80 00       	push   $0x805000
  8017e7:	53                   	push   %ebx
  8017e8:	e8 3c f2 ff ff       	call   800a29 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017ed:	a1 80 50 80 00       	mov    0x805080,%eax
  8017f2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017f8:	a1 84 50 80 00       	mov    0x805084,%eax
  8017fd:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801803:	83 c4 10             	add    $0x10,%esp
  801806:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80180b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80180e:	c9                   	leave  
  80180f:	c3                   	ret    

00801810 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801810:	55                   	push   %ebp
  801811:	89 e5                	mov    %esp,%ebp
  801813:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801816:	68 9c 27 80 00       	push   $0x80279c
  80181b:	68 90 00 00 00       	push   $0x90
  801820:	68 ba 27 80 00       	push   $0x8027ba
  801825:	e8 fa ea ff ff       	call   800324 <_panic>

0080182a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80182a:	55                   	push   %ebp
  80182b:	89 e5                	mov    %esp,%ebp
  80182d:	56                   	push   %esi
  80182e:	53                   	push   %ebx
  80182f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801832:	8b 45 08             	mov    0x8(%ebp),%eax
  801835:	8b 40 0c             	mov    0xc(%eax),%eax
  801838:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80183d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801843:	ba 00 00 00 00       	mov    $0x0,%edx
  801848:	b8 03 00 00 00       	mov    $0x3,%eax
  80184d:	e8 ce fe ff ff       	call   801720 <fsipc>
  801852:	89 c3                	mov    %eax,%ebx
  801854:	85 c0                	test   %eax,%eax
  801856:	78 4b                	js     8018a3 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801858:	39 c6                	cmp    %eax,%esi
  80185a:	73 16                	jae    801872 <devfile_read+0x48>
  80185c:	68 c5 27 80 00       	push   $0x8027c5
  801861:	68 cc 27 80 00       	push   $0x8027cc
  801866:	6a 7c                	push   $0x7c
  801868:	68 ba 27 80 00       	push   $0x8027ba
  80186d:	e8 b2 ea ff ff       	call   800324 <_panic>
	assert(r <= PGSIZE);
  801872:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801877:	7e 16                	jle    80188f <devfile_read+0x65>
  801879:	68 e1 27 80 00       	push   $0x8027e1
  80187e:	68 cc 27 80 00       	push   $0x8027cc
  801883:	6a 7d                	push   $0x7d
  801885:	68 ba 27 80 00       	push   $0x8027ba
  80188a:	e8 95 ea ff ff       	call   800324 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80188f:	83 ec 04             	sub    $0x4,%esp
  801892:	50                   	push   %eax
  801893:	68 00 50 80 00       	push   $0x805000
  801898:	ff 75 0c             	pushl  0xc(%ebp)
  80189b:	e8 1b f3 ff ff       	call   800bbb <memmove>
	return r;
  8018a0:	83 c4 10             	add    $0x10,%esp
}
  8018a3:	89 d8                	mov    %ebx,%eax
  8018a5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018a8:	5b                   	pop    %ebx
  8018a9:	5e                   	pop    %esi
  8018aa:	5d                   	pop    %ebp
  8018ab:	c3                   	ret    

008018ac <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018ac:	55                   	push   %ebp
  8018ad:	89 e5                	mov    %esp,%ebp
  8018af:	53                   	push   %ebx
  8018b0:	83 ec 20             	sub    $0x20,%esp
  8018b3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018b6:	53                   	push   %ebx
  8018b7:	e8 34 f1 ff ff       	call   8009f0 <strlen>
  8018bc:	83 c4 10             	add    $0x10,%esp
  8018bf:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018c4:	7f 67                	jg     80192d <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018c6:	83 ec 0c             	sub    $0xc,%esp
  8018c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018cc:	50                   	push   %eax
  8018cd:	e8 c6 f8 ff ff       	call   801198 <fd_alloc>
  8018d2:	83 c4 10             	add    $0x10,%esp
		return r;
  8018d5:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018d7:	85 c0                	test   %eax,%eax
  8018d9:	78 57                	js     801932 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018db:	83 ec 08             	sub    $0x8,%esp
  8018de:	53                   	push   %ebx
  8018df:	68 00 50 80 00       	push   $0x805000
  8018e4:	e8 40 f1 ff ff       	call   800a29 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018e9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018ec:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018f1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018f4:	b8 01 00 00 00       	mov    $0x1,%eax
  8018f9:	e8 22 fe ff ff       	call   801720 <fsipc>
  8018fe:	89 c3                	mov    %eax,%ebx
  801900:	83 c4 10             	add    $0x10,%esp
  801903:	85 c0                	test   %eax,%eax
  801905:	79 14                	jns    80191b <open+0x6f>
		fd_close(fd, 0);
  801907:	83 ec 08             	sub    $0x8,%esp
  80190a:	6a 00                	push   $0x0
  80190c:	ff 75 f4             	pushl  -0xc(%ebp)
  80190f:	e8 7c f9 ff ff       	call   801290 <fd_close>
		return r;
  801914:	83 c4 10             	add    $0x10,%esp
  801917:	89 da                	mov    %ebx,%edx
  801919:	eb 17                	jmp    801932 <open+0x86>
	}

	return fd2num(fd);
  80191b:	83 ec 0c             	sub    $0xc,%esp
  80191e:	ff 75 f4             	pushl  -0xc(%ebp)
  801921:	e8 4b f8 ff ff       	call   801171 <fd2num>
  801926:	89 c2                	mov    %eax,%edx
  801928:	83 c4 10             	add    $0x10,%esp
  80192b:	eb 05                	jmp    801932 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80192d:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801932:	89 d0                	mov    %edx,%eax
  801934:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801937:	c9                   	leave  
  801938:	c3                   	ret    

00801939 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801939:	55                   	push   %ebp
  80193a:	89 e5                	mov    %esp,%ebp
  80193c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80193f:	ba 00 00 00 00       	mov    $0x0,%edx
  801944:	b8 08 00 00 00       	mov    $0x8,%eax
  801949:	e8 d2 fd ff ff       	call   801720 <fsipc>
}
  80194e:	c9                   	leave  
  80194f:	c3                   	ret    

00801950 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  801950:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801954:	7e 37                	jle    80198d <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  801956:	55                   	push   %ebp
  801957:	89 e5                	mov    %esp,%ebp
  801959:	53                   	push   %ebx
  80195a:	83 ec 08             	sub    $0x8,%esp
  80195d:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  80195f:	ff 70 04             	pushl  0x4(%eax)
  801962:	8d 40 10             	lea    0x10(%eax),%eax
  801965:	50                   	push   %eax
  801966:	ff 33                	pushl  (%ebx)
  801968:	e8 ba fb ff ff       	call   801527 <write>
		if (result > 0)
  80196d:	83 c4 10             	add    $0x10,%esp
  801970:	85 c0                	test   %eax,%eax
  801972:	7e 03                	jle    801977 <writebuf+0x27>
			b->result += result;
  801974:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801977:	3b 43 04             	cmp    0x4(%ebx),%eax
  80197a:	74 0d                	je     801989 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  80197c:	85 c0                	test   %eax,%eax
  80197e:	ba 00 00 00 00       	mov    $0x0,%edx
  801983:	0f 4f c2             	cmovg  %edx,%eax
  801986:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801989:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80198c:	c9                   	leave  
  80198d:	f3 c3                	repz ret 

0080198f <putch>:

static void
putch(int ch, void *thunk)
{
  80198f:	55                   	push   %ebp
  801990:	89 e5                	mov    %esp,%ebp
  801992:	53                   	push   %ebx
  801993:	83 ec 04             	sub    $0x4,%esp
  801996:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801999:	8b 53 04             	mov    0x4(%ebx),%edx
  80199c:	8d 42 01             	lea    0x1(%edx),%eax
  80199f:	89 43 04             	mov    %eax,0x4(%ebx)
  8019a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019a5:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  8019a9:	3d 00 01 00 00       	cmp    $0x100,%eax
  8019ae:	75 0e                	jne    8019be <putch+0x2f>
		writebuf(b);
  8019b0:	89 d8                	mov    %ebx,%eax
  8019b2:	e8 99 ff ff ff       	call   801950 <writebuf>
		b->idx = 0;
  8019b7:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8019be:	83 c4 04             	add    $0x4,%esp
  8019c1:	5b                   	pop    %ebx
  8019c2:	5d                   	pop    %ebp
  8019c3:	c3                   	ret    

008019c4 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8019c4:	55                   	push   %ebp
  8019c5:	89 e5                	mov    %esp,%ebp
  8019c7:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  8019cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d0:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8019d6:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8019dd:	00 00 00 
	b.result = 0;
  8019e0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8019e7:	00 00 00 
	b.error = 1;
  8019ea:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8019f1:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8019f4:	ff 75 10             	pushl  0x10(%ebp)
  8019f7:	ff 75 0c             	pushl  0xc(%ebp)
  8019fa:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801a00:	50                   	push   %eax
  801a01:	68 8f 19 80 00       	push   $0x80198f
  801a06:	e8 ef ea ff ff       	call   8004fa <vprintfmt>
	if (b.idx > 0)
  801a0b:	83 c4 10             	add    $0x10,%esp
  801a0e:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801a15:	7e 0b                	jle    801a22 <vfprintf+0x5e>
		writebuf(&b);
  801a17:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801a1d:	e8 2e ff ff ff       	call   801950 <writebuf>

	return (b.result ? b.result : b.error);
  801a22:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801a28:	85 c0                	test   %eax,%eax
  801a2a:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801a31:	c9                   	leave  
  801a32:	c3                   	ret    

00801a33 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801a33:	55                   	push   %ebp
  801a34:	89 e5                	mov    %esp,%ebp
  801a36:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801a39:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801a3c:	50                   	push   %eax
  801a3d:	ff 75 0c             	pushl  0xc(%ebp)
  801a40:	ff 75 08             	pushl  0x8(%ebp)
  801a43:	e8 7c ff ff ff       	call   8019c4 <vfprintf>
	va_end(ap);

	return cnt;
}
  801a48:	c9                   	leave  
  801a49:	c3                   	ret    

00801a4a <printf>:

int
printf(const char *fmt, ...)
{
  801a4a:	55                   	push   %ebp
  801a4b:	89 e5                	mov    %esp,%ebp
  801a4d:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801a50:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801a53:	50                   	push   %eax
  801a54:	ff 75 08             	pushl  0x8(%ebp)
  801a57:	6a 01                	push   $0x1
  801a59:	e8 66 ff ff ff       	call   8019c4 <vfprintf>
	va_end(ap);

	return cnt;
}
  801a5e:	c9                   	leave  
  801a5f:	c3                   	ret    

00801a60 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a60:	55                   	push   %ebp
  801a61:	89 e5                	mov    %esp,%ebp
  801a63:	56                   	push   %esi
  801a64:	53                   	push   %ebx
  801a65:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a68:	83 ec 0c             	sub    $0xc,%esp
  801a6b:	ff 75 08             	pushl  0x8(%ebp)
  801a6e:	e8 0e f7 ff ff       	call   801181 <fd2data>
  801a73:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a75:	83 c4 08             	add    $0x8,%esp
  801a78:	68 ed 27 80 00       	push   $0x8027ed
  801a7d:	53                   	push   %ebx
  801a7e:	e8 a6 ef ff ff       	call   800a29 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a83:	8b 46 04             	mov    0x4(%esi),%eax
  801a86:	2b 06                	sub    (%esi),%eax
  801a88:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a8e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a95:	00 00 00 
	stat->st_dev = &devpipe;
  801a98:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a9f:	30 80 00 
	return 0;
}
  801aa2:	b8 00 00 00 00       	mov    $0x0,%eax
  801aa7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aaa:	5b                   	pop    %ebx
  801aab:	5e                   	pop    %esi
  801aac:	5d                   	pop    %ebp
  801aad:	c3                   	ret    

00801aae <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801aae:	55                   	push   %ebp
  801aaf:	89 e5                	mov    %esp,%ebp
  801ab1:	53                   	push   %ebx
  801ab2:	83 ec 0c             	sub    $0xc,%esp
  801ab5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ab8:	53                   	push   %ebx
  801ab9:	6a 00                	push   $0x0
  801abb:	e8 f1 f3 ff ff       	call   800eb1 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ac0:	89 1c 24             	mov    %ebx,(%esp)
  801ac3:	e8 b9 f6 ff ff       	call   801181 <fd2data>
  801ac8:	83 c4 08             	add    $0x8,%esp
  801acb:	50                   	push   %eax
  801acc:	6a 00                	push   $0x0
  801ace:	e8 de f3 ff ff       	call   800eb1 <sys_page_unmap>
}
  801ad3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ad6:	c9                   	leave  
  801ad7:	c3                   	ret    

00801ad8 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801ad8:	55                   	push   %ebp
  801ad9:	89 e5                	mov    %esp,%ebp
  801adb:	57                   	push   %edi
  801adc:	56                   	push   %esi
  801add:	53                   	push   %ebx
  801ade:	83 ec 1c             	sub    $0x1c,%esp
  801ae1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801ae4:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ae6:	a1 20 44 80 00       	mov    0x804420,%eax
  801aeb:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801aee:	83 ec 0c             	sub    $0xc,%esp
  801af1:	ff 75 e0             	pushl  -0x20(%ebp)
  801af4:	e8 48 05 00 00       	call   802041 <pageref>
  801af9:	89 c3                	mov    %eax,%ebx
  801afb:	89 3c 24             	mov    %edi,(%esp)
  801afe:	e8 3e 05 00 00       	call   802041 <pageref>
  801b03:	83 c4 10             	add    $0x10,%esp
  801b06:	39 c3                	cmp    %eax,%ebx
  801b08:	0f 94 c1             	sete   %cl
  801b0b:	0f b6 c9             	movzbl %cl,%ecx
  801b0e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801b11:	8b 15 20 44 80 00    	mov    0x804420,%edx
  801b17:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b1a:	39 ce                	cmp    %ecx,%esi
  801b1c:	74 1b                	je     801b39 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801b1e:	39 c3                	cmp    %eax,%ebx
  801b20:	75 c4                	jne    801ae6 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b22:	8b 42 58             	mov    0x58(%edx),%eax
  801b25:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b28:	50                   	push   %eax
  801b29:	56                   	push   %esi
  801b2a:	68 f4 27 80 00       	push   $0x8027f4
  801b2f:	e8 c9 e8 ff ff       	call   8003fd <cprintf>
  801b34:	83 c4 10             	add    $0x10,%esp
  801b37:	eb ad                	jmp    801ae6 <_pipeisclosed+0xe>
	}
}
  801b39:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b3c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b3f:	5b                   	pop    %ebx
  801b40:	5e                   	pop    %esi
  801b41:	5f                   	pop    %edi
  801b42:	5d                   	pop    %ebp
  801b43:	c3                   	ret    

00801b44 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b44:	55                   	push   %ebp
  801b45:	89 e5                	mov    %esp,%ebp
  801b47:	57                   	push   %edi
  801b48:	56                   	push   %esi
  801b49:	53                   	push   %ebx
  801b4a:	83 ec 28             	sub    $0x28,%esp
  801b4d:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b50:	56                   	push   %esi
  801b51:	e8 2b f6 ff ff       	call   801181 <fd2data>
  801b56:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b58:	83 c4 10             	add    $0x10,%esp
  801b5b:	bf 00 00 00 00       	mov    $0x0,%edi
  801b60:	eb 4b                	jmp    801bad <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b62:	89 da                	mov    %ebx,%edx
  801b64:	89 f0                	mov    %esi,%eax
  801b66:	e8 6d ff ff ff       	call   801ad8 <_pipeisclosed>
  801b6b:	85 c0                	test   %eax,%eax
  801b6d:	75 48                	jne    801bb7 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b6f:	e8 99 f2 ff ff       	call   800e0d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b74:	8b 43 04             	mov    0x4(%ebx),%eax
  801b77:	8b 0b                	mov    (%ebx),%ecx
  801b79:	8d 51 20             	lea    0x20(%ecx),%edx
  801b7c:	39 d0                	cmp    %edx,%eax
  801b7e:	73 e2                	jae    801b62 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b83:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b87:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b8a:	89 c2                	mov    %eax,%edx
  801b8c:	c1 fa 1f             	sar    $0x1f,%edx
  801b8f:	89 d1                	mov    %edx,%ecx
  801b91:	c1 e9 1b             	shr    $0x1b,%ecx
  801b94:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b97:	83 e2 1f             	and    $0x1f,%edx
  801b9a:	29 ca                	sub    %ecx,%edx
  801b9c:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801ba0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ba4:	83 c0 01             	add    $0x1,%eax
  801ba7:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801baa:	83 c7 01             	add    $0x1,%edi
  801bad:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801bb0:	75 c2                	jne    801b74 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801bb2:	8b 45 10             	mov    0x10(%ebp),%eax
  801bb5:	eb 05                	jmp    801bbc <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bb7:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801bbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bbf:	5b                   	pop    %ebx
  801bc0:	5e                   	pop    %esi
  801bc1:	5f                   	pop    %edi
  801bc2:	5d                   	pop    %ebp
  801bc3:	c3                   	ret    

00801bc4 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801bc4:	55                   	push   %ebp
  801bc5:	89 e5                	mov    %esp,%ebp
  801bc7:	57                   	push   %edi
  801bc8:	56                   	push   %esi
  801bc9:	53                   	push   %ebx
  801bca:	83 ec 18             	sub    $0x18,%esp
  801bcd:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801bd0:	57                   	push   %edi
  801bd1:	e8 ab f5 ff ff       	call   801181 <fd2data>
  801bd6:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bd8:	83 c4 10             	add    $0x10,%esp
  801bdb:	bb 00 00 00 00       	mov    $0x0,%ebx
  801be0:	eb 3d                	jmp    801c1f <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801be2:	85 db                	test   %ebx,%ebx
  801be4:	74 04                	je     801bea <devpipe_read+0x26>
				return i;
  801be6:	89 d8                	mov    %ebx,%eax
  801be8:	eb 44                	jmp    801c2e <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801bea:	89 f2                	mov    %esi,%edx
  801bec:	89 f8                	mov    %edi,%eax
  801bee:	e8 e5 fe ff ff       	call   801ad8 <_pipeisclosed>
  801bf3:	85 c0                	test   %eax,%eax
  801bf5:	75 32                	jne    801c29 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801bf7:	e8 11 f2 ff ff       	call   800e0d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801bfc:	8b 06                	mov    (%esi),%eax
  801bfe:	3b 46 04             	cmp    0x4(%esi),%eax
  801c01:	74 df                	je     801be2 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c03:	99                   	cltd   
  801c04:	c1 ea 1b             	shr    $0x1b,%edx
  801c07:	01 d0                	add    %edx,%eax
  801c09:	83 e0 1f             	and    $0x1f,%eax
  801c0c:	29 d0                	sub    %edx,%eax
  801c0e:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801c13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c16:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801c19:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c1c:	83 c3 01             	add    $0x1,%ebx
  801c1f:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c22:	75 d8                	jne    801bfc <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c24:	8b 45 10             	mov    0x10(%ebp),%eax
  801c27:	eb 05                	jmp    801c2e <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c29:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c2e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c31:	5b                   	pop    %ebx
  801c32:	5e                   	pop    %esi
  801c33:	5f                   	pop    %edi
  801c34:	5d                   	pop    %ebp
  801c35:	c3                   	ret    

00801c36 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c36:	55                   	push   %ebp
  801c37:	89 e5                	mov    %esp,%ebp
  801c39:	56                   	push   %esi
  801c3a:	53                   	push   %ebx
  801c3b:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c3e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c41:	50                   	push   %eax
  801c42:	e8 51 f5 ff ff       	call   801198 <fd_alloc>
  801c47:	83 c4 10             	add    $0x10,%esp
  801c4a:	89 c2                	mov    %eax,%edx
  801c4c:	85 c0                	test   %eax,%eax
  801c4e:	0f 88 2c 01 00 00    	js     801d80 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c54:	83 ec 04             	sub    $0x4,%esp
  801c57:	68 07 04 00 00       	push   $0x407
  801c5c:	ff 75 f4             	pushl  -0xc(%ebp)
  801c5f:	6a 00                	push   $0x0
  801c61:	e8 c6 f1 ff ff       	call   800e2c <sys_page_alloc>
  801c66:	83 c4 10             	add    $0x10,%esp
  801c69:	89 c2                	mov    %eax,%edx
  801c6b:	85 c0                	test   %eax,%eax
  801c6d:	0f 88 0d 01 00 00    	js     801d80 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c73:	83 ec 0c             	sub    $0xc,%esp
  801c76:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c79:	50                   	push   %eax
  801c7a:	e8 19 f5 ff ff       	call   801198 <fd_alloc>
  801c7f:	89 c3                	mov    %eax,%ebx
  801c81:	83 c4 10             	add    $0x10,%esp
  801c84:	85 c0                	test   %eax,%eax
  801c86:	0f 88 e2 00 00 00    	js     801d6e <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c8c:	83 ec 04             	sub    $0x4,%esp
  801c8f:	68 07 04 00 00       	push   $0x407
  801c94:	ff 75 f0             	pushl  -0x10(%ebp)
  801c97:	6a 00                	push   $0x0
  801c99:	e8 8e f1 ff ff       	call   800e2c <sys_page_alloc>
  801c9e:	89 c3                	mov    %eax,%ebx
  801ca0:	83 c4 10             	add    $0x10,%esp
  801ca3:	85 c0                	test   %eax,%eax
  801ca5:	0f 88 c3 00 00 00    	js     801d6e <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801cab:	83 ec 0c             	sub    $0xc,%esp
  801cae:	ff 75 f4             	pushl  -0xc(%ebp)
  801cb1:	e8 cb f4 ff ff       	call   801181 <fd2data>
  801cb6:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cb8:	83 c4 0c             	add    $0xc,%esp
  801cbb:	68 07 04 00 00       	push   $0x407
  801cc0:	50                   	push   %eax
  801cc1:	6a 00                	push   $0x0
  801cc3:	e8 64 f1 ff ff       	call   800e2c <sys_page_alloc>
  801cc8:	89 c3                	mov    %eax,%ebx
  801cca:	83 c4 10             	add    $0x10,%esp
  801ccd:	85 c0                	test   %eax,%eax
  801ccf:	0f 88 89 00 00 00    	js     801d5e <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cd5:	83 ec 0c             	sub    $0xc,%esp
  801cd8:	ff 75 f0             	pushl  -0x10(%ebp)
  801cdb:	e8 a1 f4 ff ff       	call   801181 <fd2data>
  801ce0:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801ce7:	50                   	push   %eax
  801ce8:	6a 00                	push   $0x0
  801cea:	56                   	push   %esi
  801ceb:	6a 00                	push   $0x0
  801ced:	e8 7d f1 ff ff       	call   800e6f <sys_page_map>
  801cf2:	89 c3                	mov    %eax,%ebx
  801cf4:	83 c4 20             	add    $0x20,%esp
  801cf7:	85 c0                	test   %eax,%eax
  801cf9:	78 55                	js     801d50 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801cfb:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d01:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d04:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d06:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d09:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d10:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d16:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d19:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d1e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d25:	83 ec 0c             	sub    $0xc,%esp
  801d28:	ff 75 f4             	pushl  -0xc(%ebp)
  801d2b:	e8 41 f4 ff ff       	call   801171 <fd2num>
  801d30:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d33:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d35:	83 c4 04             	add    $0x4,%esp
  801d38:	ff 75 f0             	pushl  -0x10(%ebp)
  801d3b:	e8 31 f4 ff ff       	call   801171 <fd2num>
  801d40:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d43:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d46:	83 c4 10             	add    $0x10,%esp
  801d49:	ba 00 00 00 00       	mov    $0x0,%edx
  801d4e:	eb 30                	jmp    801d80 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d50:	83 ec 08             	sub    $0x8,%esp
  801d53:	56                   	push   %esi
  801d54:	6a 00                	push   $0x0
  801d56:	e8 56 f1 ff ff       	call   800eb1 <sys_page_unmap>
  801d5b:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d5e:	83 ec 08             	sub    $0x8,%esp
  801d61:	ff 75 f0             	pushl  -0x10(%ebp)
  801d64:	6a 00                	push   $0x0
  801d66:	e8 46 f1 ff ff       	call   800eb1 <sys_page_unmap>
  801d6b:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d6e:	83 ec 08             	sub    $0x8,%esp
  801d71:	ff 75 f4             	pushl  -0xc(%ebp)
  801d74:	6a 00                	push   $0x0
  801d76:	e8 36 f1 ff ff       	call   800eb1 <sys_page_unmap>
  801d7b:	83 c4 10             	add    $0x10,%esp
  801d7e:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d80:	89 d0                	mov    %edx,%eax
  801d82:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d85:	5b                   	pop    %ebx
  801d86:	5e                   	pop    %esi
  801d87:	5d                   	pop    %ebp
  801d88:	c3                   	ret    

00801d89 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d89:	55                   	push   %ebp
  801d8a:	89 e5                	mov    %esp,%ebp
  801d8c:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d8f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d92:	50                   	push   %eax
  801d93:	ff 75 08             	pushl  0x8(%ebp)
  801d96:	e8 4c f4 ff ff       	call   8011e7 <fd_lookup>
  801d9b:	83 c4 10             	add    $0x10,%esp
  801d9e:	85 c0                	test   %eax,%eax
  801da0:	78 18                	js     801dba <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801da2:	83 ec 0c             	sub    $0xc,%esp
  801da5:	ff 75 f4             	pushl  -0xc(%ebp)
  801da8:	e8 d4 f3 ff ff       	call   801181 <fd2data>
	return _pipeisclosed(fd, p);
  801dad:	89 c2                	mov    %eax,%edx
  801daf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801db2:	e8 21 fd ff ff       	call   801ad8 <_pipeisclosed>
  801db7:	83 c4 10             	add    $0x10,%esp
}
  801dba:	c9                   	leave  
  801dbb:	c3                   	ret    

00801dbc <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801dbc:	55                   	push   %ebp
  801dbd:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801dbf:	b8 00 00 00 00       	mov    $0x0,%eax
  801dc4:	5d                   	pop    %ebp
  801dc5:	c3                   	ret    

00801dc6 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801dc6:	55                   	push   %ebp
  801dc7:	89 e5                	mov    %esp,%ebp
  801dc9:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801dcc:	68 0c 28 80 00       	push   $0x80280c
  801dd1:	ff 75 0c             	pushl  0xc(%ebp)
  801dd4:	e8 50 ec ff ff       	call   800a29 <strcpy>
	return 0;
}
  801dd9:	b8 00 00 00 00       	mov    $0x0,%eax
  801dde:	c9                   	leave  
  801ddf:	c3                   	ret    

00801de0 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801de0:	55                   	push   %ebp
  801de1:	89 e5                	mov    %esp,%ebp
  801de3:	57                   	push   %edi
  801de4:	56                   	push   %esi
  801de5:	53                   	push   %ebx
  801de6:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dec:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801df1:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801df7:	eb 2d                	jmp    801e26 <devcons_write+0x46>
		m = n - tot;
  801df9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801dfc:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801dfe:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e01:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801e06:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e09:	83 ec 04             	sub    $0x4,%esp
  801e0c:	53                   	push   %ebx
  801e0d:	03 45 0c             	add    0xc(%ebp),%eax
  801e10:	50                   	push   %eax
  801e11:	57                   	push   %edi
  801e12:	e8 a4 ed ff ff       	call   800bbb <memmove>
		sys_cputs(buf, m);
  801e17:	83 c4 08             	add    $0x8,%esp
  801e1a:	53                   	push   %ebx
  801e1b:	57                   	push   %edi
  801e1c:	e8 4f ef ff ff       	call   800d70 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e21:	01 de                	add    %ebx,%esi
  801e23:	83 c4 10             	add    $0x10,%esp
  801e26:	89 f0                	mov    %esi,%eax
  801e28:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e2b:	72 cc                	jb     801df9 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e2d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e30:	5b                   	pop    %ebx
  801e31:	5e                   	pop    %esi
  801e32:	5f                   	pop    %edi
  801e33:	5d                   	pop    %ebp
  801e34:	c3                   	ret    

00801e35 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e35:	55                   	push   %ebp
  801e36:	89 e5                	mov    %esp,%ebp
  801e38:	83 ec 08             	sub    $0x8,%esp
  801e3b:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801e40:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e44:	74 2a                	je     801e70 <devcons_read+0x3b>
  801e46:	eb 05                	jmp    801e4d <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e48:	e8 c0 ef ff ff       	call   800e0d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e4d:	e8 3c ef ff ff       	call   800d8e <sys_cgetc>
  801e52:	85 c0                	test   %eax,%eax
  801e54:	74 f2                	je     801e48 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801e56:	85 c0                	test   %eax,%eax
  801e58:	78 16                	js     801e70 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e5a:	83 f8 04             	cmp    $0x4,%eax
  801e5d:	74 0c                	je     801e6b <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e5f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e62:	88 02                	mov    %al,(%edx)
	return 1;
  801e64:	b8 01 00 00 00       	mov    $0x1,%eax
  801e69:	eb 05                	jmp    801e70 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e6b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e70:	c9                   	leave  
  801e71:	c3                   	ret    

00801e72 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e72:	55                   	push   %ebp
  801e73:	89 e5                	mov    %esp,%ebp
  801e75:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e78:	8b 45 08             	mov    0x8(%ebp),%eax
  801e7b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e7e:	6a 01                	push   $0x1
  801e80:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e83:	50                   	push   %eax
  801e84:	e8 e7 ee ff ff       	call   800d70 <sys_cputs>
}
  801e89:	83 c4 10             	add    $0x10,%esp
  801e8c:	c9                   	leave  
  801e8d:	c3                   	ret    

00801e8e <getchar>:

int
getchar(void)
{
  801e8e:	55                   	push   %ebp
  801e8f:	89 e5                	mov    %esp,%ebp
  801e91:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e94:	6a 01                	push   $0x1
  801e96:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e99:	50                   	push   %eax
  801e9a:	6a 00                	push   $0x0
  801e9c:	e8 ac f5 ff ff       	call   80144d <read>
	if (r < 0)
  801ea1:	83 c4 10             	add    $0x10,%esp
  801ea4:	85 c0                	test   %eax,%eax
  801ea6:	78 0f                	js     801eb7 <getchar+0x29>
		return r;
	if (r < 1)
  801ea8:	85 c0                	test   %eax,%eax
  801eaa:	7e 06                	jle    801eb2 <getchar+0x24>
		return -E_EOF;
	return c;
  801eac:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801eb0:	eb 05                	jmp    801eb7 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801eb2:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801eb7:	c9                   	leave  
  801eb8:	c3                   	ret    

00801eb9 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801eb9:	55                   	push   %ebp
  801eba:	89 e5                	mov    %esp,%ebp
  801ebc:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ebf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ec2:	50                   	push   %eax
  801ec3:	ff 75 08             	pushl  0x8(%ebp)
  801ec6:	e8 1c f3 ff ff       	call   8011e7 <fd_lookup>
  801ecb:	83 c4 10             	add    $0x10,%esp
  801ece:	85 c0                	test   %eax,%eax
  801ed0:	78 11                	js     801ee3 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ed2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ed5:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801edb:	39 10                	cmp    %edx,(%eax)
  801edd:	0f 94 c0             	sete   %al
  801ee0:	0f b6 c0             	movzbl %al,%eax
}
  801ee3:	c9                   	leave  
  801ee4:	c3                   	ret    

00801ee5 <opencons>:

int
opencons(void)
{
  801ee5:	55                   	push   %ebp
  801ee6:	89 e5                	mov    %esp,%ebp
  801ee8:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801eeb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801eee:	50                   	push   %eax
  801eef:	e8 a4 f2 ff ff       	call   801198 <fd_alloc>
  801ef4:	83 c4 10             	add    $0x10,%esp
		return r;
  801ef7:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ef9:	85 c0                	test   %eax,%eax
  801efb:	78 3e                	js     801f3b <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801efd:	83 ec 04             	sub    $0x4,%esp
  801f00:	68 07 04 00 00       	push   $0x407
  801f05:	ff 75 f4             	pushl  -0xc(%ebp)
  801f08:	6a 00                	push   $0x0
  801f0a:	e8 1d ef ff ff       	call   800e2c <sys_page_alloc>
  801f0f:	83 c4 10             	add    $0x10,%esp
		return r;
  801f12:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f14:	85 c0                	test   %eax,%eax
  801f16:	78 23                	js     801f3b <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f18:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f21:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f23:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f26:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f2d:	83 ec 0c             	sub    $0xc,%esp
  801f30:	50                   	push   %eax
  801f31:	e8 3b f2 ff ff       	call   801171 <fd2num>
  801f36:	89 c2                	mov    %eax,%edx
  801f38:	83 c4 10             	add    $0x10,%esp
}
  801f3b:	89 d0                	mov    %edx,%eax
  801f3d:	c9                   	leave  
  801f3e:	c3                   	ret    

00801f3f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f3f:	55                   	push   %ebp
  801f40:	89 e5                	mov    %esp,%ebp
  801f42:	56                   	push   %esi
  801f43:	53                   	push   %ebx
  801f44:	8b 75 08             	mov    0x8(%ebp),%esi
  801f47:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f4a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int ret;
	if (pg) ret = sys_ipc_recv(pg);
  801f4d:	85 c0                	test   %eax,%eax
  801f4f:	74 0e                	je     801f5f <ipc_recv+0x20>
  801f51:	83 ec 0c             	sub    $0xc,%esp
  801f54:	50                   	push   %eax
  801f55:	e8 82 f0 ff ff       	call   800fdc <sys_ipc_recv>
  801f5a:	83 c4 10             	add    $0x10,%esp
  801f5d:	eb 10                	jmp    801f6f <ipc_recv+0x30>
	else ret = sys_ipc_recv((void*)UTOP);
  801f5f:	83 ec 0c             	sub    $0xc,%esp
  801f62:	68 00 00 c0 ee       	push   $0xeec00000
  801f67:	e8 70 f0 ff ff       	call   800fdc <sys_ipc_recv>
  801f6c:	83 c4 10             	add    $0x10,%esp
	if (ret) {
  801f6f:	85 c0                	test   %eax,%eax
  801f71:	74 16                	je     801f89 <ipc_recv+0x4a>
		if (from_env_store) *from_env_store = 0;
  801f73:	85 f6                	test   %esi,%esi
  801f75:	74 06                	je     801f7d <ipc_recv+0x3e>
  801f77:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  801f7d:	85 db                	test   %ebx,%ebx
  801f7f:	74 2c                	je     801fad <ipc_recv+0x6e>
  801f81:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801f87:	eb 24                	jmp    801fad <ipc_recv+0x6e>
		return ret;
	}
	if (from_env_store) *from_env_store = thisenv->env_ipc_from;
  801f89:	85 f6                	test   %esi,%esi
  801f8b:	74 0a                	je     801f97 <ipc_recv+0x58>
  801f8d:	a1 20 44 80 00       	mov    0x804420,%eax
  801f92:	8b 40 74             	mov    0x74(%eax),%eax
  801f95:	89 06                	mov    %eax,(%esi)
	if (perm_store) *perm_store = thisenv->env_ipc_perm;
  801f97:	85 db                	test   %ebx,%ebx
  801f99:	74 0a                	je     801fa5 <ipc_recv+0x66>
  801f9b:	a1 20 44 80 00       	mov    0x804420,%eax
  801fa0:	8b 40 78             	mov    0x78(%eax),%eax
  801fa3:	89 03                	mov    %eax,(%ebx)

	// panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801fa5:	a1 20 44 80 00       	mov    0x804420,%eax
  801faa:	8b 40 70             	mov    0x70(%eax),%eax
}
  801fad:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fb0:	5b                   	pop    %ebx
  801fb1:	5e                   	pop    %esi
  801fb2:	5d                   	pop    %ebp
  801fb3:	c3                   	ret    

00801fb4 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801fb4:	55                   	push   %ebp
  801fb5:	89 e5                	mov    %esp,%ebp
  801fb7:	57                   	push   %edi
  801fb8:	56                   	push   %esi
  801fb9:	53                   	push   %ebx
  801fba:	83 ec 0c             	sub    $0xc,%esp
  801fbd:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fc0:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fc3:	8b 45 10             	mov    0x10(%ebp),%eax
  801fc6:	85 c0                	test   %eax,%eax
  801fc8:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801fcd:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	while (true) {
		void* srcva = (pg)? pg: (void*)UTOP;
		int ret = sys_ipc_try_send(to_env, val, srcva, perm);
  801fd0:	ff 75 14             	pushl  0x14(%ebp)
  801fd3:	53                   	push   %ebx
  801fd4:	56                   	push   %esi
  801fd5:	57                   	push   %edi
  801fd6:	e8 de ef ff ff       	call   800fb9 <sys_ipc_try_send>
		if (ret == 0) break;
  801fdb:	83 c4 10             	add    $0x10,%esp
  801fde:	85 c0                	test   %eax,%eax
  801fe0:	74 1e                	je     802000 <ipc_send+0x4c>
		if (ret != -E_IPC_NOT_RECV) panic("ipc_send: %e", ret);
  801fe2:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801fe5:	74 12                	je     801ff9 <ipc_send+0x45>
  801fe7:	50                   	push   %eax
  801fe8:	68 18 28 80 00       	push   $0x802818
  801fed:	6a 39                	push   $0x39
  801fef:	68 25 28 80 00       	push   $0x802825
  801ff4:	e8 2b e3 ff ff       	call   800324 <_panic>
		sys_yield();
  801ff9:	e8 0f ee ff ff       	call   800e0d <sys_yield>
	}
  801ffe:	eb d0                	jmp    801fd0 <ipc_send+0x1c>
	// panic("ipc_send not implemented");
}
  802000:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802003:	5b                   	pop    %ebx
  802004:	5e                   	pop    %esi
  802005:	5f                   	pop    %edi
  802006:	5d                   	pop    %ebp
  802007:	c3                   	ret    

00802008 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802008:	55                   	push   %ebp
  802009:	89 e5                	mov    %esp,%ebp
  80200b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80200e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802013:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802016:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80201c:	8b 52 50             	mov    0x50(%edx),%edx
  80201f:	39 ca                	cmp    %ecx,%edx
  802021:	75 0d                	jne    802030 <ipc_find_env+0x28>
			return envs[i].env_id;
  802023:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802026:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80202b:	8b 40 48             	mov    0x48(%eax),%eax
  80202e:	eb 0f                	jmp    80203f <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802030:	83 c0 01             	add    $0x1,%eax
  802033:	3d 00 04 00 00       	cmp    $0x400,%eax
  802038:	75 d9                	jne    802013 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80203a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80203f:	5d                   	pop    %ebp
  802040:	c3                   	ret    

00802041 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802041:	55                   	push   %ebp
  802042:	89 e5                	mov    %esp,%ebp
  802044:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802047:	89 d0                	mov    %edx,%eax
  802049:	c1 e8 16             	shr    $0x16,%eax
  80204c:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802053:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802058:	f6 c1 01             	test   $0x1,%cl
  80205b:	74 1d                	je     80207a <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80205d:	c1 ea 0c             	shr    $0xc,%edx
  802060:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802067:	f6 c2 01             	test   $0x1,%dl
  80206a:	74 0e                	je     80207a <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80206c:	c1 ea 0c             	shr    $0xc,%edx
  80206f:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802076:	ef 
  802077:	0f b7 c0             	movzwl %ax,%eax
}
  80207a:	5d                   	pop    %ebp
  80207b:	c3                   	ret    
  80207c:	66 90                	xchg   %ax,%ax
  80207e:	66 90                	xchg   %ax,%ax

00802080 <__udivdi3>:
  802080:	55                   	push   %ebp
  802081:	57                   	push   %edi
  802082:	56                   	push   %esi
  802083:	53                   	push   %ebx
  802084:	83 ec 1c             	sub    $0x1c,%esp
  802087:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80208b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80208f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802093:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802097:	85 f6                	test   %esi,%esi
  802099:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80209d:	89 ca                	mov    %ecx,%edx
  80209f:	89 f8                	mov    %edi,%eax
  8020a1:	75 3d                	jne    8020e0 <__udivdi3+0x60>
  8020a3:	39 cf                	cmp    %ecx,%edi
  8020a5:	0f 87 c5 00 00 00    	ja     802170 <__udivdi3+0xf0>
  8020ab:	85 ff                	test   %edi,%edi
  8020ad:	89 fd                	mov    %edi,%ebp
  8020af:	75 0b                	jne    8020bc <__udivdi3+0x3c>
  8020b1:	b8 01 00 00 00       	mov    $0x1,%eax
  8020b6:	31 d2                	xor    %edx,%edx
  8020b8:	f7 f7                	div    %edi
  8020ba:	89 c5                	mov    %eax,%ebp
  8020bc:	89 c8                	mov    %ecx,%eax
  8020be:	31 d2                	xor    %edx,%edx
  8020c0:	f7 f5                	div    %ebp
  8020c2:	89 c1                	mov    %eax,%ecx
  8020c4:	89 d8                	mov    %ebx,%eax
  8020c6:	89 cf                	mov    %ecx,%edi
  8020c8:	f7 f5                	div    %ebp
  8020ca:	89 c3                	mov    %eax,%ebx
  8020cc:	89 d8                	mov    %ebx,%eax
  8020ce:	89 fa                	mov    %edi,%edx
  8020d0:	83 c4 1c             	add    $0x1c,%esp
  8020d3:	5b                   	pop    %ebx
  8020d4:	5e                   	pop    %esi
  8020d5:	5f                   	pop    %edi
  8020d6:	5d                   	pop    %ebp
  8020d7:	c3                   	ret    
  8020d8:	90                   	nop
  8020d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020e0:	39 ce                	cmp    %ecx,%esi
  8020e2:	77 74                	ja     802158 <__udivdi3+0xd8>
  8020e4:	0f bd fe             	bsr    %esi,%edi
  8020e7:	83 f7 1f             	xor    $0x1f,%edi
  8020ea:	0f 84 98 00 00 00    	je     802188 <__udivdi3+0x108>
  8020f0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8020f5:	89 f9                	mov    %edi,%ecx
  8020f7:	89 c5                	mov    %eax,%ebp
  8020f9:	29 fb                	sub    %edi,%ebx
  8020fb:	d3 e6                	shl    %cl,%esi
  8020fd:	89 d9                	mov    %ebx,%ecx
  8020ff:	d3 ed                	shr    %cl,%ebp
  802101:	89 f9                	mov    %edi,%ecx
  802103:	d3 e0                	shl    %cl,%eax
  802105:	09 ee                	or     %ebp,%esi
  802107:	89 d9                	mov    %ebx,%ecx
  802109:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80210d:	89 d5                	mov    %edx,%ebp
  80210f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802113:	d3 ed                	shr    %cl,%ebp
  802115:	89 f9                	mov    %edi,%ecx
  802117:	d3 e2                	shl    %cl,%edx
  802119:	89 d9                	mov    %ebx,%ecx
  80211b:	d3 e8                	shr    %cl,%eax
  80211d:	09 c2                	or     %eax,%edx
  80211f:	89 d0                	mov    %edx,%eax
  802121:	89 ea                	mov    %ebp,%edx
  802123:	f7 f6                	div    %esi
  802125:	89 d5                	mov    %edx,%ebp
  802127:	89 c3                	mov    %eax,%ebx
  802129:	f7 64 24 0c          	mull   0xc(%esp)
  80212d:	39 d5                	cmp    %edx,%ebp
  80212f:	72 10                	jb     802141 <__udivdi3+0xc1>
  802131:	8b 74 24 08          	mov    0x8(%esp),%esi
  802135:	89 f9                	mov    %edi,%ecx
  802137:	d3 e6                	shl    %cl,%esi
  802139:	39 c6                	cmp    %eax,%esi
  80213b:	73 07                	jae    802144 <__udivdi3+0xc4>
  80213d:	39 d5                	cmp    %edx,%ebp
  80213f:	75 03                	jne    802144 <__udivdi3+0xc4>
  802141:	83 eb 01             	sub    $0x1,%ebx
  802144:	31 ff                	xor    %edi,%edi
  802146:	89 d8                	mov    %ebx,%eax
  802148:	89 fa                	mov    %edi,%edx
  80214a:	83 c4 1c             	add    $0x1c,%esp
  80214d:	5b                   	pop    %ebx
  80214e:	5e                   	pop    %esi
  80214f:	5f                   	pop    %edi
  802150:	5d                   	pop    %ebp
  802151:	c3                   	ret    
  802152:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802158:	31 ff                	xor    %edi,%edi
  80215a:	31 db                	xor    %ebx,%ebx
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
  802170:	89 d8                	mov    %ebx,%eax
  802172:	f7 f7                	div    %edi
  802174:	31 ff                	xor    %edi,%edi
  802176:	89 c3                	mov    %eax,%ebx
  802178:	89 d8                	mov    %ebx,%eax
  80217a:	89 fa                	mov    %edi,%edx
  80217c:	83 c4 1c             	add    $0x1c,%esp
  80217f:	5b                   	pop    %ebx
  802180:	5e                   	pop    %esi
  802181:	5f                   	pop    %edi
  802182:	5d                   	pop    %ebp
  802183:	c3                   	ret    
  802184:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802188:	39 ce                	cmp    %ecx,%esi
  80218a:	72 0c                	jb     802198 <__udivdi3+0x118>
  80218c:	31 db                	xor    %ebx,%ebx
  80218e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802192:	0f 87 34 ff ff ff    	ja     8020cc <__udivdi3+0x4c>
  802198:	bb 01 00 00 00       	mov    $0x1,%ebx
  80219d:	e9 2a ff ff ff       	jmp    8020cc <__udivdi3+0x4c>
  8021a2:	66 90                	xchg   %ax,%ax
  8021a4:	66 90                	xchg   %ax,%ax
  8021a6:	66 90                	xchg   %ax,%ax
  8021a8:	66 90                	xchg   %ax,%ax
  8021aa:	66 90                	xchg   %ax,%ax
  8021ac:	66 90                	xchg   %ax,%ax
  8021ae:	66 90                	xchg   %ax,%ax

008021b0 <__umoddi3>:
  8021b0:	55                   	push   %ebp
  8021b1:	57                   	push   %edi
  8021b2:	56                   	push   %esi
  8021b3:	53                   	push   %ebx
  8021b4:	83 ec 1c             	sub    $0x1c,%esp
  8021b7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8021bb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8021bf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8021c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021c7:	85 d2                	test   %edx,%edx
  8021c9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8021cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021d1:	89 f3                	mov    %esi,%ebx
  8021d3:	89 3c 24             	mov    %edi,(%esp)
  8021d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021da:	75 1c                	jne    8021f8 <__umoddi3+0x48>
  8021dc:	39 f7                	cmp    %esi,%edi
  8021de:	76 50                	jbe    802230 <__umoddi3+0x80>
  8021e0:	89 c8                	mov    %ecx,%eax
  8021e2:	89 f2                	mov    %esi,%edx
  8021e4:	f7 f7                	div    %edi
  8021e6:	89 d0                	mov    %edx,%eax
  8021e8:	31 d2                	xor    %edx,%edx
  8021ea:	83 c4 1c             	add    $0x1c,%esp
  8021ed:	5b                   	pop    %ebx
  8021ee:	5e                   	pop    %esi
  8021ef:	5f                   	pop    %edi
  8021f0:	5d                   	pop    %ebp
  8021f1:	c3                   	ret    
  8021f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021f8:	39 f2                	cmp    %esi,%edx
  8021fa:	89 d0                	mov    %edx,%eax
  8021fc:	77 52                	ja     802250 <__umoddi3+0xa0>
  8021fe:	0f bd ea             	bsr    %edx,%ebp
  802201:	83 f5 1f             	xor    $0x1f,%ebp
  802204:	75 5a                	jne    802260 <__umoddi3+0xb0>
  802206:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80220a:	0f 82 e0 00 00 00    	jb     8022f0 <__umoddi3+0x140>
  802210:	39 0c 24             	cmp    %ecx,(%esp)
  802213:	0f 86 d7 00 00 00    	jbe    8022f0 <__umoddi3+0x140>
  802219:	8b 44 24 08          	mov    0x8(%esp),%eax
  80221d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802221:	83 c4 1c             	add    $0x1c,%esp
  802224:	5b                   	pop    %ebx
  802225:	5e                   	pop    %esi
  802226:	5f                   	pop    %edi
  802227:	5d                   	pop    %ebp
  802228:	c3                   	ret    
  802229:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802230:	85 ff                	test   %edi,%edi
  802232:	89 fd                	mov    %edi,%ebp
  802234:	75 0b                	jne    802241 <__umoddi3+0x91>
  802236:	b8 01 00 00 00       	mov    $0x1,%eax
  80223b:	31 d2                	xor    %edx,%edx
  80223d:	f7 f7                	div    %edi
  80223f:	89 c5                	mov    %eax,%ebp
  802241:	89 f0                	mov    %esi,%eax
  802243:	31 d2                	xor    %edx,%edx
  802245:	f7 f5                	div    %ebp
  802247:	89 c8                	mov    %ecx,%eax
  802249:	f7 f5                	div    %ebp
  80224b:	89 d0                	mov    %edx,%eax
  80224d:	eb 99                	jmp    8021e8 <__umoddi3+0x38>
  80224f:	90                   	nop
  802250:	89 c8                	mov    %ecx,%eax
  802252:	89 f2                	mov    %esi,%edx
  802254:	83 c4 1c             	add    $0x1c,%esp
  802257:	5b                   	pop    %ebx
  802258:	5e                   	pop    %esi
  802259:	5f                   	pop    %edi
  80225a:	5d                   	pop    %ebp
  80225b:	c3                   	ret    
  80225c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802260:	8b 34 24             	mov    (%esp),%esi
  802263:	bf 20 00 00 00       	mov    $0x20,%edi
  802268:	89 e9                	mov    %ebp,%ecx
  80226a:	29 ef                	sub    %ebp,%edi
  80226c:	d3 e0                	shl    %cl,%eax
  80226e:	89 f9                	mov    %edi,%ecx
  802270:	89 f2                	mov    %esi,%edx
  802272:	d3 ea                	shr    %cl,%edx
  802274:	89 e9                	mov    %ebp,%ecx
  802276:	09 c2                	or     %eax,%edx
  802278:	89 d8                	mov    %ebx,%eax
  80227a:	89 14 24             	mov    %edx,(%esp)
  80227d:	89 f2                	mov    %esi,%edx
  80227f:	d3 e2                	shl    %cl,%edx
  802281:	89 f9                	mov    %edi,%ecx
  802283:	89 54 24 04          	mov    %edx,0x4(%esp)
  802287:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80228b:	d3 e8                	shr    %cl,%eax
  80228d:	89 e9                	mov    %ebp,%ecx
  80228f:	89 c6                	mov    %eax,%esi
  802291:	d3 e3                	shl    %cl,%ebx
  802293:	89 f9                	mov    %edi,%ecx
  802295:	89 d0                	mov    %edx,%eax
  802297:	d3 e8                	shr    %cl,%eax
  802299:	89 e9                	mov    %ebp,%ecx
  80229b:	09 d8                	or     %ebx,%eax
  80229d:	89 d3                	mov    %edx,%ebx
  80229f:	89 f2                	mov    %esi,%edx
  8022a1:	f7 34 24             	divl   (%esp)
  8022a4:	89 d6                	mov    %edx,%esi
  8022a6:	d3 e3                	shl    %cl,%ebx
  8022a8:	f7 64 24 04          	mull   0x4(%esp)
  8022ac:	39 d6                	cmp    %edx,%esi
  8022ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022b2:	89 d1                	mov    %edx,%ecx
  8022b4:	89 c3                	mov    %eax,%ebx
  8022b6:	72 08                	jb     8022c0 <__umoddi3+0x110>
  8022b8:	75 11                	jne    8022cb <__umoddi3+0x11b>
  8022ba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8022be:	73 0b                	jae    8022cb <__umoddi3+0x11b>
  8022c0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8022c4:	1b 14 24             	sbb    (%esp),%edx
  8022c7:	89 d1                	mov    %edx,%ecx
  8022c9:	89 c3                	mov    %eax,%ebx
  8022cb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8022cf:	29 da                	sub    %ebx,%edx
  8022d1:	19 ce                	sbb    %ecx,%esi
  8022d3:	89 f9                	mov    %edi,%ecx
  8022d5:	89 f0                	mov    %esi,%eax
  8022d7:	d3 e0                	shl    %cl,%eax
  8022d9:	89 e9                	mov    %ebp,%ecx
  8022db:	d3 ea                	shr    %cl,%edx
  8022dd:	89 e9                	mov    %ebp,%ecx
  8022df:	d3 ee                	shr    %cl,%esi
  8022e1:	09 d0                	or     %edx,%eax
  8022e3:	89 f2                	mov    %esi,%edx
  8022e5:	83 c4 1c             	add    $0x1c,%esp
  8022e8:	5b                   	pop    %ebx
  8022e9:	5e                   	pop    %esi
  8022ea:	5f                   	pop    %edi
  8022eb:	5d                   	pop    %ebp
  8022ec:	c3                   	ret    
  8022ed:	8d 76 00             	lea    0x0(%esi),%esi
  8022f0:	29 f9                	sub    %edi,%ecx
  8022f2:	19 d6                	sbb    %edx,%esi
  8022f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022fc:	e9 18 ff ff ff       	jmp    802219 <__umoddi3+0x69>
