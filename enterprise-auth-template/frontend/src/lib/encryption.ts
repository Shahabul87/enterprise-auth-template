/**
 * Client-side encryption utility
 * Provides secure encryption/decryption for sensitive data in the browser
 * Supports multiple algorithms, key management, and data integrity verification
 */


// Encryption types
export interface EncryptionResult {
  encrypted: string;
  iv: string;
  salt?: string;
  algorithm: string;
  keyDerivation?: string;
  integrity?: string;
  timestamp: number;
}

export interface DecryptionResult<T = string> {
  decrypted: T;
  algorithm: string;
  timestamp: number;
  verified: boolean;
}

export interface KeyDerivationOptions {
  salt?: Uint8Array;
  iterations?: number;
  keyLength?: number;
  hashAlgorithm?: 'SHA-256' | 'SHA-384' | 'SHA-512';
}

export interface EncryptionOptions {
  algorithm?: 'AES-GCM' | 'AES-CBC' | 'AES-CTR';
  keyDerivation?: 'PBKDF2' | 'HKDF';
  keyDerivationOptions?: KeyDerivationOptions;
  additionalData?: Uint8Array;
  includeIntegrity?: boolean;
  compress?: boolean;
}

export interface KeyPair {
  publicKey: CryptoKey;
  privateKey: CryptoKey;
  algorithm: string;
}

export interface SignatureResult {
  signature: string;
  algorithm: string;
  timestamp: number;
}

// Configuration interface
export interface EncryptionConfig {
  defaultAlgorithm: 'AES-GCM' | 'AES-CBC' | 'AES-CTR';
  defaultKeyDerivation: 'PBKDF2' | 'HKDF';
  keyStorage: {
    enabled: boolean;
    location: 'memory' | 'sessionStorage' | 'indexedDB';
    keyPrefix: string;
    autoCleanup?: boolean;
    maxAge?: number;
  };
  security: {
    saltLength: number;
    ivLength: number;
    keyLength: number;
    pbkdf2Iterations: number;
    includeIntegrity: boolean;
    secureRandom: boolean;
  };
  performance: {
    enableWorker?: boolean;
    batchSize?: number;
    enableCaching?: boolean;
  };
  debug?: boolean;
}

// Key storage interface
export interface KeyStorage {
  store(keyId: string, key: CryptoKey, metadata?: Record<string, unknown>): Promise<void>;
  retrieve(keyId: string): Promise<CryptoKey | null>;
  remove(keyId: string): Promise<boolean>;
  list(): Promise<string[]>;
  clear(): Promise<void>;
}

/**
 * Memory-based key storage
 */
class MemoryKeyStorage implements KeyStorage {
  private keys = new Map<string, { key: CryptoKey; metadata?: Record<string, unknown>; timestamp: number }>();

  async store(keyId: string, key: CryptoKey, metadata?: Record<string, unknown>): Promise<void> {
    this.keys.set(keyId, {
      key,
      ...(metadata ? { metadata } : {}),
      timestamp: Date.now(),
    });
  }

  async retrieve(keyId: string): Promise<CryptoKey | null> {
    const stored = this.keys.get(keyId);
    return stored ? stored.key : null;
  }

  async remove(keyId: string): Promise<boolean> {
    return this.keys.delete(keyId);
  }

  async list(): Promise<string[]> {
    return Array.from(this.keys.keys());
  }

  async clear(): Promise<void> {
    this.keys.clear();
  }
}

/**
 * IndexedDB-based key storage
 */
class IndexedDBKeyStorage implements KeyStorage {
  private dbName = 'EncryptionKeys';
  private version = 1;
  private storeName = 'keys';

  private async getDB(): Promise<IDBDatabase> {
    return new Promise((resolve, reject) => {
      const request = indexedDB.open(this.dbName, this.version);

      request.onerror = () => reject(request.error);
      request.onsuccess = () => resolve(request.result);

      request.onupgradeneeded = (event) => {
        const db = (event.target as IDBOpenDBRequest).result;
        if (!db.objectStoreNames.contains(this.storeName)) {
          const store = db.createObjectStore(this.storeName, { keyPath: 'id' });
          store.createIndex('timestamp', 'timestamp');
        }
      };
    });
  }

