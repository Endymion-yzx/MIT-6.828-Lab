
obj/user/badsegment.debug:     file format elf32-i386


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
  80002c:	e8 0d 00 00 00       	call   80003e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800036:	66 b8 28 00          	mov    $0x28,%ax
  80003a:	8e d8                	mov    %eax,%ds
}
  80003c:	5d                   	pop    %ebp
  80003d:	c3                   	ret    

0080003e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003e:	55                   	push   %ebp
  80003f:	89 e5                	mov    %esp,%ebp
  800041:	56                   	push   %esi
  800042:	53                   	push   %ebx
  800043:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800046:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	envid_t envid = sys_getenvid();
  800049:	e8 ce 00 00 00       	call   80011c <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  80004e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800053:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800056:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005b:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800060:	85 db                	test   %ebx,%ebx
  800062:	7e 07                	jle    80006b <libmain+0x2d>
		binaryname = argv[0];
  800064:	8b 06                	mov    (%esi),%eax
  800066:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80006b:	83 ec 08             	sub    $0x8,%esp
  80006e:	56                   	push   %esi
  80006f:	53                   	push   %ebx
  800070:	e8 be ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800075:	e8 0a 00 00 00       	call   800084 <exit>
}
  80007a:	83 c4 10             	add    $0x10,%esp
  80007d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800080:	5b                   	pop    %ebx
  800081:	5e                   	pop    %esi
  800082:	5d                   	pop    %ebp
  800083:	c3                   	ret    

00800084 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800084:	55                   	push   %ebp
  800085:	89 e5                	mov    %esp,%ebp
  800087:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80008a:	e8 87 04 00 00       	call   800516 <close_all>
	sys_env_destroy(0);
  80008f:	83 ec 0c             	sub    $0xc,%esp
  800092:	6a 00                	push   $0x0
  800094:	e8 42 00 00 00       	call   8000db <sys_env_destroy>
}
  800099:	83 c4 10             	add    $0x10,%esp
  80009c:	c9                   	leave  
  80009d:	c3                   	ret    

0080009e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80009e:	55                   	push   %ebp
  80009f:	89 e5                	mov    %esp,%ebp
  8000a1:	57                   	push   %edi
  8000a2:	56                   	push   %esi
  8000a3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8000af:	89 c3                	mov    %eax,%ebx
  8000b1:	89 c7                	mov    %eax,%edi
  8000b3:	89 c6                	mov    %eax,%esi
  8000b5:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b7:	5b                   	pop    %ebx
  8000b8:	5e                   	pop    %esi
  8000b9:	5f                   	pop    %edi
  8000ba:	5d                   	pop    %ebp
  8000bb:	c3                   	ret    

008000bc <sys_cgetc>:

int
sys_cgetc(void)
{
  8000bc:	55                   	push   %ebp
  8000bd:	89 e5                	mov    %esp,%ebp
  8000bf:	57                   	push   %edi
  8000c0:	56                   	push   %esi
  8000c1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c7:	b8 01 00 00 00       	mov    $0x1,%eax
  8000cc:	89 d1                	mov    %edx,%ecx
  8000ce:	89 d3                	mov    %edx,%ebx
  8000d0:	89 d7                	mov    %edx,%edi
  8000d2:	89 d6                	mov    %edx,%esi
  8000d4:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d6:	5b                   	pop    %ebx
  8000d7:	5e                   	pop    %esi
  8000d8:	5f                   	pop    %edi
  8000d9:	5d                   	pop    %ebp
  8000da:	c3                   	ret    

008000db <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000db:	55                   	push   %ebp
  8000dc:	89 e5                	mov    %esp,%ebp
  8000de:	57                   	push   %edi
  8000df:	56                   	push   %esi
  8000e0:	53                   	push   %ebx
  8000e1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e9:	b8 03 00 00 00       	mov    $0x3,%eax
  8000ee:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f1:	89 cb                	mov    %ecx,%ebx
  8000f3:	89 cf                	mov    %ecx,%edi
  8000f5:	89 ce                	mov    %ecx,%esi
  8000f7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8000f9:	85 c0                	test   %eax,%eax
  8000fb:	7e 17                	jle    800114 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000fd:	83 ec 0c             	sub    $0xc,%esp
  800100:	50                   	push   %eax
  800101:	6a 03                	push   $0x3
  800103:	68 4a 1e 80 00       	push   $0x801e4a
  800108:	6a 23                	push   $0x23
  80010a:	68 67 1e 80 00       	push   $0x801e67
  80010f:	e8 f5 0e 00 00       	call   801009 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800114:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800117:	5b                   	pop    %ebx
  800118:	5e                   	pop    %esi
  800119:	5f                   	pop    %edi
  80011a:	5d                   	pop    %ebp
  80011b:	c3                   	ret    

0080011c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80011c:	55                   	push   %ebp
  80011d:	89 e5                	mov    %esp,%ebp
  80011f:	57                   	push   %edi
  800120:	56                   	push   %esi
  800121:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800122:	ba 00 00 00 00       	mov    $0x0,%edx
  800127:	b8 02 00 00 00       	mov    $0x2,%eax
  80012c:	89 d1                	mov    %edx,%ecx
  80012e:	89 d3                	mov    %edx,%ebx
  800130:	89 d7                	mov    %edx,%edi
  800132:	89 d6                	mov    %edx,%esi
  800134:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800136:	5b                   	pop    %ebx
  800137:	5e                   	pop    %esi
  800138:	5f                   	pop    %edi
  800139:	5d                   	pop    %ebp
  80013a:	c3                   	ret    

0080013b <sys_yield>:

void
sys_yield(void)
{
  80013b:	55                   	push   %ebp
  80013c:	89 e5                	mov    %esp,%ebp
  80013e:	57                   	push   %edi
  80013f:	56                   	push   %esi
  800140:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800141:	ba 00 00 00 00       	mov    $0x0,%edx
  800146:	b8 0b 00 00 00       	mov    $0xb,%eax
  80014b:	89 d1                	mov    %edx,%ecx
  80014d:	89 d3                	mov    %edx,%ebx
  80014f:	89 d7                	mov    %edx,%edi
  800151:	89 d6                	mov    %edx,%esi
  800153:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800155:	5b                   	pop    %ebx
  800156:	5e                   	pop    %esi
  800157:	5f                   	pop    %edi
  800158:	5d                   	pop    %ebp
  800159:	c3                   	ret    

0080015a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80015a:	55                   	push   %ebp
  80015b:	89 e5                	mov    %esp,%ebp
  80015d:	57                   	push   %edi
  80015e:	56                   	push   %esi
  80015f:	53                   	push   %ebx
  800160:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800163:	be 00 00 00 00       	mov    $0x0,%esi
  800168:	b8 04 00 00 00       	mov    $0x4,%eax
  80016d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800170:	8b 55 08             	mov    0x8(%ebp),%edx
  800173:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800176:	89 f7                	mov    %esi,%edi
  800178:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80017a:	85 c0                	test   %eax,%eax
  80017c:	7e 17                	jle    800195 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80017e:	83 ec 0c             	sub    $0xc,%esp
  800181:	50                   	push   %eax
  800182:	6a 04                	push   $0x4
  800184:	68 4a 1e 80 00       	push   $0x801e4a
  800189:	6a 23                	push   $0x23
  80018b:	68 67 1e 80 00       	push   $0x801e67
  800190:	e8 74 0e 00 00       	call   801009 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800195:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800198:	5b                   	pop    %ebx
  800199:	5e                   	pop    %esi
  80019a:	5f                   	pop    %edi
  80019b:	5d                   	pop    %ebp
  80019c:	c3                   	ret    

0080019d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80019d:	55                   	push   %ebp
  80019e:	89 e5                	mov    %esp,%ebp
  8001a0:	57                   	push   %edi
  8001a1:	56                   	push   %esi
  8001a2:	53                   	push   %ebx
  8001a3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001a6:	b8 05 00 00 00       	mov    $0x5,%eax
  8001ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001b7:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ba:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001bc:	85 c0                	test   %eax,%eax
  8001be:	7e 17                	jle    8001d7 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c0:	83 ec 0c             	sub    $0xc,%esp
  8001c3:	50                   	push   %eax
  8001c4:	6a 05                	push   $0x5
  8001c6:	68 4a 1e 80 00       	push   $0x801e4a
  8001cb:	6a 23                	push   $0x23
  8001cd:	68 67 1e 80 00       	push   $0x801e67
  8001d2:	e8 32 0e 00 00       	call   801009 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001da:	5b                   	pop    %ebx
  8001db:	5e                   	pop    %esi
  8001dc:	5f                   	pop    %edi
  8001dd:	5d                   	pop    %ebp
  8001de:	c3                   	ret    

008001df <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001df:	55                   	push   %ebp
  8001e0:	89 e5                	mov    %esp,%ebp
  8001e2:	57                   	push   %edi
  8001e3:	56                   	push   %esi
  8001e4:	53                   	push   %ebx
  8001e5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001ed:	b8 06 00 00 00       	mov    $0x6,%eax
  8001f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f8:	89 df                	mov    %ebx,%edi
  8001fa:	89 de                	mov    %ebx,%esi
  8001fc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001fe:	85 c0                	test   %eax,%eax
  800200:	7e 17                	jle    800219 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800202:	83 ec 0c             	sub    $0xc,%esp
  800205:	50                   	push   %eax
  800206:	6a 06                	push   $0x6
  800208:	68 4a 1e 80 00       	push   $0x801e4a
  80020d:	6a 23                	push   $0x23
  80020f:	68 67 1e 80 00       	push   $0x801e67
  800214:	e8 f0 0d 00 00       	call   801009 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800219:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80021c:	5b                   	pop    %ebx
  80021d:	5e                   	pop    %esi
  80021e:	5f                   	pop    %edi
  80021f:	5d                   	pop    %ebp
  800220:	c3                   	ret    

00800221 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800221:	55                   	push   %ebp
  800222:	89 e5                	mov    %esp,%ebp
  800224:	57                   	push   %edi
  800225:	56                   	push   %esi
  800226:	53                   	push   %ebx
  800227:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80022a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022f:	b8 08 00 00 00       	mov    $0x8,%eax
  800234:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800237:	8b 55 08             	mov    0x8(%ebp),%edx
  80023a:	89 df                	mov    %ebx,%edi
  80023c:	89 de                	mov    %ebx,%esi
  80023e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800240:	85 c0                	test   %eax,%eax
  800242:	7e 17                	jle    80025b <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800244:	83 ec 0c             	sub    $0xc,%esp
  800247:	50                   	push   %eax
  800248:	6a 08                	push   $0x8
  80024a:	68 4a 1e 80 00       	push   $0x801e4a
  80024f:	6a 23                	push   $0x23
  800251:	68 67 1e 80 00       	push   $0x801e67
  800256:	e8 ae 0d 00 00       	call   801009 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80025b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80025e:	5b                   	pop    %ebx
  80025f:	5e                   	pop    %esi
  800260:	5f                   	pop    %edi
  800261:	5d                   	pop    %ebp
  800262:	c3                   	ret    

00800263 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800263:	55                   	push   %ebp
  800264:	89 e5                	mov    %esp,%ebp
  800266:	57                   	push   %edi
  800267:	56                   	push   %esi
  800268:	53                   	push   %ebx
  800269:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80026c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800271:	b8 09 00 00 00       	mov    $0x9,%eax
  800276:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800279:	8b 55 08             	mov    0x8(%ebp),%edx
  80027c:	89 df                	mov    %ebx,%edi
  80027e:	89 de                	mov    %ebx,%esi
  800280:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800282:	85 c0                	test   %eax,%eax
  800284:	7e 17                	jle    80029d <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800286:	83 ec 0c             	sub    $0xc,%esp
  800289:	50                   	push   %eax
  80028a:	6a 09                	push   $0x9
  80028c:	68 4a 1e 80 00       	push   $0x801e4a
  800291:	6a 23                	push   $0x23
  800293:	68 67 1e 80 00       	push   $0x801e67
  800298:	e8 6c 0d 00 00       	call   801009 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80029d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a0:	5b                   	pop    %ebx
  8002a1:	5e                   	pop    %esi
  8002a2:	5f                   	pop    %edi
  8002a3:	5d                   	pop    %ebp
  8002a4:	c3                   	ret    

008002a5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002a5:	55                   	push   %ebp
  8002a6:	89 e5                	mov    %esp,%ebp
  8002a8:	57                   	push   %edi
  8002a9:	56                   	push   %esi
  8002aa:	53                   	push   %ebx
  8002ab:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002ae:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002b3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002bb:	8b 55 08             	mov    0x8(%ebp),%edx
  8002be:	89 df                	mov    %ebx,%edi
  8002c0:	89 de                	mov    %ebx,%esi
  8002c2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002c4:	85 c0                	test   %eax,%eax
  8002c6:	7e 17                	jle    8002df <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002c8:	83 ec 0c             	sub    $0xc,%esp
  8002cb:	50                   	push   %eax
  8002cc:	6a 0a                	push   $0xa
  8002ce:	68 4a 1e 80 00       	push   $0x801e4a
  8002d3:	6a 23                	push   $0x23
  8002d5:	68 67 1e 80 00       	push   $0x801e67
  8002da:	e8 2a 0d 00 00       	call   801009 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e2:	5b                   	pop    %ebx
  8002e3:	5e                   	pop    %esi
  8002e4:	5f                   	pop    %edi
  8002e5:	5d                   	pop    %ebp
  8002e6:	c3                   	ret    

008002e7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002e7:	55                   	push   %ebp
  8002e8:	89 e5                	mov    %esp,%ebp
  8002ea:	57                   	push   %edi
  8002eb:	56                   	push   %esi
  8002ec:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002ed:	be 00 00 00 00       	mov    $0x0,%esi
  8002f2:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8002fd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800300:	8b 7d 14             	mov    0x14(%ebp),%edi
  800303:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800305:	5b                   	pop    %ebx
  800306:	5e                   	pop    %esi
  800307:	5f                   	pop    %edi
  800308:	5d                   	pop    %ebp
  800309:	c3                   	ret    

0080030a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80030a:	55                   	push   %ebp
  80030b:	89 e5                	mov    %esp,%ebp
  80030d:	57                   	push   %edi
  80030e:	56                   	push   %esi
  80030f:	53                   	push   %ebx
  800310:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800313:	b9 00 00 00 00       	mov    $0x0,%ecx
  800318:	b8 0d 00 00 00       	mov    $0xd,%eax
  80031d:	8b 55 08             	mov    0x8(%ebp),%edx
  800320:	89 cb                	mov    %ecx,%ebx
  800322:	89 cf                	mov    %ecx,%edi
  800324:	89 ce                	mov    %ecx,%esi
  800326:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800328:	85 c0                	test   %eax,%eax
  80032a:	7e 17                	jle    800343 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80032c:	83 ec 0c             	sub    $0xc,%esp
  80032f:	50                   	push   %eax
  800330:	6a 0d                	push   $0xd
  800332:	68 4a 1e 80 00       	push   $0x801e4a
  800337:	6a 23                	push   $0x23
  800339:	68 67 1e 80 00       	push   $0x801e67
  80033e:	e8 c6 0c 00 00       	call   801009 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800343:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800346:	5b                   	pop    %ebx
  800347:	5e                   	pop    %esi
  800348:	5f                   	pop    %edi
  800349:	5d                   	pop    %ebp
  80034a:	c3                   	ret    

0080034b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80034b:	55                   	push   %ebp
  80034c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80034e:	8b 45 08             	mov    0x8(%ebp),%eax
  800351:	05 00 00 00 30       	add    $0x30000000,%eax
  800356:	c1 e8 0c             	shr    $0xc,%eax
}
  800359:	5d                   	pop    %ebp
  80035a:	c3                   	ret    

0080035b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80035b:	55                   	push   %ebp
  80035c:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80035e:	8b 45 08             	mov    0x8(%ebp),%eax
  800361:	05 00 00 00 30       	add    $0x30000000,%eax
  800366:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80036b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800370:	5d                   	pop    %ebp
  800371:	c3                   	ret    

00800372 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800372:	55                   	push   %ebp
  800373:	89 e5                	mov    %esp,%ebp
  800375:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800378:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80037d:	89 c2                	mov    %eax,%edx
  80037f:	c1 ea 16             	shr    $0x16,%edx
  800382:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800389:	f6 c2 01             	test   $0x1,%dl
  80038c:	74 11                	je     80039f <fd_alloc+0x2d>
  80038e:	89 c2                	mov    %eax,%edx
  800390:	c1 ea 0c             	shr    $0xc,%edx
  800393:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80039a:	f6 c2 01             	test   $0x1,%dl
  80039d:	75 09                	jne    8003a8 <fd_alloc+0x36>
			*fd_store = fd;
  80039f:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8003a6:	eb 17                	jmp    8003bf <fd_alloc+0x4d>
  8003a8:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003ad:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003b2:	75 c9                	jne    80037d <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003b4:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003ba:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003bf:	5d                   	pop    %ebp
  8003c0:	c3                   	ret    

008003c1 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003c1:	55                   	push   %ebp
  8003c2:	89 e5                	mov    %esp,%ebp
  8003c4:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003c7:	83 f8 1f             	cmp    $0x1f,%eax
  8003ca:	77 36                	ja     800402 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003cc:	c1 e0 0c             	shl    $0xc,%eax
  8003cf:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003d4:	89 c2                	mov    %eax,%edx
  8003d6:	c1 ea 16             	shr    $0x16,%edx
  8003d9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003e0:	f6 c2 01             	test   $0x1,%dl
  8003e3:	74 24                	je     800409 <fd_lookup+0x48>
  8003e5:	89 c2                	mov    %eax,%edx
  8003e7:	c1 ea 0c             	shr    $0xc,%edx
  8003ea:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003f1:	f6 c2 01             	test   $0x1,%dl
  8003f4:	74 1a                	je     800410 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003f9:	89 02                	mov    %eax,(%edx)
	return 0;
  8003fb:	b8 00 00 00 00       	mov    $0x0,%eax
  800400:	eb 13                	jmp    800415 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800402:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800407:	eb 0c                	jmp    800415 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800409:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80040e:	eb 05                	jmp    800415 <fd_lookup+0x54>
  800410:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800415:	5d                   	pop    %ebp
  800416:	c3                   	ret    

00800417 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800417:	55                   	push   %ebp
  800418:	89 e5                	mov    %esp,%ebp
  80041a:	83 ec 08             	sub    $0x8,%esp
  80041d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800420:	ba f4 1e 80 00       	mov    $0x801ef4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800425:	eb 13                	jmp    80043a <dev_lookup+0x23>
  800427:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80042a:	39 08                	cmp    %ecx,(%eax)
  80042c:	75 0c                	jne    80043a <dev_lookup+0x23>
			*dev = devtab[i];
  80042e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800431:	89 01                	mov    %eax,(%ecx)
			return 0;
  800433:	b8 00 00 00 00       	mov    $0x0,%eax
  800438:	eb 2e                	jmp    800468 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80043a:	8b 02                	mov    (%edx),%eax
  80043c:	85 c0                	test   %eax,%eax
  80043e:	75 e7                	jne    800427 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800440:	a1 04 40 80 00       	mov    0x804004,%eax
  800445:	8b 40 48             	mov    0x48(%eax),%eax
  800448:	83 ec 04             	sub    $0x4,%esp
  80044b:	51                   	push   %ecx
  80044c:	50                   	push   %eax
  80044d:	68 78 1e 80 00       	push   $0x801e78
  800452:	e8 8b 0c 00 00       	call   8010e2 <cprintf>
	*dev = 0;
  800457:	8b 45 0c             	mov    0xc(%ebp),%eax
  80045a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800460:	83 c4 10             	add    $0x10,%esp
  800463:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800468:	c9                   	leave  
  800469:	c3                   	ret    

0080046a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80046a:	55                   	push   %ebp
  80046b:	89 e5                	mov    %esp,%ebp
  80046d:	56                   	push   %esi
  80046e:	53                   	push   %ebx
  80046f:	83 ec 10             	sub    $0x10,%esp
  800472:	8b 75 08             	mov    0x8(%ebp),%esi
  800475:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800478:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80047b:	50                   	push   %eax
  80047c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800482:	c1 e8 0c             	shr    $0xc,%eax
  800485:	50                   	push   %eax
  800486:	e8 36 ff ff ff       	call   8003c1 <fd_lookup>
  80048b:	83 c4 08             	add    $0x8,%esp
  80048e:	85 c0                	test   %eax,%eax
  800490:	78 05                	js     800497 <fd_close+0x2d>
	    || fd != fd2)
  800492:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800495:	74 0c                	je     8004a3 <fd_close+0x39>
		return (must_exist ? r : 0);
  800497:	84 db                	test   %bl,%bl
  800499:	ba 00 00 00 00       	mov    $0x0,%edx
  80049e:	0f 44 c2             	cmove  %edx,%eax
  8004a1:	eb 41                	jmp    8004e4 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004a3:	83 ec 08             	sub    $0x8,%esp
  8004a6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004a9:	50                   	push   %eax
  8004aa:	ff 36                	pushl  (%esi)
  8004ac:	e8 66 ff ff ff       	call   800417 <dev_lookup>
  8004b1:	89 c3                	mov    %eax,%ebx
  8004b3:	83 c4 10             	add    $0x10,%esp
  8004b6:	85 c0                	test   %eax,%eax
  8004b8:	78 1a                	js     8004d4 <fd_close+0x6a>
		if (dev->dev_close)
  8004ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004bd:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004c0:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004c5:	85 c0                	test   %eax,%eax
  8004c7:	74 0b                	je     8004d4 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004c9:	83 ec 0c             	sub    $0xc,%esp
  8004cc:	56                   	push   %esi
  8004cd:	ff d0                	call   *%eax
  8004cf:	89 c3                	mov    %eax,%ebx
  8004d1:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004d4:	83 ec 08             	sub    $0x8,%esp
  8004d7:	56                   	push   %esi
  8004d8:	6a 00                	push   $0x0
  8004da:	e8 00 fd ff ff       	call   8001df <sys_page_unmap>
	return r;
  8004df:	83 c4 10             	add    $0x10,%esp
  8004e2:	89 d8                	mov    %ebx,%eax
}
  8004e4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004e7:	5b                   	pop    %ebx
  8004e8:	5e                   	pop    %esi
  8004e9:	5d                   	pop    %ebp
  8004ea:	c3                   	ret    

