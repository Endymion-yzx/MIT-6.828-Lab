
obj/user/faultbadhandler.debug:     file format elf32-i386


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
  80002c:	e8 34 00 00 00       	call   800065 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 0c             	sub    $0xc,%esp
	sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  800039:	6a 07                	push   $0x7
  80003b:	68 00 f0 bf ee       	push   $0xeebff000
  800040:	6a 00                	push   $0x0
  800042:	e8 3a 01 00 00       	call   800181 <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xDeadBeef);
  800047:	83 c4 08             	add    $0x8,%esp
  80004a:	68 ef be ad de       	push   $0xdeadbeef
  80004f:	6a 00                	push   $0x0
  800051:	e8 76 02 00 00       	call   8002cc <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800056:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80005d:	00 00 00 
}
  800060:	83 c4 10             	add    $0x10,%esp
  800063:	c9                   	leave  
  800064:	c3                   	ret    

00800065 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800065:	55                   	push   %ebp
  800066:	89 e5                	mov    %esp,%ebp
  800068:	56                   	push   %esi
  800069:	53                   	push   %ebx
  80006a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80006d:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	envid_t envid = sys_getenvid();
  800070:	e8 ce 00 00 00       	call   800143 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  800075:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80007d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800082:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800087:	85 db                	test   %ebx,%ebx
  800089:	7e 07                	jle    800092 <libmain+0x2d>
		binaryname = argv[0];
  80008b:	8b 06                	mov    (%esi),%eax
  80008d:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800092:	83 ec 08             	sub    $0x8,%esp
  800095:	56                   	push   %esi
  800096:	53                   	push   %ebx
  800097:	e8 97 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80009c:	e8 0a 00 00 00       	call   8000ab <exit>
}
  8000a1:	83 c4 10             	add    $0x10,%esp
  8000a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a7:	5b                   	pop    %ebx
  8000a8:	5e                   	pop    %esi
  8000a9:	5d                   	pop    %ebp
  8000aa:	c3                   	ret    

008000ab <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ab:	55                   	push   %ebp
  8000ac:	89 e5                	mov    %esp,%ebp
  8000ae:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000b1:	e8 87 04 00 00       	call   80053d <close_all>
	sys_env_destroy(0);
  8000b6:	83 ec 0c             	sub    $0xc,%esp
  8000b9:	6a 00                	push   $0x0
  8000bb:	e8 42 00 00 00       	call   800102 <sys_env_destroy>
}
  8000c0:	83 c4 10             	add    $0x10,%esp
  8000c3:	c9                   	leave  
  8000c4:	c3                   	ret    

008000c5 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000c5:	55                   	push   %ebp
  8000c6:	89 e5                	mov    %esp,%ebp
  8000c8:	57                   	push   %edi
  8000c9:	56                   	push   %esi
  8000ca:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8000d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000d3:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d6:	89 c3                	mov    %eax,%ebx
  8000d8:	89 c7                	mov    %eax,%edi
  8000da:	89 c6                	mov    %eax,%esi
  8000dc:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000de:	5b                   	pop    %ebx
  8000df:	5e                   	pop    %esi
  8000e0:	5f                   	pop    %edi
  8000e1:	5d                   	pop    %ebp
  8000e2:	c3                   	ret    

008000e3 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000e3:	55                   	push   %ebp
  8000e4:	89 e5                	mov    %esp,%ebp
  8000e6:	57                   	push   %edi
  8000e7:	56                   	push   %esi
  8000e8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8000ee:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f3:	89 d1                	mov    %edx,%ecx
  8000f5:	89 d3                	mov    %edx,%ebx
  8000f7:	89 d7                	mov    %edx,%edi
  8000f9:	89 d6                	mov    %edx,%esi
  8000fb:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000fd:	5b                   	pop    %ebx
  8000fe:	5e                   	pop    %esi
  8000ff:	5f                   	pop    %edi
  800100:	5d                   	pop    %ebp
  800101:	c3                   	ret    

00800102 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800102:	55                   	push   %ebp
  800103:	89 e5                	mov    %esp,%ebp
  800105:	57                   	push   %edi
  800106:	56                   	push   %esi
  800107:	53                   	push   %ebx
  800108:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80010b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800110:	b8 03 00 00 00       	mov    $0x3,%eax
  800115:	8b 55 08             	mov    0x8(%ebp),%edx
  800118:	89 cb                	mov    %ecx,%ebx
  80011a:	89 cf                	mov    %ecx,%edi
  80011c:	89 ce                	mov    %ecx,%esi
  80011e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800120:	85 c0                	test   %eax,%eax
  800122:	7e 17                	jle    80013b <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800124:	83 ec 0c             	sub    $0xc,%esp
  800127:	50                   	push   %eax
  800128:	6a 03                	push   $0x3
  80012a:	68 6a 1e 80 00       	push   $0x801e6a
  80012f:	6a 23                	push   $0x23
  800131:	68 87 1e 80 00       	push   $0x801e87
  800136:	e8 f5 0e 00 00       	call   801030 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80013b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80013e:	5b                   	pop    %ebx
  80013f:	5e                   	pop    %esi
  800140:	5f                   	pop    %edi
  800141:	5d                   	pop    %ebp
  800142:	c3                   	ret    

00800143 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	57                   	push   %edi
  800147:	56                   	push   %esi
  800148:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800149:	ba 00 00 00 00       	mov    $0x0,%edx
  80014e:	b8 02 00 00 00       	mov    $0x2,%eax
  800153:	89 d1                	mov    %edx,%ecx
  800155:	89 d3                	mov    %edx,%ebx
  800157:	89 d7                	mov    %edx,%edi
  800159:	89 d6                	mov    %edx,%esi
  80015b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80015d:	5b                   	pop    %ebx
  80015e:	5e                   	pop    %esi
  80015f:	5f                   	pop    %edi
  800160:	5d                   	pop    %ebp
  800161:	c3                   	ret    

00800162 <sys_yield>:

void
sys_yield(void)
{
  800162:	55                   	push   %ebp
  800163:	89 e5                	mov    %esp,%ebp
  800165:	57                   	push   %edi
  800166:	56                   	push   %esi
  800167:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800168:	ba 00 00 00 00       	mov    $0x0,%edx
  80016d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800172:	89 d1                	mov    %edx,%ecx
  800174:	89 d3                	mov    %edx,%ebx
  800176:	89 d7                	mov    %edx,%edi
  800178:	89 d6                	mov    %edx,%esi
  80017a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80017c:	5b                   	pop    %ebx
  80017d:	5e                   	pop    %esi
  80017e:	5f                   	pop    %edi
  80017f:	5d                   	pop    %ebp
  800180:	c3                   	ret    

00800181 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800181:	55                   	push   %ebp
  800182:	89 e5                	mov    %esp,%ebp
  800184:	57                   	push   %edi
  800185:	56                   	push   %esi
  800186:	53                   	push   %ebx
  800187:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80018a:	be 00 00 00 00       	mov    $0x0,%esi
  80018f:	b8 04 00 00 00       	mov    $0x4,%eax
  800194:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800197:	8b 55 08             	mov    0x8(%ebp),%edx
  80019a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80019d:	89 f7                	mov    %esi,%edi
  80019f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001a1:	85 c0                	test   %eax,%eax
  8001a3:	7e 17                	jle    8001bc <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001a5:	83 ec 0c             	sub    $0xc,%esp
  8001a8:	50                   	push   %eax
  8001a9:	6a 04                	push   $0x4
  8001ab:	68 6a 1e 80 00       	push   $0x801e6a
  8001b0:	6a 23                	push   $0x23
  8001b2:	68 87 1e 80 00       	push   $0x801e87
  8001b7:	e8 74 0e 00 00       	call   801030 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001bf:	5b                   	pop    %ebx
  8001c0:	5e                   	pop    %esi
  8001c1:	5f                   	pop    %edi
  8001c2:	5d                   	pop    %ebp
  8001c3:	c3                   	ret    

008001c4 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001c4:	55                   	push   %ebp
  8001c5:	89 e5                	mov    %esp,%ebp
  8001c7:	57                   	push   %edi
  8001c8:	56                   	push   %esi
  8001c9:	53                   	push   %ebx
  8001ca:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001cd:	b8 05 00 00 00       	mov    $0x5,%eax
  8001d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001d5:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001db:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001de:	8b 75 18             	mov    0x18(%ebp),%esi
  8001e1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001e3:	85 c0                	test   %eax,%eax
  8001e5:	7e 17                	jle    8001fe <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001e7:	83 ec 0c             	sub    $0xc,%esp
  8001ea:	50                   	push   %eax
  8001eb:	6a 05                	push   $0x5
  8001ed:	68 6a 1e 80 00       	push   $0x801e6a
  8001f2:	6a 23                	push   $0x23
  8001f4:	68 87 1e 80 00       	push   $0x801e87
  8001f9:	e8 32 0e 00 00       	call   801030 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800201:	5b                   	pop    %ebx
  800202:	5e                   	pop    %esi
  800203:	5f                   	pop    %edi
  800204:	5d                   	pop    %ebp
  800205:	c3                   	ret    

00800206 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800206:	55                   	push   %ebp
  800207:	89 e5                	mov    %esp,%ebp
  800209:	57                   	push   %edi
  80020a:	56                   	push   %esi
  80020b:	53                   	push   %ebx
  80020c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80020f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800214:	b8 06 00 00 00       	mov    $0x6,%eax
  800219:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80021c:	8b 55 08             	mov    0x8(%ebp),%edx
  80021f:	89 df                	mov    %ebx,%edi
  800221:	89 de                	mov    %ebx,%esi
  800223:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800225:	85 c0                	test   %eax,%eax
  800227:	7e 17                	jle    800240 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800229:	83 ec 0c             	sub    $0xc,%esp
  80022c:	50                   	push   %eax
  80022d:	6a 06                	push   $0x6
  80022f:	68 6a 1e 80 00       	push   $0x801e6a
  800234:	6a 23                	push   $0x23
  800236:	68 87 1e 80 00       	push   $0x801e87
  80023b:	e8 f0 0d 00 00       	call   801030 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800240:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800243:	5b                   	pop    %ebx
  800244:	5e                   	pop    %esi
  800245:	5f                   	pop    %edi
  800246:	5d                   	pop    %ebp
  800247:	c3                   	ret    

00800248 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800248:	55                   	push   %ebp
  800249:	89 e5                	mov    %esp,%ebp
  80024b:	57                   	push   %edi
  80024c:	56                   	push   %esi
  80024d:	53                   	push   %ebx
  80024e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800251:	bb 00 00 00 00       	mov    $0x0,%ebx
  800256:	b8 08 00 00 00       	mov    $0x8,%eax
  80025b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80025e:	8b 55 08             	mov    0x8(%ebp),%edx
  800261:	89 df                	mov    %ebx,%edi
  800263:	89 de                	mov    %ebx,%esi
  800265:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800267:	85 c0                	test   %eax,%eax
  800269:	7e 17                	jle    800282 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80026b:	83 ec 0c             	sub    $0xc,%esp
  80026e:	50                   	push   %eax
  80026f:	6a 08                	push   $0x8
  800271:	68 6a 1e 80 00       	push   $0x801e6a
  800276:	6a 23                	push   $0x23
  800278:	68 87 1e 80 00       	push   $0x801e87
  80027d:	e8 ae 0d 00 00       	call   801030 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800282:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800285:	5b                   	pop    %ebx
  800286:	5e                   	pop    %esi
  800287:	5f                   	pop    %edi
  800288:	5d                   	pop    %ebp
  800289:	c3                   	ret    

0080028a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	57                   	push   %edi
  80028e:	56                   	push   %esi
  80028f:	53                   	push   %ebx
  800290:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800293:	bb 00 00 00 00       	mov    $0x0,%ebx
  800298:	b8 09 00 00 00       	mov    $0x9,%eax
  80029d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a3:	89 df                	mov    %ebx,%edi
  8002a5:	89 de                	mov    %ebx,%esi
  8002a7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002a9:	85 c0                	test   %eax,%eax
  8002ab:	7e 17                	jle    8002c4 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ad:	83 ec 0c             	sub    $0xc,%esp
  8002b0:	50                   	push   %eax
  8002b1:	6a 09                	push   $0x9
  8002b3:	68 6a 1e 80 00       	push   $0x801e6a
  8002b8:	6a 23                	push   $0x23
  8002ba:	68 87 1e 80 00       	push   $0x801e87
  8002bf:	e8 6c 0d 00 00       	call   801030 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c7:	5b                   	pop    %ebx
  8002c8:	5e                   	pop    %esi
  8002c9:	5f                   	pop    %edi
  8002ca:	5d                   	pop    %ebp
  8002cb:	c3                   	ret    

008002cc <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	57                   	push   %edi
  8002d0:	56                   	push   %esi
  8002d1:	53                   	push   %ebx
  8002d2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002d5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002da:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002e2:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e5:	89 df                	mov    %ebx,%edi
  8002e7:	89 de                	mov    %ebx,%esi
  8002e9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002eb:	85 c0                	test   %eax,%eax
  8002ed:	7e 17                	jle    800306 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ef:	83 ec 0c             	sub    $0xc,%esp
  8002f2:	50                   	push   %eax
  8002f3:	6a 0a                	push   $0xa
  8002f5:	68 6a 1e 80 00       	push   $0x801e6a
  8002fa:	6a 23                	push   $0x23
  8002fc:	68 87 1e 80 00       	push   $0x801e87
  800301:	e8 2a 0d 00 00       	call   801030 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800306:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800309:	5b                   	pop    %ebx
  80030a:	5e                   	pop    %esi
  80030b:	5f                   	pop    %edi
  80030c:	5d                   	pop    %ebp
  80030d:	c3                   	ret    

0080030e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80030e:	55                   	push   %ebp
  80030f:	89 e5                	mov    %esp,%ebp
  800311:	57                   	push   %edi
  800312:	56                   	push   %esi
  800313:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800314:	be 00 00 00 00       	mov    $0x0,%esi
  800319:	b8 0c 00 00 00       	mov    $0xc,%eax
  80031e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800321:	8b 55 08             	mov    0x8(%ebp),%edx
  800324:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800327:	8b 7d 14             	mov    0x14(%ebp),%edi
  80032a:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80032c:	5b                   	pop    %ebx
  80032d:	5e                   	pop    %esi
  80032e:	5f                   	pop    %edi
  80032f:	5d                   	pop    %ebp
  800330:	c3                   	ret    

00800331 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800331:	55                   	push   %ebp
  800332:	89 e5                	mov    %esp,%ebp
  800334:	57                   	push   %edi
  800335:	56                   	push   %esi
  800336:	53                   	push   %ebx
  800337:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80033a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80033f:	b8 0d 00 00 00       	mov    $0xd,%eax
  800344:	8b 55 08             	mov    0x8(%ebp),%edx
  800347:	89 cb                	mov    %ecx,%ebx
  800349:	89 cf                	mov    %ecx,%edi
  80034b:	89 ce                	mov    %ecx,%esi
  80034d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80034f:	85 c0                	test   %eax,%eax
  800351:	7e 17                	jle    80036a <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800353:	83 ec 0c             	sub    $0xc,%esp
  800356:	50                   	push   %eax
  800357:	6a 0d                	push   $0xd
  800359:	68 6a 1e 80 00       	push   $0x801e6a
  80035e:	6a 23                	push   $0x23
  800360:	68 87 1e 80 00       	push   $0x801e87
  800365:	e8 c6 0c 00 00       	call   801030 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80036a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80036d:	5b                   	pop    %ebx
  80036e:	5e                   	pop    %esi
  80036f:	5f                   	pop    %edi
  800370:	5d                   	pop    %ebp
  800371:	c3                   	ret    

00800372 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800372:	55                   	push   %ebp
  800373:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800375:	8b 45 08             	mov    0x8(%ebp),%eax
  800378:	05 00 00 00 30       	add    $0x30000000,%eax
  80037d:	c1 e8 0c             	shr    $0xc,%eax
}
  800380:	5d                   	pop    %ebp
  800381:	c3                   	ret    

00800382 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800382:	55                   	push   %ebp
  800383:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800385:	8b 45 08             	mov    0x8(%ebp),%eax
  800388:	05 00 00 00 30       	add    $0x30000000,%eax
  80038d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800392:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800397:	5d                   	pop    %ebp
  800398:	c3                   	ret    

00800399 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800399:	55                   	push   %ebp
  80039a:	89 e5                	mov    %esp,%ebp
  80039c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80039f:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003a4:	89 c2                	mov    %eax,%edx
  8003a6:	c1 ea 16             	shr    $0x16,%edx
  8003a9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003b0:	f6 c2 01             	test   $0x1,%dl
  8003b3:	74 11                	je     8003c6 <fd_alloc+0x2d>
  8003b5:	89 c2                	mov    %eax,%edx
  8003b7:	c1 ea 0c             	shr    $0xc,%edx
  8003ba:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003c1:	f6 c2 01             	test   $0x1,%dl
  8003c4:	75 09                	jne    8003cf <fd_alloc+0x36>
			*fd_store = fd;
  8003c6:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8003cd:	eb 17                	jmp    8003e6 <fd_alloc+0x4d>
  8003cf:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003d4:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003d9:	75 c9                	jne    8003a4 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003db:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003e1:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003e6:	5d                   	pop    %ebp
  8003e7:	c3                   	ret    

008003e8 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003e8:	55                   	push   %ebp
  8003e9:	89 e5                	mov    %esp,%ebp
  8003eb:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003ee:	83 f8 1f             	cmp    $0x1f,%eax
  8003f1:	77 36                	ja     800429 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003f3:	c1 e0 0c             	shl    $0xc,%eax
  8003f6:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003fb:	89 c2                	mov    %eax,%edx
  8003fd:	c1 ea 16             	shr    $0x16,%edx
  800400:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800407:	f6 c2 01             	test   $0x1,%dl
  80040a:	74 24                	je     800430 <fd_lookup+0x48>
  80040c:	89 c2                	mov    %eax,%edx
  80040e:	c1 ea 0c             	shr    $0xc,%edx
  800411:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800418:	f6 c2 01             	test   $0x1,%dl
  80041b:	74 1a                	je     800437 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80041d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800420:	89 02                	mov    %eax,(%edx)
	return 0;
  800422:	b8 00 00 00 00       	mov    $0x0,%eax
  800427:	eb 13                	jmp    80043c <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800429:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80042e:	eb 0c                	jmp    80043c <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800430:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800435:	eb 05                	jmp    80043c <fd_lookup+0x54>
  800437:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80043c:	5d                   	pop    %ebp
  80043d:	c3                   	ret    