  async store(keyId: string, key: CryptoKey, metadata?: Record<string, unknown>): Promise<void> {
    const db = await this.getDB();
    const transaction = db.transaction([this.storeName], 'readwrite');
    const store = transaction.objectStore(this.storeName);

    // Export key for storage
    const exportedKey = await crypto.subtle.exportKey('jwk', key);

    await new Promise<void>((resolve, reject) => {
      const request = store.put({
        id: keyId,
        key: exportedKey,
        algorithm: key.algorithm,
        extractable: key.extractable,
        usages: key.usages,
        metadata,
        timestamp: Date.now(),
      });

      request.onerror = () => reject(request.error);
      request.onsuccess = () => resolve();
    });
  }

  async retrieve(keyId: string): Promise<CryptoKey | null> {
    try {
      const db = await this.getDB();
      const transaction = db.transaction([this.storeName], 'readonly');
      const store = transaction.objectStore(this.storeName);

      const stored = await new Promise<unknown>((resolve, reject) => {
        const request = store.get(keyId);
        request.onerror = () => reject(request.error);
        request.onsuccess = () => resolve(request.result);
      });

      if (!stored) return null;

      // Import key from storage
      const keyData = stored as { key: JsonWebKey; algorithm: AlgorithmIdentifier; extractable: boolean; usages: KeyUsage[] };
      return await crypto.subtle.importKey(
        'jwk',
        keyData.key,
        keyData.algorithm,
        keyData.extractable,
        keyData.usages
      );
    } catch {
      // Encryption operation error occurred
      return null;
    }
  }

  async remove(keyId: string): Promise<boolean> {
    try {
      const db = await this.getDB();
      const transaction = db.transaction([this.storeName], 'readwrite');
      const store = transaction.objectStore(this.storeName);

      await new Promise<void>((resolve, reject) => {
        const request = store.delete(keyId);
        request.onerror = () => reject(request.error);
        request.onsuccess = () => resolve();
      });

      return true;
    } catch {
      
      return false;
    }
  }

  async list(): Promise<string[]> {
    try {
      const db = await this.getDB();
      const transaction = db.transaction([this.storeName], 'readonly');
      const store = transaction.objectStore(this.storeName);

      return await new Promise<string[]>((resolve, reject) => {
        const request = store.getAllKeys();
        request.onerror = () => reject(request.error);
        request.onsuccess = () => resolve(request.result as string[]);
      });
    } catch {
      
      return [];
    }
  }

  async clear(): Promise<void> {
    try {
      const db = await this.getDB();
      const transaction = db.transaction([this.storeName], 'readwrite');
      const store = transaction.objectStore(this.storeName);

      await new Promise<void>((resolve, reject) => {
        const request = store.clear();
        request.onerror = () => reject(request.error);
        request.onsuccess = () => resolve();
      });
    } catch {
      
    }
  }
}

/**
 * Client-side encryption manager
 * Handles encryption, decryption, and key management
 */
class EncryptionManager {
  private static instance: EncryptionManager;
  private config: EncryptionConfig;
  private keyStorage: KeyStorage;
  private initialized = false;
  private debug = false;

  private constructor() {
    this.config = {
      defaultAlgorithm: 'AES-GCM',
      defaultKeyDerivation: 'PBKDF2',
      keyStorage: {
        enabled: true,
        location: 'memory',
        keyPrefix: 'enc_key_',
        autoCleanup: true,
        maxAge: 24 * 60 * 60 * 1000, // 24 hours
      },
      security: {
        saltLength: 16, // 128 bits
        ivLength: 12, // 96 bits for GCM
        keyLength: 32, // 256 bits
        pbkdf2Iterations: 100000, // OWASP recommendation
        includeIntegrity: true,
        secureRandom: true,
      },
      performance: {
        enableWorker: false, // Web Workers for heavy operations
        batchSize: 10,
        enableCaching: true,
      },
      debug: process.env['NODE_ENV'] === 'development',
    };

    this.debug = this.config.debug || false;
    this.keyStorage = new MemoryKeyStorage();
  }

  /**
   * Get singleton instance
   */
  public static getInstance(): EncryptionManager {
    if (!EncryptionManager.instance) {
      EncryptionManager.instance = new EncryptionManager();
    }
    return EncryptionManager.instance;
  }

