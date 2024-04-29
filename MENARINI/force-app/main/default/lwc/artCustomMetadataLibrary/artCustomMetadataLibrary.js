// MetadataUtility
import apex_getAllByMetadataName from "@salesforce/apex/ART_CustomMetadataUtility.getAllByMetadataName";
import apex_getMapByMetadataName from "@salesforce/apex/ART_CustomMetadataUtility.getMapByMetadataName";
import apex_getMapByMetadataNameKey from "@salesforce/apex/ART_CustomMetadataUtility.getMapByMetadataNameKey";
import apex_getRecordByName from "@salesforce/apex/ART_CustomMetadataUtility.getRecordByName";
import apex_getRecordByPrefix from "@salesforce/apex/ART_CustomMetadataUtility.getRecordByPrefix";
import apex_makeQuery from "@salesforce/apex/ART_CustomMetadataUtility.makeQuery";
import apex_makeQueryWithFields from "@salesforce/apex/ART_CustomMetadataUtility.makeQueryWithFields";


export default class ArtCustomMetadataLibrary {
    
    static getAllByMetadataName = (metadataName) => {
        return new Promise(function (resolve, reject) {
            apex_getAllByMetadataName({ metadataName: metadataName }).then(result => {
                resolve(result);
            }).catch(error => {
                reject(error);
            });
        });
    }
    static getMapByMetadataName = (metadataName) => {
        return new Promise(function(resolve,reject) {
            apex_getMapByMetadataName({metadataName:metadataName}).then(result=>{
                resolve(result);            
            }).catch(error=>{
                reject(error);
            });
        });
    }
    static getMapByMetadataNameKey = (metadataName,key) => {
        return new Promise(function(resolve,reject) {
            apex_getMapByMetadataNameKey({metadataName:metadataName,key:key}).then(result=>{
                resolve(result);            
            }).catch(error=>{
                reject(error);
            });
        });
    }
    static getMetadataRecordByName = (metadataName,name) => {
        return new Promise(function(resolve,reject) {
            apex_getRecordByName({metadataName:metadataName,name:name}).then(result=>{
                resolve(result);            
            }).catch(error=>{
                reject(error);
            });
        });
    }
    static getMetadataRecordByPrefix = (metadataName,prefix) => {
        return new Promise(function(resolve,reject) {
            apex_getRecordByPrefix({metadataName:metadataName,prefix:prefix}).then(result=>{
                resolve(result);            
            }).catch(error=>{
                reject(error);
            });
        });
    }
    static makeMetadataQuery = (metadataName,whereCondition) => {
        return new Promise(function(resolve,reject) {
            apex_makeQuery({metadataName:metadataName,whereCondition:whereCondition}).then(result=>{
                resolve(result);            
            }).catch(error=>{
                reject(error);
            });
        });
    }
    static makeMetadataQueryWithFields = (metadataName,whereCondition,queryFields) => {
        return new Promise(function(resolve,reject) {
            apex_makeQueryWithFields({metadataName:metadataName,whereCondition:whereCondition,queryFields:queryFields}).then(result=>{
                resolve(result);            
            }).catch(error=>{
                reject(error);
            });
        });
    }
}