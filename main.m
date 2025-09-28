#include <stdio.h>
#include <Foundation/Foundation.h>
#include <dirent.h>
#include <sys/stat.h>
#include <mach-o/loader.h>

int resign(char* path) {
	char* args[] = {
		"/usr/bin/ldid",
		"-S",
		"-M",
		path,
		NULL
	};
	char* env[]  = {NULL};
	printf("[*] resigning: %s\n", path);
	int p = fork();
	if (p == 0) {
		int ret = execve(args[0], args, env);
		return 0;
	} else {
		return p;
	}
}

bool isMacho(char* path) {
	
	FILE *fd = fopen(path, "rb");
	if (!fd) {
		return false;
	}

	uint32_t magic;
	if (fread(&magic, sizeof(magic), 1, fd) != 1) {
		fclose(fd);
		return false;
	}

	fclose(fd);

	return (magic == 0xFEEDFACE || magic == 0xCEFAEDFE ||
			magic == 0xFEEDFACF || magic == 0xCFFAEDFE ||
			magic == 0xCAFEBABE || magic == 0xBEBAFECA ||
			magic == 0xCAFEBABF || magic == 0xBFBAFECA);
}

int walkdir(char *path) {
	// TODO:
	// Handle symlinks maybe?

	int ret = 0;
	
	DIR *dir = opendir(path);
	if (dir == NULL) {
		fprintf(stderr, "[-]Failed to opendir('%s'): %s\n", path, strerror(errno));
		return -1;
	}
	
	
	struct dirent *ent;
	while ((ent = readdir(dir)) != NULL) {
		if (strcmp(ent->d_name, ".") == 0 || strcmp(ent->d_name, "..") == 0 || strcmp(&ent->d_name[0], ".") == 0){
			continue;
		}
		
		char src_path[PATH_MAX];
		if (snprintf(src_path, sizeof(src_path), "%s/%s", path, ent->d_name) >= sizeof(src_path)) {
			printf("[-] Path too long: %s/%s\n", path, ent->d_name);
			continue;
		}
		
		struct stat st;
		if (lstat(src_path, &st) != 0) {
			printf("[-] Failed to lstat('%s'): %s\n", src_path, strerror(errno));
			continue;
		}
		if (S_ISLNK(st.st_mode)) {
			continue;
		}
		
		if (S_ISDIR(st.st_mode)) {
			ret = walkdir(src_path);
			if (ret != 0) {
				closedir(dir);
				return ret;
			}
		}
		else {
			// printf("%s\n", src_path);
			if (isMacho(src_path)) {
				int res = resign(src_path);

			}
		}
	}
	
	closedir(dir);
	return 0;
}


int main() {
	if (access("/usr/bin/ldid", F_OK) != 0) {
		printf("[-] No ldid found -> exiting");
		return -1;
	}

	DIR *dir;
	struct dirent *entry;
	char path_user[PATH_MAX]; 
	scanf("%s", path_user);

	// printf("%i\n", is_mach_o_simple(path_user)); // Some testing for mach-o detect function

	dir = opendir(path_user);
	if (dir == NULL) {
		perror("Unable to open directory");
		return 1;
	}

	walkdir(path_user);
	printf("[+] Resigned!");
	closedir(dir);


	return 0;
}