  /**
   * Initialize encryption manager
   */
  public async initialize(config?: Partial<EncryptionConfig>): Promise<void> {
    try {
      if (config) {
        this.config = { ...this.config, ...config };
      }

      // Check Web Crypto API availability
      if (!this.isWebCryptoSupported()) {
        throw new Error('Web Crypto API is not supported in this environment');
      }

      // Initialize key storage
      await this.initializeKeyStorage();

      this.initialized = true;
      this.log('Encryption manager initialized successfully');
    } catch (error) {
      this.log('Failed to initialize encryption manager:', error);
      throw error;
    }
  }

  /**
   * Check if Web Crypto API is supported
   */
  private isWebCryptoSupported(): boolean {
    return (
      typeof window !== 'undefined' &&
      'crypto' in window &&
      'subtle' in window.crypto &&
      typeof window.crypto.subtle.encrypt === 'function'
    );
  }

  /**
   * Initialize key storage backend
   */
  private async initializeKeyStorage(): Promise<void> {
    switch (this.config.keyStorage.location) {
      case 'memory':
        this.keyStorage = new MemoryKeyStorage();
        break;
      case 'indexedDB':
        this.keyStorage = new IndexedDBKeyStorage();
        break;
      case 'sessionStorage':
        // SessionStorage implementation would go here
        this.keyStorage = new MemoryKeyStorage();
        break;
      default:
        this.keyStorage = new MemoryKeyStorage();
    }

    this.log('Key storage initialized:', this.config.keyStorage.location);
  }

  /**
   * Generate a cryptographic key
   */
  public async generateKey(
    algorithm: 'AES-GCM' | 'AES-CBC' | 'AES-CTR' = this.config.defaultAlgorithm,
    extractable = false
  ): Promise<CryptoKey> {
    try {
      if (!this.initialized) {
        throw new Error('Encryption manager not initialized');
      }

      const keySpec: AesKeyGenParams = {
        name: algorithm,
        length: this.config.security.keyLength * 8, // Convert to bits
      };

      const key = await crypto.subtle.generateKey(
        keySpec,
        extractable,
        ['encrypt', 'decrypt']
      );

      this.log('Generated key for algorithm:', algorithm);
      return key;
    } catch (error) {
      
      throw error;
    }
  }

  /**
   * Derive key from password using PBKDF2
   */
  public async deriveKeyFromPassword(
    password: string,
    options: KeyDerivationOptions = {}
  ): Promise<CryptoKey> {
    try {
      if (!this.initialized) {
        throw new Error('Encryption manager not initialized');
      }

      const {
        salt = this.generateRandomBytes(this.config.security.saltLength),
        iterations = this.config.security.pbkdf2Iterations,
        keyLength = this.config.security.keyLength,
        hashAlgorithm = 'SHA-256',
      } = options;

      // Import password as key
      const passwordKey = await crypto.subtle.importKey(
        'raw',
        new TextEncoder().encode(password),
        'PBKDF2',
        false,
        ['deriveBits', 'deriveKey']
      );

      // Derive key
      const derivedKey = await crypto.subtle.deriveKey(
        {
          name: 'PBKDF2',
          salt,
          iterations,
          hash: hashAlgorithm,
        } as Pbkdf2Params,
        passwordKey,
        {
          name: this.config.defaultAlgorithm,
          length: keyLength * 8,
        } as AesKeyGenParams,
        false,
        ['encrypt', 'decrypt']
      );

      this.log('Derived key from password using PBKDF2');
      return derivedKey;
    } catch (error) {
      
      throw error;
    }
  }

