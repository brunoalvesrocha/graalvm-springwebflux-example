package com.example.demo;

import java.util.List;
import java.util.function.BiFunction;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import lombok.extern.slf4j.Slf4j;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import reactor.core.scheduler.Schedulers;

@Service
@Slf4j
@Transactional
public class UserService {

	@Autowired
	private UserRepository userRepository;

	@Autowired
	private DepartmentRepository departmentRepository;

	public Mono<User> createUser(User user) {
		return userRepository.save(user);
	}

	public Flux<User> getAllUsers() {
		return userRepository.findAll();
	}

	public Mono<User> findById(Long userId) {
		return userRepository.findById(userId);
	}

	public Mono<User> updateUser(Long userId, User user) {
		return userRepository.findById(userId).flatMap(dbUser -> {
			dbUser.setAge(user.getAge());
			dbUser.setSalary(user.getSalary());
			return userRepository.save(dbUser);
		});
	}

	public Mono<User> deleteUser(Long userId) {
		return userRepository.findById(userId)
				.flatMap(existingUser -> userRepository.delete(existingUser)
						.then(Mono.just(existingUser)));
	}

	public Flux<User> findUsersByAge(int age) {
		return userRepository.findByAge(age);
	}

	private Mono<Department> getDepartmentByUserId(Long userId) {
		return departmentRepository.findByUserId(userId);
	}

	public Mono<UserDepartmentDTO> fetchUserAndDepartment(Long userId) {
		Mono<User> user = findById(userId).subscribeOn(Schedulers.elastic());
		Mono<Department> department = getDepartmentByUserId(userId).subscribeOn(Schedulers.elastic());
		return Mono.zip(user, department, userDepartmentDTOBiFunction);
	}

	private BiFunction<User, Department, UserDepartmentDTO> userDepartmentDTOBiFunction = (x1, x2) -> UserDepartmentDTO
			.builder().age(x1.getAge()).departmentId(x2.getId()).departmentName(x2.getName()).userName(x1.getName())
			.userId(x1.getId()).loc(x2.getLoc()).salary(x1.getSalary()).build();

}