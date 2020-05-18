/************************************************************************
Lab 9 Nios Software

Dong Kai Wang, Fall 2017
Christine Chen, Fall 2013

For use with ECE 385 Experiment 9
University of Illinois ECE Department
************************************************************************/

#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include "aes.h"

// Pointer to base address of AES module, make sure it matches Qsys
volatile unsigned int * AES_PTR = (unsigned int *) 0x00000100;

// Execution mode: 0 for testing, 1 for benchmarking
int run_mode = 0;


void printMatrix(unsigned char(*w)[4]){
	int i;
	printf("============Print Matrix===========\n");
	for(i=0; i<4; i++){
		printf("%2x %2x %2x %2x\n", w[0][i],  w[1][i],  w[2][i], w[3][i]);
	}
	printf("==================================\n");
}

void SubBytes(unsigned char(*state)[4]){
	int i,j;
	for(i=0; i<4;i++){
		for(j=0; j<4;j++){
			state[i][j] = aes_sbox[state[i][j]];
		}
	}
}


void ShiftRows(unsigned char(*state)[4]){
	int i;
	int temp;
	int shift;
	int j;
	for (j = 0; j<4; j++){
		for (shift = 0; shift<j; shift++){
			temp = state[0][j];
			for (i = 0;i < 3;i++){
				state[i][j] = state[i+1][j];
			}
			state[3][j] = temp;
		}
	}
	
}



void MixColumns(unsigned char(*state)[4]){
	unsigned char currCol[4];
	int i,j;
	
	for(i=0;i<4;i++){

		// determine the current column

		// b0 = 2a0 + 3a1 + 1a2 + 1a3
		currCol[0] = gf_mul[state[i][0]][0] ^ gf_mul[state[i][1]][1] ^ state[i][2] ^ state[i][3];

		// b1 = 1a0 + 2a1 + 3a2 + 1a3
		currCol[1] = state[i][0] ^ gf_mul[state[i][1]][0] ^ gf_mul[state[i][2]][1] ^ state[i][3];

		// b2 = 1a0 + 1a1 + 2a2 + 3a3
		currCol[2] = state[i][0] ^ state[i][1] ^ gf_mul[state[i][2]][0] ^ gf_mul[state[i][3]][1];

		// b3 = 3a0 + 1a1 + 1a2 + 2a3
		currCol[3] = gf_mul[state[i][0]][1] ^ state[i][1] ^ state[i][2] ^ gf_mul[state[i][3]][0];

		// update the values of the whole column in the state
		for(j=0; j<4; j++){
			state[i][j] = currCol[j];
		}

	}
}

void AddRoundKey(unsigned char(*state)[4], unsigned char(*w)[4]){
	int i,j;
	for(i=0; i<4;i++){
		for(j=0; j<4;j++){
			state[i][j] = state[i][j] ^ w[i][j];
		}
	}
}

void KeyExpansion(unsigned char(*w)[4], int k){

	// printMatrix(w);

	unsigned int newW[4];
	unsigned int lastColWord;
	unsigned char lastCol[4];
	int i,j;

	// RotWord and SubWord
	unsigned char temp = w[3][0];
	for(j=0; j<3; j++){
		lastCol[j] = aes_sbox[w[3][j+1]];
	}
	lastCol[3] = aes_sbox[temp];
	

	lastColWord = (lastCol[0] << 24 | lastCol[1] << 16 | lastCol[2] << 8 | lastCol[3]) ^ Rcon[k];


	newW[0] = (w[0][0] << 24 | w[0][1] << 16 | w[0][2] << 8 | w[0][3]) ^ lastColWord;
	// assign newW[0-2]
	for(i=1; i<4; i++){
		newW[i] = (w[i][0] << 24 | w[i][1] << 16 | w[i][2] << 8 | w[i][3]) ^ newW[i-1];
	}

	// update the values of key array
	for(i=0; i<4; i++){
		w[i][3] = (unsigned char) newW[i] & 0xFF;
		w[i][2] = (unsigned char) (newW[i] >> 8) & 0xFF;
		w[i][1] = (unsigned char) (newW[i] >> 16) & 0xFF;
		w[i][0] = (unsigned char) (newW[i] >> 24) & 0xFF;
	}


}









/** charToHex
 *  Convert a single character to the 4-bit value it represents.
 *  
 *  Input: a character c (e.g. 'A')
 *  Output: converted 4-bit value (e.g. 0xA)
 */
char charToHex(char c)
{
	char hex = c;

	if (hex >= '0' && hex <= '9')
		hex -= '0';
	else if (hex >= 'A' && hex <= 'F')
	{
		hex -= 'A';
		hex += 10;
	}
	else if (hex >= 'a' && hex <= 'f')
	{
		hex -= 'a';
		hex += 10;
	}
	return hex;
}

/** charsToHex
 *  Convert two characters to byte value it represents.
 *  Inputs must be 0-9, A-F, or a-f.
 *  
 *  Input: two characters c1 and c2 (e.g. 'A' and '7')
 *  Output: converted byte value (e.g. 0xA7)
 */
char charsToHex(char c1, char c2)
{
	char hex1 = charToHex(c1);
	char hex2 = charToHex(c2);
	return (hex1 << 4) + hex2;
}

