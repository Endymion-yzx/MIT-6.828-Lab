
obj/user/breakpoint.debug:     file format elf32-i386


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
  80002c:	e8 08 00 00 00       	call   800039 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $3");
  800036:	cc                   	int3   
}
  800037:	5d                   	pop    %ebp
  800038:	c3                   	ret    

00800039 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800039:	55                   	push   %ebp
  80003a:	89 e5                	mov    %esp,%ebp
  80003c:	56                   	push   %esi
  80003d:	53                   	push   %ebx
  80003e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800041:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	envid_t envid = sys_getenvid();
  800044:	e8 ce 00 00 00       	call   800117 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  800049:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800051:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800056:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005b:	85 db                	test   %ebx,%ebx
  80005d:	7e 07                	jle    800066 <libmain+0x2d>
		binaryname = argv[0];
  80005f:	8b 06                	mov    (%esi),%eax
  800061:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800066:	83 ec 08             	sub    $0x8,%esp
  800069:	56                   	push   %esi
  80006a:	53                   	push   %ebx
  80006b:	e8 c3 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800070:	e8 0a 00 00 00       	call   80007f <exit>
}
  800075:	83 c4 10             	add    $0x10,%esp
  800078:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80007b:	5b                   	pop    %ebx
  80007c:	5e                   	pop    %esi
  80007d:	5d                   	pop    %ebp
  80007e:	c3                   	ret    

0080007f <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80007f:	55                   	push   %ebp
  800080:	89 e5                	mov    %esp,%ebp
  800082:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800085:	e8 87 04 00 00       	call   800511 <close_all>
	sys_env_destroy(0);
  80008a:	83 ec 0c             	sub    $0xc,%esp
  80008d:	6a 00                	push   $0x0
  80008f:	e8 42 00 00 00       	call   8000d6 <sys_env_destroy>
}
  800094:	83 c4 10             	add    $0x10,%esp
  800097:	c9                   	leave  
  800098:	c3                   	ret    

00800099 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800099:	55                   	push   %ebp
  80009a:	89 e5                	mov    %esp,%ebp
  80009c:	57                   	push   %edi
  80009d:	56                   	push   %esi
  80009e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80009f:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000aa:	89 c3                	mov    %eax,%ebx
  8000ac:	89 c7                	mov    %eax,%edi
  8000ae:	89 c6                	mov    %eax,%esi
  8000b0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b2:	5b                   	pop    %ebx
  8000b3:	5e                   	pop    %esi
  8000b4:	5f                   	pop    %edi
  8000b5:	5d                   	pop    %ebp
  8000b6:	c3                   	ret    

008000b7 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b7:	55                   	push   %ebp
  8000b8:	89 e5                	mov    %esp,%ebp
  8000ba:	57                   	push   %edi
  8000bb:	56                   	push   %esi
  8000bc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c2:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c7:	89 d1                	mov    %edx,%ecx
  8000c9:	89 d3                	mov    %edx,%ebx
  8000cb:	89 d7                	mov    %edx,%edi
  8000cd:	89 d6                	mov    %edx,%esi
  8000cf:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d1:	5b                   	pop    %ebx
  8000d2:	5e                   	pop    %esi
  8000d3:	5f                   	pop    %edi
  8000d4:	5d                   	pop    %ebp
  8000d5:	c3                   	ret    

008000d6 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d6:	55                   	push   %ebp
  8000d7:	89 e5                	mov    %esp,%ebp
  8000d9:	57                   	push   %edi
  8000da:	56                   	push   %esi
  8000db:	53                   	push   %ebx
  8000dc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000df:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e4:	b8 03 00 00 00       	mov    $0x3,%eax
  8000e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ec:	89 cb                	mov    %ecx,%ebx
  8000ee:	89 cf                	mov    %ecx,%edi
  8000f0:	89 ce                	mov    %ecx,%esi
  8000f2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8000f4:	85 c0                	test   %eax,%eax
  8000f6:	7e 17                	jle    80010f <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f8:	83 ec 0c             	sub    $0xc,%esp
  8000fb:	50                   	push   %eax
  8000fc:	6a 03                	push   $0x3
  8000fe:	68 2a 1e 80 00       	push   $0x801e2a
  800103:	6a 23                	push   $0x23
  800105:	68 47 1e 80 00       	push   $0x801e47
  80010a:	e8 f5 0e 00 00       	call   801004 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80010f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800112:	5b                   	pop    %ebx
  800113:	5e                   	pop    %esi
  800114:	5f                   	pop    %edi
  800115:	5d                   	pop    %ebp
  800116:	c3                   	ret    

00800117 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800117:	55                   	push   %ebp
  800118:	89 e5                	mov    %esp,%ebp
  80011a:	57                   	push   %edi
  80011b:	56                   	push   %esi
  80011c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80011d:	ba 00 00 00 00       	mov    $0x0,%edx
  800122:	b8 02 00 00 00       	mov    $0x2,%eax
  800127:	89 d1                	mov    %edx,%ecx
  800129:	89 d3                	mov    %edx,%ebx
  80012b:	89 d7                	mov    %edx,%edi
  80012d:	89 d6                	mov    %edx,%esi
  80012f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800131:	5b                   	pop    %ebx
  800132:	5e                   	pop    %esi
  800133:	5f                   	pop    %edi
  800134:	5d                   	pop    %ebp
  800135:	c3                   	ret    

00800136 <sys_yield>:

void
sys_yield(void)
{
  800136:	55                   	push   %ebp
  800137:	89 e5                	mov    %esp,%ebp
  800139:	57                   	push   %edi
  80013a:	56                   	push   %esi
  80013b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80013c:	ba 00 00 00 00       	mov    $0x0,%edx
  800141:	b8 0b 00 00 00       	mov    $0xb,%eax
  800146:	89 d1                	mov    %edx,%ecx
  800148:	89 d3                	mov    %edx,%ebx
  80014a:	89 d7                	mov    %edx,%edi
  80014c:	89 d6                	mov    %edx,%esi
  80014e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800150:	5b                   	pop    %ebx
  800151:	5e                   	pop    %esi
  800152:	5f                   	pop    %edi
  800153:	5d                   	pop    %ebp
  800154:	c3                   	ret    

00800155 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800155:	55                   	push   %ebp
  800156:	89 e5                	mov    %esp,%ebp
  800158:	57                   	push   %edi
  800159:	56                   	push   %esi
  80015a:	53                   	push   %ebx
  80015b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80015e:	be 00 00 00 00       	mov    $0x0,%esi
  800163:	b8 04 00 00 00       	mov    $0x4,%eax
  800168:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80016b:	8b 55 08             	mov    0x8(%ebp),%edx
  80016e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800171:	89 f7                	mov    %esi,%edi
  800173:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800175:	85 c0                	test   %eax,%eax
  800177:	7e 17                	jle    800190 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800179:	83 ec 0c             	sub    $0xc,%esp
  80017c:	50                   	push   %eax
  80017d:	6a 04                	push   $0x4
  80017f:	68 2a 1e 80 00       	push   $0x801e2a
  800184:	6a 23                	push   $0x23
  800186:	68 47 1e 80 00       	push   $0x801e47
  80018b:	e8 74 0e 00 00       	call   801004 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800190:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800193:	5b                   	pop    %ebx
  800194:	5e                   	pop    %esi
  800195:	5f                   	pop    %edi
  800196:	5d                   	pop    %ebp
  800197:	c3                   	ret    

00800198 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800198:	55                   	push   %ebp
  800199:	89 e5                	mov    %esp,%ebp
  80019b:	57                   	push   %edi
  80019c:	56                   	push   %esi
  80019d:	53                   	push   %ebx
  80019e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001a1:	b8 05 00 00 00       	mov    $0x5,%eax
  8001a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001af:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001b2:	8b 75 18             	mov    0x18(%ebp),%esi
  8001b5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001b7:	85 c0                	test   %eax,%eax
  8001b9:	7e 17                	jle    8001d2 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001bb:	83 ec 0c             	sub    $0xc,%esp
  8001be:	50                   	push   %eax
  8001bf:	6a 05                	push   $0x5
  8001c1:	68 2a 1e 80 00       	push   $0x801e2a
  8001c6:	6a 23                	push   $0x23
  8001c8:	68 47 1e 80 00       	push   $0x801e47
  8001cd:	e8 32 0e 00 00       	call   801004 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d5:	5b                   	pop    %ebx
  8001d6:	5e                   	pop    %esi
  8001d7:	5f                   	pop    %edi
  8001d8:	5d                   	pop    %ebp
  8001d9:	c3                   	ret    

008001da <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001da:	55                   	push   %ebp
  8001db:	89 e5                	mov    %esp,%ebp
  8001dd:	57                   	push   %edi
  8001de:	56                   	push   %esi
  8001df:	53                   	push   %ebx
  8001e0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e8:	b8 06 00 00 00       	mov    $0x6,%eax
  8001ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f3:	89 df                	mov    %ebx,%edi
  8001f5:	89 de                	mov    %ebx,%esi
  8001f7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001f9:	85 c0                	test   %eax,%eax
  8001fb:	7e 17                	jle    800214 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001fd:	83 ec 0c             	sub    $0xc,%esp
  800200:	50                   	push   %eax
  800201:	6a 06                	push   $0x6
  800203:	68 2a 1e 80 00       	push   $0x801e2a
  800208:	6a 23                	push   $0x23
  80020a:	68 47 1e 80 00       	push   $0x801e47
  80020f:	e8 f0 0d 00 00       	call   801004 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800214:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800217:	5b                   	pop    %ebx
  800218:	5e                   	pop    %esi
  800219:	5f                   	pop    %edi
  80021a:	5d                   	pop    %ebp
  80021b:	c3                   	ret    

0080021c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	57                   	push   %edi
  800220:	56                   	push   %esi
  800221:	53                   	push   %ebx
  800222:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800225:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022a:	b8 08 00 00 00       	mov    $0x8,%eax
  80022f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800232:	8b 55 08             	mov    0x8(%ebp),%edx
  800235:	89 df                	mov    %ebx,%edi
  800237:	89 de                	mov    %ebx,%esi
  800239:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80023b:	85 c0                	test   %eax,%eax
  80023d:	7e 17                	jle    800256 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80023f:	83 ec 0c             	sub    $0xc,%esp
  800242:	50                   	push   %eax
  800243:	6a 08                	push   $0x8
  800245:	68 2a 1e 80 00       	push   $0x801e2a
  80024a:	6a 23                	push   $0x23
  80024c:	68 47 1e 80 00       	push   $0x801e47
  800251:	e8 ae 0d 00 00       	call   801004 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800256:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800259:	5b                   	pop    %ebx
  80025a:	5e                   	pop    %esi
  80025b:	5f                   	pop    %edi
  80025c:	5d                   	pop    %ebp
  80025d:	c3                   	ret    

0080025e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80025e:	55                   	push   %ebp
  80025f:	89 e5                	mov    %esp,%ebp
  800261:	57                   	push   %edi
  800262:	56                   	push   %esi
  800263:	53                   	push   %ebx
  800264:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800267:	bb 00 00 00 00       	mov    $0x0,%ebx
  80026c:	b8 09 00 00 00       	mov    $0x9,%eax
  800271:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800274:	8b 55 08             	mov    0x8(%ebp),%edx
  800277:	89 df                	mov    %ebx,%edi
  800279:	89 de                	mov    %ebx,%esi
  80027b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80027d:	85 c0                	test   %eax,%eax
  80027f:	7e 17                	jle    800298 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800281:	83 ec 0c             	sub    $0xc,%esp
  800284:	50                   	push   %eax
  800285:	6a 09                	push   $0x9
  800287:	68 2a 1e 80 00       	push   $0x801e2a
  80028c:	6a 23                	push   $0x23
  80028e:	68 47 1e 80 00       	push   $0x801e47
  800293:	e8 6c 0d 00 00       	call   801004 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800298:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80029b:	5b                   	pop    %ebx
  80029c:	5e                   	pop    %esi
  80029d:	5f                   	pop    %edi
  80029e:	5d                   	pop    %ebp
  80029f:	c3                   	ret    

008002a0 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	57                   	push   %edi
  8002a4:	56                   	push   %esi
  8002a5:	53                   	push   %ebx
  8002a6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002a9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002ae:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b9:	89 df                	mov    %ebx,%edi
  8002bb:	89 de                	mov    %ebx,%esi
  8002bd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002bf:	85 c0                	test   %eax,%eax
  8002c1:	7e 17                	jle    8002da <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002c3:	83 ec 0c             	sub    $0xc,%esp
  8002c6:	50                   	push   %eax
  8002c7:	6a 0a                	push   $0xa
  8002c9:	68 2a 1e 80 00       	push   $0x801e2a
  8002ce:	6a 23                	push   $0x23
  8002d0:	68 47 1e 80 00       	push   $0x801e47
  8002d5:	e8 2a 0d 00 00       	call   801004 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002dd:	5b                   	pop    %ebx
  8002de:	5e                   	pop    %esi
  8002df:	5f                   	pop    %edi
  8002e0:	5d                   	pop    %ebp
  8002e1:	c3                   	ret    

008002e2 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002e2:	55                   	push   %ebp
  8002e3:	89 e5                	mov    %esp,%ebp
  8002e5:	57                   	push   %edi
  8002e6:	56                   	push   %esi
  8002e7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002e8:	be 00 00 00 00       	mov    $0x0,%esi
  8002ed:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002fb:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002fe:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800300:	5b                   	pop    %ebx
  800301:	5e                   	pop    %esi
  800302:	5f                   	pop    %edi
  800303:	5d                   	pop    %ebp
  800304:	c3                   	ret    

00800305 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800305:	55                   	push   %ebp
  800306:	89 e5                	mov    %esp,%ebp
  800308:	57                   	push   %edi
  800309:	56                   	push   %esi
  80030a:	53                   	push   %ebx
  80030b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80030e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800313:	b8 0d 00 00 00       	mov    $0xd,%eax
  800318:	8b 55 08             	mov    0x8(%ebp),%edx
  80031b:	89 cb                	mov    %ecx,%ebx
  80031d:	89 cf                	mov    %ecx,%edi
  80031f:	89 ce                	mov    %ecx,%esi
  800321:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800323:	85 c0                	test   %eax,%eax
  800325:	7e 17                	jle    80033e <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800327:	83 ec 0c             	sub    $0xc,%esp
  80032a:	50                   	push   %eax
  80032b:	6a 0d                	push   $0xd
  80032d:	68 2a 1e 80 00       	push   $0x801e2a
  800332:	6a 23                	push   $0x23
  800334:	68 47 1e 80 00       	push   $0x801e47
  800339:	e8 c6 0c 00 00       	call   801004 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80033e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800341:	5b                   	pop    %ebx
  800342:	5e                   	pop    %esi
  800343:	5f                   	pop    %edi
  800344:	5d                   	pop    %ebp
  800345:	c3                   	ret    

00800346 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800346:	55                   	push   %ebp
  800347:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800349:	8b 45 08             	mov    0x8(%ebp),%eax
  80034c:	05 00 00 00 30       	add    $0x30000000,%eax
  800351:	c1 e8 0c             	shr    $0xc,%eax
}
  800354:	5d                   	pop    %ebp
  800355:	c3                   	ret    

00800356 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800356:	55                   	push   %ebp
  800357:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800359:	8b 45 08             	mov    0x8(%ebp),%eax
  80035c:	05 00 00 00 30       	add    $0x30000000,%eax
  800361:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800366:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80036b:	5d                   	pop    %ebp
  80036c:	c3                   	ret    

0080036d <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80036d:	55                   	push   %ebp
  80036e:	89 e5                	mov    %esp,%ebp
  800370:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800373:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800378:	89 c2                	mov    %eax,%edx
  80037a:	c1 ea 16             	shr    $0x16,%edx
  80037d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800384:	f6 c2 01             	test   $0x1,%dl
  800387:	74 11                	je     80039a <fd_alloc+0x2d>
  800389:	89 c2                	mov    %eax,%edx
  80038b:	c1 ea 0c             	shr    $0xc,%edx
  80038e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800395:	f6 c2 01             	test   $0x1,%dl
  800398:	75 09                	jne    8003a3 <fd_alloc+0x36>
			*fd_store = fd;
  80039a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80039c:	b8 00 00 00 00       	mov    $0x0,%eax
  8003a1:	eb 17                	jmp    8003ba <fd_alloc+0x4d>
  8003a3:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003a8:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003ad:	75 c9                	jne    800378 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003af:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003b5:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003ba:	5d                   	pop    %ebp
  8003bb:	c3                   	ret    

008003bc <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003bc:	55                   	push   %ebp
  8003bd:	89 e5                	mov    %esp,%ebp
  8003bf:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003c2:	83 f8 1f             	cmp    $0x1f,%eax
  8003c5:	77 36                	ja     8003fd <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003c7:	c1 e0 0c             	shl    $0xc,%eax
  8003ca:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003cf:	89 c2                	mov    %eax,%edx
  8003d1:	c1 ea 16             	shr    $0x16,%edx
  8003d4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003db:	f6 c2 01             	test   $0x1,%dl
  8003de:	74 24                	je     800404 <fd_lookup+0x48>
  8003e0:	89 c2                	mov    %eax,%edx
  8003e2:	c1 ea 0c             	shr    $0xc,%edx
  8003e5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003ec:	f6 c2 01             	test   $0x1,%dl
  8003ef:	74 1a                	je     80040b <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003f1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003f4:	89 02                	mov    %eax,(%edx)
	return 0;
  8003f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8003fb:	eb 13                	jmp    800410 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8003fd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800402:	eb 0c                	jmp    800410 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800404:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800409:	eb 05                	jmp    800410 <fd_lookup+0x54>
  80040b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800410:	5d                   	pop    %ebp
  800411:	c3                   	ret    