008004eb <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8004eb:	55                   	push   %ebp
  8004ec:	89 e5                	mov    %esp,%ebp
  8004ee:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004f4:	50                   	push   %eax
  8004f5:	ff 75 08             	pushl  0x8(%ebp)
  8004f8:	e8 c4 fe ff ff       	call   8003c1 <fd_lookup>
  8004fd:	83 c4 08             	add    $0x8,%esp
  800500:	85 c0                	test   %eax,%eax
  800502:	78 10                	js     800514 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800504:	83 ec 08             	sub    $0x8,%esp
  800507:	6a 01                	push   $0x1
  800509:	ff 75 f4             	pushl  -0xc(%ebp)
  80050c:	e8 59 ff ff ff       	call   80046a <fd_close>
  800511:	83 c4 10             	add    $0x10,%esp
}
  800514:	c9                   	leave  
  800515:	c3                   	ret    

00800516 <close_all>:

void
close_all(void)
{
  800516:	55                   	push   %ebp
  800517:	89 e5                	mov    %esp,%ebp
  800519:	53                   	push   %ebx
  80051a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80051d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800522:	83 ec 0c             	sub    $0xc,%esp
  800525:	53                   	push   %ebx
  800526:	e8 c0 ff ff ff       	call   8004eb <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80052b:	83 c3 01             	add    $0x1,%ebx
  80052e:	83 c4 10             	add    $0x10,%esp
  800531:	83 fb 20             	cmp    $0x20,%ebx
  800534:	75 ec                	jne    800522 <close_all+0xc>
		close(i);
}
  800536:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800539:	c9                   	leave  
  80053a:	c3                   	ret    

0080053b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80053b:	55                   	push   %ebp
  80053c:	89 e5                	mov    %esp,%ebp
  80053e:	57                   	push   %edi
  80053f:	56                   	push   %esi
  800540:	53                   	push   %ebx
  800541:	83 ec 2c             	sub    $0x2c,%esp
  800544:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800547:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80054a:	50                   	push   %eax
  80054b:	ff 75 08             	pushl  0x8(%ebp)
  80054e:	e8 6e fe ff ff       	call   8003c1 <fd_lookup>
  800553:	83 c4 08             	add    $0x8,%esp
  800556:	85 c0                	test   %eax,%eax
  800558:	0f 88 c1 00 00 00    	js     80061f <dup+0xe4>
		return r;
	close(newfdnum);
  80055e:	83 ec 0c             	sub    $0xc,%esp
  800561:	56                   	push   %esi
  800562:	e8 84 ff ff ff       	call   8004eb <close>

	newfd = INDEX2FD(newfdnum);
  800567:	89 f3                	mov    %esi,%ebx
  800569:	c1 e3 0c             	shl    $0xc,%ebx
  80056c:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800572:	83 c4 04             	add    $0x4,%esp
  800575:	ff 75 e4             	pushl  -0x1c(%ebp)
  800578:	e8 de fd ff ff       	call   80035b <fd2data>
  80057d:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80057f:	89 1c 24             	mov    %ebx,(%esp)
  800582:	e8 d4 fd ff ff       	call   80035b <fd2data>
  800587:	83 c4 10             	add    $0x10,%esp
  80058a:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80058d:	89 f8                	mov    %edi,%eax
  80058f:	c1 e8 16             	shr    $0x16,%eax
  800592:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800599:	a8 01                	test   $0x1,%al
  80059b:	74 37                	je     8005d4 <dup+0x99>
  80059d:	89 f8                	mov    %edi,%eax
  80059f:	c1 e8 0c             	shr    $0xc,%eax
  8005a2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005a9:	f6 c2 01             	test   $0x1,%dl
  8005ac:	74 26                	je     8005d4 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005ae:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005b5:	83 ec 0c             	sub    $0xc,%esp
  8005b8:	25 07 0e 00 00       	and    $0xe07,%eax
  8005bd:	50                   	push   %eax
  8005be:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005c1:	6a 00                	push   $0x0
  8005c3:	57                   	push   %edi
  8005c4:	6a 00                	push   $0x0
  8005c6:	e8 d2 fb ff ff       	call   80019d <sys_page_map>
  8005cb:	89 c7                	mov    %eax,%edi
  8005cd:	83 c4 20             	add    $0x20,%esp
  8005d0:	85 c0                	test   %eax,%eax
  8005d2:	78 2e                	js     800602 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005d4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005d7:	89 d0                	mov    %edx,%eax
  8005d9:	c1 e8 0c             	shr    $0xc,%eax
  8005dc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005e3:	83 ec 0c             	sub    $0xc,%esp
  8005e6:	25 07 0e 00 00       	and    $0xe07,%eax
  8005eb:	50                   	push   %eax
  8005ec:	53                   	push   %ebx
  8005ed:	6a 00                	push   $0x0
  8005ef:	52                   	push   %edx
  8005f0:	6a 00                	push   $0x0
  8005f2:	e8 a6 fb ff ff       	call   80019d <sys_page_map>
  8005f7:	89 c7                	mov    %eax,%edi
  8005f9:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8005fc:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005fe:	85 ff                	test   %edi,%edi
  800600:	79 1d                	jns    80061f <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800602:	83 ec 08             	sub    $0x8,%esp
  800605:	53                   	push   %ebx
  800606:	6a 00                	push   $0x0
  800608:	e8 d2 fb ff ff       	call   8001df <sys_page_unmap>
	sys_page_unmap(0, nva);
  80060d:	83 c4 08             	add    $0x8,%esp
  800610:	ff 75 d4             	pushl  -0x2c(%ebp)
  800613:	6a 00                	push   $0x0
  800615:	e8 c5 fb ff ff       	call   8001df <sys_page_unmap>
	return r;
  80061a:	83 c4 10             	add    $0x10,%esp
  80061d:	89 f8                	mov    %edi,%eax
}
  80061f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800622:	5b                   	pop    %ebx
  800623:	5e                   	pop    %esi
  800624:	5f                   	pop    %edi
  800625:	5d                   	pop    %ebp
  800626:	c3                   	ret    

00800627 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800627:	55                   	push   %ebp
  800628:	89 e5                	mov    %esp,%ebp
  80062a:	53                   	push   %ebx
  80062b:	83 ec 14             	sub    $0x14,%esp
  80062e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800631:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800634:	50                   	push   %eax
  800635:	53                   	push   %ebx
  800636:	e8 86 fd ff ff       	call   8003c1 <fd_lookup>
  80063b:	83 c4 08             	add    $0x8,%esp
  80063e:	89 c2                	mov    %eax,%edx
  800640:	85 c0                	test   %eax,%eax
  800642:	78 6d                	js     8006b1 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800644:	83 ec 08             	sub    $0x8,%esp
  800647:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80064a:	50                   	push   %eax
  80064b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80064e:	ff 30                	pushl  (%eax)
  800650:	e8 c2 fd ff ff       	call   800417 <dev_lookup>
  800655:	83 c4 10             	add    $0x10,%esp
  800658:	85 c0                	test   %eax,%eax
  80065a:	78 4c                	js     8006a8 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80065c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80065f:	8b 42 08             	mov    0x8(%edx),%eax
  800662:	83 e0 03             	and    $0x3,%eax
  800665:	83 f8 01             	cmp    $0x1,%eax
  800668:	75 21                	jne    80068b <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80066a:	a1 04 40 80 00       	mov    0x804004,%eax
  80066f:	8b 40 48             	mov    0x48(%eax),%eax
  800672:	83 ec 04             	sub    $0x4,%esp
  800675:	53                   	push   %ebx
  800676:	50                   	push   %eax
  800677:	68 b9 1e 80 00       	push   $0x801eb9
  80067c:	e8 61 0a 00 00       	call   8010e2 <cprintf>
		return -E_INVAL;
  800681:	83 c4 10             	add    $0x10,%esp
  800684:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800689:	eb 26                	jmp    8006b1 <read+0x8a>
	}
	if (!dev->dev_read)
  80068b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80068e:	8b 40 08             	mov    0x8(%eax),%eax
  800691:	85 c0                	test   %eax,%eax
  800693:	74 17                	je     8006ac <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800695:	83 ec 04             	sub    $0x4,%esp
  800698:	ff 75 10             	pushl  0x10(%ebp)
  80069b:	ff 75 0c             	pushl  0xc(%ebp)
  80069e:	52                   	push   %edx
  80069f:	ff d0                	call   *%eax
  8006a1:	89 c2                	mov    %eax,%edx
  8006a3:	83 c4 10             	add    $0x10,%esp
  8006a6:	eb 09                	jmp    8006b1 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006a8:	89 c2                	mov    %eax,%edx
  8006aa:	eb 05                	jmp    8006b1 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006ac:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006b1:	89 d0                	mov    %edx,%eax
  8006b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006b6:	c9                   	leave  
  8006b7:	c3                   	ret    

008006b8 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006b8:	55                   	push   %ebp
  8006b9:	89 e5                	mov    %esp,%ebp
  8006bb:	57                   	push   %edi
  8006bc:	56                   	push   %esi
  8006bd:	53                   	push   %ebx
  8006be:	83 ec 0c             	sub    $0xc,%esp
  8006c1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006c4:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006c7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006cc:	eb 21                	jmp    8006ef <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006ce:	83 ec 04             	sub    $0x4,%esp
  8006d1:	89 f0                	mov    %esi,%eax
  8006d3:	29 d8                	sub    %ebx,%eax
  8006d5:	50                   	push   %eax
  8006d6:	89 d8                	mov    %ebx,%eax
  8006d8:	03 45 0c             	add    0xc(%ebp),%eax
  8006db:	50                   	push   %eax
  8006dc:	57                   	push   %edi
  8006dd:	e8 45 ff ff ff       	call   800627 <read>
		if (m < 0)
  8006e2:	83 c4 10             	add    $0x10,%esp
  8006e5:	85 c0                	test   %eax,%eax
  8006e7:	78 10                	js     8006f9 <readn+0x41>
			return m;
		if (m == 0)
  8006e9:	85 c0                	test   %eax,%eax
  8006eb:	74 0a                	je     8006f7 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006ed:	01 c3                	add    %eax,%ebx
  8006ef:	39 f3                	cmp    %esi,%ebx
  8006f1:	72 db                	jb     8006ce <readn+0x16>
  8006f3:	89 d8                	mov    %ebx,%eax
  8006f5:	eb 02                	jmp    8006f9 <readn+0x41>
  8006f7:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8006f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006fc:	5b                   	pop    %ebx
  8006fd:	5e                   	pop    %esi
  8006fe:	5f                   	pop    %edi
  8006ff:	5d                   	pop    %ebp
  800700:	c3                   	ret    

00800701 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800701:	55                   	push   %ebp
  800702:	89 e5                	mov    %esp,%ebp
  800704:	53                   	push   %ebx
  800705:	83 ec 14             	sub    $0x14,%esp
  800708:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80070b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80070e:	50                   	push   %eax
  80070f:	53                   	push   %ebx
  800710:	e8 ac fc ff ff       	call   8003c1 <fd_lookup>
  800715:	83 c4 08             	add    $0x8,%esp
  800718:	89 c2                	mov    %eax,%edx
  80071a:	85 c0                	test   %eax,%eax
  80071c:	78 68                	js     800786 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80071e:	83 ec 08             	sub    $0x8,%esp
  800721:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800724:	50                   	push   %eax
  800725:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800728:	ff 30                	pushl  (%eax)
  80072a:	e8 e8 fc ff ff       	call   800417 <dev_lookup>
  80072f:	83 c4 10             	add    $0x10,%esp
  800732:	85 c0                	test   %eax,%eax
  800734:	78 47                	js     80077d <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800736:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800739:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80073d:	75 21                	jne    800760 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80073f:	a1 04 40 80 00       	mov    0x804004,%eax
  800744:	8b 40 48             	mov    0x48(%eax),%eax
  800747:	83 ec 04             	sub    $0x4,%esp
  80074a:	53                   	push   %ebx
  80074b:	50                   	push   %eax
  80074c:	68 d5 1e 80 00       	push   $0x801ed5
  800751:	e8 8c 09 00 00       	call   8010e2 <cprintf>
		return -E_INVAL;
  800756:	83 c4 10             	add    $0x10,%esp
  800759:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80075e:	eb 26                	jmp    800786 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800760:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800763:	8b 52 0c             	mov    0xc(%edx),%edx
  800766:	85 d2                	test   %edx,%edx
  800768:	74 17                	je     800781 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80076a:	83 ec 04             	sub    $0x4,%esp
  80076d:	ff 75 10             	pushl  0x10(%ebp)
  800770:	ff 75 0c             	pushl  0xc(%ebp)
  800773:	50                   	push   %eax
  800774:	ff d2                	call   *%edx
  800776:	89 c2                	mov    %eax,%edx
  800778:	83 c4 10             	add    $0x10,%esp
  80077b:	eb 09                	jmp    800786 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80077d:	89 c2                	mov    %eax,%edx
  80077f:	eb 05                	jmp    800786 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800781:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800786:	89 d0                	mov    %edx,%eax
  800788:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80078b:	c9                   	leave  
  80078c:	c3                   	ret    

0080078d <seek>:

