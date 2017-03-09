
obj/user/testfile.debug:     file format elf32-i386


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
  80002c:	e8 f7 05 00 00       	call   800628 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <xopen>:

#define FVA ((struct Fd*)0xCCCCC000)

static int
xopen(const char *path, int mode)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
  80003a:	89 d3                	mov    %edx,%ebx
	extern union Fsipc fsipcbuf;
	envid_t fsenv;
	
	strcpy(fsipcbuf.open.req_path, path);
  80003c:	50                   	push   %eax
  80003d:	68 00 50 80 00       	push   $0x805000
  800042:	e8 46 0d 00 00       	call   800d8d <strcpy>
	fsipcbuf.open.req_omode = mode;
  800047:	89 1d 00 54 80 00    	mov    %ebx,0x805400

	fsenv = ipc_find_env(ENV_TYPE_FS);
  80004d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800054:	e8 f1 13 00 00       	call   80144a <ipc_find_env>
	ipc_send(fsenv, FSREQ_OPEN, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800059:	6a 07                	push   $0x7
  80005b:	68 00 50 80 00       	push   $0x805000
  800060:	6a 01                	push   $0x1
  800062:	50                   	push   %eax
  800063:	e8 8e 13 00 00       	call   8013f6 <ipc_send>
	return ipc_recv(NULL, FVA, NULL);
  800068:	83 c4 1c             	add    $0x1c,%esp
  80006b:	6a 00                	push   $0x0
  80006d:	68 00 c0 cc cc       	push   $0xccccc000
  800072:	6a 00                	push   $0x0
  800074:	e8 08 13 00 00       	call   801381 <ipc_recv>
}
  800079:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80007c:	c9                   	leave  
  80007d:	c3                   	ret    

0080007e <umain>:

void
umain(int argc, char **argv)
{
  80007e:	55                   	push   %ebp
  80007f:	89 e5                	mov    %esp,%ebp
  800081:	57                   	push   %edi
  800082:	56                   	push   %esi
  800083:	53                   	push   %ebx
  800084:	81 ec ac 02 00 00    	sub    $0x2ac,%esp
	struct Fd fdcopy;
	struct Stat st;
	char buf[512];

	// We open files manually first, to avoid the FD layer
	if ((r = xopen("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  80008a:	ba 00 00 00 00       	mov    $0x0,%edx
  80008f:	b8 20 24 80 00       	mov    $0x802420,%eax
  800094:	e8 9a ff ff ff       	call   800033 <xopen>
  800099:	83 f8 f5             	cmp    $0xfffffff5,%eax
  80009c:	74 1b                	je     8000b9 <umain+0x3b>
  80009e:	89 c2                	mov    %eax,%edx
  8000a0:	c1 ea 1f             	shr    $0x1f,%edx
  8000a3:	84 d2                	test   %dl,%dl
  8000a5:	74 12                	je     8000b9 <umain+0x3b>
		panic("serve_open /not-found: %e", r);
  8000a7:	50                   	push   %eax
  8000a8:	68 2b 24 80 00       	push   $0x80242b
  8000ad:	6a 20                	push   $0x20
  8000af:	68 45 24 80 00       	push   $0x802445
  8000b4:	e8 cf 05 00 00       	call   800688 <_panic>
	else if (r >= 0)
  8000b9:	85 c0                	test   %eax,%eax
  8000bb:	78 14                	js     8000d1 <umain+0x53>
		panic("serve_open /not-found succeeded!");
  8000bd:	83 ec 04             	sub    $0x4,%esp
  8000c0:	68 e0 25 80 00       	push   $0x8025e0
  8000c5:	6a 22                	push   $0x22
  8000c7:	68 45 24 80 00       	push   $0x802445
  8000cc:	e8 b7 05 00 00       	call   800688 <_panic>

	if ((r = xopen("/newmotd", O_RDONLY)) < 0)
  8000d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d6:	b8 55 24 80 00       	mov    $0x802455,%eax
  8000db:	e8 53 ff ff ff       	call   800033 <xopen>
  8000e0:	85 c0                	test   %eax,%eax
  8000e2:	79 12                	jns    8000f6 <umain+0x78>
		panic("serve_open /newmotd: %e", r);
  8000e4:	50                   	push   %eax
  8000e5:	68 5e 24 80 00       	push   $0x80245e
  8000ea:	6a 25                	push   $0x25
  8000ec:	68 45 24 80 00       	push   $0x802445
  8000f1:	e8 92 05 00 00       	call   800688 <_panic>
	if (FVA->fd_dev_id != 'f' || FVA->fd_offset != 0 || FVA->fd_omode != O_RDONLY)
  8000f6:	83 3d 00 c0 cc cc 66 	cmpl   $0x66,0xccccc000
  8000fd:	75 12                	jne    800111 <umain+0x93>
  8000ff:	83 3d 04 c0 cc cc 00 	cmpl   $0x0,0xccccc004
  800106:	75 09                	jne    800111 <umain+0x93>
  800108:	83 3d 08 c0 cc cc 00 	cmpl   $0x0,0xccccc008
  80010f:	74 14                	je     800125 <umain+0xa7>
		panic("serve_open did not fill struct Fd correctly\n");
  800111:	83 ec 04             	sub    $0x4,%esp
  800114:	68 04 26 80 00       	push   $0x802604
  800119:	6a 27                	push   $0x27
  80011b:	68 45 24 80 00       	push   $0x802445
  800120:	e8 63 05 00 00       	call   800688 <_panic>
	cprintf("serve_open is good\n");
  800125:	83 ec 0c             	sub    $0xc,%esp
  800128:	68 76 24 80 00       	push   $0x802476
  80012d:	e8 2f 06 00 00       	call   800761 <cprintf>

	if ((r = devfile.dev_stat(FVA, &st)) < 0)
  800132:	83 c4 08             	add    $0x8,%esp
  800135:	8d 85 4c ff ff ff    	lea    -0xb4(%ebp),%eax
  80013b:	50                   	push   %eax
  80013c:	68 00 c0 cc cc       	push   $0xccccc000
  800141:	ff 15 1c 30 80 00    	call   *0x80301c
  800147:	83 c4 10             	add    $0x10,%esp
  80014a:	85 c0                	test   %eax,%eax
  80014c:	79 12                	jns    800160 <umain+0xe2>
		panic("file_stat: %e", r);
  80014e:	50                   	push   %eax
  80014f:	68 8a 24 80 00       	push   $0x80248a
  800154:	6a 2b                	push   $0x2b
  800156:	68 45 24 80 00       	push   $0x802445
  80015b:	e8 28 05 00 00       	call   800688 <_panic>
	if (strlen(msg) != st.st_size)
  800160:	83 ec 0c             	sub    $0xc,%esp
  800163:	ff 35 00 30 80 00    	pushl  0x803000
  800169:	e8 e6 0b 00 00       	call   800d54 <strlen>
  80016e:	83 c4 10             	add    $0x10,%esp
  800171:	3b 45 cc             	cmp    -0x34(%ebp),%eax
  800174:	74 25                	je     80019b <umain+0x11d>
		panic("file_stat returned size %d wanted %d\n", st.st_size, strlen(msg));
  800176:	83 ec 0c             	sub    $0xc,%esp
  800179:	ff 35 00 30 80 00    	pushl  0x803000
  80017f:	e8 d0 0b 00 00       	call   800d54 <strlen>
  800184:	89 04 24             	mov    %eax,(%esp)
  800187:	ff 75 cc             	pushl  -0x34(%ebp)
  80018a:	68 34 26 80 00       	push   $0x802634
  80018f:	6a 2d                	push   $0x2d
  800191:	68 45 24 80 00       	push   $0x802445
  800196:	e8 ed 04 00 00       	call   800688 <_panic>
	cprintf("file_stat is good\n");
  80019b:	83 ec 0c             	sub    $0xc,%esp
  80019e:	68 98 24 80 00       	push   $0x802498
  8001a3:	e8 b9 05 00 00       	call   800761 <cprintf>

	memset(buf, 0, sizeof buf);
  8001a8:	83 c4 0c             	add    $0xc,%esp
  8001ab:	68 00 02 00 00       	push   $0x200
  8001b0:	6a 00                	push   $0x0
  8001b2:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  8001b8:	53                   	push   %ebx
  8001b9:	e8 14 0d 00 00       	call   800ed2 <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  8001be:	83 c4 0c             	add    $0xc,%esp
  8001c1:	68 00 02 00 00       	push   $0x200
  8001c6:	53                   	push   %ebx
  8001c7:	68 00 c0 cc cc       	push   $0xccccc000
  8001cc:	ff 15 10 30 80 00    	call   *0x803010
  8001d2:	83 c4 10             	add    $0x10,%esp
  8001d5:	85 c0                	test   %eax,%eax
  8001d7:	79 12                	jns    8001eb <umain+0x16d>
		panic("file_read: %e", r);
  8001d9:	50                   	push   %eax
  8001da:	68 ab 24 80 00       	push   $0x8024ab
  8001df:	6a 32                	push   $0x32
  8001e1:	68 45 24 80 00       	push   $0x802445
  8001e6:	e8 9d 04 00 00       	call   800688 <_panic>
	if (strcmp(buf, msg) != 0)
  8001eb:	83 ec 08             	sub    $0x8,%esp
  8001ee:	ff 35 00 30 80 00    	pushl  0x803000
  8001f4:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8001fa:	50                   	push   %eax
  8001fb:	e8 37 0c 00 00       	call   800e37 <strcmp>
  800200:	83 c4 10             	add    $0x10,%esp
  800203:	85 c0                	test   %eax,%eax
  800205:	74 14                	je     80021b <umain+0x19d>
		panic("file_read returned wrong data");
  800207:	83 ec 04             	sub    $0x4,%esp
  80020a:	68 b9 24 80 00       	push   $0x8024b9
  80020f:	6a 34                	push   $0x34
  800211:	68 45 24 80 00       	push   $0x802445
  800216:	e8 6d 04 00 00       	call   800688 <_panic>
	cprintf("file_read is good\n");
  80021b:	83 ec 0c             	sub    $0xc,%esp
  80021e:	68 d7 24 80 00       	push   $0x8024d7
  800223:	e8 39 05 00 00       	call   800761 <cprintf>

	if ((r = devfile.dev_close(FVA)) < 0)
  800228:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  80022f:	ff 15 18 30 80 00    	call   *0x803018
  800235:	83 c4 10             	add    $0x10,%esp
  800238:	85 c0                	test   %eax,%eax
  80023a:	79 12                	jns    80024e <umain+0x1d0>
		panic("file_close: %e", r);
  80023c:	50                   	push   %eax
  80023d:	68 ea 24 80 00       	push   $0x8024ea
  800242:	6a 38                	push   $0x38
  800244:	68 45 24 80 00       	push   $0x802445
  800249:	e8 3a 04 00 00       	call   800688 <_panic>
	cprintf("file_close is good\n");
  80024e:	83 ec 0c             	sub    $0xc,%esp
  800251:	68 f9 24 80 00       	push   $0x8024f9
  800256:	e8 06 05 00 00       	call   800761 <cprintf>

	// We're about to unmap the FD, but still need a way to get
	// the stale filenum to serve_read, so we make a local copy.
	// The file server won't think it's stale until we unmap the
	// FD page.
	fdcopy = *FVA;
  80025b:	a1 00 c0 cc cc       	mov    0xccccc000,%eax
  800260:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800263:	a1 04 c0 cc cc       	mov    0xccccc004,%eax
  800268:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80026b:	a1 08 c0 cc cc       	mov    0xccccc008,%eax
  800270:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800273:	a1 0c c0 cc cc       	mov    0xccccc00c,%eax
  800278:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	sys_page_unmap(0, FVA);
  80027b:	83 c4 08             	add    $0x8,%esp
  80027e:	68 00 c0 cc cc       	push   $0xccccc000
  800283:	6a 00                	push   $0x0
  800285:	e8 8b 0f 00 00       	call   801215 <sys_page_unmap>

	if ((r = devfile.dev_read(&fdcopy, buf, sizeof buf)) != -E_INVAL)
  80028a:	83 c4 0c             	add    $0xc,%esp
  80028d:	68 00 02 00 00       	push   $0x200
  800292:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  800298:	50                   	push   %eax
  800299:	8d 45 d8             	lea    -0x28(%ebp),%eax
  80029c:	50                   	push   %eax
  80029d:	ff 15 10 30 80 00    	call   *0x803010
  8002a3:	83 c4 10             	add    $0x10,%esp
  8002a6:	83 f8 fd             	cmp    $0xfffffffd,%eax
  8002a9:	74 12                	je     8002bd <umain+0x23f>
		panic("serve_read does not handle stale fileids correctly: %e", r);
  8002ab:	50                   	push   %eax
  8002ac:	68 5c 26 80 00       	push   $0x80265c
  8002b1:	6a 43                	push   $0x43
  8002b3:	68 45 24 80 00       	push   $0x802445
  8002b8:	e8 cb 03 00 00       	call   800688 <_panic>
	cprintf("stale fileid is good\n");
  8002bd:	83 ec 0c             	sub    $0xc,%esp
  8002c0:	68 0d 25 80 00       	push   $0x80250d
  8002c5:	e8 97 04 00 00       	call   800761 <cprintf>

	// Try writing
	if ((r = xopen("/new-file", O_RDWR|O_CREAT)) < 0)
  8002ca:	ba 02 01 00 00       	mov    $0x102,%edx
  8002cf:	b8 23 25 80 00       	mov    $0x802523,%eax
  8002d4:	e8 5a fd ff ff       	call   800033 <xopen>
  8002d9:	83 c4 10             	add    $0x10,%esp
  8002dc:	85 c0                	test   %eax,%eax
  8002de:	79 12                	jns    8002f2 <umain+0x274>
		panic("serve_open /new-file: %e", r);
  8002e0:	50                   	push   %eax
  8002e1:	68 2d 25 80 00       	push   $0x80252d
  8002e6:	6a 48                	push   $0x48
  8002e8:	68 45 24 80 00       	push   $0x802445
  8002ed:	e8 96 03 00 00       	call   800688 <_panic>

	if ((r = devfile.dev_write(FVA, msg, strlen(msg))) != strlen(msg))
  8002f2:	8b 1d 14 30 80 00    	mov    0x803014,%ebx
  8002f8:	83 ec 0c             	sub    $0xc,%esp
  8002fb:	ff 35 00 30 80 00    	pushl  0x803000
  800301:	e8 4e 0a 00 00       	call   800d54 <strlen>
  800306:	83 c4 0c             	add    $0xc,%esp
  800309:	50                   	push   %eax
  80030a:	ff 35 00 30 80 00    	pushl  0x803000
  800310:	68 00 c0 cc cc       	push   $0xccccc000
  800315:	ff d3                	call   *%ebx
  800317:	89 c3                	mov    %eax,%ebx
  800319:	83 c4 04             	add    $0x4,%esp
  80031c:	ff 35 00 30 80 00    	pushl  0x803000
  800322:	e8 2d 0a 00 00       	call   800d54 <strlen>
  800327:	83 c4 10             	add    $0x10,%esp
  80032a:	39 c3                	cmp    %eax,%ebx
  80032c:	74 12                	je     800340 <umain+0x2c2>
		panic("file_write: %e", r);
  80032e:	53                   	push   %ebx
  80032f:	68 46 25 80 00       	push   $0x802546
  800334:	6a 4b                	push   $0x4b
  800336:	68 45 24 80 00       	push   $0x802445
  80033b:	e8 48 03 00 00       	call   800688 <_panic>
	cprintf("file_write is good\n");
  800340:	83 ec 0c             	sub    $0xc,%esp
  800343:	68 55 25 80 00       	push   $0x802555
  800348:	e8 14 04 00 00       	call   800761 <cprintf>

	FVA->fd_offset = 0;
  80034d:	c7 05 04 c0 cc cc 00 	movl   $0x0,0xccccc004
  800354:	00 00 00 
	memset(buf, 0, sizeof buf);
  800357:	83 c4 0c             	add    $0xc,%esp
  80035a:	68 00 02 00 00       	push   $0x200
  80035f:	6a 00                	push   $0x0
  800361:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  800367:	53                   	push   %ebx
  800368:	e8 65 0b 00 00       	call   800ed2 <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  80036d:	83 c4 0c             	add    $0xc,%esp
  800370:	68 00 02 00 00       	push   $0x200
  800375:	53                   	push   %ebx
  800376:	68 00 c0 cc cc       	push   $0xccccc000
  80037b:	ff 15 10 30 80 00    	call   *0x803010
  800381:	89 c3                	mov    %eax,%ebx
  800383:	83 c4 10             	add    $0x10,%esp
  800386:	85 c0                	test   %eax,%eax
  800388:	79 12                	jns    80039c <umain+0x31e>
		panic("file_read after file_write: %e", r);
  80038a:	50                   	push   %eax
  80038b:	68 94 26 80 00       	push   $0x802694
  800390:	6a 51                	push   $0x51
  800392:	68 45 24 80 00       	push   $0x802445
  800397:	e8 ec 02 00 00       	call   800688 <_panic>
	if (r != strlen(msg))
  80039c:	83 ec 0c             	sub    $0xc,%esp
  80039f:	ff 35 00 30 80 00    	pushl  0x803000
  8003a5:	e8 aa 09 00 00       	call   800d54 <strlen>
  8003aa:	83 c4 10             	add    $0x10,%esp
  8003ad:	39 c3                	cmp    %eax,%ebx
  8003af:	74 12                	je     8003c3 <umain+0x345>
		panic("file_read after file_write returned wrong length: %d", r);
  8003b1:	53                   	push   %ebx
  8003b2:	68 b4 26 80 00       	push   $0x8026b4
  8003b7:	6a 53                	push   $0x53
  8003b9:	68 45 24 80 00       	push   $0x802445
  8003be:	e8 c5 02 00 00       	call   800688 <_panic>
	if (strcmp(buf, msg) != 0)
  8003c3:	83 ec 08             	sub    $0x8,%esp
  8003c6:	ff 35 00 30 80 00    	pushl  0x803000
  8003cc:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8003d2:	50                   	push   %eax
  8003d3:	e8 5f 0a 00 00       	call   800e37 <strcmp>
  8003d8:	83 c4 10             	add    $0x10,%esp
  8003db:	85 c0                	test   %eax,%eax
  8003dd:	74 14                	je     8003f3 <umain+0x375>
		panic("file_read after file_write returned wrong data");
  8003df:	83 ec 04             	sub    $0x4,%esp
  8003e2:	68 ec 26 80 00       	push   $0x8026ec
  8003e7:	6a 55                	push   $0x55
  8003e9:	68 45 24 80 00       	push   $0x802445
  8003ee:	e8 95 02 00 00       	call   800688 <_panic>
	cprintf("file_read after file_write is good\n");
  8003f3:	83 ec 0c             	sub    $0xc,%esp
  8003f6:	68 1c 27 80 00       	push   $0x80271c
  8003fb:	e8 61 03 00 00       	call   800761 <cprintf>

	// Now we'll try out open
	if ((r = open("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  800400:	83 c4 08             	add    $0x8,%esp
  800403:	6a 00                	push   $0x0
  800405:	68 20 24 80 00       	push   $0x802420
  80040a:	e8 af 17 00 00       	call   801bbe <open>
  80040f:	83 c4 10             	add    $0x10,%esp
  800412:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800415:	74 1b                	je     800432 <umain+0x3b4>
  800417:	89 c2                	mov    %eax,%edx
  800419:	c1 ea 1f             	shr    $0x1f,%edx
  80041c:	84 d2                	test   %dl,%dl
  80041e:	74 12                	je     800432 <umain+0x3b4>
		panic("open /not-found: %e", r);
  800420:	50                   	push   %eax
  800421:	68 31 24 80 00       	push   $0x802431
  800426:	6a 5a                	push   $0x5a
  800428:	68 45 24 80 00       	push   $0x802445
  80042d:	e8 56 02 00 00       	call   800688 <_panic>
	else if (r >= 0)
  800432:	85 c0                	test   %eax,%eax
  800434:	78 14                	js     80044a <umain+0x3cc>
		panic("open /not-found succeeded!");
  800436:	83 ec 04             	sub    $0x4,%esp
  800439:	68 69 25 80 00       	push   $0x802569
  80043e:	6a 5c                	push   $0x5c
  800440:	68 45 24 80 00       	push   $0x802445
  800445:	e8 3e 02 00 00       	call   800688 <_panic>

	if ((r = open("/newmotd", O_RDONLY)) < 0)
  80044a:	83 ec 08             	sub    $0x8,%esp
  80044d:	6a 00                	push   $0x0
  80044f:	68 55 24 80 00       	push   $0x802455
  800454:	e8 65 17 00 00       	call   801bbe <open>
  800459:	83 c4 10             	add    $0x10,%esp
  80045c:	85 c0                	test   %eax,%eax
  80045e:	79 12                	jns    800472 <umain+0x3f4>
		panic("open /newmotd: %e", r);
  800460:	50                   	push   %eax
  800461:	68 64 24 80 00       	push   $0x802464
  800466:	6a 5f                	push   $0x5f
  800468:	68 45 24 80 00       	push   $0x802445
  80046d:	e8 16 02 00 00       	call   800688 <_panic>
	fd = (struct Fd*) (0xD0000000 + r*PGSIZE);
  800472:	c1 e0 0c             	shl    $0xc,%eax
	if (fd->fd_dev_id != 'f' || fd->fd_offset != 0 || fd->fd_omode != O_RDONLY)
  800475:	83 b8 00 00 00 d0 66 	cmpl   $0x66,-0x30000000(%eax)
  80047c:	75 12                	jne    800490 <umain+0x412>
  80047e:	83 b8 04 00 00 d0 00 	cmpl   $0x0,-0x2ffffffc(%eax)
  800485:	75 09                	jne    800490 <umain+0x412>
  800487:	83 b8 08 00 00 d0 00 	cmpl   $0x0,-0x2ffffff8(%eax)
  80048e:	74 14                	je     8004a4 <umain+0x426>
		panic("open did not fill struct Fd correctly\n");
  800490:	83 ec 04             	sub    $0x4,%esp
  800493:	68 40 27 80 00       	push   $0x802740
  800498:	6a 62                	push   $0x62
  80049a:	68 45 24 80 00       	push   $0x802445
  80049f:	e8 e4 01 00 00       	call   800688 <_panic>
	cprintf("open is good\n");
  8004a4:	83 ec 0c             	sub    $0xc,%esp
  8004a7:	68 7c 24 80 00       	push   $0x80247c
  8004ac:	e8 b0 02 00 00       	call   800761 <cprintf>

	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
  8004b1:	83 c4 08             	add    $0x8,%esp
  8004b4:	68 01 01 00 00       	push   $0x101
  8004b9:	68 84 25 80 00       	push   $0x802584
  8004be:	e8 fb 16 00 00       	call   801bbe <open>
  8004c3:	89 c6                	mov    %eax,%esi
  8004c5:	83 c4 10             	add    $0x10,%esp
  8004c8:	85 c0                	test   %eax,%eax
  8004ca:	79 12                	jns    8004de <umain+0x460>
		panic("creat /big: %e", f);
  8004cc:	50                   	push   %eax
  8004cd:	68 89 25 80 00       	push   $0x802589
  8004d2:	6a 67                	push   $0x67
  8004d4:	68 45 24 80 00       	push   $0x802445
  8004d9:	e8 aa 01 00 00       	call   800688 <_panic>
	memset(buf, 0, sizeof(buf));
  8004de:	83 ec 04             	sub    $0x4,%esp
  8004e1:	68 00 02 00 00       	push   $0x200
  8004e6:	6a 00                	push   $0x0
  8004e8:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8004ee:	50                   	push   %eax
  8004ef:	e8 de 09 00 00       	call   800ed2 <memset>
  8004f4:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  8004f7:	bb 00 00 00 00       	mov    $0x0,%ebx
		*(int*)buf = i;
		if ((r = write(f, buf, sizeof(buf))) < 0)
  8004fc:	8d bd 4c fd ff ff    	lea    -0x2b4(%ebp),%edi
	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
		panic("creat /big: %e", f);
	memset(buf, 0, sizeof(buf));
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
  800502:	89 9d 4c fd ff ff    	mov    %ebx,-0x2b4(%ebp)
		if ((r = write(f, buf, sizeof(buf))) < 0)
  800508:	83 ec 04             	sub    $0x4,%esp
  80050b:	68 00 02 00 00       	push   $0x200
  800510:	57                   	push   %edi
  800511:	56                   	push   %esi
  800512:	e8 22 13 00 00       	call   801839 <write>
  800517:	83 c4 10             	add    $0x10,%esp
  80051a:	85 c0                	test   %eax,%eax
  80051c:	79 16                	jns    800534 <umain+0x4b6>
			panic("write /big@%d: %e", i, r);
  80051e:	83 ec 0c             	sub    $0xc,%esp
  800521:	50                   	push   %eax
  800522:	53                   	push   %ebx
  800523:	68 98 25 80 00       	push   $0x802598
  800528:	6a 6c                	push   $0x6c
  80052a:	68 45 24 80 00       	push   $0x802445
  80052f:	e8 54 01 00 00       	call   800688 <_panic>
  800534:	8d 83 00 02 00 00    	lea    0x200(%ebx),%eax
  80053a:	89 c3                	mov    %eax,%ebx

	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
		panic("creat /big: %e", f);
	memset(buf, 0, sizeof(buf));
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  80053c:	3d 00 e0 01 00       	cmp    $0x1e000,%eax
  800541:	75 bf                	jne    800502 <umain+0x484>
		*(int*)buf = i;
		if ((r = write(f, buf, sizeof(buf))) < 0)
			panic("write /big@%d: %e", i, r);
	}
	close(f);
  800543:	83 ec 0c             	sub    $0xc,%esp
  800546:	56                   	push   %esi
  800547:	e8 d7 10 00 00       	call   801623 <close>

	if ((f = open("/big", O_RDONLY)) < 0)
  80054c:	83 c4 08             	add    $0x8,%esp
  80054f:	6a 00                	push   $0x0
  800551:	68 84 25 80 00       	push   $0x802584
  800556:	e8 63 16 00 00       	call   801bbe <open>
  80055b:	89 c6                	mov    %eax,%esi
  80055d:	83 c4 10             	add    $0x10,%esp
  800560:	85 c0                	test   %eax,%eax
  800562:	79 12                	jns    800576 <umain+0x4f8>
		panic("open /big: %e", f);
  800564:	50                   	push   %eax
  800565:	68 aa 25 80 00       	push   $0x8025aa
  80056a:	6a 71                	push   $0x71
  80056c:	68 45 24 80 00       	push   $0x802445
  800571:	e8 12 01 00 00       	call   800688 <_panic>
  800576:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
		if ((r = readn(f, buf, sizeof(buf))) < 0)
  80057b:	8d bd 4c fd ff ff    	lea    -0x2b4(%ebp),%edi
	close(f);

	if ((f = open("/big", O_RDONLY)) < 0)
		panic("open /big: %e", f);
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
  800581:	89 9d 4c fd ff ff    	mov    %ebx,-0x2b4(%ebp)
		if ((r = readn(f, buf, sizeof(buf))) < 0)
  800587:	83 ec 04             	sub    $0x4,%esp
  80058a:	68 00 02 00 00       	push   $0x200
  80058f:	57                   	push   %edi
  800590:	56                   	push   %esi
  800591:	e8 5a 12 00 00       	call   8017f0 <readn>
  800596:	83 c4 10             	add    $0x10,%esp
  800599:	85 c0                	test   %eax,%eax
  80059b:	79 16                	jns    8005b3 <umain+0x535>
			panic("read /big@%d: %e", i, r);
  80059d:	83 ec 0c             	sub    $0xc,%esp
  8005a0:	50                   	push   %eax
  8005a1:	53                   	push   %ebx
  8005a2:	68 b8 25 80 00       	push   $0x8025b8
  8005a7:	6a 75                	push   $0x75
  8005a9:	68 45 24 80 00       	push   $0x802445
  8005ae:	e8 d5 00 00 00       	call   800688 <_panic>
		if (r != sizeof(buf))
  8005b3:	3d 00 02 00 00       	cmp    $0x200,%eax
  8005b8:	74 1b                	je     8005d5 <umain+0x557>
			panic("read /big from %d returned %d < %d bytes",
  8005ba:	83 ec 08             	sub    $0x8,%esp
  8005bd:	68 00 02 00 00       	push   $0x200
  8005c2:	50                   	push   %eax
  8005c3:	53                   	push   %ebx
  8005c4:	68 68 27 80 00       	push   $0x802768
  8005c9:	6a 78                	push   $0x78
  8005cb:	68 45 24 80 00       	push   $0x802445
  8005d0:	e8 b3 00 00 00       	call   800688 <_panic>
			      i, r, sizeof(buf));
		if (*(int*)buf != i)
  8005d5:	8b 85 4c fd ff ff    	mov    -0x2b4(%ebp),%eax
  8005db:	39 d8                	cmp    %ebx,%eax
  8005dd:	74 16                	je     8005f5 <umain+0x577>
			panic("read /big from %d returned bad data %d",
  8005df:	83 ec 0c             	sub    $0xc,%esp
  8005e2:	50                   	push   %eax
  8005e3:	53                   	push   %ebx
  8005e4:	68 94 27 80 00       	push   $0x802794
  8005e9:	6a 7b                	push   $0x7b
  8005eb:	68 45 24 80 00       	push   $0x802445
  8005f0:	e8 93 00 00 00       	call   800688 <_panic>
  8005f5:	8d 83 00 02 00 00    	lea    0x200(%ebx),%eax
  8005fb:	89 c3                	mov    %eax,%ebx
	}
	close(f);

	if ((f = open("/big", O_RDONLY)) < 0)
		panic("open /big: %e", f);
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  8005fd:	3d 00 e0 01 00       	cmp    $0x1e000,%eax
  800602:	0f 85 79 ff ff ff    	jne    800581 <umain+0x503>
			      i, r, sizeof(buf));
		if (*(int*)buf != i)
			panic("read /big from %d returned bad data %d",
			      i, *(int*)buf);
	}
	close(f);
  800608:	83 ec 0c             	sub    $0xc,%esp
  80060b:	56                   	push   %esi
  80060c:	e8 12 10 00 00       	call   801623 <close>
	cprintf("large file is good\n");
  800611:	c7 04 24 c9 25 80 00 	movl   $0x8025c9,(%esp)
  800618:	e8 44 01 00 00       	call   800761 <cprintf>
}
  80061d:	83 c4 10             	add    $0x10,%esp
  800620:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800623:	5b                   	pop    %ebx
  800624:	5e                   	pop    %esi
  800625:	5f                   	pop    %edi
  800626:	5d                   	pop    %ebp
  800627:	c3                   	ret    

00800628 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800628:	55                   	push   %ebp
  800629:	89 e5                	mov    %esp,%ebp
  80062b:	56                   	push   %esi
  80062c:	53                   	push   %ebx
  80062d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800630:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	envid_t envid = sys_getenvid();
  800633:	e8 1a 0b 00 00       	call   801152 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  800638:	25 ff 03 00 00       	and    $0x3ff,%eax
  80063d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800640:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800645:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80064a:	85 db                	test   %ebx,%ebx
  80064c:	7e 07                	jle    800655 <libmain+0x2d>
		binaryname = argv[0];
  80064e:	8b 06                	mov    (%esi),%eax
  800650:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  800655:	83 ec 08             	sub    $0x8,%esp
  800658:	56                   	push   %esi
  800659:	53                   	push   %ebx
  80065a:	e8 1f fa ff ff       	call   80007e <umain>

	// exit gracefully
	exit();
  80065f:	e8 0a 00 00 00       	call   80066e <exit>
}
  800664:	83 c4 10             	add    $0x10,%esp
  800667:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80066a:	5b                   	pop    %ebx
  80066b:	5e                   	pop    %esi
  80066c:	5d                   	pop    %ebp
  80066d:	c3                   	ret    

0080066e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80066e:	55                   	push   %ebp
  80066f:	89 e5                	mov    %esp,%ebp
  800671:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800674:	e8 d5 0f 00 00       	call   80164e <close_all>
	sys_env_destroy(0);
  800679:	83 ec 0c             	sub    $0xc,%esp
  80067c:	6a 00                	push   $0x0
  80067e:	e8 8e 0a 00 00       	call   801111 <sys_env_destroy>
}
  800683:	83 c4 10             	add    $0x10,%esp
  800686:	c9                   	leave  
  800687:	c3                   	ret    

00800688 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800688:	55                   	push   %ebp
  800689:	89 e5                	mov    %esp,%ebp
  80068b:	56                   	push   %esi
  80068c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80068d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800690:	8b 35 04 30 80 00    	mov    0x803004,%esi
  800696:	e8 b7 0a 00 00       	call   801152 <sys_getenvid>
  80069b:	83 ec 0c             	sub    $0xc,%esp
  80069e:	ff 75 0c             	pushl  0xc(%ebp)
  8006a1:	ff 75 08             	pushl  0x8(%ebp)
  8006a4:	56                   	push   %esi
  8006a5:	50                   	push   %eax
  8006a6:	68 ec 27 80 00       	push   $0x8027ec
  8006ab:	e8 b1 00 00 00       	call   800761 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8006b0:	83 c4 18             	add    $0x18,%esp
  8006b3:	53                   	push   %ebx
  8006b4:	ff 75 10             	pushl  0x10(%ebp)
  8006b7:	e8 54 00 00 00       	call   800710 <vcprintf>
	cprintf("\n");
  8006bc:	c7 04 24 5d 2c 80 00 	movl   $0x802c5d,(%esp)
  8006c3:	e8 99 00 00 00       	call   800761 <cprintf>
  8006c8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8006cb:	cc                   	int3   
  8006cc:	eb fd                	jmp    8006cb <_panic+0x43>

008006ce <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8006ce:	55                   	push   %ebp
  8006cf:	89 e5                	mov    %esp,%ebp
  8006d1:	53                   	push   %ebx
  8006d2:	83 ec 04             	sub    $0x4,%esp
  8006d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8006d8:	8b 13                	mov    (%ebx),%edx
  8006da:	8d 42 01             	lea    0x1(%edx),%eax
  8006dd:	89 03                	mov    %eax,(%ebx)
  8006df:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006e2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8006e6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8006eb:	75 1a                	jne    800707 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8006ed:	83 ec 08             	sub    $0x8,%esp
  8006f0:	68 ff 00 00 00       	push   $0xff
  8006f5:	8d 43 08             	lea    0x8(%ebx),%eax
  8006f8:	50                   	push   %eax
  8006f9:	e8 d6 09 00 00       	call   8010d4 <sys_cputs>
		b->idx = 0;
  8006fe:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800704:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800707:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80070b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80070e:	c9                   	leave  
  80070f:	c3                   	ret    

00800710 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800710:	55                   	push   %ebp
  800711:	89 e5                	mov    %esp,%ebp
  800713:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800719:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800720:	00 00 00 
	b.cnt = 0;
  800723:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80072a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80072d:	ff 75 0c             	pushl  0xc(%ebp)
  800730:	ff 75 08             	pushl  0x8(%ebp)
  800733:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800739:	50                   	push   %eax
  80073a:	68 ce 06 80 00       	push   $0x8006ce
  80073f:	e8 1a 01 00 00       	call   80085e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800744:	83 c4 08             	add    $0x8,%esp
  800747:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80074d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800753:	50                   	push   %eax
  800754:	e8 7b 09 00 00       	call   8010d4 <sys_cputs>

	return b.cnt;
}
  800759:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80075f:	c9                   	leave  
  800760:	c3                   	ret    