00800412 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800412:	55                   	push   %ebp
  800413:	89 e5                	mov    %esp,%ebp
  800415:	83 ec 08             	sub    $0x8,%esp
  800418:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80041b:	ba d4 1e 80 00       	mov    $0x801ed4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800420:	eb 13                	jmp    800435 <dev_lookup+0x23>
  800422:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800425:	39 08                	cmp    %ecx,(%eax)
  800427:	75 0c                	jne    800435 <dev_lookup+0x23>
			*dev = devtab[i];
  800429:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80042c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80042e:	b8 00 00 00 00       	mov    $0x0,%eax
  800433:	eb 2e                	jmp    800463 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800435:	8b 02                	mov    (%edx),%eax
  800437:	85 c0                	test   %eax,%eax
  800439:	75 e7                	jne    800422 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80043b:	a1 04 40 80 00       	mov    0x804004,%eax
  800440:	8b 40 48             	mov    0x48(%eax),%eax
  800443:	83 ec 04             	sub    $0x4,%esp
  800446:	51                   	push   %ecx
  800447:	50                   	push   %eax
  800448:	68 58 1e 80 00       	push   $0x801e58
  80044d:	e8 8b 0c 00 00       	call   8010dd <cprintf>
	*dev = 0;
  800452:	8b 45 0c             	mov    0xc(%ebp),%eax
  800455:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80045b:	83 c4 10             	add    $0x10,%esp
  80045e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800463:	c9                   	leave  
  800464:	c3                   	ret    

00800465 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800465:	55                   	push   %ebp
  800466:	89 e5                	mov    %esp,%ebp
  800468:	56                   	push   %esi
  800469:	53                   	push   %ebx
  80046a:	83 ec 10             	sub    $0x10,%esp
  80046d:	8b 75 08             	mov    0x8(%ebp),%esi
  800470:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800473:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800476:	50                   	push   %eax
  800477:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80047d:	c1 e8 0c             	shr    $0xc,%eax
  800480:	50                   	push   %eax
  800481:	e8 36 ff ff ff       	call   8003bc <fd_lookup>
  800486:	83 c4 08             	add    $0x8,%esp
  800489:	85 c0                	test   %eax,%eax
  80048b:	78 05                	js     800492 <fd_close+0x2d>
	    || fd != fd2)
  80048d:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800490:	74 0c                	je     80049e <fd_close+0x39>
		return (must_exist ? r : 0);
  800492:	84 db                	test   %bl,%bl
  800494:	ba 00 00 00 00       	mov    $0x0,%edx
  800499:	0f 44 c2             	cmove  %edx,%eax
  80049c:	eb 41                	jmp    8004df <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80049e:	83 ec 08             	sub    $0x8,%esp
  8004a1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004a4:	50                   	push   %eax
  8004a5:	ff 36                	pushl  (%esi)
  8004a7:	e8 66 ff ff ff       	call   800412 <dev_lookup>
  8004ac:	89 c3                	mov    %eax,%ebx
  8004ae:	83 c4 10             	add    $0x10,%esp
  8004b1:	85 c0                	test   %eax,%eax
  8004b3:	78 1a                	js     8004cf <fd_close+0x6a>
		if (dev->dev_close)
  8004b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004b8:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004bb:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004c0:	85 c0                	test   %eax,%eax
  8004c2:	74 0b                	je     8004cf <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004c4:	83 ec 0c             	sub    $0xc,%esp
  8004c7:	56                   	push   %esi
  8004c8:	ff d0                	call   *%eax
  8004ca:	89 c3                	mov    %eax,%ebx
  8004cc:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004cf:	83 ec 08             	sub    $0x8,%esp
  8004d2:	56                   	push   %esi
  8004d3:	6a 00                	push   $0x0
  8004d5:	e8 00 fd ff ff       	call   8001da <sys_page_unmap>
	return r;
  8004da:	83 c4 10             	add    $0x10,%esp
  8004dd:	89 d8                	mov    %ebx,%eax
}
  8004df:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004e2:	5b                   	pop    %ebx
  8004e3:	5e                   	pop    %esi
  8004e4:	5d                   	pop    %ebp
  8004e5:	c3                   	ret    

008004e6 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8004e6:	55                   	push   %ebp
  8004e7:	89 e5                	mov    %esp,%ebp
  8004e9:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004ef:	50                   	push   %eax
  8004f0:	ff 75 08             	pushl  0x8(%ebp)
  8004f3:	e8 c4 fe ff ff       	call   8003bc <fd_lookup>
  8004f8:	83 c4 08             	add    $0x8,%esp
  8004fb:	85 c0                	test   %eax,%eax
  8004fd:	78 10                	js     80050f <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8004ff:	83 ec 08             	sub    $0x8,%esp
  800502:	6a 01                	push   $0x1
  800504:	ff 75 f4             	pushl  -0xc(%ebp)
  800507:	e8 59 ff ff ff       	call   800465 <fd_close>
  80050c:	83 c4 10             	add    $0x10,%esp
}
  80050f:	c9                   	leave  
  800510:	c3                   	ret    

00800511 <close_all>:

void
close_all(void)
{
  800511:	55                   	push   %ebp
  800512:	89 e5                	mov    %esp,%ebp
  800514:	53                   	push   %ebx
  800515:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800518:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80051d:	83 ec 0c             	sub    $0xc,%esp
  800520:	53                   	push   %ebx
  800521:	e8 c0 ff ff ff       	call   8004e6 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800526:	83 c3 01             	add    $0x1,%ebx
  800529:	83 c4 10             	add    $0x10,%esp
  80052c:	83 fb 20             	cmp    $0x20,%ebx
  80052f:	75 ec                	jne    80051d <close_all+0xc>
		close(i);
}
  800531:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800534:	c9                   	leave  
  800535:	c3                   	ret    

00800536 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800536:	55                   	push   %ebp
  800537:	89 e5                	mov    %esp,%ebp
  800539:	57                   	push   %edi
  80053a:	56                   	push   %esi
  80053b:	53                   	push   %ebx
  80053c:	83 ec 2c             	sub    $0x2c,%esp
  80053f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800542:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800545:	50                   	push   %eax
  800546:	ff 75 08             	pushl  0x8(%ebp)
  800549:	e8 6e fe ff ff       	call   8003bc <fd_lookup>
  80054e:	83 c4 08             	add    $0x8,%esp
  800551:	85 c0                	test   %eax,%eax
  800553:	0f 88 c1 00 00 00    	js     80061a <dup+0xe4>
		return r;
	close(newfdnum);
  800559:	83 ec 0c             	sub    $0xc,%esp
  80055c:	56                   	push   %esi
  80055d:	e8 84 ff ff ff       	call   8004e6 <close>

	newfd = INDEX2FD(newfdnum);
  800562:	89 f3                	mov    %esi,%ebx
  800564:	c1 e3 0c             	shl    $0xc,%ebx
  800567:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80056d:	83 c4 04             	add    $0x4,%esp
  800570:	ff 75 e4             	pushl  -0x1c(%ebp)
  800573:	e8 de fd ff ff       	call   800356 <fd2data>
  800578:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80057a:	89 1c 24             	mov    %ebx,(%esp)
  80057d:	e8 d4 fd ff ff       	call   800356 <fd2data>
  800582:	83 c4 10             	add    $0x10,%esp
  800585:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800588:	89 f8                	mov    %edi,%eax
  80058a:	c1 e8 16             	shr    $0x16,%eax
  80058d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800594:	a8 01                	test   $0x1,%al
  800596:	74 37                	je     8005cf <dup+0x99>
  800598:	89 f8                	mov    %edi,%eax
  80059a:	c1 e8 0c             	shr    $0xc,%eax
  80059d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005a4:	f6 c2 01             	test   $0x1,%dl
  8005a7:	74 26                	je     8005cf <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005a9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005b0:	83 ec 0c             	sub    $0xc,%esp
  8005b3:	25 07 0e 00 00       	and    $0xe07,%eax
  8005b8:	50                   	push   %eax
  8005b9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005bc:	6a 00                	push   $0x0
  8005be:	57                   	push   %edi
  8005bf:	6a 00                	push   $0x0
  8005c1:	e8 d2 fb ff ff       	call   800198 <sys_page_map>
  8005c6:	89 c7                	mov    %eax,%edi
  8005c8:	83 c4 20             	add    $0x20,%esp
  8005cb:	85 c0                	test   %eax,%eax
  8005cd:	78 2e                	js     8005fd <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005cf:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005d2:	89 d0                	mov    %edx,%eax
  8005d4:	c1 e8 0c             	shr    $0xc,%eax
  8005d7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005de:	83 ec 0c             	sub    $0xc,%esp
  8005e1:	25 07 0e 00 00       	and    $0xe07,%eax
  8005e6:	50                   	push   %eax
  8005e7:	53                   	push   %ebx
  8005e8:	6a 00                	push   $0x0
  8005ea:	52                   	push   %edx
  8005eb:	6a 00                	push   $0x0
  8005ed:	e8 a6 fb ff ff       	call   800198 <sys_page_map>
  8005f2:	89 c7                	mov    %eax,%edi
  8005f4:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8005f7:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005f9:	85 ff                	test   %edi,%edi
  8005fb:	79 1d                	jns    80061a <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8005fd:	83 ec 08             	sub    $0x8,%esp
  800600:	53                   	push   %ebx
  800601:	6a 00                	push   $0x0
  800603:	e8 d2 fb ff ff       	call   8001da <sys_page_unmap>
	sys_page_unmap(0, nva);
  800608:	83 c4 08             	add    $0x8,%esp
  80060b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80060e:	6a 00                	push   $0x0
  800610:	e8 c5 fb ff ff       	call   8001da <sys_page_unmap>
	return r;
  800615:	83 c4 10             	add    $0x10,%esp
  800618:	89 f8                	mov    %edi,%eax
}
  80061a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80061d:	5b                   	pop    %ebx
  80061e:	5e                   	pop    %esi
  80061f:	5f                   	pop    %edi
  800620:	5d                   	pop    %ebp
  800621:	c3                   	ret    

00800622 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800622:	55                   	push   %ebp
  800623:	89 e5                	mov    %esp,%ebp
  800625:	53                   	push   %ebx
  800626:	83 ec 14             	sub    $0x14,%esp
  800629:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80062c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80062f:	50                   	push   %eax
  800630:	53                   	push   %ebx
  800631:	e8 86 fd ff ff       	call   8003bc <fd_lookup>
  800636:	83 c4 08             	add    $0x8,%esp
  800639:	89 c2                	mov    %eax,%edx
  80063b:	85 c0                	test   %eax,%eax
  80063d:	78 6d                	js     8006ac <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80063f:	83 ec 08             	sub    $0x8,%esp
  800642:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800645:	50                   	push   %eax
  800646:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800649:	ff 30                	pushl  (%eax)
  80064b:	e8 c2 fd ff ff       	call   800412 <dev_lookup>
  800650:	83 c4 10             	add    $0x10,%esp
  800653:	85 c0                	test   %eax,%eax
  800655:	78 4c                	js     8006a3 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800657:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80065a:	8b 42 08             	mov    0x8(%edx),%eax
  80065d:	83 e0 03             	and    $0x3,%eax
  800660:	83 f8 01             	cmp    $0x1,%eax
  800663:	75 21                	jne    800686 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800665:	a1 04 40 80 00       	mov    0x804004,%eax
  80066a:	8b 40 48             	mov    0x48(%eax),%eax
  80066d:	83 ec 04             	sub    $0x4,%esp
  800670:	53                   	push   %ebx
  800671:	50                   	push   %eax
  800672:	68 99 1e 80 00       	push   $0x801e99
  800677:	e8 61 0a 00 00       	call   8010dd <cprintf>
		return -E_INVAL;
  80067c:	83 c4 10             	add    $0x10,%esp
  80067f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800684:	eb 26                	jmp    8006ac <read+0x8a>
	}
	if (!dev->dev_read)
  800686:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800689:	8b 40 08             	mov    0x8(%eax),%eax
  80068c:	85 c0                	test   %eax,%eax
  80068e:	74 17                	je     8006a7 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800690:	83 ec 04             	sub    $0x4,%esp
  800693:	ff 75 10             	pushl  0x10(%ebp)
  800696:	ff 75 0c             	pushl  0xc(%ebp)
  800699:	52                   	push   %edx
  80069a:	ff d0                	call   *%eax
  80069c:	89 c2                	mov    %eax,%edx
  80069e:	83 c4 10             	add    $0x10,%esp
  8006a1:	eb 09                	jmp    8006ac <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006a3:	89 c2                	mov    %eax,%edx
  8006a5:	eb 05                	jmp    8006ac <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006a7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006ac:	89 d0                	mov    %edx,%eax
  8006ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006b1:	c9                   	leave  
  8006b2:	c3                   	ret    

008006b3 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006b3:	55                   	push   %ebp
  8006b4:	89 e5                	mov    %esp,%ebp
  8006b6:	57                   	push   %edi
  8006b7:	56                   	push   %esi
  8006b8:	53                   	push   %ebx
  8006b9:	83 ec 0c             	sub    $0xc,%esp
  8006bc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006bf:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006c2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006c7:	eb 21                	jmp    8006ea <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006c9:	83 ec 04             	sub    $0x4,%esp
  8006cc:	89 f0                	mov    %esi,%eax
  8006ce:	29 d8                	sub    %ebx,%eax
  8006d0:	50                   	push   %eax
  8006d1:	89 d8                	mov    %ebx,%eax
  8006d3:	03 45 0c             	add    0xc(%ebp),%eax
  8006d6:	50                   	push   %eax
  8006d7:	57                   	push   %edi
  8006d8:	e8 45 ff ff ff       	call   800622 <read>
		if (m < 0)
  8006dd:	83 c4 10             	add    $0x10,%esp
  8006e0:	85 c0                	test   %eax,%eax
  8006e2:	78 10                	js     8006f4 <readn+0x41>
			return m;
		if (m == 0)
  8006e4:	85 c0                	test   %eax,%eax
  8006e6:	74 0a                	je     8006f2 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006e8:	01 c3                	add    %eax,%ebx
  8006ea:	39 f3                	cmp    %esi,%ebx
  8006ec:	72 db                	jb     8006c9 <readn+0x16>
  8006ee:	89 d8                	mov    %ebx,%eax
  8006f0:	eb 02                	jmp    8006f4 <readn+0x41>
  8006f2:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8006f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f7:	5b                   	pop    %ebx
  8006f8:	5e                   	pop    %esi
  8006f9:	5f                   	pop    %edi
  8006fa:	5d                   	pop    %ebp
  8006fb:	c3                   	ret    

008006fc <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8006fc:	55                   	push   %ebp
  8006fd:	89 e5                	mov    %esp,%ebp
  8006ff:	53                   	push   %ebx
  800700:	83 ec 14             	sub    $0x14,%esp
  800703:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800706:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800709:	50                   	push   %eax
  80070a:	53                   	push   %ebx
  80070b:	e8 ac fc ff ff       	call   8003bc <fd_lookup>
  800710:	83 c4 08             	add    $0x8,%esp
  800713:	89 c2                	mov    %eax,%edx
  800715:	85 c0                	test   %eax,%eax
  800717:	78 68                	js     800781 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800719:	83 ec 08             	sub    $0x8,%esp
  80071c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80071f:	50                   	push   %eax
  800720:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800723:	ff 30                	pushl  (%eax)
  800725:	e8 e8 fc ff ff       	call   800412 <dev_lookup>
  80072a:	83 c4 10             	add    $0x10,%esp
  80072d:	85 c0                	test   %eax,%eax
  80072f:	78 47                	js     800778 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800731:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800734:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800738:	75 21                	jne    80075b <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80073a:	a1 04 40 80 00       	mov    0x804004,%eax
  80073f:	8b 40 48             	mov    0x48(%eax),%eax
  800742:	83 ec 04             	sub    $0x4,%esp
  800745:	53                   	push   %ebx
  800746:	50                   	push   %eax
  800747:	68 b5 1e 80 00       	push   $0x801eb5
  80074c:	e8 8c 09 00 00       	call   8010dd <cprintf>
		return -E_INVAL;
  800751:	83 c4 10             	add    $0x10,%esp
  800754:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800759:	eb 26                	jmp    800781 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80075b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80075e:	8b 52 0c             	mov    0xc(%edx),%edx
  800761:	85 d2                	test   %edx,%edx
  800763:	74 17                	je     80077c <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800765:	83 ec 04             	sub    $0x4,%esp
  800768:	ff 75 10             	pushl  0x10(%ebp)
  80076b:	ff 75 0c             	pushl  0xc(%ebp)
  80076e:	50                   	push   %eax
  80076f:	ff d2                	call   *%edx
  800771:	89 c2                	mov    %eax,%edx
  800773:	83 c4 10             	add    $0x10,%esp
  800776:	eb 09                	jmp    800781 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800778:	89 c2                	mov    %eax,%edx
  80077a:	eb 05                	jmp    800781 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80077c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800781:	89 d0                	mov    %edx,%eax
  800783:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800786:	c9                   	leave  
  800787:	c3                   	ret    

00800788 <seek>:

