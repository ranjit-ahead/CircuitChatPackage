//
//  CircuitChatPageViewController.swift
//  CircuitChat
//
//  Created by Apple on 19/08/23.
//
import SwiftUI
import UIKit

struct CircuitChatPageVC: View {
    @Binding var selectedMedia: SelectedMedia
    @Binding var currentImage: Int
    
    var body: some View {
        CircuitChatPageViewController(pages: selectedMedia.items.map({ mediaObject in
            MediaVC(selectedMedia: $selectedMedia, mediaObject: mediaObject)
        }), currentPage: $currentImage)
    }
}

struct CircuitChatPageViewController<Page: View>: UIViewControllerRepresentable {
     var pages: [Page]
    @Binding var currentPage: Int

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIPageViewController {
        let pageViewController = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal)
        pageViewController.dataSource = context.coordinator
        pageViewController.delegate = context.coordinator

        return pageViewController
    }

    func updateUIViewController(_ pageViewController: UIPageViewController, context: Context) {
//        context.coordinator.parent = self
        if context.coordinator.controllers.count>currentPage {
            pageViewController.setViewControllers(
                [context.coordinator.controllers[currentPage]], direction: .forward, animated: true)
        }
    }

    class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        var parent: CircuitChatPageViewController
        var controllers = [UIViewController]()

        init(_ pageViewController: CircuitChatPageViewController) {
            parent = pageViewController
            controllers = parent.pages.map { UIHostingController(rootView: $0) }
        }

        func pageViewController(
            _ pageViewController: UIPageViewController,
            viewControllerBefore viewController: UIViewController) -> UIViewController?
        {
            guard let index = controllers.firstIndex(of: viewController) else {
                return nil
            }
            if index == 0 {
                return controllers.last
            }
            return controllers[index - 1]
        }


        func pageViewController(
            _ pageViewController: UIPageViewController,
            viewControllerAfter viewController: UIViewController) -> UIViewController?
        {
            guard let index = controllers.firstIndex(of: viewController) else {
                return nil
            }
            if index + 1 == controllers.count {
                return controllers.first
            }
            return controllers[index + 1]
        }

        func pageViewController(
            _ pageViewController: UIPageViewController,
            didFinishAnimating finished: Bool,
            previousViewControllers: [UIViewController],
            transitionCompleted completed: Bool) {
                if completed,
                   let visibleViewController = pageViewController.viewControllers?.first,
                   let index = controllers.firstIndex(of: visibleViewController) {
                    parent.currentPage = index
                }
            }
    }
}

//struct PageViewController<Page: View>: UIViewControllerRepresentable {
//    @Binding var pages: [Page]
//    @Binding var currentPage: Int
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//
//    func makeUIViewController(context: Context) -> UIPageViewController {
//        let pageViewController = UIPageViewController(
//            transitionStyle: .scroll,
//            navigationOrientation: .horizontal)
//        pageViewController.dataSource = context.coordinator
//        pageViewController.delegate = context.coordinator
//
//        return pageViewController
//    }
//
//    func updateUIViewController(_ pageViewController: UIPageViewController, context: Context) {
//        context.coordinator.updateControllers(with: self, context: context)
//
//        pageViewController.setViewControllers(
//            [context.coordinator.controllers[currentPage]], direction: .forward, animated: true)
//
////        let pageViewController = UIPageViewController(
////            transitionStyle: .scroll,
////            navigationOrientation: .horizontal)
////        pageViewController.dataSource = context.coordinator
////        pageViewController.delegate = context.coordinator
////
////        return pageViewController
//    }
//
//    class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
//        var parent: PageViewController
//        var controllers = [UIViewController]()
//
//        init(_ pageViewController: PageViewController) {
//            parent = pageViewController
//            controllers = parent.pages.map { UIHostingController(rootView: $0) }
//        }
//
//        func updateControllers(with parent: PageViewController, context: Context) {
//            parent.pages = parent.pages
//            controllers = parent.pages.map { UIHostingController(rootView: $0) }
//
//            controllers.first.setViewControllers(
//                [context.coordinator.controllers[currentPage]], direction: .forward, animated: true)
//        }
//
//        func pageViewController(
//            _ pageViewController: UIPageViewController,
//            viewControllerBefore viewController: UIViewController) -> UIViewController?
//        {
//            guard let index = controllers.firstIndex(of: viewController) else {
//                return nil
//            }
//            if index == 0 {
//                return controllers.last
//            }
//            return controllers[index - 1]
//        }
//
//        func pageViewController(
//            _ pageViewController: UIPageViewController,
//            viewControllerAfter viewController: UIViewController) -> UIViewController?
//        {
//            guard let index = controllers.firstIndex(of: viewController) else {
//                return nil
//            }
//            if index + 1 == controllers.count {
//                return controllers.first
//            }
//            return controllers[index + 1]
//        }
//
//        func pageViewController(
//            _ pageViewController: UIPageViewController,
//            didFinishAnimating finished: Bool,
//            previousViewControllers: [UIViewController],
//            transitionCompleted completed: Bool) {
//                if completed,
//                   let visibleViewController = pageViewController.viewControllers?.first,
//                   let index = controllers.firstIndex(of: visibleViewController) {
//                    parent.currentPage = index
//                }
//            }
//    }
//}