int
seek(int fdnum, off_t offset)
{
  80078d:	55                   	push   %ebp
  80078e:	89 e5                	mov    %esp,%ebp
  800790:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800793:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800796:	50                   	push   %eax
  800797:	ff 75 08             	pushl  0x8(%ebp)
  80079a:	e8 22 fc ff ff       	call   8003c1 <fd_lookup>
  80079f:	83 c4 08             	add    $0x8,%esp
  8007a2:	85 c0                	test   %eax,%eax
  8007a4:	78 0e                	js     8007b4 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007a6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ac:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007af:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007b4:	c9                   	leave  
  8007b5:	c3                   	ret    

008007b6 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007b6:	55                   	push   %ebp
  8007b7:	89 e5                	mov    %esp,%ebp
  8007b9:	53                   	push   %ebx
  8007ba:	83 ec 14             	sub    $0x14,%esp
  8007bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007c0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007c3:	50                   	push   %eax
  8007c4:	53                   	push   %ebx
  8007c5:	e8 f7 fb ff ff       	call   8003c1 <fd_lookup>
  8007ca:	83 c4 08             	add    $0x8,%esp
  8007cd:	89 c2                	mov    %eax,%edx
  8007cf:	85 c0                	test   %eax,%eax
  8007d1:	78 65                	js     800838 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007d3:	83 ec 08             	sub    $0x8,%esp
  8007d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007d9:	50                   	push   %eax
  8007da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007dd:	ff 30                	pushl  (%eax)
  8007df:	e8 33 fc ff ff       	call   800417 <dev_lookup>
  8007e4:	83 c4 10             	add    $0x10,%esp
  8007e7:	85 c0                	test   %eax,%eax
  8007e9:	78 44                	js     80082f <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007ee:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007f2:	75 21                	jne    800815 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8007f4:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8007f9:	8b 40 48             	mov    0x48(%eax),%eax
  8007fc:	83 ec 04             	sub    $0x4,%esp
  8007ff:	53                   	push   %ebx
  800800:	50                   	push   %eax
  800801:	68 98 1e 80 00       	push   $0x801e98
  800806:	e8 d7 08 00 00       	call   8010e2 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80080b:	83 c4 10             	add    $0x10,%esp
  80080e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800813:	eb 23                	jmp    800838 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800815:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800818:	8b 52 18             	mov    0x18(%edx),%edx
  80081b:	85 d2                	test   %edx,%edx
  80081d:	74 14                	je     800833 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80081f:	83 ec 08             	sub    $0x8,%esp
  800822:	ff 75 0c             	pushl  0xc(%ebp)
  800825:	50                   	push   %eax
  800826:	ff d2                	call   *%edx
  800828:	89 c2                	mov    %eax,%edx
  80082a:	83 c4 10             	add    $0x10,%esp
  80082d:	eb 09                	jmp    800838 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80082f:	89 c2                	mov    %eax,%edx
  800831:	eb 05                	jmp    800838 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800833:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800838:	89 d0                	mov    %edx,%eax
  80083a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80083d:	c9                   	leave  
  80083e:	c3                   	ret    

0080083f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80083f:	55                   	push   %ebp
  800840:	89 e5                	mov    %esp,%ebp
  800842:	53                   	push   %ebx
  800843:	83 ec 14             	sub    $0x14,%esp
  800846:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800849:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80084c:	50                   	push   %eax
  80084d:	ff 75 08             	pushl  0x8(%ebp)
  800850:	e8 6c fb ff ff       	call   8003c1 <fd_lookup>
  800855:	83 c4 08             	add    $0x8,%esp
  800858:	89 c2                	mov    %eax,%edx
  80085a:	85 c0                	test   %eax,%eax
  80085c:	78 58                	js     8008b6 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80085e:	83 ec 08             	sub    $0x8,%esp
  800861:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800864:	50                   	push   %eax
  800865:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800868:	ff 30                	pushl  (%eax)
  80086a:	e8 a8 fb ff ff       	call   800417 <dev_lookup>
  80086f:	83 c4 10             	add    $0x10,%esp
  800872:	85 c0                	test   %eax,%eax
  800874:	78 37                	js     8008ad <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800876:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800879:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80087d:	74 32                	je     8008b1 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80087f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800882:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800889:	00 00 00 
	stat->st_isdir = 0;
  80088c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800893:	00 00 00 
	stat->st_dev = dev;
  800896:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80089c:	83 ec 08             	sub    $0x8,%esp
  80089f:	53                   	push   %ebx
  8008a0:	ff 75 f0             	pushl  -0x10(%ebp)
  8008a3:	ff 50 14             	call   *0x14(%eax)
  8008a6:	89 c2                	mov    %eax,%edx
  8008a8:	83 c4 10             	add    $0x10,%esp
  8008ab:	eb 09                	jmp    8008b6 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008ad:	89 c2                	mov    %eax,%edx
  8008af:	eb 05                	jmp    8008b6 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008b1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008b6:	89 d0                	mov    %edx,%eax
  8008b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008bb:	c9                   	leave  
  8008bc:	c3                   	ret    

008008bd <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008bd:	55                   	push   %ebp
  8008be:	89 e5                	mov    %esp,%ebp
  8008c0:	56                   	push   %esi
  8008c1:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008c2:	83 ec 08             	sub    $0x8,%esp
  8008c5:	6a 00                	push   $0x0
  8008c7:	ff 75 08             	pushl  0x8(%ebp)
  8008ca:	e8 b7 01 00 00       	call   800a86 <open>
  8008cf:	89 c3                	mov    %eax,%ebx
  8008d1:	83 c4 10             	add    $0x10,%esp
  8008d4:	85 c0                	test   %eax,%eax
  8008d6:	78 1b                	js     8008f3 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008d8:	83 ec 08             	sub    $0x8,%esp
  8008db:	ff 75 0c             	pushl  0xc(%ebp)
  8008de:	50                   	push   %eax
  8008df:	e8 5b ff ff ff       	call   80083f <fstat>
  8008e4:	89 c6                	mov    %eax,%esi
	close(fd);
  8008e6:	89 1c 24             	mov    %ebx,(%esp)
  8008e9:	e8 fd fb ff ff       	call   8004eb <close>
	return r;
  8008ee:	83 c4 10             	add    $0x10,%esp
  8008f1:	89 f0                	mov    %esi,%eax
}
  8008f3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008f6:	5b                   	pop    %ebx
  8008f7:	5e                   	pop    %esi
  8008f8:	5d                   	pop    %ebp
  8008f9:	c3                   	ret    

008008fa <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008fa:	55                   	push   %ebp
  8008fb:	89 e5                	mov    %esp,%ebp
  8008fd:	56                   	push   %esi
  8008fe:	53                   	push   %ebx
  8008ff:	89 c6                	mov    %eax,%esi
  800901:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800903:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80090a:	75 12                	jne    80091e <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80090c:	83 ec 0c             	sub    $0xc,%esp
  80090f:	6a 01                	push   $0x1
  800911:	e8 08 12 00 00       	call   801b1e <ipc_find_env>
  800916:	a3 00 40 80 00       	mov    %eax,0x804000
  80091b:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80091e:	6a 07                	push   $0x7
  800920:	68 00 50 80 00       	push   $0x805000
  800925:	56                   	push   %esi
  800926:	ff 35 00 40 80 00    	pushl  0x804000
  80092c:	e8 99 11 00 00       	call   801aca <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800931:	83 c4 0c             	add    $0xc,%esp
  800934:	6a 00                	push   $0x0
  800936:	53                   	push   %ebx
  800937:	6a 00                	push   $0x0
  800939:	e8 17 11 00 00       	call   801a55 <ipc_recv>
}
  80093e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800941:	5b                   	pop    %ebx
  800942:	5e                   	pop    %esi
  800943:	5d                   	pop    %ebp
  800944:	c3                   	ret    

00800945 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800945:	55                   	push   %ebp
  800946:	89 e5                	mov    %esp,%ebp
  800948:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80094b:	8b 45 08             	mov    0x8(%ebp),%eax
  80094e:	8b 40 0c             	mov    0xc(%eax),%eax
  800951:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800956:	8b 45 0c             	mov    0xc(%ebp),%eax
  800959:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80095e:	ba 00 00 00 00       	mov    $0x0,%edx
  800963:	b8 02 00 00 00       	mov    $0x2,%eax
  800968:	e8 8d ff ff ff       	call   8008fa <fsipc>
}
  80096d:	c9                   	leave  
  80096e:	c3                   	ret    

0080096f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80096f:	55                   	push   %ebp
  800970:	89 e5                	mov    %esp,%ebp
  800972:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800975:	8b 45 08             	mov    0x8(%ebp),%eax
  800978:	8b 40 0c             	mov    0xc(%eax),%eax
  80097b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800980:	ba 00 00 00 00       	mov    $0x0,%edx
  800985:	b8 06 00 00 00       	mov    $0x6,%eax
  80098a:	e8 6b ff ff ff       	call   8008fa <fsipc>
}
  80098f:	c9                   	leave  
  800990:	c3                   	ret    

00800991 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800991:	55                   	push   %ebp
  800992:	89 e5                	mov    %esp,%ebp
  800994:	53                   	push   %ebx
  800995:	83 ec 04             	sub    $0x4,%esp
  800998:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80099b:	8b 45 08             	mov    0x8(%ebp),%eax
  80099e:	8b 40 0c             	mov    0xc(%eax),%eax
  8009a1:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009a6:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ab:	b8 05 00 00 00       	mov    $0x5,%eax
  8009b0:	e8 45 ff ff ff       	call   8008fa <fsipc>
  8009b5:	85 c0                	test   %eax,%eax
  8009b7:	78 2c                	js     8009e5 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009b9:	83 ec 08             	sub    $0x8,%esp
  8009bc:	68 00 50 80 00       	push   $0x805000
  8009c1:	53                   	push   %ebx
  8009c2:	e8 47 0d 00 00       	call   80170e <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009c7:	a1 80 50 80 00       	mov    0x805080,%eax
  8009cc:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009d2:	a1 84 50 80 00       	mov    0x805084,%eax
  8009d7:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009dd:	83 c4 10             	add    $0x10,%esp
  8009e0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009e8:	c9                   	leave  
  8009e9:	c3                   	ret    

008009ea <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8009ea:	55                   	push   %ebp
  8009eb:	89 e5                	mov    %esp,%ebp
  8009ed:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  8009f0:	68 04 1f 80 00       	push   $0x801f04
  8009f5:	68 90 00 00 00       	push   $0x90
  8009fa:	68 22 1f 80 00       	push   $0x801f22
  8009ff:	e8 05 06 00 00       	call   801009 <_panic>

00800a04 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a04:	55                   	push   %ebp
  800a05:	89 e5                	mov    %esp,%ebp
  800a07:	56                   	push   %esi
  800a08:	53                   	push   %ebx
  800a09:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a0c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0f:	8b 40 0c             	mov    0xc(%eax),%eax
  800a12:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a17:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a1d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a22:	b8 03 00 00 00       	mov    $0x3,%eax
  800a27:	e8 ce fe ff ff       	call   8008fa <fsipc>
  800a2c:	89 c3                	mov    %eax,%ebx
  800a2e:	85 c0                	test   %eax,%eax
  800a30:	78 4b                	js     800a7d <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a32:	39 c6                	cmp    %eax,%esi
  800a34:	73 16                	jae    800a4c <devfile_read+0x48>
  800a36:	68 2d 1f 80 00       	push   $0x801f2d
  800a3b:	68 34 1f 80 00       	push   $0x801f34
  800a40:	6a 7c                	push   $0x7c
  800a42:	68 22 1f 80 00       	push   $0x801f22
  800a47:	e8 bd 05 00 00       	call   801009 <_panic>
	assert(r <= PGSIZE);
  800a4c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a51:	7e 16                	jle    800a69 <devfile_read+0x65>
  800a53:	68 49 1f 80 00       	push   $0x801f49
  800a58:	68 34 1f 80 00       	push   $0x801f34
  800a5d:	6a 7d                	push   $0x7d
  800a5f:	68 22 1f 80 00       	push   $0x801f22
  800a64:	e8 a0 05 00 00       	call   801009 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a69:	83 ec 04             	sub    $0x4,%esp
  800a6c:	50                   	push   %eax
  800a6d:	68 00 50 80 00       	push   $0x805000
  800a72:	ff 75 0c             	pushl  0xc(%ebp)
  800a75:	e8 26 0e 00 00       	call   8018a0 <memmove>
	return r;
  800a7a:	83 c4 10             	add    $0x10,%esp
}
  800a7d:	89 d8                	mov    %ebx,%eax
  800a7f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a82:	5b                   	pop    %ebx
  800a83:	5e                   	pop    %esi
  800a84:	5d                   	pop    %ebp
  800a85:	c3                   	ret    

00800a86 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800a86:	55                   	push   %ebp
  800a87:	89 e5                	mov    %esp,%ebp
  800a89:	53                   	push   %ebx
  800a8a:	83 ec 20             	sub    $0x20,%esp
  800a8d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800a90:	53                   	push   %ebx
  800a91:	e8 3f 0c 00 00       	call   8016d5 <strlen>
  800a96:	83 c4 10             	add    $0x10,%esp
  800a99:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800a9e:	7f 67                	jg     800b07 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800aa0:	83 ec 0c             	sub    $0xc,%esp
  800aa3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800aa6:	50                   	push   %eax
  800aa7:	e8 c6 f8 ff ff       	call   800372 <fd_alloc>
  800aac:	83 c4 10             	add    $0x10,%esp
		return r;
  800aaf:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ab1:	85 c0                	test   %eax,%eax
  800ab3:	78 57                	js     800b0c <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800ab5:	83 ec 08             	sub    $0x8,%esp
  800ab8:	53                   	push   %ebx
  800ab9:	68 00 50 80 00       	push   $0x805000
  800abe:	e8 4b 0c 00 00       	call   80170e <strcpy>
	fsipcbuf.open.req_omode = mode;
  800ac3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac6:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800acb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ace:	b8 01 00 00 00       	mov    $0x1,%eax
  800ad3:	e8 22 fe ff ff       	call   8008fa <fsipc>
  800ad8:	89 c3                	mov    %eax,%ebx
  800ada:	83 c4 10             	add    $0x10,%esp
  800add:	85 c0                	test   %eax,%eax
  800adf:	79 14                	jns    800af5 <open+0x6f>
		fd_close(fd, 0);
  800ae1:	83 ec 08             	sub    $0x8,%esp
  800ae4:	6a 00                	push   $0x0
  800ae6:	ff 75 f4             	pushl  -0xc(%ebp)
  800ae9:	e8 7c f9 ff ff       	call   80046a <fd_close>
		return r;
  800aee:	83 c4 10             	add    $0x10,%esp
  800af1:	89 da                	mov    %ebx,%edx
  800af3:	eb 17                	jmp    800b0c <open+0x86>
	}

	return fd2num(fd);
  800af5:	83 ec 0c             	sub    $0xc,%esp
  800af8:	ff 75 f4             	pushl  -0xc(%ebp)
  800afb:	e8 4b f8 ff ff       	call   80034b <fd2num>
  800b00:	89 c2                	mov    %eax,%edx
  800b02:	83 c4 10             	add    $0x10,%esp
  800b05:	eb 05                	jmp    800b0c <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b07:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b0c:	89 d0                	mov    %edx,%eax
  800b0e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b11:	c9                   	leave  
  800b12:	c3                   	ret    

00800b13 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b13:	55                   	push   %ebp
  800b14:	89 e5                	mov    %esp,%ebp
  800b16:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b19:	ba 00 00 00 00       	mov    $0x0,%edx
  800b1e:	b8 08 00 00 00       	mov    $0x8,%eax
  800b23:	e8 d2 fd ff ff       	call   8008fa <fsipc>
}
  800b28:	c9                   	leave  
  800b29:	c3                   	ret    

00800b2a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b2a:	55                   	push   %ebp
  800b2b:	89 e5                	mov    %esp,%ebp
  800b2d:	56                   	push   %esi
  800b2e:	53                   	push   %ebx
  800b2f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b32:	83 ec 0c             	sub    $0xc,%esp
  800b35:	ff 75 08             	pushl  0x8(%ebp)
  800b38:	e8 1e f8 ff ff       	call   80035b <fd2data>
  800b3d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b3f:	83 c4 08             	add    $0x8,%esp
  800b42:	68 55 1f 80 00       	push   $0x801f55
  800b47:	53                   	push   %ebx
  800b48:	e8 c1 0b 00 00       	call   80170e <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b4d:	8b 46 04             	mov    0x4(%esi),%eax
  800b50:	2b 06                	sub    (%esi),%eax
  800b52:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b58:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b5f:	00 00 00 
	stat->st_dev = &devpipe;
  800b62:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800b69:	30 80 00 
	return 0;
}
  800b6c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b71:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b74:	5b                   	pop    %ebx
  800b75:	5e                   	pop    %esi
  800b76:	5d                   	pop    %ebp
  800b77:	c3                   	ret    

00800b78 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800b78:	55                   	push   %ebp
  800b79:	89 e5                	mov    %esp,%ebp
  800b7b:	53                   	push   %ebx
  800b7c:	83 ec 0c             	sub    $0xc,%esp
  800b7f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800b82:	53                   	push   %ebx
  800b83:	6a 00                	push   $0x0
  800b85:	e8 55 f6 ff ff       	call   8001df <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800b8a:	89 1c 24             	mov    %ebx,(%esp)
  800b8d:	e8 c9 f7 ff ff       	call   80035b <fd2data>
  800b92:	83 c4 08             	add    $0x8,%esp
  800b95:	50                   	push   %eax
  800b96:	6a 00                	push   $0x0
  800b98:	e8 42 f6 ff ff       	call   8001df <sys_page_unmap>
}
  800b9d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ba0:	c9                   	leave  
  800ba1:	c3                   	ret    