0080043e <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80043e:	55                   	push   %ebp
  80043f:	89 e5                	mov    %esp,%ebp
  800441:	83 ec 08             	sub    $0x8,%esp
  800444:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800447:	ba 14 1f 80 00       	mov    $0x801f14,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80044c:	eb 13                	jmp    800461 <dev_lookup+0x23>
  80044e:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800451:	39 08                	cmp    %ecx,(%eax)
  800453:	75 0c                	jne    800461 <dev_lookup+0x23>
			*dev = devtab[i];
  800455:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800458:	89 01                	mov    %eax,(%ecx)
			return 0;
  80045a:	b8 00 00 00 00       	mov    $0x0,%eax
  80045f:	eb 2e                	jmp    80048f <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800461:	8b 02                	mov    (%edx),%eax
  800463:	85 c0                	test   %eax,%eax
  800465:	75 e7                	jne    80044e <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800467:	a1 04 40 80 00       	mov    0x804004,%eax
  80046c:	8b 40 48             	mov    0x48(%eax),%eax
  80046f:	83 ec 04             	sub    $0x4,%esp
  800472:	51                   	push   %ecx
  800473:	50                   	push   %eax
  800474:	68 98 1e 80 00       	push   $0x801e98
  800479:	e8 8b 0c 00 00       	call   801109 <cprintf>
	*dev = 0;
  80047e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800481:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800487:	83 c4 10             	add    $0x10,%esp
  80048a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80048f:	c9                   	leave  
  800490:	c3                   	ret    

00800491 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800491:	55                   	push   %ebp
  800492:	89 e5                	mov    %esp,%ebp
  800494:	56                   	push   %esi
  800495:	53                   	push   %ebx
  800496:	83 ec 10             	sub    $0x10,%esp
  800499:	8b 75 08             	mov    0x8(%ebp),%esi
  80049c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80049f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004a2:	50                   	push   %eax
  8004a3:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004a9:	c1 e8 0c             	shr    $0xc,%eax
  8004ac:	50                   	push   %eax
  8004ad:	e8 36 ff ff ff       	call   8003e8 <fd_lookup>
  8004b2:	83 c4 08             	add    $0x8,%esp
  8004b5:	85 c0                	test   %eax,%eax
  8004b7:	78 05                	js     8004be <fd_close+0x2d>
	    || fd != fd2)
  8004b9:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004bc:	74 0c                	je     8004ca <fd_close+0x39>
		return (must_exist ? r : 0);
  8004be:	84 db                	test   %bl,%bl
  8004c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8004c5:	0f 44 c2             	cmove  %edx,%eax
  8004c8:	eb 41                	jmp    80050b <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004ca:	83 ec 08             	sub    $0x8,%esp
  8004cd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004d0:	50                   	push   %eax
  8004d1:	ff 36                	pushl  (%esi)
  8004d3:	e8 66 ff ff ff       	call   80043e <dev_lookup>
  8004d8:	89 c3                	mov    %eax,%ebx
  8004da:	83 c4 10             	add    $0x10,%esp
  8004dd:	85 c0                	test   %eax,%eax
  8004df:	78 1a                	js     8004fb <fd_close+0x6a>
		if (dev->dev_close)
  8004e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004e4:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004e7:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004ec:	85 c0                	test   %eax,%eax
  8004ee:	74 0b                	je     8004fb <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004f0:	83 ec 0c             	sub    $0xc,%esp
  8004f3:	56                   	push   %esi
  8004f4:	ff d0                	call   *%eax
  8004f6:	89 c3                	mov    %eax,%ebx
  8004f8:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004fb:	83 ec 08             	sub    $0x8,%esp
  8004fe:	56                   	push   %esi
  8004ff:	6a 00                	push   $0x0
  800501:	e8 00 fd ff ff       	call   800206 <sys_page_unmap>
	return r;
  800506:	83 c4 10             	add    $0x10,%esp
  800509:	89 d8                	mov    %ebx,%eax
}
  80050b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80050e:	5b                   	pop    %ebx
  80050f:	5e                   	pop    %esi
  800510:	5d                   	pop    %ebp
  800511:	c3                   	ret    

00800512 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800512:	55                   	push   %ebp
  800513:	89 e5                	mov    %esp,%ebp
  800515:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800518:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80051b:	50                   	push   %eax
  80051c:	ff 75 08             	pushl  0x8(%ebp)
  80051f:	e8 c4 fe ff ff       	call   8003e8 <fd_lookup>
  800524:	83 c4 08             	add    $0x8,%esp
  800527:	85 c0                	test   %eax,%eax
  800529:	78 10                	js     80053b <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80052b:	83 ec 08             	sub    $0x8,%esp
  80052e:	6a 01                	push   $0x1
  800530:	ff 75 f4             	pushl  -0xc(%ebp)
  800533:	e8 59 ff ff ff       	call   800491 <fd_close>
  800538:	83 c4 10             	add    $0x10,%esp
}
  80053b:	c9                   	leave  
  80053c:	c3                   	ret    

0080053d <close_all>:

void
close_all(void)
{
  80053d:	55                   	push   %ebp
  80053e:	89 e5                	mov    %esp,%ebp
  800540:	53                   	push   %ebx
  800541:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800544:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800549:	83 ec 0c             	sub    $0xc,%esp
  80054c:	53                   	push   %ebx
  80054d:	e8 c0 ff ff ff       	call   800512 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800552:	83 c3 01             	add    $0x1,%ebx
  800555:	83 c4 10             	add    $0x10,%esp
  800558:	83 fb 20             	cmp    $0x20,%ebx
  80055b:	75 ec                	jne    800549 <close_all+0xc>
		close(i);
}
  80055d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800560:	c9                   	leave  
  800561:	c3                   	ret    

00800562 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800562:	55                   	push   %ebp
  800563:	89 e5                	mov    %esp,%ebp
  800565:	57                   	push   %edi
  800566:	56                   	push   %esi
  800567:	53                   	push   %ebx
  800568:	83 ec 2c             	sub    $0x2c,%esp
  80056b:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80056e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800571:	50                   	push   %eax
  800572:	ff 75 08             	pushl  0x8(%ebp)
  800575:	e8 6e fe ff ff       	call   8003e8 <fd_lookup>
  80057a:	83 c4 08             	add    $0x8,%esp
  80057d:	85 c0                	test   %eax,%eax
  80057f:	0f 88 c1 00 00 00    	js     800646 <dup+0xe4>
		return r;
	close(newfdnum);
  800585:	83 ec 0c             	sub    $0xc,%esp
  800588:	56                   	push   %esi
  800589:	e8 84 ff ff ff       	call   800512 <close>

	newfd = INDEX2FD(newfdnum);
  80058e:	89 f3                	mov    %esi,%ebx
  800590:	c1 e3 0c             	shl    $0xc,%ebx
  800593:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800599:	83 c4 04             	add    $0x4,%esp
  80059c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80059f:	e8 de fd ff ff       	call   800382 <fd2data>
  8005a4:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8005a6:	89 1c 24             	mov    %ebx,(%esp)
  8005a9:	e8 d4 fd ff ff       	call   800382 <fd2data>
  8005ae:	83 c4 10             	add    $0x10,%esp
  8005b1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005b4:	89 f8                	mov    %edi,%eax
  8005b6:	c1 e8 16             	shr    $0x16,%eax
  8005b9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005c0:	a8 01                	test   $0x1,%al
  8005c2:	74 37                	je     8005fb <dup+0x99>
  8005c4:	89 f8                	mov    %edi,%eax
  8005c6:	c1 e8 0c             	shr    $0xc,%eax
  8005c9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005d0:	f6 c2 01             	test   $0x1,%dl
  8005d3:	74 26                	je     8005fb <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005d5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005dc:	83 ec 0c             	sub    $0xc,%esp
  8005df:	25 07 0e 00 00       	and    $0xe07,%eax
  8005e4:	50                   	push   %eax
  8005e5:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005e8:	6a 00                	push   $0x0
  8005ea:	57                   	push   %edi
  8005eb:	6a 00                	push   $0x0
  8005ed:	e8 d2 fb ff ff       	call   8001c4 <sys_page_map>
  8005f2:	89 c7                	mov    %eax,%edi
  8005f4:	83 c4 20             	add    $0x20,%esp
  8005f7:	85 c0                	test   %eax,%eax
  8005f9:	78 2e                	js     800629 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005fb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005fe:	89 d0                	mov    %edx,%eax
  800600:	c1 e8 0c             	shr    $0xc,%eax
  800603:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80060a:	83 ec 0c             	sub    $0xc,%esp
  80060d:	25 07 0e 00 00       	and    $0xe07,%eax
  800612:	50                   	push   %eax
  800613:	53                   	push   %ebx
  800614:	6a 00                	push   $0x0
  800616:	52                   	push   %edx
  800617:	6a 00                	push   $0x0
  800619:	e8 a6 fb ff ff       	call   8001c4 <sys_page_map>
  80061e:	89 c7                	mov    %eax,%edi
  800620:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800623:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800625:	85 ff                	test   %edi,%edi
  800627:	79 1d                	jns    800646 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800629:	83 ec 08             	sub    $0x8,%esp
  80062c:	53                   	push   %ebx
  80062d:	6a 00                	push   $0x0
  80062f:	e8 d2 fb ff ff       	call   800206 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800634:	83 c4 08             	add    $0x8,%esp
  800637:	ff 75 d4             	pushl  -0x2c(%ebp)
  80063a:	6a 00                	push   $0x0
  80063c:	e8 c5 fb ff ff       	call   800206 <sys_page_unmap>
	return r;
  800641:	83 c4 10             	add    $0x10,%esp
  800644:	89 f8                	mov    %edi,%eax
}
  800646:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800649:	5b                   	pop    %ebx
  80064a:	5e                   	pop    %esi
  80064b:	5f                   	pop    %edi
  80064c:	5d                   	pop    %ebp
  80064d:	c3                   	ret    

0080064e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80064e:	55                   	push   %ebp
  80064f:	89 e5                	mov    %esp,%ebp
  800651:	53                   	push   %ebx
  800652:	83 ec 14             	sub    $0x14,%esp
  800655:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800658:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80065b:	50                   	push   %eax
  80065c:	53                   	push   %ebx
  80065d:	e8 86 fd ff ff       	call   8003e8 <fd_lookup>
  800662:	83 c4 08             	add    $0x8,%esp
  800665:	89 c2                	mov    %eax,%edx
  800667:	85 c0                	test   %eax,%eax
  800669:	78 6d                	js     8006d8 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80066b:	83 ec 08             	sub    $0x8,%esp
  80066e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800671:	50                   	push   %eax
  800672:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800675:	ff 30                	pushl  (%eax)
  800677:	e8 c2 fd ff ff       	call   80043e <dev_lookup>
  80067c:	83 c4 10             	add    $0x10,%esp
  80067f:	85 c0                	test   %eax,%eax
  800681:	78 4c                	js     8006cf <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800683:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800686:	8b 42 08             	mov    0x8(%edx),%eax
  800689:	83 e0 03             	and    $0x3,%eax
  80068c:	83 f8 01             	cmp    $0x1,%eax
  80068f:	75 21                	jne    8006b2 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800691:	a1 04 40 80 00       	mov    0x804004,%eax
  800696:	8b 40 48             	mov    0x48(%eax),%eax
  800699:	83 ec 04             	sub    $0x4,%esp
  80069c:	53                   	push   %ebx
  80069d:	50                   	push   %eax
  80069e:	68 d9 1e 80 00       	push   $0x801ed9
  8006a3:	e8 61 0a 00 00       	call   801109 <cprintf>
		return -E_INVAL;
  8006a8:	83 c4 10             	add    $0x10,%esp
  8006ab:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006b0:	eb 26                	jmp    8006d8 <read+0x8a>
	}
	if (!dev->dev_read)
  8006b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006b5:	8b 40 08             	mov    0x8(%eax),%eax
  8006b8:	85 c0                	test   %eax,%eax
  8006ba:	74 17                	je     8006d3 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006bc:	83 ec 04             	sub    $0x4,%esp
  8006bf:	ff 75 10             	pushl  0x10(%ebp)
  8006c2:	ff 75 0c             	pushl  0xc(%ebp)
  8006c5:	52                   	push   %edx
  8006c6:	ff d0                	call   *%eax
  8006c8:	89 c2                	mov    %eax,%edx
  8006ca:	83 c4 10             	add    $0x10,%esp
  8006cd:	eb 09                	jmp    8006d8 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006cf:	89 c2                	mov    %eax,%edx
  8006d1:	eb 05                	jmp    8006d8 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006d3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006d8:	89 d0                	mov    %edx,%eax
  8006da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006dd:	c9                   	leave  
  8006de:	c3                   	ret    

008006df <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006df:	55                   	push   %ebp
  8006e0:	89 e5                	mov    %esp,%ebp
  8006e2:	57                   	push   %edi
  8006e3:	56                   	push   %esi
  8006e4:	53                   	push   %ebx
  8006e5:	83 ec 0c             	sub    $0xc,%esp
  8006e8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006eb:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006ee:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006f3:	eb 21                	jmp    800716 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006f5:	83 ec 04             	sub    $0x4,%esp
  8006f8:	89 f0                	mov    %esi,%eax
  8006fa:	29 d8                	sub    %ebx,%eax
  8006fc:	50                   	push   %eax
  8006fd:	89 d8                	mov    %ebx,%eax
  8006ff:	03 45 0c             	add    0xc(%ebp),%eax
  800702:	50                   	push   %eax
  800703:	57                   	push   %edi
  800704:	e8 45 ff ff ff       	call   80064e <read>
		if (m < 0)
  800709:	83 c4 10             	add    $0x10,%esp
  80070c:	85 c0                	test   %eax,%eax
  80070e:	78 10                	js     800720 <readn+0x41>
			return m;
		if (m == 0)
  800710:	85 c0                	test   %eax,%eax
  800712:	74 0a                	je     80071e <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800714:	01 c3                	add    %eax,%ebx
  800716:	39 f3                	cmp    %esi,%ebx
  800718:	72 db                	jb     8006f5 <readn+0x16>
  80071a:	89 d8                	mov    %ebx,%eax
  80071c:	eb 02                	jmp    800720 <readn+0x41>
  80071e:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800720:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800723:	5b                   	pop    %ebx
  800724:	5e                   	pop    %esi
  800725:	5f                   	pop    %edi
  800726:	5d                   	pop    %ebp
  800727:	c3                   	ret    

00800728 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800728:	55                   	push   %ebp
  800729:	89 e5                	mov    %esp,%ebp
  80072b:	53                   	push   %ebx
  80072c:	83 ec 14             	sub    $0x14,%esp
  80072f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800732:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800735:	50                   	push   %eax
  800736:	53                   	push   %ebx
  800737:	e8 ac fc ff ff       	call   8003e8 <fd_lookup>
  80073c:	83 c4 08             	add    $0x8,%esp
  80073f:	89 c2                	mov    %eax,%edx
  800741:	85 c0                	test   %eax,%eax
  800743:	78 68                	js     8007ad <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800745:	83 ec 08             	sub    $0x8,%esp
  800748:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80074b:	50                   	push   %eax
  80074c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80074f:	ff 30                	pushl  (%eax)
  800751:	e8 e8 fc ff ff       	call   80043e <dev_lookup>
  800756:	83 c4 10             	add    $0x10,%esp
  800759:	85 c0                	test   %eax,%eax
  80075b:	78 47                	js     8007a4 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80075d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800760:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800764:	75 21                	jne    800787 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800766:	a1 04 40 80 00       	mov    0x804004,%eax
  80076b:	8b 40 48             	mov    0x48(%eax),%eax
  80076e:	83 ec 04             	sub    $0x4,%esp
  800771:	53                   	push   %ebx
  800772:	50                   	push   %eax
  800773:	68 f5 1e 80 00       	push   $0x801ef5
  800778:	e8 8c 09 00 00       	call   801109 <cprintf>
		return -E_INVAL;
  80077d:	83 c4 10             	add    $0x10,%esp
  800780:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800785:	eb 26                	jmp    8007ad <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800787:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80078a:	8b 52 0c             	mov    0xc(%edx),%edx
  80078d:	85 d2                	test   %edx,%edx
  80078f:	74 17                	je     8007a8 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800791:	83 ec 04             	sub    $0x4,%esp
  800794:	ff 75 10             	pushl  0x10(%ebp)
  800797:	ff 75 0c             	pushl  0xc(%ebp)
  80079a:	50                   	push   %eax
  80079b:	ff d2                	call   *%edx
  80079d:	89 c2                	mov    %eax,%edx
  80079f:	83 c4 10             	add    $0x10,%esp
  8007a2:	eb 09                	jmp    8007ad <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007a4:	89 c2                	mov    %eax,%edx
  8007a6:	eb 05                	jmp    8007ad <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007a8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007ad:	89 d0                	mov    %edx,%eax
  8007af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007b2:	c9                   	leave  
  8007b3:	c3                   	ret    

008007b4 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007b4:	55                   	push   %ebp
  8007b5:	89 e5                	mov    %esp,%ebp
  8007b7:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007ba:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007bd:	50                   	push   %eax
  8007be:	ff 75 08             	pushl  0x8(%ebp)
  8007c1:	e8 22 fc ff ff       	call   8003e8 <fd_lookup>
  8007c6:	83 c4 08             	add    $0x8,%esp
  8007c9:	85 c0                	test   %eax,%eax
  8007cb:	78 0e                	js     8007db <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007d0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007d3:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007d6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007db:	c9                   	leave  
  8007dc:	c3                   	ret    