int
seek(int fdnum, off_t offset)
{
  800788:	55                   	push   %ebp
  800789:	89 e5                	mov    %esp,%ebp
  80078b:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80078e:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800791:	50                   	push   %eax
  800792:	ff 75 08             	pushl  0x8(%ebp)
  800795:	e8 22 fc ff ff       	call   8003bc <fd_lookup>
  80079a:	83 c4 08             	add    $0x8,%esp
  80079d:	85 c0                	test   %eax,%eax
  80079f:	78 0e                	js     8007af <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007a7:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007aa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007af:	c9                   	leave  
  8007b0:	c3                   	ret    

008007b1 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007b1:	55                   	push   %ebp
  8007b2:	89 e5                	mov    %esp,%ebp
  8007b4:	53                   	push   %ebx
  8007b5:	83 ec 14             	sub    $0x14,%esp
  8007b8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007bb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007be:	50                   	push   %eax
  8007bf:	53                   	push   %ebx
  8007c0:	e8 f7 fb ff ff       	call   8003bc <fd_lookup>
  8007c5:	83 c4 08             	add    $0x8,%esp
  8007c8:	89 c2                	mov    %eax,%edx
  8007ca:	85 c0                	test   %eax,%eax
  8007cc:	78 65                	js     800833 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007ce:	83 ec 08             	sub    $0x8,%esp
  8007d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007d4:	50                   	push   %eax
  8007d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007d8:	ff 30                	pushl  (%eax)
  8007da:	e8 33 fc ff ff       	call   800412 <dev_lookup>
  8007df:	83 c4 10             	add    $0x10,%esp
  8007e2:	85 c0                	test   %eax,%eax
  8007e4:	78 44                	js     80082a <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007e9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007ed:	75 21                	jne    800810 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8007ef:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8007f4:	8b 40 48             	mov    0x48(%eax),%eax
  8007f7:	83 ec 04             	sub    $0x4,%esp
  8007fa:	53                   	push   %ebx
  8007fb:	50                   	push   %eax
  8007fc:	68 78 1e 80 00       	push   $0x801e78
  800801:	e8 d7 08 00 00       	call   8010dd <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800806:	83 c4 10             	add    $0x10,%esp
  800809:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80080e:	eb 23                	jmp    800833 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800810:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800813:	8b 52 18             	mov    0x18(%edx),%edx
  800816:	85 d2                	test   %edx,%edx
  800818:	74 14                	je     80082e <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80081a:	83 ec 08             	sub    $0x8,%esp
  80081d:	ff 75 0c             	pushl  0xc(%ebp)
  800820:	50                   	push   %eax
  800821:	ff d2                	call   *%edx
  800823:	89 c2                	mov    %eax,%edx
  800825:	83 c4 10             	add    $0x10,%esp
  800828:	eb 09                	jmp    800833 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80082a:	89 c2                	mov    %eax,%edx
  80082c:	eb 05                	jmp    800833 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80082e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800833:	89 d0                	mov    %edx,%eax
  800835:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800838:	c9                   	leave  
  800839:	c3                   	ret    

0080083a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80083a:	55                   	push   %ebp
  80083b:	89 e5                	mov    %esp,%ebp
  80083d:	53                   	push   %ebx
  80083e:	83 ec 14             	sub    $0x14,%esp
  800841:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800844:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800847:	50                   	push   %eax
  800848:	ff 75 08             	pushl  0x8(%ebp)
  80084b:	e8 6c fb ff ff       	call   8003bc <fd_lookup>
  800850:	83 c4 08             	add    $0x8,%esp
  800853:	89 c2                	mov    %eax,%edx
  800855:	85 c0                	test   %eax,%eax
  800857:	78 58                	js     8008b1 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800859:	83 ec 08             	sub    $0x8,%esp
  80085c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80085f:	50                   	push   %eax
  800860:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800863:	ff 30                	pushl  (%eax)
  800865:	e8 a8 fb ff ff       	call   800412 <dev_lookup>
  80086a:	83 c4 10             	add    $0x10,%esp
  80086d:	85 c0                	test   %eax,%eax
  80086f:	78 37                	js     8008a8 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800871:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800874:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800878:	74 32                	je     8008ac <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80087a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80087d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800884:	00 00 00 
	stat->st_isdir = 0;
  800887:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80088e:	00 00 00 
	stat->st_dev = dev;
  800891:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800897:	83 ec 08             	sub    $0x8,%esp
  80089a:	53                   	push   %ebx
  80089b:	ff 75 f0             	pushl  -0x10(%ebp)
  80089e:	ff 50 14             	call   *0x14(%eax)
  8008a1:	89 c2                	mov    %eax,%edx
  8008a3:	83 c4 10             	add    $0x10,%esp
  8008a6:	eb 09                	jmp    8008b1 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008a8:	89 c2                	mov    %eax,%edx
  8008aa:	eb 05                	jmp    8008b1 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008ac:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008b1:	89 d0                	mov    %edx,%eax
  8008b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008b6:	c9                   	leave  
  8008b7:	c3                   	ret    

008008b8 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008b8:	55                   	push   %ebp
  8008b9:	89 e5                	mov    %esp,%ebp
  8008bb:	56                   	push   %esi
  8008bc:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008bd:	83 ec 08             	sub    $0x8,%esp
  8008c0:	6a 00                	push   $0x0
  8008c2:	ff 75 08             	pushl  0x8(%ebp)
  8008c5:	e8 b7 01 00 00       	call   800a81 <open>
  8008ca:	89 c3                	mov    %eax,%ebx
  8008cc:	83 c4 10             	add    $0x10,%esp
  8008cf:	85 c0                	test   %eax,%eax
  8008d1:	78 1b                	js     8008ee <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008d3:	83 ec 08             	sub    $0x8,%esp
  8008d6:	ff 75 0c             	pushl  0xc(%ebp)
  8008d9:	50                   	push   %eax
  8008da:	e8 5b ff ff ff       	call   80083a <fstat>
  8008df:	89 c6                	mov    %eax,%esi
	close(fd);
  8008e1:	89 1c 24             	mov    %ebx,(%esp)
  8008e4:	e8 fd fb ff ff       	call   8004e6 <close>
	return r;
  8008e9:	83 c4 10             	add    $0x10,%esp
  8008ec:	89 f0                	mov    %esi,%eax
}
  8008ee:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008f1:	5b                   	pop    %ebx
  8008f2:	5e                   	pop    %esi
  8008f3:	5d                   	pop    %ebp
  8008f4:	c3                   	ret    

008008f5 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008f5:	55                   	push   %ebp
  8008f6:	89 e5                	mov    %esp,%ebp
  8008f8:	56                   	push   %esi
  8008f9:	53                   	push   %ebx
  8008fa:	89 c6                	mov    %eax,%esi
  8008fc:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8008fe:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800905:	75 12                	jne    800919 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800907:	83 ec 0c             	sub    $0xc,%esp
  80090a:	6a 01                	push   $0x1
  80090c:	e8 08 12 00 00       	call   801b19 <ipc_find_env>
  800911:	a3 00 40 80 00       	mov    %eax,0x804000
  800916:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800919:	6a 07                	push   $0x7
  80091b:	68 00 50 80 00       	push   $0x805000
  800920:	56                   	push   %esi
  800921:	ff 35 00 40 80 00    	pushl  0x804000
  800927:	e8 99 11 00 00       	call   801ac5 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80092c:	83 c4 0c             	add    $0xc,%esp
  80092f:	6a 00                	push   $0x0
  800931:	53                   	push   %ebx
  800932:	6a 00                	push   $0x0
  800934:	e8 17 11 00 00       	call   801a50 <ipc_recv>
}
  800939:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80093c:	5b                   	pop    %ebx
  80093d:	5e                   	pop    %esi
  80093e:	5d                   	pop    %ebp
  80093f:	c3                   	ret    

00800940 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800940:	55                   	push   %ebp
  800941:	89 e5                	mov    %esp,%ebp
  800943:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800946:	8b 45 08             	mov    0x8(%ebp),%eax
  800949:	8b 40 0c             	mov    0xc(%eax),%eax
  80094c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800951:	8b 45 0c             	mov    0xc(%ebp),%eax
  800954:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800959:	ba 00 00 00 00       	mov    $0x0,%edx
  80095e:	b8 02 00 00 00       	mov    $0x2,%eax
  800963:	e8 8d ff ff ff       	call   8008f5 <fsipc>
}
  800968:	c9                   	leave  
  800969:	c3                   	ret    

0080096a <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80096a:	55                   	push   %ebp
  80096b:	89 e5                	mov    %esp,%ebp
  80096d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800970:	8b 45 08             	mov    0x8(%ebp),%eax
  800973:	8b 40 0c             	mov    0xc(%eax),%eax
  800976:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80097b:	ba 00 00 00 00       	mov    $0x0,%edx
  800980:	b8 06 00 00 00       	mov    $0x6,%eax
  800985:	e8 6b ff ff ff       	call   8008f5 <fsipc>
}
  80098a:	c9                   	leave  
  80098b:	c3                   	ret    

0080098c <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80098c:	55                   	push   %ebp
  80098d:	89 e5                	mov    %esp,%ebp
  80098f:	53                   	push   %ebx
  800990:	83 ec 04             	sub    $0x4,%esp
  800993:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800996:	8b 45 08             	mov    0x8(%ebp),%eax
  800999:	8b 40 0c             	mov    0xc(%eax),%eax
  80099c:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8009a6:	b8 05 00 00 00       	mov    $0x5,%eax
  8009ab:	e8 45 ff ff ff       	call   8008f5 <fsipc>
  8009b0:	85 c0                	test   %eax,%eax
  8009b2:	78 2c                	js     8009e0 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009b4:	83 ec 08             	sub    $0x8,%esp
  8009b7:	68 00 50 80 00       	push   $0x805000
  8009bc:	53                   	push   %ebx
  8009bd:	e8 47 0d 00 00       	call   801709 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009c2:	a1 80 50 80 00       	mov    0x805080,%eax
  8009c7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009cd:	a1 84 50 80 00       	mov    0x805084,%eax
  8009d2:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009d8:	83 c4 10             	add    $0x10,%esp
  8009db:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009e3:	c9                   	leave  
  8009e4:	c3                   	ret    

008009e5 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8009e5:	55                   	push   %ebp
  8009e6:	89 e5                	mov    %esp,%ebp
  8009e8:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  8009eb:	68 e4 1e 80 00       	push   $0x801ee4
  8009f0:	68 90 00 00 00       	push   $0x90
  8009f5:	68 02 1f 80 00       	push   $0x801f02
  8009fa:	e8 05 06 00 00       	call   801004 <_panic>

008009ff <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8009ff:	55                   	push   %ebp
  800a00:	89 e5                	mov    %esp,%ebp
  800a02:	56                   	push   %esi
  800a03:	53                   	push   %ebx
  800a04:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a07:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0a:	8b 40 0c             	mov    0xc(%eax),%eax
  800a0d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a12:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a18:	ba 00 00 00 00       	mov    $0x0,%edx
  800a1d:	b8 03 00 00 00       	mov    $0x3,%eax
  800a22:	e8 ce fe ff ff       	call   8008f5 <fsipc>
  800a27:	89 c3                	mov    %eax,%ebx
  800a29:	85 c0                	test   %eax,%eax
  800a2b:	78 4b                	js     800a78 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a2d:	39 c6                	cmp    %eax,%esi
  800a2f:	73 16                	jae    800a47 <devfile_read+0x48>
  800a31:	68 0d 1f 80 00       	push   $0x801f0d
  800a36:	68 14 1f 80 00       	push   $0x801f14
  800a3b:	6a 7c                	push   $0x7c
  800a3d:	68 02 1f 80 00       	push   $0x801f02
  800a42:	e8 bd 05 00 00       	call   801004 <_panic>
	assert(r <= PGSIZE);
  800a47:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a4c:	7e 16                	jle    800a64 <devfile_read+0x65>
  800a4e:	68 29 1f 80 00       	push   $0x801f29
  800a53:	68 14 1f 80 00       	push   $0x801f14
  800a58:	6a 7d                	push   $0x7d
  800a5a:	68 02 1f 80 00       	push   $0x801f02
  800a5f:	e8 a0 05 00 00       	call   801004 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a64:	83 ec 04             	sub    $0x4,%esp
  800a67:	50                   	push   %eax
  800a68:	68 00 50 80 00       	push   $0x805000
  800a6d:	ff 75 0c             	pushl  0xc(%ebp)
  800a70:	e8 26 0e 00 00       	call   80189b <memmove>
	return r;
  800a75:	83 c4 10             	add    $0x10,%esp
}
  800a78:	89 d8                	mov    %ebx,%eax
  800a7a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a7d:	5b                   	pop    %ebx
  800a7e:	5e                   	pop    %esi
  800a7f:	5d                   	pop    %ebp
  800a80:	c3                   	ret    

00800a81 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800a81:	55                   	push   %ebp
  800a82:	89 e5                	mov    %esp,%ebp
  800a84:	53                   	push   %ebx
  800a85:	83 ec 20             	sub    $0x20,%esp
  800a88:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800a8b:	53                   	push   %ebx
  800a8c:	e8 3f 0c 00 00       	call   8016d0 <strlen>
  800a91:	83 c4 10             	add    $0x10,%esp
  800a94:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800a99:	7f 67                	jg     800b02 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800a9b:	83 ec 0c             	sub    $0xc,%esp
  800a9e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800aa1:	50                   	push   %eax
  800aa2:	e8 c6 f8 ff ff       	call   80036d <fd_alloc>
  800aa7:	83 c4 10             	add    $0x10,%esp
		return r;
  800aaa:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800aac:	85 c0                	test   %eax,%eax
  800aae:	78 57                	js     800b07 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800ab0:	83 ec 08             	sub    $0x8,%esp
  800ab3:	53                   	push   %ebx
  800ab4:	68 00 50 80 00       	push   $0x805000
  800ab9:	e8 4b 0c 00 00       	call   801709 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800abe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac1:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800ac6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ac9:	b8 01 00 00 00       	mov    $0x1,%eax
  800ace:	e8 22 fe ff ff       	call   8008f5 <fsipc>
  800ad3:	89 c3                	mov    %eax,%ebx
  800ad5:	83 c4 10             	add    $0x10,%esp
  800ad8:	85 c0                	test   %eax,%eax
  800ada:	79 14                	jns    800af0 <open+0x6f>
		fd_close(fd, 0);
  800adc:	83 ec 08             	sub    $0x8,%esp
  800adf:	6a 00                	push   $0x0
  800ae1:	ff 75 f4             	pushl  -0xc(%ebp)
  800ae4:	e8 7c f9 ff ff       	call   800465 <fd_close>
		return r;
  800ae9:	83 c4 10             	add    $0x10,%esp
  800aec:	89 da                	mov    %ebx,%edx
  800aee:	eb 17                	jmp    800b07 <open+0x86>
	}

	return fd2num(fd);
  800af0:	83 ec 0c             	sub    $0xc,%esp
  800af3:	ff 75 f4             	pushl  -0xc(%ebp)
  800af6:	e8 4b f8 ff ff       	call   800346 <fd2num>
  800afb:	89 c2                	mov    %eax,%edx
  800afd:	83 c4 10             	add    $0x10,%esp
  800b00:	eb 05                	jmp    800b07 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b02:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b07:	89 d0                	mov    %edx,%eax
  800b09:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b0c:	c9                   	leave  
  800b0d:	c3                   	ret    

00800b0e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b0e:	55                   	push   %ebp
  800b0f:	89 e5                	mov    %esp,%ebp
  800b11:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b14:	ba 00 00 00 00       	mov    $0x0,%edx
  800b19:	b8 08 00 00 00       	mov    $0x8,%eax
  800b1e:	e8 d2 fd ff ff       	call   8008f5 <fsipc>
}
  800b23:	c9                   	leave  
  800b24:	c3                   	ret    

00800b25 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b25:	55                   	push   %ebp
  800b26:	89 e5                	mov    %esp,%ebp
  800b28:	56                   	push   %esi
  800b29:	53                   	push   %ebx
  800b2a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b2d:	83 ec 0c             	sub    $0xc,%esp
  800b30:	ff 75 08             	pushl  0x8(%ebp)
  800b33:	e8 1e f8 ff ff       	call   800356 <fd2data>
  800b38:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b3a:	83 c4 08             	add    $0x8,%esp
  800b3d:	68 35 1f 80 00       	push   $0x801f35
  800b42:	53                   	push   %ebx
  800b43:	e8 c1 0b 00 00       	call   801709 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b48:	8b 46 04             	mov    0x4(%esi),%eax
  800b4b:	2b 06                	sub    (%esi),%eax
  800b4d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b53:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b5a:	00 00 00 
	stat->st_dev = &devpipe;
  800b5d:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800b64:	30 80 00 
	return 0;
}
  800b67:	b8 00 00 00 00       	mov    $0x0,%eax
  800b6c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b6f:	5b                   	pop    %ebx
  800b70:	5e                   	pop    %esi
  800b71:	5d                   	pop    %ebp
  800b72:	c3                   	ret    

00800b73 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800b73:	55                   	push   %ebp
  800b74:	89 e5                	mov    %esp,%ebp
  800b76:	53                   	push   %ebx
  800b77:	83 ec 0c             	sub    $0xc,%esp
  800b7a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800b7d:	53                   	push   %ebx
  800b7e:	6a 00                	push   $0x0
  800b80:	e8 55 f6 ff ff       	call   8001da <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800b85:	89 1c 24             	mov    %ebx,(%esp)
  800b88:	e8 c9 f7 ff ff       	call   800356 <fd2data>
  800b8d:	83 c4 08             	add    $0x8,%esp
  800b90:	50                   	push   %eax
  800b91:	6a 00                	push   $0x0
  800b93:	e8 42 f6 ff ff       	call   8001da <sys_page_unmap>
}
  800b98:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b9b:	c9                   	leave  
  800b9c:	c3                   	ret    

