import { Point, utils } from "@noble/secp256k1";
import AES from "crypto-js/aes";
import { enc } from "crypto-js";

/**
 * @dev Generates a random private key
 * @returns privKey 32-bytes random private key
 */
export function generateRandomPrivateKey() {
    return BigInt(`0x${utils.bytesToHex(utils.randomPrivateKey())}`);
}

/**
 * @dev Random big int
 * @returns randomNumber Random Big int
 */
export function generateRandomNumber() {
    const randomBytes = utils.randomBytes(32);
    const randomNumber = BigInt(`0x${utils.bytesToHex(randomBytes)}`);
    return randomNumber;
}

/**
 * @dev Get result of scalar product between a scalar and a Point on curve
 * @param scalar Scalar to multiply
 * @param point Point to multiply with
 * @returns Resultant point
 */
export function getScalarProductWithPoint(scalar: bigint, point: Point) {
    return point.multiply(scalar);
}

/**
 * @dev Get result of scalar product between a scalar and Generator point on curve
 * @param scalar Scalar to multiply
 * @returns Resultant point
 */
export function getScalarProductWithGeneratorPoint(scalar: bigint) {
    return Point.BASE.multiply(scalar);
}

/**
 * @dev Encrypt a message with shared key
 * @param message Message to encrypt
 * @param key Shared key
 * @returns Encrypted message in Base64 string
 */
export function encryptMessageWithSharedKey(message: string, key: bigint) {
    return AES.encrypt(message, key.toString()).toString();
}

/**
 * @dev Decrypt a message with shared key
 * @param messageEnc Message to decrypt
 * @param key Shared key
 * @returns Decrypted message in plaintext
 */
export function decryptMessageWithSharedKey(messageEnc: string, key: bigint) {
    return AES.decrypt(messageEnc, key.toString()).toString(enc.Utf8);
}

/**
 * @dev Converts a base64 encoded string to hex encoded one
 * @param b64Text Base64 text to convert
 * @returns Hex string, prefixed with `0x`
 */
export function convertBase64ToHex(b64Text: string) {
    return `0x${enc.Hex.stringify(enc.Base64.parse(b64Text))}`;
}
