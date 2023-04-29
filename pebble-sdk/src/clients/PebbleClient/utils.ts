import { Point, utils } from "@noble/secp256k1";
import AES from "crypto-js/aes";
import { enc, lib } from "crypto-js";

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
 * @dev Tries to guess encoding type and parsed Word array of a plaintext message
 * @param message Plaintext message
 * @returns Encoding type and parsed Word array, or null
 */
export function getMessageWordArray(message: string) {
    let encodingType: (null | "utf8" | "utf16" | "utf16-le" | "utf16-be") = null;
    let messageWordArray: null | lib.WordArray = null;

    try {
        messageWordArray = enc.Utf8.parse(message);
        encodingType = "utf8";
    } catch {
        try {
            messageWordArray = enc.Utf16.parse(message);
            encodingType = "utf16";
        } catch {
            try {
                messageWordArray = enc.Utf16LE.parse(message);
                encodingType = "utf16-le";
            } catch {
                messageWordArray = enc.Utf16BE.parse(message);
                encodingType = "utf16-be";
            }
        }
    }

    return {
        encodingType,
        messageWordArray
    };
}

/**
 * @dev Tries to guess encoding type and plaintext of a Word array
 * @param message Word array of the message
 * @returns Encoding type and stringified Word array, or null
 */
export function getMessagePlaintext(messageWordArray: lib.WordArray) {
    let encodingType: (null | "utf8" | "utf16" | "utf16-le" | "utf16-be") = null;
    let message: null | string = null;

    try {
        message = enc.Utf8.stringify(messageWordArray);
        encodingType = "utf8";
    } catch {
        try {
            message = enc.Utf16.stringify(messageWordArray);
            encodingType = "utf16";
        } catch {
            try {
                message = enc.Utf16LE.stringify(messageWordArray);
                encodingType = "utf16-le";
            } catch {
                message = enc.Utf16BE.stringify(messageWordArray);
                encodingType = "utf16-be";
            }
        }
    }

    return {
        encodingType,
        message
    };
}

/**
 * @dev Encrypt a message with shared key
 * @param message Message to encrypt
 * @param key Shared key
 * @returns Encrypted message in Base64 string
 */
export function encryptMessageWithSharedKey(message: string, key: bigint) {
    const { messageWordArray } = getMessageWordArray(message);
    return AES.encrypt(messageWordArray, key.toString()).toString();
}

/**
 * @dev Decrypt a message with shared key
 * @param messageEnc Message to decrypt (base64)
 * @param key Shared key
 * @returns Decrypted message in plaintext
 */
export function decryptMessageWithSharedKey(messageEnc: string, key: bigint) {
    const { message } = getMessagePlaintext(AES.decrypt(messageEnc, key.toString()));
    return message;
}

/**
 * @dev Converts a base64 encoded string to hex encoded one
 * @param b64Text Base64 text to convert
 * @returns Hex string, prefixed with `0x`
 */
export function convertBase64ToHex(b64Text: string) {
    return `0x${enc.Hex.stringify(enc.Base64.parse(b64Text))}`;
}

/**
 * @dev Converts a Hex encoded string to Base64 encoded one
 * @param hexText Hex text to convert
 * @returns Base64 string
 */
export function convertHexToBase64(hexText: string) {
    return enc.Base64.stringify(enc.Hex.parse(
        hexText.startsWith("0x")
            ? hexText.slice(2)
            : hexText
    ));
}