00800761 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800761:	55                   	push   %ebp
  800762:	89 e5                	mov    %esp,%ebp
  800764:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800767:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80076a:	50                   	push   %eax
  80076b:	ff 75 08             	pushl  0x8(%ebp)
  80076e:	e8 9d ff ff ff       	call   800710 <vcprintf>
	va_end(ap);

	return cnt;
}
  800773:	c9                   	leave  
  800774:	c3                   	ret    

00800775 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800775:	55                   	push   %ebp
  800776:	89 e5                	mov    %esp,%ebp
  800778:	57                   	push   %edi
  800779:	56                   	push   %esi
  80077a:	53                   	push   %ebx
  80077b:	83 ec 1c             	sub    $0x1c,%esp
  80077e:	89 c7                	mov    %eax,%edi
  800780:	89 d6                	mov    %edx,%esi
  800782:	8b 45 08             	mov    0x8(%ebp),%eax
  800785:	8b 55 0c             	mov    0xc(%ebp),%edx
  800788:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80078b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80078e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800791:	bb 00 00 00 00       	mov    $0x0,%ebx
  800796:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800799:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80079c:	39 d3                	cmp    %edx,%ebx
  80079e:	72 05                	jb     8007a5 <printnum+0x30>
  8007a0:	39 45 10             	cmp    %eax,0x10(%ebp)
  8007a3:	77 45                	ja     8007ea <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8007a5:	83 ec 0c             	sub    $0xc,%esp
  8007a8:	ff 75 18             	pushl  0x18(%ebp)
  8007ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ae:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8007b1:	53                   	push   %ebx
  8007b2:	ff 75 10             	pushl  0x10(%ebp)
  8007b5:	83 ec 08             	sub    $0x8,%esp
  8007b8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8007bb:	ff 75 e0             	pushl  -0x20(%ebp)
  8007be:	ff 75 dc             	pushl  -0x24(%ebp)
  8007c1:	ff 75 d8             	pushl  -0x28(%ebp)
  8007c4:	e8 b7 19 00 00       	call   802180 <__udivdi3>
  8007c9:	83 c4 18             	add    $0x18,%esp
  8007cc:	52                   	push   %edx
  8007cd:	50                   	push   %eax
  8007ce:	89 f2                	mov    %esi,%edx
  8007d0:	89 f8                	mov    %edi,%eax
  8007d2:	e8 9e ff ff ff       	call   800775 <printnum>
  8007d7:	83 c4 20             	add    $0x20,%esp
  8007da:	eb 18                	jmp    8007f4 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8007dc:	83 ec 08             	sub    $0x8,%esp
  8007df:	56                   	push   %esi
  8007e0:	ff 75 18             	pushl  0x18(%ebp)
  8007e3:	ff d7                	call   *%edi
  8007e5:	83 c4 10             	add    $0x10,%esp
  8007e8:	eb 03                	jmp    8007ed <printnum+0x78>
  8007ea:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8007ed:	83 eb 01             	sub    $0x1,%ebx
  8007f0:	85 db                	test   %ebx,%ebx
  8007f2:	7f e8                	jg     8007dc <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8007f4:	83 ec 08             	sub    $0x8,%esp
  8007f7:	56                   	push   %esi
  8007f8:	83 ec 04             	sub    $0x4,%esp
  8007fb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8007fe:	ff 75 e0             	pushl  -0x20(%ebp)
  800801:	ff 75 dc             	pushl  -0x24(%ebp)
  800804:	ff 75 d8             	pushl  -0x28(%ebp)
  800807:	e8 a4 1a 00 00       	call   8022b0 <__umoddi3>
  80080c:	83 c4 14             	add    $0x14,%esp
  80080f:	0f be 80 0f 28 80 00 	movsbl 0x80280f(%eax),%eax
  800816:	50                   	push   %eax
  800817:	ff d7                	call   *%edi
}
  800819:	83 c4 10             	add    $0x10,%esp
  80081c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80081f:	5b                   	pop    %ebx
  800820:	5e                   	pop    %esi
  800821:	5f                   	pop    %edi
  800822:	5d                   	pop    %ebp
  800823:	c3                   	ret    

00800824 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800824:	55                   	push   %ebp
  800825:	89 e5                	mov    %esp,%ebp
  800827:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80082a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80082e:	8b 10                	mov    (%eax),%edx
  800830:	3b 50 04             	cmp    0x4(%eax),%edx
  800833:	73 0a                	jae    80083f <sprintputch+0x1b>
		*b->buf++ = ch;
  800835:	8d 4a 01             	lea    0x1(%edx),%ecx
  800838:	89 08                	mov    %ecx,(%eax)
  80083a:	8b 45 08             	mov    0x8(%ebp),%eax
  80083d:	88 02                	mov    %al,(%edx)
}
  80083f:	5d                   	pop    %ebp
  800840:	c3                   	ret    

00800841 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800841:	55                   	push   %ebp
  800842:	89 e5                	mov    %esp,%ebp
  800844:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800847:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80084a:	50                   	push   %eax
  80084b:	ff 75 10             	pushl  0x10(%ebp)
  80084e:	ff 75 0c             	pushl  0xc(%ebp)
  800851:	ff 75 08             	pushl  0x8(%ebp)
  800854:	e8 05 00 00 00       	call   80085e <vprintfmt>
	va_end(ap);
}
  800859:	83 c4 10             	add    $0x10,%esp
  80085c:	c9                   	leave  
  80085d:	c3                   	ret    