/** encrypt
 *  Perform AES encryption in software.
 *
 *  Input: msg_ascii - Pointer to 32x 8-bit char array that contains the input message in ASCII format
 *         key_ascii - Pointer to 32x 8-bit char array that contains the input key in ASCII format
 *  Output:  msg_enc - Pointer to 4x 32-bit int array that contains the encrypted message
 *               key - Pointer to 4x 32-bit int array that contains the input key
 */
void encrypt(unsigned char * msg_ascii, unsigned char * key_ascii, unsigned int * msg_enc, unsigned int * key)
{
	// Implement this function
	int i,j,idx;
	unsigned char w[4][4];

	// construct the state array by the given input messege
	unsigned char state[4][4];
	for(i=0; i<4;i++){
		for(j=0; j<4;j++){
			idx = i*2+j*8;
			state[i][j] = charsToHex(msg_ascii[idx],msg_ascii[idx+1]);
		}
	}

	// construct the key array by the given input key
	for(i=0; i<4;i++){
		for(j=0; j<4;j++){
			idx = i*2+j*8;
			w[i][j] = charsToHex(key_ascii[idx],key_ascii[idx+1]);
		}
	}

	// printMatrix(state);


	// the main function of the encoding part
	AddRoundKey(state, w);

	for(i=0; i<9; i++){

		printf("ROUND#%d", i);
		printMatrix(state);

		// update key array
		KeyExpansion(w, i+1);

		SubBytes(state);
		// printMatrix(state);

		ShiftRows(state);
		// printMatrix(state);

		MixColumns(state);
		// printMatrix(state);

		AddRoundKey(state, w);
		// printMatrix(state);


	}

	printf("FINAL ROUND");
	printMatrix(state);

	// update key array
	KeyExpansion(w, 10);

	SubBytes(state);
	ShiftRows(state);
	AddRoundKey(state, w);

	printf("Finial State");
	printMatrix(state);

	// output the encoded message to the corresponding position
	for(i=0;i<4;i++){
		msg_enc[i] = state[i][0] << 24 | state[i][1] << 16 | state[i][2] << 8 | state[i][3];
		key[i] = w[i][0] << 24 | w[i][1] << 16 | w[i][2] << 8 | w[i][3];
	}

}

/** decrypt
 *  Perform AES decryption in hardware.
 *
 *  Input:  msg_enc - Pointer to 4x 32-bit int array that contains the encrypted message
 *              key - Pointer to 4x 32-bit int array that contains the input key
 *  Output: msg_dec - Pointer to 4x 32-bit int array that contains the decrypted message
 */
void decrypt(unsigned int * msg_enc, unsigned int * msg_dec, unsigned int * key)
{
	// Implement this function
}

/** main
 *  Allows the user to enter the message, key, and select execution mode
 *
 */
int main()
{
	// Input Message and Key as 32x 8-bit ASCII Characters ([33] is for NULL terminator)
	unsigned char msg_ascii[33];
	unsigned char key_ascii[33];
	// Key, Encrypted Message, and Decrypted Message in 4x 32-bit Format to facilitate Read/Write to Hardware
	unsigned int key[4];
	unsigned int msg_enc[4];
	unsigned int msg_dec[4];

	printf("Select execution mode: 0 for testing, 1 for benchmarking: ");
	scanf("%d", &run_mode);

	if (run_mode == 0) {
		// Continuously Perform Encryption and Decryption
		while (1) {
			int i = 0;
			printf("\nEnter Message:\n");
			scanf("%s", msg_ascii);
			printf("\n");
			printf("\nEnter Key:\n");
			scanf("%s", key_ascii);
			printf("\n");
			encrypt(msg_ascii, key_ascii, msg_enc, key);
			printf("\nEncrpted message is: \n");
			for(i = 0; i < 4; i++){
				printf("%08x", msg_enc[i]);
			}
			printf("\n");
			decrypt(msg_enc, msg_dec, key);
			printf("\nDecrypted message is: \n");
			for(i = 0; i < 4; i++){
				printf("%08x", msg_dec[i]);
			}
			printf("\n");
		}
	}
	else {
		// Run the Benchmark
		int i = 0;
		int size_KB = 2;
		// Choose a random Plaintext and Key
		for (i = 0; i < 32; i++) {
			msg_ascii[i] = 'a';
			key_ascii[i] = 'b';
		}
		// Run Encryption
		clock_t begin = clock();
		for (i = 0; i < size_KB * 64; i++)
			encrypt(msg_ascii, key_ascii, msg_enc, key);
		clock_t end = clock();
		double time_spent = (double)(end - begin) / CLOCKS_PER_SEC;
		double speed = size_KB / time_spent;
		printf("Software Encryption Speed: %f KB/s \n", speed);
		// Run Decryption
		begin = clock();
		for (i = 0; i < size_KB * 64; i++)
			decrypt(msg_enc, msg_dec, key);
		end = clock();
		time_spent = (double)(end - begin) / CLOCKS_PER_SEC;
		speed = size_KB / time_spent;
		printf("Hardware Encryption Speed: %f KB/s \n", speed);
	}
	return 0;
}


