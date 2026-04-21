declare function initGeetest4(options: any, callback: (captchaObj: any) => void): void
export class GeetestUtils {
  private captchaObj: any
  private onSuccessCallback: (result: any) => void

  constructor(private captchaId: string = '5a071071606e0a97b72ebb208aae92af', private product: string = 'bind', onSuccessCallback: (result: any) => void = () => {}) {
    this.onSuccessCallback = onSuccessCallback
  }

  public initCaptcha(): Promise<void> {
    return new Promise((resolve, reject) => {
      const script = document.createElement('script')
      script.src = 'https://static.geetest.com/v4/gt4.js'
      script.onload = () => {
        initGeetest4({
          captchaId: this.captchaId,
          product: this.product
        }, (captchaObj: any) => {
          this.captchaObj = captchaObj
          this.captchaObj.onReady(() => {
            const feedbackElement = document.querySelector('.geetest_feedback') as HTMLElement
            if (feedbackElement) {
              feedbackElement.style.display = 'none'
            }
            const logoElement = document.querySelector('.geetest_box_logo') as HTMLElement
            if (logoElement) {
              logoElement.style.display = 'none'
            }
            resolve()
          }).onSuccess(() => {
            const result = this.captchaObj.getValidate()
            // 调用传入的 onSuccess 回调
            this.onSuccessCallback(result)
            // 重置验证码
            this.captchaObj.reset()
          }).onError(() => {
            // 处理错误
            reject(new Error('验证码加载失败'))
          })
        })
      }
      script.onerror = () => {
        reject(new Error('验证码脚本加载失败'))
      }
      document.head.appendChild(script)
    })
  }

  public showCaptcha(): void {
    if (this.captchaObj) {
      this.captchaObj.showCaptcha()
    }
  }

  public getCaptchaObj(): any {
    return this.captchaObj
  }
}
