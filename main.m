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
	
	FILE *fp = fopen(path, "rb");
	if (!fp) {
		return false;
	}

	uint32_t magic;
	if (fread(&magic, sizeof(magic), 1, fp) != 1) {
		fclose(fp);
		return false;
	}

	fclose(fp);
	if (magic == MH_MAGIC || magic == MH_CIGAM ||
		magic == MH_MAGIC_64 || magic == MH_CIGAM_64) {
		return true;
	}

	return false;
  

}

int walkdir(char *path) {
	// TODO:
	// Handle symlinks maybe?

	int ret = 0;
	
	DIR *dir = opendir(path);
	if (dir == NULL) {
		fprintf(stderr, "Failed to opendir('%s'): %s\n", path, strerror(errno));
		return -1;
	}
	
	
	struct dirent *ent;
	while ((ent = readdir(dir)) != NULL) {
		if (strcmp(ent->d_name, ".") == 0 || strcmp(ent->d_name, "..") == 0){
			continue;
		}
		
		char src_path[PATH_MAX];
		if (snprintf(src_path, sizeof(src_path), "%s/%s", path, ent->d_name) >= sizeof(src_path)) {
			printf("Path too long: %s/%s\n", path, ent->d_name);
			closedir(dir);
			return -1;
		}
		
		struct stat st;
		if (lstat(src_path, &st) != 0) {
			printf("Failed to lstat('%s'): %s\n", src_path, strerror(errno));
			closedir(dir);
			return -1;
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