00800b9d <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800b9d:	55                   	push   %ebp
  800b9e:	89 e5                	mov    %esp,%ebp
  800ba0:	57                   	push   %edi
  800ba1:	56                   	push   %esi
  800ba2:	53                   	push   %ebx
  800ba3:	83 ec 1c             	sub    $0x1c,%esp
  800ba6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800ba9:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800bab:	a1 04 40 80 00       	mov    0x804004,%eax
  800bb0:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800bb3:	83 ec 0c             	sub    $0xc,%esp
  800bb6:	ff 75 e0             	pushl  -0x20(%ebp)
  800bb9:	e8 94 0f 00 00       	call   801b52 <pageref>
  800bbe:	89 c3                	mov    %eax,%ebx
  800bc0:	89 3c 24             	mov    %edi,(%esp)
  800bc3:	e8 8a 0f 00 00       	call   801b52 <pageref>
  800bc8:	83 c4 10             	add    $0x10,%esp
  800bcb:	39 c3                	cmp    %eax,%ebx
  800bcd:	0f 94 c1             	sete   %cl
  800bd0:	0f b6 c9             	movzbl %cl,%ecx
  800bd3:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800bd6:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800bdc:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800bdf:	39 ce                	cmp    %ecx,%esi
  800be1:	74 1b                	je     800bfe <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800be3:	39 c3                	cmp    %eax,%ebx
  800be5:	75 c4                	jne    800bab <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800be7:	8b 42 58             	mov    0x58(%edx),%eax
  800bea:	ff 75 e4             	pushl  -0x1c(%ebp)
  800bed:	50                   	push   %eax
  800bee:	56                   	push   %esi
  800bef:	68 3c 1f 80 00       	push   $0x801f3c
  800bf4:	e8 e4 04 00 00       	call   8010dd <cprintf>
  800bf9:	83 c4 10             	add    $0x10,%esp
  800bfc:	eb ad                	jmp    800bab <_pipeisclosed+0xe>
	}
}
  800bfe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c01:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c04:	5b                   	pop    %ebx
  800c05:	5e                   	pop    %esi
  800c06:	5f                   	pop    %edi
  800c07:	5d                   	pop    %ebp
  800c08:	c3                   	ret    

00800c09 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c09:	55                   	push   %ebp
  800c0a:	89 e5                	mov    %esp,%ebp
  800c0c:	57                   	push   %edi
  800c0d:	56                   	push   %esi
  800c0e:	53                   	push   %ebx
  800c0f:	83 ec 28             	sub    $0x28,%esp
  800c12:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c15:	56                   	push   %esi
  800c16:	e8 3b f7 ff ff       	call   800356 <fd2data>
  800c1b:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c1d:	83 c4 10             	add    $0x10,%esp
  800c20:	bf 00 00 00 00       	mov    $0x0,%edi
  800c25:	eb 4b                	jmp    800c72 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c27:	89 da                	mov    %ebx,%edx
  800c29:	89 f0                	mov    %esi,%eax
  800c2b:	e8 6d ff ff ff       	call   800b9d <_pipeisclosed>
  800c30:	85 c0                	test   %eax,%eax
  800c32:	75 48                	jne    800c7c <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c34:	e8 fd f4 ff ff       	call   800136 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c39:	8b 43 04             	mov    0x4(%ebx),%eax
  800c3c:	8b 0b                	mov    (%ebx),%ecx
  800c3e:	8d 51 20             	lea    0x20(%ecx),%edx
  800c41:	39 d0                	cmp    %edx,%eax
  800c43:	73 e2                	jae    800c27 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c48:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c4c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c4f:	89 c2                	mov    %eax,%edx
  800c51:	c1 fa 1f             	sar    $0x1f,%edx
  800c54:	89 d1                	mov    %edx,%ecx
  800c56:	c1 e9 1b             	shr    $0x1b,%ecx
  800c59:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c5c:	83 e2 1f             	and    $0x1f,%edx
  800c5f:	29 ca                	sub    %ecx,%edx
  800c61:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800c65:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800c69:	83 c0 01             	add    $0x1,%eax
  800c6c:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c6f:	83 c7 01             	add    $0x1,%edi
  800c72:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800c75:	75 c2                	jne    800c39 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800c77:	8b 45 10             	mov    0x10(%ebp),%eax
  800c7a:	eb 05                	jmp    800c81 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800c7c:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800c81:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c84:	5b                   	pop    %ebx
  800c85:	5e                   	pop    %esi
  800c86:	5f                   	pop    %edi
  800c87:	5d                   	pop    %ebp
  800c88:	c3                   	ret    

00800c89 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800c89:	55                   	push   %ebp
  800c8a:	89 e5                	mov    %esp,%ebp
  800c8c:	57                   	push   %edi
  800c8d:	56                   	push   %esi
  800c8e:	53                   	push   %ebx
  800c8f:	83 ec 18             	sub    $0x18,%esp
  800c92:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800c95:	57                   	push   %edi
  800c96:	e8 bb f6 ff ff       	call   800356 <fd2data>
  800c9b:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c9d:	83 c4 10             	add    $0x10,%esp
  800ca0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca5:	eb 3d                	jmp    800ce4 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800ca7:	85 db                	test   %ebx,%ebx
  800ca9:	74 04                	je     800caf <devpipe_read+0x26>
				return i;
  800cab:	89 d8                	mov    %ebx,%eax
  800cad:	eb 44                	jmp    800cf3 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800caf:	89 f2                	mov    %esi,%edx
  800cb1:	89 f8                	mov    %edi,%eax
  800cb3:	e8 e5 fe ff ff       	call   800b9d <_pipeisclosed>
  800cb8:	85 c0                	test   %eax,%eax
  800cba:	75 32                	jne    800cee <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800cbc:	e8 75 f4 ff ff       	call   800136 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800cc1:	8b 06                	mov    (%esi),%eax
  800cc3:	3b 46 04             	cmp    0x4(%esi),%eax
  800cc6:	74 df                	je     800ca7 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800cc8:	99                   	cltd   
  800cc9:	c1 ea 1b             	shr    $0x1b,%edx
  800ccc:	01 d0                	add    %edx,%eax
  800cce:	83 e0 1f             	and    $0x1f,%eax
  800cd1:	29 d0                	sub    %edx,%eax
  800cd3:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800cd8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdb:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800cde:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ce1:	83 c3 01             	add    $0x1,%ebx
  800ce4:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800ce7:	75 d8                	jne    800cc1 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800ce9:	8b 45 10             	mov    0x10(%ebp),%eax
  800cec:	eb 05                	jmp    800cf3 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cee:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800cf3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf6:	5b                   	pop    %ebx
  800cf7:	5e                   	pop    %esi
  800cf8:	5f                   	pop    %edi
  800cf9:	5d                   	pop    %ebp
  800cfa:	c3                   	ret    

00800cfb <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800cfb:	55                   	push   %ebp
  800cfc:	89 e5                	mov    %esp,%ebp
  800cfe:	56                   	push   %esi
  800cff:	53                   	push   %ebx
  800d00:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d03:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d06:	50                   	push   %eax
  800d07:	e8 61 f6 ff ff       	call   80036d <fd_alloc>
  800d0c:	83 c4 10             	add    $0x10,%esp
  800d0f:	89 c2                	mov    %eax,%edx
  800d11:	85 c0                	test   %eax,%eax
  800d13:	0f 88 2c 01 00 00    	js     800e45 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d19:	83 ec 04             	sub    $0x4,%esp
  800d1c:	68 07 04 00 00       	push   $0x407
  800d21:	ff 75 f4             	pushl  -0xc(%ebp)
  800d24:	6a 00                	push   $0x0
  800d26:	e8 2a f4 ff ff       	call   800155 <sys_page_alloc>
  800d2b:	83 c4 10             	add    $0x10,%esp
  800d2e:	89 c2                	mov    %eax,%edx
  800d30:	85 c0                	test   %eax,%eax
  800d32:	0f 88 0d 01 00 00    	js     800e45 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d38:	83 ec 0c             	sub    $0xc,%esp
  800d3b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d3e:	50                   	push   %eax
  800d3f:	e8 29 f6 ff ff       	call   80036d <fd_alloc>
  800d44:	89 c3                	mov    %eax,%ebx
  800d46:	83 c4 10             	add    $0x10,%esp
  800d49:	85 c0                	test   %eax,%eax
  800d4b:	0f 88 e2 00 00 00    	js     800e33 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d51:	83 ec 04             	sub    $0x4,%esp
  800d54:	68 07 04 00 00       	push   $0x407
  800d59:	ff 75 f0             	pushl  -0x10(%ebp)
  800d5c:	6a 00                	push   $0x0
  800d5e:	e8 f2 f3 ff ff       	call   800155 <sys_page_alloc>
  800d63:	89 c3                	mov    %eax,%ebx
  800d65:	83 c4 10             	add    $0x10,%esp
  800d68:	85 c0                	test   %eax,%eax
  800d6a:	0f 88 c3 00 00 00    	js     800e33 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800d70:	83 ec 0c             	sub    $0xc,%esp
  800d73:	ff 75 f4             	pushl  -0xc(%ebp)
  800d76:	e8 db f5 ff ff       	call   800356 <fd2data>
  800d7b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d7d:	83 c4 0c             	add    $0xc,%esp
  800d80:	68 07 04 00 00       	push   $0x407
  800d85:	50                   	push   %eax
  800d86:	6a 00                	push   $0x0
  800d88:	e8 c8 f3 ff ff       	call   800155 <sys_page_alloc>
  800d8d:	89 c3                	mov    %eax,%ebx
  800d8f:	83 c4 10             	add    $0x10,%esp
  800d92:	85 c0                	test   %eax,%eax
  800d94:	0f 88 89 00 00 00    	js     800e23 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d9a:	83 ec 0c             	sub    $0xc,%esp
  800d9d:	ff 75 f0             	pushl  -0x10(%ebp)
  800da0:	e8 b1 f5 ff ff       	call   800356 <fd2data>
  800da5:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800dac:	50                   	push   %eax
  800dad:	6a 00                	push   $0x0
  800daf:	56                   	push   %esi
  800db0:	6a 00                	push   $0x0
  800db2:	e8 e1 f3 ff ff       	call   800198 <sys_page_map>
  800db7:	89 c3                	mov    %eax,%ebx
  800db9:	83 c4 20             	add    $0x20,%esp
  800dbc:	85 c0                	test   %eax,%eax
  800dbe:	78 55                	js     800e15 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800dc0:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800dc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dc9:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800dcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dce:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800dd5:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800ddb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800dde:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800de0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800de3:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800dea:	83 ec 0c             	sub    $0xc,%esp
  800ded:	ff 75 f4             	pushl  -0xc(%ebp)
  800df0:	e8 51 f5 ff ff       	call   800346 <fd2num>
  800df5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800df8:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800dfa:	83 c4 04             	add    $0x4,%esp
  800dfd:	ff 75 f0             	pushl  -0x10(%ebp)
  800e00:	e8 41 f5 ff ff       	call   800346 <fd2num>
  800e05:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e08:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e0b:	83 c4 10             	add    $0x10,%esp
  800e0e:	ba 00 00 00 00       	mov    $0x0,%edx
  800e13:	eb 30                	jmp    800e45 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e15:	83 ec 08             	sub    $0x8,%esp
  800e18:	56                   	push   %esi
  800e19:	6a 00                	push   $0x0
  800e1b:	e8 ba f3 ff ff       	call   8001da <sys_page_unmap>
  800e20:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e23:	83 ec 08             	sub    $0x8,%esp
  800e26:	ff 75 f0             	pushl  -0x10(%ebp)
  800e29:	6a 00                	push   $0x0
  800e2b:	e8 aa f3 ff ff       	call   8001da <sys_page_unmap>
  800e30:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e33:	83 ec 08             	sub    $0x8,%esp
  800e36:	ff 75 f4             	pushl  -0xc(%ebp)
  800e39:	6a 00                	push   $0x0
  800e3b:	e8 9a f3 ff ff       	call   8001da <sys_page_unmap>
  800e40:	83 c4 10             	add    $0x10,%esp
  800e43:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800e45:	89 d0                	mov    %edx,%eax
  800e47:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e4a:	5b                   	pop    %ebx
  800e4b:	5e                   	pop    %esi
  800e4c:	5d                   	pop    %ebp
  800e4d:	c3                   	ret    

00800e4e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e4e:	55                   	push   %ebp
  800e4f:	89 e5                	mov    %esp,%ebp
  800e51:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e54:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e57:	50                   	push   %eax
  800e58:	ff 75 08             	pushl  0x8(%ebp)
  800e5b:	e8 5c f5 ff ff       	call   8003bc <fd_lookup>
  800e60:	83 c4 10             	add    $0x10,%esp
  800e63:	85 c0                	test   %eax,%eax
  800e65:	78 18                	js     800e7f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800e67:	83 ec 0c             	sub    $0xc,%esp
  800e6a:	ff 75 f4             	pushl  -0xc(%ebp)
  800e6d:	e8 e4 f4 ff ff       	call   800356 <fd2data>
	return _pipeisclosed(fd, p);
  800e72:	89 c2                	mov    %eax,%edx
  800e74:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e77:	e8 21 fd ff ff       	call   800b9d <_pipeisclosed>
  800e7c:	83 c4 10             	add    $0x10,%esp
}
  800e7f:	c9                   	leave  
  800e80:	c3                   	ret    

00800e81 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800e81:	55                   	push   %ebp
  800e82:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800e84:	b8 00 00 00 00       	mov    $0x0,%eax
  800e89:	5d                   	pop    %ebp
  800e8a:	c3                   	ret    

00800e8b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800e8b:	55                   	push   %ebp
  800e8c:	89 e5                	mov    %esp,%ebp
  800e8e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800e91:	68 54 1f 80 00       	push   $0x801f54
  800e96:	ff 75 0c             	pushl  0xc(%ebp)
  800e99:	e8 6b 08 00 00       	call   801709 <strcpy>
	return 0;
}
  800e9e:	b8 00 00 00 00       	mov    $0x0,%eax
  800ea3:	c9                   	leave  
  800ea4:	c3                   	ret    

00800ea5 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800ea5:	55                   	push   %ebp
  800ea6:	89 e5                	mov    %esp,%ebp
  800ea8:	57                   	push   %edi
  800ea9:	56                   	push   %esi
  800eaa:	53                   	push   %ebx
  800eab:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800eb1:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800eb6:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ebc:	eb 2d                	jmp    800eeb <devcons_write+0x46>
		m = n - tot;
  800ebe:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ec1:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800ec3:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800ec6:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800ecb:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800ece:	83 ec 04             	sub    $0x4,%esp
  800ed1:	53                   	push   %ebx
  800ed2:	03 45 0c             	add    0xc(%ebp),%eax
  800ed5:	50                   	push   %eax
  800ed6:	57                   	push   %edi
  800ed7:	e8 bf 09 00 00       	call   80189b <memmove>
		sys_cputs(buf, m);
  800edc:	83 c4 08             	add    $0x8,%esp
  800edf:	53                   	push   %ebx
  800ee0:	57                   	push   %edi
  800ee1:	e8 b3 f1 ff ff       	call   800099 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ee6:	01 de                	add    %ebx,%esi
  800ee8:	83 c4 10             	add    $0x10,%esp
  800eeb:	89 f0                	mov    %esi,%eax
  800eed:	3b 75 10             	cmp    0x10(%ebp),%esi
  800ef0:	72 cc                	jb     800ebe <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800ef2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ef5:	5b                   	pop    %ebx
  800ef6:	5e                   	pop    %esi
  800ef7:	5f                   	pop    %edi
  800ef8:	5d                   	pop    %ebp
  800ef9:	c3                   	ret    

00800efa <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800efa:	55                   	push   %ebp
  800efb:	89 e5                	mov    %esp,%ebp
  800efd:	83 ec 08             	sub    $0x8,%esp
  800f00:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f05:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f09:	74 2a                	je     800f35 <devcons_read+0x3b>
  800f0b:	eb 05                	jmp    800f12 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f0d:	e8 24 f2 ff ff       	call   800136 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f12:	e8 a0 f1 ff ff       	call   8000b7 <sys_cgetc>
  800f17:	85 c0                	test   %eax,%eax
  800f19:	74 f2                	je     800f0d <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f1b:	85 c0                	test   %eax,%eax
  800f1d:	78 16                	js     800f35 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f1f:	83 f8 04             	cmp    $0x4,%eax
  800f22:	74 0c                	je     800f30 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f24:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f27:	88 02                	mov    %al,(%edx)
	return 1;
  800f29:	b8 01 00 00 00       	mov    $0x1,%eax
  800f2e:	eb 05                	jmp    800f35 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f30:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f35:	c9                   	leave  
  800f36:	c3                   	ret    

00800f37 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f37:	55                   	push   %ebp
  800f38:	89 e5                	mov    %esp,%ebp
  800f3a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f3d:	8b 45 08             	mov    0x8(%ebp),%eax
  800f40:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f43:	6a 01                	push   $0x1
  800f45:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f48:	50                   	push   %eax
  800f49:	e8 4b f1 ff ff       	call   800099 <sys_cputs>
}
  800f4e:	83 c4 10             	add    $0x10,%esp
  800f51:	c9                   	leave  
  800f52:	c3                   	ret    

00800f53 <getchar>:

int
getchar(void)
{
  800f53:	55                   	push   %ebp
  800f54:	89 e5                	mov    %esp,%ebp
  800f56:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f59:	6a 01                	push   $0x1
  800f5b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f5e:	50                   	push   %eax
  800f5f:	6a 00                	push   $0x0
  800f61:	e8 bc f6 ff ff       	call   800622 <read>
	if (r < 0)
  800f66:	83 c4 10             	add    $0x10,%esp
  800f69:	85 c0                	test   %eax,%eax
  800f6b:	78 0f                	js     800f7c <getchar+0x29>
		return r;
	if (r < 1)
  800f6d:	85 c0                	test   %eax,%eax
  800f6f:	7e 06                	jle    800f77 <getchar+0x24>
		return -E_EOF;
	return c;
  800f71:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800f75:	eb 05                	jmp    800f7c <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800f77:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800f7c:	c9                   	leave  
  800f7d:	c3                   	ret    

00800f7e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800f7e:	55                   	push   %ebp
  800f7f:	89 e5                	mov    %esp,%ebp
  800f81:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f84:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f87:	50                   	push   %eax
  800f88:	ff 75 08             	pushl  0x8(%ebp)
  800f8b:	e8 2c f4 ff ff       	call   8003bc <fd_lookup>
  800f90:	83 c4 10             	add    $0x10,%esp
  800f93:	85 c0                	test   %eax,%eax
  800f95:	78 11                	js     800fa8 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800f97:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f9a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fa0:	39 10                	cmp    %edx,(%eax)
  800fa2:	0f 94 c0             	sete   %al
  800fa5:	0f b6 c0             	movzbl %al,%eax
}
  800fa8:	c9                   	leave  
  800fa9:	c3                   	ret    

00800faa <opencons>:

