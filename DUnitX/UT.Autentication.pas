unit UT.Autentication;

interface

uses
  System.Classes, System.SysUtils,
  DUnitX.TestFramework,
  FB4D.Interfaces;

{$M+}
type
  [TestFixture]
  UT_Authentication = class(TObject)
  private
    fConfig: IFirebaseConfiguration;
    fUser: IFirebaseUser;
    fErrMsg: string;
    fReqID: string;
    fInfo: string;
    fEMail: string;
    fIsRegistered: boolean;
    fProviders: string;
    fCallBack: boolean;
    procedure OnUserResponse(const Info: string; User: IFirebaseUser);
    procedure OnError(const RequestID, ErrMsg: string);
    procedure OnFetchProviders(const EMail: string; IsRegistered: boolean;
      Providers: TStrings);
    procedure OnResp(const RequestID: string; Response: IFirebaseResponse);
    procedure OnGetUserData(FirebaseUserList: TFirebaseUserList);
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
  published
    [TestCase]
    procedure SignUpWithEmailAndPasswordSynchronous;
    procedure SignUpWithEmailAndPassword;
    procedure SignInWithEmailAndPasswordSynchronous;
    procedure SignInWithEmailAndPassword;
    procedure SignInAnonymouslySynchronous;
    procedure SignInAnonymously;
    procedure LinkWithEMailAndPasswordSynchronous;
    procedure LinkWithEMailAndPassword;
    procedure FetchProvidersForEMailSynchronous;
    procedure FetchProvidersForEMail;
    procedure ChangeProfileSynchronousAndGetUserDataSynchronous;
    procedure ChangeProfileAndGetUserData;
  end;

implementation

uses
  VCL.Forms,
  FB4D.Configuration;

{$I FBConfig.inc}

const
  cEMail = 'Integration.Tester@FB4D.org';
  cPassword = 'It54623!';
  cDisplayName = 'The Tester';
  cPhotoURL = 'https://www.schneider-infosys.ch/img/Christoph.png';

procedure UT_Authentication.Setup;
begin
  fConfig := TFirebaseConfiguration.Create(cApiKey, cProjectID, cBucket);
  fUser := nil;
  fErrMsg := '';
  fReqID := '';
  fInfo := '';
  fEMail := '';
  fIsRegistered := false;
  fProviders := '';
  fCallBack := false;
end;

procedure UT_Authentication.TearDown;
begin
  if assigned(fUser) then
    fConfig.Auth.DeleteCurrentUserSynchronous;
  fUser := nil;
  fConfig := nil;
end;

{ Call back }
procedure UT_Authentication.OnError(const RequestID, ErrMsg: string);
begin
  fReqID := RequestID;
  fErrMsg := ErrMsg;
  fCallBack := true;
end;

procedure UT_Authentication.OnUserResponse(const Info: string;
  User: IFirebaseUser);
begin
  fInfo := Info;
  fUser := User;
  fCallBack := true;
end;

procedure UT_Authentication.OnFetchProviders(const EMail: string;
  IsRegistered: boolean; Providers: TStrings);
begin
  fEMail := EMail;
  fIsRegistered := IsRegistered;
  fProviders := Providers.CommaText;
  fCallBack := true;
end;

procedure UT_Authentication.OnResp(const RequestID: string;
  Response: IFirebaseResponse);
begin
  fReqID := RequestID;
  fCallBack := true;
end;

procedure UT_Authentication.OnGetUserData(FirebaseUserList: TFirebaseUserList);
begin
  if FirebaseUserList.Count < 1 then
    fUser := nil
  else
    fUser := FirebaseUserList.Items[0];
  fCallBack := true;
end;
{ Test Cases }

procedure UT_Authentication.SignUpWithEmailAndPasswordSynchronous;
begin
  fUser := fConfig.Auth.SignUpWithEmailAndPasswordSynchronous(cEmail, cPassword);
  Assert.IsNotNull(fUser, 'No user created');
  Assert.IsTrue(fUser.IsEMailAvailable, 'No EMail');
  Assert.AreEqual(fUser.EMail, cEMail, 'Wrong EMail');
  Assert.IsNotEmpty(fUser.UID, 'UID is empty');
  Assert.IsNotEmpty(fUSer.Token, 'Token is empty');
end;

procedure UT_Authentication.SignUpWithEmailAndPassword;
begin
  fConfig.Auth.SignUpWithEmailAndPassword(cEmail, cPassword, OnUserResponse,
    OnError);
  while not fCallBack do
    Application.ProcessMessages;
  Assert.IsNotNull(fUser, 'No user created');
  Assert.IsTrue(fUser.IsEMailAvailable, 'No EMail');
  Assert.AreEqual(fUser.EMail, cEMail, 'Wrong EMail');
  Assert.IsNotEmpty(fUser.UID, 'UID is empty');
  Assert.IsNotEmpty(fUSer.Token, 'Token is empty');