008007dd <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007dd:	55                   	push   %ebp
  8007de:	89 e5                	mov    %esp,%ebp
  8007e0:	53                   	push   %ebx
  8007e1:	83 ec 14             	sub    $0x14,%esp
  8007e4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007e7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007ea:	50                   	push   %eax
  8007eb:	53                   	push   %ebx
  8007ec:	e8 f7 fb ff ff       	call   8003e8 <fd_lookup>
  8007f1:	83 c4 08             	add    $0x8,%esp
  8007f4:	89 c2                	mov    %eax,%edx
  8007f6:	85 c0                	test   %eax,%eax
  8007f8:	78 65                	js     80085f <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007fa:	83 ec 08             	sub    $0x8,%esp
  8007fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800800:	50                   	push   %eax
  800801:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800804:	ff 30                	pushl  (%eax)
  800806:	e8 33 fc ff ff       	call   80043e <dev_lookup>
  80080b:	83 c4 10             	add    $0x10,%esp
  80080e:	85 c0                	test   %eax,%eax
  800810:	78 44                	js     800856 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800812:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800815:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800819:	75 21                	jne    80083c <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80081b:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800820:	8b 40 48             	mov    0x48(%eax),%eax
  800823:	83 ec 04             	sub    $0x4,%esp
  800826:	53                   	push   %ebx
  800827:	50                   	push   %eax
  800828:	68 b8 1e 80 00       	push   $0x801eb8
  80082d:	e8 d7 08 00 00       	call   801109 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800832:	83 c4 10             	add    $0x10,%esp
  800835:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80083a:	eb 23                	jmp    80085f <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80083c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80083f:	8b 52 18             	mov    0x18(%edx),%edx
  800842:	85 d2                	test   %edx,%edx
  800844:	74 14                	je     80085a <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800846:	83 ec 08             	sub    $0x8,%esp
  800849:	ff 75 0c             	pushl  0xc(%ebp)
  80084c:	50                   	push   %eax
  80084d:	ff d2                	call   *%edx
  80084f:	89 c2                	mov    %eax,%edx
  800851:	83 c4 10             	add    $0x10,%esp
  800854:	eb 09                	jmp    80085f <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800856:	89 c2                	mov    %eax,%edx
  800858:	eb 05                	jmp    80085f <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80085a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80085f:	89 d0                	mov    %edx,%eax
  800861:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800864:	c9                   	leave  
  800865:	c3                   	ret    

00800866 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800866:	55                   	push   %ebp
  800867:	89 e5                	mov    %esp,%ebp
  800869:	53                   	push   %ebx
  80086a:	83 ec 14             	sub    $0x14,%esp
  80086d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800870:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800873:	50                   	push   %eax
  800874:	ff 75 08             	pushl  0x8(%ebp)
  800877:	e8 6c fb ff ff       	call   8003e8 <fd_lookup>
  80087c:	83 c4 08             	add    $0x8,%esp
  80087f:	89 c2                	mov    %eax,%edx
  800881:	85 c0                	test   %eax,%eax
  800883:	78 58                	js     8008dd <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800885:	83 ec 08             	sub    $0x8,%esp
  800888:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80088b:	50                   	push   %eax
  80088c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80088f:	ff 30                	pushl  (%eax)
  800891:	e8 a8 fb ff ff       	call   80043e <dev_lookup>
  800896:	83 c4 10             	add    $0x10,%esp
  800899:	85 c0                	test   %eax,%eax
  80089b:	78 37                	js     8008d4 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80089d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008a0:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008a4:	74 32                	je     8008d8 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008a6:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008a9:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008b0:	00 00 00 
	stat->st_isdir = 0;
  8008b3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008ba:	00 00 00 
	stat->st_dev = dev;
  8008bd:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008c3:	83 ec 08             	sub    $0x8,%esp
  8008c6:	53                   	push   %ebx
  8008c7:	ff 75 f0             	pushl  -0x10(%ebp)
  8008ca:	ff 50 14             	call   *0x14(%eax)
  8008cd:	89 c2                	mov    %eax,%edx
  8008cf:	83 c4 10             	add    $0x10,%esp
  8008d2:	eb 09                	jmp    8008dd <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008d4:	89 c2                	mov    %eax,%edx
  8008d6:	eb 05                	jmp    8008dd <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008d8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008dd:	89 d0                	mov    %edx,%eax
  8008df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008e2:	c9                   	leave  
  8008e3:	c3                   	ret    

008008e4 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008e4:	55                   	push   %ebp
  8008e5:	89 e5                	mov    %esp,%ebp
  8008e7:	56                   	push   %esi
  8008e8:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008e9:	83 ec 08             	sub    $0x8,%esp
  8008ec:	6a 00                	push   $0x0
  8008ee:	ff 75 08             	pushl  0x8(%ebp)
  8008f1:	e8 b7 01 00 00       	call   800aad <open>
  8008f6:	89 c3                	mov    %eax,%ebx
  8008f8:	83 c4 10             	add    $0x10,%esp
  8008fb:	85 c0                	test   %eax,%eax
  8008fd:	78 1b                	js     80091a <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008ff:	83 ec 08             	sub    $0x8,%esp
  800902:	ff 75 0c             	pushl  0xc(%ebp)
  800905:	50                   	push   %eax
  800906:	e8 5b ff ff ff       	call   800866 <fstat>
  80090b:	89 c6                	mov    %eax,%esi
	close(fd);
  80090d:	89 1c 24             	mov    %ebx,(%esp)
  800910:	e8 fd fb ff ff       	call   800512 <close>
	return r;
  800915:	83 c4 10             	add    $0x10,%esp
  800918:	89 f0                	mov    %esi,%eax
}
  80091a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80091d:	5b                   	pop    %ebx
  80091e:	5e                   	pop    %esi
  80091f:	5d                   	pop    %ebp
  800920:	c3                   	ret    

00800921 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800921:	55                   	push   %ebp
  800922:	89 e5                	mov    %esp,%ebp
  800924:	56                   	push   %esi
  800925:	53                   	push   %ebx
  800926:	89 c6                	mov    %eax,%esi
  800928:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80092a:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800931:	75 12                	jne    800945 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800933:	83 ec 0c             	sub    $0xc,%esp
  800936:	6a 01                	push   $0x1
  800938:	e8 08 12 00 00       	call   801b45 <ipc_find_env>
  80093d:	a3 00 40 80 00       	mov    %eax,0x804000
  800942:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800945:	6a 07                	push   $0x7
  800947:	68 00 50 80 00       	push   $0x805000
  80094c:	56                   	push   %esi
  80094d:	ff 35 00 40 80 00    	pushl  0x804000
  800953:	e8 99 11 00 00       	call   801af1 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800958:	83 c4 0c             	add    $0xc,%esp
  80095b:	6a 00                	push   $0x0
  80095d:	53                   	push   %ebx
  80095e:	6a 00                	push   $0x0
  800960:	e8 17 11 00 00       	call   801a7c <ipc_recv>
}
  800965:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800968:	5b                   	pop    %ebx
  800969:	5e                   	pop    %esi
  80096a:	5d                   	pop    %ebp
  80096b:	c3                   	ret    

0080096c <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80096c:	55                   	push   %ebp
  80096d:	89 e5                	mov    %esp,%ebp
  80096f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800972:	8b 45 08             	mov    0x8(%ebp),%eax
  800975:	8b 40 0c             	mov    0xc(%eax),%eax
  800978:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80097d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800980:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800985:	ba 00 00 00 00       	mov    $0x0,%edx
  80098a:	b8 02 00 00 00       	mov    $0x2,%eax
  80098f:	e8 8d ff ff ff       	call   800921 <fsipc>
}
  800994:	c9                   	leave  
  800995:	c3                   	ret    

00800996 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800996:	55                   	push   %ebp
  800997:	89 e5                	mov    %esp,%ebp
  800999:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80099c:	8b 45 08             	mov    0x8(%ebp),%eax
  80099f:	8b 40 0c             	mov    0xc(%eax),%eax
  8009a2:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ac:	b8 06 00 00 00       	mov    $0x6,%eax
  8009b1:	e8 6b ff ff ff       	call   800921 <fsipc>
}
  8009b6:	c9                   	leave  
  8009b7:	c3                   	ret    

008009b8 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009b8:	55                   	push   %ebp
  8009b9:	89 e5                	mov    %esp,%ebp
  8009bb:	53                   	push   %ebx
  8009bc:	83 ec 04             	sub    $0x4,%esp
  8009bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c5:	8b 40 0c             	mov    0xc(%eax),%eax
  8009c8:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8009d2:	b8 05 00 00 00       	mov    $0x5,%eax
  8009d7:	e8 45 ff ff ff       	call   800921 <fsipc>
  8009dc:	85 c0                	test   %eax,%eax
  8009de:	78 2c                	js     800a0c <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009e0:	83 ec 08             	sub    $0x8,%esp
  8009e3:	68 00 50 80 00       	push   $0x805000
  8009e8:	53                   	push   %ebx
  8009e9:	e8 47 0d 00 00       	call   801735 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009ee:	a1 80 50 80 00       	mov    0x805080,%eax
  8009f3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009f9:	a1 84 50 80 00       	mov    0x805084,%eax
  8009fe:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a04:	83 c4 10             	add    $0x10,%esp
  800a07:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a0c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a0f:	c9                   	leave  
  800a10:	c3                   	ret    

00800a11 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a11:	55                   	push   %ebp
  800a12:	89 e5                	mov    %esp,%ebp
  800a14:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  800a17:	68 24 1f 80 00       	push   $0x801f24
  800a1c:	68 90 00 00 00       	push   $0x90
  800a21:	68 42 1f 80 00       	push   $0x801f42
  800a26:	e8 05 06 00 00       	call   801030 <_panic>

00800a2b <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a2b:	55                   	push   %ebp
  800a2c:	89 e5                	mov    %esp,%ebp
  800a2e:	56                   	push   %esi
  800a2f:	53                   	push   %ebx
  800a30:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a33:	8b 45 08             	mov    0x8(%ebp),%eax
  800a36:	8b 40 0c             	mov    0xc(%eax),%eax
  800a39:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a3e:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a44:	ba 00 00 00 00       	mov    $0x0,%edx
  800a49:	b8 03 00 00 00       	mov    $0x3,%eax
  800a4e:	e8 ce fe ff ff       	call   800921 <fsipc>
  800a53:	89 c3                	mov    %eax,%ebx
  800a55:	85 c0                	test   %eax,%eax
  800a57:	78 4b                	js     800aa4 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a59:	39 c6                	cmp    %eax,%esi
  800a5b:	73 16                	jae    800a73 <devfile_read+0x48>
  800a5d:	68 4d 1f 80 00       	push   $0x801f4d
  800a62:	68 54 1f 80 00       	push   $0x801f54
  800a67:	6a 7c                	push   $0x7c
  800a69:	68 42 1f 80 00       	push   $0x801f42
  800a6e:	e8 bd 05 00 00       	call   801030 <_panic>
	assert(r <= PGSIZE);
  800a73:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a78:	7e 16                	jle    800a90 <devfile_read+0x65>
  800a7a:	68 69 1f 80 00       	push   $0x801f69
  800a7f:	68 54 1f 80 00       	push   $0x801f54
  800a84:	6a 7d                	push   $0x7d
  800a86:	68 42 1f 80 00       	push   $0x801f42
  800a8b:	e8 a0 05 00 00       	call   801030 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a90:	83 ec 04             	sub    $0x4,%esp
  800a93:	50                   	push   %eax
  800a94:	68 00 50 80 00       	push   $0x805000
  800a99:	ff 75 0c             	pushl  0xc(%ebp)
  800a9c:	e8 26 0e 00 00       	call   8018c7 <memmove>
	return r;
  800aa1:	83 c4 10             	add    $0x10,%esp
}
  800aa4:	89 d8                	mov    %ebx,%eax
  800aa6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800aa9:	5b                   	pop    %ebx
  800aaa:	5e                   	pop    %esi
  800aab:	5d                   	pop    %ebp
  800aac:	c3                   	ret    

00800aad <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800aad:	55                   	push   %ebp
  800aae:	89 e5                	mov    %esp,%ebp
  800ab0:	53                   	push   %ebx
  800ab1:	83 ec 20             	sub    $0x20,%esp
  800ab4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800ab7:	53                   	push   %ebx
  800ab8:	e8 3f 0c 00 00       	call   8016fc <strlen>
  800abd:	83 c4 10             	add    $0x10,%esp
  800ac0:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ac5:	7f 67                	jg     800b2e <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ac7:	83 ec 0c             	sub    $0xc,%esp
  800aca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800acd:	50                   	push   %eax
  800ace:	e8 c6 f8 ff ff       	call   800399 <fd_alloc>
  800ad3:	83 c4 10             	add    $0x10,%esp
		return r;
  800ad6:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ad8:	85 c0                	test   %eax,%eax
  800ada:	78 57                	js     800b33 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800adc:	83 ec 08             	sub    $0x8,%esp
  800adf:	53                   	push   %ebx
  800ae0:	68 00 50 80 00       	push   $0x805000
  800ae5:	e8 4b 0c 00 00       	call   801735 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800aea:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aed:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800af2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800af5:	b8 01 00 00 00       	mov    $0x1,%eax
  800afa:	e8 22 fe ff ff       	call   800921 <fsipc>
  800aff:	89 c3                	mov    %eax,%ebx
  800b01:	83 c4 10             	add    $0x10,%esp
  800b04:	85 c0                	test   %eax,%eax
  800b06:	79 14                	jns    800b1c <open+0x6f>
		fd_close(fd, 0);
  800b08:	83 ec 08             	sub    $0x8,%esp
  800b0b:	6a 00                	push   $0x0
  800b0d:	ff 75 f4             	pushl  -0xc(%ebp)
  800b10:	e8 7c f9 ff ff       	call   800491 <fd_close>
		return r;
  800b15:	83 c4 10             	add    $0x10,%esp
  800b18:	89 da                	mov    %ebx,%edx
  800b1a:	eb 17                	jmp    800b33 <open+0x86>
	}

	return fd2num(fd);
  800b1c:	83 ec 0c             	sub    $0xc,%esp
  800b1f:	ff 75 f4             	pushl  -0xc(%ebp)
  800b22:	e8 4b f8 ff ff       	call   800372 <fd2num>
  800b27:	89 c2                	mov    %eax,%edx
  800b29:	83 c4 10             	add    $0x10,%esp
  800b2c:	eb 05                	jmp    800b33 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b2e:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b33:	89 d0                	mov    %edx,%eax
  800b35:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b38:	c9                   	leave  
  800b39:	c3                   	ret    

00800b3a <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b3a:	55                   	push   %ebp
  800b3b:	89 e5                	mov    %esp,%ebp
  800b3d:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b40:	ba 00 00 00 00       	mov    $0x0,%edx
  800b45:	b8 08 00 00 00       	mov    $0x8,%eax
  800b4a:	e8 d2 fd ff ff       	call   800921 <fsipc>
}
  800b4f:	c9                   	leave  
  800b50:	c3                   	ret    

00800b51 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b51:	55                   	push   %ebp
  800b52:	89 e5                	mov    %esp,%ebp
  800b54:	56                   	push   %esi
  800b55:	53                   	push   %ebx
  800b56:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b59:	83 ec 0c             	sub    $0xc,%esp
  800b5c:	ff 75 08             	pushl  0x8(%ebp)
  800b5f:	e8 1e f8 ff ff       	call   800382 <fd2data>
  800b64:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b66:	83 c4 08             	add    $0x8,%esp
  800b69:	68 75 1f 80 00       	push   $0x801f75
  800b6e:	53                   	push   %ebx
  800b6f:	e8 c1 0b 00 00       	call   801735 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b74:	8b 46 04             	mov    0x4(%esi),%eax
  800b77:	2b 06                	sub    (%esi),%eax
  800b79:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b7f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b86:	00 00 00 
	stat->st_dev = &devpipe;
  800b89:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800b90:	30 80 00 
	return 0;
}
  800b93:	b8 00 00 00 00       	mov    $0x0,%eax
  800b98:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b9b:	5b                   	pop    %ebx
  800b9c:	5e                   	pop    %esi
  800b9d:	5d                   	pop    %ebp
  800b9e:	c3                   	ret    

00800b9f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800b9f:	55                   	push   %ebp
  800ba0:	89 e5                	mov    %esp,%ebp
  800ba2:	53                   	push   %ebx
  800ba3:	83 ec 0c             	sub    $0xc,%esp
  800ba6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800ba9:	53                   	push   %ebx
  800baa:	6a 00                	push   $0x0
  800bac:	e8 55 f6 ff ff       	call   800206 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bb1:	89 1c 24             	mov    %ebx,(%esp)
  800bb4:	e8 c9 f7 ff ff       	call   800382 <fd2data>
  800bb9:	83 c4 08             	add    $0x8,%esp
  800bbc:	50                   	push   %eax
  800bbd:	6a 00                	push   $0x0
  800bbf:	e8 42 f6 ff ff       	call   800206 <sys_page_unmap>
}
  800bc4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bc7:	c9                   	leave  
  800bc8:	c3                   	ret    

