import { Point, utils } from "@noble/secp256k1";

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