end;

procedure UT_Authentication.SignInWithEmailAndPasswordSynchronous;
begin
  // precondition is a created user
  SignUpWithEmailAndPasswordSynchronous;
  fConfig.Auth.SignOut;
  fUser := nil;
  // start test
  fUser := fConfig.Auth.SignInWithEmailAndPasswordSynchronous(cEmail, cPassword);
  Assert.IsNotNull(fUser, 'No user created');
  Assert.IsTrue(fUser.IsEMailAvailable, 'No EMail');
  Assert.AreEqual(fUser.EMail, cEMail, 'Wrong EMail');
  Assert.IsNotEmpty(fUser.UID, 'UID is empty');
  Assert.IsNotEmpty(fUSer.Token, 'Token is empty');
end;

procedure UT_Authentication.SignInWithEmailAndPassword;
begin
  // precondition is a created user
  SignUpWithEmailAndPasswordSynchronous;
  fConfig.Auth.SignOut;
  fUser := nil;
  // start test
  fConfig.Auth.SignInWithEmailAndPassword(cEmail, cPassword, OnUserResponse,
    OnError);
  while not fCallBack do
    Application.ProcessMessages;
  Assert.IsNotNull(fUser, 'No user created');
  Assert.IsTrue(fUser.IsEMailAvailable, 'No EMail');
  Assert.AreEqual(fUser.EMail, cEMail, 'Wrong EMail');
  Assert.IsNotEmpty(fUser.UID, 'UID is empty');
  Assert.IsNotEmpty(fUSer.Token, 'Token is empty');
end;

procedure UT_Authentication.SignInAnonymouslySynchronous;
begin
  fUser := fConfig.Auth.SignInAnonymouslySynchronous;
  Assert.IsNotNull(fUser, 'No user created');
  Assert.IsFalse(fUser.IsEMailAvailable, 'Unexpected EMail');
  Assert.IsNotEmpty(fUser.UID, 'UID is empty');
  Assert.IsNotEmpty(fUSer.Token, 'Token is empty');
end;

procedure UT_Authentication.SignInAnonymously;
begin
  fConfig.Auth.SignInAnonymously(OnUserResponse, OnError);
  while not fCallBack do
    Application.ProcessMessages;
  Assert.IsNotNull(fUser, 'No user created');
  Assert.IsFalse(fUser.IsEMailAvailable, 'Unexpected EMail');
  Assert.IsNotEmpty(fUser.UID, 'UID is empty');
  Assert.IsNotEmpty(fUSer.Token, 'Token is empty');
end;

procedure UT_Authentication.LinkWithEMailAndPasswordSynchronous;
begin
  // precondition is an anonymous user
  SignInAnonymouslySynchronous;
  // start test
  fUser := fConfig.Auth.LinkWithEMailAndPasswordSynchronous(cEmail, cPassword);
  Assert.IsNotNull(fUser, 'No user created');
  // re-login
  fUser := fConfig.Auth.SignInWithEmailAndPasswordSynchronous(cEmail, cPassword);
  Assert.IsNotNull(fUser, 'No user created');
  Assert.IsTrue(fUser.IsEMailAvailable, 'No EMail');
  Assert.AreEqual(fUser.EMail, cEMail, 'Wrong EMail');
  Assert.IsNotEmpty(fUser.UID, 'UID is empty');
  Assert.IsNotEmpty(fUSer.Token, 'Token is empty');
end;

procedure UT_Authentication.LinkWithEMailAndPassword;
begin
  // precondition is an anonymous user
  SignInAnonymouslySynchronous;
  // start test
  fConfig.Auth.LinkWithEMailAndPassword(cEmail, cPassword, OnUserResponse,
    OnError);
  while not fCallBack do
    Application.ProcessMessages;
  Assert.IsNotNull(fUser, 'No user created');
  // re-login
  fUser := fConfig.Auth.SignInWithEmailAndPasswordSynchronous(cEmail, cPassword);
  Assert.IsNotNull(fUser, 'No user created');
  Assert.IsTrue(fUser.IsEMailAvailable, 'No EMail');
  Assert.AreEqual(fUser.EMail, cEMail, 'Wrong EMail');
  Assert.IsNotEmpty(fUser.UID, 'UID is empty');
  Assert.IsNotEmpty(fUSer.Token, 'Token is empty');