00800ba2 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800ba2:	55                   	push   %ebp
  800ba3:	89 e5                	mov    %esp,%ebp
  800ba5:	57                   	push   %edi
  800ba6:	56                   	push   %esi
  800ba7:	53                   	push   %ebx
  800ba8:	83 ec 1c             	sub    $0x1c,%esp
  800bab:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800bae:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800bb0:	a1 04 40 80 00       	mov    0x804004,%eax
  800bb5:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800bb8:	83 ec 0c             	sub    $0xc,%esp
  800bbb:	ff 75 e0             	pushl  -0x20(%ebp)
  800bbe:	e8 94 0f 00 00       	call   801b57 <pageref>
  800bc3:	89 c3                	mov    %eax,%ebx
  800bc5:	89 3c 24             	mov    %edi,(%esp)
  800bc8:	e8 8a 0f 00 00       	call   801b57 <pageref>
  800bcd:	83 c4 10             	add    $0x10,%esp
  800bd0:	39 c3                	cmp    %eax,%ebx
  800bd2:	0f 94 c1             	sete   %cl
  800bd5:	0f b6 c9             	movzbl %cl,%ecx
  800bd8:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800bdb:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800be1:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800be4:	39 ce                	cmp    %ecx,%esi
  800be6:	74 1b                	je     800c03 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800be8:	39 c3                	cmp    %eax,%ebx
  800bea:	75 c4                	jne    800bb0 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800bec:	8b 42 58             	mov    0x58(%edx),%eax
  800bef:	ff 75 e4             	pushl  -0x1c(%ebp)
  800bf2:	50                   	push   %eax
  800bf3:	56                   	push   %esi
  800bf4:	68 5c 1f 80 00       	push   $0x801f5c
  800bf9:	e8 e4 04 00 00       	call   8010e2 <cprintf>
  800bfe:	83 c4 10             	add    $0x10,%esp
  800c01:	eb ad                	jmp    800bb0 <_pipeisclosed+0xe>
	}
}
  800c03:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c06:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c09:	5b                   	pop    %ebx
  800c0a:	5e                   	pop    %esi
  800c0b:	5f                   	pop    %edi
  800c0c:	5d                   	pop    %ebp
  800c0d:	c3                   	ret    

00800c0e <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c0e:	55                   	push   %ebp
  800c0f:	89 e5                	mov    %esp,%ebp
  800c11:	57                   	push   %edi
  800c12:	56                   	push   %esi
  800c13:	53                   	push   %ebx
  800c14:	83 ec 28             	sub    $0x28,%esp
  800c17:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c1a:	56                   	push   %esi
  800c1b:	e8 3b f7 ff ff       	call   80035b <fd2data>
  800c20:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c22:	83 c4 10             	add    $0x10,%esp
  800c25:	bf 00 00 00 00       	mov    $0x0,%edi
  800c2a:	eb 4b                	jmp    800c77 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c2c:	89 da                	mov    %ebx,%edx
  800c2e:	89 f0                	mov    %esi,%eax
  800c30:	e8 6d ff ff ff       	call   800ba2 <_pipeisclosed>
  800c35:	85 c0                	test   %eax,%eax
  800c37:	75 48                	jne    800c81 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c39:	e8 fd f4 ff ff       	call   80013b <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c3e:	8b 43 04             	mov    0x4(%ebx),%eax
  800c41:	8b 0b                	mov    (%ebx),%ecx
  800c43:	8d 51 20             	lea    0x20(%ecx),%edx
  800c46:	39 d0                	cmp    %edx,%eax
  800c48:	73 e2                	jae    800c2c <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4d:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c51:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c54:	89 c2                	mov    %eax,%edx
  800c56:	c1 fa 1f             	sar    $0x1f,%edx
  800c59:	89 d1                	mov    %edx,%ecx
  800c5b:	c1 e9 1b             	shr    $0x1b,%ecx
  800c5e:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c61:	83 e2 1f             	and    $0x1f,%edx
  800c64:	29 ca                	sub    %ecx,%edx
  800c66:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800c6a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800c6e:	83 c0 01             	add    $0x1,%eax
  800c71:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c74:	83 c7 01             	add    $0x1,%edi
  800c77:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800c7a:	75 c2                	jne    800c3e <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800c7c:	8b 45 10             	mov    0x10(%ebp),%eax
  800c7f:	eb 05                	jmp    800c86 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800c81:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800c86:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c89:	5b                   	pop    %ebx
  800c8a:	5e                   	pop    %esi
  800c8b:	5f                   	pop    %edi
  800c8c:	5d                   	pop    %ebp
  800c8d:	c3                   	ret    

00800c8e <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800c8e:	55                   	push   %ebp
  800c8f:	89 e5                	mov    %esp,%ebp
  800c91:	57                   	push   %edi
  800c92:	56                   	push   %esi
  800c93:	53                   	push   %ebx
  800c94:	83 ec 18             	sub    $0x18,%esp
  800c97:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800c9a:	57                   	push   %edi
  800c9b:	e8 bb f6 ff ff       	call   80035b <fd2data>
  800ca0:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ca2:	83 c4 10             	add    $0x10,%esp
  800ca5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800caa:	eb 3d                	jmp    800ce9 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800cac:	85 db                	test   %ebx,%ebx
  800cae:	74 04                	je     800cb4 <devpipe_read+0x26>
				return i;
  800cb0:	89 d8                	mov    %ebx,%eax
  800cb2:	eb 44                	jmp    800cf8 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800cb4:	89 f2                	mov    %esi,%edx
  800cb6:	89 f8                	mov    %edi,%eax
  800cb8:	e8 e5 fe ff ff       	call   800ba2 <_pipeisclosed>
  800cbd:	85 c0                	test   %eax,%eax
  800cbf:	75 32                	jne    800cf3 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800cc1:	e8 75 f4 ff ff       	call   80013b <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800cc6:	8b 06                	mov    (%esi),%eax
  800cc8:	3b 46 04             	cmp    0x4(%esi),%eax
  800ccb:	74 df                	je     800cac <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800ccd:	99                   	cltd   
  800cce:	c1 ea 1b             	shr    $0x1b,%edx
  800cd1:	01 d0                	add    %edx,%eax
  800cd3:	83 e0 1f             	and    $0x1f,%eax
  800cd6:	29 d0                	sub    %edx,%eax
  800cd8:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800cdd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce0:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800ce3:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ce6:	83 c3 01             	add    $0x1,%ebx
  800ce9:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800cec:	75 d8                	jne    800cc6 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800cee:	8b 45 10             	mov    0x10(%ebp),%eax
  800cf1:	eb 05                	jmp    800cf8 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cf3:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800cf8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfb:	5b                   	pop    %ebx
  800cfc:	5e                   	pop    %esi
  800cfd:	5f                   	pop    %edi
  800cfe:	5d                   	pop    %ebp
  800cff:	c3                   	ret    

00800d00 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d00:	55                   	push   %ebp
  800d01:	89 e5                	mov    %esp,%ebp
  800d03:	56                   	push   %esi
  800d04:	53                   	push   %ebx
  800d05:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d08:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d0b:	50                   	push   %eax
  800d0c:	e8 61 f6 ff ff       	call   800372 <fd_alloc>
  800d11:	83 c4 10             	add    $0x10,%esp
  800d14:	89 c2                	mov    %eax,%edx
  800d16:	85 c0                	test   %eax,%eax
  800d18:	0f 88 2c 01 00 00    	js     800e4a <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d1e:	83 ec 04             	sub    $0x4,%esp
  800d21:	68 07 04 00 00       	push   $0x407
  800d26:	ff 75 f4             	pushl  -0xc(%ebp)
  800d29:	6a 00                	push   $0x0
  800d2b:	e8 2a f4 ff ff       	call   80015a <sys_page_alloc>
  800d30:	83 c4 10             	add    $0x10,%esp
  800d33:	89 c2                	mov    %eax,%edx
  800d35:	85 c0                	test   %eax,%eax
  800d37:	0f 88 0d 01 00 00    	js     800e4a <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d3d:	83 ec 0c             	sub    $0xc,%esp
  800d40:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d43:	50                   	push   %eax
  800d44:	e8 29 f6 ff ff       	call   800372 <fd_alloc>
  800d49:	89 c3                	mov    %eax,%ebx
  800d4b:	83 c4 10             	add    $0x10,%esp
  800d4e:	85 c0                	test   %eax,%eax
  800d50:	0f 88 e2 00 00 00    	js     800e38 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d56:	83 ec 04             	sub    $0x4,%esp
  800d59:	68 07 04 00 00       	push   $0x407
  800d5e:	ff 75 f0             	pushl  -0x10(%ebp)
  800d61:	6a 00                	push   $0x0
  800d63:	e8 f2 f3 ff ff       	call   80015a <sys_page_alloc>
  800d68:	89 c3                	mov    %eax,%ebx
  800d6a:	83 c4 10             	add    $0x10,%esp
  800d6d:	85 c0                	test   %eax,%eax
  800d6f:	0f 88 c3 00 00 00    	js     800e38 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800d75:	83 ec 0c             	sub    $0xc,%esp
  800d78:	ff 75 f4             	pushl  -0xc(%ebp)
  800d7b:	e8 db f5 ff ff       	call   80035b <fd2data>
  800d80:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d82:	83 c4 0c             	add    $0xc,%esp
  800d85:	68 07 04 00 00       	push   $0x407
  800d8a:	50                   	push   %eax
  800d8b:	6a 00                	push   $0x0
  800d8d:	e8 c8 f3 ff ff       	call   80015a <sys_page_alloc>
  800d92:	89 c3                	mov    %eax,%ebx
  800d94:	83 c4 10             	add    $0x10,%esp
  800d97:	85 c0                	test   %eax,%eax
  800d99:	0f 88 89 00 00 00    	js     800e28 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d9f:	83 ec 0c             	sub    $0xc,%esp
  800da2:	ff 75 f0             	pushl  -0x10(%ebp)
  800da5:	e8 b1 f5 ff ff       	call   80035b <fd2data>
  800daa:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800db1:	50                   	push   %eax
  800db2:	6a 00                	push   $0x0
  800db4:	56                   	push   %esi
  800db5:	6a 00                	push   $0x0
  800db7:	e8 e1 f3 ff ff       	call   80019d <sys_page_map>
  800dbc:	89 c3                	mov    %eax,%ebx
  800dbe:	83 c4 20             	add    $0x20,%esp
  800dc1:	85 c0                	test   %eax,%eax
  800dc3:	78 55                	js     800e1a <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800dc5:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800dcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dce:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800dd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dd3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800dda:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800de0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800de3:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800de5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800de8:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800def:	83 ec 0c             	sub    $0xc,%esp
  800df2:	ff 75 f4             	pushl  -0xc(%ebp)
  800df5:	e8 51 f5 ff ff       	call   80034b <fd2num>
  800dfa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dfd:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800dff:	83 c4 04             	add    $0x4,%esp
  800e02:	ff 75 f0             	pushl  -0x10(%ebp)
  800e05:	e8 41 f5 ff ff       	call   80034b <fd2num>
  800e0a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e0d:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e10:	83 c4 10             	add    $0x10,%esp
  800e13:	ba 00 00 00 00       	mov    $0x0,%edx
  800e18:	eb 30                	jmp    800e4a <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e1a:	83 ec 08             	sub    $0x8,%esp
  800e1d:	56                   	push   %esi
  800e1e:	6a 00                	push   $0x0
  800e20:	e8 ba f3 ff ff       	call   8001df <sys_page_unmap>
  800e25:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e28:	83 ec 08             	sub    $0x8,%esp
  800e2b:	ff 75 f0             	pushl  -0x10(%ebp)
  800e2e:	6a 00                	push   $0x0
  800e30:	e8 aa f3 ff ff       	call   8001df <sys_page_unmap>
  800e35:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e38:	83 ec 08             	sub    $0x8,%esp
  800e3b:	ff 75 f4             	pushl  -0xc(%ebp)
  800e3e:	6a 00                	push   $0x0
  800e40:	e8 9a f3 ff ff       	call   8001df <sys_page_unmap>
  800e45:	83 c4 10             	add    $0x10,%esp
  800e48:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800e4a:	89 d0                	mov    %edx,%eax
  800e4c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e4f:	5b                   	pop    %ebx
  800e50:	5e                   	pop    %esi
  800e51:	5d                   	pop    %ebp
  800e52:	c3                   	ret    

00800e53 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e53:	55                   	push   %ebp
  800e54:	89 e5                	mov    %esp,%ebp
  800e56:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e59:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e5c:	50                   	push   %eax
  800e5d:	ff 75 08             	pushl  0x8(%ebp)
  800e60:	e8 5c f5 ff ff       	call   8003c1 <fd_lookup>
  800e65:	83 c4 10             	add    $0x10,%esp
  800e68:	85 c0                	test   %eax,%eax
  800e6a:	78 18                	js     800e84 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800e6c:	83 ec 0c             	sub    $0xc,%esp
  800e6f:	ff 75 f4             	pushl  -0xc(%ebp)
  800e72:	e8 e4 f4 ff ff       	call   80035b <fd2data>
	return _pipeisclosed(fd, p);
  800e77:	89 c2                	mov    %eax,%edx
  800e79:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e7c:	e8 21 fd ff ff       	call   800ba2 <_pipeisclosed>
  800e81:	83 c4 10             	add    $0x10,%esp
}
  800e84:	c9                   	leave  
  800e85:	c3                   	ret    

00800e86 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800e86:	55                   	push   %ebp
  800e87:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800e89:	b8 00 00 00 00       	mov    $0x0,%eax
  800e8e:	5d                   	pop    %ebp
  800e8f:	c3                   	ret    

00800e90 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800e90:	55                   	push   %ebp
  800e91:	89 e5                	mov    %esp,%ebp
  800e93:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800e96:	68 74 1f 80 00       	push   $0x801f74
  800e9b:	ff 75 0c             	pushl  0xc(%ebp)
  800e9e:	e8 6b 08 00 00       	call   80170e <strcpy>
	return 0;
}
  800ea3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ea8:	c9                   	leave  
  800ea9:	c3                   	ret    

00800eaa <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800eaa:	55                   	push   %ebp
  800eab:	89 e5                	mov    %esp,%ebp
  800ead:	57                   	push   %edi
  800eae:	56                   	push   %esi
  800eaf:	53                   	push   %ebx
  800eb0:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800eb6:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800ebb:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ec1:	eb 2d                	jmp    800ef0 <devcons_write+0x46>
		m = n - tot;
  800ec3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ec6:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800ec8:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800ecb:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800ed0:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800ed3:	83 ec 04             	sub    $0x4,%esp
  800ed6:	53                   	push   %ebx
  800ed7:	03 45 0c             	add    0xc(%ebp),%eax
  800eda:	50                   	push   %eax
  800edb:	57                   	push   %edi
  800edc:	e8 bf 09 00 00       	call   8018a0 <memmove>
		sys_cputs(buf, m);
  800ee1:	83 c4 08             	add    $0x8,%esp
  800ee4:	53                   	push   %ebx
  800ee5:	57                   	push   %edi
  800ee6:	e8 b3 f1 ff ff       	call   80009e <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800eeb:	01 de                	add    %ebx,%esi
  800eed:	83 c4 10             	add    $0x10,%esp
  800ef0:	89 f0                	mov    %esi,%eax
  800ef2:	3b 75 10             	cmp    0x10(%ebp),%esi
  800ef5:	72 cc                	jb     800ec3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800ef7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800efa:	5b                   	pop    %ebx
  800efb:	5e                   	pop    %esi
  800efc:	5f                   	pop    %edi
  800efd:	5d                   	pop    %ebp
  800efe:	c3                   	ret    

00800eff <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800eff:	55                   	push   %ebp
  800f00:	89 e5                	mov    %esp,%ebp
  800f02:	83 ec 08             	sub    $0x8,%esp
  800f05:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f0a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f0e:	74 2a                	je     800f3a <devcons_read+0x3b>
  800f10:	eb 05                	jmp    800f17 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f12:	e8 24 f2 ff ff       	call   80013b <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f17:	e8 a0 f1 ff ff       	call   8000bc <sys_cgetc>
  800f1c:	85 c0                	test   %eax,%eax
  800f1e:	74 f2                	je     800f12 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f20:	85 c0                	test   %eax,%eax
  800f22:	78 16                	js     800f3a <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f24:	83 f8 04             	cmp    $0x4,%eax
  800f27:	74 0c                	je     800f35 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f29:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f2c:	88 02                	mov    %al,(%edx)
	return 1;
  800f2e:	b8 01 00 00 00       	mov    $0x1,%eax
  800f33:	eb 05                	jmp    800f3a <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f35:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f3a:	c9                   	leave  
  800f3b:	c3                   	ret    

00800f3c <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f3c:	55                   	push   %ebp
  800f3d:	89 e5                	mov    %esp,%ebp
  800f3f:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f42:	8b 45 08             	mov    0x8(%ebp),%eax
  800f45:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f48:	6a 01                	push   $0x1
  800f4a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f4d:	50                   	push   %eax
  800f4e:	e8 4b f1 ff ff       	call   80009e <sys_cputs>
}
  800f53:	83 c4 10             	add    $0x10,%esp
  800f56:	c9                   	leave  
  800f57:	c3                   	ret    

00800f58 <getchar>:

int
getchar(void)
{
  800f58:	55                   	push   %ebp
  800f59:	89 e5                	mov    %esp,%ebp
  800f5b:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f5e:	6a 01                	push   $0x1
  800f60:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f63:	50                   	push   %eax
  800f64:	6a 00                	push   $0x0
  800f66:	e8 bc f6 ff ff       	call   800627 <read>
	if (r < 0)
  800f6b:	83 c4 10             	add    $0x10,%esp
  800f6e:	85 c0                	test   %eax,%eax
  800f70:	78 0f                	js     800f81 <getchar+0x29>
		return r;
	if (r < 1)
  800f72:	85 c0                	test   %eax,%eax
  800f74:	7e 06                	jle    800f7c <getchar+0x24>
		return -E_EOF;
	return c;
  800f76:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800f7a:	eb 05                	jmp    800f81 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800f7c:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800f81:	c9                   	leave  
  800f82:	c3                   	ret    

00800f83 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800f83:	55                   	push   %ebp
  800f84:	89 e5                	mov    %esp,%ebp
  800f86:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f89:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f8c:	50                   	push   %eax
  800f8d:	ff 75 08             	pushl  0x8(%ebp)
  800f90:	e8 2c f4 ff ff       	call   8003c1 <fd_lookup>
  800f95:	83 c4 10             	add    $0x10,%esp
  800f98:	85 c0                	test   %eax,%eax
  800f9a:	78 11                	js     800fad <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800f9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f9f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fa5:	39 10                	cmp    %edx,(%eax)
  800fa7:	0f 94 c0             	sete   %al
  800faa:	0f b6 c0             	movzbl %al,%eax
}
  800fad:	c9                   	leave  
  800fae:	c3                   	ret    

00800faf <opencons>:

