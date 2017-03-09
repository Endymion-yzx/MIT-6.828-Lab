
obj/boot/boot.out:     file format elf32-i386


Disassembly of section .text:

00007c00 <start>:
.set CR0_PE_ON,      0x1         # protected mode enable flag

.globl start
start:
  .code16                     # Assemble for 16-bit mode
  cli                         # Disable interrupts
    7c00:	fa                   	cli    
  cld                         # String operations increment
    7c01:	fc                   	cld    

  # Set up the important data segment registers (DS, ES, SS).
  xorw    %ax,%ax             # Segment number zero
    7c02:	31 c0                	xor    %eax,%eax
  movw    %ax,%ds             # -> Data Segment
    7c04:	8e d8                	mov    %eax,%ds
  movw    %ax,%es             # -> Extra Segment
    7c06:	8e c0                	mov    %eax,%es
  movw    %ax,%ss             # -> Stack Segment
    7c08:	8e d0                	mov    %eax,%ss

00007c0a <seta20.1>:
  # Enable A20:
  #   For backwards compatibility with the earliest PCs, physical
  #   address line 20 is tied low, so that addresses higher than
  #   1MB wrap around to zero by default.  This code undoes this.
seta20.1:
  inb     $0x64,%al               # Wait for not busy
    7c0a:	e4 64                	in     $0x64,%al
  testb   $0x2,%al
    7c0c:	a8 02                	test   $0x2,%al
  jnz     seta20.1
    7c0e:	75 fa                	jne    7c0a <seta20.1>

  movb    $0xd1,%al               # 0xd1 -> port 0x64
    7c10:	b0 d1                	mov    $0xd1,%al
  outb    %al,$0x64
    7c12:	e6 64                	out    %al,$0x64

00007c14 <seta20.2>:

seta20.2:
  inb     $0x64,%al               # Wait for not busy
    7c14:	e4 64                	in     $0x64,%al
  testb   $0x2,%al
    7c16:	a8 02                	test   $0x2,%al
  jnz     seta20.2
    7c18:	75 fa                	jne    7c14 <seta20.2>

  movb    $0xdf,%al               # 0xdf -> port 0x60
    7c1a:	b0 df                	mov    $0xdf,%al
  outb    %al,$0x60
    7c1c:	e6 60                	out    %al,$0x60

  # Switch from real to protected mode, using a bootstrap GDT
  # and segment translation that makes virtual addresses 
  # identical to their physical addresses, so that the 
  # effective memory map does not change during the switch.
  lgdt    gdtdesc
    7c1e:	0f 01 16             	lgdtl  (%esi)
    7c21:	6c                   	insb   (%dx),%es:(%edi)
    7c22:	7c 0f                	jl     7c33 <seta20.2+0x1f>
  movl    %cr0, %eax
    7c24:	20 c0                	and    %al,%al
  orl     $CR0_PE_ON, %eax
    7c26:	66 83 c8 01          	or     $0x1,%ax
  movl    %eax, %cr0
    7c2a:	0f 22 c0             	mov    %eax,%cr0

  xor     %eax, %eax
    7c2d:	66 31 c0             	xor    %ax,%ax
  inc     %eax
    7c30:	66 40                	inc    %ax
  
  # Jump to next instruction, but in 32-bit code segment.
  # Switches processor into 32-bit mode.
  ljmp    $PROT_MODE_CSEG, $protcseg
    7c32:	ea 37 7c 08 00 66 b8 	ljmp   $0xb866,$0x87c37

00007c37 <protcseg>:

  .code32                     # Assemble for 32-bit mode
protcseg:
  # Set up the protected-mode data segment registers
  movw    $PROT_MODE_DSEG, %ax    # Our data segment selector
    7c37:	66 b8 10 00          	mov    $0x10,%ax
  movw    %ax, %ds                # -> DS: Data Segment
    7c3b:	8e d8                	mov    %eax,%ds
  movw    %ax, %es                # -> ES: Extra Segment
    7c3d:	8e c0                	mov    %eax,%es
  movw    %ax, %fs                # -> FS
    7c3f:	8e e0                	mov    %eax,%fs
  movw    %ax, %gs                # -> GS
    7c41:	8e e8                	mov    %eax,%gs
  movw    %ax, %ss                # -> SS: Stack Segment
    7c43:	8e d0                	mov    %eax,%ss
  
  # Set up the stack pointer and call into C.
  movl    $start, %esp
    7c45:	bc 00 7c 00 00       	mov    $0x7c00,%esp
  call bootmain
    7c4a:	e8 ce 00 00 00       	call   7d1d <bootmain>