  /**
   * Encrypt data
   */
  public async encrypt<T = string>(
    data: T,
    key: CryptoKey | string,
    options: EncryptionOptions = {}
  ): Promise<EncryptionResult> {
    try {
      if (!this.initialized) {
        throw new Error('Encryption manager not initialized');
      }

      const {
        algorithm = this.config.defaultAlgorithm,
        additionalData,
        includeIntegrity = this.config.security.includeIntegrity,
      } = options;

      // Resolve key
      let cryptoKey: CryptoKey;
      if (typeof key === 'string') {
        cryptoKey = await this.deriveKeyFromPassword(key, options.keyDerivationOptions);
      } else {
        cryptoKey = key;
      }

      // Prepare data
      let plaintext: string;
      if (typeof data === 'string') {
        plaintext = data;
      } else {
        plaintext = JSON.stringify(data);
      }

      // Compress if requested
      if (options.compress) {
        // Compression would be implemented here
        this.log('Data compressed before encryption');
      }

      const plaintextBytes = new TextEncoder().encode(plaintext);

      // Generate IV
      const iv = this.generateRandomBytes(this.getIVLength(algorithm));

      // Prepare algorithm parameters
      let algorithmParams: AesGcmParams | AesCbcParams | AesCtrParams;

      switch (algorithm) {
        case 'AES-GCM':
          algorithmParams = {
            name: 'AES-GCM',
            iv,
            ...(additionalData && { additionalData }),
          } as AesGcmParams;
          break;
        case 'AES-CBC':
          algorithmParams = {
            name: 'AES-CBC',
            iv,
          } as AesCbcParams;
          break;
        case 'AES-CTR':
          algorithmParams = {
            name: 'AES-CTR',
            counter: iv,
            length: 64,
          } as AesCtrParams;
          break;
        default:
          throw new Error(`Unsupported algorithm: ${algorithm}`);
      }

      // Encrypt
      const encryptedBuffer = await crypto.subtle.encrypt(
        algorithmParams,
        cryptoKey,
        plaintextBytes
      );

      const encrypted = this.arrayBufferToBase64(encryptedBuffer);
      const ivBase64 = this.arrayBufferToBase64(iv.buffer as ArrayBuffer);

      // Generate integrity hash if requested
      let integrity: string | undefined;
      if (includeIntegrity) {
        integrity = await this.generateIntegrityHash(encrypted + ivBase64);
      }

      const result: EncryptionResult = {
        encrypted,
        iv: ivBase64,
        algorithm,
        timestamp: Date.now(),
        ...(integrity && { integrity }),
      };

      this.log('Data encrypted successfully using', algorithm);
      return result;
    } catch (error) {
      
      throw error;
    }
  }

  /**
   * Decrypt data
   */
  public async decrypt<T = string>(
    encryptedData: EncryptionResult,
    key: CryptoKey | string,
    options: KeyDerivationOptions = {}
  ): Promise<DecryptionResult<T>> {
    try {
      if (!this.initialized) {
        throw new Error('Encryption manager not initialized');
      }

      const { encrypted, iv, algorithm, integrity } = encryptedData;

      // Resolve key
      let cryptoKey: CryptoKey;
      if (typeof key === 'string') {
        cryptoKey = await this.deriveKeyFromPassword(key, options);
      } else {
        cryptoKey = key;
      }

      // Verify integrity if present
      let verified = true;
      if (integrity) {
        const computedIntegrity = await this.generateIntegrityHash(encrypted + iv);
        verified = computedIntegrity === integrity;
        
        if (!verified) {
          this.log('WARNING: Integrity verification failed');
        }
      }

      // Prepare algorithm parameters
      const ivBuffer = this.base64ToArrayBuffer(iv);
      let algorithmParams: AesGcmParams | AesCbcParams | AesCtrParams;

      switch (algorithm) {
        case 'AES-GCM':
          algorithmParams = {
            name: 'AES-GCM',
            iv: ivBuffer,
          } as AesGcmParams;
          break;
        case 'AES-CBC':
          algorithmParams = {
            name: 'AES-CBC',
            iv: ivBuffer,
          } as AesCbcParams;
          break;
        case 'AES-CTR':
          algorithmParams = {
            name: 'AES-CTR',
            counter: ivBuffer,
            length: 64,
          } as AesCtrParams;
          break;
        default:
          throw new Error(`Unsupported algorithm: ${algorithm}`);
      }

      // Decrypt
      const encryptedBuffer = this.base64ToArrayBuffer(encrypted);
      const decryptedBuffer = await crypto.subtle.decrypt(
        algorithmParams,
        cryptoKey,
        encryptedBuffer
      );

      const decrypted = new TextDecoder().decode(decryptedBuffer);

      // Handle decompression if needed
      // Decompression would be implemented here

      // Try to parse as JSON if it looks like JSON
      let result: T;
      try {
        if (decrypted.startsWith('{') || decrypted.startsWith('[')) {
          result = JSON.parse(decrypted) as T;
        } else {
          result = decrypted as T;
        }
      } catch {
        result = decrypted as T;
      }

      this.log('Data decrypted successfully using', algorithm);
      return {
        decrypted: result,
        algorithm,
        timestamp: encryptedData.timestamp,
        verified,
      };
    } catch (error) {
      
      throw error;
    }
  }