int
opencons(void)
{
  800faf:	55                   	push   %ebp
  800fb0:	89 e5                	mov    %esp,%ebp
  800fb2:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fb5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fb8:	50                   	push   %eax
  800fb9:	e8 b4 f3 ff ff       	call   800372 <fd_alloc>
  800fbe:	83 c4 10             	add    $0x10,%esp
		return r;
  800fc1:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fc3:	85 c0                	test   %eax,%eax
  800fc5:	78 3e                	js     801005 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fc7:	83 ec 04             	sub    $0x4,%esp
  800fca:	68 07 04 00 00       	push   $0x407
  800fcf:	ff 75 f4             	pushl  -0xc(%ebp)
  800fd2:	6a 00                	push   $0x0
  800fd4:	e8 81 f1 ff ff       	call   80015a <sys_page_alloc>
  800fd9:	83 c4 10             	add    $0x10,%esp
		return r;
  800fdc:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fde:	85 c0                	test   %eax,%eax
  800fe0:	78 23                	js     801005 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800fe2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fe8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800feb:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800fed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ff0:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800ff7:	83 ec 0c             	sub    $0xc,%esp
  800ffa:	50                   	push   %eax
  800ffb:	e8 4b f3 ff ff       	call   80034b <fd2num>
  801000:	89 c2                	mov    %eax,%edx
  801002:	83 c4 10             	add    $0x10,%esp
}
  801005:	89 d0                	mov    %edx,%eax
  801007:	c9                   	leave  
  801008:	c3                   	ret    

00801009 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801009:	55                   	push   %ebp
  80100a:	89 e5                	mov    %esp,%ebp
  80100c:	56                   	push   %esi
  80100d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80100e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801011:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801017:	e8 00 f1 ff ff       	call   80011c <sys_getenvid>
  80101c:	83 ec 0c             	sub    $0xc,%esp
  80101f:	ff 75 0c             	pushl  0xc(%ebp)
  801022:	ff 75 08             	pushl  0x8(%ebp)
  801025:	56                   	push   %esi
  801026:	50                   	push   %eax
  801027:	68 80 1f 80 00       	push   $0x801f80
  80102c:	e8 b1 00 00 00       	call   8010e2 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801031:	83 c4 18             	add    $0x18,%esp
  801034:	53                   	push   %ebx
  801035:	ff 75 10             	pushl  0x10(%ebp)
  801038:	e8 54 00 00 00       	call   801091 <vcprintf>
	cprintf("\n");
  80103d:	c7 04 24 6d 1f 80 00 	movl   $0x801f6d,(%esp)
  801044:	e8 99 00 00 00       	call   8010e2 <cprintf>
  801049:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80104c:	cc                   	int3   
  80104d:	eb fd                	jmp    80104c <_panic+0x43>

0080104f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80104f:	55                   	push   %ebp
  801050:	89 e5                	mov    %esp,%ebp
  801052:	53                   	push   %ebx
  801053:	83 ec 04             	sub    $0x4,%esp
  801056:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801059:	8b 13                	mov    (%ebx),%edx
  80105b:	8d 42 01             	lea    0x1(%edx),%eax
  80105e:	89 03                	mov    %eax,(%ebx)
  801060:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801063:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801067:	3d ff 00 00 00       	cmp    $0xff,%eax
  80106c:	75 1a                	jne    801088 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80106e:	83 ec 08             	sub    $0x8,%esp
  801071:	68 ff 00 00 00       	push   $0xff
  801076:	8d 43 08             	lea    0x8(%ebx),%eax
  801079:	50                   	push   %eax
  80107a:	e8 1f f0 ff ff       	call   80009e <sys_cputs>
		b->idx = 0;
  80107f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801085:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801088:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80108c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80108f:	c9                   	leave  
  801090:	c3                   	ret    

00801091 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801091:	55                   	push   %ebp
  801092:	89 e5                	mov    %esp,%ebp
  801094:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80109a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010a1:	00 00 00 
	b.cnt = 0;
  8010a4:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010ab:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010ae:	ff 75 0c             	pushl  0xc(%ebp)
  8010b1:	ff 75 08             	pushl  0x8(%ebp)
  8010b4:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010ba:	50                   	push   %eax
  8010bb:	68 4f 10 80 00       	push   $0x80104f
  8010c0:	e8 1a 01 00 00       	call   8011df <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010c5:	83 c4 08             	add    $0x8,%esp
  8010c8:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8010ce:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8010d4:	50                   	push   %eax
  8010d5:	e8 c4 ef ff ff       	call   80009e <sys_cputs>

	return b.cnt;
}
  8010da:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8010e0:	c9                   	leave  
  8010e1:	c3                   	ret    

008010e2 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8010e2:	55                   	push   %ebp
  8010e3:	89 e5                	mov    %esp,%ebp
  8010e5:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8010e8:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8010eb:	50                   	push   %eax
  8010ec:	ff 75 08             	pushl  0x8(%ebp)
  8010ef:	e8 9d ff ff ff       	call   801091 <vcprintf>
	va_end(ap);

	return cnt;
}
  8010f4:	c9                   	leave  
  8010f5:	c3                   	ret    

008010f6 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8010f6:	55                   	push   %ebp
  8010f7:	89 e5                	mov    %esp,%ebp
  8010f9:	57                   	push   %edi
  8010fa:	56                   	push   %esi
  8010fb:	53                   	push   %ebx
  8010fc:	83 ec 1c             	sub    $0x1c,%esp
  8010ff:	89 c7                	mov    %eax,%edi
  801101:	89 d6                	mov    %edx,%esi
  801103:	8b 45 08             	mov    0x8(%ebp),%eax
  801106:	8b 55 0c             	mov    0xc(%ebp),%edx
  801109:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80110c:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80110f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801112:	bb 00 00 00 00       	mov    $0x0,%ebx
  801117:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80111a:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80111d:	39 d3                	cmp    %edx,%ebx
  80111f:	72 05                	jb     801126 <printnum+0x30>
  801121:	39 45 10             	cmp    %eax,0x10(%ebp)
  801124:	77 45                	ja     80116b <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801126:	83 ec 0c             	sub    $0xc,%esp
  801129:	ff 75 18             	pushl  0x18(%ebp)
  80112c:	8b 45 14             	mov    0x14(%ebp),%eax
  80112f:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801132:	53                   	push   %ebx
  801133:	ff 75 10             	pushl  0x10(%ebp)
  801136:	83 ec 08             	sub    $0x8,%esp
  801139:	ff 75 e4             	pushl  -0x1c(%ebp)
  80113c:	ff 75 e0             	pushl  -0x20(%ebp)
  80113f:	ff 75 dc             	pushl  -0x24(%ebp)
  801142:	ff 75 d8             	pushl  -0x28(%ebp)
  801145:	e8 56 0a 00 00       	call   801ba0 <__udivdi3>
  80114a:	83 c4 18             	add    $0x18,%esp
  80114d:	52                   	push   %edx
  80114e:	50                   	push   %eax
  80114f:	89 f2                	mov    %esi,%edx
  801151:	89 f8                	mov    %edi,%eax
  801153:	e8 9e ff ff ff       	call   8010f6 <printnum>
  801158:	83 c4 20             	add    $0x20,%esp
  80115b:	eb 18                	jmp    801175 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80115d:	83 ec 08             	sub    $0x8,%esp
  801160:	56                   	push   %esi
  801161:	ff 75 18             	pushl  0x18(%ebp)
  801164:	ff d7                	call   *%edi
  801166:	83 c4 10             	add    $0x10,%esp
  801169:	eb 03                	jmp    80116e <printnum+0x78>
  80116b:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80116e:	83 eb 01             	sub    $0x1,%ebx
  801171:	85 db                	test   %ebx,%ebx
  801173:	7f e8                	jg     80115d <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801175:	83 ec 08             	sub    $0x8,%esp
  801178:	56                   	push   %esi
  801179:	83 ec 04             	sub    $0x4,%esp
  80117c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80117f:	ff 75 e0             	pushl  -0x20(%ebp)
  801182:	ff 75 dc             	pushl  -0x24(%ebp)
  801185:	ff 75 d8             	pushl  -0x28(%ebp)
  801188:	e8 43 0b 00 00       	call   801cd0 <__umoddi3>
  80118d:	83 c4 14             	add    $0x14,%esp
  801190:	0f be 80 a3 1f 80 00 	movsbl 0x801fa3(%eax),%eax
  801197:	50                   	push   %eax
  801198:	ff d7                	call   *%edi
}
  80119a:	83 c4 10             	add    $0x10,%esp
  80119d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011a0:	5b                   	pop    %ebx
  8011a1:	5e                   	pop    %esi
  8011a2:	5f                   	pop    %edi
  8011a3:	5d                   	pop    %ebp
  8011a4:	c3                   	ret    

008011a5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011a5:	55                   	push   %ebp
  8011a6:	89 e5                	mov    %esp,%ebp
  8011a8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011ab:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8011af:	8b 10                	mov    (%eax),%edx
  8011b1:	3b 50 04             	cmp    0x4(%eax),%edx
  8011b4:	73 0a                	jae    8011c0 <sprintputch+0x1b>
		*b->buf++ = ch;
  8011b6:	8d 4a 01             	lea    0x1(%edx),%ecx
  8011b9:	89 08                	mov    %ecx,(%eax)
  8011bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8011be:	88 02                	mov    %al,(%edx)
}
  8011c0:	5d                   	pop    %ebp
  8011c1:	c3                   	ret    

008011c2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8011c2:	55                   	push   %ebp
  8011c3:	89 e5                	mov    %esp,%ebp
  8011c5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8011c8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8011cb:	50                   	push   %eax
  8011cc:	ff 75 10             	pushl  0x10(%ebp)
  8011cf:	ff 75 0c             	pushl  0xc(%ebp)
  8011d2:	ff 75 08             	pushl  0x8(%ebp)
  8011d5:	e8 05 00 00 00       	call   8011df <vprintfmt>
	va_end(ap);
}
  8011da:	83 c4 10             	add    $0x10,%esp
  8011dd:	c9                   	leave  
  8011de:	c3                   	ret    

