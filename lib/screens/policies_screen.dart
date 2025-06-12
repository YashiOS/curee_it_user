import 'package:cureeit_user_app/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class PoliciesScreen extends StatelessWidget {
  const PoliciesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBlackColor,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: true,
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
        ),
        title: Text(
          "Policies",
          style: GoogleFonts.mulish(
              color: whiteColor, fontSize: 22.69, fontWeight: FontWeight.w400),
        ),
        backgroundColor: ligtBlackColor,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 24.0),
            child: Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Row(
                spacing: 4,
                children: [
                  SvgPicture.asset(
                    colorFilter:
                        ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    "lib/images/back.svg",
                    width: 24, // optional
                    height: 24, // optional
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: RawScrollbar(
        radius:  Radius.circular(10),
   thumbColor: greenColor,
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Privacy Policy",
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w700),
                ),
                Text(
                  '''Cureeit Medicos Pvt. Ltd. (“Medkaro”), a company incorporated under the Companies Act, 2013 and having its registered office at 355, Vinoba Vihar, Model Town, Maviya Nagar, Malviya Nagar (Jaipur), Jaipur, Jaipur, Rajasthan, India, 302017, is the owner of the brand Medkaro and web based platform ‘Medkaro.in’ and mobile application ‘Medkaro’ (collectively, the“Platform”). The ‘Company’ is a licensee of the brand Medkaro and the Platform, and is responsible for operating and managing the Platform under the license. You can access the complete Company details here.''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),
                Text(
                  '''This privacy policy (Privacy Policy) describes the policies and procedures applicable to the collection, use, disclosure and protection of Your information shared with Us while You use the Platform, and for the purpose of this Privacy Policy "We", "Us", or "Our" refers to any of the Company or Medkaro or both of them, wherever context so require and the terms “You”, “Your”, “Yourself” or “User” refer to user of the Platform. We value the trust You place in Us. That is why, We maintain reasonable security standards for securing the transactions andYour information.''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),
                Text(
                  '''This Privacy Policy specifies the manner in which Your information is collected, received, stored, processed, disclosed, transferred, dealt with or otherwise handled by Us. This Privacy Policy does not apply to information that You provide to, or that is collected by, any third-party through the Platform, and any Third-Party Sites that You access or use in connection with the Services offered on the Platform. By visiting the Platform or setting up/creating an user account (Account) on the Platform, You accept and agree to be bound by the terms and conditions of this Privacy Policy and consent to Us collecting, storing, processing, transferring and sharing information including Your Personal Information (defined below) in accordance with this Privacy Policy. Further, in case You are under the age of 18 years, You (i) accept and acknowledge that You are accessing the Platform through a parent or a legal guardian who is of a legal age to form a binding contract under the Indian Contract Act, 1872 and such person has accepted this Privacy Policy on Your behalf to bind You; and (ii) hereby acknowledge that You are accessing this Platform under the supervision of Your parent or legal guardian and have their express permission to use the Services. We may update this Privacy Policy in order to comply with the regulatory or administrative requirements. If We make any significant changes to this Privacy Policy, We will endeavour to provide You with reasonable notice of such changes, such as via prominent notice on the platform or any other communication channels on record.''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),
                  Text(
                  '''To the extent permitted under applicable law, Your continued use of the Services after We publish or send a notice about the changes to this Privacy Policy shall constitute Your consent to the updated Privacy Policy. This Privacy Policy is incorporated into and subject to the terms of use available on the Platform (“Terms”) and shall be read harmoniously and in conjunction with the Terms. All capitalised terms used herein however not defined under this Privacy Policy shall have the meaning ascribed to them under the Terms. 1) Collection of Information: We collect various information from You when You access or visit the Platform, register or set up an Account on the Platform or use the Platform. You may browse certain sections of the Platform and the Content, without registering an Account on the Platform. However, to avail certain Services on the Platform, You are required to set up an Account on the Platform. This Privacy Policy applies to information(s), as mentioned below and collected about You:''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),
                 Text(
                  '''a) Personal Information: You may provide certain information to Us voluntarily while registering on the Platform for availing Services including but not limited to Your complete name, mobile number, email address, date of birth, gender, age, address details, proof of identity such as Permanent Account Number (PAN), passport, driving license, the voter's identity card issued by the Election Commission of India, or any other document recognized by the Government for identification, and any other information voluntarily provided through the Platform (“Personal Information”). The act of providing Your Personal Information is voluntary in nature and We hereby agree and acknowledge that We will collect, use, store, transfer, deal with and share such details in compliance with applicable laws and this Privacy Policy.''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),
                Text(
                  '''b) Sensitive Personal Information: For the purpose of this Privacy Policy, Sensitive Personal Information consists of information relating to the following:''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),
                Text(
                  '''i) passwords;''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),
                Text(
                  '''ii) financial information such as bank account or credit card or debit card or other payment instrument details;''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),
                 Text(
                  '''iii) physical, physiological and mental health condition;''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),
                 Text(
                  '''iv) sexual orientation;''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),
                 Text(
                  '''v) medical records and history;''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),
                 Text(
                  '''vi) biometric information;''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),
                 Text(
                  '''vii) any details relating to the above as provided to a body corporate for providing services; and''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),
                 Text(
                  '''viii) any details relating to the above, received by a body corporate for processing, stored or processed under lawful contract or otherwise.''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),
                 Text(
                  '''ix) any other information that may be regarded as Sensitive Personal Information as per the prevailing law for the time being in force.''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),
        
                 Text(
                  '''Provided that, any information that is freely available or accessible in public domain or furnished under the Right to Information Act, 2005 or any other law for the time being in force shall not be regarded as Sensitive Personal Information.''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ), Text(
                  '''You may be asked for the payment details to process payments for the Services. You may also be asked to provide certain additional information about Yourself on a case to case basis.''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),
                 Text(
                  '''c) Transactional Information: If You choose to avail the Services through the Platform, We will also collect and store information about Your transactions including transaction status, order history, number of transactions, details and Your behaviour or preferences on the Platform. All transactional information gathered by Us shall be stored on servers, log files and any other storage system owned by any of Us or by third parties.''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),
                 Text(
                  '''d) Location based information: When and if You download and/or use the Platform through Your mobile, tablet, and/or any other computer sources or electronic devices, We may receive information about Your location, Your IP address, including a unique identifier number for Your device. The informationYou provide may be used to provide You with location-based Services including but not limited to search results and other personalized content. If You permit the Platform to access Your location through the permission system used by Your device operating system, the precise location of Your device when the Platform is running in the foreground or background may be collected. You can withdraw Your consent at any time by disabling the location tracking functions on Your device. However, this may affect Your experience of certain functionalities on the Platform. In addition to the above, Your IP address is identified and used to also help diagnose problems with Our server, resolve such problems and administer the Platform. Your IP address is also used to help identify You and to gather broad demographic information.''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),
                 Text(
                  '''The primary goal in doing so is to provide You a safe, efficient, smooth, and customized experience on the Platform. The information collected allows Us to provide the Services and/or features on the Platform that most likely meet Your needs, and to customize the Platform to make Your experience safer and easier. More importantly, while doing so, We collect the above - mentioned Personal Information from You that We consider necessary for achieving this purpose.''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),
                 Text(
                  '''We may also collect certain non-personal information, such as Your internet protocol address, web request, operating system, browser type, other browsing information (connection, speed, connection type etc.), device type, the device's telephone number, URL, internet service provider, aggregate user data, software and hardware attributes, the URL of the previous website visited by You, list of third-party applications being used by You, pages You request, and cookie information, etc. which will not identify with You specifically, the activities conducted by You (“Non - Personal Information”), while You browse, access or use the Platform. We receive and store Non-Personal Information by the use of data collection devices such as “cookies” on certain pages of the Platform for various purposes, including authenticating Users, store information (including on Your device or in Your browser cache) about Your use of our Services, remembering User preferences and settings, determining the relevancy of content, delivering and measuring the promotional effectiveness, and promote trust and safety, analyzing site traffic and trends, and generally understanding the online behaviors and interests of people.''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),
                 Text(
                  '''Certain additional features may be offered on the Platform that are only available through use of a “cookie”. We place both permanent and temporary cookies in Your device. We may also use cookies from third party partners for marketing and analytics purposes.''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),
                 Text(
                  '''You are always free to decline such cookies if Your browser permits, although in that case, You may not be able to use certain features or Services being provided on the Platform.''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),
                 Text(
                  '''In general, You can browse the Platform without telling Us who You are or revealing any Personal Information about Yourself. In such a case, We will only collect and store the Non -Personal Information. Once You give us Your Personal Information, You are not anonymous to Us. Wherever possible, while providing the information to Us, We indicate which fields are mandatory and which fields are optional for You. You always have the option to not provide the Personal Information to Us through the Platform by choosing to not use a particular Service or feature being provided on the Platform, which requires You to provide such information. We may automatically track certain information about You based upon Your behaviour on the Platform. We use this information to do internal research on Your demographics, interests, and behaviour to better understand, protect and prove service to You. This information is compiled and analyzed by Us on an aggregated basis and not individually, in a manner that does not specifically identify You.''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),
                 Text(
                  '''If You choose to post messages on the Platform’s message boards, chat rooms or other message areas or leave feedback, We will collect and store such information You provide to Us. We retain this information as necessary to resolve disputes, provide customer support, respond to queries, and inquiries, and troubleshoot problems and improve the Services.''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),
                 Text(
                  '''If You send us correspondence, such as emails or letters, or if other users or third parties send us correspondence about Your activities or postings on the Platform, We may collect and retain such information into a file specific to You for responding to Your request and addressing concerns in relation to Your use of the Platform.''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),
                 Text(
                  '''We shall be entitled to retain Your Personal Information and other information for such duration as may be required for the purposes specified hereunder and will be used only in accordance with this Privacy Policy.''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),
                 Text(
                  '''2) Use of information: We use the information, for the following:''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),
                 Text(
                  '''a) to provide and improve the Services on the Platform that you Request;''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),
                 Text(
                  '''b) for internal business purposes and services, including without limitation, warehousing services, delivery services, IT support services, and data analysis services;''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),
                 Text(
                  '''c) to resolve disputes, administer our service and diagnose/troubleshoot technical problems;''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),
                 Text(
                  '''d) to help promote a safe service on the Platform and protect the security and integrity of the Platform, the Services and the users;''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),
                Text(
                  '''e) to design and improve the products and Services and customer relationship management processes;''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),
                Text(
                  '''f) to collect money from You in relation to the Services,''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),
                Text(
                  '''g) to inform You about online and offline offers, product, services and updates;''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),
                Text(
                  '''h) to customize Your experience on the platform or shake marketing material with You;''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),
                Text(
                  '''i) to detect, prevent and protect Us from any errors, fraud and other criminal or prohibited activity on the Platform;''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),
                Text(
                  '''j) to enforce and inform about Our Terms;''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),
                Text(
                  '''k) to process and fulfill Your request for Services or respond to Your comments, and queries on the Platform;''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),
                Text(
                  '''l) to contact You through email, SMS, WhatsApp, telephone and any other mode of communication in relation to the Services;''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),
                Text(
                  '''m) to allow Our service providers, business partners and/or associates to present customized messages to You;''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),
                Text(
                  '''n) to communicate important notices or changes in the Services, use of the Platform and the Terms/policies which govern the relationship between You and the Company and/or Medkaro, as applicable;''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),
                Text(
                  '''o) to conform to the legal requirements, compliance/reporting to regulatory authorities, as may be required and to comply with applicable laws;''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),

                Text(
                  '''p) to carry out Our obligations and enforce Our rights arising from any contract entered into between You and Us; and''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),
                Text(
                  '''q) to carry out research with relevant partners.''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),
                Text(
                  '''r) for any other purpose after obtaining Your consent at the time of collection.''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),

                Text(
                  '''(collectively “Purposes”).''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),
                Text(
                  '''The Company and/or Medkaro may occasionally ask You to complete optional online surveys. These surveys may ask You for Your contact information and demographic information (like pin code, or age). We use this information to tailor Your experience on the Platform, providing You with content that We think You might be interested in and to display content according to Your preferences. We use Your information to send You promotional emails, however, We will provide You the ability to opt-out of receiving such emails from Us. However, You will not be able to opt-out of receiving administrative messages, customer service responses or other transactional communications. We will not share Your Personal Information with another user of the Platform and vice versa without Your express consent.''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),

                Text(
                  '''3) Sharing of Information:''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),
                Text(
                  '''a) Third Party Service Providers: We may disclose Your Personal Information to third party vendors, delivery partners, consultants, partners for carrying out research and other service providers who work for either of Us or provide Services through the Platform and are bound by contractual obligations to keep such Personal Information confidential and use it only for the purposes for which We disclose it to them and maintain the same level of data protection that is adhered to by Us. This disclosure may be required, for instance, to provide You access to the Services and process payments including validation of Your Payment Details, to facilitate and assist marketing and advertising activities/initiatives, for undertaking auditing or data analysis, or''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),

                Text(
                  '''to prevent, detect, mitigate, and investigate fraudulent or illegal activities related to the Services. You expressly consent to the sharing of Your information with third party service providers, including payment gateways, to process payments and manage Your payment-related information. We do not disclose Your Personal Information to third parties for their marketing and advertising purposes without Your explicit consent.''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),
                Text(
                  '''b) Compliance with law: We may disclose Your information including Personal Information, to the extent necessary: (a) to comply with laws, regulatory requirements and to respond to lawful requests and legal process or an investigation, (b) to protect Our rights and property, the users, and others, including to enforce the Terms or to prevent any illegal or unlawful activities, and (c) in an emergency to protect Our personal safety and assets the users, or any person. In all such events We shall in no manner be responsible for informing You or seeking Your approval or consent. We may also share aggregated anonymized (and de-identified) information with third parties at Our discretion.''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),
                Text(
                  '''c) Acquisition Sale or Merger: We may, in compliance with applicable laws, share all of Your Personal Information (including SensitivePersonal Information) and other information with any other business entity(ies), in the event of a merger, sale, reorganisation, amalgamation, joint ventures, assignment, restructuring of business or transfer or disposition of all or any portion of any of Us.''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),
                Text(
                  '''d) Sharing of information with third party for operation of the Platform: In the event the license agreement is terminated or the territory of the license is modified or limited in any manner, We may share any or all Your Personal Information (including Sensitive Personal Information, if any) and Non-Personal Information with the incoming licensee continuity of smooth operation of the Platform and seamless user experience.''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),
                Text(
                  '''e) Sharing of information with any member of Our Group or affiliated entities, third parties and transfer outside India: Subject to applicable law, we may at Our sole discretion, share Personal Information (including Sensitive Personal Information) to Our Group or affiliated entities, any third party that ensures at least the same level of data protection as is provided by Us under the terms hereof, located in India or any other country. By using the Platform, You accept the terms hereof and hereby consent to Us, sharing of Your Personal Information and Sensitive Personal Information to Our Group or affiliated entities, third parties, including in any location outsideIndia, provided that they ensure that Your Personal Information and Sensitive Personal Information is protected in compliance with standards that are comparable to the standards of protection afforded to it in India.''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),
                Text(
                  '''For the purpose of this clause the term “Group” shall mean, with respect to any person, any entity that is controlled by such person, or any entity that controls such person, or any entity that is under common control with such person, whether directly or indirectly, including any Relative or Related Party (as such term defined in the Companies Act, 2013 to the extent applicable) of such person, holding, subsidiary Companies, etc.''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),
                Text(
                  '''You also specifically agree and consent to Us collecting, storing, processing, transferring, and sharing information (including Personal Information and Sensitive Personal Information)related to You with third parties such as with entities registered under applicable laws including payment gateways and aggregators, solely for Us to provide Services to You including processing Your transaction requests for theServices or to improve Your experience on the Platform.''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),
                Text(
                  '''4) Security Precautions and Measures: The Platform has reasonable security measures and safeguards in place to protect Your privacy and Personal Information from loss, misuse, unauthorized access, disclosure, destruction, and alteration, in compliance with applicable laws. Further, whenever You change or access Your Account on the Platform or any information relating to it, the use of a secure server is offered. It is further clarified that You have and so long as You access and/or use the Platform (directly or indirectly) the obligation to ensure that You shall at all times take adequate physical, managerial, and technical safeguards, at Your end, to preserve the integrity and security of Your data which shall include and not be limited to Your Personal Information.''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),
                Text(
                  '''You will be responsible for maintaining the confidentiality of the Account information and are fully responsible for all activities that occur under Your Account. You agree to (a)immediately notify Us of any unauthorized use of Your Account information or any other breach of security, and (b) ensure that You exit from Your Account at the end of each session. We cannot and will not be liable for any loss or damage arising from Your failure to comply with this provision. You may be held liable for losses incurred by any of Us or any other user of or visitor to thePlatform due to authorized or unauthorized use of Your Account as a result of Your failure in keeping Your Account information secure and confidential.''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),
                Text(
                  '''When payment information is being transmitted on or through the Platform, it will be protected by encryption technology. Hence, we cannot guarantee that transmissions of Your payment-related information or Personal Information will always be secure or that unauthorized third parties will never be able to defeat the security measures taken by Us or Our third-party service providers. We assume no liability or responsibility for disclosure of Your information due to errors in transmission, unauthorized third-party access, or other causes beyond Our control. You play an important role in keeping Your Personal Information secure. You shall not share Your Personal Information or other security information for Your Account with anyone. We have undertaken reasonable measures to protect Your rights of privacy with respect to Your usage of thePlatform and the Services. However, We shall not be liable for any unauthorized or unlawful disclosures of Your Personal Information made by any third parties who are not subject to Our control.''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),
                Text(
                  '''Notwithstanding anything contained in this Privacy Policy or elsewhere, We shall not be held responsible for:''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),
                Text(
                  '''a) any security breaches on third-party websites or applications or for any actions of third-parties that receive Your PersonalInformation; or''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),
                Text(
                  '''b) any loss, damage or misuse of Your Personal Information, if such loss, damage or misuse is attributable to a Force Majeure Event. For the purpose of this Privacy Policy, a “Force Majeure Event” shall mean any event that is beyond Our reasonable control and shall include, acts of God, fires, explosions, wars or other hostilities, insurrections, revolutions, strikes, labour unrest, earthquakes, floods, pandemic, epidemics or regulatory or quarantine restrictions, unforeseeable governmental restrictions or controls or a failure by a third party hosting provider or internet service provider or on account of any change or defect in the software and/or hardware of Your computer system.''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),
                Text(
                  '''5) Retention of Your Personal Information: We maintain records of Your Personal Information only till such time it is required for the Purposes, or for as long as required by applicable law. When You request us to delete Your information, we will honour the said request, but we may retain certain information about you for the purposes authorized under thisPrivacy Policy unless prohibited by law.''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),
                Text(
                  '''6) Links to Other Third–Party Sites and collection of information: The Platform may link You to other third-party Platforms (“Third-Party Sites”) that may collect Your Personal Information including Your IP address, browser specification, or operating system. We are not in any manner responsible for the security of such information or their privacy practices or content of those Third-Party Sites. Additionally, You may also encounter “cookies” or other similar devices on certain pages of the Third-Party Sites and it is hereby clarified that the Platform does not control the use of cookies by these Third-Party Sites. These third-party service providers and Third-Party Sites may have their own privacy policies governing the storage and retention of Your information that You may be subject to. This Privacy Policy does not govern any information provided to, stored on, or used by these third-party providers and Third-Party Sites. We recommend that when You enter a Third-Party Site, You review the Third-Party Site’s privacy policy as it relates to safeguarding of Your information. We may use third-party advertising companies to serve ads when You visit the Platform. These companies may use information (not includingYour name, address, email address, or telephone number) about Your visits to the Platform and Third-Party Sites in order to provide advertisements about goods and services of interest to You. You agree and acknowledge that We are not liable for the information published in search results or by any Third-Party Sites.''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),
                Text(
                  '''7) Public Posts: You may provide Your feedback, reviews, testimonials, etc. on the Platform on Your use of the Services (“Posts”). Any content or PersonalInformation and Posts that You share or upload on the publicly viewable portion of the Platform (on discussion boards, in messages and chat areas, etc.) will be publicly available, and can be viewed by other users and any and all intellectual property rights in and to such Posts shall vest with Us. Your Posts shall have to comply with the conditions relating to Posts as mentioned in the Terms. We shall retain an unconditional right to remove and delete any Post or such part of the Post that, in Our opinion, does not comply with the conditions in the Terms or where applicable law requires us to remove such Post. We reserve the right to use, reproduce and share Your Posts for any purpose. If You delete Your Posts from the Platform, copies of such Posts may remain viewable in archived pages, or such Posts may have been copied or stored by other Users.''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),
                Text(
                  '''8) Your Consent, Rectification and Changes to Privacy Policy: Your acknowledgement: All information disclosed by You shall be deemed to be disclosed willingly and without any coercion. No liability pertaining to the authenticity / genuineness / misrepresentation / fraud / negligence of the information disclosed shall lie on Us nor will We be in any way responsible to verify any information obtained from You.''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),
                Text(
                  '''Withdrawal of consent: You may choose to withdraw Your consent provided hereunder at any point in time. You may do the same by visiting Home page ->Settings Icon-> Profile on the mobile application.''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),
                Text(
                  '''In case You do not provide Your consent or later withdraw Your consent, We request You not to access thePlatform, Content or use the Services. We also reserve the right to not provideYou any Services and/or Content on the Platform and/or features of the Platform once You withdraw Your consent. In such a scenario, We will delete Your information (personal or otherwise)or de-identify it so that it is anonymous and not attributable to You. In the event, We retain the Personal Information post withdrawal or cancellation of Your consent, it shall retain it only for the period permitted under applicable laws.''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),
                Text(
                  '''You should be aware that some of the Personal Information that may have been shared on third-party websites may still continue to be available as we do not have control over these websites.Your Personal Information may also appear in online searches. Other Personal Information that You have shared with others, or that other users have copied, may also remain visible. You should only share Personal Information with people that You trust because they will be able to save it or re-share it with others, including when they sync the Personal Information to a device.''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),
                Text(
                  '''Rectification of Your information: You may review, correct, update and change the information that You have provided to Us, at any point by making changes on the mobile application Homepage ->Settings Icon -> Profile. Should You choose to update Your Personal Information or modify it in a way that is not verifiable by Us, or leads to such information being incorrect, We will be unable to provide You with access to the Platform or the Services. We reserve the right to verify and authenticate Your identity and Your Personal Information in order to ensure that We are able to offer You Services and/or make available the Platform. We can only keep Your Personal Information up-to-date and accurate to the extent You provide us with the necessary information. It is Your responsibility to notify Us of any changes in Your Personal Information. Access to or correction, updating or deletion of Your Personal Information may be denied or limited by Us if it would violate another person’s rights and/or is not otherwise permitted by applicable law.''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),
                Text(
                  '''Changes to Our Privacy Policy: We reserve the unconditional right to change, modify, add, or remove portions of this Privacy Policy at any time, and shall provide a notice to You of such changes. Any changes or updates will be effective immediately. You should review this Privacy''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),
                Text(
                  '''Policy regularly for changes. You can determine if changes have been made by checking the “Last Updated” legend above. Your acceptance of the amended Privacy Policy by continuing to visit the Platform or using theServices, shall signify Your consent to such changes and agreement to be legally bound by the same.''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),
                Text(
                  '''9) Grievance Officer:''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),
                Text(
                  '''We have appointed a grievance officer, under authorization, in accordance with the Information Technology Act, 2000 and the rules made thereunder, for the purpose of redressing any grievances or complaints you may have regarding the handling of Your Personal Information. You can contact the designated Grievance Officer for the purpose of this Privacy Policy, namely, Yash Saxena, at medkaro.in@gmail.com. For order related concerns, reach out to medkaro.in@gmail.com.''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),
                Text(
                  '''10) Questions?''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),
                Text(
                  '''Please feel free to contact at this medkaro.in@gmail.com regarding any questions on the Privacy Policy. We will use reasonable efforts to respond promptly to requests, questions or concerns You may have regarding Our use of Your Personal Information. Except where required by law, We cannot ensure a response to questions or comments regarding topics unrelated to this Privacy Policy or the privacy practices specified herein.''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),
                Text(
                  '''Further, please note that the Platform stores Your data with the cloud platform of Amazon Web Services provided by Amazon Web Services, Inc., which may store this data on their servers located outside of India.''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),
                Text(
                  '''Amazon Web Services has security measures in place to protect the loss, misuse and alteration of the information, details of which are available at https://aws.amazon.com/. The privacy policy adopted by Amazon Web Services is detailed inhttps://aws.amazon.com/privacy. In the event You have questions or concerns about the security measures adopted by Amazon Web Services, You can contact their data protection / privacy team / legal team or designated the grievance officer at these organisations, whose contact details are available in its privacy policy, or can also write to Our Grievance Officer at the address provided above.''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),
                Text(
                  '''© 2025 Medkaro, All rights reserved.''',
                  style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),


                
        
                
                
              ],
            ),
          ),
        ),
      ),
    );
    ;
  }
}