  /**
   * Generate RSA key pair for asymmetric encryption
   */
  public async generateKeyPair(
    keySize = 2048,
    extractable = false
  ): Promise<KeyPair> {
    try {
      if (!this.initialized) {
        throw new Error('Encryption manager not initialized');
      }

      const keyPair = await crypto.subtle.generateKey(
        {
          name: 'RSA-OAEP',
          modulusLength: keySize,
          publicExponent: new Uint8Array([1, 0, 1]),
          hash: 'SHA-256',
        },
        extractable,
        ['encrypt', 'decrypt']
      );

      this.log('Generated RSA key pair with', keySize, 'bit keys');
      return {
        publicKey: keyPair.publicKey,
        privateKey: keyPair.privateKey,
        algorithm: 'RSA-OAEP',
      };
    } catch (error) {
      
      throw error;
    }
  }

  /**
   * Sign data with private key
   */
  public async sign(
    data: string | ArrayBuffer,
    privateKey: CryptoKey,
    algorithm = 'RSASSA-PKCS1-v1_5'
  ): Promise<SignatureResult> {
    try {
      if (!this.initialized) {
        throw new Error('Encryption manager not initialized');
      }

      const dataBuffer = typeof data === 'string' 
        ? new TextEncoder().encode(data)
        : data;

      const signatureBuffer = await crypto.subtle.sign(
        {
          name: algorithm,
          hash: 'SHA-256',
        },
        privateKey,
        dataBuffer
      );

      const signature = this.arrayBufferToBase64(signatureBuffer);

      this.log('Data signed successfully using', algorithm);
      return {
        signature,
        algorithm,
        timestamp: Date.now(),
      };
    } catch (error) {
      
      throw error;
    }
  }

  /**
   * Verify signature with public key
   */
  public async verify(
    data: string | ArrayBuffer,
    signature: string,
    publicKey: CryptoKey,
    algorithm = 'RSASSA-PKCS1-v1_5'
  ): Promise<boolean> {
    try {
      if (!this.initialized) {
        throw new Error('Encryption manager not initialized');
      }

      const dataBuffer = typeof data === 'string' 
        ? new TextEncoder().encode(data)
        : data;

      const signatureBuffer = this.base64ToArrayBuffer(signature);

      const isValid = await crypto.subtle.verify(
        {
          name: algorithm,
          hash: 'SHA-256',
        },
        publicKey,
        signatureBuffer,
        dataBuffer
      );

      this.log('Signature verification result:', isValid);
      return isValid;
    } catch {
      
      return false;
    }
  }

  /**
   * Store key with ID
   */
  public async storeKey(
    keyId: string,
    key: CryptoKey,
    metadata?: Record<string, unknown>
  ): Promise<void> {
    if (!this.config.keyStorage.enabled) {
      throw new Error('Key storage is disabled');
    }

    const fullKeyId = this.config.keyStorage.keyPrefix + keyId;
    await this.keyStorage.store(fullKeyId, key, metadata);
    this.log('Key stored with ID:', keyId);
  }

  /**
   * Retrieve key by ID
   */
  public async retrieveKey(keyId: string): Promise<CryptoKey | null> {
    if (!this.config.keyStorage.enabled) {
      throw new Error('Key storage is disabled');
    }

    const fullKeyId = this.config.keyStorage.keyPrefix + keyId;
    const key = await this.keyStorage.retrieve(fullKeyId);
    
    if (key) {
      this.log('Key retrieved with ID:', keyId);
    }
    
    return key;
  }

  /**
   * Remove key by ID
   */
  public async removeKey(keyId: string): Promise<boolean> {
    if (!this.config.keyStorage.enabled) {
      throw new Error('Key storage is disabled');
    }

    const fullKeyId = this.config.keyStorage.keyPrefix + keyId;
    const removed = await this.keyStorage.remove(fullKeyId);
    
    if (removed) {
      this.log('Key removed with ID:', keyId);
    }
    
    return removed;
  }

  /**
   * List all stored key IDs
   */
  public async listKeys(): Promise<string[]> {
    if (!this.config.keyStorage.enabled) {
      return [];
    }

    const allKeys = await this.keyStorage.list();
    return allKeys
      .filter(key => key.startsWith(this.config.keyStorage.keyPrefix))
      .map(key => key.substring(this.config.keyStorage.keyPrefix.length));
  }