008011df <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8011df:	55                   	push   %ebp
  8011e0:	89 e5                	mov    %esp,%ebp
  8011e2:	57                   	push   %edi
  8011e3:	56                   	push   %esi
  8011e4:	53                   	push   %ebx
  8011e5:	83 ec 2c             	sub    $0x2c,%esp
  8011e8:	8b 75 08             	mov    0x8(%ebp),%esi
  8011eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8011ee:	8b 7d 10             	mov    0x10(%ebp),%edi
  8011f1:	eb 12                	jmp    801205 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8011f3:	85 c0                	test   %eax,%eax
  8011f5:	0f 84 6a 04 00 00    	je     801665 <vprintfmt+0x486>
				return;
			putch(ch, putdat);
  8011fb:	83 ec 08             	sub    $0x8,%esp
  8011fe:	53                   	push   %ebx
  8011ff:	50                   	push   %eax
  801200:	ff d6                	call   *%esi
  801202:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801205:	83 c7 01             	add    $0x1,%edi
  801208:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80120c:	83 f8 25             	cmp    $0x25,%eax
  80120f:	75 e2                	jne    8011f3 <vprintfmt+0x14>
  801211:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801215:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80121c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801223:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80122a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80122f:	eb 07                	jmp    801238 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801231:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801234:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801238:	8d 47 01             	lea    0x1(%edi),%eax
  80123b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80123e:	0f b6 07             	movzbl (%edi),%eax
  801241:	0f b6 d0             	movzbl %al,%edx
  801244:	83 e8 23             	sub    $0x23,%eax
  801247:	3c 55                	cmp    $0x55,%al
  801249:	0f 87 fb 03 00 00    	ja     80164a <vprintfmt+0x46b>
  80124f:	0f b6 c0             	movzbl %al,%eax
  801252:	ff 24 85 e0 20 80 00 	jmp    *0x8020e0(,%eax,4)
  801259:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80125c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801260:	eb d6                	jmp    801238 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801262:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801265:	b8 00 00 00 00       	mov    $0x0,%eax
  80126a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80126d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801270:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801274:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801277:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80127a:	83 f9 09             	cmp    $0x9,%ecx
  80127d:	77 3f                	ja     8012be <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80127f:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801282:	eb e9                	jmp    80126d <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801284:	8b 45 14             	mov    0x14(%ebp),%eax
  801287:	8b 00                	mov    (%eax),%eax
  801289:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80128c:	8b 45 14             	mov    0x14(%ebp),%eax
  80128f:	8d 40 04             	lea    0x4(%eax),%eax
  801292:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801295:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801298:	eb 2a                	jmp    8012c4 <vprintfmt+0xe5>
  80129a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80129d:	85 c0                	test   %eax,%eax
  80129f:	ba 00 00 00 00       	mov    $0x0,%edx
  8012a4:	0f 49 d0             	cmovns %eax,%edx
  8012a7:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012ad:	eb 89                	jmp    801238 <vprintfmt+0x59>
  8012af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8012b2:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8012b9:	e9 7a ff ff ff       	jmp    801238 <vprintfmt+0x59>
  8012be:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8012c1:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8012c4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8012c8:	0f 89 6a ff ff ff    	jns    801238 <vprintfmt+0x59>
				width = precision, precision = -1;
  8012ce:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8012d1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8012d4:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8012db:	e9 58 ff ff ff       	jmp    801238 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8012e0:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8012e6:	e9 4d ff ff ff       	jmp    801238 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8012eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8012ee:	8d 78 04             	lea    0x4(%eax),%edi
  8012f1:	83 ec 08             	sub    $0x8,%esp
  8012f4:	53                   	push   %ebx
  8012f5:	ff 30                	pushl  (%eax)
  8012f7:	ff d6                	call   *%esi
			break;
  8012f9:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8012fc:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801302:	e9 fe fe ff ff       	jmp    801205 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801307:	8b 45 14             	mov    0x14(%ebp),%eax
  80130a:	8d 78 04             	lea    0x4(%eax),%edi
  80130d:	8b 00                	mov    (%eax),%eax
  80130f:	99                   	cltd   
  801310:	31 d0                	xor    %edx,%eax
  801312:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801314:	83 f8 0f             	cmp    $0xf,%eax
  801317:	7f 0b                	jg     801324 <vprintfmt+0x145>
  801319:	8b 14 85 40 22 80 00 	mov    0x802240(,%eax,4),%edx
  801320:	85 d2                	test   %edx,%edx
  801322:	75 1b                	jne    80133f <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  801324:	50                   	push   %eax
  801325:	68 bb 1f 80 00       	push   $0x801fbb
  80132a:	53                   	push   %ebx
  80132b:	56                   	push   %esi
  80132c:	e8 91 fe ff ff       	call   8011c2 <printfmt>
  801331:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  801334:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801337:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80133a:	e9 c6 fe ff ff       	jmp    801205 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80133f:	52                   	push   %edx
  801340:	68 46 1f 80 00       	push   $0x801f46
  801345:	53                   	push   %ebx
  801346:	56                   	push   %esi
  801347:	e8 76 fe ff ff       	call   8011c2 <printfmt>
  80134c:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80134f:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801352:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801355:	e9 ab fe ff ff       	jmp    801205 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80135a:	8b 45 14             	mov    0x14(%ebp),%eax
  80135d:	83 c0 04             	add    $0x4,%eax
  801360:	89 45 cc             	mov    %eax,-0x34(%ebp)
  801363:	8b 45 14             	mov    0x14(%ebp),%eax
  801366:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801368:	85 ff                	test   %edi,%edi
  80136a:	b8 b4 1f 80 00       	mov    $0x801fb4,%eax
  80136f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801372:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801376:	0f 8e 94 00 00 00    	jle    801410 <vprintfmt+0x231>
  80137c:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801380:	0f 84 98 00 00 00    	je     80141e <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  801386:	83 ec 08             	sub    $0x8,%esp
  801389:	ff 75 d0             	pushl  -0x30(%ebp)
  80138c:	57                   	push   %edi
  80138d:	e8 5b 03 00 00       	call   8016ed <strnlen>
  801392:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801395:	29 c1                	sub    %eax,%ecx
  801397:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80139a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80139d:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8013a1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8013a4:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8013a7:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013a9:	eb 0f                	jmp    8013ba <vprintfmt+0x1db>
					putch(padc, putdat);
  8013ab:	83 ec 08             	sub    $0x8,%esp
  8013ae:	53                   	push   %ebx
  8013af:	ff 75 e0             	pushl  -0x20(%ebp)
  8013b2:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013b4:	83 ef 01             	sub    $0x1,%edi
  8013b7:	83 c4 10             	add    $0x10,%esp
  8013ba:	85 ff                	test   %edi,%edi
  8013bc:	7f ed                	jg     8013ab <vprintfmt+0x1cc>
  8013be:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8013c1:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8013c4:	85 c9                	test   %ecx,%ecx
  8013c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8013cb:	0f 49 c1             	cmovns %ecx,%eax
  8013ce:	29 c1                	sub    %eax,%ecx
  8013d0:	89 75 08             	mov    %esi,0x8(%ebp)
  8013d3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8013d6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8013d9:	89 cb                	mov    %ecx,%ebx
  8013db:	eb 4d                	jmp    80142a <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8013dd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8013e1:	74 1b                	je     8013fe <vprintfmt+0x21f>
  8013e3:	0f be c0             	movsbl %al,%eax
  8013e6:	83 e8 20             	sub    $0x20,%eax
  8013e9:	83 f8 5e             	cmp    $0x5e,%eax
  8013ec:	76 10                	jbe    8013fe <vprintfmt+0x21f>
					putch('?', putdat);
  8013ee:	83 ec 08             	sub    $0x8,%esp
  8013f1:	ff 75 0c             	pushl  0xc(%ebp)
  8013f4:	6a 3f                	push   $0x3f
  8013f6:	ff 55 08             	call   *0x8(%ebp)
  8013f9:	83 c4 10             	add    $0x10,%esp
  8013fc:	eb 0d                	jmp    80140b <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  8013fe:	83 ec 08             	sub    $0x8,%esp
  801401:	ff 75 0c             	pushl  0xc(%ebp)
  801404:	52                   	push   %edx
  801405:	ff 55 08             	call   *0x8(%ebp)
  801408:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80140b:	83 eb 01             	sub    $0x1,%ebx
  80140e:	eb 1a                	jmp    80142a <vprintfmt+0x24b>
  801410:	89 75 08             	mov    %esi,0x8(%ebp)
  801413:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801416:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801419:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80141c:	eb 0c                	jmp    80142a <vprintfmt+0x24b>
  80141e:	89 75 08             	mov    %esi,0x8(%ebp)
  801421:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801424:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801427:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80142a:	83 c7 01             	add    $0x1,%edi
  80142d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801431:	0f be d0             	movsbl %al,%edx
  801434:	85 d2                	test   %edx,%edx
  801436:	74 23                	je     80145b <vprintfmt+0x27c>
  801438:	85 f6                	test   %esi,%esi
  80143a:	78 a1                	js     8013dd <vprintfmt+0x1fe>
  80143c:	83 ee 01             	sub    $0x1,%esi
  80143f:	79 9c                	jns    8013dd <vprintfmt+0x1fe>
  801441:	89 df                	mov    %ebx,%edi
  801443:	8b 75 08             	mov    0x8(%ebp),%esi
  801446:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801449:	eb 18                	jmp    801463 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80144b:	83 ec 08             	sub    $0x8,%esp
  80144e:	53                   	push   %ebx
  80144f:	6a 20                	push   $0x20
  801451:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801453:	83 ef 01             	sub    $0x1,%edi
  801456:	83 c4 10             	add    $0x10,%esp
  801459:	eb 08                	jmp    801463 <vprintfmt+0x284>
  80145b:	89 df                	mov    %ebx,%edi
  80145d:	8b 75 08             	mov    0x8(%ebp),%esi
  801460:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801463:	85 ff                	test   %edi,%edi
  801465:	7f e4                	jg     80144b <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801467:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80146a:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80146d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801470:	e9 90 fd ff ff       	jmp    801205 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801475:	83 f9 01             	cmp    $0x1,%ecx
  801478:	7e 19                	jle    801493 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  80147a:	8b 45 14             	mov    0x14(%ebp),%eax
  80147d:	8b 50 04             	mov    0x4(%eax),%edx
  801480:	8b 00                	mov    (%eax),%eax
  801482:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801485:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801488:	8b 45 14             	mov    0x14(%ebp),%eax
  80148b:	8d 40 08             	lea    0x8(%eax),%eax
  80148e:	89 45 14             	mov    %eax,0x14(%ebp)
  801491:	eb 38                	jmp    8014cb <vprintfmt+0x2ec>
	else if (lflag)
  801493:	85 c9                	test   %ecx,%ecx
  801495:	74 1b                	je     8014b2 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  801497:	8b 45 14             	mov    0x14(%ebp),%eax
  80149a:	8b 00                	mov    (%eax),%eax
  80149c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80149f:	89 c1                	mov    %eax,%ecx
  8014a1:	c1 f9 1f             	sar    $0x1f,%ecx
  8014a4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8014aa:	8d 40 04             	lea    0x4(%eax),%eax
  8014ad:	89 45 14             	mov    %eax,0x14(%ebp)
  8014b0:	eb 19                	jmp    8014cb <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8014b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8014b5:	8b 00                	mov    (%eax),%eax
  8014b7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014ba:	89 c1                	mov    %eax,%ecx
  8014bc:	c1 f9 1f             	sar    $0x1f,%ecx
  8014bf:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8014c5:	8d 40 04             	lea    0x4(%eax),%eax
  8014c8:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8014cb:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8014ce:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8014d1:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8014d6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8014da:	0f 89 36 01 00 00    	jns    801616 <vprintfmt+0x437>
				putch('-', putdat);
  8014e0:	83 ec 08             	sub    $0x8,%esp
  8014e3:	53                   	push   %ebx
  8014e4:	6a 2d                	push   $0x2d
  8014e6:	ff d6                	call   *%esi
				num = -(long long) num;
  8014e8:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8014eb:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8014ee:	f7 da                	neg    %edx
  8014f0:	83 d1 00             	adc    $0x0,%ecx
  8014f3:	f7 d9                	neg    %ecx
  8014f5:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8014f8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014fd:	e9 14 01 00 00       	jmp    801616 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801502:	83 f9 01             	cmp    $0x1,%ecx
  801505:	7e 18                	jle    80151f <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  801507:	8b 45 14             	mov    0x14(%ebp),%eax
  80150a:	8b 10                	mov    (%eax),%edx
  80150c:	8b 48 04             	mov    0x4(%eax),%ecx
  80150f:	8d 40 08             	lea    0x8(%eax),%eax
  801512:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801515:	b8 0a 00 00 00       	mov    $0xa,%eax
  80151a:	e9 f7 00 00 00       	jmp    801616 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80151f:	85 c9                	test   %ecx,%ecx
  801521:	74 1a                	je     80153d <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  801523:	8b 45 14             	mov    0x14(%ebp),%eax
  801526:	8b 10                	mov    (%eax),%edx
  801528:	b9 00 00 00 00       	mov    $0x0,%ecx
  80152d:	8d 40 04             	lea    0x4(%eax),%eax
  801530:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801533:	b8 0a 00 00 00       	mov    $0xa,%eax
  801538:	e9 d9 00 00 00       	jmp    801616 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80153d:	8b 45 14             	mov    0x14(%ebp),%eax
  801540:	8b 10                	mov    (%eax),%edx
  801542:	b9 00 00 00 00       	mov    $0x0,%ecx
  801547:	8d 40 04             	lea    0x4(%eax),%eax
  80154a:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80154d:	b8 0a 00 00 00       	mov    $0xa,%eax
  801552:	e9 bf 00 00 00       	jmp    801616 <vprintfmt+0x437>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801557:	83 f9 01             	cmp    $0x1,%ecx
  80155a:	7e 13                	jle    80156f <vprintfmt+0x390>
		return va_arg(*ap, long long);
  80155c:	8b 45 14             	mov    0x14(%ebp),%eax
  80155f:	8b 50 04             	mov    0x4(%eax),%edx
  801562:	8b 00                	mov    (%eax),%eax
  801564:	8b 4d 14             	mov    0x14(%ebp),%ecx
  801567:	8d 49 08             	lea    0x8(%ecx),%ecx
  80156a:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80156d:	eb 28                	jmp    801597 <vprintfmt+0x3b8>
	else if (lflag)
  80156f:	85 c9                	test   %ecx,%ecx
  801571:	74 13                	je     801586 <vprintfmt+0x3a7>
		return va_arg(*ap, long);
  801573:	8b 45 14             	mov    0x14(%ebp),%eax
  801576:	8b 10                	mov    (%eax),%edx
  801578:	89 d0                	mov    %edx,%eax
  80157a:	99                   	cltd   
  80157b:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80157e:	8d 49 04             	lea    0x4(%ecx),%ecx
  801581:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801584:	eb 11                	jmp    801597 <vprintfmt+0x3b8>
	else
		return va_arg(*ap, int);
  801586:	8b 45 14             	mov    0x14(%ebp),%eax
  801589:	8b 10                	mov    (%eax),%edx
  80158b:	89 d0                	mov    %edx,%eax
  80158d:	99                   	cltd   
  80158e:	8b 4d 14             	mov    0x14(%ebp),%ecx
  801591:	8d 49 04             	lea    0x4(%ecx),%ecx
  801594:	89 4d 14             	mov    %ecx,0x14(%ebp)
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getint(&ap, lflag);
  801597:	89 d1                	mov    %edx,%ecx
  801599:	89 c2                	mov    %eax,%edx
			base = 8;
  80159b:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8015a0:	eb 74                	jmp    801616 <vprintfmt+0x437>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8015a2:	83 ec 08             	sub    $0x8,%esp
  8015a5:	53                   	push   %ebx
  8015a6:	6a 30                	push   $0x30
  8015a8:	ff d6                	call   *%esi
			putch('x', putdat);
  8015aa:	83 c4 08             	add    $0x8,%esp
  8015ad:	53                   	push   %ebx
  8015ae:	6a 78                	push   $0x78
  8015b0:	ff d6                	call   *%esi
			num = (unsigned long long)
  8015b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8015b5:	8b 10                	mov    (%eax),%edx
  8015b7:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015bc:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8015bf:	8d 40 04             	lea    0x4(%eax),%eax
  8015c2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8015c5:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8015ca:	eb 4a                	jmp    801616 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8015cc:	83 f9 01             	cmp    $0x1,%ecx
  8015cf:	7e 15                	jle    8015e6 <vprintfmt+0x407>
		return va_arg(*ap, unsigned long long);
  8015d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8015d4:	8b 10                	mov    (%eax),%edx
  8015d6:	8b 48 04             	mov    0x4(%eax),%ecx
  8015d9:	8d 40 08             	lea    0x8(%eax),%eax
  8015dc:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8015df:	b8 10 00 00 00       	mov    $0x10,%eax
  8015e4:	eb 30                	jmp    801616 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8015e6:	85 c9                	test   %ecx,%ecx
  8015e8:	74 17                	je     801601 <vprintfmt+0x422>
		return va_arg(*ap, unsigned long);
  8015ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8015ed:	8b 10                	mov    (%eax),%edx
  8015ef:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015f4:	8d 40 04             	lea    0x4(%eax),%eax
  8015f7:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8015fa:	b8 10 00 00 00       	mov    $0x10,%eax
  8015ff:	eb 15                	jmp    801616 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  801601:	8b 45 14             	mov    0x14(%ebp),%eax
  801604:	8b 10                	mov    (%eax),%edx
  801606:	b9 00 00 00 00       	mov    $0x0,%ecx
  80160b:	8d 40 04             	lea    0x4(%eax),%eax
  80160e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  801611:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  801616:	83 ec 0c             	sub    $0xc,%esp
  801619:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80161d:	57                   	push   %edi
  80161e:	ff 75 e0             	pushl  -0x20(%ebp)
  801621:	50                   	push   %eax
  801622:	51                   	push   %ecx
  801623:	52                   	push   %edx
  801624:	89 da                	mov    %ebx,%edx
  801626:	89 f0                	mov    %esi,%eax
  801628:	e8 c9 fa ff ff       	call   8010f6 <printnum>
			break;
  80162d:	83 c4 20             	add    $0x20,%esp
  801630:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801633:	e9 cd fb ff ff       	jmp    801205 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801638:	83 ec 08             	sub    $0x8,%esp
  80163b:	53                   	push   %ebx
  80163c:	52                   	push   %edx
  80163d:	ff d6                	call   *%esi
			break;
  80163f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801642:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801645:	e9 bb fb ff ff       	jmp    801205 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80164a:	83 ec 08             	sub    $0x8,%esp
  80164d:	53                   	push   %ebx
  80164e:	6a 25                	push   $0x25
  801650:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801652:	83 c4 10             	add    $0x10,%esp
  801655:	eb 03                	jmp    80165a <vprintfmt+0x47b>
  801657:	83 ef 01             	sub    $0x1,%edi
  80165a:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80165e:	75 f7                	jne    801657 <vprintfmt+0x478>
  801660:	e9 a0 fb ff ff       	jmp    801205 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801665:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801668:	5b                   	pop    %ebx
  801669:	5e                   	pop    %esi
  80166a:	5f                   	pop    %edi
  80166b:	5d                   	pop    %ebp
  80166c:	c3                   	ret    

0080166d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80166d:	55                   	push   %ebp
  80166e:	89 e5                	mov    %esp,%ebp
  801670:	83 ec 18             	sub    $0x18,%esp
  801673:	8b 45 08             	mov    0x8(%ebp),%eax
  801676:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801679:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80167c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801680:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801683:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80168a:	85 c0                	test   %eax,%eax
  80168c:	74 26                	je     8016b4 <vsnprintf+0x47>
  80168e:	85 d2                	test   %edx,%edx
  801690:	7e 22                	jle    8016b4 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801692:	ff 75 14             	pushl  0x14(%ebp)
  801695:	ff 75 10             	pushl  0x10(%ebp)
  801698:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80169b:	50                   	push   %eax
  80169c:	68 a5 11 80 00       	push   $0x8011a5
  8016a1:	e8 39 fb ff ff       	call   8011df <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8016a6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8016a9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8016ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016af:	83 c4 10             	add    $0x10,%esp
  8016b2:	eb 05                	jmp    8016b9 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8016b4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8016b9:	c9                   	leave  
  8016ba:	c3                   	ret    

008016bb <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8016bb:	55                   	push   %ebp
  8016bc:	89 e5                	mov    %esp,%ebp
  8016be:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8016c1:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8016c4:	50                   	push   %eax
  8016c5:	ff 75 10             	pushl  0x10(%ebp)
  8016c8:	ff 75 0c             	pushl  0xc(%ebp)
  8016cb:	ff 75 08             	pushl  0x8(%ebp)
  8016ce:	e8 9a ff ff ff       	call   80166d <vsnprintf>
	va_end(ap);

	return rc;
}
  8016d3:	c9                   	leave  
  8016d4:	c3                   	ret    

008016d5 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8016d5:	55                   	push   %ebp
  8016d6:	89 e5                	mov    %esp,%ebp
  8016d8:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8016db:	b8 00 00 00 00       	mov    $0x0,%eax
  8016e0:	eb 03                	jmp    8016e5 <strlen+0x10>
		n++;
  8016e2:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8016e5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8016e9:	75 f7                	jne    8016e2 <strlen+0xd>
		n++;
	return n;
}
  8016eb:	5d                   	pop    %ebp
  8016ec:	c3                   	ret    

008016ed <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8016ed:	55                   	push   %ebp
  8016ee:	89 e5                	mov    %esp,%ebp
  8016f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016f3:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016f6:	ba 00 00 00 00       	mov    $0x0,%edx
  8016fb:	eb 03                	jmp    801700 <strnlen+0x13>
		n++;
  8016fd:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801700:	39 c2                	cmp    %eax,%edx
  801702:	74 08                	je     80170c <strnlen+0x1f>
  801704:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801708:	75 f3                	jne    8016fd <strnlen+0x10>
  80170a:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80170c:	5d                   	pop    %ebp
  80170d:	c3                   	ret    

0080170e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80170e:	55                   	push   %ebp
  80170f:	89 e5                	mov    %esp,%ebp
  801711:	53                   	push   %ebx
  801712:	8b 45 08             	mov    0x8(%ebp),%eax
  801715:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801718:	89 c2                	mov    %eax,%edx
  80171a:	83 c2 01             	add    $0x1,%edx
  80171d:	83 c1 01             	add    $0x1,%ecx
  801720:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801724:	88 5a ff             	mov    %bl,-0x1(%edx)
  801727:	84 db                	test   %bl,%bl
  801729:	75 ef                	jne    80171a <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80172b:	5b                   	pop    %ebx
  80172c:	5d                   	pop    %ebp
  80172d:	c3                   	ret    

0080172e <strcat>:

char *
strcat(char *dst, const char *src)
{
  80172e:	55                   	push   %ebp
  80172f:	89 e5                	mov    %esp,%ebp
  801731:	53                   	push   %ebx
  801732:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801735:	53                   	push   %ebx
  801736:	e8 9a ff ff ff       	call   8016d5 <strlen>
  80173b:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80173e:	ff 75 0c             	pushl  0xc(%ebp)
  801741:	01 d8                	add    %ebx,%eax
  801743:	50                   	push   %eax
  801744:	e8 c5 ff ff ff       	call   80170e <strcpy>
	return dst;
}
  801749:	89 d8                	mov    %ebx,%eax
  80174b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80174e:	c9                   	leave  
  80174f:	c3                   	ret    

00801750 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801750:	55                   	push   %ebp
  801751:	89 e5                	mov    %esp,%ebp
  801753:	56                   	push   %esi
  801754:	53                   	push   %ebx
  801755:	8b 75 08             	mov    0x8(%ebp),%esi
  801758:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80175b:	89 f3                	mov    %esi,%ebx
  80175d:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801760:	89 f2                	mov    %esi,%edx
  801762:	eb 0f                	jmp    801773 <strncpy+0x23>
		*dst++ = *src;
  801764:	83 c2 01             	add    $0x1,%edx
  801767:	0f b6 01             	movzbl (%ecx),%eax
  80176a:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80176d:	80 39 01             	cmpb   $0x1,(%ecx)
  801770:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801773:	39 da                	cmp    %ebx,%edx
  801775:	75 ed                	jne    801764 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801777:	89 f0                	mov    %esi,%eax
  801779:	5b                   	pop    %ebx
  80177a:	5e                   	pop    %esi
  80177b:	5d                   	pop    %ebp
  80177c:	c3                   	ret    

0080177d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80177d:	55                   	push   %ebp
  80177e:	89 e5                	mov    %esp,%ebp
  801780:	56                   	push   %esi
  801781:	53                   	push   %ebx
  801782:	8b 75 08             	mov    0x8(%ebp),%esi
  801785:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801788:	8b 55 10             	mov    0x10(%ebp),%edx
  80178b:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80178d:	85 d2                	test   %edx,%edx
  80178f:	74 21                	je     8017b2 <strlcpy+0x35>
  801791:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801795:	89 f2                	mov    %esi,%edx
  801797:	eb 09                	jmp    8017a2 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801799:	83 c2 01             	add    $0x1,%edx
  80179c:	83 c1 01             	add    $0x1,%ecx
  80179f:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8017a2:	39 c2                	cmp    %eax,%edx
  8017a4:	74 09                	je     8017af <strlcpy+0x32>
  8017a6:	0f b6 19             	movzbl (%ecx),%ebx
  8017a9:	84 db                	test   %bl,%bl
  8017ab:	75 ec                	jne    801799 <strlcpy+0x1c>
  8017ad:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8017af:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8017b2:	29 f0                	sub    %esi,%eax
}
  8017b4:	5b                   	pop    %ebx
  8017b5:	5e                   	pop    %esi
  8017b6:	5d                   	pop    %ebp
  8017b7:	c3                   	ret    