int
opencons(void)
{
  800faa:	55                   	push   %ebp
  800fab:	89 e5                	mov    %esp,%ebp
  800fad:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fb0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fb3:	50                   	push   %eax
  800fb4:	e8 b4 f3 ff ff       	call   80036d <fd_alloc>
  800fb9:	83 c4 10             	add    $0x10,%esp
		return r;
  800fbc:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fbe:	85 c0                	test   %eax,%eax
  800fc0:	78 3e                	js     801000 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fc2:	83 ec 04             	sub    $0x4,%esp
  800fc5:	68 07 04 00 00       	push   $0x407
  800fca:	ff 75 f4             	pushl  -0xc(%ebp)
  800fcd:	6a 00                	push   $0x0
  800fcf:	e8 81 f1 ff ff       	call   800155 <sys_page_alloc>
  800fd4:	83 c4 10             	add    $0x10,%esp
		return r;
  800fd7:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fd9:	85 c0                	test   %eax,%eax
  800fdb:	78 23                	js     801000 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800fdd:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fe3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fe6:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800fe8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800feb:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800ff2:	83 ec 0c             	sub    $0xc,%esp
  800ff5:	50                   	push   %eax
  800ff6:	e8 4b f3 ff ff       	call   800346 <fd2num>
  800ffb:	89 c2                	mov    %eax,%edx
  800ffd:	83 c4 10             	add    $0x10,%esp
}
  801000:	89 d0                	mov    %edx,%eax
  801002:	c9                   	leave  
  801003:	c3                   	ret    

00801004 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801004:	55                   	push   %ebp
  801005:	89 e5                	mov    %esp,%ebp
  801007:	56                   	push   %esi
  801008:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801009:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80100c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801012:	e8 00 f1 ff ff       	call   800117 <sys_getenvid>
  801017:	83 ec 0c             	sub    $0xc,%esp
  80101a:	ff 75 0c             	pushl  0xc(%ebp)
  80101d:	ff 75 08             	pushl  0x8(%ebp)
  801020:	56                   	push   %esi
  801021:	50                   	push   %eax
  801022:	68 60 1f 80 00       	push   $0x801f60
  801027:	e8 b1 00 00 00       	call   8010dd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80102c:	83 c4 18             	add    $0x18,%esp
  80102f:	53                   	push   %ebx
  801030:	ff 75 10             	pushl  0x10(%ebp)
  801033:	e8 54 00 00 00       	call   80108c <vcprintf>
	cprintf("\n");
  801038:	c7 04 24 4d 1f 80 00 	movl   $0x801f4d,(%esp)
  80103f:	e8 99 00 00 00       	call   8010dd <cprintf>
  801044:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801047:	cc                   	int3   
  801048:	eb fd                	jmp    801047 <_panic+0x43>

0080104a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80104a:	55                   	push   %ebp
  80104b:	89 e5                	mov    %esp,%ebp
  80104d:	53                   	push   %ebx
  80104e:	83 ec 04             	sub    $0x4,%esp
  801051:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801054:	8b 13                	mov    (%ebx),%edx
  801056:	8d 42 01             	lea    0x1(%edx),%eax
  801059:	89 03                	mov    %eax,(%ebx)
  80105b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80105e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801062:	3d ff 00 00 00       	cmp    $0xff,%eax
  801067:	75 1a                	jne    801083 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801069:	83 ec 08             	sub    $0x8,%esp
  80106c:	68 ff 00 00 00       	push   $0xff
  801071:	8d 43 08             	lea    0x8(%ebx),%eax
  801074:	50                   	push   %eax
  801075:	e8 1f f0 ff ff       	call   800099 <sys_cputs>
		b->idx = 0;
  80107a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801080:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801083:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801087:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80108a:	c9                   	leave  
  80108b:	c3                   	ret    

0080108c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80108c:	55                   	push   %ebp
  80108d:	89 e5                	mov    %esp,%ebp
  80108f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801095:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80109c:	00 00 00 
	b.cnt = 0;
  80109f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010a6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010a9:	ff 75 0c             	pushl  0xc(%ebp)
  8010ac:	ff 75 08             	pushl  0x8(%ebp)
  8010af:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010b5:	50                   	push   %eax
  8010b6:	68 4a 10 80 00       	push   $0x80104a
  8010bb:	e8 1a 01 00 00       	call   8011da <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010c0:	83 c4 08             	add    $0x8,%esp
  8010c3:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8010c9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8010cf:	50                   	push   %eax
  8010d0:	e8 c4 ef ff ff       	call   800099 <sys_cputs>

	return b.cnt;
}
  8010d5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8010db:	c9                   	leave  
  8010dc:	c3                   	ret    

008010dd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8010dd:	55                   	push   %ebp
  8010de:	89 e5                	mov    %esp,%ebp
  8010e0:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8010e3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8010e6:	50                   	push   %eax
  8010e7:	ff 75 08             	pushl  0x8(%ebp)
  8010ea:	e8 9d ff ff ff       	call   80108c <vcprintf>
	va_end(ap);

	return cnt;
}
  8010ef:	c9                   	leave  
  8010f0:	c3                   	ret    

008010f1 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8010f1:	55                   	push   %ebp
  8010f2:	89 e5                	mov    %esp,%ebp
  8010f4:	57                   	push   %edi
  8010f5:	56                   	push   %esi
  8010f6:	53                   	push   %ebx
  8010f7:	83 ec 1c             	sub    $0x1c,%esp
  8010fa:	89 c7                	mov    %eax,%edi
  8010fc:	89 d6                	mov    %edx,%esi
  8010fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801101:	8b 55 0c             	mov    0xc(%ebp),%edx
  801104:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801107:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80110a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80110d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801112:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801115:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801118:	39 d3                	cmp    %edx,%ebx
  80111a:	72 05                	jb     801121 <printnum+0x30>
  80111c:	39 45 10             	cmp    %eax,0x10(%ebp)
  80111f:	77 45                	ja     801166 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801121:	83 ec 0c             	sub    $0xc,%esp
  801124:	ff 75 18             	pushl  0x18(%ebp)
  801127:	8b 45 14             	mov    0x14(%ebp),%eax
  80112a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80112d:	53                   	push   %ebx
  80112e:	ff 75 10             	pushl  0x10(%ebp)
  801131:	83 ec 08             	sub    $0x8,%esp
  801134:	ff 75 e4             	pushl  -0x1c(%ebp)
  801137:	ff 75 e0             	pushl  -0x20(%ebp)
  80113a:	ff 75 dc             	pushl  -0x24(%ebp)
  80113d:	ff 75 d8             	pushl  -0x28(%ebp)
  801140:	e8 4b 0a 00 00       	call   801b90 <__udivdi3>
  801145:	83 c4 18             	add    $0x18,%esp
  801148:	52                   	push   %edx
  801149:	50                   	push   %eax
  80114a:	89 f2                	mov    %esi,%edx
  80114c:	89 f8                	mov    %edi,%eax
  80114e:	e8 9e ff ff ff       	call   8010f1 <printnum>
  801153:	83 c4 20             	add    $0x20,%esp
  801156:	eb 18                	jmp    801170 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801158:	83 ec 08             	sub    $0x8,%esp
  80115b:	56                   	push   %esi
  80115c:	ff 75 18             	pushl  0x18(%ebp)
  80115f:	ff d7                	call   *%edi
  801161:	83 c4 10             	add    $0x10,%esp
  801164:	eb 03                	jmp    801169 <printnum+0x78>
  801166:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801169:	83 eb 01             	sub    $0x1,%ebx
  80116c:	85 db                	test   %ebx,%ebx
  80116e:	7f e8                	jg     801158 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801170:	83 ec 08             	sub    $0x8,%esp
  801173:	56                   	push   %esi
  801174:	83 ec 04             	sub    $0x4,%esp
  801177:	ff 75 e4             	pushl  -0x1c(%ebp)
  80117a:	ff 75 e0             	pushl  -0x20(%ebp)
  80117d:	ff 75 dc             	pushl  -0x24(%ebp)
  801180:	ff 75 d8             	pushl  -0x28(%ebp)
  801183:	e8 38 0b 00 00       	call   801cc0 <__umoddi3>
  801188:	83 c4 14             	add    $0x14,%esp
  80118b:	0f be 80 83 1f 80 00 	movsbl 0x801f83(%eax),%eax
  801192:	50                   	push   %eax
  801193:	ff d7                	call   *%edi
}
  801195:	83 c4 10             	add    $0x10,%esp
  801198:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80119b:	5b                   	pop    %ebx
  80119c:	5e                   	pop    %esi
  80119d:	5f                   	pop    %edi
  80119e:	5d                   	pop    %ebp
  80119f:	c3                   	ret    

008011a0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011a0:	55                   	push   %ebp
  8011a1:	89 e5                	mov    %esp,%ebp
  8011a3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011a6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8011aa:	8b 10                	mov    (%eax),%edx
  8011ac:	3b 50 04             	cmp    0x4(%eax),%edx
  8011af:	73 0a                	jae    8011bb <sprintputch+0x1b>
		*b->buf++ = ch;
  8011b1:	8d 4a 01             	lea    0x1(%edx),%ecx
  8011b4:	89 08                	mov    %ecx,(%eax)
  8011b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8011b9:	88 02                	mov    %al,(%edx)
}
  8011bb:	5d                   	pop    %ebp
  8011bc:	c3                   	ret    

008011bd <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8011bd:	55                   	push   %ebp
  8011be:	89 e5                	mov    %esp,%ebp
  8011c0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8011c3:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8011c6:	50                   	push   %eax
  8011c7:	ff 75 10             	pushl  0x10(%ebp)
  8011ca:	ff 75 0c             	pushl  0xc(%ebp)
  8011cd:	ff 75 08             	pushl  0x8(%ebp)
  8011d0:	e8 05 00 00 00       	call   8011da <vprintfmt>
	va_end(ap);
}
  8011d5:	83 c4 10             	add    $0x10,%esp
  8011d8:	c9                   	leave  
  8011d9:	c3                   	ret    

