//
//  OnboardingViewController.swift
//  AboutXTime
//
//  Created by Nicky Y on 2024/10/14.
//

import Foundation
import UIKit

class OnboardingViewController: UIPageViewController {

    private var pages = [UIViewController]()
    private var pageControl = UIPageControl()
    var onOnboardingComplete: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black
        dataSource = self
        delegate = self

        pages.append(createPage(title: "創建膠囊送給自己",
                                description: "透過記錄和追蹤每一個重要時刻，無論是想法、目標還是成長歷程，幫助您重新認識自己，見證自己的成長與蛻變。這是一段陪伴您的旅程，讓未來的您更加自信且堅定！",
                                imageName: "planet4"))
        pages.append(createPage(title: "創建膠囊送給對方",
                                description: "透過這個功能，您可以將最珍貴的情感瞬間保存下來，並在特別的時刻與對方分享。這是一個讓感情持續升溫的秘密武器，讓重要的關係不隨時間而淡去，而是隨著時光變得更加深厚。",
                                imageName: "planet3"))
        pages.append(createFinalPage())

        setViewControllers([pages[0]], direction: .forward, animated: true, completion: nil)

        let skipButton = UIButton(frame: CGRect(x: view.frame.width - 80, y: 50, width: 70, height: 30))
        skipButton.setTitle("跳過", for: .normal)
        skipButton.setTitleColor(STColor.C1.uiColor, for: .normal)
        skipButton.addTarget(self, action: #selector(skipTapped), for: .touchUpInside)
        view.addSubview(skipButton)

        setupPageControl()

        updateSkipButtonVisibility(skipButton)
    }

    @objc private func skipTapped() {
        onOnboardingComplete?()
    }

    private func updateSkipButtonVisibility(_ skipButton: UIButton) {
        if pageControl.currentPage == pages.count - 1 {
            skipButton.isHidden = true
        } else {
            skipButton.isHidden = false
        }
    }