008017b8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8017b8:	55                   	push   %ebp
  8017b9:	89 e5                	mov    %esp,%ebp
  8017bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017be:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8017c1:	eb 06                	jmp    8017c9 <strcmp+0x11>
		p++, q++;
  8017c3:	83 c1 01             	add    $0x1,%ecx
  8017c6:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8017c9:	0f b6 01             	movzbl (%ecx),%eax
  8017cc:	84 c0                	test   %al,%al
  8017ce:	74 04                	je     8017d4 <strcmp+0x1c>
  8017d0:	3a 02                	cmp    (%edx),%al
  8017d2:	74 ef                	je     8017c3 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8017d4:	0f b6 c0             	movzbl %al,%eax
  8017d7:	0f b6 12             	movzbl (%edx),%edx
  8017da:	29 d0                	sub    %edx,%eax
}
  8017dc:	5d                   	pop    %ebp
  8017dd:	c3                   	ret    

008017de <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017de:	55                   	push   %ebp
  8017df:	89 e5                	mov    %esp,%ebp
  8017e1:	53                   	push   %ebx
  8017e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017e8:	89 c3                	mov    %eax,%ebx
  8017ea:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017ed:	eb 06                	jmp    8017f5 <strncmp+0x17>
		n--, p++, q++;
  8017ef:	83 c0 01             	add    $0x1,%eax
  8017f2:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8017f5:	39 d8                	cmp    %ebx,%eax
  8017f7:	74 15                	je     80180e <strncmp+0x30>
  8017f9:	0f b6 08             	movzbl (%eax),%ecx
  8017fc:	84 c9                	test   %cl,%cl
  8017fe:	74 04                	je     801804 <strncmp+0x26>
  801800:	3a 0a                	cmp    (%edx),%cl
  801802:	74 eb                	je     8017ef <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801804:	0f b6 00             	movzbl (%eax),%eax
  801807:	0f b6 12             	movzbl (%edx),%edx
  80180a:	29 d0                	sub    %edx,%eax
  80180c:	eb 05                	jmp    801813 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80180e:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801813:	5b                   	pop    %ebx
  801814:	5d                   	pop    %ebp
  801815:	c3                   	ret    

00801816 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801816:	55                   	push   %ebp
  801817:	89 e5                	mov    %esp,%ebp
  801819:	8b 45 08             	mov    0x8(%ebp),%eax
  80181c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801820:	eb 07                	jmp    801829 <strchr+0x13>
		if (*s == c)
  801822:	38 ca                	cmp    %cl,%dl
  801824:	74 0f                	je     801835 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801826:	83 c0 01             	add    $0x1,%eax
  801829:	0f b6 10             	movzbl (%eax),%edx
  80182c:	84 d2                	test   %dl,%dl
  80182e:	75 f2                	jne    801822 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801830:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801835:	5d                   	pop    %ebp
  801836:	c3                   	ret    

00801837 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801837:	55                   	push   %ebp
  801838:	89 e5                	mov    %esp,%ebp
  80183a:	8b 45 08             	mov    0x8(%ebp),%eax
  80183d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801841:	eb 03                	jmp    801846 <strfind+0xf>
  801843:	83 c0 01             	add    $0x1,%eax
  801846:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801849:	38 ca                	cmp    %cl,%dl
  80184b:	74 04                	je     801851 <strfind+0x1a>
  80184d:	84 d2                	test   %dl,%dl
  80184f:	75 f2                	jne    801843 <strfind+0xc>
			break;
	return (char *) s;
}
  801851:	5d                   	pop    %ebp
  801852:	c3                   	ret    

00801853 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801853:	55                   	push   %ebp
  801854:	89 e5                	mov    %esp,%ebp
  801856:	57                   	push   %edi
  801857:	56                   	push   %esi
  801858:	53                   	push   %ebx
  801859:	8b 7d 08             	mov    0x8(%ebp),%edi
  80185c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80185f:	85 c9                	test   %ecx,%ecx
  801861:	74 36                	je     801899 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801863:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801869:	75 28                	jne    801893 <memset+0x40>
  80186b:	f6 c1 03             	test   $0x3,%cl
  80186e:	75 23                	jne    801893 <memset+0x40>
		c &= 0xFF;
  801870:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801874:	89 d3                	mov    %edx,%ebx
  801876:	c1 e3 08             	shl    $0x8,%ebx
  801879:	89 d6                	mov    %edx,%esi
  80187b:	c1 e6 18             	shl    $0x18,%esi
  80187e:	89 d0                	mov    %edx,%eax
  801880:	c1 e0 10             	shl    $0x10,%eax
  801883:	09 f0                	or     %esi,%eax
  801885:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801887:	89 d8                	mov    %ebx,%eax
  801889:	09 d0                	or     %edx,%eax
  80188b:	c1 e9 02             	shr    $0x2,%ecx
  80188e:	fc                   	cld    
  80188f:	f3 ab                	rep stos %eax,%es:(%edi)
  801891:	eb 06                	jmp    801899 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801893:	8b 45 0c             	mov    0xc(%ebp),%eax
  801896:	fc                   	cld    
  801897:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801899:	89 f8                	mov    %edi,%eax
  80189b:	5b                   	pop    %ebx
  80189c:	5e                   	pop    %esi
  80189d:	5f                   	pop    %edi
  80189e:	5d                   	pop    %ebp
  80189f:	c3                   	ret    

008018a0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8018a0:	55                   	push   %ebp
  8018a1:	89 e5                	mov    %esp,%ebp
  8018a3:	57                   	push   %edi
  8018a4:	56                   	push   %esi
  8018a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018ab:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8018ae:	39 c6                	cmp    %eax,%esi
  8018b0:	73 35                	jae    8018e7 <memmove+0x47>
  8018b2:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8018b5:	39 d0                	cmp    %edx,%eax
  8018b7:	73 2e                	jae    8018e7 <memmove+0x47>
		s += n;
		d += n;
  8018b9:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018bc:	89 d6                	mov    %edx,%esi
  8018be:	09 fe                	or     %edi,%esi
  8018c0:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018c6:	75 13                	jne    8018db <memmove+0x3b>
  8018c8:	f6 c1 03             	test   $0x3,%cl
  8018cb:	75 0e                	jne    8018db <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8018cd:	83 ef 04             	sub    $0x4,%edi
  8018d0:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018d3:	c1 e9 02             	shr    $0x2,%ecx
  8018d6:	fd                   	std    
  8018d7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018d9:	eb 09                	jmp    8018e4 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8018db:	83 ef 01             	sub    $0x1,%edi
  8018de:	8d 72 ff             	lea    -0x1(%edx),%esi
  8018e1:	fd                   	std    
  8018e2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018e4:	fc                   	cld    
  8018e5:	eb 1d                	jmp    801904 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018e7:	89 f2                	mov    %esi,%edx
  8018e9:	09 c2                	or     %eax,%edx
  8018eb:	f6 c2 03             	test   $0x3,%dl
  8018ee:	75 0f                	jne    8018ff <memmove+0x5f>
  8018f0:	f6 c1 03             	test   $0x3,%cl
  8018f3:	75 0a                	jne    8018ff <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8018f5:	c1 e9 02             	shr    $0x2,%ecx
  8018f8:	89 c7                	mov    %eax,%edi
  8018fa:	fc                   	cld    
  8018fb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018fd:	eb 05                	jmp    801904 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018ff:	89 c7                	mov    %eax,%edi
  801901:	fc                   	cld    
  801902:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801904:	5e                   	pop    %esi
  801905:	5f                   	pop    %edi
  801906:	5d                   	pop    %ebp
  801907:	c3                   	ret    

00801908 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801908:	55                   	push   %ebp
  801909:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80190b:	ff 75 10             	pushl  0x10(%ebp)
  80190e:	ff 75 0c             	pushl  0xc(%ebp)
  801911:	ff 75 08             	pushl  0x8(%ebp)
  801914:	e8 87 ff ff ff       	call   8018a0 <memmove>
}
  801919:	c9                   	leave  
  80191a:	c3                   	ret    

0080191b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80191b:	55                   	push   %ebp
  80191c:	89 e5                	mov    %esp,%ebp
  80191e:	56                   	push   %esi
  80191f:	53                   	push   %ebx
  801920:	8b 45 08             	mov    0x8(%ebp),%eax
  801923:	8b 55 0c             	mov    0xc(%ebp),%edx
  801926:	89 c6                	mov    %eax,%esi
  801928:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80192b:	eb 1a                	jmp    801947 <memcmp+0x2c>
		if (*s1 != *s2)
  80192d:	0f b6 08             	movzbl (%eax),%ecx
  801930:	0f b6 1a             	movzbl (%edx),%ebx
  801933:	38 d9                	cmp    %bl,%cl
  801935:	74 0a                	je     801941 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801937:	0f b6 c1             	movzbl %cl,%eax
  80193a:	0f b6 db             	movzbl %bl,%ebx
  80193d:	29 d8                	sub    %ebx,%eax
  80193f:	eb 0f                	jmp    801950 <memcmp+0x35>
		s1++, s2++;
  801941:	83 c0 01             	add    $0x1,%eax
  801944:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801947:	39 f0                	cmp    %esi,%eax
  801949:	75 e2                	jne    80192d <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80194b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801950:	5b                   	pop    %ebx
  801951:	5e                   	pop    %esi
  801952:	5d                   	pop    %ebp
  801953:	c3                   	ret    

00801954 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801954:	55                   	push   %ebp
  801955:	89 e5                	mov    %esp,%ebp
  801957:	53                   	push   %ebx
  801958:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80195b:	89 c1                	mov    %eax,%ecx
  80195d:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801960:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801964:	eb 0a                	jmp    801970 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801966:	0f b6 10             	movzbl (%eax),%edx
  801969:	39 da                	cmp    %ebx,%edx
  80196b:	74 07                	je     801974 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80196d:	83 c0 01             	add    $0x1,%eax
  801970:	39 c8                	cmp    %ecx,%eax
  801972:	72 f2                	jb     801966 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801974:	5b                   	pop    %ebx
  801975:	5d                   	pop    %ebp
  801976:	c3                   	ret    

00801977 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801977:	55                   	push   %ebp
  801978:	89 e5                	mov    %esp,%ebp
  80197a:	57                   	push   %edi
  80197b:	56                   	push   %esi
  80197c:	53                   	push   %ebx
  80197d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801980:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801983:	eb 03                	jmp    801988 <strtol+0x11>
		s++;
  801985:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801988:	0f b6 01             	movzbl (%ecx),%eax
  80198b:	3c 20                	cmp    $0x20,%al
  80198d:	74 f6                	je     801985 <strtol+0xe>
  80198f:	3c 09                	cmp    $0x9,%al
  801991:	74 f2                	je     801985 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801993:	3c 2b                	cmp    $0x2b,%al
  801995:	75 0a                	jne    8019a1 <strtol+0x2a>
		s++;
  801997:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80199a:	bf 00 00 00 00       	mov    $0x0,%edi
  80199f:	eb 11                	jmp    8019b2 <strtol+0x3b>
  8019a1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8019a6:	3c 2d                	cmp    $0x2d,%al
  8019a8:	75 08                	jne    8019b2 <strtol+0x3b>
		s++, neg = 1;
  8019aa:	83 c1 01             	add    $0x1,%ecx
  8019ad:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019b2:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8019b8:	75 15                	jne    8019cf <strtol+0x58>
  8019ba:	80 39 30             	cmpb   $0x30,(%ecx)
  8019bd:	75 10                	jne    8019cf <strtol+0x58>
  8019bf:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8019c3:	75 7c                	jne    801a41 <strtol+0xca>
		s += 2, base = 16;
  8019c5:	83 c1 02             	add    $0x2,%ecx
  8019c8:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019cd:	eb 16                	jmp    8019e5 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8019cf:	85 db                	test   %ebx,%ebx
  8019d1:	75 12                	jne    8019e5 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8019d3:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019d8:	80 39 30             	cmpb   $0x30,(%ecx)
  8019db:	75 08                	jne    8019e5 <strtol+0x6e>
		s++, base = 8;
  8019dd:	83 c1 01             	add    $0x1,%ecx
  8019e0:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8019e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8019ea:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8019ed:	0f b6 11             	movzbl (%ecx),%edx
  8019f0:	8d 72 d0             	lea    -0x30(%edx),%esi
  8019f3:	89 f3                	mov    %esi,%ebx
  8019f5:	80 fb 09             	cmp    $0x9,%bl
  8019f8:	77 08                	ja     801a02 <strtol+0x8b>
			dig = *s - '0';
  8019fa:	0f be d2             	movsbl %dl,%edx
  8019fd:	83 ea 30             	sub    $0x30,%edx
  801a00:	eb 22                	jmp    801a24 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801a02:	8d 72 9f             	lea    -0x61(%edx),%esi
  801a05:	89 f3                	mov    %esi,%ebx
  801a07:	80 fb 19             	cmp    $0x19,%bl
  801a0a:	77 08                	ja     801a14 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801a0c:	0f be d2             	movsbl %dl,%edx
  801a0f:	83 ea 57             	sub    $0x57,%edx
  801a12:	eb 10                	jmp    801a24 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801a14:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a17:	89 f3                	mov    %esi,%ebx
  801a19:	80 fb 19             	cmp    $0x19,%bl
  801a1c:	77 16                	ja     801a34 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801a1e:	0f be d2             	movsbl %dl,%edx
  801a21:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801a24:	3b 55 10             	cmp    0x10(%ebp),%edx
  801a27:	7d 0b                	jge    801a34 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801a29:	83 c1 01             	add    $0x1,%ecx
  801a2c:	0f af 45 10          	imul   0x10(%ebp),%eax
  801a30:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801a32:	eb b9                	jmp    8019ed <strtol+0x76>

	if (endptr)
  801a34:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a38:	74 0d                	je     801a47 <strtol+0xd0>
		*endptr = (char *) s;
  801a3a:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a3d:	89 0e                	mov    %ecx,(%esi)
  801a3f:	eb 06                	jmp    801a47 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801a41:	85 db                	test   %ebx,%ebx
  801a43:	74 98                	je     8019dd <strtol+0x66>
  801a45:	eb 9e                	jmp    8019e5 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801a47:	89 c2                	mov    %eax,%edx
  801a49:	f7 da                	neg    %edx
  801a4b:	85 ff                	test   %edi,%edi
  801a4d:	0f 45 c2             	cmovne %edx,%eax
}
  801a50:	5b                   	pop    %ebx
  801a51:	5e                   	pop    %esi
  801a52:	5f                   	pop    %edi
  801a53:	5d                   	pop    %ebp
  801a54:	c3                   	ret    

00801a55 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a55:	55                   	push   %ebp
  801a56:	89 e5                	mov    %esp,%ebp
  801a58:	56                   	push   %esi
  801a59:	53                   	push   %ebx
  801a5a:	8b 75 08             	mov    0x8(%ebp),%esi
  801a5d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a60:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int ret;
	if (pg) ret = sys_ipc_recv(pg);
  801a63:	85 c0                	test   %eax,%eax
  801a65:	74 0e                	je     801a75 <ipc_recv+0x20>
  801a67:	83 ec 0c             	sub    $0xc,%esp
  801a6a:	50                   	push   %eax
  801a6b:	e8 9a e8 ff ff       	call   80030a <sys_ipc_recv>
  801a70:	83 c4 10             	add    $0x10,%esp
  801a73:	eb 10                	jmp    801a85 <ipc_recv+0x30>
	else ret = sys_ipc_recv((void*)UTOP);
  801a75:	83 ec 0c             	sub    $0xc,%esp
  801a78:	68 00 00 c0 ee       	push   $0xeec00000
  801a7d:	e8 88 e8 ff ff       	call   80030a <sys_ipc_recv>
  801a82:	83 c4 10             	add    $0x10,%esp
	if (ret) {
  801a85:	85 c0                	test   %eax,%eax
  801a87:	74 16                	je     801a9f <ipc_recv+0x4a>
		if (from_env_store) *from_env_store = 0;
  801a89:	85 f6                	test   %esi,%esi
  801a8b:	74 06                	je     801a93 <ipc_recv+0x3e>
  801a8d:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  801a93:	85 db                	test   %ebx,%ebx
  801a95:	74 2c                	je     801ac3 <ipc_recv+0x6e>
  801a97:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801a9d:	eb 24                	jmp    801ac3 <ipc_recv+0x6e>
		return ret;
	}
	if (from_env_store) *from_env_store = thisenv->env_ipc_from;
  801a9f:	85 f6                	test   %esi,%esi
  801aa1:	74 0a                	je     801aad <ipc_recv+0x58>
  801aa3:	a1 04 40 80 00       	mov    0x804004,%eax
  801aa8:	8b 40 74             	mov    0x74(%eax),%eax
  801aab:	89 06                	mov    %eax,(%esi)
	if (perm_store) *perm_store = thisenv->env_ipc_perm;
  801aad:	85 db                	test   %ebx,%ebx
  801aaf:	74 0a                	je     801abb <ipc_recv+0x66>
  801ab1:	a1 04 40 80 00       	mov    0x804004,%eax
  801ab6:	8b 40 78             	mov    0x78(%eax),%eax
  801ab9:	89 03                	mov    %eax,(%ebx)

	// panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801abb:	a1 04 40 80 00       	mov    0x804004,%eax
  801ac0:	8b 40 70             	mov    0x70(%eax),%eax
}
  801ac3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ac6:	5b                   	pop    %ebx
  801ac7:	5e                   	pop    %esi
  801ac8:	5d                   	pop    %ebp
  801ac9:	c3                   	ret    