00800bc9 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800bc9:	55                   	push   %ebp
  800bca:	89 e5                	mov    %esp,%ebp
  800bcc:	57                   	push   %edi
  800bcd:	56                   	push   %esi
  800bce:	53                   	push   %ebx
  800bcf:	83 ec 1c             	sub    $0x1c,%esp
  800bd2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800bd5:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800bd7:	a1 04 40 80 00       	mov    0x804004,%eax
  800bdc:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800bdf:	83 ec 0c             	sub    $0xc,%esp
  800be2:	ff 75 e0             	pushl  -0x20(%ebp)
  800be5:	e8 94 0f 00 00       	call   801b7e <pageref>
  800bea:	89 c3                	mov    %eax,%ebx
  800bec:	89 3c 24             	mov    %edi,(%esp)
  800bef:	e8 8a 0f 00 00       	call   801b7e <pageref>
  800bf4:	83 c4 10             	add    $0x10,%esp
  800bf7:	39 c3                	cmp    %eax,%ebx
  800bf9:	0f 94 c1             	sete   %cl
  800bfc:	0f b6 c9             	movzbl %cl,%ecx
  800bff:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c02:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c08:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c0b:	39 ce                	cmp    %ecx,%esi
  800c0d:	74 1b                	je     800c2a <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c0f:	39 c3                	cmp    %eax,%ebx
  800c11:	75 c4                	jne    800bd7 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c13:	8b 42 58             	mov    0x58(%edx),%eax
  800c16:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c19:	50                   	push   %eax
  800c1a:	56                   	push   %esi
  800c1b:	68 7c 1f 80 00       	push   $0x801f7c
  800c20:	e8 e4 04 00 00       	call   801109 <cprintf>
  800c25:	83 c4 10             	add    $0x10,%esp
  800c28:	eb ad                	jmp    800bd7 <_pipeisclosed+0xe>
	}
}
  800c2a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c2d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c30:	5b                   	pop    %ebx
  800c31:	5e                   	pop    %esi
  800c32:	5f                   	pop    %edi
  800c33:	5d                   	pop    %ebp
  800c34:	c3                   	ret    

00800c35 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c35:	55                   	push   %ebp
  800c36:	89 e5                	mov    %esp,%ebp
  800c38:	57                   	push   %edi
  800c39:	56                   	push   %esi
  800c3a:	53                   	push   %ebx
  800c3b:	83 ec 28             	sub    $0x28,%esp
  800c3e:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c41:	56                   	push   %esi
  800c42:	e8 3b f7 ff ff       	call   800382 <fd2data>
  800c47:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c49:	83 c4 10             	add    $0x10,%esp
  800c4c:	bf 00 00 00 00       	mov    $0x0,%edi
  800c51:	eb 4b                	jmp    800c9e <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c53:	89 da                	mov    %ebx,%edx
  800c55:	89 f0                	mov    %esi,%eax
  800c57:	e8 6d ff ff ff       	call   800bc9 <_pipeisclosed>
  800c5c:	85 c0                	test   %eax,%eax
  800c5e:	75 48                	jne    800ca8 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c60:	e8 fd f4 ff ff       	call   800162 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c65:	8b 43 04             	mov    0x4(%ebx),%eax
  800c68:	8b 0b                	mov    (%ebx),%ecx
  800c6a:	8d 51 20             	lea    0x20(%ecx),%edx
  800c6d:	39 d0                	cmp    %edx,%eax
  800c6f:	73 e2                	jae    800c53 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c74:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c78:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c7b:	89 c2                	mov    %eax,%edx
  800c7d:	c1 fa 1f             	sar    $0x1f,%edx
  800c80:	89 d1                	mov    %edx,%ecx
  800c82:	c1 e9 1b             	shr    $0x1b,%ecx
  800c85:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c88:	83 e2 1f             	and    $0x1f,%edx
  800c8b:	29 ca                	sub    %ecx,%edx
  800c8d:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800c91:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800c95:	83 c0 01             	add    $0x1,%eax
  800c98:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c9b:	83 c7 01             	add    $0x1,%edi
  800c9e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800ca1:	75 c2                	jne    800c65 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800ca3:	8b 45 10             	mov    0x10(%ebp),%eax
  800ca6:	eb 05                	jmp    800cad <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800ca8:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800cad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb0:	5b                   	pop    %ebx
  800cb1:	5e                   	pop    %esi
  800cb2:	5f                   	pop    %edi
  800cb3:	5d                   	pop    %ebp
  800cb4:	c3                   	ret    

00800cb5 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800cb5:	55                   	push   %ebp
  800cb6:	89 e5                	mov    %esp,%ebp
  800cb8:	57                   	push   %edi
  800cb9:	56                   	push   %esi
  800cba:	53                   	push   %ebx
  800cbb:	83 ec 18             	sub    $0x18,%esp
  800cbe:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800cc1:	57                   	push   %edi
  800cc2:	e8 bb f6 ff ff       	call   800382 <fd2data>
  800cc7:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cc9:	83 c4 10             	add    $0x10,%esp
  800ccc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd1:	eb 3d                	jmp    800d10 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800cd3:	85 db                	test   %ebx,%ebx
  800cd5:	74 04                	je     800cdb <devpipe_read+0x26>
				return i;
  800cd7:	89 d8                	mov    %ebx,%eax
  800cd9:	eb 44                	jmp    800d1f <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800cdb:	89 f2                	mov    %esi,%edx
  800cdd:	89 f8                	mov    %edi,%eax
  800cdf:	e8 e5 fe ff ff       	call   800bc9 <_pipeisclosed>
  800ce4:	85 c0                	test   %eax,%eax
  800ce6:	75 32                	jne    800d1a <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800ce8:	e8 75 f4 ff ff       	call   800162 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800ced:	8b 06                	mov    (%esi),%eax
  800cef:	3b 46 04             	cmp    0x4(%esi),%eax
  800cf2:	74 df                	je     800cd3 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800cf4:	99                   	cltd   
  800cf5:	c1 ea 1b             	shr    $0x1b,%edx
  800cf8:	01 d0                	add    %edx,%eax
  800cfa:	83 e0 1f             	and    $0x1f,%eax
  800cfd:	29 d0                	sub    %edx,%eax
  800cff:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d04:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d07:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d0a:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d0d:	83 c3 01             	add    $0x1,%ebx
  800d10:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d13:	75 d8                	jne    800ced <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d15:	8b 45 10             	mov    0x10(%ebp),%eax
  800d18:	eb 05                	jmp    800d1f <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d1a:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d1f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d22:	5b                   	pop    %ebx
  800d23:	5e                   	pop    %esi
  800d24:	5f                   	pop    %edi
  800d25:	5d                   	pop    %ebp
  800d26:	c3                   	ret    

00800d27 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d27:	55                   	push   %ebp
  800d28:	89 e5                	mov    %esp,%ebp
  800d2a:	56                   	push   %esi
  800d2b:	53                   	push   %ebx
  800d2c:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d2f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d32:	50                   	push   %eax
  800d33:	e8 61 f6 ff ff       	call   800399 <fd_alloc>
  800d38:	83 c4 10             	add    $0x10,%esp
  800d3b:	89 c2                	mov    %eax,%edx
  800d3d:	85 c0                	test   %eax,%eax
  800d3f:	0f 88 2c 01 00 00    	js     800e71 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d45:	83 ec 04             	sub    $0x4,%esp
  800d48:	68 07 04 00 00       	push   $0x407
  800d4d:	ff 75 f4             	pushl  -0xc(%ebp)
  800d50:	6a 00                	push   $0x0
  800d52:	e8 2a f4 ff ff       	call   800181 <sys_page_alloc>
  800d57:	83 c4 10             	add    $0x10,%esp
  800d5a:	89 c2                	mov    %eax,%edx
  800d5c:	85 c0                	test   %eax,%eax
  800d5e:	0f 88 0d 01 00 00    	js     800e71 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d64:	83 ec 0c             	sub    $0xc,%esp
  800d67:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d6a:	50                   	push   %eax
  800d6b:	e8 29 f6 ff ff       	call   800399 <fd_alloc>
  800d70:	89 c3                	mov    %eax,%ebx
  800d72:	83 c4 10             	add    $0x10,%esp
  800d75:	85 c0                	test   %eax,%eax
  800d77:	0f 88 e2 00 00 00    	js     800e5f <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d7d:	83 ec 04             	sub    $0x4,%esp
  800d80:	68 07 04 00 00       	push   $0x407
  800d85:	ff 75 f0             	pushl  -0x10(%ebp)
  800d88:	6a 00                	push   $0x0
  800d8a:	e8 f2 f3 ff ff       	call   800181 <sys_page_alloc>
  800d8f:	89 c3                	mov    %eax,%ebx
  800d91:	83 c4 10             	add    $0x10,%esp
  800d94:	85 c0                	test   %eax,%eax
  800d96:	0f 88 c3 00 00 00    	js     800e5f <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800d9c:	83 ec 0c             	sub    $0xc,%esp
  800d9f:	ff 75 f4             	pushl  -0xc(%ebp)
  800da2:	e8 db f5 ff ff       	call   800382 <fd2data>
  800da7:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800da9:	83 c4 0c             	add    $0xc,%esp
  800dac:	68 07 04 00 00       	push   $0x407
  800db1:	50                   	push   %eax
  800db2:	6a 00                	push   $0x0
  800db4:	e8 c8 f3 ff ff       	call   800181 <sys_page_alloc>
  800db9:	89 c3                	mov    %eax,%ebx
  800dbb:	83 c4 10             	add    $0x10,%esp
  800dbe:	85 c0                	test   %eax,%eax
  800dc0:	0f 88 89 00 00 00    	js     800e4f <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dc6:	83 ec 0c             	sub    $0xc,%esp
  800dc9:	ff 75 f0             	pushl  -0x10(%ebp)
  800dcc:	e8 b1 f5 ff ff       	call   800382 <fd2data>
  800dd1:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800dd8:	50                   	push   %eax
  800dd9:	6a 00                	push   $0x0
  800ddb:	56                   	push   %esi
  800ddc:	6a 00                	push   $0x0
  800dde:	e8 e1 f3 ff ff       	call   8001c4 <sys_page_map>
  800de3:	89 c3                	mov    %eax,%ebx
  800de5:	83 c4 20             	add    $0x20,%esp
  800de8:	85 c0                	test   %eax,%eax
  800dea:	78 55                	js     800e41 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800dec:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800df2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800df5:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800df7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dfa:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e01:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e07:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e0a:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e0f:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e16:	83 ec 0c             	sub    $0xc,%esp
  800e19:	ff 75 f4             	pushl  -0xc(%ebp)
  800e1c:	e8 51 f5 ff ff       	call   800372 <fd2num>
  800e21:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e24:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e26:	83 c4 04             	add    $0x4,%esp
  800e29:	ff 75 f0             	pushl  -0x10(%ebp)
  800e2c:	e8 41 f5 ff ff       	call   800372 <fd2num>
  800e31:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e34:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e37:	83 c4 10             	add    $0x10,%esp
  800e3a:	ba 00 00 00 00       	mov    $0x0,%edx
  800e3f:	eb 30                	jmp    800e71 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e41:	83 ec 08             	sub    $0x8,%esp
  800e44:	56                   	push   %esi
  800e45:	6a 00                	push   $0x0
  800e47:	e8 ba f3 ff ff       	call   800206 <sys_page_unmap>
  800e4c:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e4f:	83 ec 08             	sub    $0x8,%esp
  800e52:	ff 75 f0             	pushl  -0x10(%ebp)
  800e55:	6a 00                	push   $0x0
  800e57:	e8 aa f3 ff ff       	call   800206 <sys_page_unmap>
  800e5c:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e5f:	83 ec 08             	sub    $0x8,%esp
  800e62:	ff 75 f4             	pushl  -0xc(%ebp)
  800e65:	6a 00                	push   $0x0
  800e67:	e8 9a f3 ff ff       	call   800206 <sys_page_unmap>
  800e6c:	83 c4 10             	add    $0x10,%esp
  800e6f:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800e71:	89 d0                	mov    %edx,%eax
  800e73:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e76:	5b                   	pop    %ebx
  800e77:	5e                   	pop    %esi
  800e78:	5d                   	pop    %ebp
  800e79:	c3                   	ret    

00800e7a <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e7a:	55                   	push   %ebp
  800e7b:	89 e5                	mov    %esp,%ebp
  800e7d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e80:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e83:	50                   	push   %eax
  800e84:	ff 75 08             	pushl  0x8(%ebp)
  800e87:	e8 5c f5 ff ff       	call   8003e8 <fd_lookup>
  800e8c:	83 c4 10             	add    $0x10,%esp
  800e8f:	85 c0                	test   %eax,%eax
  800e91:	78 18                	js     800eab <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800e93:	83 ec 0c             	sub    $0xc,%esp
  800e96:	ff 75 f4             	pushl  -0xc(%ebp)
  800e99:	e8 e4 f4 ff ff       	call   800382 <fd2data>
	return _pipeisclosed(fd, p);
  800e9e:	89 c2                	mov    %eax,%edx
  800ea0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ea3:	e8 21 fd ff ff       	call   800bc9 <_pipeisclosed>
  800ea8:	83 c4 10             	add    $0x10,%esp
}
  800eab:	c9                   	leave  
  800eac:	c3                   	ret    

00800ead <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800ead:	55                   	push   %ebp
  800eae:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800eb0:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb5:	5d                   	pop    %ebp
  800eb6:	c3                   	ret    

00800eb7 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800eb7:	55                   	push   %ebp
  800eb8:	89 e5                	mov    %esp,%ebp
  800eba:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ebd:	68 94 1f 80 00       	push   $0x801f94
  800ec2:	ff 75 0c             	pushl  0xc(%ebp)
  800ec5:	e8 6b 08 00 00       	call   801735 <strcpy>
	return 0;
}
  800eca:	b8 00 00 00 00       	mov    $0x0,%eax
  800ecf:	c9                   	leave  
  800ed0:	c3                   	ret    

00800ed1 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800ed1:	55                   	push   %ebp
  800ed2:	89 e5                	mov    %esp,%ebp
  800ed4:	57                   	push   %edi
  800ed5:	56                   	push   %esi
  800ed6:	53                   	push   %ebx
  800ed7:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800edd:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800ee2:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ee8:	eb 2d                	jmp    800f17 <devcons_write+0x46>
		m = n - tot;
  800eea:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eed:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800eef:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800ef2:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800ef7:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800efa:	83 ec 04             	sub    $0x4,%esp
  800efd:	53                   	push   %ebx
  800efe:	03 45 0c             	add    0xc(%ebp),%eax
  800f01:	50                   	push   %eax
  800f02:	57                   	push   %edi
  800f03:	e8 bf 09 00 00       	call   8018c7 <memmove>
		sys_cputs(buf, m);
  800f08:	83 c4 08             	add    $0x8,%esp
  800f0b:	53                   	push   %ebx
  800f0c:	57                   	push   %edi
  800f0d:	e8 b3 f1 ff ff       	call   8000c5 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f12:	01 de                	add    %ebx,%esi
  800f14:	83 c4 10             	add    $0x10,%esp
  800f17:	89 f0                	mov    %esi,%eax
  800f19:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f1c:	72 cc                	jb     800eea <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f1e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f21:	5b                   	pop    %ebx
  800f22:	5e                   	pop    %esi
  800f23:	5f                   	pop    %edi
  800f24:	5d                   	pop    %ebp
  800f25:	c3                   	ret    

00800f26 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f26:	55                   	push   %ebp
  800f27:	89 e5                	mov    %esp,%ebp
  800f29:	83 ec 08             	sub    $0x8,%esp
  800f2c:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f31:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f35:	74 2a                	je     800f61 <devcons_read+0x3b>
  800f37:	eb 05                	jmp    800f3e <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f39:	e8 24 f2 ff ff       	call   800162 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f3e:	e8 a0 f1 ff ff       	call   8000e3 <sys_cgetc>
  800f43:	85 c0                	test   %eax,%eax
  800f45:	74 f2                	je     800f39 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f47:	85 c0                	test   %eax,%eax
  800f49:	78 16                	js     800f61 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f4b:	83 f8 04             	cmp    $0x4,%eax
  800f4e:	74 0c                	je     800f5c <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f50:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f53:	88 02                	mov    %al,(%edx)
	return 1;
  800f55:	b8 01 00 00 00       	mov    $0x1,%eax
  800f5a:	eb 05                	jmp    800f61 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f5c:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f61:	c9                   	leave  
  800f62:	c3                   	ret    

00800f63 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f63:	55                   	push   %ebp
  800f64:	89 e5                	mov    %esp,%ebp
  800f66:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f69:	8b 45 08             	mov    0x8(%ebp),%eax
  800f6c:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f6f:	6a 01                	push   $0x1
  800f71:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f74:	50                   	push   %eax
  800f75:	e8 4b f1 ff ff       	call   8000c5 <sys_cputs>
}
  800f7a:	83 c4 10             	add    $0x10,%esp
  800f7d:	c9                   	leave  
  800f7e:	c3                   	ret    

00800f7f <getchar>:

int
getchar(void)
{
  800f7f:	55                   	push   %ebp
  800f80:	89 e5                	mov    %esp,%ebp
  800f82:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f85:	6a 01                	push   $0x1
  800f87:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f8a:	50                   	push   %eax
  800f8b:	6a 00                	push   $0x0
  800f8d:	e8 bc f6 ff ff       	call   80064e <read>
	if (r < 0)
  800f92:	83 c4 10             	add    $0x10,%esp
  800f95:	85 c0                	test   %eax,%eax
  800f97:	78 0f                	js     800fa8 <getchar+0x29>
		return r;
	if (r < 1)
  800f99:	85 c0                	test   %eax,%eax
  800f9b:	7e 06                	jle    800fa3 <getchar+0x24>
		return -E_EOF;
	return c;
  800f9d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800fa1:	eb 05                	jmp    800fa8 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800fa3:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800fa8:	c9                   	leave  
  800fa9:	c3                   	ret    

00800faa <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800faa:	55                   	push   %ebp
  800fab:	89 e5                	mov    %esp,%ebp
  800fad:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fb0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fb3:	50                   	push   %eax
  800fb4:	ff 75 08             	pushl  0x8(%ebp)
  800fb7:	e8 2c f4 ff ff       	call   8003e8 <fd_lookup>
  800fbc:	83 c4 10             	add    $0x10,%esp
  800fbf:	85 c0                	test   %eax,%eax
  800fc1:	78 11                	js     800fd4 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800fc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fc6:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fcc:	39 10                	cmp    %edx,(%eax)
  800fce:	0f 94 c0             	sete   %al
  800fd1:	0f b6 c0             	movzbl %al,%eax
}
  800fd4:	c9                   	leave  
  800fd5:	c3                   	ret    