0080085e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80085e:	55                   	push   %ebp
  80085f:	89 e5                	mov    %esp,%ebp
  800861:	57                   	push   %edi
  800862:	56                   	push   %esi
  800863:	53                   	push   %ebx
  800864:	83 ec 2c             	sub    $0x2c,%esp
  800867:	8b 75 08             	mov    0x8(%ebp),%esi
  80086a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80086d:	8b 7d 10             	mov    0x10(%ebp),%edi
  800870:	eb 12                	jmp    800884 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800872:	85 c0                	test   %eax,%eax
  800874:	0f 84 6a 04 00 00    	je     800ce4 <vprintfmt+0x486>
				return;
			putch(ch, putdat);
  80087a:	83 ec 08             	sub    $0x8,%esp
  80087d:	53                   	push   %ebx
  80087e:	50                   	push   %eax
  80087f:	ff d6                	call   *%esi
  800881:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800884:	83 c7 01             	add    $0x1,%edi
  800887:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80088b:	83 f8 25             	cmp    $0x25,%eax
  80088e:	75 e2                	jne    800872 <vprintfmt+0x14>
  800890:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800894:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80089b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8008a2:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8008a9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008ae:	eb 07                	jmp    8008b7 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8008b3:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008b7:	8d 47 01             	lea    0x1(%edi),%eax
  8008ba:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8008bd:	0f b6 07             	movzbl (%edi),%eax
  8008c0:	0f b6 d0             	movzbl %al,%edx
  8008c3:	83 e8 23             	sub    $0x23,%eax
  8008c6:	3c 55                	cmp    $0x55,%al
  8008c8:	0f 87 fb 03 00 00    	ja     800cc9 <vprintfmt+0x46b>
  8008ce:	0f b6 c0             	movzbl %al,%eax
  8008d1:	ff 24 85 60 29 80 00 	jmp    *0x802960(,%eax,4)
  8008d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8008db:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8008df:	eb d6                	jmp    8008b7 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008e4:	b8 00 00 00 00       	mov    $0x0,%eax
  8008e9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8008ec:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8008ef:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8008f3:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8008f6:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8008f9:	83 f9 09             	cmp    $0x9,%ecx
  8008fc:	77 3f                	ja     80093d <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8008fe:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800901:	eb e9                	jmp    8008ec <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800903:	8b 45 14             	mov    0x14(%ebp),%eax
  800906:	8b 00                	mov    (%eax),%eax
  800908:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80090b:	8b 45 14             	mov    0x14(%ebp),%eax
  80090e:	8d 40 04             	lea    0x4(%eax),%eax
  800911:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800914:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800917:	eb 2a                	jmp    800943 <vprintfmt+0xe5>
  800919:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80091c:	85 c0                	test   %eax,%eax
  80091e:	ba 00 00 00 00       	mov    $0x0,%edx
  800923:	0f 49 d0             	cmovns %eax,%edx
  800926:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800929:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80092c:	eb 89                	jmp    8008b7 <vprintfmt+0x59>
  80092e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800931:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800938:	e9 7a ff ff ff       	jmp    8008b7 <vprintfmt+0x59>
  80093d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800940:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800943:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800947:	0f 89 6a ff ff ff    	jns    8008b7 <vprintfmt+0x59>
				width = precision, precision = -1;
  80094d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800950:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800953:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80095a:	e9 58 ff ff ff       	jmp    8008b7 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80095f:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800962:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800965:	e9 4d ff ff ff       	jmp    8008b7 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80096a:	8b 45 14             	mov    0x14(%ebp),%eax
  80096d:	8d 78 04             	lea    0x4(%eax),%edi
  800970:	83 ec 08             	sub    $0x8,%esp
  800973:	53                   	push   %ebx
  800974:	ff 30                	pushl  (%eax)
  800976:	ff d6                	call   *%esi
			break;
  800978:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80097b:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80097e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800981:	e9 fe fe ff ff       	jmp    800884 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800986:	8b 45 14             	mov    0x14(%ebp),%eax
  800989:	8d 78 04             	lea    0x4(%eax),%edi
  80098c:	8b 00                	mov    (%eax),%eax
  80098e:	99                   	cltd   
  80098f:	31 d0                	xor    %edx,%eax
  800991:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800993:	83 f8 0f             	cmp    $0xf,%eax
  800996:	7f 0b                	jg     8009a3 <vprintfmt+0x145>
  800998:	8b 14 85 c0 2a 80 00 	mov    0x802ac0(,%eax,4),%edx
  80099f:	85 d2                	test   %edx,%edx
  8009a1:	75 1b                	jne    8009be <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  8009a3:	50                   	push   %eax
  8009a4:	68 27 28 80 00       	push   $0x802827
  8009a9:	53                   	push   %ebx
  8009aa:	56                   	push   %esi
  8009ab:	e8 91 fe ff ff       	call   800841 <printfmt>
  8009b0:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8009b3:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8009b9:	e9 c6 fe ff ff       	jmp    800884 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8009be:	52                   	push   %edx
  8009bf:	68 36 2c 80 00       	push   $0x802c36
  8009c4:	53                   	push   %ebx
  8009c5:	56                   	push   %esi
  8009c6:	e8 76 fe ff ff       	call   800841 <printfmt>
  8009cb:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8009ce:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8009d4:	e9 ab fe ff ff       	jmp    800884 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8009d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8009dc:	83 c0 04             	add    $0x4,%eax
  8009df:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8009e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8009e5:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8009e7:	85 ff                	test   %edi,%edi
  8009e9:	b8 20 28 80 00       	mov    $0x802820,%eax
  8009ee:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8009f1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8009f5:	0f 8e 94 00 00 00    	jle    800a8f <vprintfmt+0x231>
  8009fb:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8009ff:	0f 84 98 00 00 00    	je     800a9d <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800a05:	83 ec 08             	sub    $0x8,%esp
  800a08:	ff 75 d0             	pushl  -0x30(%ebp)
  800a0b:	57                   	push   %edi
  800a0c:	e8 5b 03 00 00       	call   800d6c <strnlen>
  800a11:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800a14:	29 c1                	sub    %eax,%ecx
  800a16:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800a19:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800a1c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800a20:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a23:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800a26:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a28:	eb 0f                	jmp    800a39 <vprintfmt+0x1db>
					putch(padc, putdat);
  800a2a:	83 ec 08             	sub    $0x8,%esp
  800a2d:	53                   	push   %ebx
  800a2e:	ff 75 e0             	pushl  -0x20(%ebp)
  800a31:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a33:	83 ef 01             	sub    $0x1,%edi
  800a36:	83 c4 10             	add    $0x10,%esp
  800a39:	85 ff                	test   %edi,%edi
  800a3b:	7f ed                	jg     800a2a <vprintfmt+0x1cc>
  800a3d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800a40:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800a43:	85 c9                	test   %ecx,%ecx
  800a45:	b8 00 00 00 00       	mov    $0x0,%eax
  800a4a:	0f 49 c1             	cmovns %ecx,%eax
  800a4d:	29 c1                	sub    %eax,%ecx
  800a4f:	89 75 08             	mov    %esi,0x8(%ebp)
  800a52:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a55:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a58:	89 cb                	mov    %ecx,%ebx
  800a5a:	eb 4d                	jmp    800aa9 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800a5c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800a60:	74 1b                	je     800a7d <vprintfmt+0x21f>
  800a62:	0f be c0             	movsbl %al,%eax
  800a65:	83 e8 20             	sub    $0x20,%eax
  800a68:	83 f8 5e             	cmp    $0x5e,%eax
  800a6b:	76 10                	jbe    800a7d <vprintfmt+0x21f>
					putch('?', putdat);
  800a6d:	83 ec 08             	sub    $0x8,%esp
  800a70:	ff 75 0c             	pushl  0xc(%ebp)
  800a73:	6a 3f                	push   $0x3f
  800a75:	ff 55 08             	call   *0x8(%ebp)
  800a78:	83 c4 10             	add    $0x10,%esp
  800a7b:	eb 0d                	jmp    800a8a <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  800a7d:	83 ec 08             	sub    $0x8,%esp
  800a80:	ff 75 0c             	pushl  0xc(%ebp)
  800a83:	52                   	push   %edx
  800a84:	ff 55 08             	call   *0x8(%ebp)
  800a87:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a8a:	83 eb 01             	sub    $0x1,%ebx
  800a8d:	eb 1a                	jmp    800aa9 <vprintfmt+0x24b>
  800a8f:	89 75 08             	mov    %esi,0x8(%ebp)
  800a92:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a95:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a98:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800a9b:	eb 0c                	jmp    800aa9 <vprintfmt+0x24b>
  800a9d:	89 75 08             	mov    %esi,0x8(%ebp)
  800aa0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800aa3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800aa6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800aa9:	83 c7 01             	add    $0x1,%edi
  800aac:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800ab0:	0f be d0             	movsbl %al,%edx
  800ab3:	85 d2                	test   %edx,%edx
  800ab5:	74 23                	je     800ada <vprintfmt+0x27c>
  800ab7:	85 f6                	test   %esi,%esi
  800ab9:	78 a1                	js     800a5c <vprintfmt+0x1fe>
  800abb:	83 ee 01             	sub    $0x1,%esi
  800abe:	79 9c                	jns    800a5c <vprintfmt+0x1fe>
  800ac0:	89 df                	mov    %ebx,%edi
  800ac2:	8b 75 08             	mov    0x8(%ebp),%esi
  800ac5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ac8:	eb 18                	jmp    800ae2 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800aca:	83 ec 08             	sub    $0x8,%esp
  800acd:	53                   	push   %ebx
  800ace:	6a 20                	push   $0x20
  800ad0:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800ad2:	83 ef 01             	sub    $0x1,%edi
  800ad5:	83 c4 10             	add    $0x10,%esp
  800ad8:	eb 08                	jmp    800ae2 <vprintfmt+0x284>
  800ada:	89 df                	mov    %ebx,%edi
  800adc:	8b 75 08             	mov    0x8(%ebp),%esi
  800adf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ae2:	85 ff                	test   %edi,%edi
  800ae4:	7f e4                	jg     800aca <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800ae6:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800ae9:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800aec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800aef:	e9 90 fd ff ff       	jmp    800884 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800af4:	83 f9 01             	cmp    $0x1,%ecx
  800af7:	7e 19                	jle    800b12 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800af9:	8b 45 14             	mov    0x14(%ebp),%eax
  800afc:	8b 50 04             	mov    0x4(%eax),%edx
  800aff:	8b 00                	mov    (%eax),%eax
  800b01:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b04:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800b07:	8b 45 14             	mov    0x14(%ebp),%eax
  800b0a:	8d 40 08             	lea    0x8(%eax),%eax
  800b0d:	89 45 14             	mov    %eax,0x14(%ebp)
  800b10:	eb 38                	jmp    800b4a <vprintfmt+0x2ec>
	else if (lflag)
  800b12:	85 c9                	test   %ecx,%ecx
  800b14:	74 1b                	je     800b31 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800b16:	8b 45 14             	mov    0x14(%ebp),%eax
  800b19:	8b 00                	mov    (%eax),%eax
  800b1b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b1e:	89 c1                	mov    %eax,%ecx
  800b20:	c1 f9 1f             	sar    $0x1f,%ecx
  800b23:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800b26:	8b 45 14             	mov    0x14(%ebp),%eax
  800b29:	8d 40 04             	lea    0x4(%eax),%eax
  800b2c:	89 45 14             	mov    %eax,0x14(%ebp)
  800b2f:	eb 19                	jmp    800b4a <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800b31:	8b 45 14             	mov    0x14(%ebp),%eax
  800b34:	8b 00                	mov    (%eax),%eax
  800b36:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b39:	89 c1                	mov    %eax,%ecx
  800b3b:	c1 f9 1f             	sar    $0x1f,%ecx
  800b3e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800b41:	8b 45 14             	mov    0x14(%ebp),%eax
  800b44:	8d 40 04             	lea    0x4(%eax),%eax
  800b47:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800b4a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800b4d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800b50:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800b55:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800b59:	0f 89 36 01 00 00    	jns    800c95 <vprintfmt+0x437>
				putch('-', putdat);
  800b5f:	83 ec 08             	sub    $0x8,%esp
  800b62:	53                   	push   %ebx
  800b63:	6a 2d                	push   $0x2d
  800b65:	ff d6                	call   *%esi
				num = -(long long) num;
  800b67:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800b6a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800b6d:	f7 da                	neg    %edx
  800b6f:	83 d1 00             	adc    $0x0,%ecx
  800b72:	f7 d9                	neg    %ecx
  800b74:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800b77:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b7c:	e9 14 01 00 00       	jmp    800c95 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800b81:	83 f9 01             	cmp    $0x1,%ecx
  800b84:	7e 18                	jle    800b9e <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800b86:	8b 45 14             	mov    0x14(%ebp),%eax
  800b89:	8b 10                	mov    (%eax),%edx
  800b8b:	8b 48 04             	mov    0x4(%eax),%ecx
  800b8e:	8d 40 08             	lea    0x8(%eax),%eax
  800b91:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800b94:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b99:	e9 f7 00 00 00       	jmp    800c95 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800b9e:	85 c9                	test   %ecx,%ecx
  800ba0:	74 1a                	je     800bbc <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  800ba2:	8b 45 14             	mov    0x14(%ebp),%eax
  800ba5:	8b 10                	mov    (%eax),%edx
  800ba7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bac:	8d 40 04             	lea    0x4(%eax),%eax
  800baf:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800bb2:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bb7:	e9 d9 00 00 00       	jmp    800c95 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800bbc:	8b 45 14             	mov    0x14(%ebp),%eax
  800bbf:	8b 10                	mov    (%eax),%edx
  800bc1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bc6:	8d 40 04             	lea    0x4(%eax),%eax
  800bc9:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800bcc:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bd1:	e9 bf 00 00 00       	jmp    800c95 <vprintfmt+0x437>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800bd6:	83 f9 01             	cmp    $0x1,%ecx
  800bd9:	7e 13                	jle    800bee <vprintfmt+0x390>
		return va_arg(*ap, long long);
  800bdb:	8b 45 14             	mov    0x14(%ebp),%eax
  800bde:	8b 50 04             	mov    0x4(%eax),%edx
  800be1:	8b 00                	mov    (%eax),%eax
  800be3:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800be6:	8d 49 08             	lea    0x8(%ecx),%ecx
  800be9:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800bec:	eb 28                	jmp    800c16 <vprintfmt+0x3b8>
	else if (lflag)
  800bee:	85 c9                	test   %ecx,%ecx
  800bf0:	74 13                	je     800c05 <vprintfmt+0x3a7>
		return va_arg(*ap, long);
  800bf2:	8b 45 14             	mov    0x14(%ebp),%eax
  800bf5:	8b 10                	mov    (%eax),%edx
  800bf7:	89 d0                	mov    %edx,%eax
  800bf9:	99                   	cltd   
  800bfa:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800bfd:	8d 49 04             	lea    0x4(%ecx),%ecx
  800c00:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800c03:	eb 11                	jmp    800c16 <vprintfmt+0x3b8>
	else
		return va_arg(*ap, int);
  800c05:	8b 45 14             	mov    0x14(%ebp),%eax
  800c08:	8b 10                	mov    (%eax),%edx
  800c0a:	89 d0                	mov    %edx,%eax
  800c0c:	99                   	cltd   
  800c0d:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800c10:	8d 49 04             	lea    0x4(%ecx),%ecx
  800c13:	89 4d 14             	mov    %ecx,0x14(%ebp)
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getint(&ap, lflag);
  800c16:	89 d1                	mov    %edx,%ecx
  800c18:	89 c2                	mov    %eax,%edx
			base = 8;
  800c1a:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800c1f:	eb 74                	jmp    800c95 <vprintfmt+0x437>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800c21:	83 ec 08             	sub    $0x8,%esp
  800c24:	53                   	push   %ebx
  800c25:	6a 30                	push   $0x30
  800c27:	ff d6                	call   *%esi
			putch('x', putdat);
  800c29:	83 c4 08             	add    $0x8,%esp
  800c2c:	53                   	push   %ebx
  800c2d:	6a 78                	push   $0x78
  800c2f:	ff d6                	call   *%esi
			num = (unsigned long long)
  800c31:	8b 45 14             	mov    0x14(%ebp),%eax
  800c34:	8b 10                	mov    (%eax),%edx
  800c36:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800c3b:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800c3e:	8d 40 04             	lea    0x4(%eax),%eax
  800c41:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800c44:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800c49:	eb 4a                	jmp    800c95 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800c4b:	83 f9 01             	cmp    $0x1,%ecx
  800c4e:	7e 15                	jle    800c65 <vprintfmt+0x407>
		return va_arg(*ap, unsigned long long);
  800c50:	8b 45 14             	mov    0x14(%ebp),%eax
  800c53:	8b 10                	mov    (%eax),%edx
  800c55:	8b 48 04             	mov    0x4(%eax),%ecx
  800c58:	8d 40 08             	lea    0x8(%eax),%eax
  800c5b:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800c5e:	b8 10 00 00 00       	mov    $0x10,%eax
  800c63:	eb 30                	jmp    800c95 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800c65:	85 c9                	test   %ecx,%ecx
  800c67:	74 17                	je     800c80 <vprintfmt+0x422>
		return va_arg(*ap, unsigned long);
  800c69:	8b 45 14             	mov    0x14(%ebp),%eax
  800c6c:	8b 10                	mov    (%eax),%edx
  800c6e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c73:	8d 40 04             	lea    0x4(%eax),%eax
  800c76:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800c79:	b8 10 00 00 00       	mov    $0x10,%eax
  800c7e:	eb 15                	jmp    800c95 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800c80:	8b 45 14             	mov    0x14(%ebp),%eax
  800c83:	8b 10                	mov    (%eax),%edx
  800c85:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c8a:	8d 40 04             	lea    0x4(%eax),%eax
  800c8d:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800c90:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800c95:	83 ec 0c             	sub    $0xc,%esp
  800c98:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800c9c:	57                   	push   %edi
  800c9d:	ff 75 e0             	pushl  -0x20(%ebp)
  800ca0:	50                   	push   %eax
  800ca1:	51                   	push   %ecx
  800ca2:	52                   	push   %edx
  800ca3:	89 da                	mov    %ebx,%edx
  800ca5:	89 f0                	mov    %esi,%eax
  800ca7:	e8 c9 fa ff ff       	call   800775 <printnum>
			break;
  800cac:	83 c4 20             	add    $0x20,%esp
  800caf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800cb2:	e9 cd fb ff ff       	jmp    800884 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800cb7:	83 ec 08             	sub    $0x8,%esp
  800cba:	53                   	push   %ebx
  800cbb:	52                   	push   %edx
  800cbc:	ff d6                	call   *%esi
			break;
  800cbe:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cc1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800cc4:	e9 bb fb ff ff       	jmp    800884 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800cc9:	83 ec 08             	sub    $0x8,%esp
  800ccc:	53                   	push   %ebx
  800ccd:	6a 25                	push   $0x25
  800ccf:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800cd1:	83 c4 10             	add    $0x10,%esp
  800cd4:	eb 03                	jmp    800cd9 <vprintfmt+0x47b>
  800cd6:	83 ef 01             	sub    $0x1,%edi
  800cd9:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800cdd:	75 f7                	jne    800cd6 <vprintfmt+0x478>
  800cdf:	e9 a0 fb ff ff       	jmp    800884 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800ce4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce7:	5b                   	pop    %ebx
  800ce8:	5e                   	pop    %esi
  800ce9:	5f                   	pop    %edi
  800cea:	5d                   	pop    %ebp
  800ceb:	c3                   	ret    

00800cec <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800cec:	55                   	push   %ebp
  800ced:	89 e5                	mov    %esp,%ebp
  800cef:	83 ec 18             	sub    $0x18,%esp
  800cf2:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf5:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800cf8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800cfb:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800cff:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800d02:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800d09:	85 c0                	test   %eax,%eax
  800d0b:	74 26                	je     800d33 <vsnprintf+0x47>
  800d0d:	85 d2                	test   %edx,%edx
  800d0f:	7e 22                	jle    800d33 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800d11:	ff 75 14             	pushl  0x14(%ebp)
  800d14:	ff 75 10             	pushl  0x10(%ebp)
  800d17:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800d1a:	50                   	push   %eax
  800d1b:	68 24 08 80 00       	push   $0x800824
  800d20:	e8 39 fb ff ff       	call   80085e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800d25:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800d28:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800d2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d2e:	83 c4 10             	add    $0x10,%esp
  800d31:	eb 05                	jmp    800d38 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800d33:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800d38:	c9                   	leave  
  800d39:	c3                   	ret    

00800d3a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800d3a:	55                   	push   %ebp
  800d3b:	89 e5                	mov    %esp,%ebp
  800d3d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800d40:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800d43:	50                   	push   %eax
  800d44:	ff 75 10             	pushl  0x10(%ebp)
  800d47:	ff 75 0c             	pushl  0xc(%ebp)
  800d4a:	ff 75 08             	pushl  0x8(%ebp)
  800d4d:	e8 9a ff ff ff       	call   800cec <vsnprintf>
	va_end(ap);

	return rc;
}
  800d52:	c9                   	leave  
  800d53:	c3                   	ret    

00800d54 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800d54:	55                   	push   %ebp
  800d55:	89 e5                	mov    %esp,%ebp
  800d57:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800d5a:	b8 00 00 00 00       	mov    $0x0,%eax
  800d5f:	eb 03                	jmp    800d64 <strlen+0x10>
		n++;
  800d61:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800d64:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800d68:	75 f7                	jne    800d61 <strlen+0xd>
		n++;
	return n;
}
  800d6a:	5d                   	pop    %ebp
  800d6b:	c3                   	ret    

00800d6c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800d6c:	55                   	push   %ebp
  800d6d:	89 e5                	mov    %esp,%ebp
  800d6f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d72:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d75:	ba 00 00 00 00       	mov    $0x0,%edx
  800d7a:	eb 03                	jmp    800d7f <strnlen+0x13>
		n++;
  800d7c:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d7f:	39 c2                	cmp    %eax,%edx
  800d81:	74 08                	je     800d8b <strnlen+0x1f>
  800d83:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800d87:	75 f3                	jne    800d7c <strnlen+0x10>
  800d89:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800d8b:	5d                   	pop    %ebp
  800d8c:	c3                   	ret    

00800d8d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800d8d:	55                   	push   %ebp
  800d8e:	89 e5                	mov    %esp,%ebp
  800d90:	53                   	push   %ebx
  800d91:	8b 45 08             	mov    0x8(%ebp),%eax
  800d94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800d97:	89 c2                	mov    %eax,%edx
  800d99:	83 c2 01             	add    $0x1,%edx
  800d9c:	83 c1 01             	add    $0x1,%ecx
  800d9f:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800da3:	88 5a ff             	mov    %bl,-0x1(%edx)
  800da6:	84 db                	test   %bl,%bl
  800da8:	75 ef                	jne    800d99 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800daa:	5b                   	pop    %ebx
  800dab:	5d                   	pop    %ebp
  800dac:	c3                   	ret    

00800dad <strcat>:

char *
strcat(char *dst, const char *src)
{
  800dad:	55                   	push   %ebp
  800dae:	89 e5                	mov    %esp,%ebp
  800db0:	53                   	push   %ebx
  800db1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800db4:	53                   	push   %ebx
  800db5:	e8 9a ff ff ff       	call   800d54 <strlen>
  800dba:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800dbd:	ff 75 0c             	pushl  0xc(%ebp)
  800dc0:	01 d8                	add    %ebx,%eax
  800dc2:	50                   	push   %eax
  800dc3:	e8 c5 ff ff ff       	call   800d8d <strcpy>
	return dst;
}
  800dc8:	89 d8                	mov    %ebx,%eax
  800dca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dcd:	c9                   	leave  
  800dce:	c3                   	ret    

00800dcf <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800dcf:	55                   	push   %ebp
  800dd0:	89 e5                	mov    %esp,%ebp
  800dd2:	56                   	push   %esi
  800dd3:	53                   	push   %ebx
  800dd4:	8b 75 08             	mov    0x8(%ebp),%esi
  800dd7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dda:	89 f3                	mov    %esi,%ebx
  800ddc:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ddf:	89 f2                	mov    %esi,%edx
  800de1:	eb 0f                	jmp    800df2 <strncpy+0x23>
		*dst++ = *src;
  800de3:	83 c2 01             	add    $0x1,%edx
  800de6:	0f b6 01             	movzbl (%ecx),%eax
  800de9:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800dec:	80 39 01             	cmpb   $0x1,(%ecx)
  800def:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800df2:	39 da                	cmp    %ebx,%edx
  800df4:	75 ed                	jne    800de3 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800df6:	89 f0                	mov    %esi,%eax
  800df8:	5b                   	pop    %ebx
  800df9:	5e                   	pop    %esi
  800dfa:	5d                   	pop    %ebp
  800dfb:	c3                   	ret    