00801aca <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801aca:	55                   	push   %ebp
  801acb:	89 e5                	mov    %esp,%ebp
  801acd:	57                   	push   %edi
  801ace:	56                   	push   %esi
  801acf:	53                   	push   %ebx
  801ad0:	83 ec 0c             	sub    $0xc,%esp
  801ad3:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ad6:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ad9:	8b 45 10             	mov    0x10(%ebp),%eax
  801adc:	85 c0                	test   %eax,%eax
  801ade:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801ae3:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	while (true) {
		void* srcva = (pg)? pg: (void*)UTOP;
		int ret = sys_ipc_try_send(to_env, val, srcva, perm);
  801ae6:	ff 75 14             	pushl  0x14(%ebp)
  801ae9:	53                   	push   %ebx
  801aea:	56                   	push   %esi
  801aeb:	57                   	push   %edi
  801aec:	e8 f6 e7 ff ff       	call   8002e7 <sys_ipc_try_send>
		if (ret == 0) break;
  801af1:	83 c4 10             	add    $0x10,%esp
  801af4:	85 c0                	test   %eax,%eax
  801af6:	74 1e                	je     801b16 <ipc_send+0x4c>
		if (ret != -E_IPC_NOT_RECV) panic("ipc_send: %e", ret);
  801af8:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801afb:	74 12                	je     801b0f <ipc_send+0x45>
  801afd:	50                   	push   %eax
  801afe:	68 a0 22 80 00       	push   $0x8022a0
  801b03:	6a 39                	push   $0x39
  801b05:	68 ad 22 80 00       	push   $0x8022ad
  801b0a:	e8 fa f4 ff ff       	call   801009 <_panic>
		sys_yield();
  801b0f:	e8 27 e6 ff ff       	call   80013b <sys_yield>
	}
  801b14:	eb d0                	jmp    801ae6 <ipc_send+0x1c>
	// panic("ipc_send not implemented");
}
  801b16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b19:	5b                   	pop    %ebx
  801b1a:	5e                   	pop    %esi
  801b1b:	5f                   	pop    %edi
  801b1c:	5d                   	pop    %ebp
  801b1d:	c3                   	ret    

00801b1e <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b1e:	55                   	push   %ebp
  801b1f:	89 e5                	mov    %esp,%ebp
  801b21:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b24:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b29:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b2c:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b32:	8b 52 50             	mov    0x50(%edx),%edx
  801b35:	39 ca                	cmp    %ecx,%edx
  801b37:	75 0d                	jne    801b46 <ipc_find_env+0x28>
			return envs[i].env_id;
  801b39:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b3c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b41:	8b 40 48             	mov    0x48(%eax),%eax
  801b44:	eb 0f                	jmp    801b55 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b46:	83 c0 01             	add    $0x1,%eax
  801b49:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b4e:	75 d9                	jne    801b29 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b50:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b55:	5d                   	pop    %ebp
  801b56:	c3                   	ret    

00801b57 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b57:	55                   	push   %ebp
  801b58:	89 e5                	mov    %esp,%ebp
  801b5a:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b5d:	89 d0                	mov    %edx,%eax
  801b5f:	c1 e8 16             	shr    $0x16,%eax
  801b62:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b69:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b6e:	f6 c1 01             	test   $0x1,%cl
  801b71:	74 1d                	je     801b90 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b73:	c1 ea 0c             	shr    $0xc,%edx
  801b76:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b7d:	f6 c2 01             	test   $0x1,%dl
  801b80:	74 0e                	je     801b90 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b82:	c1 ea 0c             	shr    $0xc,%edx
  801b85:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b8c:	ef 
  801b8d:	0f b7 c0             	movzwl %ax,%eax
}
  801b90:	5d                   	pop    %ebp
  801b91:	c3                   	ret    
  801b92:	66 90                	xchg   %ax,%ax
  801b94:	66 90                	xchg   %ax,%ax
  801b96:	66 90                	xchg   %ax,%ax
  801b98:	66 90                	xchg   %ax,%ax
  801b9a:	66 90                	xchg   %ax,%ax
  801b9c:	66 90                	xchg   %ax,%ax
  801b9e:	66 90                	xchg   %ax,%ax

00801ba0 <__udivdi3>:
  801ba0:	55                   	push   %ebp
  801ba1:	57                   	push   %edi
  801ba2:	56                   	push   %esi
  801ba3:	53                   	push   %ebx
  801ba4:	83 ec 1c             	sub    $0x1c,%esp
  801ba7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801bab:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801baf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801bb3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801bb7:	85 f6                	test   %esi,%esi
  801bb9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bbd:	89 ca                	mov    %ecx,%edx
  801bbf:	89 f8                	mov    %edi,%eax
  801bc1:	75 3d                	jne    801c00 <__udivdi3+0x60>
  801bc3:	39 cf                	cmp    %ecx,%edi
  801bc5:	0f 87 c5 00 00 00    	ja     801c90 <__udivdi3+0xf0>
  801bcb:	85 ff                	test   %edi,%edi
  801bcd:	89 fd                	mov    %edi,%ebp
  801bcf:	75 0b                	jne    801bdc <__udivdi3+0x3c>
  801bd1:	b8 01 00 00 00       	mov    $0x1,%eax
  801bd6:	31 d2                	xor    %edx,%edx
  801bd8:	f7 f7                	div    %edi
  801bda:	89 c5                	mov    %eax,%ebp
  801bdc:	89 c8                	mov    %ecx,%eax
  801bde:	31 d2                	xor    %edx,%edx
  801be0:	f7 f5                	div    %ebp
  801be2:	89 c1                	mov    %eax,%ecx
  801be4:	89 d8                	mov    %ebx,%eax
  801be6:	89 cf                	mov    %ecx,%edi
  801be8:	f7 f5                	div    %ebp
  801bea:	89 c3                	mov    %eax,%ebx
  801bec:	89 d8                	mov    %ebx,%eax
  801bee:	89 fa                	mov    %edi,%edx
  801bf0:	83 c4 1c             	add    $0x1c,%esp
  801bf3:	5b                   	pop    %ebx
  801bf4:	5e                   	pop    %esi
  801bf5:	5f                   	pop    %edi
  801bf6:	5d                   	pop    %ebp
  801bf7:	c3                   	ret    
  801bf8:	90                   	nop
  801bf9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c00:	39 ce                	cmp    %ecx,%esi
  801c02:	77 74                	ja     801c78 <__udivdi3+0xd8>
  801c04:	0f bd fe             	bsr    %esi,%edi
  801c07:	83 f7 1f             	xor    $0x1f,%edi
  801c0a:	0f 84 98 00 00 00    	je     801ca8 <__udivdi3+0x108>
  801c10:	bb 20 00 00 00       	mov    $0x20,%ebx
  801c15:	89 f9                	mov    %edi,%ecx
  801c17:	89 c5                	mov    %eax,%ebp
  801c19:	29 fb                	sub    %edi,%ebx
  801c1b:	d3 e6                	shl    %cl,%esi
  801c1d:	89 d9                	mov    %ebx,%ecx
  801c1f:	d3 ed                	shr    %cl,%ebp
  801c21:	89 f9                	mov    %edi,%ecx
  801c23:	d3 e0                	shl    %cl,%eax
  801c25:	09 ee                	or     %ebp,%esi
  801c27:	89 d9                	mov    %ebx,%ecx
  801c29:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c2d:	89 d5                	mov    %edx,%ebp
  801c2f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801c33:	d3 ed                	shr    %cl,%ebp
  801c35:	89 f9                	mov    %edi,%ecx
  801c37:	d3 e2                	shl    %cl,%edx
  801c39:	89 d9                	mov    %ebx,%ecx
  801c3b:	d3 e8                	shr    %cl,%eax
  801c3d:	09 c2                	or     %eax,%edx
  801c3f:	89 d0                	mov    %edx,%eax
  801c41:	89 ea                	mov    %ebp,%edx
  801c43:	f7 f6                	div    %esi
  801c45:	89 d5                	mov    %edx,%ebp
  801c47:	89 c3                	mov    %eax,%ebx
  801c49:	f7 64 24 0c          	mull   0xc(%esp)
  801c4d:	39 d5                	cmp    %edx,%ebp
  801c4f:	72 10                	jb     801c61 <__udivdi3+0xc1>
  801c51:	8b 74 24 08          	mov    0x8(%esp),%esi
  801c55:	89 f9                	mov    %edi,%ecx
  801c57:	d3 e6                	shl    %cl,%esi
  801c59:	39 c6                	cmp    %eax,%esi
  801c5b:	73 07                	jae    801c64 <__udivdi3+0xc4>
  801c5d:	39 d5                	cmp    %edx,%ebp
  801c5f:	75 03                	jne    801c64 <__udivdi3+0xc4>
  801c61:	83 eb 01             	sub    $0x1,%ebx
  801c64:	31 ff                	xor    %edi,%edi
  801c66:	89 d8                	mov    %ebx,%eax
  801c68:	89 fa                	mov    %edi,%edx
  801c6a:	83 c4 1c             	add    $0x1c,%esp
  801c6d:	5b                   	pop    %ebx
  801c6e:	5e                   	pop    %esi
  801c6f:	5f                   	pop    %edi
  801c70:	5d                   	pop    %ebp
  801c71:	c3                   	ret    
  801c72:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c78:	31 ff                	xor    %edi,%edi
  801c7a:	31 db                	xor    %ebx,%ebx
  801c7c:	89 d8                	mov    %ebx,%eax
  801c7e:	89 fa                	mov    %edi,%edx
  801c80:	83 c4 1c             	add    $0x1c,%esp
  801c83:	5b                   	pop    %ebx
  801c84:	5e                   	pop    %esi
  801c85:	5f                   	pop    %edi
  801c86:	5d                   	pop    %ebp
  801c87:	c3                   	ret    
  801c88:	90                   	nop
  801c89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c90:	89 d8                	mov    %ebx,%eax
  801c92:	f7 f7                	div    %edi
  801c94:	31 ff                	xor    %edi,%edi
  801c96:	89 c3                	mov    %eax,%ebx
  801c98:	89 d8                	mov    %ebx,%eax
  801c9a:	89 fa                	mov    %edi,%edx
  801c9c:	83 c4 1c             	add    $0x1c,%esp
  801c9f:	5b                   	pop    %ebx
  801ca0:	5e                   	pop    %esi
  801ca1:	5f                   	pop    %edi
  801ca2:	5d                   	pop    %ebp
  801ca3:	c3                   	ret    
  801ca4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ca8:	39 ce                	cmp    %ecx,%esi
  801caa:	72 0c                	jb     801cb8 <__udivdi3+0x118>
  801cac:	31 db                	xor    %ebx,%ebx
  801cae:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801cb2:	0f 87 34 ff ff ff    	ja     801bec <__udivdi3+0x4c>
  801cb8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801cbd:	e9 2a ff ff ff       	jmp    801bec <__udivdi3+0x4c>
  801cc2:	66 90                	xchg   %ax,%ax
  801cc4:	66 90                	xchg   %ax,%ax
  801cc6:	66 90                	xchg   %ax,%ax
  801cc8:	66 90                	xchg   %ax,%ax
  801cca:	66 90                	xchg   %ax,%ax
  801ccc:	66 90                	xchg   %ax,%ax
  801cce:	66 90                	xchg   %ax,%ax

00801cd0 <__umoddi3>:
  801cd0:	55                   	push   %ebp
  801cd1:	57                   	push   %edi
  801cd2:	56                   	push   %esi
  801cd3:	53                   	push   %ebx
  801cd4:	83 ec 1c             	sub    $0x1c,%esp
  801cd7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801cdb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801cdf:	8b 74 24 34          	mov    0x34(%esp),%esi
  801ce3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801ce7:	85 d2                	test   %edx,%edx
  801ce9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801ced:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801cf1:	89 f3                	mov    %esi,%ebx
  801cf3:	89 3c 24             	mov    %edi,(%esp)
  801cf6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cfa:	75 1c                	jne    801d18 <__umoddi3+0x48>
  801cfc:	39 f7                	cmp    %esi,%edi
  801cfe:	76 50                	jbe    801d50 <__umoddi3+0x80>
  801d00:	89 c8                	mov    %ecx,%eax
  801d02:	89 f2                	mov    %esi,%edx
  801d04:	f7 f7                	div    %edi
  801d06:	89 d0                	mov    %edx,%eax
  801d08:	31 d2                	xor    %edx,%edx
  801d0a:	83 c4 1c             	add    $0x1c,%esp
  801d0d:	5b                   	pop    %ebx
  801d0e:	5e                   	pop    %esi
  801d0f:	5f                   	pop    %edi
  801d10:	5d                   	pop    %ebp
  801d11:	c3                   	ret    
  801d12:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d18:	39 f2                	cmp    %esi,%edx
  801d1a:	89 d0                	mov    %edx,%eax
  801d1c:	77 52                	ja     801d70 <__umoddi3+0xa0>
  801d1e:	0f bd ea             	bsr    %edx,%ebp
  801d21:	83 f5 1f             	xor    $0x1f,%ebp
  801d24:	75 5a                	jne    801d80 <__umoddi3+0xb0>
  801d26:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801d2a:	0f 82 e0 00 00 00    	jb     801e10 <__umoddi3+0x140>
  801d30:	39 0c 24             	cmp    %ecx,(%esp)
  801d33:	0f 86 d7 00 00 00    	jbe    801e10 <__umoddi3+0x140>
  801d39:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d3d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d41:	83 c4 1c             	add    $0x1c,%esp
  801d44:	5b                   	pop    %ebx
  801d45:	5e                   	pop    %esi
  801d46:	5f                   	pop    %edi
  801d47:	5d                   	pop    %ebp
  801d48:	c3                   	ret    
  801d49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d50:	85 ff                	test   %edi,%edi
  801d52:	89 fd                	mov    %edi,%ebp
  801d54:	75 0b                	jne    801d61 <__umoddi3+0x91>
  801d56:	b8 01 00 00 00       	mov    $0x1,%eax
  801d5b:	31 d2                	xor    %edx,%edx
  801d5d:	f7 f7                	div    %edi
  801d5f:	89 c5                	mov    %eax,%ebp
  801d61:	89 f0                	mov    %esi,%eax
  801d63:	31 d2                	xor    %edx,%edx
  801d65:	f7 f5                	div    %ebp
  801d67:	89 c8                	mov    %ecx,%eax
  801d69:	f7 f5                	div    %ebp
  801d6b:	89 d0                	mov    %edx,%eax
  801d6d:	eb 99                	jmp    801d08 <__umoddi3+0x38>
  801d6f:	90                   	nop
  801d70:	89 c8                	mov    %ecx,%eax
  801d72:	89 f2                	mov    %esi,%edx
  801d74:	83 c4 1c             	add    $0x1c,%esp
  801d77:	5b                   	pop    %ebx
  801d78:	5e                   	pop    %esi
  801d79:	5f                   	pop    %edi
  801d7a:	5d                   	pop    %ebp
  801d7b:	c3                   	ret    
  801d7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d80:	8b 34 24             	mov    (%esp),%esi
  801d83:	bf 20 00 00 00       	mov    $0x20,%edi
  801d88:	89 e9                	mov    %ebp,%ecx
  801d8a:	29 ef                	sub    %ebp,%edi
  801d8c:	d3 e0                	shl    %cl,%eax
  801d8e:	89 f9                	mov    %edi,%ecx
  801d90:	89 f2                	mov    %esi,%edx
  801d92:	d3 ea                	shr    %cl,%edx
  801d94:	89 e9                	mov    %ebp,%ecx
  801d96:	09 c2                	or     %eax,%edx
  801d98:	89 d8                	mov    %ebx,%eax
  801d9a:	89 14 24             	mov    %edx,(%esp)
  801d9d:	89 f2                	mov    %esi,%edx
  801d9f:	d3 e2                	shl    %cl,%edx
  801da1:	89 f9                	mov    %edi,%ecx
  801da3:	89 54 24 04          	mov    %edx,0x4(%esp)
  801da7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801dab:	d3 e8                	shr    %cl,%eax
  801dad:	89 e9                	mov    %ebp,%ecx
  801daf:	89 c6                	mov    %eax,%esi
  801db1:	d3 e3                	shl    %cl,%ebx
  801db3:	89 f9                	mov    %edi,%ecx
  801db5:	89 d0                	mov    %edx,%eax
  801db7:	d3 e8                	shr    %cl,%eax
  801db9:	89 e9                	mov    %ebp,%ecx
  801dbb:	09 d8                	or     %ebx,%eax
  801dbd:	89 d3                	mov    %edx,%ebx
  801dbf:	89 f2                	mov    %esi,%edx
  801dc1:	f7 34 24             	divl   (%esp)
  801dc4:	89 d6                	mov    %edx,%esi
  801dc6:	d3 e3                	shl    %cl,%ebx
  801dc8:	f7 64 24 04          	mull   0x4(%esp)
  801dcc:	39 d6                	cmp    %edx,%esi
  801dce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801dd2:	89 d1                	mov    %edx,%ecx
  801dd4:	89 c3                	mov    %eax,%ebx
  801dd6:	72 08                	jb     801de0 <__umoddi3+0x110>
  801dd8:	75 11                	jne    801deb <__umoddi3+0x11b>
  801dda:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801dde:	73 0b                	jae    801deb <__umoddi3+0x11b>
  801de0:	2b 44 24 04          	sub    0x4(%esp),%eax
  801de4:	1b 14 24             	sbb    (%esp),%edx
  801de7:	89 d1                	mov    %edx,%ecx
  801de9:	89 c3                	mov    %eax,%ebx
  801deb:	8b 54 24 08          	mov    0x8(%esp),%edx
  801def:	29 da                	sub    %ebx,%edx
  801df1:	19 ce                	sbb    %ecx,%esi
  801df3:	89 f9                	mov    %edi,%ecx
  801df5:	89 f0                	mov    %esi,%eax
  801df7:	d3 e0                	shl    %cl,%eax
  801df9:	89 e9                	mov    %ebp,%ecx
  801dfb:	d3 ea                	shr    %cl,%edx
  801dfd:	89 e9                	mov    %ebp,%ecx
  801dff:	d3 ee                	shr    %cl,%esi
  801e01:	09 d0                	or     %edx,%eax
  801e03:	89 f2                	mov    %esi,%edx
  801e05:	83 c4 1c             	add    $0x1c,%esp
  801e08:	5b                   	pop    %ebx
  801e09:	5e                   	pop    %esi
  801e0a:	5f                   	pop    %edi
  801e0b:	5d                   	pop    %ebp
  801e0c:	c3                   	ret    
  801e0d:	8d 76 00             	lea    0x0(%esi),%esi
  801e10:	29 f9                	sub    %edi,%ecx
  801e12:	19 d6                	sbb    %edx,%esi
  801e14:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e18:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e1c:	e9 18 ff ff ff       	jmp    801d39 <__umoddi3+0x69>