00007c4f <spin>:

  # If bootmain returns (it shouldn't), loop.
spin:
  jmp spin
    7c4f:	eb fe                	jmp    7c4f <spin>
    7c51:	8d 76 00             	lea    0x0(%esi),%esi

00007c54 <gdt>:
	...
    7c5c:	ff                   	(bad)  
    7c5d:	ff 00                	incl   (%eax)
    7c5f:	00 00                	add    %al,(%eax)
    7c61:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
    7c68:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

00007c6c <gdtdesc>:
    7c6c:	17                   	pop    %ss
    7c6d:	00 54 7c 00          	add    %dl,0x0(%esp,%edi,2)
	...

00007c72 <waitdisk>:
	}
}

void
waitdisk(void)
{
    7c72:	55                   	push   %ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
    7c73:	ba f7 01 00 00       	mov    $0x1f7,%edx
    7c78:	89 e5                	mov    %esp,%ebp
    7c7a:	ec                   	in     (%dx),%al
	// wait for disk reaady
	while ((inb(0x1F7) & 0xC0) != 0x40)
    7c7b:	83 e0 c0             	and    $0xffffffc0,%eax
    7c7e:	3c 40                	cmp    $0x40,%al
    7c80:	75 f8                	jne    7c7a <waitdisk+0x8>
		/* do nothing */;
}
    7c82:	5d                   	pop    %ebp
    7c83:	c3                   	ret    

00007c84 <readsect>:

void
readsect(void *dst, uint32_t offset)
{
    7c84:	55                   	push   %ebp
    7c85:	89 e5                	mov    %esp,%ebp
    7c87:	57                   	push   %edi
    7c88:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// wait for disk to be ready
	waitdisk();
    7c8b:	e8 e2 ff ff ff       	call   7c72 <waitdisk>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
    7c90:	ba f2 01 00 00       	mov    $0x1f2,%edx
    7c95:	b0 01                	mov    $0x1,%al
    7c97:	ee                   	out    %al,(%dx)
    7c98:	ba f3 01 00 00       	mov    $0x1f3,%edx
    7c9d:	88 c8                	mov    %cl,%al
    7c9f:	ee                   	out    %al,(%dx)
    7ca0:	89 c8                	mov    %ecx,%eax
    7ca2:	ba f4 01 00 00       	mov    $0x1f4,%edx
    7ca7:	c1 e8 08             	shr    $0x8,%eax
    7caa:	ee                   	out    %al,(%dx)
    7cab:	89 c8                	mov    %ecx,%eax
    7cad:	ba f5 01 00 00       	mov    $0x1f5,%edx
    7cb2:	c1 e8 10             	shr    $0x10,%eax
    7cb5:	ee                   	out    %al,(%dx)
    7cb6:	89 c8                	mov    %ecx,%eax
    7cb8:	ba f6 01 00 00       	mov    $0x1f6,%edx
    7cbd:	c1 e8 18             	shr    $0x18,%eax
    7cc0:	83 c8 e0             	or     $0xffffffe0,%eax
    7cc3:	ee                   	out    %al,(%dx)
    7cc4:	ba f7 01 00 00       	mov    $0x1f7,%edx
    7cc9:	b0 20                	mov    $0x20,%al
    7ccb:	ee                   	out    %al,(%dx)
	outb(0x1F5, offset >> 16);
	outb(0x1F6, (offset >> 24) | 0xE0);
	outb(0x1F7, 0x20);	// cmd 0x20 - read sectors

	// wait for disk to be ready
	waitdisk();
    7ccc:	e8 a1 ff ff ff       	call   7c72 <waitdisk>
}