    private func createPage(title: String, description: String, imageName: String) -> UIViewController {
        let pageVC = UIViewController()
        pageVC.view.backgroundColor = .black

        let bgView = UIView()
        bgView.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        bgView.layer.cornerRadius = 20
        bgView.translatesAutoresizingMaskIntoConstraints = false
        pageVC.view.addSubview(bgView)

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.textColor = STColor.CC2.uiColor
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        pageVC.view.addSubview(titleLabel)

        let descriptionLabel = UILabel()
        let attributedString = NSMutableAttributedString(string: description)
        let paragraphStyle = NSMutableParagraphStyle()

        paragraphStyle.lineSpacing = 5

        attributedString.addAttribute(.paragraphStyle,
                                      value: paragraphStyle,
                                      range: NSRange(location: 0, length: description.count))

        attributedString.addAttribute(.kern, value: 1.2, range: NSRange(location: 0, length: description.count))

        descriptionLabel.attributedText = attributedString

        descriptionLabel.font = UIFont.systemFont(ofSize: 16)
        descriptionLabel.textColor = .white
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .left
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false

        pageVC.view.addSubview(descriptionLabel)

        let imageView = UIImageView(image: UIImage(named: imageName))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        pageVC.view.addSubview(imageView)

        NSLayoutConstraint.activate([

            bgView.topAnchor.constraint(equalTo: descriptionLabel.topAnchor, constant: -20),
            bgView.bottomAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20),
            bgView.leadingAnchor.constraint(equalTo: descriptionLabel.leadingAnchor, constant: -20),
            bgView.trailingAnchor.constraint(equalTo: descriptionLabel.trailingAnchor, constant: 20),

            imageView.topAnchor.constraint(equalTo: pageVC.view.safeAreaLayoutGuide.topAnchor, constant: 50),
            imageView.leadingAnchor.constraint(equalTo: pageVC.view.leadingAnchor, constant: 20),
            imageView.trailingAnchor.constraint(equalTo: pageVC.view.trailingAnchor, constant: -20),
            imageView.heightAnchor.constraint(equalToConstant: 200),

            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 60),
            titleLabel.leadingAnchor.constraint(equalTo: pageVC.view.leadingAnchor, constant: 40),
            titleLabel.trailingAnchor.constraint(equalTo: pageVC.view.trailingAnchor, constant: -40),

            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 60),
            descriptionLabel.leadingAnchor.constraint(equalTo: pageVC.view.leadingAnchor, constant: 80),
            descriptionLabel.trailingAnchor.constraint(equalTo: pageVC.view.trailingAnchor, constant: -80)
        ])

        return pageVC
    }

    private func createFinalPage() -> UIViewController {
        let pageVC = UIViewController()
        pageVC.view.backgroundColor = .black

        let titleLabel = UILabel()
        titleLabel.text = "與多位好友共同創建"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.textColor = STColor.CC2.uiColor
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        pageVC.view.addSubview(titleLabel)

        let bgView = UIView()
        bgView.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        bgView.layer.cornerRadius = 20
        bgView.translatesAutoresizingMaskIntoConstraints = false
        pageVC.view.addSubview(bgView)

        let descriptionLabel = UILabel()
        let descriptionText = "與好友們一起創造專屬的回憶膠囊，將每一個有趣、溫暖的時刻鎖住。未來某天一起開啟，喚起那些被時間藏起來的回憶，增強彼此的連結，為友情添上更多驚喜和感動！"

        let attributedString = NSMutableAttributedString(string: descriptionText)
        let paragraphStyle = NSMutableParagraphStyle()

        paragraphStyle.lineSpacing = 5

        attributedString.addAttribute(.paragraphStyle,
                                      value: paragraphStyle,
                                      range: NSRange(location: 0, length: descriptionText.count))

        attributedString.addAttribute(.kern, value: 1.2, range: NSRange(location: 0, length: descriptionText.count))

        descriptionLabel.attributedText = attributedString

        descriptionLabel.font = UIFont.systemFont(ofSize: 16)
        descriptionLabel.textColor = .white
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .left
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false

        pageVC.view.addSubview(descriptionLabel)

        let imageView = UIImageView(image: UIImage(named: "planet5"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        pageVC.view.addSubview(imageView)

        let finishButton = UIButton(type: .system)
        finishButton.setTitle("開始使用", for: .normal)
        finishButton.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        finishButton.layer.borderColor = STColor.C1.uiColor.cgColor
        finishButton.layer.borderWidth = 1
        finishButton.setTitleColor(.white, for: .normal)
        finishButton.layer.cornerRadius = 10
        finishButton.translatesAutoresizingMaskIntoConstraints = false
        finishButton.addTarget(self, action: #selector(finishTapped), for: .touchUpInside)
        pageVC.view.addSubview(finishButton)

        NSLayoutConstraint.activate([

            bgView.topAnchor.constraint(equalTo: descriptionLabel.topAnchor, constant: -20),
            bgView.bottomAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20),
            bgView.leadingAnchor.constraint(equalTo: descriptionLabel.leadingAnchor, constant: -20),
            bgView.trailingAnchor.constraint(equalTo: descriptionLabel.trailingAnchor, constant: 20),

            imageView.topAnchor.constraint(equalTo: pageVC.view.safeAreaLayoutGuide.topAnchor, constant: 50),
            imageView.leadingAnchor.constraint(equalTo: pageVC.view.leadingAnchor, constant: 20),
            imageView.trailingAnchor.constraint(equalTo: pageVC.view.trailingAnchor, constant: -20),
            imageView.heightAnchor.constraint(equalToConstant: 200),

            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 60),
            titleLabel.leadingAnchor.constraint(equalTo: pageVC.view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: pageVC.view.trailingAnchor, constant: -20),

            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 60),
            descriptionLabel.leadingAnchor.constraint(equalTo: pageVC.view.leadingAnchor, constant: 80),
            descriptionLabel.trailingAnchor.constraint(equalTo: pageVC.view.trailingAnchor, constant: -80),

            finishButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 80),
            finishButton.centerXAnchor.constraint(equalTo: pageVC.view.centerXAnchor),
            finishButton.widthAnchor.constraint(equalToConstant: 200),
            finishButton.heightAnchor.constraint(equalToConstant: 50)
        ])

        return pageVC
    }

    @objc private func finishTapped() {
        onOnboardingComplete?()
    }

    private func setupPageControl() {
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.currentPageIndicatorTintColor = STColor.C1.uiColor
        pageControl.pageIndicatorTintColor = STColor.C1.uiColor.withAlphaComponent(0.3)
        view.addSubview(pageControl)

        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}

// MARK: - UIPageViewControllerDataSource
extension OnboardingViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController), index > 0 else {
            return nil
        }
        return pages[index - 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController), index < pages.count - 1 else {
            return nil
        }
        return pages[index + 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        guard completed, let currentVC = viewControllers?.first,
              let index = pages.firstIndex(of: currentVC) else {
            return
        }

        pageControl.currentPage = index

        if let skipButton = view.subviews.first(where: { $0 is UIButton }) as? UIButton {
            updateSkipButtonVisibility(skipButton)
        }
    }
}