008011da <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8011da:	55                   	push   %ebp
  8011db:	89 e5                	mov    %esp,%ebp
  8011dd:	57                   	push   %edi
  8011de:	56                   	push   %esi
  8011df:	53                   	push   %ebx
  8011e0:	83 ec 2c             	sub    $0x2c,%esp
  8011e3:	8b 75 08             	mov    0x8(%ebp),%esi
  8011e6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8011e9:	8b 7d 10             	mov    0x10(%ebp),%edi
  8011ec:	eb 12                	jmp    801200 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8011ee:	85 c0                	test   %eax,%eax
  8011f0:	0f 84 6a 04 00 00    	je     801660 <vprintfmt+0x486>
				return;
			putch(ch, putdat);
  8011f6:	83 ec 08             	sub    $0x8,%esp
  8011f9:	53                   	push   %ebx
  8011fa:	50                   	push   %eax
  8011fb:	ff d6                	call   *%esi
  8011fd:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801200:	83 c7 01             	add    $0x1,%edi
  801203:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801207:	83 f8 25             	cmp    $0x25,%eax
  80120a:	75 e2                	jne    8011ee <vprintfmt+0x14>
  80120c:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801210:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801217:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80121e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801225:	b9 00 00 00 00       	mov    $0x0,%ecx
  80122a:	eb 07                	jmp    801233 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80122c:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80122f:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801233:	8d 47 01             	lea    0x1(%edi),%eax
  801236:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801239:	0f b6 07             	movzbl (%edi),%eax
  80123c:	0f b6 d0             	movzbl %al,%edx
  80123f:	83 e8 23             	sub    $0x23,%eax
  801242:	3c 55                	cmp    $0x55,%al
  801244:	0f 87 fb 03 00 00    	ja     801645 <vprintfmt+0x46b>
  80124a:	0f b6 c0             	movzbl %al,%eax
  80124d:	ff 24 85 c0 20 80 00 	jmp    *0x8020c0(,%eax,4)
  801254:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801257:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80125b:	eb d6                	jmp    801233 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80125d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801260:	b8 00 00 00 00       	mov    $0x0,%eax
  801265:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801268:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80126b:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80126f:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801272:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801275:	83 f9 09             	cmp    $0x9,%ecx
  801278:	77 3f                	ja     8012b9 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80127a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80127d:	eb e9                	jmp    801268 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80127f:	8b 45 14             	mov    0x14(%ebp),%eax
  801282:	8b 00                	mov    (%eax),%eax
  801284:	89 45 d0             	mov    %eax,-0x30(%ebp)
  801287:	8b 45 14             	mov    0x14(%ebp),%eax
  80128a:	8d 40 04             	lea    0x4(%eax),%eax
  80128d:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801290:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801293:	eb 2a                	jmp    8012bf <vprintfmt+0xe5>
  801295:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801298:	85 c0                	test   %eax,%eax
  80129a:	ba 00 00 00 00       	mov    $0x0,%edx
  80129f:	0f 49 d0             	cmovns %eax,%edx
  8012a2:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012a8:	eb 89                	jmp    801233 <vprintfmt+0x59>
  8012aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8012ad:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8012b4:	e9 7a ff ff ff       	jmp    801233 <vprintfmt+0x59>
  8012b9:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8012bc:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8012bf:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8012c3:	0f 89 6a ff ff ff    	jns    801233 <vprintfmt+0x59>
				width = precision, precision = -1;
  8012c9:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8012cc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8012cf:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8012d6:	e9 58 ff ff ff       	jmp    801233 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8012db:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012de:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8012e1:	e9 4d ff ff ff       	jmp    801233 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8012e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8012e9:	8d 78 04             	lea    0x4(%eax),%edi
  8012ec:	83 ec 08             	sub    $0x8,%esp
  8012ef:	53                   	push   %ebx
  8012f0:	ff 30                	pushl  (%eax)
  8012f2:	ff d6                	call   *%esi
			break;
  8012f4:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8012f7:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8012fd:	e9 fe fe ff ff       	jmp    801200 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801302:	8b 45 14             	mov    0x14(%ebp),%eax
  801305:	8d 78 04             	lea    0x4(%eax),%edi
  801308:	8b 00                	mov    (%eax),%eax
  80130a:	99                   	cltd   
  80130b:	31 d0                	xor    %edx,%eax
  80130d:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80130f:	83 f8 0f             	cmp    $0xf,%eax
  801312:	7f 0b                	jg     80131f <vprintfmt+0x145>
  801314:	8b 14 85 20 22 80 00 	mov    0x802220(,%eax,4),%edx
  80131b:	85 d2                	test   %edx,%edx
  80131d:	75 1b                	jne    80133a <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  80131f:	50                   	push   %eax
  801320:	68 9b 1f 80 00       	push   $0x801f9b
  801325:	53                   	push   %ebx
  801326:	56                   	push   %esi
  801327:	e8 91 fe ff ff       	call   8011bd <printfmt>
  80132c:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80132f:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801332:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801335:	e9 c6 fe ff ff       	jmp    801200 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80133a:	52                   	push   %edx
  80133b:	68 26 1f 80 00       	push   $0x801f26
  801340:	53                   	push   %ebx
  801341:	56                   	push   %esi
  801342:	e8 76 fe ff ff       	call   8011bd <printfmt>
  801347:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80134a:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80134d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801350:	e9 ab fe ff ff       	jmp    801200 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801355:	8b 45 14             	mov    0x14(%ebp),%eax
  801358:	83 c0 04             	add    $0x4,%eax
  80135b:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80135e:	8b 45 14             	mov    0x14(%ebp),%eax
  801361:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801363:	85 ff                	test   %edi,%edi
  801365:	b8 94 1f 80 00       	mov    $0x801f94,%eax
  80136a:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80136d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801371:	0f 8e 94 00 00 00    	jle    80140b <vprintfmt+0x231>
  801377:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80137b:	0f 84 98 00 00 00    	je     801419 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  801381:	83 ec 08             	sub    $0x8,%esp
  801384:	ff 75 d0             	pushl  -0x30(%ebp)
  801387:	57                   	push   %edi
  801388:	e8 5b 03 00 00       	call   8016e8 <strnlen>
  80138d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801390:	29 c1                	sub    %eax,%ecx
  801392:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  801395:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801398:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80139c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80139f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8013a2:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013a4:	eb 0f                	jmp    8013b5 <vprintfmt+0x1db>
					putch(padc, putdat);
  8013a6:	83 ec 08             	sub    $0x8,%esp
  8013a9:	53                   	push   %ebx
  8013aa:	ff 75 e0             	pushl  -0x20(%ebp)
  8013ad:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013af:	83 ef 01             	sub    $0x1,%edi
  8013b2:	83 c4 10             	add    $0x10,%esp
  8013b5:	85 ff                	test   %edi,%edi
  8013b7:	7f ed                	jg     8013a6 <vprintfmt+0x1cc>
  8013b9:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8013bc:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8013bf:	85 c9                	test   %ecx,%ecx
  8013c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8013c6:	0f 49 c1             	cmovns %ecx,%eax
  8013c9:	29 c1                	sub    %eax,%ecx
  8013cb:	89 75 08             	mov    %esi,0x8(%ebp)
  8013ce:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8013d1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8013d4:	89 cb                	mov    %ecx,%ebx
  8013d6:	eb 4d                	jmp    801425 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8013d8:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8013dc:	74 1b                	je     8013f9 <vprintfmt+0x21f>
  8013de:	0f be c0             	movsbl %al,%eax
  8013e1:	83 e8 20             	sub    $0x20,%eax
  8013e4:	83 f8 5e             	cmp    $0x5e,%eax
  8013e7:	76 10                	jbe    8013f9 <vprintfmt+0x21f>
					putch('?', putdat);
  8013e9:	83 ec 08             	sub    $0x8,%esp
  8013ec:	ff 75 0c             	pushl  0xc(%ebp)
  8013ef:	6a 3f                	push   $0x3f
  8013f1:	ff 55 08             	call   *0x8(%ebp)
  8013f4:	83 c4 10             	add    $0x10,%esp
  8013f7:	eb 0d                	jmp    801406 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  8013f9:	83 ec 08             	sub    $0x8,%esp
  8013fc:	ff 75 0c             	pushl  0xc(%ebp)
  8013ff:	52                   	push   %edx
  801400:	ff 55 08             	call   *0x8(%ebp)
  801403:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801406:	83 eb 01             	sub    $0x1,%ebx
  801409:	eb 1a                	jmp    801425 <vprintfmt+0x24b>
  80140b:	89 75 08             	mov    %esi,0x8(%ebp)
  80140e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801411:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801414:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801417:	eb 0c                	jmp    801425 <vprintfmt+0x24b>
  801419:	89 75 08             	mov    %esi,0x8(%ebp)
  80141c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80141f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801422:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801425:	83 c7 01             	add    $0x1,%edi
  801428:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80142c:	0f be d0             	movsbl %al,%edx
  80142f:	85 d2                	test   %edx,%edx
  801431:	74 23                	je     801456 <vprintfmt+0x27c>
  801433:	85 f6                	test   %esi,%esi
  801435:	78 a1                	js     8013d8 <vprintfmt+0x1fe>
  801437:	83 ee 01             	sub    $0x1,%esi
  80143a:	79 9c                	jns    8013d8 <vprintfmt+0x1fe>
  80143c:	89 df                	mov    %ebx,%edi
  80143e:	8b 75 08             	mov    0x8(%ebp),%esi
  801441:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801444:	eb 18                	jmp    80145e <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801446:	83 ec 08             	sub    $0x8,%esp
  801449:	53                   	push   %ebx
  80144a:	6a 20                	push   $0x20
  80144c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80144e:	83 ef 01             	sub    $0x1,%edi
  801451:	83 c4 10             	add    $0x10,%esp
  801454:	eb 08                	jmp    80145e <vprintfmt+0x284>
  801456:	89 df                	mov    %ebx,%edi
  801458:	8b 75 08             	mov    0x8(%ebp),%esi
  80145b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80145e:	85 ff                	test   %edi,%edi
  801460:	7f e4                	jg     801446 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801462:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801465:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801468:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80146b:	e9 90 fd ff ff       	jmp    801200 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801470:	83 f9 01             	cmp    $0x1,%ecx
  801473:	7e 19                	jle    80148e <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  801475:	8b 45 14             	mov    0x14(%ebp),%eax
  801478:	8b 50 04             	mov    0x4(%eax),%edx
  80147b:	8b 00                	mov    (%eax),%eax
  80147d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801480:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801483:	8b 45 14             	mov    0x14(%ebp),%eax
  801486:	8d 40 08             	lea    0x8(%eax),%eax
  801489:	89 45 14             	mov    %eax,0x14(%ebp)
  80148c:	eb 38                	jmp    8014c6 <vprintfmt+0x2ec>
	else if (lflag)
  80148e:	85 c9                	test   %ecx,%ecx
  801490:	74 1b                	je     8014ad <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  801492:	8b 45 14             	mov    0x14(%ebp),%eax
  801495:	8b 00                	mov    (%eax),%eax
  801497:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80149a:	89 c1                	mov    %eax,%ecx
  80149c:	c1 f9 1f             	sar    $0x1f,%ecx
  80149f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8014a5:	8d 40 04             	lea    0x4(%eax),%eax
  8014a8:	89 45 14             	mov    %eax,0x14(%ebp)
  8014ab:	eb 19                	jmp    8014c6 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8014ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8014b0:	8b 00                	mov    (%eax),%eax
  8014b2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014b5:	89 c1                	mov    %eax,%ecx
  8014b7:	c1 f9 1f             	sar    $0x1f,%ecx
  8014ba:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8014c0:	8d 40 04             	lea    0x4(%eax),%eax
  8014c3:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8014c6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8014c9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8014cc:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8014d1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8014d5:	0f 89 36 01 00 00    	jns    801611 <vprintfmt+0x437>
				putch('-', putdat);
  8014db:	83 ec 08             	sub    $0x8,%esp
  8014de:	53                   	push   %ebx
  8014df:	6a 2d                	push   $0x2d
  8014e1:	ff d6                	call   *%esi
				num = -(long long) num;
  8014e3:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8014e6:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8014e9:	f7 da                	neg    %edx
  8014eb:	83 d1 00             	adc    $0x0,%ecx
  8014ee:	f7 d9                	neg    %ecx
  8014f0:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8014f3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014f8:	e9 14 01 00 00       	jmp    801611 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8014fd:	83 f9 01             	cmp    $0x1,%ecx
  801500:	7e 18                	jle    80151a <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  801502:	8b 45 14             	mov    0x14(%ebp),%eax
  801505:	8b 10                	mov    (%eax),%edx
  801507:	8b 48 04             	mov    0x4(%eax),%ecx
  80150a:	8d 40 08             	lea    0x8(%eax),%eax
  80150d:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801510:	b8 0a 00 00 00       	mov    $0xa,%eax
  801515:	e9 f7 00 00 00       	jmp    801611 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80151a:	85 c9                	test   %ecx,%ecx
  80151c:	74 1a                	je     801538 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  80151e:	8b 45 14             	mov    0x14(%ebp),%eax
  801521:	8b 10                	mov    (%eax),%edx
  801523:	b9 00 00 00 00       	mov    $0x0,%ecx
  801528:	8d 40 04             	lea    0x4(%eax),%eax
  80152b:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80152e:	b8 0a 00 00 00       	mov    $0xa,%eax
  801533:	e9 d9 00 00 00       	jmp    801611 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  801538:	8b 45 14             	mov    0x14(%ebp),%eax
  80153b:	8b 10                	mov    (%eax),%edx
  80153d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801542:	8d 40 04             	lea    0x4(%eax),%eax
  801545:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801548:	b8 0a 00 00 00       	mov    $0xa,%eax
  80154d:	e9 bf 00 00 00       	jmp    801611 <vprintfmt+0x437>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801552:	83 f9 01             	cmp    $0x1,%ecx
  801555:	7e 13                	jle    80156a <vprintfmt+0x390>
		return va_arg(*ap, long long);
  801557:	8b 45 14             	mov    0x14(%ebp),%eax
  80155a:	8b 50 04             	mov    0x4(%eax),%edx
  80155d:	8b 00                	mov    (%eax),%eax
  80155f:	8b 4d 14             	mov    0x14(%ebp),%ecx
  801562:	8d 49 08             	lea    0x8(%ecx),%ecx
  801565:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801568:	eb 28                	jmp    801592 <vprintfmt+0x3b8>
	else if (lflag)
  80156a:	85 c9                	test   %ecx,%ecx
  80156c:	74 13                	je     801581 <vprintfmt+0x3a7>
		return va_arg(*ap, long);
  80156e:	8b 45 14             	mov    0x14(%ebp),%eax
  801571:	8b 10                	mov    (%eax),%edx
  801573:	89 d0                	mov    %edx,%eax
  801575:	99                   	cltd   
  801576:	8b 4d 14             	mov    0x14(%ebp),%ecx
  801579:	8d 49 04             	lea    0x4(%ecx),%ecx
  80157c:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80157f:	eb 11                	jmp    801592 <vprintfmt+0x3b8>
	else
		return va_arg(*ap, int);
  801581:	8b 45 14             	mov    0x14(%ebp),%eax
  801584:	8b 10                	mov    (%eax),%edx
  801586:	89 d0                	mov    %edx,%eax
  801588:	99                   	cltd   
  801589:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80158c:	8d 49 04             	lea    0x4(%ecx),%ecx
  80158f:	89 4d 14             	mov    %ecx,0x14(%ebp)
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getint(&ap, lflag);
  801592:	89 d1                	mov    %edx,%ecx
  801594:	89 c2                	mov    %eax,%edx
			base = 8;
  801596:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  80159b:	eb 74                	jmp    801611 <vprintfmt+0x437>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80159d:	83 ec 08             	sub    $0x8,%esp
  8015a0:	53                   	push   %ebx
  8015a1:	6a 30                	push   $0x30
  8015a3:	ff d6                	call   *%esi
			putch('x', putdat);
  8015a5:	83 c4 08             	add    $0x8,%esp
  8015a8:	53                   	push   %ebx
  8015a9:	6a 78                	push   $0x78
  8015ab:	ff d6                	call   *%esi
			num = (unsigned long long)
  8015ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8015b0:	8b 10                	mov    (%eax),%edx
  8015b2:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015b7:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8015ba:	8d 40 04             	lea    0x4(%eax),%eax
  8015bd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8015c0:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8015c5:	eb 4a                	jmp    801611 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8015c7:	83 f9 01             	cmp    $0x1,%ecx
  8015ca:	7e 15                	jle    8015e1 <vprintfmt+0x407>
		return va_arg(*ap, unsigned long long);
  8015cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8015cf:	8b 10                	mov    (%eax),%edx
  8015d1:	8b 48 04             	mov    0x4(%eax),%ecx
  8015d4:	8d 40 08             	lea    0x8(%eax),%eax
  8015d7:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8015da:	b8 10 00 00 00       	mov    $0x10,%eax
  8015df:	eb 30                	jmp    801611 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8015e1:	85 c9                	test   %ecx,%ecx
  8015e3:	74 17                	je     8015fc <vprintfmt+0x422>
		return va_arg(*ap, unsigned long);
  8015e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8015e8:	8b 10                	mov    (%eax),%edx
  8015ea:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015ef:	8d 40 04             	lea    0x4(%eax),%eax
  8015f2:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8015f5:	b8 10 00 00 00       	mov    $0x10,%eax
  8015fa:	eb 15                	jmp    801611 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8015fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8015ff:	8b 10                	mov    (%eax),%edx
  801601:	b9 00 00 00 00       	mov    $0x0,%ecx
  801606:	8d 40 04             	lea    0x4(%eax),%eax
  801609:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80160c:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  801611:	83 ec 0c             	sub    $0xc,%esp
  801614:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801618:	57                   	push   %edi
  801619:	ff 75 e0             	pushl  -0x20(%ebp)
  80161c:	50                   	push   %eax
  80161d:	51                   	push   %ecx
  80161e:	52                   	push   %edx
  80161f:	89 da                	mov    %ebx,%edx
  801621:	89 f0                	mov    %esi,%eax
  801623:	e8 c9 fa ff ff       	call   8010f1 <printnum>
			break;
  801628:	83 c4 20             	add    $0x20,%esp
  80162b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80162e:	e9 cd fb ff ff       	jmp    801200 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801633:	83 ec 08             	sub    $0x8,%esp
  801636:	53                   	push   %ebx
  801637:	52                   	push   %edx
  801638:	ff d6                	call   *%esi
			break;
  80163a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80163d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801640:	e9 bb fb ff ff       	jmp    801200 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801645:	83 ec 08             	sub    $0x8,%esp
  801648:	53                   	push   %ebx
  801649:	6a 25                	push   $0x25
  80164b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80164d:	83 c4 10             	add    $0x10,%esp
  801650:	eb 03                	jmp    801655 <vprintfmt+0x47b>
  801652:	83 ef 01             	sub    $0x1,%edi
  801655:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801659:	75 f7                	jne    801652 <vprintfmt+0x478>
  80165b:	e9 a0 fb ff ff       	jmp    801200 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801660:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801663:	5b                   	pop    %ebx
  801664:	5e                   	pop    %esi
  801665:	5f                   	pop    %edi
  801666:	5d                   	pop    %ebp
  801667:	c3                   	ret    

00801668 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801668:	55                   	push   %ebp
  801669:	89 e5                	mov    %esp,%ebp
  80166b:	83 ec 18             	sub    $0x18,%esp
  80166e:	8b 45 08             	mov    0x8(%ebp),%eax
  801671:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801674:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801677:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80167b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80167e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801685:	85 c0                	test   %eax,%eax
  801687:	74 26                	je     8016af <vsnprintf+0x47>
  801689:	85 d2                	test   %edx,%edx
  80168b:	7e 22                	jle    8016af <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80168d:	ff 75 14             	pushl  0x14(%ebp)
  801690:	ff 75 10             	pushl  0x10(%ebp)
  801693:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801696:	50                   	push   %eax
  801697:	68 a0 11 80 00       	push   $0x8011a0
  80169c:	e8 39 fb ff ff       	call   8011da <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8016a1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8016a4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8016a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016aa:	83 c4 10             	add    $0x10,%esp
  8016ad:	eb 05                	jmp    8016b4 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8016af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8016b4:	c9                   	leave  
  8016b5:	c3                   	ret    

008016b6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8016b6:	55                   	push   %ebp
  8016b7:	89 e5                	mov    %esp,%ebp
  8016b9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8016bc:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8016bf:	50                   	push   %eax
  8016c0:	ff 75 10             	pushl  0x10(%ebp)
  8016c3:	ff 75 0c             	pushl  0xc(%ebp)
  8016c6:	ff 75 08             	pushl  0x8(%ebp)
  8016c9:	e8 9a ff ff ff       	call   801668 <vsnprintf>
	va_end(ap);

	return rc;
}
  8016ce:	c9                   	leave  
  8016cf:	c3                   	ret    

008016d0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8016d0:	55                   	push   %ebp
  8016d1:	89 e5                	mov    %esp,%ebp
  8016d3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8016d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8016db:	eb 03                	jmp    8016e0 <strlen+0x10>
		n++;
  8016dd:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8016e0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8016e4:	75 f7                	jne    8016dd <strlen+0xd>
		n++;
	return n;
}
  8016e6:	5d                   	pop    %ebp
  8016e7:	c3                   	ret    

008016e8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8016e8:	55                   	push   %ebp
  8016e9:	89 e5                	mov    %esp,%ebp
  8016eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016ee:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8016f6:	eb 03                	jmp    8016fb <strnlen+0x13>
		n++;
  8016f8:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016fb:	39 c2                	cmp    %eax,%edx
  8016fd:	74 08                	je     801707 <strnlen+0x1f>
  8016ff:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801703:	75 f3                	jne    8016f8 <strnlen+0x10>
  801705:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801707:	5d                   	pop    %ebp
  801708:	c3                   	ret    

00801709 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801709:	55                   	push   %ebp
  80170a:	89 e5                	mov    %esp,%ebp
  80170c:	53                   	push   %ebx
  80170d:	8b 45 08             	mov    0x8(%ebp),%eax
  801710:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801713:	89 c2                	mov    %eax,%edx
  801715:	83 c2 01             	add    $0x1,%edx
  801718:	83 c1 01             	add    $0x1,%ecx
  80171b:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80171f:	88 5a ff             	mov    %bl,-0x1(%edx)
  801722:	84 db                	test   %bl,%bl
  801724:	75 ef                	jne    801715 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801726:	5b                   	pop    %ebx
  801727:	5d                   	pop    %ebp
  801728:	c3                   	ret    

00801729 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801729:	55                   	push   %ebp
  80172a:	89 e5                	mov    %esp,%ebp
  80172c:	53                   	push   %ebx
  80172d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801730:	53                   	push   %ebx
  801731:	e8 9a ff ff ff       	call   8016d0 <strlen>
  801736:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801739:	ff 75 0c             	pushl  0xc(%ebp)
  80173c:	01 d8                	add    %ebx,%eax
  80173e:	50                   	push   %eax
  80173f:	e8 c5 ff ff ff       	call   801709 <strcpy>
	return dst;
}
  801744:	89 d8                	mov    %ebx,%eax
  801746:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801749:	c9                   	leave  
  80174a:	c3                   	ret    

0080174b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80174b:	55                   	push   %ebp
  80174c:	89 e5                	mov    %esp,%ebp
  80174e:	56                   	push   %esi
  80174f:	53                   	push   %ebx
  801750:	8b 75 08             	mov    0x8(%ebp),%esi
  801753:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801756:	89 f3                	mov    %esi,%ebx
  801758:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80175b:	89 f2                	mov    %esi,%edx
  80175d:	eb 0f                	jmp    80176e <strncpy+0x23>
		*dst++ = *src;
  80175f:	83 c2 01             	add    $0x1,%edx
  801762:	0f b6 01             	movzbl (%ecx),%eax
  801765:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801768:	80 39 01             	cmpb   $0x1,(%ecx)
  80176b:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80176e:	39 da                	cmp    %ebx,%edx
  801770:	75 ed                	jne    80175f <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801772:	89 f0                	mov    %esi,%eax
  801774:	5b                   	pop    %ebx
  801775:	5e                   	pop    %esi
  801776:	5d                   	pop    %ebp
  801777:	c3                   	ret    

00801778 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801778:	55                   	push   %ebp
  801779:	89 e5                	mov    %esp,%ebp
  80177b:	56                   	push   %esi
  80177c:	53                   	push   %ebx
  80177d:	8b 75 08             	mov    0x8(%ebp),%esi
  801780:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801783:	8b 55 10             	mov    0x10(%ebp),%edx
  801786:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801788:	85 d2                	test   %edx,%edx
  80178a:	74 21                	je     8017ad <strlcpy+0x35>
  80178c:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801790:	89 f2                	mov    %esi,%edx
  801792:	eb 09                	jmp    80179d <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801794:	83 c2 01             	add    $0x1,%edx
  801797:	83 c1 01             	add    $0x1,%ecx
  80179a:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80179d:	39 c2                	cmp    %eax,%edx
  80179f:	74 09                	je     8017aa <strlcpy+0x32>
  8017a1:	0f b6 19             	movzbl (%ecx),%ebx
  8017a4:	84 db                	test   %bl,%bl
  8017a6:	75 ec                	jne    801794 <strlcpy+0x1c>
  8017a8:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8017aa:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8017ad:	29 f0                	sub    %esi,%eax
}
  8017af:	5b                   	pop    %ebx
  8017b0:	5e                   	pop    %esi
  8017b1:	5d                   	pop    %ebp
  8017b2:	c3                   	ret    