00800fd6 <opencons>:

int
opencons(void)
{
  800fd6:	55                   	push   %ebp
  800fd7:	89 e5                	mov    %esp,%ebp
  800fd9:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fdc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fdf:	50                   	push   %eax
  800fe0:	e8 b4 f3 ff ff       	call   800399 <fd_alloc>
  800fe5:	83 c4 10             	add    $0x10,%esp
		return r;
  800fe8:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fea:	85 c0                	test   %eax,%eax
  800fec:	78 3e                	js     80102c <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fee:	83 ec 04             	sub    $0x4,%esp
  800ff1:	68 07 04 00 00       	push   $0x407
  800ff6:	ff 75 f4             	pushl  -0xc(%ebp)
  800ff9:	6a 00                	push   $0x0
  800ffb:	e8 81 f1 ff ff       	call   800181 <sys_page_alloc>
  801000:	83 c4 10             	add    $0x10,%esp
		return r;
  801003:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801005:	85 c0                	test   %eax,%eax
  801007:	78 23                	js     80102c <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801009:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80100f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801012:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801014:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801017:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80101e:	83 ec 0c             	sub    $0xc,%esp
  801021:	50                   	push   %eax
  801022:	e8 4b f3 ff ff       	call   800372 <fd2num>
  801027:	89 c2                	mov    %eax,%edx
  801029:	83 c4 10             	add    $0x10,%esp
}
  80102c:	89 d0                	mov    %edx,%eax
  80102e:	c9                   	leave  
  80102f:	c3                   	ret    

00801030 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801030:	55                   	push   %ebp
  801031:	89 e5                	mov    %esp,%ebp
  801033:	56                   	push   %esi
  801034:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801035:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801038:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80103e:	e8 00 f1 ff ff       	call   800143 <sys_getenvid>
  801043:	83 ec 0c             	sub    $0xc,%esp
  801046:	ff 75 0c             	pushl  0xc(%ebp)
  801049:	ff 75 08             	pushl  0x8(%ebp)
  80104c:	56                   	push   %esi
  80104d:	50                   	push   %eax
  80104e:	68 a0 1f 80 00       	push   $0x801fa0
  801053:	e8 b1 00 00 00       	call   801109 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801058:	83 c4 18             	add    $0x18,%esp
  80105b:	53                   	push   %ebx
  80105c:	ff 75 10             	pushl  0x10(%ebp)
  80105f:	e8 54 00 00 00       	call   8010b8 <vcprintf>
	cprintf("\n");
  801064:	c7 04 24 8d 1f 80 00 	movl   $0x801f8d,(%esp)
  80106b:	e8 99 00 00 00       	call   801109 <cprintf>
  801070:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801073:	cc                   	int3   
  801074:	eb fd                	jmp    801073 <_panic+0x43>

00801076 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801076:	55                   	push   %ebp
  801077:	89 e5                	mov    %esp,%ebp
  801079:	53                   	push   %ebx
  80107a:	83 ec 04             	sub    $0x4,%esp
  80107d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801080:	8b 13                	mov    (%ebx),%edx
  801082:	8d 42 01             	lea    0x1(%edx),%eax
  801085:	89 03                	mov    %eax,(%ebx)
  801087:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80108a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80108e:	3d ff 00 00 00       	cmp    $0xff,%eax
  801093:	75 1a                	jne    8010af <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801095:	83 ec 08             	sub    $0x8,%esp
  801098:	68 ff 00 00 00       	push   $0xff
  80109d:	8d 43 08             	lea    0x8(%ebx),%eax
  8010a0:	50                   	push   %eax
  8010a1:	e8 1f f0 ff ff       	call   8000c5 <sys_cputs>
		b->idx = 0;
  8010a6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010ac:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010af:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010b6:	c9                   	leave  
  8010b7:	c3                   	ret    

008010b8 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010b8:	55                   	push   %ebp
  8010b9:	89 e5                	mov    %esp,%ebp
  8010bb:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010c1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010c8:	00 00 00 
	b.cnt = 0;
  8010cb:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010d2:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010d5:	ff 75 0c             	pushl  0xc(%ebp)
  8010d8:	ff 75 08             	pushl  0x8(%ebp)
  8010db:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010e1:	50                   	push   %eax
  8010e2:	68 76 10 80 00       	push   $0x801076
  8010e7:	e8 1a 01 00 00       	call   801206 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010ec:	83 c4 08             	add    $0x8,%esp
  8010ef:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8010f5:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8010fb:	50                   	push   %eax
  8010fc:	e8 c4 ef ff ff       	call   8000c5 <sys_cputs>

	return b.cnt;
}
  801101:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801107:	c9                   	leave  
  801108:	c3                   	ret    

00801109 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801109:	55                   	push   %ebp
  80110a:	89 e5                	mov    %esp,%ebp
  80110c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80110f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801112:	50                   	push   %eax
  801113:	ff 75 08             	pushl  0x8(%ebp)
  801116:	e8 9d ff ff ff       	call   8010b8 <vcprintf>
	va_end(ap);

	return cnt;
}
  80111b:	c9                   	leave  
  80111c:	c3                   	ret    

0080111d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80111d:	55                   	push   %ebp
  80111e:	89 e5                	mov    %esp,%ebp
  801120:	57                   	push   %edi
  801121:	56                   	push   %esi
  801122:	53                   	push   %ebx
  801123:	83 ec 1c             	sub    $0x1c,%esp
  801126:	89 c7                	mov    %eax,%edi
  801128:	89 d6                	mov    %edx,%esi
  80112a:	8b 45 08             	mov    0x8(%ebp),%eax
  80112d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801130:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801133:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801136:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801139:	bb 00 00 00 00       	mov    $0x0,%ebx
  80113e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801141:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801144:	39 d3                	cmp    %edx,%ebx
  801146:	72 05                	jb     80114d <printnum+0x30>
  801148:	39 45 10             	cmp    %eax,0x10(%ebp)
  80114b:	77 45                	ja     801192 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80114d:	83 ec 0c             	sub    $0xc,%esp
  801150:	ff 75 18             	pushl  0x18(%ebp)
  801153:	8b 45 14             	mov    0x14(%ebp),%eax
  801156:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801159:	53                   	push   %ebx
  80115a:	ff 75 10             	pushl  0x10(%ebp)
  80115d:	83 ec 08             	sub    $0x8,%esp
  801160:	ff 75 e4             	pushl  -0x1c(%ebp)
  801163:	ff 75 e0             	pushl  -0x20(%ebp)
  801166:	ff 75 dc             	pushl  -0x24(%ebp)
  801169:	ff 75 d8             	pushl  -0x28(%ebp)
  80116c:	e8 4f 0a 00 00       	call   801bc0 <__udivdi3>
  801171:	83 c4 18             	add    $0x18,%esp
  801174:	52                   	push   %edx
  801175:	50                   	push   %eax
  801176:	89 f2                	mov    %esi,%edx
  801178:	89 f8                	mov    %edi,%eax
  80117a:	e8 9e ff ff ff       	call   80111d <printnum>
  80117f:	83 c4 20             	add    $0x20,%esp
  801182:	eb 18                	jmp    80119c <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801184:	83 ec 08             	sub    $0x8,%esp
  801187:	56                   	push   %esi
  801188:	ff 75 18             	pushl  0x18(%ebp)
  80118b:	ff d7                	call   *%edi
  80118d:	83 c4 10             	add    $0x10,%esp
  801190:	eb 03                	jmp    801195 <printnum+0x78>
  801192:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801195:	83 eb 01             	sub    $0x1,%ebx
  801198:	85 db                	test   %ebx,%ebx
  80119a:	7f e8                	jg     801184 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80119c:	83 ec 08             	sub    $0x8,%esp
  80119f:	56                   	push   %esi
  8011a0:	83 ec 04             	sub    $0x4,%esp
  8011a3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011a6:	ff 75 e0             	pushl  -0x20(%ebp)
  8011a9:	ff 75 dc             	pushl  -0x24(%ebp)
  8011ac:	ff 75 d8             	pushl  -0x28(%ebp)
  8011af:	e8 3c 0b 00 00       	call   801cf0 <__umoddi3>
  8011b4:	83 c4 14             	add    $0x14,%esp
  8011b7:	0f be 80 c3 1f 80 00 	movsbl 0x801fc3(%eax),%eax
  8011be:	50                   	push   %eax
  8011bf:	ff d7                	call   *%edi
}
  8011c1:	83 c4 10             	add    $0x10,%esp
  8011c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011c7:	5b                   	pop    %ebx
  8011c8:	5e                   	pop    %esi
  8011c9:	5f                   	pop    %edi
  8011ca:	5d                   	pop    %ebp
  8011cb:	c3                   	ret    

008011cc <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011cc:	55                   	push   %ebp
  8011cd:	89 e5                	mov    %esp,%ebp
  8011cf:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011d2:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8011d6:	8b 10                	mov    (%eax),%edx
  8011d8:	3b 50 04             	cmp    0x4(%eax),%edx
  8011db:	73 0a                	jae    8011e7 <sprintputch+0x1b>
		*b->buf++ = ch;
  8011dd:	8d 4a 01             	lea    0x1(%edx),%ecx
  8011e0:	89 08                	mov    %ecx,(%eax)
  8011e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e5:	88 02                	mov    %al,(%edx)
}
  8011e7:	5d                   	pop    %ebp
  8011e8:	c3                   	ret    

008011e9 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8011e9:	55                   	push   %ebp
  8011ea:	89 e5                	mov    %esp,%ebp
  8011ec:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8011ef:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8011f2:	50                   	push   %eax
  8011f3:	ff 75 10             	pushl  0x10(%ebp)
  8011f6:	ff 75 0c             	pushl  0xc(%ebp)
  8011f9:	ff 75 08             	pushl  0x8(%ebp)
  8011fc:	e8 05 00 00 00       	call   801206 <vprintfmt>
	va_end(ap);
}
  801201:	83 c4 10             	add    $0x10,%esp
  801204:	c9                   	leave  
  801205:	c3                   	ret    