00800dfc <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800dfc:	55                   	push   %ebp
  800dfd:	89 e5                	mov    %esp,%ebp
  800dff:	56                   	push   %esi
  800e00:	53                   	push   %ebx
  800e01:	8b 75 08             	mov    0x8(%ebp),%esi
  800e04:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e07:	8b 55 10             	mov    0x10(%ebp),%edx
  800e0a:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800e0c:	85 d2                	test   %edx,%edx
  800e0e:	74 21                	je     800e31 <strlcpy+0x35>
  800e10:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800e14:	89 f2                	mov    %esi,%edx
  800e16:	eb 09                	jmp    800e21 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800e18:	83 c2 01             	add    $0x1,%edx
  800e1b:	83 c1 01             	add    $0x1,%ecx
  800e1e:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800e21:	39 c2                	cmp    %eax,%edx
  800e23:	74 09                	je     800e2e <strlcpy+0x32>
  800e25:	0f b6 19             	movzbl (%ecx),%ebx
  800e28:	84 db                	test   %bl,%bl
  800e2a:	75 ec                	jne    800e18 <strlcpy+0x1c>
  800e2c:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800e2e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800e31:	29 f0                	sub    %esi,%eax
}
  800e33:	5b                   	pop    %ebx
  800e34:	5e                   	pop    %esi
  800e35:	5d                   	pop    %ebp
  800e36:	c3                   	ret    

00800e37 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800e37:	55                   	push   %ebp
  800e38:	89 e5                	mov    %esp,%ebp
  800e3a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e3d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800e40:	eb 06                	jmp    800e48 <strcmp+0x11>
		p++, q++;
  800e42:	83 c1 01             	add    $0x1,%ecx
  800e45:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800e48:	0f b6 01             	movzbl (%ecx),%eax
  800e4b:	84 c0                	test   %al,%al
  800e4d:	74 04                	je     800e53 <strcmp+0x1c>
  800e4f:	3a 02                	cmp    (%edx),%al
  800e51:	74 ef                	je     800e42 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800e53:	0f b6 c0             	movzbl %al,%eax
  800e56:	0f b6 12             	movzbl (%edx),%edx
  800e59:	29 d0                	sub    %edx,%eax
}
  800e5b:	5d                   	pop    %ebp
  800e5c:	c3                   	ret    

00800e5d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800e5d:	55                   	push   %ebp
  800e5e:	89 e5                	mov    %esp,%ebp
  800e60:	53                   	push   %ebx
  800e61:	8b 45 08             	mov    0x8(%ebp),%eax
  800e64:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e67:	89 c3                	mov    %eax,%ebx
  800e69:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800e6c:	eb 06                	jmp    800e74 <strncmp+0x17>
		n--, p++, q++;
  800e6e:	83 c0 01             	add    $0x1,%eax
  800e71:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800e74:	39 d8                	cmp    %ebx,%eax
  800e76:	74 15                	je     800e8d <strncmp+0x30>
  800e78:	0f b6 08             	movzbl (%eax),%ecx
  800e7b:	84 c9                	test   %cl,%cl
  800e7d:	74 04                	je     800e83 <strncmp+0x26>
  800e7f:	3a 0a                	cmp    (%edx),%cl
  800e81:	74 eb                	je     800e6e <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800e83:	0f b6 00             	movzbl (%eax),%eax
  800e86:	0f b6 12             	movzbl (%edx),%edx
  800e89:	29 d0                	sub    %edx,%eax
  800e8b:	eb 05                	jmp    800e92 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800e8d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800e92:	5b                   	pop    %ebx
  800e93:	5d                   	pop    %ebp
  800e94:	c3                   	ret    

00800e95 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e95:	55                   	push   %ebp
  800e96:	89 e5                	mov    %esp,%ebp
  800e98:	8b 45 08             	mov    0x8(%ebp),%eax
  800e9b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e9f:	eb 07                	jmp    800ea8 <strchr+0x13>
		if (*s == c)
  800ea1:	38 ca                	cmp    %cl,%dl
  800ea3:	74 0f                	je     800eb4 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ea5:	83 c0 01             	add    $0x1,%eax
  800ea8:	0f b6 10             	movzbl (%eax),%edx
  800eab:	84 d2                	test   %dl,%dl
  800ead:	75 f2                	jne    800ea1 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800eaf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800eb4:	5d                   	pop    %ebp
  800eb5:	c3                   	ret    

00800eb6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800eb6:	55                   	push   %ebp
  800eb7:	89 e5                	mov    %esp,%ebp
  800eb9:	8b 45 08             	mov    0x8(%ebp),%eax
  800ebc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ec0:	eb 03                	jmp    800ec5 <strfind+0xf>
  800ec2:	83 c0 01             	add    $0x1,%eax
  800ec5:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800ec8:	38 ca                	cmp    %cl,%dl
  800eca:	74 04                	je     800ed0 <strfind+0x1a>
  800ecc:	84 d2                	test   %dl,%dl
  800ece:	75 f2                	jne    800ec2 <strfind+0xc>
			break;
	return (char *) s;
}
  800ed0:	5d                   	pop    %ebp
  800ed1:	c3                   	ret    

00800ed2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ed2:	55                   	push   %ebp
  800ed3:	89 e5                	mov    %esp,%ebp
  800ed5:	57                   	push   %edi
  800ed6:	56                   	push   %esi
  800ed7:	53                   	push   %ebx
  800ed8:	8b 7d 08             	mov    0x8(%ebp),%edi
  800edb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ede:	85 c9                	test   %ecx,%ecx
  800ee0:	74 36                	je     800f18 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ee2:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ee8:	75 28                	jne    800f12 <memset+0x40>
  800eea:	f6 c1 03             	test   $0x3,%cl
  800eed:	75 23                	jne    800f12 <memset+0x40>
		c &= 0xFF;
  800eef:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ef3:	89 d3                	mov    %edx,%ebx
  800ef5:	c1 e3 08             	shl    $0x8,%ebx
  800ef8:	89 d6                	mov    %edx,%esi
  800efa:	c1 e6 18             	shl    $0x18,%esi
  800efd:	89 d0                	mov    %edx,%eax
  800eff:	c1 e0 10             	shl    $0x10,%eax
  800f02:	09 f0                	or     %esi,%eax
  800f04:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800f06:	89 d8                	mov    %ebx,%eax
  800f08:	09 d0                	or     %edx,%eax
  800f0a:	c1 e9 02             	shr    $0x2,%ecx
  800f0d:	fc                   	cld    
  800f0e:	f3 ab                	rep stos %eax,%es:(%edi)
  800f10:	eb 06                	jmp    800f18 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800f12:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f15:	fc                   	cld    
  800f16:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800f18:	89 f8                	mov    %edi,%eax
  800f1a:	5b                   	pop    %ebx
  800f1b:	5e                   	pop    %esi
  800f1c:	5f                   	pop    %edi
  800f1d:	5d                   	pop    %ebp
  800f1e:	c3                   	ret    

00800f1f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800f1f:	55                   	push   %ebp
  800f20:	89 e5                	mov    %esp,%ebp
  800f22:	57                   	push   %edi
  800f23:	56                   	push   %esi
  800f24:	8b 45 08             	mov    0x8(%ebp),%eax
  800f27:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f2a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800f2d:	39 c6                	cmp    %eax,%esi
  800f2f:	73 35                	jae    800f66 <memmove+0x47>
  800f31:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800f34:	39 d0                	cmp    %edx,%eax
  800f36:	73 2e                	jae    800f66 <memmove+0x47>
		s += n;
		d += n;
  800f38:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f3b:	89 d6                	mov    %edx,%esi
  800f3d:	09 fe                	or     %edi,%esi
  800f3f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800f45:	75 13                	jne    800f5a <memmove+0x3b>
  800f47:	f6 c1 03             	test   $0x3,%cl
  800f4a:	75 0e                	jne    800f5a <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800f4c:	83 ef 04             	sub    $0x4,%edi
  800f4f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800f52:	c1 e9 02             	shr    $0x2,%ecx
  800f55:	fd                   	std    
  800f56:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f58:	eb 09                	jmp    800f63 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800f5a:	83 ef 01             	sub    $0x1,%edi
  800f5d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800f60:	fd                   	std    
  800f61:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800f63:	fc                   	cld    
  800f64:	eb 1d                	jmp    800f83 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f66:	89 f2                	mov    %esi,%edx
  800f68:	09 c2                	or     %eax,%edx
  800f6a:	f6 c2 03             	test   $0x3,%dl
  800f6d:	75 0f                	jne    800f7e <memmove+0x5f>
  800f6f:	f6 c1 03             	test   $0x3,%cl
  800f72:	75 0a                	jne    800f7e <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800f74:	c1 e9 02             	shr    $0x2,%ecx
  800f77:	89 c7                	mov    %eax,%edi
  800f79:	fc                   	cld    
  800f7a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f7c:	eb 05                	jmp    800f83 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800f7e:	89 c7                	mov    %eax,%edi
  800f80:	fc                   	cld    
  800f81:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800f83:	5e                   	pop    %esi
  800f84:	5f                   	pop    %edi
  800f85:	5d                   	pop    %ebp
  800f86:	c3                   	ret    

00800f87 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800f87:	55                   	push   %ebp
  800f88:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800f8a:	ff 75 10             	pushl  0x10(%ebp)
  800f8d:	ff 75 0c             	pushl  0xc(%ebp)
  800f90:	ff 75 08             	pushl  0x8(%ebp)
  800f93:	e8 87 ff ff ff       	call   800f1f <memmove>
}
  800f98:	c9                   	leave  
  800f99:	c3                   	ret    

00800f9a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800f9a:	55                   	push   %ebp
  800f9b:	89 e5                	mov    %esp,%ebp
  800f9d:	56                   	push   %esi
  800f9e:	53                   	push   %ebx
  800f9f:	8b 45 08             	mov    0x8(%ebp),%eax
  800fa2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fa5:	89 c6                	mov    %eax,%esi
  800fa7:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800faa:	eb 1a                	jmp    800fc6 <memcmp+0x2c>
		if (*s1 != *s2)
  800fac:	0f b6 08             	movzbl (%eax),%ecx
  800faf:	0f b6 1a             	movzbl (%edx),%ebx
  800fb2:	38 d9                	cmp    %bl,%cl
  800fb4:	74 0a                	je     800fc0 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800fb6:	0f b6 c1             	movzbl %cl,%eax
  800fb9:	0f b6 db             	movzbl %bl,%ebx
  800fbc:	29 d8                	sub    %ebx,%eax
  800fbe:	eb 0f                	jmp    800fcf <memcmp+0x35>
		s1++, s2++;
  800fc0:	83 c0 01             	add    $0x1,%eax
  800fc3:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800fc6:	39 f0                	cmp    %esi,%eax
  800fc8:	75 e2                	jne    800fac <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800fca:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800fcf:	5b                   	pop    %ebx
  800fd0:	5e                   	pop    %esi
  800fd1:	5d                   	pop    %ebp
  800fd2:	c3                   	ret    

00800fd3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800fd3:	55                   	push   %ebp
  800fd4:	89 e5                	mov    %esp,%ebp
  800fd6:	53                   	push   %ebx
  800fd7:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800fda:	89 c1                	mov    %eax,%ecx
  800fdc:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800fdf:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800fe3:	eb 0a                	jmp    800fef <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800fe5:	0f b6 10             	movzbl (%eax),%edx
  800fe8:	39 da                	cmp    %ebx,%edx
  800fea:	74 07                	je     800ff3 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800fec:	83 c0 01             	add    $0x1,%eax
  800fef:	39 c8                	cmp    %ecx,%eax
  800ff1:	72 f2                	jb     800fe5 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ff3:	5b                   	pop    %ebx
  800ff4:	5d                   	pop    %ebp
  800ff5:	c3                   	ret    

00800ff6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ff6:	55                   	push   %ebp
  800ff7:	89 e5                	mov    %esp,%ebp
  800ff9:	57                   	push   %edi
  800ffa:	56                   	push   %esi
  800ffb:	53                   	push   %ebx
  800ffc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fff:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801002:	eb 03                	jmp    801007 <strtol+0x11>
		s++;
  801004:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801007:	0f b6 01             	movzbl (%ecx),%eax
  80100a:	3c 20                	cmp    $0x20,%al
  80100c:	74 f6                	je     801004 <strtol+0xe>
  80100e:	3c 09                	cmp    $0x9,%al
  801010:	74 f2                	je     801004 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801012:	3c 2b                	cmp    $0x2b,%al
  801014:	75 0a                	jne    801020 <strtol+0x2a>
		s++;
  801016:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801019:	bf 00 00 00 00       	mov    $0x0,%edi
  80101e:	eb 11                	jmp    801031 <strtol+0x3b>
  801020:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801025:	3c 2d                	cmp    $0x2d,%al
  801027:	75 08                	jne    801031 <strtol+0x3b>
		s++, neg = 1;
  801029:	83 c1 01             	add    $0x1,%ecx
  80102c:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801031:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801037:	75 15                	jne    80104e <strtol+0x58>
  801039:	80 39 30             	cmpb   $0x30,(%ecx)
  80103c:	75 10                	jne    80104e <strtol+0x58>
  80103e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801042:	75 7c                	jne    8010c0 <strtol+0xca>
		s += 2, base = 16;
  801044:	83 c1 02             	add    $0x2,%ecx
  801047:	bb 10 00 00 00       	mov    $0x10,%ebx
  80104c:	eb 16                	jmp    801064 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  80104e:	85 db                	test   %ebx,%ebx
  801050:	75 12                	jne    801064 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801052:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801057:	80 39 30             	cmpb   $0x30,(%ecx)
  80105a:	75 08                	jne    801064 <strtol+0x6e>
		s++, base = 8;
  80105c:	83 c1 01             	add    $0x1,%ecx
  80105f:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801064:	b8 00 00 00 00       	mov    $0x0,%eax
  801069:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  80106c:	0f b6 11             	movzbl (%ecx),%edx
  80106f:	8d 72 d0             	lea    -0x30(%edx),%esi
  801072:	89 f3                	mov    %esi,%ebx
  801074:	80 fb 09             	cmp    $0x9,%bl
  801077:	77 08                	ja     801081 <strtol+0x8b>
			dig = *s - '0';
  801079:	0f be d2             	movsbl %dl,%edx
  80107c:	83 ea 30             	sub    $0x30,%edx
  80107f:	eb 22                	jmp    8010a3 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801081:	8d 72 9f             	lea    -0x61(%edx),%esi
  801084:	89 f3                	mov    %esi,%ebx
  801086:	80 fb 19             	cmp    $0x19,%bl
  801089:	77 08                	ja     801093 <strtol+0x9d>
			dig = *s - 'a' + 10;
  80108b:	0f be d2             	movsbl %dl,%edx
  80108e:	83 ea 57             	sub    $0x57,%edx
  801091:	eb 10                	jmp    8010a3 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801093:	8d 72 bf             	lea    -0x41(%edx),%esi
  801096:	89 f3                	mov    %esi,%ebx
  801098:	80 fb 19             	cmp    $0x19,%bl
  80109b:	77 16                	ja     8010b3 <strtol+0xbd>
			dig = *s - 'A' + 10;
  80109d:	0f be d2             	movsbl %dl,%edx
  8010a0:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8010a3:	3b 55 10             	cmp    0x10(%ebp),%edx
  8010a6:	7d 0b                	jge    8010b3 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  8010a8:	83 c1 01             	add    $0x1,%ecx
  8010ab:	0f af 45 10          	imul   0x10(%ebp),%eax
  8010af:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8010b1:	eb b9                	jmp    80106c <strtol+0x76>

	if (endptr)
  8010b3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8010b7:	74 0d                	je     8010c6 <strtol+0xd0>
		*endptr = (char *) s;
  8010b9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010bc:	89 0e                	mov    %ecx,(%esi)
  8010be:	eb 06                	jmp    8010c6 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8010c0:	85 db                	test   %ebx,%ebx
  8010c2:	74 98                	je     80105c <strtol+0x66>
  8010c4:	eb 9e                	jmp    801064 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  8010c6:	89 c2                	mov    %eax,%edx
  8010c8:	f7 da                	neg    %edx
  8010ca:	85 ff                	test   %edi,%edi
  8010cc:	0f 45 c2             	cmovne %edx,%eax
}
  8010cf:	5b                   	pop    %ebx
  8010d0:	5e                   	pop    %esi
  8010d1:	5f                   	pop    %edi
  8010d2:	5d                   	pop    %ebp
  8010d3:	c3                   	ret    

008010d4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8010d4:	55                   	push   %ebp
  8010d5:	89 e5                	mov    %esp,%ebp
  8010d7:	57                   	push   %edi
  8010d8:	56                   	push   %esi
  8010d9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010da:	b8 00 00 00 00       	mov    $0x0,%eax
  8010df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010e2:	8b 55 08             	mov    0x8(%ebp),%edx
  8010e5:	89 c3                	mov    %eax,%ebx
  8010e7:	89 c7                	mov    %eax,%edi
  8010e9:	89 c6                	mov    %eax,%esi
  8010eb:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8010ed:	5b                   	pop    %ebx
  8010ee:	5e                   	pop    %esi
  8010ef:	5f                   	pop    %edi
  8010f0:	5d                   	pop    %ebp
  8010f1:	c3                   	ret    

008010f2 <sys_cgetc>:

int
sys_cgetc(void)
{
  8010f2:	55                   	push   %ebp
  8010f3:	89 e5                	mov    %esp,%ebp
  8010f5:	57                   	push   %edi
  8010f6:	56                   	push   %esi
  8010f7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8010fd:	b8 01 00 00 00       	mov    $0x1,%eax
  801102:	89 d1                	mov    %edx,%ecx
  801104:	89 d3                	mov    %edx,%ebx
  801106:	89 d7                	mov    %edx,%edi
  801108:	89 d6                	mov    %edx,%esi
  80110a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80110c:	5b                   	pop    %ebx
  80110d:	5e                   	pop    %esi
  80110e:	5f                   	pop    %edi
  80110f:	5d                   	pop    %ebp
  801110:	c3                   	ret    

00801111 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  801111:	55                   	push   %ebp
  801112:	89 e5                	mov    %esp,%ebp
  801114:	57                   	push   %edi
  801115:	56                   	push   %esi
  801116:	53                   	push   %ebx
  801117:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80111a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80111f:	b8 03 00 00 00       	mov    $0x3,%eax
  801124:	8b 55 08             	mov    0x8(%ebp),%edx
  801127:	89 cb                	mov    %ecx,%ebx
  801129:	89 cf                	mov    %ecx,%edi
  80112b:	89 ce                	mov    %ecx,%esi
  80112d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80112f:	85 c0                	test   %eax,%eax
  801131:	7e 17                	jle    80114a <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801133:	83 ec 0c             	sub    $0xc,%esp
  801136:	50                   	push   %eax
  801137:	6a 03                	push   $0x3
  801139:	68 1f 2b 80 00       	push   $0x802b1f
  80113e:	6a 23                	push   $0x23
  801140:	68 3c 2b 80 00       	push   $0x802b3c
  801145:	e8 3e f5 ff ff       	call   800688 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80114a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80114d:	5b                   	pop    %ebx
  80114e:	5e                   	pop    %esi
  80114f:	5f                   	pop    %edi
  801150:	5d                   	pop    %ebp
  801151:	c3                   	ret    

00801152 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801152:	55                   	push   %ebp
  801153:	89 e5                	mov    %esp,%ebp
  801155:	57                   	push   %edi
  801156:	56                   	push   %esi
  801157:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801158:	ba 00 00 00 00       	mov    $0x0,%edx
  80115d:	b8 02 00 00 00       	mov    $0x2,%eax
  801162:	89 d1                	mov    %edx,%ecx
  801164:	89 d3                	mov    %edx,%ebx
  801166:	89 d7                	mov    %edx,%edi
  801168:	89 d6                	mov    %edx,%esi
  80116a:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80116c:	5b                   	pop    %ebx
  80116d:	5e                   	pop    %esi
  80116e:	5f                   	pop    %edi
  80116f:	5d                   	pop    %ebp
  801170:	c3                   	ret    

00801171 <sys_yield>:

void
sys_yield(void)
{
  801171:	55                   	push   %ebp
  801172:	89 e5                	mov    %esp,%ebp
  801174:	57                   	push   %edi
  801175:	56                   	push   %esi
  801176:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801177:	ba 00 00 00 00       	mov    $0x0,%edx
  80117c:	b8 0b 00 00 00       	mov    $0xb,%eax
  801181:	89 d1                	mov    %edx,%ecx
  801183:	89 d3                	mov    %edx,%ebx
  801185:	89 d7                	mov    %edx,%edi
  801187:	89 d6                	mov    %edx,%esi
  801189:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80118b:	5b                   	pop    %ebx
  80118c:	5e                   	pop    %esi
  80118d:	5f                   	pop    %edi
  80118e:	5d                   	pop    %ebp
  80118f:	c3                   	ret    

00801190 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801190:	55                   	push   %ebp
  801191:	89 e5                	mov    %esp,%ebp
  801193:	57                   	push   %edi
  801194:	56                   	push   %esi
  801195:	53                   	push   %ebx
  801196:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801199:	be 00 00 00 00       	mov    $0x0,%esi
  80119e:	b8 04 00 00 00       	mov    $0x4,%eax
  8011a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8011a9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011ac:	89 f7                	mov    %esi,%edi
  8011ae:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8011b0:	85 c0                	test   %eax,%eax
  8011b2:	7e 17                	jle    8011cb <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011b4:	83 ec 0c             	sub    $0xc,%esp
  8011b7:	50                   	push   %eax
  8011b8:	6a 04                	push   $0x4
  8011ba:	68 1f 2b 80 00       	push   $0x802b1f
  8011bf:	6a 23                	push   $0x23
  8011c1:	68 3c 2b 80 00       	push   $0x802b3c
  8011c6:	e8 bd f4 ff ff       	call   800688 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8011cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011ce:	5b                   	pop    %ebx
  8011cf:	5e                   	pop    %esi
  8011d0:	5f                   	pop    %edi
  8011d1:	5d                   	pop    %ebp
  8011d2:	c3                   	ret    

008011d3 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8011d3:	55                   	push   %ebp
  8011d4:	89 e5                	mov    %esp,%ebp
  8011d6:	57                   	push   %edi
  8011d7:	56                   	push   %esi
  8011d8:	53                   	push   %ebx
  8011d9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011dc:	b8 05 00 00 00       	mov    $0x5,%eax
  8011e1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8011e7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011ea:	8b 7d 14             	mov    0x14(%ebp),%edi
  8011ed:	8b 75 18             	mov    0x18(%ebp),%esi
  8011f0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8011f2:	85 c0                	test   %eax,%eax
  8011f4:	7e 17                	jle    80120d <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011f6:	83 ec 0c             	sub    $0xc,%esp
  8011f9:	50                   	push   %eax
  8011fa:	6a 05                	push   $0x5
  8011fc:	68 1f 2b 80 00       	push   $0x802b1f
  801201:	6a 23                	push   $0x23
  801203:	68 3c 2b 80 00       	push   $0x802b3c
  801208:	e8 7b f4 ff ff       	call   800688 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80120d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801210:	5b                   	pop    %ebx
  801211:	5e                   	pop    %esi
  801212:	5f                   	pop    %edi
  801213:	5d                   	pop    %ebp
  801214:	c3                   	ret    

00801215 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801215:	55                   	push   %ebp
  801216:	89 e5                	mov    %esp,%ebp
  801218:	57                   	push   %edi
  801219:	56                   	push   %esi
  80121a:	53                   	push   %ebx
  80121b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80121e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801223:	b8 06 00 00 00       	mov    $0x6,%eax
  801228:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80122b:	8b 55 08             	mov    0x8(%ebp),%edx
  80122e:	89 df                	mov    %ebx,%edi
  801230:	89 de                	mov    %ebx,%esi
  801232:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801234:	85 c0                	test   %eax,%eax
  801236:	7e 17                	jle    80124f <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801238:	83 ec 0c             	sub    $0xc,%esp
  80123b:	50                   	push   %eax
  80123c:	6a 06                	push   $0x6
  80123e:	68 1f 2b 80 00       	push   $0x802b1f
  801243:	6a 23                	push   $0x23
  801245:	68 3c 2b 80 00       	push   $0x802b3c
  80124a:	e8 39 f4 ff ff       	call   800688 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80124f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801252:	5b                   	pop    %ebx
  801253:	5e                   	pop    %esi
  801254:	5f                   	pop    %edi
  801255:	5d                   	pop    %ebp
  801256:	c3                   	ret    

00801257 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801257:	55                   	push   %ebp
  801258:	89 e5                	mov    %esp,%ebp
  80125a:	57                   	push   %edi
  80125b:	56                   	push   %esi
  80125c:	53                   	push   %ebx
  80125d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801260:	bb 00 00 00 00       	mov    $0x0,%ebx
  801265:	b8 08 00 00 00       	mov    $0x8,%eax
  80126a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80126d:	8b 55 08             	mov    0x8(%ebp),%edx
  801270:	89 df                	mov    %ebx,%edi
  801272:	89 de                	mov    %ebx,%esi
  801274:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801276:	85 c0                	test   %eax,%eax
  801278:	7e 17                	jle    801291 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80127a:	83 ec 0c             	sub    $0xc,%esp
  80127d:	50                   	push   %eax
  80127e:	6a 08                	push   $0x8
  801280:	68 1f 2b 80 00       	push   $0x802b1f
  801285:	6a 23                	push   $0x23
  801287:	68 3c 2b 80 00       	push   $0x802b3c
  80128c:	e8 f7 f3 ff ff       	call   800688 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801291:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801294:	5b                   	pop    %ebx
  801295:	5e                   	pop    %esi
  801296:	5f                   	pop    %edi
  801297:	5d                   	pop    %ebp
  801298:	c3                   	ret    

00801299 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801299:	55                   	push   %ebp
  80129a:	89 e5                	mov    %esp,%ebp
  80129c:	57                   	push   %edi
  80129d:	56                   	push   %esi
  80129e:	53                   	push   %ebx
  80129f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012a2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012a7:	b8 09 00 00 00       	mov    $0x9,%eax
  8012ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012af:	8b 55 08             	mov    0x8(%ebp),%edx
  8012b2:	89 df                	mov    %ebx,%edi
  8012b4:	89 de                	mov    %ebx,%esi
  8012b6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8012b8:	85 c0                	test   %eax,%eax
  8012ba:	7e 17                	jle    8012d3 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012bc:	83 ec 0c             	sub    $0xc,%esp
  8012bf:	50                   	push   %eax
  8012c0:	6a 09                	push   $0x9
  8012c2:	68 1f 2b 80 00       	push   $0x802b1f
  8012c7:	6a 23                	push   $0x23
  8012c9:	68 3c 2b 80 00       	push   $0x802b3c
  8012ce:	e8 b5 f3 ff ff       	call   800688 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8012d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012d6:	5b                   	pop    %ebx
  8012d7:	5e                   	pop    %esi
  8012d8:	5f                   	pop    %edi
  8012d9:	5d                   	pop    %ebp
  8012da:	c3                   	ret    

008012db <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8012db:	55                   	push   %ebp
  8012dc:	89 e5                	mov    %esp,%ebp
  8012de:	57                   	push   %edi
  8012df:	56                   	push   %esi
  8012e0:	53                   	push   %ebx
  8012e1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012e4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012e9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8012ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012f1:	8b 55 08             	mov    0x8(%ebp),%edx
  8012f4:	89 df                	mov    %ebx,%edi
  8012f6:	89 de                	mov    %ebx,%esi
  8012f8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8012fa:	85 c0                	test   %eax,%eax
  8012fc:	7e 17                	jle    801315 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012fe:	83 ec 0c             	sub    $0xc,%esp
  801301:	50                   	push   %eax
  801302:	6a 0a                	push   $0xa
  801304:	68 1f 2b 80 00       	push   $0x802b1f
  801309:	6a 23                	push   $0x23
  80130b:	68 3c 2b 80 00       	push   $0x802b3c
  801310:	e8 73 f3 ff ff       	call   800688 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801315:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801318:	5b                   	pop    %ebx
  801319:	5e                   	pop    %esi
  80131a:	5f                   	pop    %edi
  80131b:	5d                   	pop    %ebp
  80131c:	c3                   	ret    

0080131d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80131d:	55                   	push   %ebp
  80131e:	89 e5                	mov    %esp,%ebp
  801320:	57                   	push   %edi
  801321:	56                   	push   %esi
  801322:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801323:	be 00 00 00 00       	mov    $0x0,%esi
  801328:	b8 0c 00 00 00       	mov    $0xc,%eax
  80132d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801330:	8b 55 08             	mov    0x8(%ebp),%edx
  801333:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801336:	8b 7d 14             	mov    0x14(%ebp),%edi
  801339:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80133b:	5b                   	pop    %ebx
  80133c:	5e                   	pop    %esi
  80133d:	5f                   	pop    %edi
  80133e:	5d                   	pop    %ebp
  80133f:	c3                   	ret    

00801340 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801340:	55                   	push   %ebp
  801341:	89 e5                	mov    %esp,%ebp
  801343:	57                   	push   %edi
  801344:	56                   	push   %esi
  801345:	53                   	push   %ebx
  801346:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801349:	b9 00 00 00 00       	mov    $0x0,%ecx
  80134e:	b8 0d 00 00 00       	mov    $0xd,%eax
  801353:	8b 55 08             	mov    0x8(%ebp),%edx
  801356:	89 cb                	mov    %ecx,%ebx
  801358:	89 cf                	mov    %ecx,%edi
  80135a:	89 ce                	mov    %ecx,%esi
  80135c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80135e:	85 c0                	test   %eax,%eax
  801360:	7e 17                	jle    801379 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801362:	83 ec 0c             	sub    $0xc,%esp
  801365:	50                   	push   %eax
  801366:	6a 0d                	push   $0xd
  801368:	68 1f 2b 80 00       	push   $0x802b1f
  80136d:	6a 23                	push   $0x23
  80136f:	68 3c 2b 80 00       	push   $0x802b3c
  801374:	e8 0f f3 ff ff       	call   800688 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801379:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80137c:	5b                   	pop    %ebx
  80137d:	5e                   	pop    %esi
  80137e:	5f                   	pop    %edi
  80137f:	5d                   	pop    %ebp
  801380:	c3                   	ret    

00801381 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801381:	55                   	push   %ebp
  801382:	89 e5                	mov    %esp,%ebp
  801384:	56                   	push   %esi
  801385:	53                   	push   %ebx
  801386:	8b 75 08             	mov    0x8(%ebp),%esi
  801389:	8b 45 0c             	mov    0xc(%ebp),%eax
  80138c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int ret;
	if (pg) ret = sys_ipc_recv(pg);
  80138f:	85 c0                	test   %eax,%eax
  801391:	74 0e                	je     8013a1 <ipc_recv+0x20>
  801393:	83 ec 0c             	sub    $0xc,%esp
  801396:	50                   	push   %eax
  801397:	e8 a4 ff ff ff       	call   801340 <sys_ipc_recv>
  80139c:	83 c4 10             	add    $0x10,%esp
  80139f:	eb 10                	jmp    8013b1 <ipc_recv+0x30>
	else ret = sys_ipc_recv((void*)UTOP);
  8013a1:	83 ec 0c             	sub    $0xc,%esp
  8013a4:	68 00 00 c0 ee       	push   $0xeec00000
  8013a9:	e8 92 ff ff ff       	call   801340 <sys_ipc_recv>
  8013ae:	83 c4 10             	add    $0x10,%esp
	if (ret) {
  8013b1:	85 c0                	test   %eax,%eax
  8013b3:	74 16                	je     8013cb <ipc_recv+0x4a>
		if (from_env_store) *from_env_store = 0;
  8013b5:	85 f6                	test   %esi,%esi
  8013b7:	74 06                	je     8013bf <ipc_recv+0x3e>
  8013b9:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  8013bf:	85 db                	test   %ebx,%ebx
  8013c1:	74 2c                	je     8013ef <ipc_recv+0x6e>
  8013c3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8013c9:	eb 24                	jmp    8013ef <ipc_recv+0x6e>
		return ret;
	}
	if (from_env_store) *from_env_store = thisenv->env_ipc_from;
  8013cb:	85 f6                	test   %esi,%esi
  8013cd:	74 0a                	je     8013d9 <ipc_recv+0x58>
  8013cf:	a1 04 40 80 00       	mov    0x804004,%eax
  8013d4:	8b 40 74             	mov    0x74(%eax),%eax
  8013d7:	89 06                	mov    %eax,(%esi)
	if (perm_store) *perm_store = thisenv->env_ipc_perm;
  8013d9:	85 db                	test   %ebx,%ebx
  8013db:	74 0a                	je     8013e7 <ipc_recv+0x66>
  8013dd:	a1 04 40 80 00       	mov    0x804004,%eax
  8013e2:	8b 40 78             	mov    0x78(%eax),%eax
  8013e5:	89 03                	mov    %eax,(%ebx)

	// panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8013e7:	a1 04 40 80 00       	mov    0x804004,%eax
  8013ec:	8b 40 70             	mov    0x70(%eax),%eax
}
  8013ef:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013f2:	5b                   	pop    %ebx
  8013f3:	5e                   	pop    %esi
  8013f4:	5d                   	pop    %ebp
  8013f5:	c3                   	ret    

008013f6 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8013f6:	55                   	push   %ebp
  8013f7:	89 e5                	mov    %esp,%ebp
  8013f9:	57                   	push   %edi
  8013fa:	56                   	push   %esi
  8013fb:	53                   	push   %ebx
  8013fc:	83 ec 0c             	sub    $0xc,%esp
  8013ff:	8b 7d 08             	mov    0x8(%ebp),%edi
  801402:	8b 75 0c             	mov    0xc(%ebp),%esi
  801405:	8b 45 10             	mov    0x10(%ebp),%eax
  801408:	85 c0                	test   %eax,%eax
  80140a:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  80140f:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	while (true) {
		void* srcva = (pg)? pg: (void*)UTOP;
		int ret = sys_ipc_try_send(to_env, val, srcva, perm);
  801412:	ff 75 14             	pushl  0x14(%ebp)
  801415:	53                   	push   %ebx
  801416:	56                   	push   %esi
  801417:	57                   	push   %edi
  801418:	e8 00 ff ff ff       	call   80131d <sys_ipc_try_send>
		if (ret == 0) break;
  80141d:	83 c4 10             	add    $0x10,%esp
  801420:	85 c0                	test   %eax,%eax
  801422:	74 1e                	je     801442 <ipc_send+0x4c>
		if (ret != -E_IPC_NOT_RECV) panic("ipc_send: %e", ret);
  801424:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801427:	74 12                	je     80143b <ipc_send+0x45>
  801429:	50                   	push   %eax
  80142a:	68 4a 2b 80 00       	push   $0x802b4a
  80142f:	6a 39                	push   $0x39
  801431:	68 57 2b 80 00       	push   $0x802b57
  801436:	e8 4d f2 ff ff       	call   800688 <_panic>
		sys_yield();
  80143b:	e8 31 fd ff ff       	call   801171 <sys_yield>
	}
  801440:	eb d0                	jmp    801412 <ipc_send+0x1c>
	// panic("ipc_send not implemented");
}
  801442:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801445:	5b                   	pop    %ebx
  801446:	5e                   	pop    %esi
  801447:	5f                   	pop    %edi
  801448:	5d                   	pop    %ebp
  801449:	c3                   	ret    

0080144a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80144a:	55                   	push   %ebp
  80144b:	89 e5                	mov    %esp,%ebp
  80144d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801450:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801455:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801458:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80145e:	8b 52 50             	mov    0x50(%edx),%edx
  801461:	39 ca                	cmp    %ecx,%edx
  801463:	75 0d                	jne    801472 <ipc_find_env+0x28>
			return envs[i].env_id;
  801465:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801468:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80146d:	8b 40 48             	mov    0x48(%eax),%eax
  801470:	eb 0f                	jmp    801481 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801472:	83 c0 01             	add    $0x1,%eax
  801475:	3d 00 04 00 00       	cmp    $0x400,%eax
  80147a:	75 d9                	jne    801455 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80147c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801481:	5d                   	pop    %ebp
  801482:	c3                   	ret    

00801483 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801483:	55                   	push   %ebp
  801484:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801486:	8b 45 08             	mov    0x8(%ebp),%eax
  801489:	05 00 00 00 30       	add    $0x30000000,%eax
  80148e:	c1 e8 0c             	shr    $0xc,%eax
}
  801491:	5d                   	pop    %ebp
  801492:	c3                   	ret    

00801493 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801493:	55                   	push   %ebp
  801494:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801496:	8b 45 08             	mov    0x8(%ebp),%eax
  801499:	05 00 00 00 30       	add    $0x30000000,%eax
  80149e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8014a3:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8014a8:	5d                   	pop    %ebp
  8014a9:	c3                   	ret    

008014aa <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8014aa:	55                   	push   %ebp
  8014ab:	89 e5                	mov    %esp,%ebp
  8014ad:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014b0:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8014b5:	89 c2                	mov    %eax,%edx
  8014b7:	c1 ea 16             	shr    $0x16,%edx
  8014ba:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014c1:	f6 c2 01             	test   $0x1,%dl
  8014c4:	74 11                	je     8014d7 <fd_alloc+0x2d>
  8014c6:	89 c2                	mov    %eax,%edx
  8014c8:	c1 ea 0c             	shr    $0xc,%edx
  8014cb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014d2:	f6 c2 01             	test   $0x1,%dl
  8014d5:	75 09                	jne    8014e0 <fd_alloc+0x36>
			*fd_store = fd;
  8014d7:	89 01                	mov    %eax,(%ecx)
			return 0;
  8014d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8014de:	eb 17                	jmp    8014f7 <fd_alloc+0x4d>
  8014e0:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8014e5:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8014ea:	75 c9                	jne    8014b5 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8014ec:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8014f2:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8014f7:	5d                   	pop    %ebp
  8014f8:	c3                   	ret    

008014f9 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8014f9:	55                   	push   %ebp
  8014fa:	89 e5                	mov    %esp,%ebp
  8014fc:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8014ff:	83 f8 1f             	cmp    $0x1f,%eax
  801502:	77 36                	ja     80153a <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801504:	c1 e0 0c             	shl    $0xc,%eax
  801507:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80150c:	89 c2                	mov    %eax,%edx
  80150e:	c1 ea 16             	shr    $0x16,%edx
  801511:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801518:	f6 c2 01             	test   $0x1,%dl
  80151b:	74 24                	je     801541 <fd_lookup+0x48>
  80151d:	89 c2                	mov    %eax,%edx
  80151f:	c1 ea 0c             	shr    $0xc,%edx
  801522:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801529:	f6 c2 01             	test   $0x1,%dl
  80152c:	74 1a                	je     801548 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80152e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801531:	89 02                	mov    %eax,(%edx)
	return 0;
  801533:	b8 00 00 00 00       	mov    $0x0,%eax
  801538:	eb 13                	jmp    80154d <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80153a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80153f:	eb 0c                	jmp    80154d <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801541:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801546:	eb 05                	jmp    80154d <fd_lookup+0x54>
  801548:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80154d:	5d                   	pop    %ebp
  80154e:	c3                   	ret    

0080154f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80154f:	55                   	push   %ebp
  801550:	89 e5                	mov    %esp,%ebp
  801552:	83 ec 08             	sub    $0x8,%esp
  801555:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801558:	ba e4 2b 80 00       	mov    $0x802be4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80155d:	eb 13                	jmp    801572 <dev_lookup+0x23>
  80155f:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801562:	39 08                	cmp    %ecx,(%eax)
  801564:	75 0c                	jne    801572 <dev_lookup+0x23>
			*dev = devtab[i];
  801566:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801569:	89 01                	mov    %eax,(%ecx)
			return 0;
  80156b:	b8 00 00 00 00       	mov    $0x0,%eax
  801570:	eb 2e                	jmp    8015a0 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801572:	8b 02                	mov    (%edx),%eax
  801574:	85 c0                	test   %eax,%eax
  801576:	75 e7                	jne    80155f <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801578:	a1 04 40 80 00       	mov    0x804004,%eax
  80157d:	8b 40 48             	mov    0x48(%eax),%eax
  801580:	83 ec 04             	sub    $0x4,%esp
  801583:	51                   	push   %ecx
  801584:	50                   	push   %eax
  801585:	68 64 2b 80 00       	push   $0x802b64
  80158a:	e8 d2 f1 ff ff       	call   800761 <cprintf>
	*dev = 0;
  80158f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801592:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801598:	83 c4 10             	add    $0x10,%esp
  80159b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8015a0:	c9                   	leave  
  8015a1:	c3                   	ret    

008015a2 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8015a2:	55                   	push   %ebp
  8015a3:	89 e5                	mov    %esp,%ebp
  8015a5:	56                   	push   %esi
  8015a6:	53                   	push   %ebx
  8015a7:	83 ec 10             	sub    $0x10,%esp
  8015aa:	8b 75 08             	mov    0x8(%ebp),%esi
  8015ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8015b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015b3:	50                   	push   %eax
  8015b4:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8015ba:	c1 e8 0c             	shr    $0xc,%eax
  8015bd:	50                   	push   %eax
  8015be:	e8 36 ff ff ff       	call   8014f9 <fd_lookup>
  8015c3:	83 c4 08             	add    $0x8,%esp
  8015c6:	85 c0                	test   %eax,%eax
  8015c8:	78 05                	js     8015cf <fd_close+0x2d>
	    || fd != fd2)
  8015ca:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8015cd:	74 0c                	je     8015db <fd_close+0x39>
		return (must_exist ? r : 0);
  8015cf:	84 db                	test   %bl,%bl
  8015d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8015d6:	0f 44 c2             	cmove  %edx,%eax
  8015d9:	eb 41                	jmp    80161c <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8015db:	83 ec 08             	sub    $0x8,%esp
  8015de:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015e1:	50                   	push   %eax
  8015e2:	ff 36                	pushl  (%esi)
  8015e4:	e8 66 ff ff ff       	call   80154f <dev_lookup>
  8015e9:	89 c3                	mov    %eax,%ebx
  8015eb:	83 c4 10             	add    $0x10,%esp
  8015ee:	85 c0                	test   %eax,%eax
  8015f0:	78 1a                	js     80160c <fd_close+0x6a>
		if (dev->dev_close)
  8015f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015f5:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8015f8:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8015fd:	85 c0                	test   %eax,%eax
  8015ff:	74 0b                	je     80160c <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801601:	83 ec 0c             	sub    $0xc,%esp
  801604:	56                   	push   %esi
  801605:	ff d0                	call   *%eax
  801607:	89 c3                	mov    %eax,%ebx
  801609:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80160c:	83 ec 08             	sub    $0x8,%esp
  80160f:	56                   	push   %esi
  801610:	6a 00                	push   $0x0
  801612:	e8 fe fb ff ff       	call   801215 <sys_page_unmap>
	return r;
  801617:	83 c4 10             	add    $0x10,%esp
  80161a:	89 d8                	mov    %ebx,%eax
}
  80161c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80161f:	5b                   	pop    %ebx
  801620:	5e                   	pop    %esi
  801621:	5d                   	pop    %ebp
  801622:	c3                   	ret    

00801623 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801623:	55                   	push   %ebp
  801624:	89 e5                	mov    %esp,%ebp
  801626:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801629:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80162c:	50                   	push   %eax
  80162d:	ff 75 08             	pushl  0x8(%ebp)
  801630:	e8 c4 fe ff ff       	call   8014f9 <fd_lookup>
  801635:	83 c4 08             	add    $0x8,%esp
  801638:	85 c0                	test   %eax,%eax
  80163a:	78 10                	js     80164c <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80163c:	83 ec 08             	sub    $0x8,%esp
  80163f:	6a 01                	push   $0x1
  801641:	ff 75 f4             	pushl  -0xc(%ebp)
  801644:	e8 59 ff ff ff       	call   8015a2 <fd_close>
  801649:	83 c4 10             	add    $0x10,%esp
}
  80164c:	c9                   	leave  
  80164d:	c3                   	ret    