008017b3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8017b3:	55                   	push   %ebp
  8017b4:	89 e5                	mov    %esp,%ebp
  8017b6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017b9:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8017bc:	eb 06                	jmp    8017c4 <strcmp+0x11>
		p++, q++;
  8017be:	83 c1 01             	add    $0x1,%ecx
  8017c1:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8017c4:	0f b6 01             	movzbl (%ecx),%eax
  8017c7:	84 c0                	test   %al,%al
  8017c9:	74 04                	je     8017cf <strcmp+0x1c>
  8017cb:	3a 02                	cmp    (%edx),%al
  8017cd:	74 ef                	je     8017be <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8017cf:	0f b6 c0             	movzbl %al,%eax
  8017d2:	0f b6 12             	movzbl (%edx),%edx
  8017d5:	29 d0                	sub    %edx,%eax
}
  8017d7:	5d                   	pop    %ebp
  8017d8:	c3                   	ret    

008017d9 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017d9:	55                   	push   %ebp
  8017da:	89 e5                	mov    %esp,%ebp
  8017dc:	53                   	push   %ebx
  8017dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017e3:	89 c3                	mov    %eax,%ebx
  8017e5:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017e8:	eb 06                	jmp    8017f0 <strncmp+0x17>
		n--, p++, q++;
  8017ea:	83 c0 01             	add    $0x1,%eax
  8017ed:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8017f0:	39 d8                	cmp    %ebx,%eax
  8017f2:	74 15                	je     801809 <strncmp+0x30>
  8017f4:	0f b6 08             	movzbl (%eax),%ecx
  8017f7:	84 c9                	test   %cl,%cl
  8017f9:	74 04                	je     8017ff <strncmp+0x26>
  8017fb:	3a 0a                	cmp    (%edx),%cl
  8017fd:	74 eb                	je     8017ea <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017ff:	0f b6 00             	movzbl (%eax),%eax
  801802:	0f b6 12             	movzbl (%edx),%edx
  801805:	29 d0                	sub    %edx,%eax
  801807:	eb 05                	jmp    80180e <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801809:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80180e:	5b                   	pop    %ebx
  80180f:	5d                   	pop    %ebp
  801810:	c3                   	ret    

00801811 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801811:	55                   	push   %ebp
  801812:	89 e5                	mov    %esp,%ebp
  801814:	8b 45 08             	mov    0x8(%ebp),%eax
  801817:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80181b:	eb 07                	jmp    801824 <strchr+0x13>
		if (*s == c)
  80181d:	38 ca                	cmp    %cl,%dl
  80181f:	74 0f                	je     801830 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801821:	83 c0 01             	add    $0x1,%eax
  801824:	0f b6 10             	movzbl (%eax),%edx
  801827:	84 d2                	test   %dl,%dl
  801829:	75 f2                	jne    80181d <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80182b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801830:	5d                   	pop    %ebp
  801831:	c3                   	ret    

00801832 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801832:	55                   	push   %ebp
  801833:	89 e5                	mov    %esp,%ebp
  801835:	8b 45 08             	mov    0x8(%ebp),%eax
  801838:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80183c:	eb 03                	jmp    801841 <strfind+0xf>
  80183e:	83 c0 01             	add    $0x1,%eax
  801841:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801844:	38 ca                	cmp    %cl,%dl
  801846:	74 04                	je     80184c <strfind+0x1a>
  801848:	84 d2                	test   %dl,%dl
  80184a:	75 f2                	jne    80183e <strfind+0xc>
			break;
	return (char *) s;
}
  80184c:	5d                   	pop    %ebp
  80184d:	c3                   	ret    

0080184e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80184e:	55                   	push   %ebp
  80184f:	89 e5                	mov    %esp,%ebp
  801851:	57                   	push   %edi
  801852:	56                   	push   %esi
  801853:	53                   	push   %ebx
  801854:	8b 7d 08             	mov    0x8(%ebp),%edi
  801857:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80185a:	85 c9                	test   %ecx,%ecx
  80185c:	74 36                	je     801894 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80185e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801864:	75 28                	jne    80188e <memset+0x40>
  801866:	f6 c1 03             	test   $0x3,%cl
  801869:	75 23                	jne    80188e <memset+0x40>
		c &= 0xFF;
  80186b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80186f:	89 d3                	mov    %edx,%ebx
  801871:	c1 e3 08             	shl    $0x8,%ebx
  801874:	89 d6                	mov    %edx,%esi
  801876:	c1 e6 18             	shl    $0x18,%esi
  801879:	89 d0                	mov    %edx,%eax
  80187b:	c1 e0 10             	shl    $0x10,%eax
  80187e:	09 f0                	or     %esi,%eax
  801880:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801882:	89 d8                	mov    %ebx,%eax
  801884:	09 d0                	or     %edx,%eax
  801886:	c1 e9 02             	shr    $0x2,%ecx
  801889:	fc                   	cld    
  80188a:	f3 ab                	rep stos %eax,%es:(%edi)
  80188c:	eb 06                	jmp    801894 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80188e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801891:	fc                   	cld    
  801892:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801894:	89 f8                	mov    %edi,%eax
  801896:	5b                   	pop    %ebx
  801897:	5e                   	pop    %esi
  801898:	5f                   	pop    %edi
  801899:	5d                   	pop    %ebp
  80189a:	c3                   	ret    

0080189b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80189b:	55                   	push   %ebp
  80189c:	89 e5                	mov    %esp,%ebp
  80189e:	57                   	push   %edi
  80189f:	56                   	push   %esi
  8018a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018a6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8018a9:	39 c6                	cmp    %eax,%esi
  8018ab:	73 35                	jae    8018e2 <memmove+0x47>
  8018ad:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8018b0:	39 d0                	cmp    %edx,%eax
  8018b2:	73 2e                	jae    8018e2 <memmove+0x47>
		s += n;
		d += n;
  8018b4:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018b7:	89 d6                	mov    %edx,%esi
  8018b9:	09 fe                	or     %edi,%esi
  8018bb:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018c1:	75 13                	jne    8018d6 <memmove+0x3b>
  8018c3:	f6 c1 03             	test   $0x3,%cl
  8018c6:	75 0e                	jne    8018d6 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8018c8:	83 ef 04             	sub    $0x4,%edi
  8018cb:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018ce:	c1 e9 02             	shr    $0x2,%ecx
  8018d1:	fd                   	std    
  8018d2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018d4:	eb 09                	jmp    8018df <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8018d6:	83 ef 01             	sub    $0x1,%edi
  8018d9:	8d 72 ff             	lea    -0x1(%edx),%esi
  8018dc:	fd                   	std    
  8018dd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018df:	fc                   	cld    
  8018e0:	eb 1d                	jmp    8018ff <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018e2:	89 f2                	mov    %esi,%edx
  8018e4:	09 c2                	or     %eax,%edx
  8018e6:	f6 c2 03             	test   $0x3,%dl
  8018e9:	75 0f                	jne    8018fa <memmove+0x5f>
  8018eb:	f6 c1 03             	test   $0x3,%cl
  8018ee:	75 0a                	jne    8018fa <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8018f0:	c1 e9 02             	shr    $0x2,%ecx
  8018f3:	89 c7                	mov    %eax,%edi
  8018f5:	fc                   	cld    
  8018f6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018f8:	eb 05                	jmp    8018ff <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018fa:	89 c7                	mov    %eax,%edi
  8018fc:	fc                   	cld    
  8018fd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018ff:	5e                   	pop    %esi
  801900:	5f                   	pop    %edi
  801901:	5d                   	pop    %ebp
  801902:	c3                   	ret    

00801903 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801903:	55                   	push   %ebp
  801904:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801906:	ff 75 10             	pushl  0x10(%ebp)
  801909:	ff 75 0c             	pushl  0xc(%ebp)
  80190c:	ff 75 08             	pushl  0x8(%ebp)
  80190f:	e8 87 ff ff ff       	call   80189b <memmove>
}
  801914:	c9                   	leave  
  801915:	c3                   	ret    

00801916 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801916:	55                   	push   %ebp
  801917:	89 e5                	mov    %esp,%ebp
  801919:	56                   	push   %esi
  80191a:	53                   	push   %ebx
  80191b:	8b 45 08             	mov    0x8(%ebp),%eax
  80191e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801921:	89 c6                	mov    %eax,%esi
  801923:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801926:	eb 1a                	jmp    801942 <memcmp+0x2c>
		if (*s1 != *s2)
  801928:	0f b6 08             	movzbl (%eax),%ecx
  80192b:	0f b6 1a             	movzbl (%edx),%ebx
  80192e:	38 d9                	cmp    %bl,%cl
  801930:	74 0a                	je     80193c <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801932:	0f b6 c1             	movzbl %cl,%eax
  801935:	0f b6 db             	movzbl %bl,%ebx
  801938:	29 d8                	sub    %ebx,%eax
  80193a:	eb 0f                	jmp    80194b <memcmp+0x35>
		s1++, s2++;
  80193c:	83 c0 01             	add    $0x1,%eax
  80193f:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801942:	39 f0                	cmp    %esi,%eax
  801944:	75 e2                	jne    801928 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801946:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80194b:	5b                   	pop    %ebx
  80194c:	5e                   	pop    %esi
  80194d:	5d                   	pop    %ebp
  80194e:	c3                   	ret    

0080194f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80194f:	55                   	push   %ebp
  801950:	89 e5                	mov    %esp,%ebp
  801952:	53                   	push   %ebx
  801953:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801956:	89 c1                	mov    %eax,%ecx
  801958:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80195b:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80195f:	eb 0a                	jmp    80196b <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801961:	0f b6 10             	movzbl (%eax),%edx
  801964:	39 da                	cmp    %ebx,%edx
  801966:	74 07                	je     80196f <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801968:	83 c0 01             	add    $0x1,%eax
  80196b:	39 c8                	cmp    %ecx,%eax
  80196d:	72 f2                	jb     801961 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80196f:	5b                   	pop    %ebx
  801970:	5d                   	pop    %ebp
  801971:	c3                   	ret    

00801972 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801972:	55                   	push   %ebp
  801973:	89 e5                	mov    %esp,%ebp
  801975:	57                   	push   %edi
  801976:	56                   	push   %esi
  801977:	53                   	push   %ebx
  801978:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80197b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80197e:	eb 03                	jmp    801983 <strtol+0x11>
		s++;
  801980:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801983:	0f b6 01             	movzbl (%ecx),%eax
  801986:	3c 20                	cmp    $0x20,%al
  801988:	74 f6                	je     801980 <strtol+0xe>
  80198a:	3c 09                	cmp    $0x9,%al
  80198c:	74 f2                	je     801980 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80198e:	3c 2b                	cmp    $0x2b,%al
  801990:	75 0a                	jne    80199c <strtol+0x2a>
		s++;
  801992:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801995:	bf 00 00 00 00       	mov    $0x0,%edi
  80199a:	eb 11                	jmp    8019ad <strtol+0x3b>
  80199c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8019a1:	3c 2d                	cmp    $0x2d,%al
  8019a3:	75 08                	jne    8019ad <strtol+0x3b>
		s++, neg = 1;
  8019a5:	83 c1 01             	add    $0x1,%ecx
  8019a8:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019ad:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8019b3:	75 15                	jne    8019ca <strtol+0x58>
  8019b5:	80 39 30             	cmpb   $0x30,(%ecx)
  8019b8:	75 10                	jne    8019ca <strtol+0x58>
  8019ba:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8019be:	75 7c                	jne    801a3c <strtol+0xca>
		s += 2, base = 16;
  8019c0:	83 c1 02             	add    $0x2,%ecx
  8019c3:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019c8:	eb 16                	jmp    8019e0 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8019ca:	85 db                	test   %ebx,%ebx
  8019cc:	75 12                	jne    8019e0 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8019ce:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019d3:	80 39 30             	cmpb   $0x30,(%ecx)
  8019d6:	75 08                	jne    8019e0 <strtol+0x6e>
		s++, base = 8;
  8019d8:	83 c1 01             	add    $0x1,%ecx
  8019db:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8019e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8019e5:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8019e8:	0f b6 11             	movzbl (%ecx),%edx
  8019eb:	8d 72 d0             	lea    -0x30(%edx),%esi
  8019ee:	89 f3                	mov    %esi,%ebx
  8019f0:	80 fb 09             	cmp    $0x9,%bl
  8019f3:	77 08                	ja     8019fd <strtol+0x8b>
			dig = *s - '0';
  8019f5:	0f be d2             	movsbl %dl,%edx
  8019f8:	83 ea 30             	sub    $0x30,%edx
  8019fb:	eb 22                	jmp    801a1f <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8019fd:	8d 72 9f             	lea    -0x61(%edx),%esi
  801a00:	89 f3                	mov    %esi,%ebx
  801a02:	80 fb 19             	cmp    $0x19,%bl
  801a05:	77 08                	ja     801a0f <strtol+0x9d>
			dig = *s - 'a' + 10;
  801a07:	0f be d2             	movsbl %dl,%edx
  801a0a:	83 ea 57             	sub    $0x57,%edx
  801a0d:	eb 10                	jmp    801a1f <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801a0f:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a12:	89 f3                	mov    %esi,%ebx
  801a14:	80 fb 19             	cmp    $0x19,%bl
  801a17:	77 16                	ja     801a2f <strtol+0xbd>
			dig = *s - 'A' + 10;
  801a19:	0f be d2             	movsbl %dl,%edx
  801a1c:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801a1f:	3b 55 10             	cmp    0x10(%ebp),%edx
  801a22:	7d 0b                	jge    801a2f <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801a24:	83 c1 01             	add    $0x1,%ecx
  801a27:	0f af 45 10          	imul   0x10(%ebp),%eax
  801a2b:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801a2d:	eb b9                	jmp    8019e8 <strtol+0x76>

	if (endptr)
  801a2f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a33:	74 0d                	je     801a42 <strtol+0xd0>
		*endptr = (char *) s;
  801a35:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a38:	89 0e                	mov    %ecx,(%esi)
  801a3a:	eb 06                	jmp    801a42 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801a3c:	85 db                	test   %ebx,%ebx
  801a3e:	74 98                	je     8019d8 <strtol+0x66>
  801a40:	eb 9e                	jmp    8019e0 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801a42:	89 c2                	mov    %eax,%edx
  801a44:	f7 da                	neg    %edx
  801a46:	85 ff                	test   %edi,%edi
  801a48:	0f 45 c2             	cmovne %edx,%eax
}
  801a4b:	5b                   	pop    %ebx
  801a4c:	5e                   	pop    %esi
  801a4d:	5f                   	pop    %edi
  801a4e:	5d                   	pop    %ebp
  801a4f:	c3                   	ret    

00801a50 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a50:	55                   	push   %ebp
  801a51:	89 e5                	mov    %esp,%ebp
  801a53:	56                   	push   %esi
  801a54:	53                   	push   %ebx
  801a55:	8b 75 08             	mov    0x8(%ebp),%esi
  801a58:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a5b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int ret;
	if (pg) ret = sys_ipc_recv(pg);
  801a5e:	85 c0                	test   %eax,%eax
  801a60:	74 0e                	je     801a70 <ipc_recv+0x20>
  801a62:	83 ec 0c             	sub    $0xc,%esp
  801a65:	50                   	push   %eax
  801a66:	e8 9a e8 ff ff       	call   800305 <sys_ipc_recv>
  801a6b:	83 c4 10             	add    $0x10,%esp
  801a6e:	eb 10                	jmp    801a80 <ipc_recv+0x30>
	else ret = sys_ipc_recv((void*)UTOP);
  801a70:	83 ec 0c             	sub    $0xc,%esp
  801a73:	68 00 00 c0 ee       	push   $0xeec00000
  801a78:	e8 88 e8 ff ff       	call   800305 <sys_ipc_recv>
  801a7d:	83 c4 10             	add    $0x10,%esp
	if (ret) {
  801a80:	85 c0                	test   %eax,%eax
  801a82:	74 16                	je     801a9a <ipc_recv+0x4a>
		if (from_env_store) *from_env_store = 0;
  801a84:	85 f6                	test   %esi,%esi
  801a86:	74 06                	je     801a8e <ipc_recv+0x3e>
  801a88:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  801a8e:	85 db                	test   %ebx,%ebx
  801a90:	74 2c                	je     801abe <ipc_recv+0x6e>
  801a92:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801a98:	eb 24                	jmp    801abe <ipc_recv+0x6e>
		return ret;
	}
	if (from_env_store) *from_env_store = thisenv->env_ipc_from;
  801a9a:	85 f6                	test   %esi,%esi
  801a9c:	74 0a                	je     801aa8 <ipc_recv+0x58>
  801a9e:	a1 04 40 80 00       	mov    0x804004,%eax
  801aa3:	8b 40 74             	mov    0x74(%eax),%eax
  801aa6:	89 06                	mov    %eax,(%esi)
	if (perm_store) *perm_store = thisenv->env_ipc_perm;
  801aa8:	85 db                	test   %ebx,%ebx
  801aaa:	74 0a                	je     801ab6 <ipc_recv+0x66>
  801aac:	a1 04 40 80 00       	mov    0x804004,%eax
  801ab1:	8b 40 78             	mov    0x78(%eax),%eax
  801ab4:	89 03                	mov    %eax,(%ebx)

	// panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801ab6:	a1 04 40 80 00       	mov    0x804004,%eax
  801abb:	8b 40 70             	mov    0x70(%eax),%eax
}
  801abe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ac1:	5b                   	pop    %ebx
  801ac2:	5e                   	pop    %esi
  801ac3:	5d                   	pop    %ebp
  801ac4:	c3                   	ret    