00801206 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801206:	55                   	push   %ebp
  801207:	89 e5                	mov    %esp,%ebp
  801209:	57                   	push   %edi
  80120a:	56                   	push   %esi
  80120b:	53                   	push   %ebx
  80120c:	83 ec 2c             	sub    $0x2c,%esp
  80120f:	8b 75 08             	mov    0x8(%ebp),%esi
  801212:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801215:	8b 7d 10             	mov    0x10(%ebp),%edi
  801218:	eb 12                	jmp    80122c <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80121a:	85 c0                	test   %eax,%eax
  80121c:	0f 84 6a 04 00 00    	je     80168c <vprintfmt+0x486>
				return;
			putch(ch, putdat);
  801222:	83 ec 08             	sub    $0x8,%esp
  801225:	53                   	push   %ebx
  801226:	50                   	push   %eax
  801227:	ff d6                	call   *%esi
  801229:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80122c:	83 c7 01             	add    $0x1,%edi
  80122f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801233:	83 f8 25             	cmp    $0x25,%eax
  801236:	75 e2                	jne    80121a <vprintfmt+0x14>
  801238:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80123c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801243:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80124a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801251:	b9 00 00 00 00       	mov    $0x0,%ecx
  801256:	eb 07                	jmp    80125f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801258:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80125b:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80125f:	8d 47 01             	lea    0x1(%edi),%eax
  801262:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801265:	0f b6 07             	movzbl (%edi),%eax
  801268:	0f b6 d0             	movzbl %al,%edx
  80126b:	83 e8 23             	sub    $0x23,%eax
  80126e:	3c 55                	cmp    $0x55,%al
  801270:	0f 87 fb 03 00 00    	ja     801671 <vprintfmt+0x46b>
  801276:	0f b6 c0             	movzbl %al,%eax
  801279:	ff 24 85 00 21 80 00 	jmp    *0x802100(,%eax,4)
  801280:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801283:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801287:	eb d6                	jmp    80125f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801289:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80128c:	b8 00 00 00 00       	mov    $0x0,%eax
  801291:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801294:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801297:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80129b:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80129e:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8012a1:	83 f9 09             	cmp    $0x9,%ecx
  8012a4:	77 3f                	ja     8012e5 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8012a6:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8012a9:	eb e9                	jmp    801294 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8012ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8012ae:	8b 00                	mov    (%eax),%eax
  8012b0:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8012b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8012b6:	8d 40 04             	lea    0x4(%eax),%eax
  8012b9:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8012bf:	eb 2a                	jmp    8012eb <vprintfmt+0xe5>
  8012c1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012c4:	85 c0                	test   %eax,%eax
  8012c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8012cb:	0f 49 d0             	cmovns %eax,%edx
  8012ce:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012d4:	eb 89                	jmp    80125f <vprintfmt+0x59>
  8012d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8012d9:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8012e0:	e9 7a ff ff ff       	jmp    80125f <vprintfmt+0x59>
  8012e5:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8012e8:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8012eb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8012ef:	0f 89 6a ff ff ff    	jns    80125f <vprintfmt+0x59>
				width = precision, precision = -1;
  8012f5:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8012f8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8012fb:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801302:	e9 58 ff ff ff       	jmp    80125f <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801307:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80130a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80130d:	e9 4d ff ff ff       	jmp    80125f <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801312:	8b 45 14             	mov    0x14(%ebp),%eax
  801315:	8d 78 04             	lea    0x4(%eax),%edi
  801318:	83 ec 08             	sub    $0x8,%esp
  80131b:	53                   	push   %ebx
  80131c:	ff 30                	pushl  (%eax)
  80131e:	ff d6                	call   *%esi
			break;
  801320:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801323:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801326:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801329:	e9 fe fe ff ff       	jmp    80122c <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80132e:	8b 45 14             	mov    0x14(%ebp),%eax
  801331:	8d 78 04             	lea    0x4(%eax),%edi
  801334:	8b 00                	mov    (%eax),%eax
  801336:	99                   	cltd   
  801337:	31 d0                	xor    %edx,%eax
  801339:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80133b:	83 f8 0f             	cmp    $0xf,%eax
  80133e:	7f 0b                	jg     80134b <vprintfmt+0x145>
  801340:	8b 14 85 60 22 80 00 	mov    0x802260(,%eax,4),%edx
  801347:	85 d2                	test   %edx,%edx
  801349:	75 1b                	jne    801366 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  80134b:	50                   	push   %eax
  80134c:	68 db 1f 80 00       	push   $0x801fdb
  801351:	53                   	push   %ebx
  801352:	56                   	push   %esi
  801353:	e8 91 fe ff ff       	call   8011e9 <printfmt>
  801358:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80135b:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80135e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801361:	e9 c6 fe ff ff       	jmp    80122c <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801366:	52                   	push   %edx
  801367:	68 66 1f 80 00       	push   $0x801f66
  80136c:	53                   	push   %ebx
  80136d:	56                   	push   %esi
  80136e:	e8 76 fe ff ff       	call   8011e9 <printfmt>
  801373:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  801376:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801379:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80137c:	e9 ab fe ff ff       	jmp    80122c <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801381:	8b 45 14             	mov    0x14(%ebp),%eax
  801384:	83 c0 04             	add    $0x4,%eax
  801387:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80138a:	8b 45 14             	mov    0x14(%ebp),%eax
  80138d:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80138f:	85 ff                	test   %edi,%edi
  801391:	b8 d4 1f 80 00       	mov    $0x801fd4,%eax
  801396:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801399:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80139d:	0f 8e 94 00 00 00    	jle    801437 <vprintfmt+0x231>
  8013a3:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8013a7:	0f 84 98 00 00 00    	je     801445 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013ad:	83 ec 08             	sub    $0x8,%esp
  8013b0:	ff 75 d0             	pushl  -0x30(%ebp)
  8013b3:	57                   	push   %edi
  8013b4:	e8 5b 03 00 00       	call   801714 <strnlen>
  8013b9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8013bc:	29 c1                	sub    %eax,%ecx
  8013be:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8013c1:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8013c4:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8013c8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8013cb:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8013ce:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013d0:	eb 0f                	jmp    8013e1 <vprintfmt+0x1db>
					putch(padc, putdat);
  8013d2:	83 ec 08             	sub    $0x8,%esp
  8013d5:	53                   	push   %ebx
  8013d6:	ff 75 e0             	pushl  -0x20(%ebp)
  8013d9:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013db:	83 ef 01             	sub    $0x1,%edi
  8013de:	83 c4 10             	add    $0x10,%esp
  8013e1:	85 ff                	test   %edi,%edi
  8013e3:	7f ed                	jg     8013d2 <vprintfmt+0x1cc>
  8013e5:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8013e8:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8013eb:	85 c9                	test   %ecx,%ecx
  8013ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8013f2:	0f 49 c1             	cmovns %ecx,%eax
  8013f5:	29 c1                	sub    %eax,%ecx
  8013f7:	89 75 08             	mov    %esi,0x8(%ebp)
  8013fa:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8013fd:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801400:	89 cb                	mov    %ecx,%ebx
  801402:	eb 4d                	jmp    801451 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801404:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801408:	74 1b                	je     801425 <vprintfmt+0x21f>
  80140a:	0f be c0             	movsbl %al,%eax
  80140d:	83 e8 20             	sub    $0x20,%eax
  801410:	83 f8 5e             	cmp    $0x5e,%eax
  801413:	76 10                	jbe    801425 <vprintfmt+0x21f>
					putch('?', putdat);
  801415:	83 ec 08             	sub    $0x8,%esp
  801418:	ff 75 0c             	pushl  0xc(%ebp)
  80141b:	6a 3f                	push   $0x3f
  80141d:	ff 55 08             	call   *0x8(%ebp)
  801420:	83 c4 10             	add    $0x10,%esp
  801423:	eb 0d                	jmp    801432 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  801425:	83 ec 08             	sub    $0x8,%esp
  801428:	ff 75 0c             	pushl  0xc(%ebp)
  80142b:	52                   	push   %edx
  80142c:	ff 55 08             	call   *0x8(%ebp)
  80142f:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801432:	83 eb 01             	sub    $0x1,%ebx
  801435:	eb 1a                	jmp    801451 <vprintfmt+0x24b>
  801437:	89 75 08             	mov    %esi,0x8(%ebp)
  80143a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80143d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801440:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801443:	eb 0c                	jmp    801451 <vprintfmt+0x24b>
  801445:	89 75 08             	mov    %esi,0x8(%ebp)
  801448:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80144b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80144e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801451:	83 c7 01             	add    $0x1,%edi
  801454:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801458:	0f be d0             	movsbl %al,%edx
  80145b:	85 d2                	test   %edx,%edx
  80145d:	74 23                	je     801482 <vprintfmt+0x27c>
  80145f:	85 f6                	test   %esi,%esi
  801461:	78 a1                	js     801404 <vprintfmt+0x1fe>
  801463:	83 ee 01             	sub    $0x1,%esi
  801466:	79 9c                	jns    801404 <vprintfmt+0x1fe>
  801468:	89 df                	mov    %ebx,%edi
  80146a:	8b 75 08             	mov    0x8(%ebp),%esi
  80146d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801470:	eb 18                	jmp    80148a <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801472:	83 ec 08             	sub    $0x8,%esp
  801475:	53                   	push   %ebx
  801476:	6a 20                	push   $0x20
  801478:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80147a:	83 ef 01             	sub    $0x1,%edi
  80147d:	83 c4 10             	add    $0x10,%esp
  801480:	eb 08                	jmp    80148a <vprintfmt+0x284>
  801482:	89 df                	mov    %ebx,%edi
  801484:	8b 75 08             	mov    0x8(%ebp),%esi
  801487:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80148a:	85 ff                	test   %edi,%edi
  80148c:	7f e4                	jg     801472 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80148e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801491:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801494:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801497:	e9 90 fd ff ff       	jmp    80122c <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80149c:	83 f9 01             	cmp    $0x1,%ecx
  80149f:	7e 19                	jle    8014ba <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8014a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8014a4:	8b 50 04             	mov    0x4(%eax),%edx
  8014a7:	8b 00                	mov    (%eax),%eax
  8014a9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014ac:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8014af:	8b 45 14             	mov    0x14(%ebp),%eax
  8014b2:	8d 40 08             	lea    0x8(%eax),%eax
  8014b5:	89 45 14             	mov    %eax,0x14(%ebp)
  8014b8:	eb 38                	jmp    8014f2 <vprintfmt+0x2ec>
	else if (lflag)
  8014ba:	85 c9                	test   %ecx,%ecx
  8014bc:	74 1b                	je     8014d9 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8014be:	8b 45 14             	mov    0x14(%ebp),%eax
  8014c1:	8b 00                	mov    (%eax),%eax
  8014c3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014c6:	89 c1                	mov    %eax,%ecx
  8014c8:	c1 f9 1f             	sar    $0x1f,%ecx
  8014cb:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8014d1:	8d 40 04             	lea    0x4(%eax),%eax
  8014d4:	89 45 14             	mov    %eax,0x14(%ebp)
  8014d7:	eb 19                	jmp    8014f2 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8014d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8014dc:	8b 00                	mov    (%eax),%eax
  8014de:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014e1:	89 c1                	mov    %eax,%ecx
  8014e3:	c1 f9 1f             	sar    $0x1f,%ecx
  8014e6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8014ec:	8d 40 04             	lea    0x4(%eax),%eax
  8014ef:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8014f2:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8014f5:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8014f8:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8014fd:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801501:	0f 89 36 01 00 00    	jns    80163d <vprintfmt+0x437>
				putch('-', putdat);
  801507:	83 ec 08             	sub    $0x8,%esp
  80150a:	53                   	push   %ebx
  80150b:	6a 2d                	push   $0x2d
  80150d:	ff d6                	call   *%esi
				num = -(long long) num;
  80150f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801512:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801515:	f7 da                	neg    %edx
  801517:	83 d1 00             	adc    $0x0,%ecx
  80151a:	f7 d9                	neg    %ecx
  80151c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80151f:	b8 0a 00 00 00       	mov    $0xa,%eax
  801524:	e9 14 01 00 00       	jmp    80163d <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801529:	83 f9 01             	cmp    $0x1,%ecx
  80152c:	7e 18                	jle    801546 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  80152e:	8b 45 14             	mov    0x14(%ebp),%eax
  801531:	8b 10                	mov    (%eax),%edx
  801533:	8b 48 04             	mov    0x4(%eax),%ecx
  801536:	8d 40 08             	lea    0x8(%eax),%eax
  801539:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80153c:	b8 0a 00 00 00       	mov    $0xa,%eax
  801541:	e9 f7 00 00 00       	jmp    80163d <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  801546:	85 c9                	test   %ecx,%ecx
  801548:	74 1a                	je     801564 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  80154a:	8b 45 14             	mov    0x14(%ebp),%eax
  80154d:	8b 10                	mov    (%eax),%edx
  80154f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801554:	8d 40 04             	lea    0x4(%eax),%eax
  801557:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80155a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80155f:	e9 d9 00 00 00       	jmp    80163d <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  801564:	8b 45 14             	mov    0x14(%ebp),%eax
  801567:	8b 10                	mov    (%eax),%edx
  801569:	b9 00 00 00 00       	mov    $0x0,%ecx
  80156e:	8d 40 04             	lea    0x4(%eax),%eax
  801571:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801574:	b8 0a 00 00 00       	mov    $0xa,%eax
  801579:	e9 bf 00 00 00       	jmp    80163d <vprintfmt+0x437>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80157e:	83 f9 01             	cmp    $0x1,%ecx
  801581:	7e 13                	jle    801596 <vprintfmt+0x390>
		return va_arg(*ap, long long);
  801583:	8b 45 14             	mov    0x14(%ebp),%eax
  801586:	8b 50 04             	mov    0x4(%eax),%edx
  801589:	8b 00                	mov    (%eax),%eax
  80158b:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80158e:	8d 49 08             	lea    0x8(%ecx),%ecx
  801591:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801594:	eb 28                	jmp    8015be <vprintfmt+0x3b8>
	else if (lflag)
  801596:	85 c9                	test   %ecx,%ecx
  801598:	74 13                	je     8015ad <vprintfmt+0x3a7>
		return va_arg(*ap, long);
  80159a:	8b 45 14             	mov    0x14(%ebp),%eax
  80159d:	8b 10                	mov    (%eax),%edx
  80159f:	89 d0                	mov    %edx,%eax
  8015a1:	99                   	cltd   
  8015a2:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8015a5:	8d 49 04             	lea    0x4(%ecx),%ecx
  8015a8:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8015ab:	eb 11                	jmp    8015be <vprintfmt+0x3b8>
	else
		return va_arg(*ap, int);
  8015ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8015b0:	8b 10                	mov    (%eax),%edx
  8015b2:	89 d0                	mov    %edx,%eax
  8015b4:	99                   	cltd   
  8015b5:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8015b8:	8d 49 04             	lea    0x4(%ecx),%ecx
  8015bb:	89 4d 14             	mov    %ecx,0x14(%ebp)
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getint(&ap, lflag);
  8015be:	89 d1                	mov    %edx,%ecx
  8015c0:	89 c2                	mov    %eax,%edx
			base = 8;
  8015c2:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8015c7:	eb 74                	jmp    80163d <vprintfmt+0x437>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8015c9:	83 ec 08             	sub    $0x8,%esp
  8015cc:	53                   	push   %ebx
  8015cd:	6a 30                	push   $0x30
  8015cf:	ff d6                	call   *%esi
			putch('x', putdat);
  8015d1:	83 c4 08             	add    $0x8,%esp
  8015d4:	53                   	push   %ebx
  8015d5:	6a 78                	push   $0x78
  8015d7:	ff d6                	call   *%esi
			num = (unsigned long long)
  8015d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8015dc:	8b 10                	mov    (%eax),%edx
  8015de:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015e3:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8015e6:	8d 40 04             	lea    0x4(%eax),%eax
  8015e9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8015ec:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8015f1:	eb 4a                	jmp    80163d <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8015f3:	83 f9 01             	cmp    $0x1,%ecx
  8015f6:	7e 15                	jle    80160d <vprintfmt+0x407>
		return va_arg(*ap, unsigned long long);
  8015f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8015fb:	8b 10                	mov    (%eax),%edx
  8015fd:	8b 48 04             	mov    0x4(%eax),%ecx
  801600:	8d 40 08             	lea    0x8(%eax),%eax
  801603:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  801606:	b8 10 00 00 00       	mov    $0x10,%eax
  80160b:	eb 30                	jmp    80163d <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80160d:	85 c9                	test   %ecx,%ecx
  80160f:	74 17                	je     801628 <vprintfmt+0x422>
		return va_arg(*ap, unsigned long);
  801611:	8b 45 14             	mov    0x14(%ebp),%eax
  801614:	8b 10                	mov    (%eax),%edx
  801616:	b9 00 00 00 00       	mov    $0x0,%ecx
  80161b:	8d 40 04             	lea    0x4(%eax),%eax
  80161e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  801621:	b8 10 00 00 00       	mov    $0x10,%eax
  801626:	eb 15                	jmp    80163d <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  801628:	8b 45 14             	mov    0x14(%ebp),%eax
  80162b:	8b 10                	mov    (%eax),%edx
  80162d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801632:	8d 40 04             	lea    0x4(%eax),%eax
  801635:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  801638:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80163d:	83 ec 0c             	sub    $0xc,%esp
  801640:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801644:	57                   	push   %edi
  801645:	ff 75 e0             	pushl  -0x20(%ebp)
  801648:	50                   	push   %eax
  801649:	51                   	push   %ecx
  80164a:	52                   	push   %edx
  80164b:	89 da                	mov    %ebx,%edx
  80164d:	89 f0                	mov    %esi,%eax
  80164f:	e8 c9 fa ff ff       	call   80111d <printnum>
			break;
  801654:	83 c4 20             	add    $0x20,%esp
  801657:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80165a:	e9 cd fb ff ff       	jmp    80122c <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80165f:	83 ec 08             	sub    $0x8,%esp
  801662:	53                   	push   %ebx
  801663:	52                   	push   %edx
  801664:	ff d6                	call   *%esi
			break;
  801666:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801669:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80166c:	e9 bb fb ff ff       	jmp    80122c <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801671:	83 ec 08             	sub    $0x8,%esp
  801674:	53                   	push   %ebx
  801675:	6a 25                	push   $0x25
  801677:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801679:	83 c4 10             	add    $0x10,%esp
  80167c:	eb 03                	jmp    801681 <vprintfmt+0x47b>
  80167e:	83 ef 01             	sub    $0x1,%edi
  801681:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801685:	75 f7                	jne    80167e <vprintfmt+0x478>
  801687:	e9 a0 fb ff ff       	jmp    80122c <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80168c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80168f:	5b                   	pop    %ebx
  801690:	5e                   	pop    %esi
  801691:	5f                   	pop    %edi
  801692:	5d                   	pop    %ebp
  801693:	c3                   	ret    

00801694 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801694:	55                   	push   %ebp
  801695:	89 e5                	mov    %esp,%ebp
  801697:	83 ec 18             	sub    $0x18,%esp
  80169a:	8b 45 08             	mov    0x8(%ebp),%eax
  80169d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8016a0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8016a3:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8016a7:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8016aa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8016b1:	85 c0                	test   %eax,%eax
  8016b3:	74 26                	je     8016db <vsnprintf+0x47>
  8016b5:	85 d2                	test   %edx,%edx
  8016b7:	7e 22                	jle    8016db <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8016b9:	ff 75 14             	pushl  0x14(%ebp)
  8016bc:	ff 75 10             	pushl  0x10(%ebp)
  8016bf:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8016c2:	50                   	push   %eax
  8016c3:	68 cc 11 80 00       	push   $0x8011cc
  8016c8:	e8 39 fb ff ff       	call   801206 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8016cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8016d0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8016d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016d6:	83 c4 10             	add    $0x10,%esp
  8016d9:	eb 05                	jmp    8016e0 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8016db:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8016e0:	c9                   	leave  
  8016e1:	c3                   	ret    

008016e2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8016e2:	55                   	push   %ebp
  8016e3:	89 e5                	mov    %esp,%ebp
  8016e5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8016e8:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8016eb:	50                   	push   %eax
  8016ec:	ff 75 10             	pushl  0x10(%ebp)
  8016ef:	ff 75 0c             	pushl  0xc(%ebp)
  8016f2:	ff 75 08             	pushl  0x8(%ebp)
  8016f5:	e8 9a ff ff ff       	call   801694 <vsnprintf>
	va_end(ap);

	return rc;
}
  8016fa:	c9                   	leave  
  8016fb:	c3                   	ret    

008016fc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8016fc:	55                   	push   %ebp
  8016fd:	89 e5                	mov    %esp,%ebp
  8016ff:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801702:	b8 00 00 00 00       	mov    $0x0,%eax
  801707:	eb 03                	jmp    80170c <strlen+0x10>
		n++;
  801709:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80170c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801710:	75 f7                	jne    801709 <strlen+0xd>
		n++;
	return n;
}
  801712:	5d                   	pop    %ebp
  801713:	c3                   	ret    

00801714 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801714:	55                   	push   %ebp
  801715:	89 e5                	mov    %esp,%ebp
  801717:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80171a:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80171d:	ba 00 00 00 00       	mov    $0x0,%edx
  801722:	eb 03                	jmp    801727 <strnlen+0x13>
		n++;
  801724:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801727:	39 c2                	cmp    %eax,%edx
  801729:	74 08                	je     801733 <strnlen+0x1f>
  80172b:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80172f:	75 f3                	jne    801724 <strnlen+0x10>
  801731:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801733:	5d                   	pop    %ebp
  801734:	c3                   	ret    

00801735 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801735:	55                   	push   %ebp
  801736:	89 e5                	mov    %esp,%ebp
  801738:	53                   	push   %ebx
  801739:	8b 45 08             	mov    0x8(%ebp),%eax
  80173c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80173f:	89 c2                	mov    %eax,%edx
  801741:	83 c2 01             	add    $0x1,%edx
  801744:	83 c1 01             	add    $0x1,%ecx
  801747:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80174b:	88 5a ff             	mov    %bl,-0x1(%edx)
  80174e:	84 db                	test   %bl,%bl
  801750:	75 ef                	jne    801741 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801752:	5b                   	pop    %ebx
  801753:	5d                   	pop    %ebp
  801754:	c3                   	ret    

00801755 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801755:	55                   	push   %ebp
  801756:	89 e5                	mov    %esp,%ebp
  801758:	53                   	push   %ebx
  801759:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80175c:	53                   	push   %ebx
  80175d:	e8 9a ff ff ff       	call   8016fc <strlen>
  801762:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801765:	ff 75 0c             	pushl  0xc(%ebp)
  801768:	01 d8                	add    %ebx,%eax
  80176a:	50                   	push   %eax
  80176b:	e8 c5 ff ff ff       	call   801735 <strcpy>
	return dst;
}
  801770:	89 d8                	mov    %ebx,%eax
  801772:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801775:	c9                   	leave  
  801776:	c3                   	ret    

00801777 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801777:	55                   	push   %ebp
  801778:	89 e5                	mov    %esp,%ebp
  80177a:	56                   	push   %esi
  80177b:	53                   	push   %ebx
  80177c:	8b 75 08             	mov    0x8(%ebp),%esi
  80177f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801782:	89 f3                	mov    %esi,%ebx
  801784:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801787:	89 f2                	mov    %esi,%edx
  801789:	eb 0f                	jmp    80179a <strncpy+0x23>
		*dst++ = *src;
  80178b:	83 c2 01             	add    $0x1,%edx
  80178e:	0f b6 01             	movzbl (%ecx),%eax
  801791:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801794:	80 39 01             	cmpb   $0x1,(%ecx)
  801797:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80179a:	39 da                	cmp    %ebx,%edx
  80179c:	75 ed                	jne    80178b <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80179e:	89 f0                	mov    %esi,%eax
  8017a0:	5b                   	pop    %ebx
  8017a1:	5e                   	pop    %esi
  8017a2:	5d                   	pop    %ebp
  8017a3:	c3                   	ret    

008017a4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8017a4:	55                   	push   %ebp
  8017a5:	89 e5                	mov    %esp,%ebp
  8017a7:	56                   	push   %esi
  8017a8:	53                   	push   %ebx
  8017a9:	8b 75 08             	mov    0x8(%ebp),%esi
  8017ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017af:	8b 55 10             	mov    0x10(%ebp),%edx
  8017b2:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8017b4:	85 d2                	test   %edx,%edx
  8017b6:	74 21                	je     8017d9 <strlcpy+0x35>
  8017b8:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8017bc:	89 f2                	mov    %esi,%edx
  8017be:	eb 09                	jmp    8017c9 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8017c0:	83 c2 01             	add    $0x1,%edx
  8017c3:	83 c1 01             	add    $0x1,%ecx
  8017c6:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8017c9:	39 c2                	cmp    %eax,%edx
  8017cb:	74 09                	je     8017d6 <strlcpy+0x32>
  8017cd:	0f b6 19             	movzbl (%ecx),%ebx
  8017d0:	84 db                	test   %bl,%bl
  8017d2:	75 ec                	jne    8017c0 <strlcpy+0x1c>
  8017d4:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8017d6:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8017d9:	29 f0                	sub    %esi,%eax
}
  8017db:	5b                   	pop    %ebx
  8017dc:	5e                   	pop    %esi
  8017dd:	5d                   	pop    %ebp
  8017de:	c3                   	ret    

008017df <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8017df:	55                   	push   %ebp
  8017e0:	89 e5                	mov    %esp,%ebp
  8017e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017e5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8017e8:	eb 06                	jmp    8017f0 <strcmp+0x11>
		p++, q++;
  8017ea:	83 c1 01             	add    $0x1,%ecx
  8017ed:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8017f0:	0f b6 01             	movzbl (%ecx),%eax
  8017f3:	84 c0                	test   %al,%al
  8017f5:	74 04                	je     8017fb <strcmp+0x1c>
  8017f7:	3a 02                	cmp    (%edx),%al
  8017f9:	74 ef                	je     8017ea <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8017fb:	0f b6 c0             	movzbl %al,%eax
  8017fe:	0f b6 12             	movzbl (%edx),%edx
  801801:	29 d0                	sub    %edx,%eax
}
  801803:	5d                   	pop    %ebp
  801804:	c3                   	ret    