0080164e <close_all>:

void
close_all(void)
{
  80164e:	55                   	push   %ebp
  80164f:	89 e5                	mov    %esp,%ebp
  801651:	53                   	push   %ebx
  801652:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801655:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80165a:	83 ec 0c             	sub    $0xc,%esp
  80165d:	53                   	push   %ebx
  80165e:	e8 c0 ff ff ff       	call   801623 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801663:	83 c3 01             	add    $0x1,%ebx
  801666:	83 c4 10             	add    $0x10,%esp
  801669:	83 fb 20             	cmp    $0x20,%ebx
  80166c:	75 ec                	jne    80165a <close_all+0xc>
		close(i);
}
  80166e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801671:	c9                   	leave  
  801672:	c3                   	ret    

00801673 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801673:	55                   	push   %ebp
  801674:	89 e5                	mov    %esp,%ebp
  801676:	57                   	push   %edi
  801677:	56                   	push   %esi
  801678:	53                   	push   %ebx
  801679:	83 ec 2c             	sub    $0x2c,%esp
  80167c:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80167f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801682:	50                   	push   %eax
  801683:	ff 75 08             	pushl  0x8(%ebp)
  801686:	e8 6e fe ff ff       	call   8014f9 <fd_lookup>
  80168b:	83 c4 08             	add    $0x8,%esp
  80168e:	85 c0                	test   %eax,%eax
  801690:	0f 88 c1 00 00 00    	js     801757 <dup+0xe4>
		return r;
	close(newfdnum);
  801696:	83 ec 0c             	sub    $0xc,%esp
  801699:	56                   	push   %esi
  80169a:	e8 84 ff ff ff       	call   801623 <close>

	newfd = INDEX2FD(newfdnum);
  80169f:	89 f3                	mov    %esi,%ebx
  8016a1:	c1 e3 0c             	shl    $0xc,%ebx
  8016a4:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8016aa:	83 c4 04             	add    $0x4,%esp
  8016ad:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016b0:	e8 de fd ff ff       	call   801493 <fd2data>
  8016b5:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8016b7:	89 1c 24             	mov    %ebx,(%esp)
  8016ba:	e8 d4 fd ff ff       	call   801493 <fd2data>
  8016bf:	83 c4 10             	add    $0x10,%esp
  8016c2:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8016c5:	89 f8                	mov    %edi,%eax
  8016c7:	c1 e8 16             	shr    $0x16,%eax
  8016ca:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8016d1:	a8 01                	test   $0x1,%al
  8016d3:	74 37                	je     80170c <dup+0x99>
  8016d5:	89 f8                	mov    %edi,%eax
  8016d7:	c1 e8 0c             	shr    $0xc,%eax
  8016da:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8016e1:	f6 c2 01             	test   $0x1,%dl
  8016e4:	74 26                	je     80170c <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8016e6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016ed:	83 ec 0c             	sub    $0xc,%esp
  8016f0:	25 07 0e 00 00       	and    $0xe07,%eax
  8016f5:	50                   	push   %eax
  8016f6:	ff 75 d4             	pushl  -0x2c(%ebp)
  8016f9:	6a 00                	push   $0x0
  8016fb:	57                   	push   %edi
  8016fc:	6a 00                	push   $0x0
  8016fe:	e8 d0 fa ff ff       	call   8011d3 <sys_page_map>
  801703:	89 c7                	mov    %eax,%edi
  801705:	83 c4 20             	add    $0x20,%esp
  801708:	85 c0                	test   %eax,%eax
  80170a:	78 2e                	js     80173a <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80170c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80170f:	89 d0                	mov    %edx,%eax
  801711:	c1 e8 0c             	shr    $0xc,%eax
  801714:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80171b:	83 ec 0c             	sub    $0xc,%esp
  80171e:	25 07 0e 00 00       	and    $0xe07,%eax
  801723:	50                   	push   %eax
  801724:	53                   	push   %ebx
  801725:	6a 00                	push   $0x0
  801727:	52                   	push   %edx
  801728:	6a 00                	push   $0x0
  80172a:	e8 a4 fa ff ff       	call   8011d3 <sys_page_map>
  80172f:	89 c7                	mov    %eax,%edi
  801731:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801734:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801736:	85 ff                	test   %edi,%edi
  801738:	79 1d                	jns    801757 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80173a:	83 ec 08             	sub    $0x8,%esp
  80173d:	53                   	push   %ebx
  80173e:	6a 00                	push   $0x0
  801740:	e8 d0 fa ff ff       	call   801215 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801745:	83 c4 08             	add    $0x8,%esp
  801748:	ff 75 d4             	pushl  -0x2c(%ebp)
  80174b:	6a 00                	push   $0x0
  80174d:	e8 c3 fa ff ff       	call   801215 <sys_page_unmap>
	return r;
  801752:	83 c4 10             	add    $0x10,%esp
  801755:	89 f8                	mov    %edi,%eax
}
  801757:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80175a:	5b                   	pop    %ebx
  80175b:	5e                   	pop    %esi
  80175c:	5f                   	pop    %edi
  80175d:	5d                   	pop    %ebp
  80175e:	c3                   	ret    

0080175f <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80175f:	55                   	push   %ebp
  801760:	89 e5                	mov    %esp,%ebp
  801762:	53                   	push   %ebx
  801763:	83 ec 14             	sub    $0x14,%esp
  801766:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801769:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80176c:	50                   	push   %eax
  80176d:	53                   	push   %ebx
  80176e:	e8 86 fd ff ff       	call   8014f9 <fd_lookup>
  801773:	83 c4 08             	add    $0x8,%esp
  801776:	89 c2                	mov    %eax,%edx
  801778:	85 c0                	test   %eax,%eax
  80177a:	78 6d                	js     8017e9 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80177c:	83 ec 08             	sub    $0x8,%esp
  80177f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801782:	50                   	push   %eax
  801783:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801786:	ff 30                	pushl  (%eax)
  801788:	e8 c2 fd ff ff       	call   80154f <dev_lookup>
  80178d:	83 c4 10             	add    $0x10,%esp
  801790:	85 c0                	test   %eax,%eax
  801792:	78 4c                	js     8017e0 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801794:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801797:	8b 42 08             	mov    0x8(%edx),%eax
  80179a:	83 e0 03             	and    $0x3,%eax
  80179d:	83 f8 01             	cmp    $0x1,%eax
  8017a0:	75 21                	jne    8017c3 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8017a2:	a1 04 40 80 00       	mov    0x804004,%eax
  8017a7:	8b 40 48             	mov    0x48(%eax),%eax
  8017aa:	83 ec 04             	sub    $0x4,%esp
  8017ad:	53                   	push   %ebx
  8017ae:	50                   	push   %eax
  8017af:	68 a8 2b 80 00       	push   $0x802ba8
  8017b4:	e8 a8 ef ff ff       	call   800761 <cprintf>
		return -E_INVAL;
  8017b9:	83 c4 10             	add    $0x10,%esp
  8017bc:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8017c1:	eb 26                	jmp    8017e9 <read+0x8a>
	}
	if (!dev->dev_read)
  8017c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017c6:	8b 40 08             	mov    0x8(%eax),%eax
  8017c9:	85 c0                	test   %eax,%eax
  8017cb:	74 17                	je     8017e4 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8017cd:	83 ec 04             	sub    $0x4,%esp
  8017d0:	ff 75 10             	pushl  0x10(%ebp)
  8017d3:	ff 75 0c             	pushl  0xc(%ebp)
  8017d6:	52                   	push   %edx
  8017d7:	ff d0                	call   *%eax
  8017d9:	89 c2                	mov    %eax,%edx
  8017db:	83 c4 10             	add    $0x10,%esp
  8017de:	eb 09                	jmp    8017e9 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017e0:	89 c2                	mov    %eax,%edx
  8017e2:	eb 05                	jmp    8017e9 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8017e4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8017e9:	89 d0                	mov    %edx,%eax
  8017eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017ee:	c9                   	leave  
  8017ef:	c3                   	ret    

008017f0 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8017f0:	55                   	push   %ebp
  8017f1:	89 e5                	mov    %esp,%ebp
  8017f3:	57                   	push   %edi
  8017f4:	56                   	push   %esi
  8017f5:	53                   	push   %ebx
  8017f6:	83 ec 0c             	sub    $0xc,%esp
  8017f9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017fc:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017ff:	bb 00 00 00 00       	mov    $0x0,%ebx
  801804:	eb 21                	jmp    801827 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801806:	83 ec 04             	sub    $0x4,%esp
  801809:	89 f0                	mov    %esi,%eax
  80180b:	29 d8                	sub    %ebx,%eax
  80180d:	50                   	push   %eax
  80180e:	89 d8                	mov    %ebx,%eax
  801810:	03 45 0c             	add    0xc(%ebp),%eax
  801813:	50                   	push   %eax
  801814:	57                   	push   %edi
  801815:	e8 45 ff ff ff       	call   80175f <read>
		if (m < 0)
  80181a:	83 c4 10             	add    $0x10,%esp
  80181d:	85 c0                	test   %eax,%eax
  80181f:	78 10                	js     801831 <readn+0x41>
			return m;
		if (m == 0)
  801821:	85 c0                	test   %eax,%eax
  801823:	74 0a                	je     80182f <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801825:	01 c3                	add    %eax,%ebx
  801827:	39 f3                	cmp    %esi,%ebx
  801829:	72 db                	jb     801806 <readn+0x16>
  80182b:	89 d8                	mov    %ebx,%eax
  80182d:	eb 02                	jmp    801831 <readn+0x41>
  80182f:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801831:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801834:	5b                   	pop    %ebx
  801835:	5e                   	pop    %esi
  801836:	5f                   	pop    %edi
  801837:	5d                   	pop    %ebp
  801838:	c3                   	ret    

00801839 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801839:	55                   	push   %ebp
  80183a:	89 e5                	mov    %esp,%ebp
  80183c:	53                   	push   %ebx
  80183d:	83 ec 14             	sub    $0x14,%esp
  801840:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801843:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801846:	50                   	push   %eax
  801847:	53                   	push   %ebx
  801848:	e8 ac fc ff ff       	call   8014f9 <fd_lookup>
  80184d:	83 c4 08             	add    $0x8,%esp
  801850:	89 c2                	mov    %eax,%edx
  801852:	85 c0                	test   %eax,%eax
  801854:	78 68                	js     8018be <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801856:	83 ec 08             	sub    $0x8,%esp
  801859:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80185c:	50                   	push   %eax
  80185d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801860:	ff 30                	pushl  (%eax)
  801862:	e8 e8 fc ff ff       	call   80154f <dev_lookup>
  801867:	83 c4 10             	add    $0x10,%esp
  80186a:	85 c0                	test   %eax,%eax
  80186c:	78 47                	js     8018b5 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80186e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801871:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801875:	75 21                	jne    801898 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801877:	a1 04 40 80 00       	mov    0x804004,%eax
  80187c:	8b 40 48             	mov    0x48(%eax),%eax
  80187f:	83 ec 04             	sub    $0x4,%esp
  801882:	53                   	push   %ebx
  801883:	50                   	push   %eax
  801884:	68 c4 2b 80 00       	push   $0x802bc4
  801889:	e8 d3 ee ff ff       	call   800761 <cprintf>
		return -E_INVAL;
  80188e:	83 c4 10             	add    $0x10,%esp
  801891:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801896:	eb 26                	jmp    8018be <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801898:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80189b:	8b 52 0c             	mov    0xc(%edx),%edx
  80189e:	85 d2                	test   %edx,%edx
  8018a0:	74 17                	je     8018b9 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8018a2:	83 ec 04             	sub    $0x4,%esp
  8018a5:	ff 75 10             	pushl  0x10(%ebp)
  8018a8:	ff 75 0c             	pushl  0xc(%ebp)
  8018ab:	50                   	push   %eax
  8018ac:	ff d2                	call   *%edx
  8018ae:	89 c2                	mov    %eax,%edx
  8018b0:	83 c4 10             	add    $0x10,%esp
  8018b3:	eb 09                	jmp    8018be <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018b5:	89 c2                	mov    %eax,%edx
  8018b7:	eb 05                	jmp    8018be <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8018b9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8018be:	89 d0                	mov    %edx,%eax
  8018c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018c3:	c9                   	leave  
  8018c4:	c3                   	ret    

008018c5 <seek>:

int
seek(int fdnum, off_t offset)
{
  8018c5:	55                   	push   %ebp
  8018c6:	89 e5                	mov    %esp,%ebp
  8018c8:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018cb:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8018ce:	50                   	push   %eax
  8018cf:	ff 75 08             	pushl  0x8(%ebp)
  8018d2:	e8 22 fc ff ff       	call   8014f9 <fd_lookup>
  8018d7:	83 c4 08             	add    $0x8,%esp
  8018da:	85 c0                	test   %eax,%eax
  8018dc:	78 0e                	js     8018ec <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8018de:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8018e1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018e4:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8018e7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018ec:	c9                   	leave  
  8018ed:	c3                   	ret    

008018ee <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8018ee:	55                   	push   %ebp
  8018ef:	89 e5                	mov    %esp,%ebp
  8018f1:	53                   	push   %ebx
  8018f2:	83 ec 14             	sub    $0x14,%esp
  8018f5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018f8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018fb:	50                   	push   %eax
  8018fc:	53                   	push   %ebx
  8018fd:	e8 f7 fb ff ff       	call   8014f9 <fd_lookup>
  801902:	83 c4 08             	add    $0x8,%esp
  801905:	89 c2                	mov    %eax,%edx
  801907:	85 c0                	test   %eax,%eax
  801909:	78 65                	js     801970 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80190b:	83 ec 08             	sub    $0x8,%esp
  80190e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801911:	50                   	push   %eax
  801912:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801915:	ff 30                	pushl  (%eax)
  801917:	e8 33 fc ff ff       	call   80154f <dev_lookup>
  80191c:	83 c4 10             	add    $0x10,%esp
  80191f:	85 c0                	test   %eax,%eax
  801921:	78 44                	js     801967 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801923:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801926:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80192a:	75 21                	jne    80194d <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80192c:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801931:	8b 40 48             	mov    0x48(%eax),%eax
  801934:	83 ec 04             	sub    $0x4,%esp
  801937:	53                   	push   %ebx
  801938:	50                   	push   %eax
  801939:	68 84 2b 80 00       	push   $0x802b84
  80193e:	e8 1e ee ff ff       	call   800761 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801943:	83 c4 10             	add    $0x10,%esp
  801946:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80194b:	eb 23                	jmp    801970 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80194d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801950:	8b 52 18             	mov    0x18(%edx),%edx
  801953:	85 d2                	test   %edx,%edx
  801955:	74 14                	je     80196b <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801957:	83 ec 08             	sub    $0x8,%esp
  80195a:	ff 75 0c             	pushl  0xc(%ebp)
  80195d:	50                   	push   %eax
  80195e:	ff d2                	call   *%edx
  801960:	89 c2                	mov    %eax,%edx
  801962:	83 c4 10             	add    $0x10,%esp
  801965:	eb 09                	jmp    801970 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801967:	89 c2                	mov    %eax,%edx
  801969:	eb 05                	jmp    801970 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80196b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801970:	89 d0                	mov    %edx,%eax
  801972:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801975:	c9                   	leave  
  801976:	c3                   	ret    

00801977 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801977:	55                   	push   %ebp
  801978:	89 e5                	mov    %esp,%ebp
  80197a:	53                   	push   %ebx
  80197b:	83 ec 14             	sub    $0x14,%esp
  80197e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801981:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801984:	50                   	push   %eax
  801985:	ff 75 08             	pushl  0x8(%ebp)
  801988:	e8 6c fb ff ff       	call   8014f9 <fd_lookup>
  80198d:	83 c4 08             	add    $0x8,%esp
  801990:	89 c2                	mov    %eax,%edx
  801992:	85 c0                	test   %eax,%eax
  801994:	78 58                	js     8019ee <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801996:	83 ec 08             	sub    $0x8,%esp
  801999:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80199c:	50                   	push   %eax
  80199d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019a0:	ff 30                	pushl  (%eax)
  8019a2:	e8 a8 fb ff ff       	call   80154f <dev_lookup>
  8019a7:	83 c4 10             	add    $0x10,%esp
  8019aa:	85 c0                	test   %eax,%eax
  8019ac:	78 37                	js     8019e5 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8019ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019b1:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8019b5:	74 32                	je     8019e9 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8019b7:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8019ba:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8019c1:	00 00 00 
	stat->st_isdir = 0;
  8019c4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019cb:	00 00 00 
	stat->st_dev = dev;
  8019ce:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8019d4:	83 ec 08             	sub    $0x8,%esp
  8019d7:	53                   	push   %ebx
  8019d8:	ff 75 f0             	pushl  -0x10(%ebp)
  8019db:	ff 50 14             	call   *0x14(%eax)
  8019de:	89 c2                	mov    %eax,%edx
  8019e0:	83 c4 10             	add    $0x10,%esp
  8019e3:	eb 09                	jmp    8019ee <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019e5:	89 c2                	mov    %eax,%edx
  8019e7:	eb 05                	jmp    8019ee <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8019e9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8019ee:	89 d0                	mov    %edx,%eax
  8019f0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019f3:	c9                   	leave  
  8019f4:	c3                   	ret    

008019f5 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8019f5:	55                   	push   %ebp
  8019f6:	89 e5                	mov    %esp,%ebp
  8019f8:	56                   	push   %esi
  8019f9:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8019fa:	83 ec 08             	sub    $0x8,%esp
  8019fd:	6a 00                	push   $0x0
  8019ff:	ff 75 08             	pushl  0x8(%ebp)
  801a02:	e8 b7 01 00 00       	call   801bbe <open>
  801a07:	89 c3                	mov    %eax,%ebx
  801a09:	83 c4 10             	add    $0x10,%esp
  801a0c:	85 c0                	test   %eax,%eax
  801a0e:	78 1b                	js     801a2b <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801a10:	83 ec 08             	sub    $0x8,%esp
  801a13:	ff 75 0c             	pushl  0xc(%ebp)
  801a16:	50                   	push   %eax
  801a17:	e8 5b ff ff ff       	call   801977 <fstat>
  801a1c:	89 c6                	mov    %eax,%esi
	close(fd);
  801a1e:	89 1c 24             	mov    %ebx,(%esp)
  801a21:	e8 fd fb ff ff       	call   801623 <close>
	return r;
  801a26:	83 c4 10             	add    $0x10,%esp
  801a29:	89 f0                	mov    %esi,%eax
}
  801a2b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a2e:	5b                   	pop    %ebx
  801a2f:	5e                   	pop    %esi
  801a30:	5d                   	pop    %ebp
  801a31:	c3                   	ret    

00801a32 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801a32:	55                   	push   %ebp
  801a33:	89 e5                	mov    %esp,%ebp
  801a35:	56                   	push   %esi
  801a36:	53                   	push   %ebx
  801a37:	89 c6                	mov    %eax,%esi
  801a39:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801a3b:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801a42:	75 12                	jne    801a56 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801a44:	83 ec 0c             	sub    $0xc,%esp
  801a47:	6a 01                	push   $0x1
  801a49:	e8 fc f9 ff ff       	call   80144a <ipc_find_env>
  801a4e:	a3 00 40 80 00       	mov    %eax,0x804000
  801a53:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a56:	6a 07                	push   $0x7
  801a58:	68 00 50 80 00       	push   $0x805000
  801a5d:	56                   	push   %esi
  801a5e:	ff 35 00 40 80 00    	pushl  0x804000
  801a64:	e8 8d f9 ff ff       	call   8013f6 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801a69:	83 c4 0c             	add    $0xc,%esp
  801a6c:	6a 00                	push   $0x0
  801a6e:	53                   	push   %ebx
  801a6f:	6a 00                	push   $0x0
  801a71:	e8 0b f9 ff ff       	call   801381 <ipc_recv>
}
  801a76:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a79:	5b                   	pop    %ebx
  801a7a:	5e                   	pop    %esi
  801a7b:	5d                   	pop    %ebp
  801a7c:	c3                   	ret    

00801a7d <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a7d:	55                   	push   %ebp
  801a7e:	89 e5                	mov    %esp,%ebp
  801a80:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a83:	8b 45 08             	mov    0x8(%ebp),%eax
  801a86:	8b 40 0c             	mov    0xc(%eax),%eax
  801a89:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801a8e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a91:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a96:	ba 00 00 00 00       	mov    $0x0,%edx
  801a9b:	b8 02 00 00 00       	mov    $0x2,%eax
  801aa0:	e8 8d ff ff ff       	call   801a32 <fsipc>
}
  801aa5:	c9                   	leave  
  801aa6:	c3                   	ret    

00801aa7 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801aa7:	55                   	push   %ebp
  801aa8:	89 e5                	mov    %esp,%ebp
  801aaa:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801aad:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab0:	8b 40 0c             	mov    0xc(%eax),%eax
  801ab3:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801ab8:	ba 00 00 00 00       	mov    $0x0,%edx
  801abd:	b8 06 00 00 00       	mov    $0x6,%eax
  801ac2:	e8 6b ff ff ff       	call   801a32 <fsipc>
}
  801ac7:	c9                   	leave  
  801ac8:	c3                   	ret    

00801ac9 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801ac9:	55                   	push   %ebp
  801aca:	89 e5                	mov    %esp,%ebp
  801acc:	53                   	push   %ebx
  801acd:	83 ec 04             	sub    $0x4,%esp
  801ad0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801ad3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ad6:	8b 40 0c             	mov    0xc(%eax),%eax
  801ad9:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801ade:	ba 00 00 00 00       	mov    $0x0,%edx
  801ae3:	b8 05 00 00 00       	mov    $0x5,%eax
  801ae8:	e8 45 ff ff ff       	call   801a32 <fsipc>
  801aed:	85 c0                	test   %eax,%eax
  801aef:	78 2c                	js     801b1d <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801af1:	83 ec 08             	sub    $0x8,%esp
  801af4:	68 00 50 80 00       	push   $0x805000
  801af9:	53                   	push   %ebx
  801afa:	e8 8e f2 ff ff       	call   800d8d <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801aff:	a1 80 50 80 00       	mov    0x805080,%eax
  801b04:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801b0a:	a1 84 50 80 00       	mov    0x805084,%eax
  801b0f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801b15:	83 c4 10             	add    $0x10,%esp
  801b18:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b1d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b20:	c9                   	leave  
  801b21:	c3                   	ret    

