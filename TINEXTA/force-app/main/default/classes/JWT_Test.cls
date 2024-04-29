@isTest
public class JWT_Test {
	static testMethod void test_none() {
		JWT jwt = new JWT('none');
        jwt.userEmail = 'test@test.com';
        jwt.iss = 'your issuer';
        jwt.sub = 'some subject';
        jwt.aud = 'some audience';
        
        String token = jwt.issue();
    }
    
    static testMethod void test_HMAC256() {
		JWT jwt = new JWT('HS256');
        jwt.userEmail = 'test@test.com';
        jwt.privateKey = 'base64 encoded secret';
        jwt.iss = 'your issuer';
        jwt.sub = 'some subject';
        jwt.aud = 'some audience';
        
        String token = jwt.issue();
    }
    
    static testMethod void test_RSA256() {
		JWT jwt = new JWT('RS256');
        jwt.userEmail = 'test@test.com';
        //jwt.cert = 'JWTKey';
        jwt.pkcs8 = 'MIIBVgIBADANBgkqhkiG9w0BAQEFAASCAUAwggE8AgEAAkEAq7BFUpkGp3+LQmlQ' +
                    'Yx2eqzDV+xeG8kx/sQFV18S5JhzGeIJNA72wSeukEPojtqUyX2J0CciPBh7eqclQ' +
                    '2zpAswIDAQABAkAgisq4+zRdrzkwH1ITV1vpytnkO/NiHcnePQiOW0VUybPyHoGM' +
                    '/jf75C5xET7ZQpBe5kx5VHsPZj0CBb3b+wSRAiEA2mPWCBytosIU/ODRfq6EiV04' +
                    'lt6waE7I2uSPqIC20LcCIQDJQYIHQII+3YaPqyhGgqMexuuuGx+lDKD6/Fu/JwPb' +
                    '5QIhAKthiYcYKlL9h8bjDsQhZDUACPasjzdsDEdq8inDyLOFAiEAmCr/tZwA3qeA' +
                    'ZoBzI10DGPIuoKXBd3nk/eBxPkaxlEECIQCNymjsoI7GldtujVnr1qT+3yedLfHK' +
                    'srDVjIT3LsvTqw==';
        jwt.iss = 'your issuer';
        jwt.sub = 'some subject';
        jwt.aud = 'some audience';
        
        String token = jwt.issue();
    }
}