00801805 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801805:	55                   	push   %ebp
  801806:	89 e5                	mov    %esp,%ebp
  801808:	53                   	push   %ebx
  801809:	8b 45 08             	mov    0x8(%ebp),%eax
  80180c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80180f:	89 c3                	mov    %eax,%ebx
  801811:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801814:	eb 06                	jmp    80181c <strncmp+0x17>
		n--, p++, q++;
  801816:	83 c0 01             	add    $0x1,%eax
  801819:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80181c:	39 d8                	cmp    %ebx,%eax
  80181e:	74 15                	je     801835 <strncmp+0x30>
  801820:	0f b6 08             	movzbl (%eax),%ecx
  801823:	84 c9                	test   %cl,%cl
  801825:	74 04                	je     80182b <strncmp+0x26>
  801827:	3a 0a                	cmp    (%edx),%cl
  801829:	74 eb                	je     801816 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80182b:	0f b6 00             	movzbl (%eax),%eax
  80182e:	0f b6 12             	movzbl (%edx),%edx
  801831:	29 d0                	sub    %edx,%eax
  801833:	eb 05                	jmp    80183a <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801835:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80183a:	5b                   	pop    %ebx
  80183b:	5d                   	pop    %ebp
  80183c:	c3                   	ret    

0080183d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80183d:	55                   	push   %ebp
  80183e:	89 e5                	mov    %esp,%ebp
  801840:	8b 45 08             	mov    0x8(%ebp),%eax
  801843:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801847:	eb 07                	jmp    801850 <strchr+0x13>
		if (*s == c)
  801849:	38 ca                	cmp    %cl,%dl
  80184b:	74 0f                	je     80185c <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80184d:	83 c0 01             	add    $0x1,%eax
  801850:	0f b6 10             	movzbl (%eax),%edx
  801853:	84 d2                	test   %dl,%dl
  801855:	75 f2                	jne    801849 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801857:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80185c:	5d                   	pop    %ebp
  80185d:	c3                   	ret    

0080185e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80185e:	55                   	push   %ebp
  80185f:	89 e5                	mov    %esp,%ebp
  801861:	8b 45 08             	mov    0x8(%ebp),%eax
  801864:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801868:	eb 03                	jmp    80186d <strfind+0xf>
  80186a:	83 c0 01             	add    $0x1,%eax
  80186d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801870:	38 ca                	cmp    %cl,%dl
  801872:	74 04                	je     801878 <strfind+0x1a>
  801874:	84 d2                	test   %dl,%dl
  801876:	75 f2                	jne    80186a <strfind+0xc>
			break;
	return (char *) s;
}
  801878:	5d                   	pop    %ebp
  801879:	c3                   	ret    

0080187a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80187a:	55                   	push   %ebp
  80187b:	89 e5                	mov    %esp,%ebp
  80187d:	57                   	push   %edi
  80187e:	56                   	push   %esi
  80187f:	53                   	push   %ebx
  801880:	8b 7d 08             	mov    0x8(%ebp),%edi
  801883:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801886:	85 c9                	test   %ecx,%ecx
  801888:	74 36                	je     8018c0 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80188a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801890:	75 28                	jne    8018ba <memset+0x40>
  801892:	f6 c1 03             	test   $0x3,%cl
  801895:	75 23                	jne    8018ba <memset+0x40>
		c &= 0xFF;
  801897:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80189b:	89 d3                	mov    %edx,%ebx
  80189d:	c1 e3 08             	shl    $0x8,%ebx
  8018a0:	89 d6                	mov    %edx,%esi
  8018a2:	c1 e6 18             	shl    $0x18,%esi
  8018a5:	89 d0                	mov    %edx,%eax
  8018a7:	c1 e0 10             	shl    $0x10,%eax
  8018aa:	09 f0                	or     %esi,%eax
  8018ac:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8018ae:	89 d8                	mov    %ebx,%eax
  8018b0:	09 d0                	or     %edx,%eax
  8018b2:	c1 e9 02             	shr    $0x2,%ecx
  8018b5:	fc                   	cld    
  8018b6:	f3 ab                	rep stos %eax,%es:(%edi)
  8018b8:	eb 06                	jmp    8018c0 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8018ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018bd:	fc                   	cld    
  8018be:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8018c0:	89 f8                	mov    %edi,%eax
  8018c2:	5b                   	pop    %ebx
  8018c3:	5e                   	pop    %esi
  8018c4:	5f                   	pop    %edi
  8018c5:	5d                   	pop    %ebp
  8018c6:	c3                   	ret    

008018c7 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8018c7:	55                   	push   %ebp
  8018c8:	89 e5                	mov    %esp,%ebp
  8018ca:	57                   	push   %edi
  8018cb:	56                   	push   %esi
  8018cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8018cf:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018d2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8018d5:	39 c6                	cmp    %eax,%esi
  8018d7:	73 35                	jae    80190e <memmove+0x47>
  8018d9:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8018dc:	39 d0                	cmp    %edx,%eax
  8018de:	73 2e                	jae    80190e <memmove+0x47>
		s += n;
		d += n;
  8018e0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018e3:	89 d6                	mov    %edx,%esi
  8018e5:	09 fe                	or     %edi,%esi
  8018e7:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018ed:	75 13                	jne    801902 <memmove+0x3b>
  8018ef:	f6 c1 03             	test   $0x3,%cl
  8018f2:	75 0e                	jne    801902 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8018f4:	83 ef 04             	sub    $0x4,%edi
  8018f7:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018fa:	c1 e9 02             	shr    $0x2,%ecx
  8018fd:	fd                   	std    
  8018fe:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801900:	eb 09                	jmp    80190b <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801902:	83 ef 01             	sub    $0x1,%edi
  801905:	8d 72 ff             	lea    -0x1(%edx),%esi
  801908:	fd                   	std    
  801909:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80190b:	fc                   	cld    
  80190c:	eb 1d                	jmp    80192b <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80190e:	89 f2                	mov    %esi,%edx
  801910:	09 c2                	or     %eax,%edx
  801912:	f6 c2 03             	test   $0x3,%dl
  801915:	75 0f                	jne    801926 <memmove+0x5f>
  801917:	f6 c1 03             	test   $0x3,%cl
  80191a:	75 0a                	jne    801926 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80191c:	c1 e9 02             	shr    $0x2,%ecx
  80191f:	89 c7                	mov    %eax,%edi
  801921:	fc                   	cld    
  801922:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801924:	eb 05                	jmp    80192b <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801926:	89 c7                	mov    %eax,%edi
  801928:	fc                   	cld    
  801929:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80192b:	5e                   	pop    %esi
  80192c:	5f                   	pop    %edi
  80192d:	5d                   	pop    %ebp
  80192e:	c3                   	ret    

0080192f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80192f:	55                   	push   %ebp
  801930:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801932:	ff 75 10             	pushl  0x10(%ebp)
  801935:	ff 75 0c             	pushl  0xc(%ebp)
  801938:	ff 75 08             	pushl  0x8(%ebp)
  80193b:	e8 87 ff ff ff       	call   8018c7 <memmove>
}
  801940:	c9                   	leave  
  801941:	c3                   	ret    

00801942 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801942:	55                   	push   %ebp
  801943:	89 e5                	mov    %esp,%ebp
  801945:	56                   	push   %esi
  801946:	53                   	push   %ebx
  801947:	8b 45 08             	mov    0x8(%ebp),%eax
  80194a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80194d:	89 c6                	mov    %eax,%esi
  80194f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801952:	eb 1a                	jmp    80196e <memcmp+0x2c>
		if (*s1 != *s2)
  801954:	0f b6 08             	movzbl (%eax),%ecx
  801957:	0f b6 1a             	movzbl (%edx),%ebx
  80195a:	38 d9                	cmp    %bl,%cl
  80195c:	74 0a                	je     801968 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80195e:	0f b6 c1             	movzbl %cl,%eax
  801961:	0f b6 db             	movzbl %bl,%ebx
  801964:	29 d8                	sub    %ebx,%eax
  801966:	eb 0f                	jmp    801977 <memcmp+0x35>
		s1++, s2++;
  801968:	83 c0 01             	add    $0x1,%eax
  80196b:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80196e:	39 f0                	cmp    %esi,%eax
  801970:	75 e2                	jne    801954 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801972:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801977:	5b                   	pop    %ebx
  801978:	5e                   	pop    %esi
  801979:	5d                   	pop    %ebp
  80197a:	c3                   	ret    

0080197b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80197b:	55                   	push   %ebp
  80197c:	89 e5                	mov    %esp,%ebp
  80197e:	53                   	push   %ebx
  80197f:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801982:	89 c1                	mov    %eax,%ecx
  801984:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801987:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80198b:	eb 0a                	jmp    801997 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80198d:	0f b6 10             	movzbl (%eax),%edx
  801990:	39 da                	cmp    %ebx,%edx
  801992:	74 07                	je     80199b <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801994:	83 c0 01             	add    $0x1,%eax
  801997:	39 c8                	cmp    %ecx,%eax
  801999:	72 f2                	jb     80198d <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80199b:	5b                   	pop    %ebx
  80199c:	5d                   	pop    %ebp
  80199d:	c3                   	ret    

0080199e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80199e:	55                   	push   %ebp
  80199f:	89 e5                	mov    %esp,%ebp
  8019a1:	57                   	push   %edi
  8019a2:	56                   	push   %esi
  8019a3:	53                   	push   %ebx
  8019a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019a7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8019aa:	eb 03                	jmp    8019af <strtol+0x11>
		s++;
  8019ac:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8019af:	0f b6 01             	movzbl (%ecx),%eax
  8019b2:	3c 20                	cmp    $0x20,%al
  8019b4:	74 f6                	je     8019ac <strtol+0xe>
  8019b6:	3c 09                	cmp    $0x9,%al
  8019b8:	74 f2                	je     8019ac <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8019ba:	3c 2b                	cmp    $0x2b,%al
  8019bc:	75 0a                	jne    8019c8 <strtol+0x2a>
		s++;
  8019be:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8019c1:	bf 00 00 00 00       	mov    $0x0,%edi
  8019c6:	eb 11                	jmp    8019d9 <strtol+0x3b>
  8019c8:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8019cd:	3c 2d                	cmp    $0x2d,%al
  8019cf:	75 08                	jne    8019d9 <strtol+0x3b>
		s++, neg = 1;
  8019d1:	83 c1 01             	add    $0x1,%ecx
  8019d4:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019d9:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8019df:	75 15                	jne    8019f6 <strtol+0x58>
  8019e1:	80 39 30             	cmpb   $0x30,(%ecx)
  8019e4:	75 10                	jne    8019f6 <strtol+0x58>
  8019e6:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8019ea:	75 7c                	jne    801a68 <strtol+0xca>
		s += 2, base = 16;
  8019ec:	83 c1 02             	add    $0x2,%ecx
  8019ef:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019f4:	eb 16                	jmp    801a0c <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8019f6:	85 db                	test   %ebx,%ebx
  8019f8:	75 12                	jne    801a0c <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8019fa:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019ff:	80 39 30             	cmpb   $0x30,(%ecx)
  801a02:	75 08                	jne    801a0c <strtol+0x6e>
		s++, base = 8;
  801a04:	83 c1 01             	add    $0x1,%ecx
  801a07:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801a0c:	b8 00 00 00 00       	mov    $0x0,%eax
  801a11:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801a14:	0f b6 11             	movzbl (%ecx),%edx
  801a17:	8d 72 d0             	lea    -0x30(%edx),%esi
  801a1a:	89 f3                	mov    %esi,%ebx
  801a1c:	80 fb 09             	cmp    $0x9,%bl
  801a1f:	77 08                	ja     801a29 <strtol+0x8b>
			dig = *s - '0';
  801a21:	0f be d2             	movsbl %dl,%edx
  801a24:	83 ea 30             	sub    $0x30,%edx
  801a27:	eb 22                	jmp    801a4b <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801a29:	8d 72 9f             	lea    -0x61(%edx),%esi
  801a2c:	89 f3                	mov    %esi,%ebx
  801a2e:	80 fb 19             	cmp    $0x19,%bl
  801a31:	77 08                	ja     801a3b <strtol+0x9d>
			dig = *s - 'a' + 10;
  801a33:	0f be d2             	movsbl %dl,%edx
  801a36:	83 ea 57             	sub    $0x57,%edx
  801a39:	eb 10                	jmp    801a4b <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801a3b:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a3e:	89 f3                	mov    %esi,%ebx
  801a40:	80 fb 19             	cmp    $0x19,%bl
  801a43:	77 16                	ja     801a5b <strtol+0xbd>
			dig = *s - 'A' + 10;
  801a45:	0f be d2             	movsbl %dl,%edx
  801a48:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801a4b:	3b 55 10             	cmp    0x10(%ebp),%edx
  801a4e:	7d 0b                	jge    801a5b <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801a50:	83 c1 01             	add    $0x1,%ecx
  801a53:	0f af 45 10          	imul   0x10(%ebp),%eax
  801a57:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801a59:	eb b9                	jmp    801a14 <strtol+0x76>

	if (endptr)
  801a5b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a5f:	74 0d                	je     801a6e <strtol+0xd0>
		*endptr = (char *) s;
  801a61:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a64:	89 0e                	mov    %ecx,(%esi)
  801a66:	eb 06                	jmp    801a6e <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801a68:	85 db                	test   %ebx,%ebx
  801a6a:	74 98                	je     801a04 <strtol+0x66>
  801a6c:	eb 9e                	jmp    801a0c <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801a6e:	89 c2                	mov    %eax,%edx
  801a70:	f7 da                	neg    %edx
  801a72:	85 ff                	test   %edi,%edi
  801a74:	0f 45 c2             	cmovne %edx,%eax
}
  801a77:	5b                   	pop    %ebx
  801a78:	5e                   	pop    %esi
  801a79:	5f                   	pop    %edi
  801a7a:	5d                   	pop    %ebp
  801a7b:	c3                   	ret    

00801a7c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a7c:	55                   	push   %ebp
  801a7d:	89 e5                	mov    %esp,%ebp
  801a7f:	56                   	push   %esi
  801a80:	53                   	push   %ebx
  801a81:	8b 75 08             	mov    0x8(%ebp),%esi
  801a84:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a87:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int ret;
	if (pg) ret = sys_ipc_recv(pg);
  801a8a:	85 c0                	test   %eax,%eax
  801a8c:	74 0e                	je     801a9c <ipc_recv+0x20>
  801a8e:	83 ec 0c             	sub    $0xc,%esp
  801a91:	50                   	push   %eax
  801a92:	e8 9a e8 ff ff       	call   800331 <sys_ipc_recv>
  801a97:	83 c4 10             	add    $0x10,%esp
  801a9a:	eb 10                	jmp    801aac <ipc_recv+0x30>
	else ret = sys_ipc_recv((void*)UTOP);
  801a9c:	83 ec 0c             	sub    $0xc,%esp
  801a9f:	68 00 00 c0 ee       	push   $0xeec00000
  801aa4:	e8 88 e8 ff ff       	call   800331 <sys_ipc_recv>
  801aa9:	83 c4 10             	add    $0x10,%esp
	if (ret) {
  801aac:	85 c0                	test   %eax,%eax
  801aae:	74 16                	je     801ac6 <ipc_recv+0x4a>
		if (from_env_store) *from_env_store = 0;
  801ab0:	85 f6                	test   %esi,%esi
  801ab2:	74 06                	je     801aba <ipc_recv+0x3e>
  801ab4:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  801aba:	85 db                	test   %ebx,%ebx
  801abc:	74 2c                	je     801aea <ipc_recv+0x6e>
  801abe:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801ac4:	eb 24                	jmp    801aea <ipc_recv+0x6e>
		return ret;
	}
	if (from_env_store) *from_env_store = thisenv->env_ipc_from;
  801ac6:	85 f6                	test   %esi,%esi
  801ac8:	74 0a                	je     801ad4 <ipc_recv+0x58>
  801aca:	a1 04 40 80 00       	mov    0x804004,%eax
  801acf:	8b 40 74             	mov    0x74(%eax),%eax
  801ad2:	89 06                	mov    %eax,(%esi)
	if (perm_store) *perm_store = thisenv->env_ipc_perm;
  801ad4:	85 db                	test   %ebx,%ebx
  801ad6:	74 0a                	je     801ae2 <ipc_recv+0x66>
  801ad8:	a1 04 40 80 00       	mov    0x804004,%eax
  801add:	8b 40 78             	mov    0x78(%eax),%eax
  801ae0:	89 03                	mov    %eax,(%ebx)

	// panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801ae2:	a1 04 40 80 00       	mov    0x804004,%eax
  801ae7:	8b 40 70             	mov    0x70(%eax),%eax
}
  801aea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aed:	5b                   	pop    %ebx
  801aee:	5e                   	pop    %esi
  801aef:	5d                   	pop    %ebp
  801af0:	c3                   	ret    