end;

procedure UT_Authentication.FetchProvidersForEMailSynchronous;
var
  strs: TStringList;
begin
  // precondition is a created user
  SignUpWithEmailAndPasswordSynchronous;
  // start test
  strs := TStringList.Create;
  try
    fConfig.Auth.FetchProvidersForEMailSynchronous(cEMail, strs);
    Assert.IsTrue(Pos('password', strs.CommaText) > 0,
      'Password provider missing');
  finally
    strs.Free;
  end;
end;

procedure UT_Authentication.FetchProvidersForEMail;
begin
  // precondition is a created user
  SignUpWithEmailAndPasswordSynchronous;
  fConfig.Auth.FetchProvidersForEMail(cEMail, OnFetchProviders, OnError);
  while not fCallBack do
    Application.ProcessMessages;
  Assert.IsNotNull(fUser, 'No user created');
  Assert.IsTrue(fIsRegistered, 'EMail not registered');
  Assert.AreEqual(fEMail, cEMail, 'Wrong EMail');
  Assert.IsTrue(Pos('password', fProviders) > 0, 'Password provider missing');
end;

procedure UT_Authentication.ChangeProfileSynchronousAndGetUserDataSynchronous;
var
  fUsers: TFirebaseUserList;
begin
  // precondition is a created user
  fUser := fConfig.Auth.SignUpWithEmailAndPasswordSynchronous(cEmail, cPassword);
  Assert.IsNotNull(fUser, 'No user created');
  Assert.IsTrue(fUser.IsEMailAvailable, 'No EMail');
  Assert.AreEqual(fUser.EMail, cEMail, 'Wrong EMail');
  Assert.IsNotEmpty(fUser.UID, 'UID is empty');
  Assert.IsNotEmpty(fUSer.Token, 'Token is empty');
  // start test
  fConfig.Auth.ChangeProfileSynchronous('', '', cDisplayName, cPhotoURL);

  fUsers := fConfig.Auth.GetUserDataSynchronous;
  Assert.AreEqual(fUsers.Count, 1 ,'No one user as expected');
  fUser := fUsers.Items[0];
  Assert.IsNotNull(fUser, 'No user created');
  Assert.IsTrue(fUser.IsEMailAvailable, 'No EMail');
  Assert.AreEqual(fUser.EMail, cEMail, 'Wrong EMail');
  Assert.IsNotEmpty(fUser.UID, 'UID is empty');
  Assert.IsTrue(fUser.IsDisplayNameAvailable, 'Display name not available');
  Assert.AreEqual(fUser.DisplayName, cDisplayName, 'Wrong Display Name');
  Assert.IsTrue(fUser.IsPhotoURLAvailable, 'Photo url not available');
  Assert.AreEqual(fUser.PhotoURL, cPhotoURL, 'Wrong Photo URL');
end;

procedure UT_Authentication.ChangeProfileAndGetUserData;
begin
  // precondition is a created user
  fUser := fConfig.Auth.SignUpWithEmailAndPasswordSynchronous(cEmail, cPassword);
  Assert.IsNotNull(fUser, 'No user created');
  Assert.IsTrue(fUser.IsEMailAvailable, 'No EMail');
  Assert.AreEqual(fUser.EMail, cEMail, 'Wrong EMail');
  Assert.IsNotEmpty(fUser.UID, 'UID is empty');
  Assert.IsNotEmpty(fUSer.Token, 'Token is empty');
  // start test
  fConfig.Auth.ChangeProfile('', '', cDisplayName, cPhotoURL, OnResp, OnError);
  while not fCallBack do
    Application.ProcessMessages;
  fCallBack := false;
  fConfig.Auth.GetUserData(OnGetUserData, OnError);
  while not fCallBack do
    Application.ProcessMessages;
  Assert.IsNotNull(fUser, 'No user created');
  Assert.IsTrue(fUser.IsEMailAvailable, 'No EMail');
  Assert.AreEqual(fUser.EMail, cEMail, 'Wrong EMail');
  Assert.IsNotEmpty(fUser.UID, 'UID is empty');
  Assert.IsTrue(fUser.IsDisplayNameAvailable, 'Display name not available');
  Assert.AreEqual(fUser.DisplayName, cDisplayName, 'Wrong Display Name');
  Assert.IsTrue(fUser.IsPhotoURLAvailable, 'Photo url not available');
  Assert.AreEqual(fUser.PhotoURL, cPhotoURL, 'Wrong Photo URL');
end;

initialization
  TDUnitX.RegisterTestFixture(UT_Authentication);
end.