00801b22 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801b22:	55                   	push   %ebp
  801b23:	89 e5                	mov    %esp,%ebp
  801b25:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801b28:	68 f4 2b 80 00       	push   $0x802bf4
  801b2d:	68 90 00 00 00       	push   $0x90
  801b32:	68 12 2c 80 00       	push   $0x802c12
  801b37:	e8 4c eb ff ff       	call   800688 <_panic>

00801b3c <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801b3c:	55                   	push   %ebp
  801b3d:	89 e5                	mov    %esp,%ebp
  801b3f:	56                   	push   %esi
  801b40:	53                   	push   %ebx
  801b41:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b44:	8b 45 08             	mov    0x8(%ebp),%eax
  801b47:	8b 40 0c             	mov    0xc(%eax),%eax
  801b4a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801b4f:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b55:	ba 00 00 00 00       	mov    $0x0,%edx
  801b5a:	b8 03 00 00 00       	mov    $0x3,%eax
  801b5f:	e8 ce fe ff ff       	call   801a32 <fsipc>
  801b64:	89 c3                	mov    %eax,%ebx
  801b66:	85 c0                	test   %eax,%eax
  801b68:	78 4b                	js     801bb5 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801b6a:	39 c6                	cmp    %eax,%esi
  801b6c:	73 16                	jae    801b84 <devfile_read+0x48>
  801b6e:	68 1d 2c 80 00       	push   $0x802c1d
  801b73:	68 24 2c 80 00       	push   $0x802c24
  801b78:	6a 7c                	push   $0x7c
  801b7a:	68 12 2c 80 00       	push   $0x802c12
  801b7f:	e8 04 eb ff ff       	call   800688 <_panic>
	assert(r <= PGSIZE);
  801b84:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b89:	7e 16                	jle    801ba1 <devfile_read+0x65>
  801b8b:	68 39 2c 80 00       	push   $0x802c39
  801b90:	68 24 2c 80 00       	push   $0x802c24
  801b95:	6a 7d                	push   $0x7d
  801b97:	68 12 2c 80 00       	push   $0x802c12
  801b9c:	e8 e7 ea ff ff       	call   800688 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801ba1:	83 ec 04             	sub    $0x4,%esp
  801ba4:	50                   	push   %eax
  801ba5:	68 00 50 80 00       	push   $0x805000
  801baa:	ff 75 0c             	pushl  0xc(%ebp)
  801bad:	e8 6d f3 ff ff       	call   800f1f <memmove>
	return r;
  801bb2:	83 c4 10             	add    $0x10,%esp
}
  801bb5:	89 d8                	mov    %ebx,%eax
  801bb7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bba:	5b                   	pop    %ebx
  801bbb:	5e                   	pop    %esi
  801bbc:	5d                   	pop    %ebp
  801bbd:	c3                   	ret    

00801bbe <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801bbe:	55                   	push   %ebp
  801bbf:	89 e5                	mov    %esp,%ebp
  801bc1:	53                   	push   %ebx
  801bc2:	83 ec 20             	sub    $0x20,%esp
  801bc5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801bc8:	53                   	push   %ebx
  801bc9:	e8 86 f1 ff ff       	call   800d54 <strlen>
  801bce:	83 c4 10             	add    $0x10,%esp
  801bd1:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801bd6:	7f 67                	jg     801c3f <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801bd8:	83 ec 0c             	sub    $0xc,%esp
  801bdb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bde:	50                   	push   %eax
  801bdf:	e8 c6 f8 ff ff       	call   8014aa <fd_alloc>
  801be4:	83 c4 10             	add    $0x10,%esp
		return r;
  801be7:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801be9:	85 c0                	test   %eax,%eax
  801beb:	78 57                	js     801c44 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801bed:	83 ec 08             	sub    $0x8,%esp
  801bf0:	53                   	push   %ebx
  801bf1:	68 00 50 80 00       	push   $0x805000
  801bf6:	e8 92 f1 ff ff       	call   800d8d <strcpy>
	fsipcbuf.open.req_omode = mode;
  801bfb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bfe:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801c03:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c06:	b8 01 00 00 00       	mov    $0x1,%eax
  801c0b:	e8 22 fe ff ff       	call   801a32 <fsipc>
  801c10:	89 c3                	mov    %eax,%ebx
  801c12:	83 c4 10             	add    $0x10,%esp
  801c15:	85 c0                	test   %eax,%eax
  801c17:	79 14                	jns    801c2d <open+0x6f>
		fd_close(fd, 0);
  801c19:	83 ec 08             	sub    $0x8,%esp
  801c1c:	6a 00                	push   $0x0
  801c1e:	ff 75 f4             	pushl  -0xc(%ebp)
  801c21:	e8 7c f9 ff ff       	call   8015a2 <fd_close>
		return r;
  801c26:	83 c4 10             	add    $0x10,%esp
  801c29:	89 da                	mov    %ebx,%edx
  801c2b:	eb 17                	jmp    801c44 <open+0x86>
	}

	return fd2num(fd);
  801c2d:	83 ec 0c             	sub    $0xc,%esp
  801c30:	ff 75 f4             	pushl  -0xc(%ebp)
  801c33:	e8 4b f8 ff ff       	call   801483 <fd2num>
  801c38:	89 c2                	mov    %eax,%edx
  801c3a:	83 c4 10             	add    $0x10,%esp
  801c3d:	eb 05                	jmp    801c44 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801c3f:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801c44:	89 d0                	mov    %edx,%eax
  801c46:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c49:	c9                   	leave  
  801c4a:	c3                   	ret    

00801c4b <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c4b:	55                   	push   %ebp
  801c4c:	89 e5                	mov    %esp,%ebp
  801c4e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c51:	ba 00 00 00 00       	mov    $0x0,%edx
  801c56:	b8 08 00 00 00       	mov    $0x8,%eax
  801c5b:	e8 d2 fd ff ff       	call   801a32 <fsipc>
}
  801c60:	c9                   	leave  
  801c61:	c3                   	ret    

00801c62 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c62:	55                   	push   %ebp
  801c63:	89 e5                	mov    %esp,%ebp
  801c65:	56                   	push   %esi
  801c66:	53                   	push   %ebx
  801c67:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c6a:	83 ec 0c             	sub    $0xc,%esp
  801c6d:	ff 75 08             	pushl  0x8(%ebp)
  801c70:	e8 1e f8 ff ff       	call   801493 <fd2data>
  801c75:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801c77:	83 c4 08             	add    $0x8,%esp
  801c7a:	68 45 2c 80 00       	push   $0x802c45
  801c7f:	53                   	push   %ebx
  801c80:	e8 08 f1 ff ff       	call   800d8d <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c85:	8b 46 04             	mov    0x4(%esi),%eax
  801c88:	2b 06                	sub    (%esi),%eax
  801c8a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801c90:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c97:	00 00 00 
	stat->st_dev = &devpipe;
  801c9a:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  801ca1:	30 80 00 
	return 0;
}
  801ca4:	b8 00 00 00 00       	mov    $0x0,%eax
  801ca9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cac:	5b                   	pop    %ebx
  801cad:	5e                   	pop    %esi
  801cae:	5d                   	pop    %ebp
  801caf:	c3                   	ret    

00801cb0 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801cb0:	55                   	push   %ebp
  801cb1:	89 e5                	mov    %esp,%ebp
  801cb3:	53                   	push   %ebx
  801cb4:	83 ec 0c             	sub    $0xc,%esp
  801cb7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801cba:	53                   	push   %ebx
  801cbb:	6a 00                	push   $0x0
  801cbd:	e8 53 f5 ff ff       	call   801215 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801cc2:	89 1c 24             	mov    %ebx,(%esp)
  801cc5:	e8 c9 f7 ff ff       	call   801493 <fd2data>
  801cca:	83 c4 08             	add    $0x8,%esp
  801ccd:	50                   	push   %eax
  801cce:	6a 00                	push   $0x0
  801cd0:	e8 40 f5 ff ff       	call   801215 <sys_page_unmap>
}
  801cd5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cd8:	c9                   	leave  
  801cd9:	c3                   	ret    

00801cda <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801cda:	55                   	push   %ebp
  801cdb:	89 e5                	mov    %esp,%ebp
  801cdd:	57                   	push   %edi
  801cde:	56                   	push   %esi
  801cdf:	53                   	push   %ebx
  801ce0:	83 ec 1c             	sub    $0x1c,%esp
  801ce3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801ce6:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ce8:	a1 04 40 80 00       	mov    0x804004,%eax
  801ced:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801cf0:	83 ec 0c             	sub    $0xc,%esp
  801cf3:	ff 75 e0             	pushl  -0x20(%ebp)
  801cf6:	e8 46 04 00 00       	call   802141 <pageref>
  801cfb:	89 c3                	mov    %eax,%ebx
  801cfd:	89 3c 24             	mov    %edi,(%esp)
  801d00:	e8 3c 04 00 00       	call   802141 <pageref>
  801d05:	83 c4 10             	add    $0x10,%esp
  801d08:	39 c3                	cmp    %eax,%ebx
  801d0a:	0f 94 c1             	sete   %cl
  801d0d:	0f b6 c9             	movzbl %cl,%ecx
  801d10:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801d13:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801d19:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801d1c:	39 ce                	cmp    %ecx,%esi
  801d1e:	74 1b                	je     801d3b <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801d20:	39 c3                	cmp    %eax,%ebx
  801d22:	75 c4                	jne    801ce8 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d24:	8b 42 58             	mov    0x58(%edx),%eax
  801d27:	ff 75 e4             	pushl  -0x1c(%ebp)
  801d2a:	50                   	push   %eax
  801d2b:	56                   	push   %esi
  801d2c:	68 4c 2c 80 00       	push   $0x802c4c
  801d31:	e8 2b ea ff ff       	call   800761 <cprintf>
  801d36:	83 c4 10             	add    $0x10,%esp
  801d39:	eb ad                	jmp    801ce8 <_pipeisclosed+0xe>
	}
}
  801d3b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d41:	5b                   	pop    %ebx
  801d42:	5e                   	pop    %esi
  801d43:	5f                   	pop    %edi
  801d44:	5d                   	pop    %ebp
  801d45:	c3                   	ret    

00801d46 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d46:	55                   	push   %ebp
  801d47:	89 e5                	mov    %esp,%ebp
  801d49:	57                   	push   %edi
  801d4a:	56                   	push   %esi
  801d4b:	53                   	push   %ebx
  801d4c:	83 ec 28             	sub    $0x28,%esp
  801d4f:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801d52:	56                   	push   %esi
  801d53:	e8 3b f7 ff ff       	call   801493 <fd2data>
  801d58:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d5a:	83 c4 10             	add    $0x10,%esp
  801d5d:	bf 00 00 00 00       	mov    $0x0,%edi
  801d62:	eb 4b                	jmp    801daf <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801d64:	89 da                	mov    %ebx,%edx
  801d66:	89 f0                	mov    %esi,%eax
  801d68:	e8 6d ff ff ff       	call   801cda <_pipeisclosed>
  801d6d:	85 c0                	test   %eax,%eax
  801d6f:	75 48                	jne    801db9 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801d71:	e8 fb f3 ff ff       	call   801171 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d76:	8b 43 04             	mov    0x4(%ebx),%eax
  801d79:	8b 0b                	mov    (%ebx),%ecx
  801d7b:	8d 51 20             	lea    0x20(%ecx),%edx
  801d7e:	39 d0                	cmp    %edx,%eax
  801d80:	73 e2                	jae    801d64 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d85:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801d89:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801d8c:	89 c2                	mov    %eax,%edx
  801d8e:	c1 fa 1f             	sar    $0x1f,%edx
  801d91:	89 d1                	mov    %edx,%ecx
  801d93:	c1 e9 1b             	shr    $0x1b,%ecx
  801d96:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801d99:	83 e2 1f             	and    $0x1f,%edx
  801d9c:	29 ca                	sub    %ecx,%edx
  801d9e:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801da2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801da6:	83 c0 01             	add    $0x1,%eax
  801da9:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801dac:	83 c7 01             	add    $0x1,%edi
  801daf:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801db2:	75 c2                	jne    801d76 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801db4:	8b 45 10             	mov    0x10(%ebp),%eax
  801db7:	eb 05                	jmp    801dbe <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801db9:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801dbe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dc1:	5b                   	pop    %ebx
  801dc2:	5e                   	pop    %esi
  801dc3:	5f                   	pop    %edi
  801dc4:	5d                   	pop    %ebp
  801dc5:	c3                   	ret    

00801dc6 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801dc6:	55                   	push   %ebp
  801dc7:	89 e5                	mov    %esp,%ebp
  801dc9:	57                   	push   %edi
  801dca:	56                   	push   %esi
  801dcb:	53                   	push   %ebx
  801dcc:	83 ec 18             	sub    $0x18,%esp
  801dcf:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801dd2:	57                   	push   %edi
  801dd3:	e8 bb f6 ff ff       	call   801493 <fd2data>
  801dd8:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801dda:	83 c4 10             	add    $0x10,%esp
  801ddd:	bb 00 00 00 00       	mov    $0x0,%ebx
  801de2:	eb 3d                	jmp    801e21 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801de4:	85 db                	test   %ebx,%ebx
  801de6:	74 04                	je     801dec <devpipe_read+0x26>
				return i;
  801de8:	89 d8                	mov    %ebx,%eax
  801dea:	eb 44                	jmp    801e30 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801dec:	89 f2                	mov    %esi,%edx
  801dee:	89 f8                	mov    %edi,%eax
  801df0:	e8 e5 fe ff ff       	call   801cda <_pipeisclosed>
  801df5:	85 c0                	test   %eax,%eax
  801df7:	75 32                	jne    801e2b <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801df9:	e8 73 f3 ff ff       	call   801171 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801dfe:	8b 06                	mov    (%esi),%eax
  801e00:	3b 46 04             	cmp    0x4(%esi),%eax
  801e03:	74 df                	je     801de4 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801e05:	99                   	cltd   
  801e06:	c1 ea 1b             	shr    $0x1b,%edx
  801e09:	01 d0                	add    %edx,%eax
  801e0b:	83 e0 1f             	and    $0x1f,%eax
  801e0e:	29 d0                	sub    %edx,%eax
  801e10:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801e15:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e18:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801e1b:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e1e:	83 c3 01             	add    $0x1,%ebx
  801e21:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801e24:	75 d8                	jne    801dfe <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801e26:	8b 45 10             	mov    0x10(%ebp),%eax
  801e29:	eb 05                	jmp    801e30 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e2b:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801e30:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e33:	5b                   	pop    %ebx
  801e34:	5e                   	pop    %esi
  801e35:	5f                   	pop    %edi
  801e36:	5d                   	pop    %ebp
  801e37:	c3                   	ret    

00801e38 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801e38:	55                   	push   %ebp
  801e39:	89 e5                	mov    %esp,%ebp
  801e3b:	56                   	push   %esi
  801e3c:	53                   	push   %ebx
  801e3d:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801e40:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e43:	50                   	push   %eax
  801e44:	e8 61 f6 ff ff       	call   8014aa <fd_alloc>
  801e49:	83 c4 10             	add    $0x10,%esp
  801e4c:	89 c2                	mov    %eax,%edx
  801e4e:	85 c0                	test   %eax,%eax
  801e50:	0f 88 2c 01 00 00    	js     801f82 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e56:	83 ec 04             	sub    $0x4,%esp
  801e59:	68 07 04 00 00       	push   $0x407
  801e5e:	ff 75 f4             	pushl  -0xc(%ebp)
  801e61:	6a 00                	push   $0x0
  801e63:	e8 28 f3 ff ff       	call   801190 <sys_page_alloc>
  801e68:	83 c4 10             	add    $0x10,%esp
  801e6b:	89 c2                	mov    %eax,%edx
  801e6d:	85 c0                	test   %eax,%eax
  801e6f:	0f 88 0d 01 00 00    	js     801f82 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801e75:	83 ec 0c             	sub    $0xc,%esp
  801e78:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e7b:	50                   	push   %eax
  801e7c:	e8 29 f6 ff ff       	call   8014aa <fd_alloc>
  801e81:	89 c3                	mov    %eax,%ebx
  801e83:	83 c4 10             	add    $0x10,%esp
  801e86:	85 c0                	test   %eax,%eax
  801e88:	0f 88 e2 00 00 00    	js     801f70 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e8e:	83 ec 04             	sub    $0x4,%esp
  801e91:	68 07 04 00 00       	push   $0x407
  801e96:	ff 75 f0             	pushl  -0x10(%ebp)
  801e99:	6a 00                	push   $0x0
  801e9b:	e8 f0 f2 ff ff       	call   801190 <sys_page_alloc>
  801ea0:	89 c3                	mov    %eax,%ebx
  801ea2:	83 c4 10             	add    $0x10,%esp
  801ea5:	85 c0                	test   %eax,%eax
  801ea7:	0f 88 c3 00 00 00    	js     801f70 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801ead:	83 ec 0c             	sub    $0xc,%esp
  801eb0:	ff 75 f4             	pushl  -0xc(%ebp)
  801eb3:	e8 db f5 ff ff       	call   801493 <fd2data>
  801eb8:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801eba:	83 c4 0c             	add    $0xc,%esp
  801ebd:	68 07 04 00 00       	push   $0x407
  801ec2:	50                   	push   %eax
  801ec3:	6a 00                	push   $0x0
  801ec5:	e8 c6 f2 ff ff       	call   801190 <sys_page_alloc>
  801eca:	89 c3                	mov    %eax,%ebx
  801ecc:	83 c4 10             	add    $0x10,%esp
  801ecf:	85 c0                	test   %eax,%eax
  801ed1:	0f 88 89 00 00 00    	js     801f60 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ed7:	83 ec 0c             	sub    $0xc,%esp
  801eda:	ff 75 f0             	pushl  -0x10(%ebp)
  801edd:	e8 b1 f5 ff ff       	call   801493 <fd2data>
  801ee2:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801ee9:	50                   	push   %eax
  801eea:	6a 00                	push   $0x0
  801eec:	56                   	push   %esi
  801eed:	6a 00                	push   $0x0
  801eef:	e8 df f2 ff ff       	call   8011d3 <sys_page_map>
  801ef4:	89 c3                	mov    %eax,%ebx
  801ef6:	83 c4 20             	add    $0x20,%esp
  801ef9:	85 c0                	test   %eax,%eax
  801efb:	78 55                	js     801f52 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801efd:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801f03:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f06:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801f08:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f0b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801f12:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801f18:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f1b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801f1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f20:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801f27:	83 ec 0c             	sub    $0xc,%esp
  801f2a:	ff 75 f4             	pushl  -0xc(%ebp)
  801f2d:	e8 51 f5 ff ff       	call   801483 <fd2num>
  801f32:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f35:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801f37:	83 c4 04             	add    $0x4,%esp
  801f3a:	ff 75 f0             	pushl  -0x10(%ebp)
  801f3d:	e8 41 f5 ff ff       	call   801483 <fd2num>
  801f42:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f45:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801f48:	83 c4 10             	add    $0x10,%esp
  801f4b:	ba 00 00 00 00       	mov    $0x0,%edx
  801f50:	eb 30                	jmp    801f82 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801f52:	83 ec 08             	sub    $0x8,%esp
  801f55:	56                   	push   %esi
  801f56:	6a 00                	push   $0x0
  801f58:	e8 b8 f2 ff ff       	call   801215 <sys_page_unmap>
  801f5d:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801f60:	83 ec 08             	sub    $0x8,%esp
  801f63:	ff 75 f0             	pushl  -0x10(%ebp)
  801f66:	6a 00                	push   $0x0
  801f68:	e8 a8 f2 ff ff       	call   801215 <sys_page_unmap>
  801f6d:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801f70:	83 ec 08             	sub    $0x8,%esp
  801f73:	ff 75 f4             	pushl  -0xc(%ebp)
  801f76:	6a 00                	push   $0x0
  801f78:	e8 98 f2 ff ff       	call   801215 <sys_page_unmap>
  801f7d:	83 c4 10             	add    $0x10,%esp
  801f80:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801f82:	89 d0                	mov    %edx,%eax
  801f84:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f87:	5b                   	pop    %ebx
  801f88:	5e                   	pop    %esi
  801f89:	5d                   	pop    %ebp
  801f8a:	c3                   	ret    

00801f8b <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801f8b:	55                   	push   %ebp
  801f8c:	89 e5                	mov    %esp,%ebp
  801f8e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f91:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f94:	50                   	push   %eax
  801f95:	ff 75 08             	pushl  0x8(%ebp)
  801f98:	e8 5c f5 ff ff       	call   8014f9 <fd_lookup>
  801f9d:	83 c4 10             	add    $0x10,%esp
  801fa0:	85 c0                	test   %eax,%eax
  801fa2:	78 18                	js     801fbc <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801fa4:	83 ec 0c             	sub    $0xc,%esp
  801fa7:	ff 75 f4             	pushl  -0xc(%ebp)
  801faa:	e8 e4 f4 ff ff       	call   801493 <fd2data>
	return _pipeisclosed(fd, p);
  801faf:	89 c2                	mov    %eax,%edx
  801fb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fb4:	e8 21 fd ff ff       	call   801cda <_pipeisclosed>
  801fb9:	83 c4 10             	add    $0x10,%esp
}
  801fbc:	c9                   	leave  
  801fbd:	c3                   	ret    

00801fbe <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801fbe:	55                   	push   %ebp
  801fbf:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801fc1:	b8 00 00 00 00       	mov    $0x0,%eax
  801fc6:	5d                   	pop    %ebp
  801fc7:	c3                   	ret    