00801af1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801af1:	55                   	push   %ebp
  801af2:	89 e5                	mov    %esp,%ebp
  801af4:	57                   	push   %edi
  801af5:	56                   	push   %esi
  801af6:	53                   	push   %ebx
  801af7:	83 ec 0c             	sub    $0xc,%esp
  801afa:	8b 7d 08             	mov    0x8(%ebp),%edi
  801afd:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b00:	8b 45 10             	mov    0x10(%ebp),%eax
  801b03:	85 c0                	test   %eax,%eax
  801b05:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801b0a:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	while (true) {
		void* srcva = (pg)? pg: (void*)UTOP;
		int ret = sys_ipc_try_send(to_env, val, srcva, perm);
  801b0d:	ff 75 14             	pushl  0x14(%ebp)
  801b10:	53                   	push   %ebx
  801b11:	56                   	push   %esi
  801b12:	57                   	push   %edi
  801b13:	e8 f6 e7 ff ff       	call   80030e <sys_ipc_try_send>
		if (ret == 0) break;
  801b18:	83 c4 10             	add    $0x10,%esp
  801b1b:	85 c0                	test   %eax,%eax
  801b1d:	74 1e                	je     801b3d <ipc_send+0x4c>
		if (ret != -E_IPC_NOT_RECV) panic("ipc_send: %e", ret);
  801b1f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b22:	74 12                	je     801b36 <ipc_send+0x45>
  801b24:	50                   	push   %eax
  801b25:	68 c0 22 80 00       	push   $0x8022c0
  801b2a:	6a 39                	push   $0x39
  801b2c:	68 cd 22 80 00       	push   $0x8022cd
  801b31:	e8 fa f4 ff ff       	call   801030 <_panic>
		sys_yield();
  801b36:	e8 27 e6 ff ff       	call   800162 <sys_yield>
	}
  801b3b:	eb d0                	jmp    801b0d <ipc_send+0x1c>
	// panic("ipc_send not implemented");
}
  801b3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b40:	5b                   	pop    %ebx
  801b41:	5e                   	pop    %esi
  801b42:	5f                   	pop    %edi
  801b43:	5d                   	pop    %ebp
  801b44:	c3                   	ret    

00801b45 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b45:	55                   	push   %ebp
  801b46:	89 e5                	mov    %esp,%ebp
  801b48:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b4b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b50:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b53:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b59:	8b 52 50             	mov    0x50(%edx),%edx
  801b5c:	39 ca                	cmp    %ecx,%edx
  801b5e:	75 0d                	jne    801b6d <ipc_find_env+0x28>
			return envs[i].env_id;
  801b60:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b63:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b68:	8b 40 48             	mov    0x48(%eax),%eax
  801b6b:	eb 0f                	jmp    801b7c <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b6d:	83 c0 01             	add    $0x1,%eax
  801b70:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b75:	75 d9                	jne    801b50 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b77:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b7c:	5d                   	pop    %ebp
  801b7d:	c3                   	ret    

00801b7e <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b7e:	55                   	push   %ebp
  801b7f:	89 e5                	mov    %esp,%ebp
  801b81:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b84:	89 d0                	mov    %edx,%eax
  801b86:	c1 e8 16             	shr    $0x16,%eax
  801b89:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b90:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b95:	f6 c1 01             	test   $0x1,%cl
  801b98:	74 1d                	je     801bb7 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b9a:	c1 ea 0c             	shr    $0xc,%edx
  801b9d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801ba4:	f6 c2 01             	test   $0x1,%dl
  801ba7:	74 0e                	je     801bb7 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ba9:	c1 ea 0c             	shr    $0xc,%edx
  801bac:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801bb3:	ef 
  801bb4:	0f b7 c0             	movzwl %ax,%eax
}
  801bb7:	5d                   	pop    %ebp
  801bb8:	c3                   	ret    
  801bb9:	66 90                	xchg   %ax,%ax
  801bbb:	66 90                	xchg   %ax,%ax
  801bbd:	66 90                	xchg   %ax,%ax
  801bbf:	90                   	nop

00801bc0 <__udivdi3>:
  801bc0:	55                   	push   %ebp
  801bc1:	57                   	push   %edi
  801bc2:	56                   	push   %esi
  801bc3:	53                   	push   %ebx
  801bc4:	83 ec 1c             	sub    $0x1c,%esp
  801bc7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801bcb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801bcf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801bd3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801bd7:	85 f6                	test   %esi,%esi
  801bd9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bdd:	89 ca                	mov    %ecx,%edx
  801bdf:	89 f8                	mov    %edi,%eax
  801be1:	75 3d                	jne    801c20 <__udivdi3+0x60>
  801be3:	39 cf                	cmp    %ecx,%edi
  801be5:	0f 87 c5 00 00 00    	ja     801cb0 <__udivdi3+0xf0>
  801beb:	85 ff                	test   %edi,%edi
  801bed:	89 fd                	mov    %edi,%ebp
  801bef:	75 0b                	jne    801bfc <__udivdi3+0x3c>
  801bf1:	b8 01 00 00 00       	mov    $0x1,%eax
  801bf6:	31 d2                	xor    %edx,%edx
  801bf8:	f7 f7                	div    %edi
  801bfa:	89 c5                	mov    %eax,%ebp
  801bfc:	89 c8                	mov    %ecx,%eax
  801bfe:	31 d2                	xor    %edx,%edx
  801c00:	f7 f5                	div    %ebp
  801c02:	89 c1                	mov    %eax,%ecx
  801c04:	89 d8                	mov    %ebx,%eax
  801c06:	89 cf                	mov    %ecx,%edi
  801c08:	f7 f5                	div    %ebp
  801c0a:	89 c3                	mov    %eax,%ebx
  801c0c:	89 d8                	mov    %ebx,%eax
  801c0e:	89 fa                	mov    %edi,%edx
  801c10:	83 c4 1c             	add    $0x1c,%esp
  801c13:	5b                   	pop    %ebx
  801c14:	5e                   	pop    %esi
  801c15:	5f                   	pop    %edi
  801c16:	5d                   	pop    %ebp
  801c17:	c3                   	ret    
  801c18:	90                   	nop
  801c19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c20:	39 ce                	cmp    %ecx,%esi
  801c22:	77 74                	ja     801c98 <__udivdi3+0xd8>
  801c24:	0f bd fe             	bsr    %esi,%edi
  801c27:	83 f7 1f             	xor    $0x1f,%edi
  801c2a:	0f 84 98 00 00 00    	je     801cc8 <__udivdi3+0x108>
  801c30:	bb 20 00 00 00       	mov    $0x20,%ebx
  801c35:	89 f9                	mov    %edi,%ecx
  801c37:	89 c5                	mov    %eax,%ebp
  801c39:	29 fb                	sub    %edi,%ebx
  801c3b:	d3 e6                	shl    %cl,%esi
  801c3d:	89 d9                	mov    %ebx,%ecx
  801c3f:	d3 ed                	shr    %cl,%ebp
  801c41:	89 f9                	mov    %edi,%ecx
  801c43:	d3 e0                	shl    %cl,%eax
  801c45:	09 ee                	or     %ebp,%esi
  801c47:	89 d9                	mov    %ebx,%ecx
  801c49:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c4d:	89 d5                	mov    %edx,%ebp
  801c4f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801c53:	d3 ed                	shr    %cl,%ebp
  801c55:	89 f9                	mov    %edi,%ecx
  801c57:	d3 e2                	shl    %cl,%edx
  801c59:	89 d9                	mov    %ebx,%ecx
  801c5b:	d3 e8                	shr    %cl,%eax
  801c5d:	09 c2                	or     %eax,%edx
  801c5f:	89 d0                	mov    %edx,%eax
  801c61:	89 ea                	mov    %ebp,%edx
  801c63:	f7 f6                	div    %esi
  801c65:	89 d5                	mov    %edx,%ebp
  801c67:	89 c3                	mov    %eax,%ebx
  801c69:	f7 64 24 0c          	mull   0xc(%esp)
  801c6d:	39 d5                	cmp    %edx,%ebp
  801c6f:	72 10                	jb     801c81 <__udivdi3+0xc1>
  801c71:	8b 74 24 08          	mov    0x8(%esp),%esi
  801c75:	89 f9                	mov    %edi,%ecx
  801c77:	d3 e6                	shl    %cl,%esi
  801c79:	39 c6                	cmp    %eax,%esi
  801c7b:	73 07                	jae    801c84 <__udivdi3+0xc4>
  801c7d:	39 d5                	cmp    %edx,%ebp
  801c7f:	75 03                	jne    801c84 <__udivdi3+0xc4>
  801c81:	83 eb 01             	sub    $0x1,%ebx
  801c84:	31 ff                	xor    %edi,%edi
  801c86:	89 d8                	mov    %ebx,%eax
  801c88:	89 fa                	mov    %edi,%edx
  801c8a:	83 c4 1c             	add    $0x1c,%esp
  801c8d:	5b                   	pop    %ebx
  801c8e:	5e                   	pop    %esi
  801c8f:	5f                   	pop    %edi
  801c90:	5d                   	pop    %ebp
  801c91:	c3                   	ret    
  801c92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c98:	31 ff                	xor    %edi,%edi
  801c9a:	31 db                	xor    %ebx,%ebx
  801c9c:	89 d8                	mov    %ebx,%eax
  801c9e:	89 fa                	mov    %edi,%edx
  801ca0:	83 c4 1c             	add    $0x1c,%esp
  801ca3:	5b                   	pop    %ebx
  801ca4:	5e                   	pop    %esi
  801ca5:	5f                   	pop    %edi
  801ca6:	5d                   	pop    %ebp
  801ca7:	c3                   	ret    
  801ca8:	90                   	nop
  801ca9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cb0:	89 d8                	mov    %ebx,%eax
  801cb2:	f7 f7                	div    %edi
  801cb4:	31 ff                	xor    %edi,%edi
  801cb6:	89 c3                	mov    %eax,%ebx
  801cb8:	89 d8                	mov    %ebx,%eax
  801cba:	89 fa                	mov    %edi,%edx
  801cbc:	83 c4 1c             	add    $0x1c,%esp
  801cbf:	5b                   	pop    %ebx
  801cc0:	5e                   	pop    %esi
  801cc1:	5f                   	pop    %edi
  801cc2:	5d                   	pop    %ebp
  801cc3:	c3                   	ret    
  801cc4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801cc8:	39 ce                	cmp    %ecx,%esi
  801cca:	72 0c                	jb     801cd8 <__udivdi3+0x118>
  801ccc:	31 db                	xor    %ebx,%ebx
  801cce:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801cd2:	0f 87 34 ff ff ff    	ja     801c0c <__udivdi3+0x4c>
  801cd8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801cdd:	e9 2a ff ff ff       	jmp    801c0c <__udivdi3+0x4c>
  801ce2:	66 90                	xchg   %ax,%ax
  801ce4:	66 90                	xchg   %ax,%ax
  801ce6:	66 90                	xchg   %ax,%ax
  801ce8:	66 90                	xchg   %ax,%ax
  801cea:	66 90                	xchg   %ax,%ax
  801cec:	66 90                	xchg   %ax,%ax
  801cee:	66 90                	xchg   %ax,%ax

00801cf0 <__umoddi3>:
  801cf0:	55                   	push   %ebp
  801cf1:	57                   	push   %edi
  801cf2:	56                   	push   %esi
  801cf3:	53                   	push   %ebx
  801cf4:	83 ec 1c             	sub    $0x1c,%esp
  801cf7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801cfb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801cff:	8b 74 24 34          	mov    0x34(%esp),%esi
  801d03:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d07:	85 d2                	test   %edx,%edx
  801d09:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801d0d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d11:	89 f3                	mov    %esi,%ebx
  801d13:	89 3c 24             	mov    %edi,(%esp)
  801d16:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d1a:	75 1c                	jne    801d38 <__umoddi3+0x48>
  801d1c:	39 f7                	cmp    %esi,%edi
  801d1e:	76 50                	jbe    801d70 <__umoddi3+0x80>
  801d20:	89 c8                	mov    %ecx,%eax
  801d22:	89 f2                	mov    %esi,%edx
  801d24:	f7 f7                	div    %edi
  801d26:	89 d0                	mov    %edx,%eax
  801d28:	31 d2                	xor    %edx,%edx
  801d2a:	83 c4 1c             	add    $0x1c,%esp
  801d2d:	5b                   	pop    %ebx
  801d2e:	5e                   	pop    %esi
  801d2f:	5f                   	pop    %edi
  801d30:	5d                   	pop    %ebp
  801d31:	c3                   	ret    
  801d32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d38:	39 f2                	cmp    %esi,%edx
  801d3a:	89 d0                	mov    %edx,%eax
  801d3c:	77 52                	ja     801d90 <__umoddi3+0xa0>
  801d3e:	0f bd ea             	bsr    %edx,%ebp
  801d41:	83 f5 1f             	xor    $0x1f,%ebp
  801d44:	75 5a                	jne    801da0 <__umoddi3+0xb0>
  801d46:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801d4a:	0f 82 e0 00 00 00    	jb     801e30 <__umoddi3+0x140>
  801d50:	39 0c 24             	cmp    %ecx,(%esp)
  801d53:	0f 86 d7 00 00 00    	jbe    801e30 <__umoddi3+0x140>
  801d59:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d5d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d61:	83 c4 1c             	add    $0x1c,%esp
  801d64:	5b                   	pop    %ebx
  801d65:	5e                   	pop    %esi
  801d66:	5f                   	pop    %edi
  801d67:	5d                   	pop    %ebp
  801d68:	c3                   	ret    
  801d69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d70:	85 ff                	test   %edi,%edi
  801d72:	89 fd                	mov    %edi,%ebp
  801d74:	75 0b                	jne    801d81 <__umoddi3+0x91>
  801d76:	b8 01 00 00 00       	mov    $0x1,%eax
  801d7b:	31 d2                	xor    %edx,%edx
  801d7d:	f7 f7                	div    %edi
  801d7f:	89 c5                	mov    %eax,%ebp
  801d81:	89 f0                	mov    %esi,%eax
  801d83:	31 d2                	xor    %edx,%edx
  801d85:	f7 f5                	div    %ebp
  801d87:	89 c8                	mov    %ecx,%eax
  801d89:	f7 f5                	div    %ebp
  801d8b:	89 d0                	mov    %edx,%eax
  801d8d:	eb 99                	jmp    801d28 <__umoddi3+0x38>
  801d8f:	90                   	nop
  801d90:	89 c8                	mov    %ecx,%eax
  801d92:	89 f2                	mov    %esi,%edx
  801d94:	83 c4 1c             	add    $0x1c,%esp
  801d97:	5b                   	pop    %ebx
  801d98:	5e                   	pop    %esi
  801d99:	5f                   	pop    %edi
  801d9a:	5d                   	pop    %ebp
  801d9b:	c3                   	ret    
  801d9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801da0:	8b 34 24             	mov    (%esp),%esi
  801da3:	bf 20 00 00 00       	mov    $0x20,%edi
  801da8:	89 e9                	mov    %ebp,%ecx
  801daa:	29 ef                	sub    %ebp,%edi
  801dac:	d3 e0                	shl    %cl,%eax
  801dae:	89 f9                	mov    %edi,%ecx
  801db0:	89 f2                	mov    %esi,%edx
  801db2:	d3 ea                	shr    %cl,%edx
  801db4:	89 e9                	mov    %ebp,%ecx
  801db6:	09 c2                	or     %eax,%edx
  801db8:	89 d8                	mov    %ebx,%eax
  801dba:	89 14 24             	mov    %edx,(%esp)
  801dbd:	89 f2                	mov    %esi,%edx
  801dbf:	d3 e2                	shl    %cl,%edx
  801dc1:	89 f9                	mov    %edi,%ecx
  801dc3:	89 54 24 04          	mov    %edx,0x4(%esp)
  801dc7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801dcb:	d3 e8                	shr    %cl,%eax
  801dcd:	89 e9                	mov    %ebp,%ecx
  801dcf:	89 c6                	mov    %eax,%esi
  801dd1:	d3 e3                	shl    %cl,%ebx
  801dd3:	89 f9                	mov    %edi,%ecx
  801dd5:	89 d0                	mov    %edx,%eax
  801dd7:	d3 e8                	shr    %cl,%eax
  801dd9:	89 e9                	mov    %ebp,%ecx
  801ddb:	09 d8                	or     %ebx,%eax
  801ddd:	89 d3                	mov    %edx,%ebx
  801ddf:	89 f2                	mov    %esi,%edx
  801de1:	f7 34 24             	divl   (%esp)
  801de4:	89 d6                	mov    %edx,%esi
  801de6:	d3 e3                	shl    %cl,%ebx
  801de8:	f7 64 24 04          	mull   0x4(%esp)
  801dec:	39 d6                	cmp    %edx,%esi
  801dee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801df2:	89 d1                	mov    %edx,%ecx
  801df4:	89 c3                	mov    %eax,%ebx
  801df6:	72 08                	jb     801e00 <__umoddi3+0x110>
  801df8:	75 11                	jne    801e0b <__umoddi3+0x11b>
  801dfa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801dfe:	73 0b                	jae    801e0b <__umoddi3+0x11b>
  801e00:	2b 44 24 04          	sub    0x4(%esp),%eax
  801e04:	1b 14 24             	sbb    (%esp),%edx
  801e07:	89 d1                	mov    %edx,%ecx
  801e09:	89 c3                	mov    %eax,%ebx
  801e0b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801e0f:	29 da                	sub    %ebx,%edx
  801e11:	19 ce                	sbb    %ecx,%esi
  801e13:	89 f9                	mov    %edi,%ecx
  801e15:	89 f0                	mov    %esi,%eax
  801e17:	d3 e0                	shl    %cl,%eax
  801e19:	89 e9                	mov    %ebp,%ecx
  801e1b:	d3 ea                	shr    %cl,%edx
  801e1d:	89 e9                	mov    %ebp,%ecx
  801e1f:	d3 ee                	shr    %cl,%esi
  801e21:	09 d0                	or     %edx,%eax
  801e23:	89 f2                	mov    %esi,%edx
  801e25:	83 c4 1c             	add    $0x1c,%esp
  801e28:	5b                   	pop    %ebx
  801e29:	5e                   	pop    %esi
  801e2a:	5f                   	pop    %edi
  801e2b:	5d                   	pop    %ebp
  801e2c:	c3                   	ret    
  801e2d:	8d 76 00             	lea    0x0(%esi),%esi
  801e30:	29 f9                	sub    %edi,%ecx
  801e32:	19 d6                	sbb    %edx,%esi
  801e34:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e38:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e3c:	e9 18 ff ff ff       	jmp    801d59 <__umoddi3+0x69>