static inline void
insl(int port, void *addr, int cnt)
{
	asm volatile("cld\n\trepne\n\tinsl"
    7cd1:	8b 7d 08             	mov    0x8(%ebp),%edi
    7cd4:	b9 80 00 00 00       	mov    $0x80,%ecx
    7cd9:	ba f0 01 00 00       	mov    $0x1f0,%edx
    7cde:	fc                   	cld    
    7cdf:	f2 6d                	repnz insl (%dx),%es:(%edi)

	// read a sector
	insl(0x1F0, dst, SECTSIZE/4);
}
    7ce1:	5f                   	pop    %edi
    7ce2:	5d                   	pop    %ebp
    7ce3:	c3                   	ret    

00007ce4 <readseg>:

// Read 'count' bytes at 'offset' from kernel into physical address 'pa'.
// Might copy more than asked
void
readseg(uint32_t pa, uint32_t count, uint32_t offset)
{
    7ce4:	55                   	push   %ebp
    7ce5:	89 e5                	mov    %esp,%ebp
    7ce7:	57                   	push   %edi
    7ce8:	56                   	push   %esi

	// round down to sector boundary
	pa &= ~(SECTSIZE - 1);

	// translate from bytes to sectors, and kernel starts at sector 1
	offset = (offset / SECTSIZE) + 1;
    7ce9:	8b 7d 10             	mov    0x10(%ebp),%edi

// Read 'count' bytes at 'offset' from kernel into physical address 'pa'.
// Might copy more than asked
void
readseg(uint32_t pa, uint32_t count, uint32_t offset)
{
    7cec:	53                   	push   %ebx
	uint32_t end_pa;

	end_pa = pa + count;
    7ced:	8b 75 0c             	mov    0xc(%ebp),%esi

// Read 'count' bytes at 'offset' from kernel into physical address 'pa'.
// Might copy more than asked
void
readseg(uint32_t pa, uint32_t count, uint32_t offset)
{
    7cf0:	8b 5d 08             	mov    0x8(%ebp),%ebx

	// round down to sector boundary
	pa &= ~(SECTSIZE - 1);

	// translate from bytes to sectors, and kernel starts at sector 1
	offset = (offset / SECTSIZE) + 1;
    7cf3:	c1 ef 09             	shr    $0x9,%edi
void
readseg(uint32_t pa, uint32_t count, uint32_t offset)
{
	uint32_t end_pa;

	end_pa = pa + count;
    7cf6:	01 de                	add    %ebx,%esi

	// round down to sector boundary
	pa &= ~(SECTSIZE - 1);

	// translate from bytes to sectors, and kernel starts at sector 1
	offset = (offset / SECTSIZE) + 1;
    7cf8:	47                   	inc    %edi
	uint32_t end_pa;

	end_pa = pa + count;

	// round down to sector boundary
	pa &= ~(SECTSIZE - 1);
    7cf9:	81 e3 00 fe ff ff    	and    $0xfffffe00,%ebx
	offset = (offset / SECTSIZE) + 1;

	// If this is too slow, we could read lots of sectors at a time.
	// We'd write more to memory than asked, but it doesn't matter --
	// we load in increasing order.
	while (pa < end_pa) {
    7cff:	39 f3                	cmp    %esi,%ebx
    7d01:	73 12                	jae    7d15 <readseg+0x31>
		// Since we haven't enabled paging yet and we're using
		// an identity segment mapping (see boot.S), we can
		// use physical addresses directly.  This won't be the
		// case once JOS enables the MMU.
		readsect((uint8_t*) pa, offset);
    7d03:	57                   	push   %edi
    7d04:	53                   	push   %ebx
		pa += SECTSIZE;
		offset++;
    7d05:	47                   	inc    %edi
		// Since we haven't enabled paging yet and we're using
		// an identity segment mapping (see boot.S), we can
		// use physical addresses directly.  This won't be the
		// case once JOS enables the MMU.
		readsect((uint8_t*) pa, offset);
		pa += SECTSIZE;
    7d06:	81 c3 00 02 00 00    	add    $0x200,%ebx
	while (pa < end_pa) {
		// Since we haven't enabled paging yet and we're using
		// an identity segment mapping (see boot.S), we can
		// use physical addresses directly.  This won't be the
		// case once JOS enables the MMU.
		readsect((uint8_t*) pa, offset);
    7d0c:	e8 73 ff ff ff       	call   7c84 <readsect>
		pa += SECTSIZE;
		offset++;
    7d11:	58                   	pop    %eax
    7d12:	5a                   	pop    %edx
    7d13:	eb ea                	jmp    7cff <readseg+0x1b>
	}
}
    7d15:	8d 65 f4             	lea    -0xc(%ebp),%esp
    7d18:	5b                   	pop    %ebx
    7d19:	5e                   	pop    %esi
    7d1a:	5f                   	pop    %edi
    7d1b:	5d                   	pop    %ebp
    7d1c:	c3                   	ret    

00007d1d <bootmain>:
void readsect(void*, uint32_t);
void readseg(uint32_t, uint32_t, uint32_t);

void
bootmain(void)
{
    7d1d:	55                   	push   %ebp
    7d1e:	89 e5                	mov    %esp,%ebp
    7d20:	56                   	push   %esi
    7d21:	53                   	push   %ebx
	struct Proghdr *ph, *eph;

	// read 1st page off disk
	readseg((uint32_t) ELFHDR, SECTSIZE*8, 0);
    7d22:	6a 00                	push   $0x0
    7d24:	68 00 10 00 00       	push   $0x1000
    7d29:	68 00 00 01 00       	push   $0x10000
    7d2e:	e8 b1 ff ff ff       	call   7ce4 <readseg>

	// is this a valid ELF?
	if (ELFHDR->e_magic != ELF_MAGIC)
    7d33:	83 c4 0c             	add    $0xc,%esp
    7d36:	81 3d 00 00 01 00 7f 	cmpl   $0x464c457f,0x10000
    7d3d:	45 4c 46 
    7d40:	75 37                	jne    7d79 <bootmain+0x5c>
		goto bad;

	// load each program segment (ignores ph flags)
	ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
    7d42:	a1 1c 00 01 00       	mov    0x1001c,%eax
	eph = ph + ELFHDR->e_phnum;
    7d47:	0f b7 35 2c 00 01 00 	movzwl 0x1002c,%esi
	// is this a valid ELF?
	if (ELFHDR->e_magic != ELF_MAGIC)
		goto bad;

	// load each program segment (ignores ph flags)
	ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
    7d4e:	8d 98 00 00 01 00    	lea    0x10000(%eax),%ebx
	eph = ph + ELFHDR->e_phnum;
    7d54:	c1 e6 05             	shl    $0x5,%esi
    7d57:	01 de                	add    %ebx,%esi
	for (; ph < eph; ph++)
    7d59:	39 f3                	cmp    %esi,%ebx
    7d5b:	73 16                	jae    7d73 <bootmain+0x56>
		// p_pa is the load address of this segment (as well
		// as the physical address)
		readseg(ph->p_pa, ph->p_memsz, ph->p_offset);
    7d5d:	ff 73 04             	pushl  0x4(%ebx)
    7d60:	ff 73 14             	pushl  0x14(%ebx)
		goto bad;

	// load each program segment (ignores ph flags)
	ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
	eph = ph + ELFHDR->e_phnum;
	for (; ph < eph; ph++)
    7d63:	83 c3 20             	add    $0x20,%ebx
		// p_pa is the load address of this segment (as well
		// as the physical address)
		readseg(ph->p_pa, ph->p_memsz, ph->p_offset);
    7d66:	ff 73 ec             	pushl  -0x14(%ebx)
    7d69:	e8 76 ff ff ff       	call   7ce4 <readseg>
		goto bad;

	// load each program segment (ignores ph flags)
	ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
	eph = ph + ELFHDR->e_phnum;
	for (; ph < eph; ph++)
    7d6e:	83 c4 0c             	add    $0xc,%esp
    7d71:	eb e6                	jmp    7d59 <bootmain+0x3c>
		// as the physical address)
		readseg(ph->p_pa, ph->p_memsz, ph->p_offset);

	// call the entry point from the ELF header
	// note: does not return!
	((void (*)(void)) (ELFHDR->e_entry))();
    7d73:	ff 15 18 00 01 00    	call   *0x10018
}

static inline void
outw(int port, uint16_t data)
{
	asm volatile("outw %0,%w1" : : "a" (data), "d" (port));
    7d79:	ba 00 8a 00 00       	mov    $0x8a00,%edx
    7d7e:	b8 00 8a ff ff       	mov    $0xffff8a00,%eax
    7d83:	66 ef                	out    %ax,(%dx)
    7d85:	b8 00 8e ff ff       	mov    $0xffff8e00,%eax
    7d8a:	66 ef                	out    %ax,(%dx)
    7d8c:	eb fe                	jmp    7d8c <bootmain+0x6f>