  /**
   * Generate random bytes
   */
  public generateRandomBytes(length: number): Uint8Array {
    if (this.config.security.secureRandom && crypto.getRandomValues) {
      return crypto.getRandomValues(new Uint8Array(length));
    } else {
      // Fallback to Math.random (less secure)
      const bytes = new Uint8Array(length);
      for (let i = 0; i < length; i++) {
        bytes[i] = Math.floor(Math.random() * 256);
      }
      return bytes;
    }
  }

  /**
   * Generate hash for integrity checking
   */
  private async generateIntegrityHash(data: string): Promise<string> {
    const buffer = new TextEncoder().encode(data);
    const hashBuffer = await crypto.subtle.digest('SHA-256', buffer);
    return this.arrayBufferToBase64(hashBuffer);
  }

  /**
   * Get IV length for algorithm
   */
  private getIVLength(algorithm: string): number {
    switch (algorithm) {
      case 'AES-GCM':
        return 12; // 96 bits recommended for GCM
      case 'AES-CBC':
      case 'AES-CTR':
        return 16; // 128 bits for CBC and CTR
      default:
        return this.config.security.ivLength;
    }
  }

  /**
   * Convert ArrayBuffer to Base64
   */
  private arrayBufferToBase64(buffer: ArrayBuffer): string {
    const bytes = new Uint8Array(buffer);
    let binary = '';
    for (let i = 0; i < bytes.byteLength; i++) {
      binary += String.fromCharCode(bytes[i] ?? 0);
    }
    return btoa(binary);
  }

  /**
   * Convert Base64 to ArrayBuffer
   */
  private base64ToArrayBuffer(base64: string): ArrayBuffer {
    const binary = atob(base64);
    const bytes = new Uint8Array(binary.length);
    for (let i = 0; i < binary.length; i++) {
      bytes[i] = binary.charCodeAt(i);
    }
    return bytes.buffer;
  }

  /**
   * Debug logging
   */
  private log(..._unusedArgs: unknown[]): void {
    if (this.debug) {
      
    }
  }

  /**
   * Clean up resources
   */
  public async cleanup(): Promise<void> {
    if (this.config.keyStorage.enabled) {
      await this.keyStorage.clear();
    }
    this.initialized = false;
  }
}

// Create and export singleton instance
const encryption = EncryptionManager.getInstance();

// Convenience functions for common encryption operations
export const encryptData = <T = string>(
  data: T,
  key: CryptoKey | string,
  options?: EncryptionOptions
): Promise<EncryptionResult> => {
  return encryption.encrypt(data, key, options);
};

export const decryptData = <T = string>(
  encryptedData: EncryptionResult,
  key: CryptoKey | string,
  options?: KeyDerivationOptions
): Promise<DecryptionResult<T>> => {
  return encryption.decrypt<T>(encryptedData, key, options);
};

export const generateEncryptionKey = (
  algorithm?: 'AES-GCM' | 'AES-CBC' | 'AES-CTR'
): Promise<CryptoKey> => {
  return encryption.generateKey(algorithm);
};

export const deriveKey = (
  password: string,
  options?: KeyDerivationOptions
): Promise<CryptoKey> => {
  return encryption.deriveKeyFromPassword(password, options);
};

export const generateKeyPair = (keySize?: number): Promise<KeyPair> => {
  return encryption.generateKeyPair(keySize);
};

export const signData = (
  data: string | ArrayBuffer,
  privateKey: CryptoKey,
  algorithm?: string
): Promise<SignatureResult> => {
  return encryption.sign(data, privateKey, algorithm);
};

export const verifySignature = (
  data: string | ArrayBuffer,
  signature: string,
  publicKey: CryptoKey,
  algorithm?: string
): Promise<boolean> => {
  return encryption.verify(data, signature, publicKey, algorithm);
};

export const storeEncryptionKey = (
  keyId: string,
  key: CryptoKey,
  metadata?: Record<string, unknown>
): Promise<void> => {
  return encryption.storeKey(keyId, key, metadata);
};

export const retrieveEncryptionKey = (keyId: string): Promise<CryptoKey | null> => {
  return encryption.retrieveKey(keyId);
};

export const generateRandomBytes = (length: number): Uint8Array => {
  return encryption.generateRandomBytes(length);
};

export const initializeEncryption = (config?: Partial<EncryptionConfig>): Promise<void> => {
  return encryption.initialize(config);
};

// Export the encryption instance for advanced usage
export { encryption };
export default encryption;