00801ac5 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ac5:	55                   	push   %ebp
  801ac6:	89 e5                	mov    %esp,%ebp
  801ac8:	57                   	push   %edi
  801ac9:	56                   	push   %esi
  801aca:	53                   	push   %ebx
  801acb:	83 ec 0c             	sub    $0xc,%esp
  801ace:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ad1:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ad4:	8b 45 10             	mov    0x10(%ebp),%eax
  801ad7:	85 c0                	test   %eax,%eax
  801ad9:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801ade:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	while (true) {
		void* srcva = (pg)? pg: (void*)UTOP;
		int ret = sys_ipc_try_send(to_env, val, srcva, perm);
  801ae1:	ff 75 14             	pushl  0x14(%ebp)
  801ae4:	53                   	push   %ebx
  801ae5:	56                   	push   %esi
  801ae6:	57                   	push   %edi
  801ae7:	e8 f6 e7 ff ff       	call   8002e2 <sys_ipc_try_send>
		if (ret == 0) break;
  801aec:	83 c4 10             	add    $0x10,%esp
  801aef:	85 c0                	test   %eax,%eax
  801af1:	74 1e                	je     801b11 <ipc_send+0x4c>
		if (ret != -E_IPC_NOT_RECV) panic("ipc_send: %e", ret);
  801af3:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801af6:	74 12                	je     801b0a <ipc_send+0x45>
  801af8:	50                   	push   %eax
  801af9:	68 80 22 80 00       	push   $0x802280
  801afe:	6a 39                	push   $0x39
  801b00:	68 8d 22 80 00       	push   $0x80228d
  801b05:	e8 fa f4 ff ff       	call   801004 <_panic>
		sys_yield();
  801b0a:	e8 27 e6 ff ff       	call   800136 <sys_yield>
	}
  801b0f:	eb d0                	jmp    801ae1 <ipc_send+0x1c>
	// panic("ipc_send not implemented");
}
  801b11:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b14:	5b                   	pop    %ebx
  801b15:	5e                   	pop    %esi
  801b16:	5f                   	pop    %edi
  801b17:	5d                   	pop    %ebp
  801b18:	c3                   	ret    

00801b19 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b19:	55                   	push   %ebp
  801b1a:	89 e5                	mov    %esp,%ebp
  801b1c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b1f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b24:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b27:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b2d:	8b 52 50             	mov    0x50(%edx),%edx
  801b30:	39 ca                	cmp    %ecx,%edx
  801b32:	75 0d                	jne    801b41 <ipc_find_env+0x28>
			return envs[i].env_id;
  801b34:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b37:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b3c:	8b 40 48             	mov    0x48(%eax),%eax
  801b3f:	eb 0f                	jmp    801b50 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b41:	83 c0 01             	add    $0x1,%eax
  801b44:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b49:	75 d9                	jne    801b24 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b4b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b50:	5d                   	pop    %ebp
  801b51:	c3                   	ret    

00801b52 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b52:	55                   	push   %ebp
  801b53:	89 e5                	mov    %esp,%ebp
  801b55:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b58:	89 d0                	mov    %edx,%eax
  801b5a:	c1 e8 16             	shr    $0x16,%eax
  801b5d:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b64:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b69:	f6 c1 01             	test   $0x1,%cl
  801b6c:	74 1d                	je     801b8b <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b6e:	c1 ea 0c             	shr    $0xc,%edx
  801b71:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b78:	f6 c2 01             	test   $0x1,%dl
  801b7b:	74 0e                	je     801b8b <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b7d:	c1 ea 0c             	shr    $0xc,%edx
  801b80:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b87:	ef 
  801b88:	0f b7 c0             	movzwl %ax,%eax
}
  801b8b:	5d                   	pop    %ebp
  801b8c:	c3                   	ret    
  801b8d:	66 90                	xchg   %ax,%ax
  801b8f:	90                   	nop

00801b90 <__udivdi3>:
  801b90:	55                   	push   %ebp
  801b91:	57                   	push   %edi
  801b92:	56                   	push   %esi
  801b93:	53                   	push   %ebx
  801b94:	83 ec 1c             	sub    $0x1c,%esp
  801b97:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801b9b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801b9f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801ba3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801ba7:	85 f6                	test   %esi,%esi
  801ba9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bad:	89 ca                	mov    %ecx,%edx
  801baf:	89 f8                	mov    %edi,%eax
  801bb1:	75 3d                	jne    801bf0 <__udivdi3+0x60>
  801bb3:	39 cf                	cmp    %ecx,%edi
  801bb5:	0f 87 c5 00 00 00    	ja     801c80 <__udivdi3+0xf0>
  801bbb:	85 ff                	test   %edi,%edi
  801bbd:	89 fd                	mov    %edi,%ebp
  801bbf:	75 0b                	jne    801bcc <__udivdi3+0x3c>
  801bc1:	b8 01 00 00 00       	mov    $0x1,%eax
  801bc6:	31 d2                	xor    %edx,%edx
  801bc8:	f7 f7                	div    %edi
  801bca:	89 c5                	mov    %eax,%ebp
  801bcc:	89 c8                	mov    %ecx,%eax
  801bce:	31 d2                	xor    %edx,%edx
  801bd0:	f7 f5                	div    %ebp
  801bd2:	89 c1                	mov    %eax,%ecx
  801bd4:	89 d8                	mov    %ebx,%eax
  801bd6:	89 cf                	mov    %ecx,%edi
  801bd8:	f7 f5                	div    %ebp
  801bda:	89 c3                	mov    %eax,%ebx
  801bdc:	89 d8                	mov    %ebx,%eax
  801bde:	89 fa                	mov    %edi,%edx
  801be0:	83 c4 1c             	add    $0x1c,%esp
  801be3:	5b                   	pop    %ebx
  801be4:	5e                   	pop    %esi
  801be5:	5f                   	pop    %edi
  801be6:	5d                   	pop    %ebp
  801be7:	c3                   	ret    
  801be8:	90                   	nop
  801be9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801bf0:	39 ce                	cmp    %ecx,%esi
  801bf2:	77 74                	ja     801c68 <__udivdi3+0xd8>
  801bf4:	0f bd fe             	bsr    %esi,%edi
  801bf7:	83 f7 1f             	xor    $0x1f,%edi
  801bfa:	0f 84 98 00 00 00    	je     801c98 <__udivdi3+0x108>
  801c00:	bb 20 00 00 00       	mov    $0x20,%ebx
  801c05:	89 f9                	mov    %edi,%ecx
  801c07:	89 c5                	mov    %eax,%ebp
  801c09:	29 fb                	sub    %edi,%ebx
  801c0b:	d3 e6                	shl    %cl,%esi
  801c0d:	89 d9                	mov    %ebx,%ecx
  801c0f:	d3 ed                	shr    %cl,%ebp
  801c11:	89 f9                	mov    %edi,%ecx
  801c13:	d3 e0                	shl    %cl,%eax
  801c15:	09 ee                	or     %ebp,%esi
  801c17:	89 d9                	mov    %ebx,%ecx
  801c19:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c1d:	89 d5                	mov    %edx,%ebp
  801c1f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801c23:	d3 ed                	shr    %cl,%ebp
  801c25:	89 f9                	mov    %edi,%ecx
  801c27:	d3 e2                	shl    %cl,%edx
  801c29:	89 d9                	mov    %ebx,%ecx
  801c2b:	d3 e8                	shr    %cl,%eax
  801c2d:	09 c2                	or     %eax,%edx
  801c2f:	89 d0                	mov    %edx,%eax
  801c31:	89 ea                	mov    %ebp,%edx
  801c33:	f7 f6                	div    %esi
  801c35:	89 d5                	mov    %edx,%ebp
  801c37:	89 c3                	mov    %eax,%ebx
  801c39:	f7 64 24 0c          	mull   0xc(%esp)
  801c3d:	39 d5                	cmp    %edx,%ebp
  801c3f:	72 10                	jb     801c51 <__udivdi3+0xc1>
  801c41:	8b 74 24 08          	mov    0x8(%esp),%esi
  801c45:	89 f9                	mov    %edi,%ecx
  801c47:	d3 e6                	shl    %cl,%esi
  801c49:	39 c6                	cmp    %eax,%esi
  801c4b:	73 07                	jae    801c54 <__udivdi3+0xc4>
  801c4d:	39 d5                	cmp    %edx,%ebp
  801c4f:	75 03                	jne    801c54 <__udivdi3+0xc4>
  801c51:	83 eb 01             	sub    $0x1,%ebx
  801c54:	31 ff                	xor    %edi,%edi
  801c56:	89 d8                	mov    %ebx,%eax
  801c58:	89 fa                	mov    %edi,%edx
  801c5a:	83 c4 1c             	add    $0x1c,%esp
  801c5d:	5b                   	pop    %ebx
  801c5e:	5e                   	pop    %esi
  801c5f:	5f                   	pop    %edi
  801c60:	5d                   	pop    %ebp
  801c61:	c3                   	ret    
  801c62:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c68:	31 ff                	xor    %edi,%edi
  801c6a:	31 db                	xor    %ebx,%ebx
  801c6c:	89 d8                	mov    %ebx,%eax
  801c6e:	89 fa                	mov    %edi,%edx
  801c70:	83 c4 1c             	add    $0x1c,%esp
  801c73:	5b                   	pop    %ebx
  801c74:	5e                   	pop    %esi
  801c75:	5f                   	pop    %edi
  801c76:	5d                   	pop    %ebp
  801c77:	c3                   	ret    
  801c78:	90                   	nop
  801c79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c80:	89 d8                	mov    %ebx,%eax
  801c82:	f7 f7                	div    %edi
  801c84:	31 ff                	xor    %edi,%edi
  801c86:	89 c3                	mov    %eax,%ebx
  801c88:	89 d8                	mov    %ebx,%eax
  801c8a:	89 fa                	mov    %edi,%edx
  801c8c:	83 c4 1c             	add    $0x1c,%esp
  801c8f:	5b                   	pop    %ebx
  801c90:	5e                   	pop    %esi
  801c91:	5f                   	pop    %edi
  801c92:	5d                   	pop    %ebp
  801c93:	c3                   	ret    
  801c94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c98:	39 ce                	cmp    %ecx,%esi
  801c9a:	72 0c                	jb     801ca8 <__udivdi3+0x118>
  801c9c:	31 db                	xor    %ebx,%ebx
  801c9e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801ca2:	0f 87 34 ff ff ff    	ja     801bdc <__udivdi3+0x4c>
  801ca8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801cad:	e9 2a ff ff ff       	jmp    801bdc <__udivdi3+0x4c>
  801cb2:	66 90                	xchg   %ax,%ax
  801cb4:	66 90                	xchg   %ax,%ax
  801cb6:	66 90                	xchg   %ax,%ax
  801cb8:	66 90                	xchg   %ax,%ax
  801cba:	66 90                	xchg   %ax,%ax
  801cbc:	66 90                	xchg   %ax,%ax
  801cbe:	66 90                	xchg   %ax,%ax

00801cc0 <__umoddi3>:
  801cc0:	55                   	push   %ebp
  801cc1:	57                   	push   %edi
  801cc2:	56                   	push   %esi
  801cc3:	53                   	push   %ebx
  801cc4:	83 ec 1c             	sub    $0x1c,%esp
  801cc7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801ccb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801ccf:	8b 74 24 34          	mov    0x34(%esp),%esi
  801cd3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801cd7:	85 d2                	test   %edx,%edx
  801cd9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801cdd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ce1:	89 f3                	mov    %esi,%ebx
  801ce3:	89 3c 24             	mov    %edi,(%esp)
  801ce6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cea:	75 1c                	jne    801d08 <__umoddi3+0x48>
  801cec:	39 f7                	cmp    %esi,%edi
  801cee:	76 50                	jbe    801d40 <__umoddi3+0x80>
  801cf0:	89 c8                	mov    %ecx,%eax
  801cf2:	89 f2                	mov    %esi,%edx
  801cf4:	f7 f7                	div    %edi
  801cf6:	89 d0                	mov    %edx,%eax
  801cf8:	31 d2                	xor    %edx,%edx
  801cfa:	83 c4 1c             	add    $0x1c,%esp
  801cfd:	5b                   	pop    %ebx
  801cfe:	5e                   	pop    %esi
  801cff:	5f                   	pop    %edi
  801d00:	5d                   	pop    %ebp
  801d01:	c3                   	ret    
  801d02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d08:	39 f2                	cmp    %esi,%edx
  801d0a:	89 d0                	mov    %edx,%eax
  801d0c:	77 52                	ja     801d60 <__umoddi3+0xa0>
  801d0e:	0f bd ea             	bsr    %edx,%ebp
  801d11:	83 f5 1f             	xor    $0x1f,%ebp
  801d14:	75 5a                	jne    801d70 <__umoddi3+0xb0>
  801d16:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801d1a:	0f 82 e0 00 00 00    	jb     801e00 <__umoddi3+0x140>
  801d20:	39 0c 24             	cmp    %ecx,(%esp)
  801d23:	0f 86 d7 00 00 00    	jbe    801e00 <__umoddi3+0x140>
  801d29:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d2d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d31:	83 c4 1c             	add    $0x1c,%esp
  801d34:	5b                   	pop    %ebx
  801d35:	5e                   	pop    %esi
  801d36:	5f                   	pop    %edi
  801d37:	5d                   	pop    %ebp
  801d38:	c3                   	ret    
  801d39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d40:	85 ff                	test   %edi,%edi
  801d42:	89 fd                	mov    %edi,%ebp
  801d44:	75 0b                	jne    801d51 <__umoddi3+0x91>
  801d46:	b8 01 00 00 00       	mov    $0x1,%eax
  801d4b:	31 d2                	xor    %edx,%edx
  801d4d:	f7 f7                	div    %edi
  801d4f:	89 c5                	mov    %eax,%ebp
  801d51:	89 f0                	mov    %esi,%eax
  801d53:	31 d2                	xor    %edx,%edx
  801d55:	f7 f5                	div    %ebp
  801d57:	89 c8                	mov    %ecx,%eax
  801d59:	f7 f5                	div    %ebp
  801d5b:	89 d0                	mov    %edx,%eax
  801d5d:	eb 99                	jmp    801cf8 <__umoddi3+0x38>
  801d5f:	90                   	nop
  801d60:	89 c8                	mov    %ecx,%eax
  801d62:	89 f2                	mov    %esi,%edx
  801d64:	83 c4 1c             	add    $0x1c,%esp
  801d67:	5b                   	pop    %ebx
  801d68:	5e                   	pop    %esi
  801d69:	5f                   	pop    %edi
  801d6a:	5d                   	pop    %ebp
  801d6b:	c3                   	ret    
  801d6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d70:	8b 34 24             	mov    (%esp),%esi
  801d73:	bf 20 00 00 00       	mov    $0x20,%edi
  801d78:	89 e9                	mov    %ebp,%ecx
  801d7a:	29 ef                	sub    %ebp,%edi
  801d7c:	d3 e0                	shl    %cl,%eax
  801d7e:	89 f9                	mov    %edi,%ecx
  801d80:	89 f2                	mov    %esi,%edx
  801d82:	d3 ea                	shr    %cl,%edx
  801d84:	89 e9                	mov    %ebp,%ecx
  801d86:	09 c2                	or     %eax,%edx
  801d88:	89 d8                	mov    %ebx,%eax
  801d8a:	89 14 24             	mov    %edx,(%esp)
  801d8d:	89 f2                	mov    %esi,%edx
  801d8f:	d3 e2                	shl    %cl,%edx
  801d91:	89 f9                	mov    %edi,%ecx
  801d93:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d97:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801d9b:	d3 e8                	shr    %cl,%eax
  801d9d:	89 e9                	mov    %ebp,%ecx
  801d9f:	89 c6                	mov    %eax,%esi
  801da1:	d3 e3                	shl    %cl,%ebx
  801da3:	89 f9                	mov    %edi,%ecx
  801da5:	89 d0                	mov    %edx,%eax
  801da7:	d3 e8                	shr    %cl,%eax
  801da9:	89 e9                	mov    %ebp,%ecx
  801dab:	09 d8                	or     %ebx,%eax
  801dad:	89 d3                	mov    %edx,%ebx
  801daf:	89 f2                	mov    %esi,%edx
  801db1:	f7 34 24             	divl   (%esp)
  801db4:	89 d6                	mov    %edx,%esi
  801db6:	d3 e3                	shl    %cl,%ebx
  801db8:	f7 64 24 04          	mull   0x4(%esp)
  801dbc:	39 d6                	cmp    %edx,%esi
  801dbe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801dc2:	89 d1                	mov    %edx,%ecx
  801dc4:	89 c3                	mov    %eax,%ebx
  801dc6:	72 08                	jb     801dd0 <__umoddi3+0x110>
  801dc8:	75 11                	jne    801ddb <__umoddi3+0x11b>
  801dca:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801dce:	73 0b                	jae    801ddb <__umoddi3+0x11b>
  801dd0:	2b 44 24 04          	sub    0x4(%esp),%eax
  801dd4:	1b 14 24             	sbb    (%esp),%edx
  801dd7:	89 d1                	mov    %edx,%ecx
  801dd9:	89 c3                	mov    %eax,%ebx
  801ddb:	8b 54 24 08          	mov    0x8(%esp),%edx
  801ddf:	29 da                	sub    %ebx,%edx
  801de1:	19 ce                	sbb    %ecx,%esi
  801de3:	89 f9                	mov    %edi,%ecx
  801de5:	89 f0                	mov    %esi,%eax
  801de7:	d3 e0                	shl    %cl,%eax
  801de9:	89 e9                	mov    %ebp,%ecx
  801deb:	d3 ea                	shr    %cl,%edx
  801ded:	89 e9                	mov    %ebp,%ecx
  801def:	d3 ee                	shr    %cl,%esi
  801df1:	09 d0                	or     %edx,%eax
  801df3:	89 f2                	mov    %esi,%edx
  801df5:	83 c4 1c             	add    $0x1c,%esp
  801df8:	5b                   	pop    %ebx
  801df9:	5e                   	pop    %esi
  801dfa:	5f                   	pop    %edi
  801dfb:	5d                   	pop    %ebp
  801dfc:	c3                   	ret    
  801dfd:	8d 76 00             	lea    0x0(%esi),%esi
  801e00:	29 f9                	sub    %edi,%ecx
  801e02:	19 d6                	sbb    %edx,%esi
  801e04:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e08:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e0c:	e9 18 ff ff ff       	jmp    801d29 <__umoddi3+0x69>
