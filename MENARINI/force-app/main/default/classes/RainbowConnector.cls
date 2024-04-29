global class RainbowConnector {
 webService static String formatPhoneNumber(String phoneNumber) {
 String formatPhoneNumber = phoneNumber;
//https://grmenarini--dev1.my.salesforce.com/_ui/common/apex/debug/ApexCSIPage#
 // By example: conversion for US
 // input +18171231234 => search (817)123-1234
 // uncomment the following lines
 // if (phoneNumber.startsWith('+1')) {
 // formatPhoneNumber = '(' + phoneNumber.substring(2, 5) + ')' + phoneNumber.substring(5, 8) + '-' +
phoneNumber.substring(8);
 // }
 return formatPhoneNumber;
 }
 webService static String getAccountsByPhoneNumber(String phoneNumber) {
 String formatedPhoneNumber = formatPhoneNumber(phoneNumber);
 List < Account > accountList = new List<Account>();
  for (Account account: [SELECT id, name, phone FROM Account WHERE phone LIKE : ('%' + formatedPhoneNumber +
'%')]) {
 accountList.add(account);
 }
 String JSONString = JSON.serialize(accountList);
 return JSONString;
 }
 webService static String getAccountsByFirstLastName(String firstlastname) {
 List < Account > accountList = new List<Account>();
 for (Account account: [SELECT id, name, phone FROM Account WHERE name = : firstlastname]) {
 accountList.add(account);
 }
 String JSONString = JSON.serialize(accountList);
 return JSONString;
 }
 webService static String getContactsByPhoneNumber(String phoneNumber) {
 String formatedPhoneNumber = formatPhoneNumber(phoneNumber);
 List < Contact > contactList = new List<Contact>();
 for (Contact contact: [SELECT id, name, email, phone, otherphone, mobilephone, homephone FROM Contact
WHERE(phone LIKE : ('%' + formatedPhoneNumber + '%') OR otherphone LIKE : ('%' + formatedPhoneNumber + '%') OR
mobilephone LIKE : ('%' + formatedPhoneNumber + '%') OR homephone LIKE : ('%' + formatedPhoneNumber + '%'))]) {
 contactList.add(contact);
 }
 String JSONString = JSON.serialize(contactList);
 return JSONString;
 }
 webService static String getContactsByFirstLastName(String firstlastname) {
 List < Contact > contactList = new List<Contact>();
 for (Contact contact: [SELECT id, name, email, phone, otherphone, mobilephone, homephone FROM Contact WHERE
name LIKE : ('%' + firstlastname + '%')]) {
 contactList.add(contact);
 }
 String JSONString = JSON.serialize(contactList);
 return JSONString;
 }
 webService static String getContactsByEmail(String emailContact) {
 List < Contact > contactList = new List<Contact>();
 for (Contact contact: [SELECT id, name, email, phone, otherphone, mobilephone, homephone FROM Contact WHERE
email LIKE : ('%' + emailContact + '%')]) {
 contactList.add(contact);
 }
 String JSONString = JSON.serialize(contactList);
 return JSONString;
 }
 webService static String getContactByRecordId(String recordId) {
 List < Contact > contactList = new List<Contact>();
 for (Contact contact: [SELECT id, name, email, phone, otherphone, mobilephone, homephone FROM Contact WHERE Id
=: recordId]) {
 contactList.add(contact);
 }
 String JSONString = JSON.serialize(contactList);
 return JSONString;
 }
}