00801fc8 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801fc8:	55                   	push   %ebp
  801fc9:	89 e5                	mov    %esp,%ebp
  801fcb:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801fce:	68 64 2c 80 00       	push   $0x802c64
  801fd3:	ff 75 0c             	pushl  0xc(%ebp)
  801fd6:	e8 b2 ed ff ff       	call   800d8d <strcpy>
	return 0;
}
  801fdb:	b8 00 00 00 00       	mov    $0x0,%eax
  801fe0:	c9                   	leave  
  801fe1:	c3                   	ret    

00801fe2 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801fe2:	55                   	push   %ebp
  801fe3:	89 e5                	mov    %esp,%ebp
  801fe5:	57                   	push   %edi
  801fe6:	56                   	push   %esi
  801fe7:	53                   	push   %ebx
  801fe8:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fee:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ff3:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ff9:	eb 2d                	jmp    802028 <devcons_write+0x46>
		m = n - tot;
  801ffb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ffe:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802000:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802003:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802008:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80200b:	83 ec 04             	sub    $0x4,%esp
  80200e:	53                   	push   %ebx
  80200f:	03 45 0c             	add    0xc(%ebp),%eax
  802012:	50                   	push   %eax
  802013:	57                   	push   %edi
  802014:	e8 06 ef ff ff       	call   800f1f <memmove>
		sys_cputs(buf, m);
  802019:	83 c4 08             	add    $0x8,%esp
  80201c:	53                   	push   %ebx
  80201d:	57                   	push   %edi
  80201e:	e8 b1 f0 ff ff       	call   8010d4 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802023:	01 de                	add    %ebx,%esi
  802025:	83 c4 10             	add    $0x10,%esp
  802028:	89 f0                	mov    %esi,%eax
  80202a:	3b 75 10             	cmp    0x10(%ebp),%esi
  80202d:	72 cc                	jb     801ffb <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80202f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802032:	5b                   	pop    %ebx
  802033:	5e                   	pop    %esi
  802034:	5f                   	pop    %edi
  802035:	5d                   	pop    %ebp
  802036:	c3                   	ret    

00802037 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802037:	55                   	push   %ebp
  802038:	89 e5                	mov    %esp,%ebp
  80203a:	83 ec 08             	sub    $0x8,%esp
  80203d:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802042:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802046:	74 2a                	je     802072 <devcons_read+0x3b>
  802048:	eb 05                	jmp    80204f <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80204a:	e8 22 f1 ff ff       	call   801171 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80204f:	e8 9e f0 ff ff       	call   8010f2 <sys_cgetc>
  802054:	85 c0                	test   %eax,%eax
  802056:	74 f2                	je     80204a <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802058:	85 c0                	test   %eax,%eax
  80205a:	78 16                	js     802072 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80205c:	83 f8 04             	cmp    $0x4,%eax
  80205f:	74 0c                	je     80206d <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802061:	8b 55 0c             	mov    0xc(%ebp),%edx
  802064:	88 02                	mov    %al,(%edx)
	return 1;
  802066:	b8 01 00 00 00       	mov    $0x1,%eax
  80206b:	eb 05                	jmp    802072 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80206d:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802072:	c9                   	leave  
  802073:	c3                   	ret    

00802074 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802074:	55                   	push   %ebp
  802075:	89 e5                	mov    %esp,%ebp
  802077:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80207a:	8b 45 08             	mov    0x8(%ebp),%eax
  80207d:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802080:	6a 01                	push   $0x1
  802082:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802085:	50                   	push   %eax
  802086:	e8 49 f0 ff ff       	call   8010d4 <sys_cputs>
}
  80208b:	83 c4 10             	add    $0x10,%esp
  80208e:	c9                   	leave  
  80208f:	c3                   	ret    

00802090 <getchar>:

int
getchar(void)
{
  802090:	55                   	push   %ebp
  802091:	89 e5                	mov    %esp,%ebp
  802093:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802096:	6a 01                	push   $0x1
  802098:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80209b:	50                   	push   %eax
  80209c:	6a 00                	push   $0x0
  80209e:	e8 bc f6 ff ff       	call   80175f <read>
	if (r < 0)
  8020a3:	83 c4 10             	add    $0x10,%esp
  8020a6:	85 c0                	test   %eax,%eax
  8020a8:	78 0f                	js     8020b9 <getchar+0x29>
		return r;
	if (r < 1)
  8020aa:	85 c0                	test   %eax,%eax
  8020ac:	7e 06                	jle    8020b4 <getchar+0x24>
		return -E_EOF;
	return c;
  8020ae:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8020b2:	eb 05                	jmp    8020b9 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8020b4:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8020b9:	c9                   	leave  
  8020ba:	c3                   	ret    

008020bb <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8020bb:	55                   	push   %ebp
  8020bc:	89 e5                	mov    %esp,%ebp
  8020be:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020c4:	50                   	push   %eax
  8020c5:	ff 75 08             	pushl  0x8(%ebp)
  8020c8:	e8 2c f4 ff ff       	call   8014f9 <fd_lookup>
  8020cd:	83 c4 10             	add    $0x10,%esp
  8020d0:	85 c0                	test   %eax,%eax
  8020d2:	78 11                	js     8020e5 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8020d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020d7:	8b 15 40 30 80 00    	mov    0x803040,%edx
  8020dd:	39 10                	cmp    %edx,(%eax)
  8020df:	0f 94 c0             	sete   %al
  8020e2:	0f b6 c0             	movzbl %al,%eax
}
  8020e5:	c9                   	leave  
  8020e6:	c3                   	ret    

008020e7 <opencons>:

int
opencons(void)
{
  8020e7:	55                   	push   %ebp
  8020e8:	89 e5                	mov    %esp,%ebp
  8020ea:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8020ed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020f0:	50                   	push   %eax
  8020f1:	e8 b4 f3 ff ff       	call   8014aa <fd_alloc>
  8020f6:	83 c4 10             	add    $0x10,%esp
		return r;
  8020f9:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8020fb:	85 c0                	test   %eax,%eax
  8020fd:	78 3e                	js     80213d <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020ff:	83 ec 04             	sub    $0x4,%esp
  802102:	68 07 04 00 00       	push   $0x407
  802107:	ff 75 f4             	pushl  -0xc(%ebp)
  80210a:	6a 00                	push   $0x0
  80210c:	e8 7f f0 ff ff       	call   801190 <sys_page_alloc>
  802111:	83 c4 10             	add    $0x10,%esp
		return r;
  802114:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802116:	85 c0                	test   %eax,%eax
  802118:	78 23                	js     80213d <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80211a:	8b 15 40 30 80 00    	mov    0x803040,%edx
  802120:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802123:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802125:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802128:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80212f:	83 ec 0c             	sub    $0xc,%esp
  802132:	50                   	push   %eax
  802133:	e8 4b f3 ff ff       	call   801483 <fd2num>
  802138:	89 c2                	mov    %eax,%edx
  80213a:	83 c4 10             	add    $0x10,%esp
}
  80213d:	89 d0                	mov    %edx,%eax
  80213f:	c9                   	leave  
  802140:	c3                   	ret    

00802141 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802141:	55                   	push   %ebp
  802142:	89 e5                	mov    %esp,%ebp
  802144:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802147:	89 d0                	mov    %edx,%eax
  802149:	c1 e8 16             	shr    $0x16,%eax
  80214c:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802153:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802158:	f6 c1 01             	test   $0x1,%cl
  80215b:	74 1d                	je     80217a <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80215d:	c1 ea 0c             	shr    $0xc,%edx
  802160:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802167:	f6 c2 01             	test   $0x1,%dl
  80216a:	74 0e                	je     80217a <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80216c:	c1 ea 0c             	shr    $0xc,%edx
  80216f:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802176:	ef 
  802177:	0f b7 c0             	movzwl %ax,%eax
}
  80217a:	5d                   	pop    %ebp
  80217b:	c3                   	ret    
  80217c:	66 90                	xchg   %ax,%ax
  80217e:	66 90                	xchg   %ax,%ax

00802180 <__udivdi3>:
  802180:	55                   	push   %ebp
  802181:	57                   	push   %edi
  802182:	56                   	push   %esi
  802183:	53                   	push   %ebx
  802184:	83 ec 1c             	sub    $0x1c,%esp
  802187:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80218b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80218f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802193:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802197:	85 f6                	test   %esi,%esi
  802199:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80219d:	89 ca                	mov    %ecx,%edx
  80219f:	89 f8                	mov    %edi,%eax
  8021a1:	75 3d                	jne    8021e0 <__udivdi3+0x60>
  8021a3:	39 cf                	cmp    %ecx,%edi
  8021a5:	0f 87 c5 00 00 00    	ja     802270 <__udivdi3+0xf0>
  8021ab:	85 ff                	test   %edi,%edi
  8021ad:	89 fd                	mov    %edi,%ebp
  8021af:	75 0b                	jne    8021bc <__udivdi3+0x3c>
  8021b1:	b8 01 00 00 00       	mov    $0x1,%eax
  8021b6:	31 d2                	xor    %edx,%edx
  8021b8:	f7 f7                	div    %edi
  8021ba:	89 c5                	mov    %eax,%ebp
  8021bc:	89 c8                	mov    %ecx,%eax
  8021be:	31 d2                	xor    %edx,%edx
  8021c0:	f7 f5                	div    %ebp
  8021c2:	89 c1                	mov    %eax,%ecx
  8021c4:	89 d8                	mov    %ebx,%eax
  8021c6:	89 cf                	mov    %ecx,%edi
  8021c8:	f7 f5                	div    %ebp
  8021ca:	89 c3                	mov    %eax,%ebx
  8021cc:	89 d8                	mov    %ebx,%eax
  8021ce:	89 fa                	mov    %edi,%edx
  8021d0:	83 c4 1c             	add    $0x1c,%esp
  8021d3:	5b                   	pop    %ebx
  8021d4:	5e                   	pop    %esi
  8021d5:	5f                   	pop    %edi
  8021d6:	5d                   	pop    %ebp
  8021d7:	c3                   	ret    
  8021d8:	90                   	nop
  8021d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021e0:	39 ce                	cmp    %ecx,%esi
  8021e2:	77 74                	ja     802258 <__udivdi3+0xd8>
  8021e4:	0f bd fe             	bsr    %esi,%edi
  8021e7:	83 f7 1f             	xor    $0x1f,%edi
  8021ea:	0f 84 98 00 00 00    	je     802288 <__udivdi3+0x108>
  8021f0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8021f5:	89 f9                	mov    %edi,%ecx
  8021f7:	89 c5                	mov    %eax,%ebp
  8021f9:	29 fb                	sub    %edi,%ebx
  8021fb:	d3 e6                	shl    %cl,%esi
  8021fd:	89 d9                	mov    %ebx,%ecx
  8021ff:	d3 ed                	shr    %cl,%ebp
  802201:	89 f9                	mov    %edi,%ecx
  802203:	d3 e0                	shl    %cl,%eax
  802205:	09 ee                	or     %ebp,%esi
  802207:	89 d9                	mov    %ebx,%ecx
  802209:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80220d:	89 d5                	mov    %edx,%ebp
  80220f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802213:	d3 ed                	shr    %cl,%ebp
  802215:	89 f9                	mov    %edi,%ecx
  802217:	d3 e2                	shl    %cl,%edx
  802219:	89 d9                	mov    %ebx,%ecx
  80221b:	d3 e8                	shr    %cl,%eax
  80221d:	09 c2                	or     %eax,%edx
  80221f:	89 d0                	mov    %edx,%eax
  802221:	89 ea                	mov    %ebp,%edx
  802223:	f7 f6                	div    %esi
  802225:	89 d5                	mov    %edx,%ebp
  802227:	89 c3                	mov    %eax,%ebx
  802229:	f7 64 24 0c          	mull   0xc(%esp)
  80222d:	39 d5                	cmp    %edx,%ebp
  80222f:	72 10                	jb     802241 <__udivdi3+0xc1>
  802231:	8b 74 24 08          	mov    0x8(%esp),%esi
  802235:	89 f9                	mov    %edi,%ecx
  802237:	d3 e6                	shl    %cl,%esi
  802239:	39 c6                	cmp    %eax,%esi
  80223b:	73 07                	jae    802244 <__udivdi3+0xc4>
  80223d:	39 d5                	cmp    %edx,%ebp
  80223f:	75 03                	jne    802244 <__udivdi3+0xc4>
  802241:	83 eb 01             	sub    $0x1,%ebx
  802244:	31 ff                	xor    %edi,%edi
  802246:	89 d8                	mov    %ebx,%eax
  802248:	89 fa                	mov    %edi,%edx
  80224a:	83 c4 1c             	add    $0x1c,%esp
  80224d:	5b                   	pop    %ebx
  80224e:	5e                   	pop    %esi
  80224f:	5f                   	pop    %edi
  802250:	5d                   	pop    %ebp
  802251:	c3                   	ret    
  802252:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802258:	31 ff                	xor    %edi,%edi
  80225a:	31 db                	xor    %ebx,%ebx
  80225c:	89 d8                	mov    %ebx,%eax
  80225e:	89 fa                	mov    %edi,%edx
  802260:	83 c4 1c             	add    $0x1c,%esp
  802263:	5b                   	pop    %ebx
  802264:	5e                   	pop    %esi
  802265:	5f                   	pop    %edi
  802266:	5d                   	pop    %ebp
  802267:	c3                   	ret    
  802268:	90                   	nop
  802269:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802270:	89 d8                	mov    %ebx,%eax
  802272:	f7 f7                	div    %edi
  802274:	31 ff                	xor    %edi,%edi
  802276:	89 c3                	mov    %eax,%ebx
  802278:	89 d8                	mov    %ebx,%eax
  80227a:	89 fa                	mov    %edi,%edx
  80227c:	83 c4 1c             	add    $0x1c,%esp
  80227f:	5b                   	pop    %ebx
  802280:	5e                   	pop    %esi
  802281:	5f                   	pop    %edi
  802282:	5d                   	pop    %ebp
  802283:	c3                   	ret    
  802284:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802288:	39 ce                	cmp    %ecx,%esi
  80228a:	72 0c                	jb     802298 <__udivdi3+0x118>
  80228c:	31 db                	xor    %ebx,%ebx
  80228e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802292:	0f 87 34 ff ff ff    	ja     8021cc <__udivdi3+0x4c>
  802298:	bb 01 00 00 00       	mov    $0x1,%ebx
  80229d:	e9 2a ff ff ff       	jmp    8021cc <__udivdi3+0x4c>
  8022a2:	66 90                	xchg   %ax,%ax
  8022a4:	66 90                	xchg   %ax,%ax
  8022a6:	66 90                	xchg   %ax,%ax
  8022a8:	66 90                	xchg   %ax,%ax
  8022aa:	66 90                	xchg   %ax,%ax
  8022ac:	66 90                	xchg   %ax,%ax
  8022ae:	66 90                	xchg   %ax,%ax

008022b0 <__umoddi3>:
  8022b0:	55                   	push   %ebp
  8022b1:	57                   	push   %edi
  8022b2:	56                   	push   %esi
  8022b3:	53                   	push   %ebx
  8022b4:	83 ec 1c             	sub    $0x1c,%esp
  8022b7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8022bb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8022bf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8022c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8022c7:	85 d2                	test   %edx,%edx
  8022c9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8022cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022d1:	89 f3                	mov    %esi,%ebx
  8022d3:	89 3c 24             	mov    %edi,(%esp)
  8022d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022da:	75 1c                	jne    8022f8 <__umoddi3+0x48>
  8022dc:	39 f7                	cmp    %esi,%edi
  8022de:	76 50                	jbe    802330 <__umoddi3+0x80>
  8022e0:	89 c8                	mov    %ecx,%eax
  8022e2:	89 f2                	mov    %esi,%edx
  8022e4:	f7 f7                	div    %edi
  8022e6:	89 d0                	mov    %edx,%eax
  8022e8:	31 d2                	xor    %edx,%edx
  8022ea:	83 c4 1c             	add    $0x1c,%esp
  8022ed:	5b                   	pop    %ebx
  8022ee:	5e                   	pop    %esi
  8022ef:	5f                   	pop    %edi
  8022f0:	5d                   	pop    %ebp
  8022f1:	c3                   	ret    
  8022f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022f8:	39 f2                	cmp    %esi,%edx
  8022fa:	89 d0                	mov    %edx,%eax
  8022fc:	77 52                	ja     802350 <__umoddi3+0xa0>
  8022fe:	0f bd ea             	bsr    %edx,%ebp
  802301:	83 f5 1f             	xor    $0x1f,%ebp
  802304:	75 5a                	jne    802360 <__umoddi3+0xb0>
  802306:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80230a:	0f 82 e0 00 00 00    	jb     8023f0 <__umoddi3+0x140>
  802310:	39 0c 24             	cmp    %ecx,(%esp)
  802313:	0f 86 d7 00 00 00    	jbe    8023f0 <__umoddi3+0x140>
  802319:	8b 44 24 08          	mov    0x8(%esp),%eax
  80231d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802321:	83 c4 1c             	add    $0x1c,%esp
  802324:	5b                   	pop    %ebx
  802325:	5e                   	pop    %esi
  802326:	5f                   	pop    %edi
  802327:	5d                   	pop    %ebp
  802328:	c3                   	ret    
  802329:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802330:	85 ff                	test   %edi,%edi
  802332:	89 fd                	mov    %edi,%ebp
  802334:	75 0b                	jne    802341 <__umoddi3+0x91>
  802336:	b8 01 00 00 00       	mov    $0x1,%eax
  80233b:	31 d2                	xor    %edx,%edx
  80233d:	f7 f7                	div    %edi
  80233f:	89 c5                	mov    %eax,%ebp
  802341:	89 f0                	mov    %esi,%eax
  802343:	31 d2                	xor    %edx,%edx
  802345:	f7 f5                	div    %ebp
  802347:	89 c8                	mov    %ecx,%eax
  802349:	f7 f5                	div    %ebp
  80234b:	89 d0                	mov    %edx,%eax
  80234d:	eb 99                	jmp    8022e8 <__umoddi3+0x38>
  80234f:	90                   	nop
  802350:	89 c8                	mov    %ecx,%eax
  802352:	89 f2                	mov    %esi,%edx
  802354:	83 c4 1c             	add    $0x1c,%esp
  802357:	5b                   	pop    %ebx
  802358:	5e                   	pop    %esi
  802359:	5f                   	pop    %edi
  80235a:	5d                   	pop    %ebp
  80235b:	c3                   	ret    
  80235c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802360:	8b 34 24             	mov    (%esp),%esi
  802363:	bf 20 00 00 00       	mov    $0x20,%edi
  802368:	89 e9                	mov    %ebp,%ecx
  80236a:	29 ef                	sub    %ebp,%edi
  80236c:	d3 e0                	shl    %cl,%eax
  80236e:	89 f9                	mov    %edi,%ecx
  802370:	89 f2                	mov    %esi,%edx
  802372:	d3 ea                	shr    %cl,%edx
  802374:	89 e9                	mov    %ebp,%ecx
  802376:	09 c2                	or     %eax,%edx
  802378:	89 d8                	mov    %ebx,%eax
  80237a:	89 14 24             	mov    %edx,(%esp)
  80237d:	89 f2                	mov    %esi,%edx
  80237f:	d3 e2                	shl    %cl,%edx
  802381:	89 f9                	mov    %edi,%ecx
  802383:	89 54 24 04          	mov    %edx,0x4(%esp)
  802387:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80238b:	d3 e8                	shr    %cl,%eax
  80238d:	89 e9                	mov    %ebp,%ecx
  80238f:	89 c6                	mov    %eax,%esi
  802391:	d3 e3                	shl    %cl,%ebx
  802393:	89 f9                	mov    %edi,%ecx
  802395:	89 d0                	mov    %edx,%eax
  802397:	d3 e8                	shr    %cl,%eax
  802399:	89 e9                	mov    %ebp,%ecx
  80239b:	09 d8                	or     %ebx,%eax
  80239d:	89 d3                	mov    %edx,%ebx
  80239f:	89 f2                	mov    %esi,%edx
  8023a1:	f7 34 24             	divl   (%esp)
  8023a4:	89 d6                	mov    %edx,%esi
  8023a6:	d3 e3                	shl    %cl,%ebx
  8023a8:	f7 64 24 04          	mull   0x4(%esp)
  8023ac:	39 d6                	cmp    %edx,%esi
  8023ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023b2:	89 d1                	mov    %edx,%ecx
  8023b4:	89 c3                	mov    %eax,%ebx
  8023b6:	72 08                	jb     8023c0 <__umoddi3+0x110>
  8023b8:	75 11                	jne    8023cb <__umoddi3+0x11b>
  8023ba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8023be:	73 0b                	jae    8023cb <__umoddi3+0x11b>
  8023c0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8023c4:	1b 14 24             	sbb    (%esp),%edx
  8023c7:	89 d1                	mov    %edx,%ecx
  8023c9:	89 c3                	mov    %eax,%ebx
  8023cb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8023cf:	29 da                	sub    %ebx,%edx
  8023d1:	19 ce                	sbb    %ecx,%esi
  8023d3:	89 f9                	mov    %edi,%ecx
  8023d5:	89 f0                	mov    %esi,%eax
  8023d7:	d3 e0                	shl    %cl,%eax
  8023d9:	89 e9                	mov    %ebp,%ecx
  8023db:	d3 ea                	shr    %cl,%edx
  8023dd:	89 e9                	mov    %ebp,%ecx
  8023df:	d3 ee                	shr    %cl,%esi
  8023e1:	09 d0                	or     %edx,%eax
  8023e3:	89 f2                	mov    %esi,%edx
  8023e5:	83 c4 1c             	add    $0x1c,%esp
  8023e8:	5b                   	pop    %ebx
  8023e9:	5e                   	pop    %esi
  8023ea:	5f                   	pop    %edi
  8023eb:	5d                   	pop    %ebp
  8023ec:	c3                   	ret    
  8023ed:	8d 76 00             	lea    0x0(%esi),%esi
  8023f0:	29 f9                	sub    %edi,%ecx
  8023f2:	19 d6                	sbb    %edx,%esi
  8023f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8023fc:	e9 18 ff ff ff       	jmp    802319 <__umoddi3+0x69>
